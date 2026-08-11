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
    await db.recursiveDelete(familyRef.collection("babies").doc(babyId));
}

module.exports = { cleanupDeletedBaby };
