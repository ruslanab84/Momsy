import { readFileSync } from "node:fs";
import { after, before, beforeEach, test } from "node:test";
import {
    assertFails,
    assertSucceeds,
    initializeTestEnvironment,
} from "@firebase/rules-unit-testing";

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
