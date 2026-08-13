const { FieldValue, Timestamp } = require("firebase-admin/firestore");
const { getAppCheck } = require("firebase-admin/app-check");
const { getAuth } = require("firebase-admin/auth");
const { Environment, SignedDataVerifier } = require("@apple/app-store-server-library");

const productIDs = new Set([
    "com.ruslanabdulov.momsy.premium.monthly",
    "com.ruslanabdulov.momsy.premium.annual",
]);
const bundleID = "RuslanAbd.Momsy";
const appleRootCAs = [
    Buffer.from(`-----BEGIN CERTIFICATE-----
MIICQzCCAcmgAwIBAgIILcX8iNLFS5UwCgYIKoZIzj0EAwMwZzEbMBkGA1UEAwwS
QXBwbGUgUm9vdCBDQSAtIEczMSYwJAYDVQQLDB1BcHBsZSBDZXJ0aWZpY2F0aW9u
IEF1dGhvcml0eTETMBEGA1UECgwKQXBwbGUgSW5jLjELMAkGA1UEBhMCVVMwHhcN
MTQwNDMwMTgxOTA2WhcNMzkwNDMwMTgxOTA2WjBnMRswGQYDVQQDDBJBcHBsZSBS
b290IENBIC0gRzMxJjAkBgNVBAsMHUFwcGxlIENlcnRpZmljY2F0aW9uIEF1
aG9yaXR5MRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUzB2MBAGByqG
SM49AgEGBSuBBAAiA2IABJjpLz1AcqTtkyJygRMc3RCV8cWjTnHcFBbZDuWmBSp3
ZHtfTjjTuxxEtX/1H7YyYl3J6YRbTzBPEVoA/VhYDKX1DyxNB0cTddqXl5dvMVzt
K517IDvYuVTZXpmkOlEKMaNCMEAwHQYDVR0OBBYEFLuw3qFYM4iapIqZ3r6966/a
yySrMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMAoGCCqGSM49BAMD
A2gAMGUCMQCD6cHEFl4aXTQY2e3v9GwOAEZLuN+yRhHFD/3meoyhpmvOwgPUnPWT
xnS4at+qIxUCMG1mihDK1A3UT82NQz60imOlM27jbdoXt2QfyFMm+YhidDkLF1vL
UagM6BgD56KyKA==
-----END CERTIFICATE-----`),
];

function premiumEntitlementFor(transaction, now = new Date()) {
    const expiresDate = Number(transaction.expiresDate ?? 0);
    const originalTransactionId = transaction.originalTransactionId;
    const isKnownProduct = productIDs.has(transaction.productId);
    const isActive = isKnownProduct
        && typeof originalTransactionId === "string"
        && originalTransactionId.length > 0
        && Number.isFinite(expiresDate)
        && expiresDate > now.getTime()
        && transaction.revocationDate == null;
    return {
        isActive,
        isKnownProduct,
        originalTransactionId,
        productId: transaction.productId,
        expiresDate,
        revocationDate: transaction.revocationDate == null ? null : Number(transaction.revocationDate),
    };
}

async function verifyTransaction(signedTransaction) {
    const appAppleId = process.env.APPLE_APP_ID ? Number(process.env.APPLE_APP_ID) : undefined;
    const environments = [Environment.SANDBOX, Environment.PRODUCTION];
    let lastError;
    for (const environment of environments) {
        try {
            if (environment === Environment.PRODUCTION && !appAppleId) continue;
            const verifier = new SignedDataVerifier(
                appleRootCAs,
                true,
                environment,
                bundleID,
                environment === Environment.PRODUCTION ? appAppleId : undefined
            );
            return await verifier.verifyAndDecodeTransaction(signedTransaction);
        } catch (error) {
            lastError = error;
        }
    }
    throw lastError ?? new Error("Could not verify App Store transaction");
}

async function authorizeRequest(request) {
    const authorization = request.get("Authorization") ?? "";
    const idToken = authorization.startsWith("Bearer ") ? authorization.slice(7) : "";
    const appCheckToken = request.get("X-Firebase-AppCheck");
    if (!idToken || !appCheckToken) throw new Error("Missing Firebase credentials");
    const [auth, appCheck] = await Promise.all([
        getAuth().verifyIdToken(idToken),
        getAppCheck().verifyToken(appCheckToken),
    ]);
    if (!auth.uid || !appCheck.appId) throw new Error("Invalid Firebase credentials");
    return auth.uid;
}

