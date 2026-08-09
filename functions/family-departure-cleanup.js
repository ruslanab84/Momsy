const { createHash } = require("node:crypto");
const { FieldPath, FieldValue } = require("firebase-admin/firestore");

const privateWellbeingSubcollections = new Set(["momSleepLogs", "waterIntakeLogs"]);
const batchLimit = 400;

async function cleanupDepartedFamilyMember(db, familyId, uid) {
    if (!familyId || !uid || uid.length > 128 || familyId.includes("/") || uid.includes("/")) {
        throw new Error("Invalid family departure cleanup scope");
    }

    const familyRef = db.collection("families").doc(familyId);
    const memberRef = familyRef.collection("members").doc(uid);
    if (await activeMembershipExists(memberRef, uid)) {
        return;
    }
    const babyRefs = await familyRef.collection("babies").listDocuments();
    const parentRefs = [...babyRefs, db.collection("babies").doc(familyId)];

    for (const parentRef of parentRefs) {
        await scrubAuthoredData(db, parentRef, memberRef, uid);
        await scrubProfile(parentRef, memberRef, uid);
    }

    await scrubInvites(db, memberRef, familyId, uid);
    await clearFamilyCreator(familyRef, memberRef, uid);
    await clearStaleUserRoute(db.collection("users").doc(uid), memberRef, familyId, uid);
    await verifyCleanup(
        parentRefs,
        familyRef,
        db.collection("users").doc(uid),
        memberRef,
        familyId,
        uid
    );
}

async function scrubAuthoredData(db, parentRef, memberRef, uid) {
    const collections = (await parentRef.listCollections()).filter(
        (collection) => collection.id !== "profile"
    );
    for (const collection of collections) {
        while (true) {
            const result = await db.runTransaction(async (transaction) => {
                if (await activeMembershipExistsInTransaction(transaction, memberRef, uid)) {
                    return "active";
                }
                const snapshot = await transaction.get(
                    collection.where("addedBy", "==", uid).limit(batchLimit)
                );
                if (snapshot.empty) {
                    return "empty";
                }
                for (const document of snapshot.docs) {
                    if (privateWellbeingSubcollections.has(collection.id)) {
                        transaction.delete(document.ref);
                    } else {
                        transaction.update(document.ref, { addedBy: "", addedByName: "" });
                    }
                }
                return "mutated";
            });
            if (result === "active") {
                return;
            }
            if (result === "empty") {
                break;
            }
        }
    }
}

async function scrubProfile(parentRef, memberRef, uid) {
    const profileRef = parentRef.collection("profile").doc("info");
    await profileRef.firestore.runTransaction(async (transaction) => {
        if (await activeMembershipExistsInTransaction(transaction, memberRef, uid)) {
            return;
        }
        const profile = await transaction.get(profileRef);
        if (!profile.exists || !Array.isArray(profile.get("members"))) {
            return;
        }

        const members = profile.get("members");
        const remaining = members.filter((member) => member?.uid !== uid);
        if (remaining.length !== members.length) {
            transaction.update(profileRef, { members: remaining });
        }
    });
}

async function scrubInvites(db, memberRef, familyId, uid) {
    let cursor;
    while (true) {
        let query = db.collection("invites")
            .where("createdBy", "==", uid)
            .orderBy(FieldPath.documentId())
            .limit(batchLimit);
        if (cursor) {
            query = query.startAfter(cursor);
        }
        const invites = await query.get();
        if (invites.empty) {
            return;
        }
        const oldFamilyInvites = invites.docs.filter(
            (invite) => invite.get("familyId") === familyId
        );
        if (oldFamilyInvites.length > 0) {
            const stillDeparted = await db.runTransaction(async (transaction) => {
                if (await activeMembershipExistsInTransaction(transaction, memberRef, uid)) {
                    return false;
                }
                const currentInvites = await transaction.getAll(
                    ...oldFamilyInvites.map((invite) => invite.ref)
                );
                for (const invite of currentInvites) {
                    if (invite.exists
                        && invite.get("familyId") === familyId
                        && invite.get("createdBy") === uid) {
                        transaction.delete(invite.ref);
                    }
                }
                return true;
            });
            if (!stillDeparted) {
                return;
            }
        }
        cursor = invites.docs.at(-1);
    }
}

