const { initializeApp } = require("firebase-admin/app");
const { FieldValue, Timestamp, getFirestore } = require("firebase-admin/firestore");
const { onDocumentDeleted, onDocumentWritten } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret, defineString } = require("firebase-functions/params");
const { cleanupDeletedBaby } = require("./baby-deletion-cleanup");
const {
    accountDeletionKind,
    cleanupDepartedFamilyMember,
    cleanupJobID,
} = require("./family-departure-cleanup");
const {
    dispatchSleepEnd,
    reconcileLiveActivityToken,
    terminalSleepChange,
} = require("./live-activity");
const {
    EntitlementError,
    authorizeRequest,
    bindEntitlementToCurrentFamily,
    premiumEntitlementFor,
    verifyTransaction,
} = require("./subscription-entitlement");

initializeApp();

const apnsAuthKey = defineSecret("APNS_AUTH_KEY");
const apnsKeyId = defineString("APNS_KEY_ID", { default: "" });
const apnsTeamId = defineString("APNS_TEAM_ID", { default: "" });

function apnsCredentials() {
    const credentials = {
        authKey: apnsAuthKey.value(), keyId: apnsKeyId.value(), teamId: apnsTeamId.value(),
    };
    return credentials.authKey && credentials.keyId && credentials.teamId ? credentials : null;
}

exports.cleanupDepartedFamilyMember = onDocumentDeleted({
    document: "families/{familyId}/members/{uid}",
    region: "us-central1",
    retry: true,
    timeoutSeconds: 540,
}, async (event) => {
    const eventId = event.id;
    const eventTime = Timestamp.fromDate(new Date(event.time));
    const storedUid = event.data?.get("uid");
    const departedUids = new Set(
        [event.params.uid, storedUid].filter((uid) =>
            typeof uid === "string"
            && uid.length > 0
            && uid.length <= 128
            && !uid.includes("/")
        )
    );
    for (const departedUid of departedUids) {
        const db = getFirestore();
        const jobRef = db.collection("familyDepartureCleanups").doc(
            cleanupJobID(event.params.familyId, departedUid)
        );
        const kind = await db.runTransaction(async (transaction) => {
            const existing = await transaction.get(jobRef);
            const requestedKind = existing.get("kind") === accountDeletionKind
                && existing.get("uid") === departedUid
                && existing.get("removedMemberId") === event.params.uid
                ? accountDeletionKind
                : undefined;
            const existingTime = existing.get("eventTime");
            const existingId = existing.get("eventId");
            const newerEventOwnsJob = existingTime instanceof Timestamp
                && (
                    existingTime.toMillis() > eventTime.toMillis()
                    || (
                        existingTime.toMillis() === eventTime.toMillis()
                        && typeof existingId === "string"
                        && existingId > eventId
                    )
                );
            if (!newerEventOwnsJob) {
                transaction.set(jobRef, {
                    familyId: event.params.familyId,
                    uid: departedUid,
                    removedMemberId: event.params.uid,
                    requestedAt: FieldValue.serverTimestamp(),
                    eventId,
                    eventTime,
                }, { merge: true });
            }
            return requestedKind;
        });
        await cleanupDepartedFamilyMember(db, event.params.familyId, departedUid, {
            kind,
            roleRaw: event.data?.get("roleRaw"),
        });
        await db.runTransaction(async (transaction) => {
            const job = await transaction.get(jobRef);
            if (job.exists && job.get("eventId") === eventId) {
                transaction.delete(jobRef);
            }
        });
    }
});

exports.cleanupDeletedBaby = onDocumentDeleted({
    document: "families/{familyId}/babies/{babyId}",
    region: "us-central1",
    retry: true,
    timeoutSeconds: 540,
}, async (event) => {
    await cleanupDeletedBaby(getFirestore(), event.params.familyId, event.params.babyId);
});

