import { readFileSync } from "node:fs";
import assert from "node:assert/strict";
import { after, before, beforeEach, test } from "node:test";
import {
    assertFails,
    assertSucceeds,
    initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import { deleteField, serverTimestamp, Timestamp } from "firebase/firestore";

const projectId = "demo-momsy";
const familyId = "family-a";
const familyBId = "family-b";
const babyId = "baby-a";
const familyPath = `families/${familyId}`;
const familyBPath = `families/${familyBId}`;
const babyPath = `${familyPath}/babies/${babyId}`;
const legacyBabyPath = `babies/${familyId}`;
const familyBInvitePath = "invites/MOMSY-B2B3-B4B5-B6B7";

const users = {
    mom: "mom",
    dad: "dad",
    nanny: "nanny",
    grandma: "grandma",
    unknown: "unknown",
    outsider: "outsider",
    outsider2: "outsider-2",
    parentB: "parent-b",
};

let testEnv;

function context(uid) {
    return testEnv.authenticatedContext(uid);
}

function firestore(uid) {
    return context(uid).firestore();
}

function storage(uid) {
    return context(uid).storage(`gs://${projectId}.appspot.com`);
}

async function seedFirestore() {
    await testEnv.withSecurityRulesDisabled(async (adminContext) => {
        const db = adminContext.firestore();
        const batch = db.batch();
        batch.set(db.doc(familyPath), {
            createdBy: users.mom,
            bootstrapComplete: true,
        });
        batch.set(db.doc("families/family-bootstrap"), {
            createdBy: users.mom,
            bootstrapComplete: false,
        });
        batch.set(db.doc(familyBPath), {
            createdBy: users.parentB,
            bootstrapComplete: true,
        });
        batch.set(db.doc(`families/family-bootstrap/members/${users.mom}`), {
            uid: users.mom,
            roleRaw: "Мама",
        });

        const roles = new Map([
            [users.mom, "Мама"],
            [users.dad, "Папа"],
            [users.nanny, "Няня"],
            [users.grandma, "Бабушка"],
            [users.unknown, "guest"],
        ]);
        for (const [uid, roleRaw] of roles) {
            batch.set(db.doc(`${familyPath}/members/${uid}`), { uid, roleRaw });
        }
        batch.set(db.doc(`${familyBPath}/members/${users.parentB}`), {
            uid: users.parentB,
            roleRaw: "Мама",
        });
        batch.set(db.doc(`${familyBPath}/members/${users.dad}`), {
            uid: users.dad,
            roleRaw: "Папа",
        });
        batch.set(db.doc(familyBInvitePath), {
            familyId: familyBId,
            createdBy: users.parentB,
            expiresAt: new Date(Date.now() + 60 * 60 * 1000),
            roleRaw: "Папа",
        });

        batch.set(db.doc(babyPath), {
            id: babyId,
            name: "Baby",
            birthDate: new Date("2026-01-01T00:00:00Z"),
        });
        batch.set(db.doc(`${babyPath}/feedingLogs/feed-mom`), {
            addedBy: users.mom,
            addedByName: "Mom",
            startedAt: new Date("2026-07-11T10:00:00Z"),
        });
        batch.set(db.doc(`${babyPath}/temperatureLogs/temp-mom`), {
            addedBy: users.mom,
            addedByName: "Mom",
            value: 37.2,
        });
        batch.set(db.doc(`${babyPath}/temperatureLogs/temp-nanny`), {
            addedBy: users.nanny,
            addedByName: "Nanny",
            value: 36.9,
        });
        batch.set(db.doc(`${babyPath}/diaryLogs/diary-mom`), {
            addedBy: users.mom,
            addedByName: "Mom",
            text: "private note",
        });
        batch.set(db.doc(`${babyPath}/deletions/deleted-log`), {
            deletedAt: new Date("2026-07-11T11:00:00Z"),
        });
        batch.set(db.doc(`${babyPath}/profile/info`), {
            members: [{ uid: users.mom, role: "parent" }],
        });
        batch.set(db.doc(`${legacyBabyPath}/feedingLogs/legacy-feed`), {
            addedBy: users.mom,
            startedAt: new Date("2026-07-11T09:00:00Z"),
        });
        batch.set(db.doc(`${legacyBabyPath}/temperatureLogs/legacy-temp`), {
            addedBy: users.mom,
            value: 37.0,
        });
        await batch.commit();
    });
}

before(async () => {
    testEnv = await initializeTestEnvironment({
        projectId,
        firestore: {
            rules: readFileSync(new URL("../firestore.rules", import.meta.url), "utf8"),
        },
        storage: {
            rules: readFileSync(new URL("../storage.rules", import.meta.url), "utf8"),
        },
    });
});

beforeEach(async () => {
    await testEnv.clearFirestore();
    await testEnv.clearStorage();
    await seedFirestore();
});

after(async () => {
    await testEnv?.cleanup();
});

test("family lifecycle cannot be reopened or client-deleted", async () => {
    const nannyDb = firestore(users.nanny);
    const dadDb = firestore(users.dad);
    const momDb = firestore(users.mom);

    await assertFails(nannyDb.doc(familyPath).update({ bootstrapComplete: false }));
    await assertFails(nannyDb.doc(familyPath).update({ name: "hacked" }));
    await assertFails(momDb.doc(familyPath).update({ bootstrapComplete: false }));
    await assertFails(momDb.doc(familyPath).update({ name: "unexpected" }));
    await assertFails(nannyDb.doc(familyPath).set({
        createdBy: users.nanny,
        bootstrapComplete: false,
    }));
    await assertFails(nannyDb.doc(familyPath).delete());
    await assertFails(dadDb.doc(familyPath).delete());
    await assertSucceeds(momDb.doc("families/family-bootstrap").update({
        bootstrapComplete: true,
    }));
    await assertFails(momDb.doc(familyPath).delete());
});

test("the creator drops their UID only by leaving the roster", async () => {
    const momDb = firestore(users.mom);
    const dadDb = firestore(users.dad);
    const memberPath = `${familyPath}/members/${users.mom}`;

    // Anonymizing on its own leaves the creator in the roster — not an erasure.
    await assertFails(momDb.doc(familyPath).update({ createdBy: "" }));
    // Ownership may never be handed to another UID, erasure or not.
    const handoff = momDb.batch();
    handoff.update(momDb.doc(familyPath), { createdBy: users.dad });
    handoff.delete(momDb.doc(memberPath));
    await assertFails(handoff.commit());
    // Only the creator may clear the field.
    const impostor = dadDb.batch();
    impostor.update(dadDb.doc(familyPath), { createdBy: "" });
    impostor.delete(dadDb.doc(`${familyPath}/members/${users.dad}`));
    await assertFails(impostor.commit());
    // The tombstone itself stays undeletable.
    await assertFails(momDb.doc(familyPath).delete());

    const erasure = momDb.batch();
    erasure.update(momDb.doc(familyPath), { createdBy: "" });
    erasure.delete(momDb.doc(memberPath));
    await assertSucceeds(erasure.commit());

    await testEnv.withSecurityRulesDisabled(async (adminContext) => {
        const family = await adminContext.firestore().doc(familyPath).get();
        assert.equal(family.data().createdBy, "");
        assert.equal(family.data().bootstrapComplete, true);
    });
});

test("family creator bootstrap requires a parent role", async () => {
    for (const [suffix, roleRaw] of [
        ["mom", "Мама"],
        ["dad", "Папа"],
    ]) {
        const uid = `creator-${suffix}`;
        const path = `families/bootstrap-${suffix}`;
        const db = firestore(uid);

        await assertSucceeds(db.doc(path).set({
            createdBy: uid,
            bootstrapComplete: false,
        }));
        await assertSucceeds(db.doc(`${path}/members/${uid}`).set({ uid, roleRaw }));
        await assertSucceeds(db.doc(`${path}/babies/baby`).set({ name: "Baby" }));
        await assertSucceeds(db.doc(path).update({ bootstrapComplete: true }));
    }

    for (const [suffix, roleRaw] of [
        ["nanny", "Няня"],
        ["grandma", "Бабушка"],
    ]) {
        const uid = `creator-${suffix}`;
        const path = `families/bootstrap-${suffix}`;
        const db = firestore(uid);

        await assertSucceeds(db.doc(path).set({
            createdBy: uid,
            bootstrapComplete: false,
        }));
        await assertFails(db.doc(`${path}/members/${uid}`).set({ uid, roleRaw }));
    }
});

test("a restricted member cannot promote their own roster role", async () => {
    const member = firestore(users.nanny).doc(`${familyPath}/members/${users.nanny}`);

    await assertSucceeds(member.update({ name: "Updated nanny" }));
    await assertFails(member.update({ roleRaw: "Мама" }));
    await assertFails(member.update({ roleRaw: deleteField() }));
});

test("a parent cannot rewrite a member's auth identity", async () => {
    const member = firestore(users.mom).doc(`${familyPath}/members/${users.nanny}`);

    await assertFails(member.update({ uid: users.dad }));
    await assertSucceeds(member.update({ name: "Updated by parent" }));
});

test("legacy members can repair a missing role without promoting themselves", async () => {
    await testEnv.withSecurityRulesDisabled(async (adminContext) => {
        const db = adminContext.firestore();
        await db.doc(`${familyPath}/members/${users.mom}`).update({
            roleRaw: deleteField(),
        });
        await db.doc(`${familyPath}/members/${users.outsider}`).set({
            uid: users.outsider,
            name: "Legacy member",
        });
    });

    const creator = firestore(users.mom).doc(`${familyPath}/members/${users.mom}`);
    await assertFails(creator.update({ roleRaw: "Папа" }));
    await assertSucceeds(creator.update({ roleRaw: "Мама" }));

    const member = firestore(users.outsider).doc(`${familyPath}/members/${users.outsider}`);
    await assertFails(member.update({ roleRaw: "Мама" }));
    await assertFails(member.update({ roleRaw: "Няня" }));
    await assertFails(member.update({ roleRaw: "Бабушка" }));
    await assertSucceeds(member.update({ roleRaw: "Папа" }));
});

test("a parent cannot create a placeholder member without an authenticated join", async () => {
    const placeholderId = "9517DE8C-7EE9-4D88-962B-8D609F48CB48";
    await assertFails(firestore(users.mom).doc(`${familyPath}/members/${placeholderId}`).set({
        id: placeholderId,
        name: "Invited parent",
        roleRaw: "Папа",
        isMe: false,
    }));
});

test("a departure cleanup job is tied to the matching membership deletion", async () => {
    const momDb = firestore(users.mom);
    const nannyDb = firestore(users.nanny);
    const cleanupRef = momDb.doc("familyDepartureCleanups/nanny-departure");
    const cleanupData = {
        familyId,
        uid: users.nanny,
        removedMemberId: users.nanny,
        requestedAt: serverTimestamp(),
    };

    await assertFails(cleanupRef.set(cleanupData));

    const removal = momDb.batch();
    removal.set(cleanupRef, cleanupData);
    removal.delete(momDb.doc(`${familyPath}/members/${users.nanny}`));
    await assertSucceeds(removal.commit());

    await assertSucceeds(nannyDb.doc(cleanupRef.path).get());
    await assertSucceeds(
        nannyDb.collection("familyDepartureCleanups").where("uid", "==", users.nanny).get()
    );
    await assertFails(nannyDb.collection("familyDepartureCleanups").get());
    await assertFails(firestore(users.dad).doc(cleanupRef.path).get());
    await assertFails(nannyDb.doc(cleanupRef.path).delete());
});

test("invite roles are immutable and replacement revokes the old code", async () => {
    const validExpiry = new Date(Date.now() + 23 * 60 * 60 * 1000);
    const invite = firestore(users.mom).doc(familyBInvitePath);

    await assertFails(invite.set({
        familyId,
        createdBy: users.mom,
        expiresAt: validExpiry,
        roleRaw: "Няня",
    }, { merge: true }));
    await assertFails(firestore(users.dad).doc(familyBInvitePath).update({ familyId }));
    await assertFails(firestore(users.parentB).doc(familyBInvitePath).update({
        roleRaw: "Няня",
    }));
    await assertFails(firestore(users.parentB).doc(familyBInvitePath).update({
        expiresAt: validExpiry,
    }));
    await assertFails(firestore(users.mom).doc("invites/MOMSY-E2X3-T4R5-A6B7").set({
        familyId,
        createdBy: users.mom,
        expiresAt: validExpiry,
        unexpected: true,
        roleRaw: "Папа",
    }));
    await assertFails(firestore(users.mom).doc("invites/MOMSY-L2N3-G4H5-J6K7").set({
        familyId,
        createdBy: users.mom,
        expiresAt: new Date(Date.now() + 25 * 60 * 60 * 1000),
        roleRaw: "Папа",
    }));
    await assertFails(firestore(users.mom).doc("invites/MOMSY-L2D3-M4N5-P6Q7").set({
        familyId,
        createdBy: users.mom,
        expiresAt: new Date(Date.now() - 60 * 1000),
        roleRaw: "Папа",
    }));
    await assertSucceeds(firestore(users.mom).doc("invites/MOMSY-V2L3-D4F5-G6H7").set({
        familyId,
        createdBy: users.mom,
        expiresAt: validExpiry,
        roleRaw: "Папа",
    }));

    const parentBDb = firestore(users.parentB);
    const replacement = parentBDb.doc("invites/MOMSY-R2S3-T4U5-V6W7");
    const replacementBatch = parentBDb.batch();
    replacementBatch.set(replacement, {
        familyId: familyBId,
        createdBy: users.parentB,
        expiresAt: validExpiry,
        roleRaw: "Няня",
    });
    replacementBatch.delete(parentBDb.doc(familyBInvitePath));
    await assertSucceeds(replacementBatch.commit());
    await assertFails(parentBDb.doc(familyBInvitePath).get());
    await assertSucceeds(replacement.get());
});

test("an account owner can enumerate and delete only their own invites", async () => {
    const ownInvitePath = "invites/MOMSY-E2R3-S4T5-U6V7";
    await testEnv.withSecurityRulesDisabled(async (adminContext) => {
        await adminContext.firestore().doc(ownInvitePath).set({
            familyId: "deleted-family",
            createdBy: users.mom,
            expiresAt: new Date(Date.now() + 60 * 60 * 1000),
        });
    });

    const ownerDb = firestore(users.mom);
    const ownInvites = ownerDb.collection("invites")
        .where("createdBy", "==", users.mom);
    const otherUsersInvite = firestore(users.outsider).collection("invites")
        .where("createdBy", "==", users.mom);

    const snapshot = await assertSucceeds(ownInvites.get());
    assert.deepEqual(snapshot.docs.map((doc) => doc.id), ["MOMSY-E2R3-S4T5-U6V7"]);
    await assertFails(otherUsersInvite.get());
    await assertSucceeds(ownerDb.doc(ownInvitePath).delete());
});

test("an invite cannot expose or recreate a deleted family", async () => {
    const staleFamilyId = "deleted-family";
    const staleInviteCode = "MOMSY-S2T3-L4M5-N6P7";
    const staleInvitePath = `invites/${staleInviteCode}`;
    await testEnv.withSecurityRulesDisabled(async (adminContext) => {
        await adminContext.firestore().doc(staleInvitePath).set({
            familyId: staleFamilyId,
            createdBy: users.mom,
            expiresAt: new Date(Date.now() + 60 * 60 * 1000),
            roleRaw: "Папа",
        });
    });

    const joinerDb = firestore(users.outsider);
    await assertFails(joinerDb.doc(staleInvitePath).get());

    const batch = joinerDb.batch();
    batch.set(joinerDb.doc(`families/${staleFamilyId}/members/${users.outsider}`), {
        uid: users.outsider,
        roleRaw: "Папа",
        inviteCode: staleInviteCode,
    });
    batch.set(joinerDb.doc(`users/${users.outsider}`), { familyId: staleFamilyId });
    await assertFails(batch.commit());
});

test("a downgraded parent cannot keep authorizing joins with an old invite", async () => {
    const inviteCode = "MOMSY-D2W3-N4G5-R6D7";
    const invitePath = `invites/${inviteCode}`;
    const momDb = firestore(users.mom);

    await assertSucceeds(momDb.doc(invitePath).set({
        familyId,
        createdBy: users.mom,
        expiresAt: new Date(Date.now() + 60 * 60 * 1000),
        roleRaw: "Папа",
    }));
    await assertSucceeds(firestore(users.dad)
        .doc(`${familyPath}/members/${users.mom}`)
        .update({ roleRaw: "Няня" }));

    const joinerDb = firestore(users.outsider);
    await assertFails(joinerDb.doc(invitePath).get());
    const batch = joinerDb.batch();
    batch.set(joinerDb.doc(`${familyPath}/members/${users.outsider}`), {
        uid: users.outsider,
        roleRaw: "Папа",
        inviteCode,
    });
    batch.set(joinerDb.doc(`users/${users.outsider}`), { familyId });
    batch.delete(joinerDb.doc(invitePath));
    await assertFails(batch.commit());
});

test("a removed parent cannot restore access with their own old invite", async () => {
    await assertSucceeds(firestore(users.dad)
        .doc(`${familyBPath}/members/${users.parentB}`)
        .delete());

    const removedParentDb = firestore(users.parentB);
    await assertFails(removedParentDb.doc(familyBInvitePath).get());
    const batch = removedParentDb.batch();
    batch.set(removedParentDb.doc(`${familyBPath}/members/${users.parentB}`), {
        uid: users.parentB,
        roleRaw: "Папа",
        inviteCode: "MOMSY-B2B3-B4B5-B6B7",
    });
    batch.set(removedParentDb.doc(`users/${users.parentB}`), { familyId: familyBId });
    batch.delete(removedParentDb.doc(familyBInvitePath));
    await assertFails(batch.commit());
});

test("self-invite join consumes the code before another UID can use it", async () => {
    const momDb = firestore(users.mom);
    const invite = momDb.doc("invites/MOMSY-J2N3-K4L5-M6N7");

    const expirySeconds = Math.floor(Date.now() / 1000) + 24 * 60 * 60;
    const cachedExpiry = new Timestamp(expirySeconds, 500000123);

    await assertSucceeds(invite.set({
        familyId,
        createdBy: users.mom,
        expiresAt: cachedExpiry,
        roleRaw: "Няня",
    }));

    // Self-invite join batch: joiner writes their own member doc plus their
    // users/{uid} routing cache and consumes the invite atomically.
    const joinerDb = firestore(users.outsider);
    const incompleteBatch = joinerDb.batch();
    incompleteBatch.set(joinerDb.doc(`${familyPath}/members/${users.outsider}`), {
        uid: users.outsider,
        roleRaw: "Няня",
        inviteCode: "MOMSY-J2N3-K4L5-M6N7",
    });
    incompleteBatch.set(joinerDb.doc(`users/${users.outsider}`), { familyId });
    await assertFails(incompleteBatch.commit());

    const batch = joinerDb.batch();
    batch.set(joinerDb.doc(`${familyPath}/members/${users.outsider}`), {
        uid: users.outsider,
        roleRaw: "Няня",
        inviteCode: "MOMSY-J2N3-K4L5-M6N7",
    });
    batch.set(joinerDb.doc(`users/${users.outsider}`), { familyId });
    batch.delete(joinerDb.doc("invites/MOMSY-J2N3-K4L5-M6N7"));
    await assertSucceeds(batch.commit());
    await assertFails(joinerDb.doc("invites/MOMSY-J2N3-K4L5-M6N7").get());

    const secondJoinerDb = firestore(users.outsider2);
    const secondBatch = secondJoinerDb.batch();
    secondBatch.set(secondJoinerDb.doc(`${familyPath}/members/${users.outsider2}`), {
        uid: users.outsider2,
        roleRaw: "Няня",
        inviteCode: "MOMSY-J2N3-K4L5-M6N7",
    });
    secondBatch.set(secondJoinerDb.doc(`users/${users.outsider2}`), { familyId });
    secondBatch.delete(secondJoinerDb.doc("invites/MOMSY-J2N3-K4L5-M6N7"));
    await assertFails(secondBatch.commit());

    // Both the inviter and the joiner now see the full roster.
    const momRoster = await momDb.collection(`${familyPath}/members`).get();
    const joinerRoster = await joinerDb.collection(`${familyPath}/members`).get();
    assert.equal(momRoster.docs.some((doc) => doc.id === users.outsider), true);
    assert.equal(joinerRoster.docs.some((doc) => doc.id === users.mom), true);

    // ensureMemberDocument self-heal: an idempotent merge that leaves the
    // role unchanged must not be blocked for a non-parent joiner.
    await assertSucceeds(joinerDb.doc(`${familyPath}/members/${users.outsider}`).set({
        uid: users.outsider,
        roleRaw: "Няня",
    }, { merge: true }));
});

test("self-invite join is rejected when the member role does not match the invite", async () => {
    const momDb = firestore(users.mom);
    const expirySeconds = Math.floor(Date.now() / 1000) + 24 * 60 * 60;

    await assertSucceeds(momDb.doc("invites/MOMSY-J2N3-K4L5-M6P8").set({
        familyId,
        createdBy: users.mom,
        expiresAt: new Timestamp(expirySeconds, 0),
        roleRaw: "Няня",
    }));

    const joinerDb = firestore(users.outsider);
    const batch = joinerDb.batch();
    batch.set(joinerDb.doc(`${familyPath}/members/${users.outsider}`), {
        uid: users.outsider,
        roleRaw: "Папа",
        inviteCode: "MOMSY-J2N3-K4L5-M6P8",
    });
    batch.set(joinerDb.doc(`users/${users.outsider}`), { familyId });
    batch.delete(joinerDb.doc("invites/MOMSY-J2N3-K4L5-M6P8"));
    await assertFails(batch.commit());
});

test("parents retain full baby and medical access", async () => {
    const db = firestore(users.dad);

    await assertSucceeds(db.doc(babyPath).get());
    await assertSucceeds(db.doc(`${babyPath}/temperatureLogs/temp-mom`).get());
    await assertSucceeds(db.doc(`${legacyBabyPath}/temperatureLogs/legacy-temp`).get());
    await assertSucceeds(db.doc(`${babyPath}/temperatureLogs/temp-dad`).set({
        addedBy: users.dad,
        value: 36.8,
    }));
    await assertSucceeds(db.doc(`${babyPath}/profile/info`).update({ label: "family" }));
});

test("parents can read and delete only their own private wellbeing logs", async () => {
    await testEnv.withSecurityRulesDisabled(async (adminContext) => {
        const db = adminContext.firestore();
        const batch = db.batch();
        for (const collection of ["momSleepLogs", "waterIntakeLogs"]) {
            batch.set(db.doc(`${babyPath}/${collection}/mom-private`), {
                addedBy: users.mom,
                addedByName: "Mom",
                updatedAt: new Date("2026-07-11T10:00:00Z"),
            });
            batch.set(db.doc(`${babyPath}/${collection}/dad-private`), {
                addedBy: users.dad,
                addedByName: "Dad",
                updatedAt: new Date("2026-07-11T11:00:00Z"),
            });
        }
        await batch.commit();
    });

    const momDb = firestore(users.mom);
    for (const collection of ["momSleepLogs", "waterIntakeLogs"]) {
        await assertFails(momDb.collection(`${babyPath}/${collection}`).get());
        const own = await assertSucceeds(
            momDb.collection(`${babyPath}/${collection}`)
                .where("addedBy", "==", users.mom)
                .get()
        );
        assert.deepEqual(own.docs.map((doc) => doc.id), ["mom-private"]);
        await assertFails(momDb.doc(`${babyPath}/${collection}/dad-private`).get());
        await assertFails(momDb.doc(`${babyPath}/${collection}/dad-private`).delete());
        await assertSucceeds(momDb.doc(`${babyPath}/${collection}/mom-private`).delete());
    }
});

test("nanny can track routine care only under their own identity", async () => {
    const db = firestore(users.nanny);
    const ownLog = db.doc(`${babyPath}/feedingLogs/feed-nanny`);

    await assertSucceeds(db.collection(`${babyPath}/feedingLogs`).get());
    await assertSucceeds(db.collection(`${legacyBabyPath}/feedingLogs`).get());
    await assertSucceeds(ownLog.set({
        addedBy: users.nanny,
        addedByName: "Nanny",
        startedAt: new Date("2026-07-11T12:00:00Z"),
    }));
    await assertSucceeds(ownLog.update({ amount: 120 }));
    await assertFails(db.doc(`${babyPath}/feedingLogs/impersonated`).set({
        addedBy: users.mom,
        startedAt: new Date("2026-07-11T12:30:00Z"),
    }));
    await assertFails(db.doc(`${babyPath}/feedingLogs/missing-author-name`).set({
        addedBy: users.nanny,
        startedAt: new Date("2026-07-11T12:45:00Z"),
    }));
    await assertFails(db.doc(`${babyPath}/feedingLogs/feed-mom`).update({ amount: 30 }));
});

test("a departing shared-family member can anonymize only their own author metadata", async () => {
    const db = firestore(users.nanny);
    const ownLog = db.doc(`${babyPath}/feedingLogs/feed-nanny`);
    const postDepartureLog = db.doc(`${babyPath}/feedingLogs/feed-nanny-after-departure`);

    await assertSucceeds(ownLog.set({
        addedBy: users.nanny,
        addedByName: "Nanny",
        startedAt: new Date("2026-07-11T12:00:00Z"),
    }));
    await assertFails(ownLog.update({
        addedBy: "",
        addedByName: "",
        startedAt: new Date("2026-07-12T12:00:00Z"),
    }));
    await assertSucceeds(ownLog.update({ addedBy: "", addedByName: "" }));
    await assertSucceeds(postDepartureLog.set({
        addedBy: users.nanny,
        addedByName: "Nanny",
        startedAt: new Date("2026-07-11T13:00:00Z"),
    }));
    await assertFails(db.doc(`${babyPath}/feedingLogs/feed-mom`).update({
        addedBy: "",
        addedByName: "",
    }));

    const ownPrivateLogs = db.collection(`${babyPath}/temperatureLogs`)
        .where("addedBy", "==", users.nanny);
    const snapshot = await assertSucceeds(ownPrivateLogs.get());
    assert.deepEqual(snapshot.docs.map((doc) => doc.id), ["temp-nanny"]);
    await assertSucceeds(snapshot.docs[0].ref.update({ addedBy: "", addedByName: "" }));

    const userRef = db.doc(`users/${users.nanny}`);
    await assertSucceeds(userRef.set({ familyId }));
    const departure = db.batch();
    departure.delete(db.doc(`${familyPath}/members/${users.nanny}`));
    departure.delete(userRef);
    await assertSucceeds(departure.commit());
    await assertFails(postDepartureLog.update({ addedBy: "", addedByName: "" }));
});

test("nanny cannot read medical or private data and cannot delete logs", async () => {
    const db = firestore(users.nanny);

    await assertFails(db.collection(`${babyPath}/temperatureLogs`).get());
    await assertFails(db.collection(`${legacyBabyPath}/temperatureLogs`).get());
    await assertFails(db.doc(`${babyPath}/diaryLogs/diary-mom`).get());
    await assertFails(db.doc(`${babyPath}/profile/info`).get());
    await assertFails(db.doc(`${babyPath}/feedingLogs/feed-mom`).delete());
    await assertFails(db.doc(`${babyPath}/deletions/new-delete`).set({
        deletedAt: new Date(),
    }));
    await assertSucceeds(db.doc(`${babyPath}/deletions/deleted-log`).get());
});

test("grandma has read-only status access without medical access", async () => {
    const db = firestore(users.grandma);

    await assertSucceeds(db.doc(babyPath).get());
    await assertSucceeds(db.collection(`${babyPath}/feedingLogs`).get());
    await assertSucceeds(db.collection(`${legacyBabyPath}/feedingLogs`).get());
    await assertSucceeds(db.doc(`${babyPath}/deletions/deleted-log`).get());
    await assertFails(db.doc(`${babyPath}/feedingLogs/feed-grandma`).set({
        addedBy: users.grandma,
    }));
    await assertFails(db.doc(`${babyPath}/temperatureLogs/temp-mom`).get());
    await assertFails(db.doc(`${babyPath}/diaryLogs/diary-mom`).get());
});

test("unknown roles and outsiders have no baby access", async () => {
    await assertFails(firestore(users.unknown).doc(babyPath).get());
    await assertFails(firestore(users.outsider).doc(familyPath).get());
    await assertFails(firestore(users.outsider).doc(`${babyPath}/feedingLogs/feed-mom`).get());
    await assertFails(testEnv.unauthenticatedContext().firestore().doc(familyPath).get());
});

test("storage stays disabled for every family role and legacy path", async () => {
    const familyPhotoPath = `${familyPath}/photos/photo.jpg`;
    const legacyPhotoPath = `users/${users.mom}/diary/legacy.jpg`;
    const bytes = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]);

    await assertFails(storage(users.mom).ref(familyPhotoPath).put(
        bytes,
        { contentType: "image/jpeg" }
    ));
    await assertFails(storage(users.nanny).ref(familyPhotoPath).put(bytes));
    await assertFails(storage(users.grandma).ref(familyPhotoPath).put(bytes));
    await assertFails(storage(users.mom).ref(legacyPhotoPath).put(bytes));
    await assertFails(testEnv.unauthenticatedContext().storage().ref(familyPhotoPath).put(bytes));
});