async function clearFamilyCreator(familyRef, memberRef, uid) {
    await familyRef.firestore.runTransaction(async (transaction) => {
        if (await activeMembershipExistsInTransaction(transaction, memberRef, uid)) {
            return;
        }
        const family = await transaction.get(familyRef);
        if (family.exists && family.get("createdBy") === uid) {
            transaction.update(familyRef, { createdBy: "" });
        }
    });
}

async function clearStaleUserRoute(userRef, memberRef, familyId, uid) {
    await userRef.firestore.runTransaction(async (transaction) => {
        if (await activeMembershipExistsInTransaction(transaction, memberRef, uid)) {
            return;
        }
        const user = await transaction.get(userRef);
        if (user.exists && user.get("familyId") === familyId) {
            transaction.update(userRef, { familyId: FieldValue.delete() });
        }
    });
}

async function verifyCleanup(parentRefs, familyRef, userRef, memberRef, familyId, uid) {
    if (await activeMembershipExists(memberRef, uid)) {
        return;
    }
    for (const parentRef of parentRefs) {
        const collections = (await parentRef.listCollections()).filter(
            (collection) => collection.id !== "profile"
        );
        const authored = await Promise.all(collections.map((collection) =>
            collection
                .where("addedBy", "==", uid)
                .limit(1)
                .get()
        ));
        if (authored.some((snapshot) => !snapshot.empty)) {
            throw new Error("Family departure cleanup verification failed: authored data remains");
        }

        const profile = await parentRef.collection("profile").doc("info").get();
        const members = profile.exists && Array.isArray(profile.get("members"))
            ? profile.get("members")
            : [];
        if (members.some((member) => member?.uid === uid)) {
            throw new Error("Family departure cleanup verification failed: profile member remains");
        }
    }

    const [family, user, oldFamilyInviteExists] = await Promise.all([
        familyRef.get(),
        userRef.get(),
        hasOldFamilyInvite(familyRef.firestore, familyId, uid),
    ]);
    if (oldFamilyInviteExists) {
        throw new Error("Family departure cleanup verification failed: invite remains");
    }
    if (family.exists && family.get("createdBy") === uid) {
        throw new Error("Family departure cleanup verification failed: creator remains");
    }
    if (user.exists && user.get("familyId") === familyId) {
        throw new Error("Family departure cleanup verification failed: stale route remains");
    }
}

async function activeMembershipExists(memberRef, uid) {
    const [canonical, matching] = await Promise.all([
        memberRef.get(),
        memberRef.parent.where("uid", "==", uid).limit(1).get(),
    ]);
    return canonical.exists || !matching.empty;
}

async function activeMembershipExistsInTransaction(transaction, memberRef, uid) {
    const canonical = await transaction.get(memberRef);
    if (canonical.exists) {
        return true;
    }
    const matching = await transaction.get(
        memberRef.parent.where("uid", "==", uid).limit(1)
    );
    return !matching.empty;
}

async function hasOldFamilyInvite(db, familyId, uid) {
    let cursor;
    while (true) {
        let query = db.collection("invites")
            .where("createdBy", "==", uid)
            .orderBy(FieldPath.documentId())
            .limit(batchLimit);
        if (cursor) {
            query = query.startAfter(cursor);
        }
        const invites = await query.get();
        if (invites.docs.some((invite) => invite.get("familyId") === familyId)) {
            return true;
        }
        if (invites.size < batchLimit) {
            return false;
        }
        cursor = invites.docs.at(-1);
    }
}

function cleanupJobID(familyId, uid) {
    return createHash("sha256").update(familyId).update("\0").update(uid).digest("hex");
}

module.exports = { cleanupDepartedFamilyMember, cleanupJobID };
