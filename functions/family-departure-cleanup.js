const { createHash } = require("node:crypto");
const { FieldPath, FieldValue } = require("firebase-admin/firestore");
const { detachFamilyEntitlements } = require("./subscription-entitlement");

const privateWellbeingSubcollections = new Set(["momSleepLogs", "waterIntakeLogs"]);
const batchLimit = 400;
const accountDeletionKind = "accountDeletion";

async function cleanupDepartedFamilyMember(db, familyId, uid, options = {}) {
    if (!familyId || !uid || uid.length > 128 || familyId.includes("/") || uid.includes("/")) {
        throw new Error("Invalid family departure cleanup scope");
    }

    const familyRef = db.collection("families").doc(familyId);
    const memberRef = familyRef.collection("members").doc(uid);
    if (await activeMembershipExists(memberRef, uid)) {
        return;
    }
    const accountDeletion = options.kind === accountDeletionKind;
    if (accountDeletion
        && isParentRole(options.roleRaw)
        && !await remainingParentExists(familyRef)) {
        await cleanupAbandonedFamily(db, familyRef, memberRef, familyId, uid);
        return;
    }
    const babyRefs = await familyRef.collection("babies").listDocuments();
    const parentRefs = [...babyRefs, db.collection("babies").doc(familyId)];

    for (const parentRef of parentRefs) {
        await scrubAuthoredData(db, parentRef, memberRef, uid);
        await scrubProfile(parentRef, memberRef, uid);
    }
    await scrubOwnedPushTokens(familyRef, memberRef, uid);

    await clearFamilyCreator(familyRef, memberRef, uid);
    const userCleanup = await clearStaleUserRoute(
        db.collection("users").doc(uid), memberRef, familyId, uid, accountDeletion
    );
    await scrubInvites(db, memberRef, familyId, uid, userCleanup === "deleted");
    await detachFamilyEntitlements(db, familyId, uid);
    await verifyCleanup(
        parentRefs,
        familyRef,
        db.collection("users").doc(uid),
        memberRef,
        familyId,
        uid,
        userCleanup === "deleted"
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

async function scrubOwnedPushTokens(familyRef, memberRef, uid) {
    for (const collectionName of ["liveActivityTokens", "devicePushTokens"]) {
        const collection = familyRef.collection(collectionName);
        while (true) {
            const result = await familyRef.firestore.runTransaction(async (transaction) => {
                if (await activeMembershipExistsInTransaction(transaction, memberRef, uid)) {
                    return "active";
                }
                const snapshot = await transaction.get(
                    collection.where("ownerUid", "==", uid).limit(batchLimit)
                );
                if (snapshot.empty) return "empty";
                for (const document of snapshot.docs) {
                    transaction.delete(document.ref);
                }
                return "deleted";
            });
            if (result === "active") return;
            if (result === "empty") break;
        }
    }
}

async function scrubInvites(db, memberRef, familyId, uid, allFamilies = false) {
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
        const deletableInvites = invites.docs.filter(
            (invite) => allFamilies || invite.get("familyId") === familyId
        );
        if (deletableInvites.length > 0) {
            const stillDeparted = await db.runTransaction(async (transaction) => {
                if (await activeMembershipExistsInTransaction(transaction, memberRef, uid)) {
                    return false;
                }
                const currentInvites = await transaction.getAll(
                    ...deletableInvites.map((invite) => invite.ref)
                );
                for (const invite of currentInvites) {
                    if (invite.exists
                        && invite.get("createdBy") === uid
                        && (allFamilies || invite.get("familyId") === familyId)) {
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

async function clearStaleUserRoute(userRef, memberRef, familyId, uid, deleteAccount = false) {
    return userRef.firestore.runTransaction(async (transaction) => {
        if (await activeMembershipExistsInTransaction(transaction, memberRef, uid)) {
            return "active";
        }
        const user = await transaction.get(userRef);
        if (!user.exists) {
            return deleteAccount ? "deleted" : "absent";
        }
        if (deleteAccount
            && (user.get("familyId") === familyId || user.get("familyId") === undefined)) {
            transaction.delete(userRef);
            return "deleted";
        }
        if (user.get("familyId") === familyId) {
            transaction.update(userRef, { familyId: FieldValue.delete() });
            return "cleared";
        }
        return "unchanged";
    });
}

async function verifyCleanup(
    parentRefs, familyRef, userRef, memberRef, familyId, uid, accountDeleted = false
) {
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

    const [family, user, inviteExists] = await Promise.all([
        familyRef.get(),
        userRef.get(),
        accountDeleted
            ? hasOwnedInvite(familyRef.firestore, uid)
            : hasOldFamilyInvite(familyRef.firestore, familyId, uid),
    ]);
    if (inviteExists) {
        throw new Error("Family departure cleanup verification failed: invite remains");
    }
    if (family.exists && family.get("createdBy") === uid) {
        throw new Error("Family departure cleanup verification failed: creator remains");
    }
    if (user.exists && user.get("familyId") === familyId) {
        throw new Error("Family departure cleanup verification failed: stale route remains");
    }
    if (accountDeleted && user.exists) {
        throw new Error("Family departure cleanup verification failed: user remains");
    }
    const pushTokens = await Promise.all([
        familyRef.collection("liveActivityTokens").where("ownerUid", "==", uid).limit(1).get(),
        familyRef.collection("devicePushTokens").where("ownerUid", "==", uid).limit(1).get(),
    ]);
    if (pushTokens.some((snapshot) => !snapshot.empty)) {
        throw new Error("Family departure cleanup verification failed: push token remains");
    }
}

async function cleanupAbandonedFamily(db, familyRef, memberRef, familyId, uid) {
    const userRef = db.collection("users").doc(uid);
    const userCleanup = await clearStaleUserRoute(
        userRef, memberRef, familyId, uid, true
    );
    await detachFamilyEntitlements(db, familyId, uid);

    await Promise.all(
        (await familyRef.listCollections()).map((collection) => db.recursiveDelete(collection))
    );
    await db.recursiveDelete(db.collection("babies").doc(familyId));
    await deleteMatchingDocuments(db.collection("invites").where("familyId", "==", familyId));
    await scrubInvites(db, memberRef, familyId, uid, userCleanup === "deleted");
    await familyRef.set({ createdBy: "", bootstrapComplete: true });

    const liveCollections = (await familyRef.listCollections()).filter(
        (collection) => collection.id !== "deletedBabies"
    );
    const [legacy, user, ownedInvite] = await Promise.all([
        db.collection("babies").doc(familyId).get(),
        userRef.get(),
        hasOwnedInvite(db, uid),
    ]);
    const remainingDocuments = await Promise.all(
        liveCollections.map((collection) => collection.limit(1).get())
    );
    if (legacy.exists
        || remainingDocuments.some((snapshot) => !snapshot.empty)
        || (userCleanup === "deleted" && user.exists)
        || (userCleanup === "deleted" && ownedInvite)) {
        throw new Error("Account deletion cleanup verification failed");
    }
}

async function deleteMatchingDocuments(query) {
    while (true) {
        const snapshot = await query.limit(batchLimit).get();
        if (snapshot.empty) return;
        const batch = snapshot.docs[0].ref.firestore.batch();
        for (const document of snapshot.docs) batch.delete(document.ref);
        await batch.commit();
    }
}

async function remainingParentExists(familyRef) {
    const members = await familyRef.collection("members").get();
    return members.docs.some((member) =>
        !isLegacyPlaceholder(member) && isParentRole(member.get("roleRaw"))
    );
}

function isLegacyPlaceholder(member) {
    const data = member.data();
    return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
        .test(member.id)
        && data.id === member.id
        && (data.uid === undefined || data.uid === member.id)
        && data.joinedAt === undefined
        && data.inviteCode === undefined
        && data.isMe !== true;
}

function isParentRole(roleRaw) {
    if (typeof roleRaw !== "string") return false;
    return new Set(["мама", "mom", "mama", "mother", "parent", "папа", "dad", "papa", "father"])
        .has(roleRaw.trim().toLowerCase());
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

async function hasOwnedInvite(db, uid) {
    return !(await db.collection("invites").where("createdBy", "==", uid).limit(1).get()).empty;
}

function cleanupJobID(familyId, uid) {
    return createHash("sha256").update(familyId).update("\0").update(uid).digest("hex");
}

module.exports = { accountDeletionKind, cleanupDepartedFamilyMember, cleanupJobID };