function recordData(entitlement, uid, familyId) {
    return {
        ownerUid: uid,
        familyId,
        productId: entitlement.productId,
        expiresAt: Timestamp.fromMillis(Math.max(0, entitlement.expiresDate)),
        revokedAt: entitlement.revocationDate == null
            ? null
            : Timestamp.fromMillis(Math.max(0, entitlement.revocationDate)),
        updatedAt: FieldValue.serverTimestamp(),
    };
}

function isActiveRecord(data, now) {
    const expiresAt = data.expiresAt instanceof Timestamp ? data.expiresAt.toMillis() : 0;
    return expiresAt > now.getTime() && !(data.revokedAt instanceof Timestamp);
}

function updateFamilyPremium(transaction, db, familyId, entitlements, replacement) {
    const candidates = entitlements.docs
        .filter((document) => document.id !== replacement.id)
        .map((document) => ({ id: document.id, ...document.data() }));
    if (replacement.familyId === familyId) candidates.push(replacement);

    const active = candidates
        .filter((entitlement) => isActiveRecord(entitlement, new Date()))
        .sort((left, right) => right.expiresAt.toMillis() - left.expiresAt.toMillis())[0];
    const familyRef = db.collection("families").doc(familyId);
    if (!active) {
        transaction.set(familyRef, { premiumEntitlement: FieldValue.delete() }, { merge: true });
        return;
    }
    transaction.set(familyRef, {
        premiumEntitlement: {
            originalTransactionId: active.id,
            productId: active.productId,
            expiresAt: active.expiresAt,
            revokedAt: active.revokedAt ?? null,
        },
    }, { merge: true });
}

async function bindEntitlementToCurrentFamily(db, uid, entitlement) {
    const entitlementRef = db.collection("subscriptionEntitlements")
        .doc(entitlement.originalTransactionId);
    await db.runTransaction(async (transaction) => {
        const userRef = db.collection("users").doc(uid);
        const [user, existing] = await Promise.all([
            transaction.get(userRef),
            transaction.get(entitlementRef),
        ]);
        const familyId = user.get("familyId");
        if (typeof familyId !== "string" || familyId.length === 0) {
            throw new Error("No active Momsy family");
        }
        const member = await transaction.get(
            db.collection("families").doc(familyId).collection("members").doc(uid)
        );
        if (!member.exists) throw new Error("User is not a current family member");
        if (existing.exists && existing.get("ownerUid") !== uid) {
            throw new Error("Subscription belongs to another Momsy account");
        }

        const previousFamilyId = existing.get("familyId");
        const replacement = {
            id: entitlement.originalTransactionId,
            ...recordData(entitlement, uid, familyId),
        };
        const familyIDsToUpdate = new Set([familyId]);
        if (typeof previousFamilyId === "string" && previousFamilyId !== familyId) {
            familyIDsToUpdate.add(previousFamilyId);
        }
        const entitlementSnapshots = await Promise.all(
            [...familyIDsToUpdate].map((id) => transaction.get(
                db.collection("subscriptionEntitlements").where("familyId", "==", id)
            ))
        );
        const write = { ...replacement };
        if (write.revokedAt === null) {
            if (existing.exists) write.revokedAt = FieldValue.delete();
            else delete write.revokedAt;
        }
        transaction.set(entitlementRef, write, { merge: true });
        const entitlementsByFamilyID = new Map(
            [...familyIDsToUpdate].map((id, index) => [id, entitlementSnapshots[index]])
        );
        updateFamilyPremium(transaction, db, familyId, entitlementsByFamilyID.get(familyId), replacement);
        if (typeof previousFamilyId === "string" && previousFamilyId !== familyId) {
            updateFamilyPremium(
                transaction,
                db,
                previousFamilyId,
                entitlementsByFamilyID.get(previousFamilyId),
                replacement
            );
        }
    });
}

async function detachFamilyEntitlements(db, familyId, uid) {
    const entitlements = await db.collection("subscriptionEntitlements")
        .where("familyId", "==", familyId)
        .get();
    const ownedEntitlements = entitlements.docs.filter((document) => document.get("ownerUid") === uid);
    if (ownedEntitlements.length === 0) return;
    const batch = db.batch();
    for (const document of ownedEntitlements) {
        batch.update(document.ref, { familyId: "", updatedAt: FieldValue.serverTimestamp() });
    }
    await batch.commit();
    await db.runTransaction(async (transaction) => {
        const currentEntitlements = await transaction.get(
            db.collection("subscriptionEntitlements").where("familyId", "==", familyId)
        );
        updateFamilyPremium(transaction, db, familyId, currentEntitlements, { id: "", familyId: "" });
    });
}

module.exports = {
    authorizeRequest,
    bindEntitlementToCurrentFamily,
    detachFamilyEntitlements,
    premiumEntitlementFor,
    verifyTransaction,
};