exports.endSleepLiveActivities = onDocumentWritten({
    document: "families/{familyId}/babies/{babyId}/sleepLogs/{sleepLogId}",
    region: "us-central1",
    retry: true,
    timeoutSeconds: 120,
    secrets: [apnsAuthKey],
}, async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    const endedAt = terminalSleepChange(before, after, new Date(event.time));
    if (!endedAt) return;
    const credentials = apnsCredentials();
    if (!credentials) {
        console.error("APNs credentials are not configured; terminal sleep push skipped");
        return;
    }
    const result = await dispatchSleepEnd(getFirestore(), {
        familyId: event.params.familyId,
        babyId: event.params.babyId,
        sleepLogId: event.params.sleepLogId,
        endedAt,
        credentials,
    });
    console.log("Dispatched terminal sleep push", {
        familyId: event.params.familyId,
        babyId: event.params.babyId,
        sleepLogId: event.params.sleepLogId,
        ...result,
    });
});

exports.endDeletedSleepLiveActivities = onDocumentWritten({
    document: "families/{familyId}/babies/{babyId}/deletions/{sleepLogId}",
    region: "us-central1",
    retry: true,
    timeoutSeconds: 120,
    secrets: [apnsAuthKey],
}, async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (before || !after) return;
    const endedAt = after.deletedAt?.toDate?.() ?? new Date(event.time);
    const credentials = apnsCredentials();
    if (!credentials) {
        console.error("APNs credentials are not configured; deleted sleep push skipped");
        return;
    }
    await dispatchSleepEnd(getFirestore(), {
        familyId: event.params.familyId,
        babyId: event.params.babyId,
        sleepLogId: event.params.sleepLogId,
        endedAt,
        credentials,
    });
});

exports.reconcileLateSleepLiveActivityToken = onDocumentWritten({
    document: "families/{familyId}/liveActivityTokens/{activityId}",
    region: "us-central1",
    retry: true,
    timeoutSeconds: 120,
    secrets: [apnsAuthKey],
}, async (event) => {
    if (!event.data?.after.exists) return;
    const credentials = apnsCredentials();
    if (!credentials) {
        console.error("APNs credentials are not configured; late token reconciliation skipped");
        return;
    }
    await reconcileLiveActivityToken(getFirestore(), {
        familyId: event.params.familyId,
        activityId: event.params.activityId,
        credentials,
    });
});

exports.syncSubscriptionEntitlement = onRequest({
    region: "us-central1",
}, async (request, response) => {
    if (request.method !== "POST") {
        response.status(405).json({ error: "Method not allowed" });
        return;
    }
    try {
        const uid = await authorizeRequest(request);
        const signedTransaction = request.body?.signedTransaction;
        if (typeof signedTransaction !== "string" || signedTransaction.length === 0) {
            throw new EntitlementError(
                "invalid_request",
                400,
                "A signed App Store transaction is required."
            );
        }
        const expectedUid = request.body?.expectedUid;
        const expectedFamilyId = request.body?.expectedFamilyId;
        if ((expectedUid !== undefined
                && (typeof expectedUid !== "string" || expectedUid.length === 0))
            || (expectedFamilyId !== undefined
                && (typeof expectedFamilyId !== "string"
                    || expectedFamilyId.length === 0
                    || expectedFamilyId.length > 128
                    || expectedFamilyId.includes("/")))) {
            throw new EntitlementError(
                "invalid_request",
                400,
                "The subscription synchronization context is invalid."
            );
        }
        if (typeof expectedUid === "string" && expectedUid !== uid) {
            throw new EntitlementError(
                "account_changed",
                409,
                "The Momsy account changed before synchronization completed."
            );
        }
        const transaction = await verifyTransaction(signedTransaction);
        const entitlement = premiumEntitlementFor(transaction);
        if (!entitlement.isKnownProduct
            || typeof entitlement.originalTransactionId !== "string"
            || !Number.isFinite(entitlement.expiresDate)) {
            throw new EntitlementError(
                "unsupported_subscription",
                400,
                "The App Store transaction is not a supported Momsy subscription."
            );
        }
        await bindEntitlementToCurrentFamily(
            getFirestore(),
            uid,
            entitlement,
            expectedFamilyId
        );
        response.status(200).json({ active: entitlement.isActive });
    } catch (error) {
        console.error("Subscription entitlement sync failed", error);
        const failure = error instanceof EntitlementError
            ? error
            : new EntitlementError(
                "service_unavailable",
                503,
                "Subscription synchronization is temporarily unavailable.",
                true,
                error
            );
        response.status(failure.httpStatus).json({
            error: failure.publicMessage,
            code: failure.code,
            retryable: failure.retryable,
        });
    }
});