test("a weak invite code cannot be minted", async () => {
    const momDb = firestore(users.mom);
    const expiresAt = Timestamp.fromMillis(Date.now() + 3_600_000);

    await assertFails(momDb.doc("invites/MOMSY-WEAK12").set({
        familyId,
        createdBy: users.mom,
        expiresAt,
        roleRaw: "Папа",
    }));
    await assertFails(momDb.doc("invites/MOMSY-A2B3-C4D5").set({
        familyId,
        createdBy: users.mom,
        expiresAt,
        roleRaw: "Папа",
    }));
    await assertFails(momDb.doc("invites/MOMSY-A2B3-C4D5-E6FI").set({
        familyId,
        createdBy: users.mom,
        expiresAt,
        roleRaw: "Папа",
    }));
    await assertSucceeds(momDb.doc("invites/MOMSY-A2B3-C4D5-E6F7").set({
        familyId,
        createdBy: users.mom,
        expiresAt,
        roleRaw: "Папа",
    }));
});

test("a weak invite code cannot be probed even when the document exists", async () => {
    const weakCode = "MOMSY-WEAK34";
    const strongCode = "MOMSY-H7J8-K9L2-M3N4";
    const expiresAt = Timestamp.fromMillis(Date.now() + 3_600_000);

    await testEnv.withSecurityRulesDisabled(async (adminContext) => {
        const db = adminContext.firestore();
        await db.doc(`invites/${weakCode}`).set({
            familyId,
            createdBy: users.mom,
            expiresAt,
        });
        await db.doc(`invites/${strongCode}`).set({
            familyId,
            createdBy: users.mom,
            expiresAt,
        });
    });

    // Перебор шестисимвольного пространства отсекается до `familyExists()`.
    await assertFails(firestore(users.outsider).doc(`invites/${weakCode}`).get());
    await assertSucceeds(firestore(users.outsider).doc(`invites/${strongCode}`).get());
});

test("a tombstone may be written with a server timestamp sentinel", async () => {
    const momDb = firestore(users.mom);

    await assertSucceeds(momDb.doc(`${babyPath}/deletions/server-stamped`).set({
        deletedAt: serverTimestamp(),
    }));

    // Роли без прав на ростер по-прежнему не могут ставить надгробия.
    await assertFails(firestore(users.nanny).doc(`${babyPath}/deletions/nanny-delete`).set({
        deletedAt: serverTimestamp(),
    }));
    await assertFails(firestore(users.grandma).doc(`${babyPath}/deletions/granny-delete`).set({
        deletedAt: serverTimestamp(),
    }));
});
