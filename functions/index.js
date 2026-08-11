const { initializeApp } = require("firebase-admin/app");
const { FieldValue, Timestamp, getFirestore } = require("firebase-admin/firestore");
const { onDocumentDeleted } = require("firebase-functions/v2/firestore");
const { cleanupDeletedBaby } = require("./baby-deletion-cleanup");
const { cleanupDepartedFamilyMember, cleanupJobID } = require("./family-departure-cleanup");

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
