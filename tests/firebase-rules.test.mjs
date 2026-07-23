import { readFileSync } from "node:fs";
import assert from "node:assert/strict";
import { after, before, beforeEach, test } from "node:test";
import {
    assertFails,
    assertSucceeds,
    initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import { Timestamp } from "firebase/firestore";

const projectId = "demo-momsy";
const familyId = "family-a";
const familyBId = "family-b";
const babyId = "baby-a";
const familyPath = `families/${familyId}`;
const familyBPath = `families/${familyBId}`;
const babyPath = `${familyPath}/babies/${babyId}`;
const legacyBabyPath = `babies/${familyId}`;
const familyBInvitePath = "invites/MOMSY-BBB234";

const users = {
    mom: "mom",
    dad: "dad",
    nanny: "nanny",
    grandma: "grandma",
    unknown: "unknown",
    outsider: "outsider",
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

test("family lifecycle cannot be reopened or deleted by restricted roles", async () => {
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
    await assertSucceeds(momDb.doc(familyPath).delete());
});

test("a restricted member cannot promote their own roster role", async () => {
    const member = firestore(users.nanny).doc(`${familyPath}/members/${users.nanny}`);

    await assertSucceeds(member.update({ name: "Updated nanny" }));
    await assertFails(member.update({ roleRaw: "Мама" }));
});

test("invite updates cannot cross families or bypass schema and expiry limits", async () => {
    const validExpiry = new Date(Date.now() + 23 * 60 * 60 * 1000);
    const invite = firestore(users.mom).doc(familyBInvitePath);

    await assertFails(invite.set({
        familyId,
        createdBy: users.mom,
        expiresAt: validExpiry,
        roleRaw: "Няня",
    }, { merge: true }));
    await assertFails(firestore(users.dad).doc(familyBInvitePath).update({ familyId }));
    await assertSucceeds(firestore(users.parentB).doc(familyBInvitePath).update({
        roleRaw: "Няня",
    }));
    await assertFails(firestore(users.parentB).doc(familyBInvitePath).update({
        expiresAt: validExpiry,
    }));
    await assertFails(firestore(users.mom).doc("invites/MOMSY-EXTRA1").set({
        familyId,
        createdBy: users.mom,
        expiresAt: validExpiry,
        unexpected: true,
    }));
    await assertFails(firestore(users.mom).doc("invites/MOMSY-LONG01").set({
        familyId,
        createdBy: users.mom,
        expiresAt: new Date(Date.now() + 25 * 60 * 60 * 1000),
    }));
    await assertFails(firestore(users.mom).doc("invites/MOMSY-OLD001").set({
        familyId,
        createdBy: users.mom,
        expiresAt: new Date(Date.now() - 60 * 1000),
    }));
    await assertSucceeds(firestore(users.mom).doc("invites/MOMSY-VALID1").set({
        familyId,
        createdBy: users.mom,
        expiresAt: validExpiry,
    }));
});

test("an account owner can enumerate and delete only their own invites", async () => {
    const ownInvitePath = "invites/MOMSY-ERASE1";
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
    assert.deepEqual(snapshot.docs.map((doc) => doc.id), ["MOMSY-ERASE1"]);
    await assertFails(otherUsersInvite.get());
    await assertSucceeds(ownerDb.doc(ownInvitePath).delete());
});

test("an invite cannot expose or recreate a deleted family", async () => {
    const staleFamilyId = "deleted-family";
    const staleInviteCode = "MOMSY-STALE1";
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

test("invite create, role update, and self-invite join keep both members visible", async () => {
    const momDb = firestore(users.mom);
    const invite = momDb.doc("invites/MOMSY-JOIN01");

    // Mirrors FirestoreInviteService: expiresAt is a client-computed
    // Timestamp(date:) with full nanosecond precision, not aligned to the
    // microsecond boundary Firestore stores. The client caches and re-sends
    // this exact value on every subsequent invite-role update.
    const expirySeconds = Math.floor(Date.now() / 1000) + 24 * 60 * 60;
    const cachedExpiry = new Timestamp(expirySeconds, 500000123);

    await assertSucceeds(invite.set({
        familyId,
        createdBy: users.mom,
        expiresAt: cachedExpiry,
        roleRaw: "Няня",
    }));

    // FirestoreInviteService.updateInviteRole resends the same cached,
    // unrounded expiresAt. The stored copy was truncated to microseconds on
    // write, so exact `==` must not be used to compare them.
    await assertSucceeds(invite.update({
        expiresAt: cachedExpiry,
        roleRaw: "Няня",
    }));

    // Self-invite join batch: joiner writes their own member doc plus their
    // users/{uid} routing cache in one atomic batch, exactly as the app's
    // join flow does.
    const joinerDb = firestore(users.outsider);
    const batch = joinerDb.batch();
    batch.set(joinerDb.doc(`${familyPath}/members/${users.outsider}`), {
        uid: users.outsider,
        roleRaw: "Няня",
        inviteCode: "MOMSY-JOIN01",
    });
    batch.set(joinerDb.doc(`users/${users.outsider}`), { familyId });
    await assertSucceeds(batch.commit());

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

    await assertSucceeds(momDb.doc("invites/MOMSY-JOIN02").set({
        familyId,
        createdBy: users.mom,
        expiresAt: new Timestamp(expirySeconds, 0),
        roleRaw: "Няня",
    }));

    const joinerDb = firestore(users.outsider);
    await assertFails(joinerDb.doc(`${familyPath}/members/${users.outsider}`).set({
        uid: users.outsider,
        roleRaw: "Папа",
        inviteCode: "MOMSY-JOIN02",
    }));
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
    await assertFails(db.doc(`${babyPath}/feedingLogs/feed-mom`).update({ amount: 30 }));
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

test("family photos are parent-managed and grandma-readable", async () => {
    const path = `${familyPath}/photos/photo.jpg`;
    const bytes = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]);

    await assertSucceeds(storage(users.mom).ref(path).put(bytes, { contentType: "image/jpeg" }));
    await assertSucceeds(storage(users.grandma).ref(path).getMetadata());
    await assertFails(storage(users.nanny).ref(path).getMetadata());
    await assertFails(testEnv.unauthenticatedContext().storage().ref(path).getMetadata());
    await assertFails(storage(users.grandma).ref(`${familyPath}/photos/grandma.jpg`).put(
        bytes,
        { contentType: "image/jpeg" },
    ));
    await assertFails(storage(users.mom).ref(`${familyPath}/photos/not-image.txt`).put(
        bytes,
        { contentType: "text/plain" },
    ));
    await assertSucceeds(storage(users.mom).ref(path).delete());
});

test("legacy user photos are owner-only", async () => {
    const path = `users/${users.mom}/diary/legacy.jpg`;
    const bytes = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]);

    await assertSucceeds(storage(users.mom).ref(path).put(bytes, { contentType: "image/jpeg" }));
    await assertSucceeds(storage(users.mom).ref(path).getMetadata());
    await assertFails(storage(users.dad).ref(path).getMetadata());
    await assertFails(storage(users.grandma).ref(path).getMetadata());
});
