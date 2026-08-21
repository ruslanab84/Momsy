const { createHash, X509Certificate } = require("node:crypto");
const { readFileSync } = require("node:fs");
const path = require("node:path");
const { FieldValue, Timestamp } = require("firebase-admin/firestore");
const { getAppCheck } = require("firebase-admin/app-check");
const { getAuth } = require("firebase-admin/auth");
const { defineInt } = require("firebase-functions/params");
const {
    Environment,
    SignedDataVerifier,
    VerificationException,
    VerificationStatus,
} = require("@apple/app-store-server-library");

const productIDs = new Set([
    "com.ruslanabdulov.momsy.premium.monthly",
    "com.ruslanabdulov.momsy.premium.annual",
]);
const bundleID = "RuslanAbd.Momsy";
const appleAppID = defineInt("APPLE_APP_ID", { default: 6784641297 });
const appleRootCAHash = "63343abfb89a6a03ebb57e9b3f5fa7be7c4f5c756f3017b3a8c488c3653e9179";

function appAccountTokenFor(uid) {
    const bytes = Buffer.from(createHash("sha256")
        .update(`${bundleID}:${uid}`)
        .digest()
        .subarray(0, 16));
    bytes[6] = (bytes[6] & 0x0f) | 0x50;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    const hex = bytes.toString("hex");
    return [
        hex.slice(0, 8),
        hex.slice(8, 12),
        hex.slice(12, 16),
        hex.slice(16, 20),
        hex.slice(20),
    ].join("-");
}

function matchesAppAccountToken(entitlement, uid) {
    if (entitlement.appAccountToken == null) return true;
    return typeof entitlement.appAccountToken === "string"
        && entitlement.appAccountToken.toLowerCase() === appAccountTokenFor(uid);
}

class EntitlementError extends Error {
    constructor(code, httpStatus, publicMessage, retryable = false, cause) {
        super(publicMessage, cause ? { cause } : undefined);
        this.name = "EntitlementError";
        this.code = code;
        this.httpStatus = httpStatus;
        this.publicMessage = publicMessage;
        this.retryable = retryable;
    }
}

function loadAppleRootCAs() {
    const certificate = readFileSync(path.join(__dirname, "certs", "AppleRootCA-G3.cer"));
    const hash = createHash("sha256").update(certificate).digest("hex");
    const root = new X509Certificate(certificate);
    if (hash !== appleRootCAHash || root.subject !== root.issuer || !root.verify(root.publicKey)) {
        throw new Error("Apple Root CA G3 failed integrity validation");
    }
    return [certificate];
}

const appleRootCAs = loadAppleRootCAs();

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
        appAccountToken: transaction.appAccountToken ?? null,
        expiresDate,
        revocationDate: transaction.revocationDate == null ? null : Number(transaction.revocationDate),
    };
}

function verificationError(error) {
    if (error instanceof EntitlementError) return error;
    if (error instanceof VerificationException
        && error.status === VerificationStatus.RETRYABLE_VERIFICATION_FAILURE) {
        return new EntitlementError(
            "verification_unavailable",
            503,
            "App Store verification is temporarily unavailable.",
            true,
            error
        );
    }
    if (error instanceof VerificationException) {
        return new EntitlementError(
            "invalid_transaction",
            400,
            "The App Store transaction could not be verified.",
            false,
            error
        );
    }
    return new EntitlementError(
        "verification_unavailable",
        503,
        "App Store verification is temporarily unavailable.",
        true,
        error
    );
}

async function verifyTransaction(signedTransaction, options = {}) {
    const configuredAppID = Number(options.appAppleId ?? appleAppID.value());
    if (!Number.isSafeInteger(configuredAppID) || configuredAppID <= 0) {
        throw new EntitlementError(
            "verification_unavailable",
            503,
            "App Store verification is temporarily unavailable.",
            true
        );
    }
    const makeVerifier = options.makeVerifier ?? ((environment, appID) => new SignedDataVerifier(
        appleRootCAs,
        true,
        environment,
        bundleID,
        appID
    ));

    try {
        return await makeVerifier(Environment.PRODUCTION, configuredAppID)
            .verifyAndDecodeTransaction(signedTransaction);
    } catch (error) {
        if (!(error instanceof VerificationException)
            || error.status !== VerificationStatus.INVALID_ENVIRONMENT) {
            throw verificationError(error);
        }
    }

    try {
        return await makeVerifier(Environment.SANDBOX, undefined)
            .verifyAndDecodeTransaction(signedTransaction);
    } catch (error) {
        throw verificationError(error);
    }
}

async function authorizeRequest(request) {
    const authorization = request.get("Authorization") ?? "";
    const idToken = authorization.startsWith("Bearer ") ? authorization.slice(7) : "";
    const appCheckToken = request.get("X-Firebase-AppCheck");
    if (!idToken || !appCheckToken) {
        throw new EntitlementError(
            "authentication_required",
            401,
            "Firebase authentication and App Check are required.",
            true
        );
    }
    try {
        const [auth, appCheck] = await Promise.all([
            getAuth().verifyIdToken(idToken),
            getAppCheck().verifyToken(appCheckToken),
        ]);
        if (!auth.uid || !appCheck.appId) throw new Error("Invalid Firebase credentials");
        return auth.uid;
    } catch (error) {
        throw new EntitlementError(
            "invalid_credentials",
            401,
            "Firebase credentials could not be verified.",
            true,
            error
        );
    }
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
    const isRevoked = data.revokedAt !== undefined && data.revokedAt !== null;
    return expiresAt > now.getTime() && !isRevoked;
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
            active: true,
            originalTransactionId: active.id,
            productId: active.productId,
            expiresAt: active.expiresAt,
            revokedAt: active.revokedAt ?? FieldValue.delete(),
        },
    }, { merge: true });
}

async function bindEntitlementToCurrentFamily(db, uid, entitlement, expectedFamilyId) {
    if (!matchesAppAccountToken(entitlement, uid)) {
        throw new EntitlementError(
            "owned_by_another_account",
            409,
            "This subscription belongs to another Momsy account."
        );
    }
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
            throw new EntitlementError(
                "no_family",
                409,
                "Set up a Momsy family before syncing the subscription.",
                true
            );
        }
        if (typeof expectedFamilyId === "string" && expectedFamilyId !== familyId) {
            throw new EntitlementError(
                "family_changed",
                409,
                "The Momsy family changed before synchronization completed."
            );
        }
        const member = await transaction.get(
            db.collection("families").doc(familyId).collection("members").doc(uid)
        );
        if (!member.exists) {
            throw new EntitlementError(
                "not_a_member",
                409,
                "The current Momsy family membership is still resolving.",
                true
            );
        }
        if (existing.exists && existing.get("ownerUid") !== uid) {
            throw new EntitlementError(
                "owned_by_another_account",
                409,
                "This subscription belongs to another Momsy account."
            );
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
    EntitlementError,
    appAccountTokenFor,
    appleRootCAHash,
    authorizeRequest,
    bindEntitlementToCurrentFamily,
    detachFamilyEntitlements,
    loadAppleRootCAs,
    matchesAppAccountToken,
    premiumEntitlementFor,
    updateFamilyPremium,
    verificationError,
    verifyTransaction,
};
