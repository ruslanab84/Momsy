const { initializeApp } = require("firebase-admin/app");
const { FieldValue, Timestamp, getFirestore } = require("firebase-admin/firestore");
const { onDocumentDeleted } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const { cleanupDeletedBaby } = require("./baby-deletion-cleanup");
const { cleanupDepartedFamilyMember, cleanupJobID } = require("./family-departure-cleanup");
const {
    authorizeRequest,
    bindEntitlementToCurrentFamily,
    premiumEntitlementFor,
    verifyTransaction,
} = require("./subscription-entitlement");

initializeApp();

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
        await db.runTransaction(async (transaction) => {
            const existing = await transaction.get(jobRef);
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
        });
        await cleanupDepartedFamilyMember(db, event.params.familyId, departedUid);
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
            response.status(400).json({ error: "Missing signed transaction" });
            return;
        }
        const transaction = await verifyTransaction(signedTransaction);
        const entitlement = premiumEntitlementFor(transaction);
        if (!entitlement.isKnownProduct
            || typeof entitlement.originalTransactionId !== "string"
            || !Number.isFinite(entitlement.expiresDate)) {
            response.status(400).json({ error: "Unsupported subscription" });
            return;
        }
        await bindEntitlementToCurrentFamily(getFirestore(), uid, entitlement);
        response.status(200).json({ active: entitlement.isActive });
    } catch (error) {
        console.error("Subscription entitlement sync failed", error);
        response.status(403).json({ error: "Could not verify subscription" });
    }
});
