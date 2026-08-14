const { FieldValue } = require("firebase-admin/firestore");

function isDocumentID(value) {
    return typeof value === "string"
        && value.length > 0
        && value.length <= 1_500
        && !value.includes("/");
}

async function cleanupDeletedBaby(db, familyId, babyId) {
    if (!isDocumentID(familyId) || !isDocumentID(babyId)) {
        throw new Error("Invalid baby deletion cleanup scope");
    }

    const familyRef = db.collection("families").doc(familyId);
    await familyRef.collection("deletedBabies").doc(babyId).set({
        deletedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    await deleteLiveActivityTokens(familyRef, babyId);
    await db.recursiveDelete(familyRef.collection("babies").doc(babyId));
}

async function deleteLiveActivityTokens(familyRef, babyId) {
    while (true) {
        const snapshot = await familyRef.collection("liveActivityTokens")
            .where("babyId", "==", babyId)
            .limit(400)
            .get();
        if (snapshot.empty) return;
        const batch = familyRef.firestore.batch();
        for (const document of snapshot.docs) {
            batch.delete(document.ref);
        }
        await batch.commit();
    }
}

module.exports = { cleanupDeletedBaby };
