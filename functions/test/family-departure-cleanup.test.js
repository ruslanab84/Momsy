const assert = require("node:assert/strict");
const { after, before, beforeEach, test } = require("node:test");
const { deleteApp, initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { cleanupDeletedBaby } = require("../baby-deletion-cleanup");
const { cleanupDepartedFamilyMember, cleanupJobID } = require("../family-departure-cleanup");
const { dispatchSleepEnd, reconcileLiveActivityToken } = require("../live-activity");
const {
    bindEntitlementToCurrentFamily,
    detachFamilyEntitlements,
} = require("../subscription-entitlement");

const projectId = "demo-momsy";
let app;
let db;

before(() => {
    assert.equal(
        cleanupJobID("family_a", "member"),
        "cd2135f3be29a59b70783a1aa034128f3b99f00959ddf133c2c8b794a13bf1f3"
    );
    app = initializeApp({ projectId }, "family-departure-tests");
    db = getFirestore(app);
});

beforeEach(async () => {
    const host = process.env.FIRESTORE_EMULATOR_HOST;
    assert.ok(host, "FIRESTORE_EMULATOR_HOST must be set");
    const response = await fetch(
        `http://${host}/emulator/v1/projects/${projectId}/databases/(default)/documents`,
        { method: "DELETE" }
    );
    assert.equal(response.ok, true);
});

after(async () => {
    await deleteApp(app);
});

test("membership removal scrubs current and legacy personal identifiers", async () => {
    const familyId = "removed-family";
    const uid = "departed-parent";
    const familyRef = db.collection("families").doc(familyId);
    const legacyMemberRef = familyRef.collection("members").doc("legacy-member-document");
    const babyRef = familyRef.collection("babies").doc("baby-a");
    const legacyRef = db.collection("babies").doc(familyId);
    const batch = db.batch();

    batch.set(familyRef, { createdBy: uid, bootstrapComplete: true });
    batch.set(legacyMemberRef, { uid, roleRaw: "Папа" });
    batch.set(db.collection("users").doc(uid), { familyId, displayName: "Dad" });
    batch.set(db.collection("invites").doc("old-family-invite"), {
        familyId,
        createdBy: uid,
    });
    batch.set(db.collection("invites").doc("other-family-invite"), {
        familyId: "another-family",
        createdBy: uid,
    });
    batch.set(babyRef.collection("feedingLogs").doc("own-shared"), {
        addedBy: uid,
        addedByName: "Dad",
        amount: 120,
    });
    batch.set(babyRef.collection("feedingLogs").doc("other-shared"), {
        addedBy: "remaining-parent",
        addedByName: "Mom",
    });
    batch.set(babyRef.collection("momSleepLogs").doc("own-private"), {
        addedBy: uid,
        addedByName: "Dad",
    });
    batch.set(babyRef.collection("futureLogs").doc("own-future"), {
        addedBy: uid,
        addedByName: "Dad",
    });
    batch.set(babyRef.collection("profile").doc("info"), {
        members: [{ uid, name: "Dad" }, { uid: "remaining-parent", name: "Mom" }],
    });
    batch.set(legacyRef.collection("temperatureLogs").doc("legacy-shared"), {
        addedBy: uid,
        addedByName: "Dad",
        value: 37,
    });
    batch.set(legacyRef.collection("waterIntakeLogs").doc("legacy-private"), {
        addedBy: uid,
        addedByName: "Dad",
    });
    batch.set(legacyRef.collection("profile").doc("info"), {
        members: [{ uid, name: "Dad" }],
    });
    batch.set(familyRef.collection("liveActivityTokens").doc("departed-activity"), {
        ownerUid: uid,
        babyId: "baby-a",
    });
    batch.set(familyRef.collection("devicePushTokens").doc("departed-device"), {
        ownerUid: uid,
    });
    await batch.commit();

    const cleanupRef = db.collection("familyDepartureCleanups").doc(cleanupJobID(familyId, uid));
    const removal = db.batch();
    removal.set(cleanupRef, { familyId, uid, removedMemberId: legacyMemberRef.id });
    removal.delete(legacyMemberRef);
    await removal.commit();
    await waitFor(async () => {
        const [shared, privateLog, family, user, cleanup] = await Promise.all([
            babyRef.collection("feedingLogs").doc("own-shared").get(),
            babyRef.collection("momSleepLogs").doc("own-private").get(),
            familyRef.get(),
            db.collection("users").doc(uid).get(),
            cleanupRef.get(),
        ]);
        return shared.get("addedBy") === ""
            && !privateLog.exists
            && family.get("createdBy") === ""
            && user.get("familyId") === undefined
            && !cleanup.exists;
    });

    const [
        shared, other, future, legacyShared, legacyPrivate, profile, legacyProfile,
        family, user, oldInvite, otherInvite, liveToken, deviceToken,
    ] =
        await Promise.all([
            babyRef.collection("feedingLogs").doc("own-shared").get(),
            babyRef.collection("feedingLogs").doc("other-shared").get(),
            babyRef.collection("futureLogs").doc("own-future").get(),
            legacyRef.collection("temperatureLogs").doc("legacy-shared").get(),
            legacyRef.collection("waterIntakeLogs").doc("legacy-private").get(),
            babyRef.collection("profile").doc("info").get(),
            legacyRef.collection("profile").doc("info").get(),
            familyRef.get(),
            db.collection("users").doc(uid).get(),
            db.collection("invites").doc("old-family-invite").get(),
            db.collection("invites").doc("other-family-invite").get(),
            familyRef.collection("liveActivityTokens").doc("departed-activity").get(),
            familyRef.collection("devicePushTokens").doc("departed-device").get(),
        ]);

    assert.deepEqual(
        { addedBy: shared.get("addedBy"), addedByName: shared.get("addedByName"), amount: shared.get("amount") },
        { addedBy: "", addedByName: "", amount: 120 }
    );
    assert.equal(other.get("addedBy"), "remaining-parent");
    assert.equal(future.get("addedBy"), "");
    assert.equal(legacyShared.get("addedBy"), "");
    assert.equal(legacyPrivate.exists, false);
    assert.deepEqual(profile.get("members"), [{ uid: "remaining-parent", name: "Mom" }]);
    assert.deepEqual(legacyProfile.get("members"), []);
    assert.equal(family.get("createdBy"), "");
    assert.equal(user.get("familyId"), undefined);
    assert.equal(user.get("displayName"), "Dad");
    assert.equal(oldInvite.exists, false);
    assert.equal(otherInvite.exists, true);
    assert.equal(liveToken.exists, false);
    assert.equal(deviceToken.exists, false);
    assert.equal((await cleanupRef.get()).exists, false);

    await cleanupDepartedFamilyMember(db, familyId, uid);
});

test("family switch cleanup preserves the new family route", async () => {
    const oldFamilyId = "old-family";
    const newFamilyId = "new-family";
    const uid = "switching-parent";
    const oldFamilyRef = db.collection("families").doc(oldFamilyId);
    const oldMemberRef = oldFamilyRef.collection("members").doc(uid);
    const userRef = db.collection("users").doc(uid);
    const cleanupRef = db.collection("familyDepartureCleanups").doc(
        cleanupJobID(oldFamilyId, uid)
    );
    const sharedRef = oldFamilyRef.collection("babies").doc("baby-a")
        .collection("sleepLogs").doc("old-log");

    await oldFamilyRef.set({ createdBy: "other-parent", bootstrapComplete: true });
    await oldMemberRef.set({ uid, roleRaw: "Папа" });
    await sharedRef.set({ addedBy: uid, addedByName: "Dad" });

    const switchBatch = db.batch();
    switchBatch.delete(oldMemberRef);
    switchBatch.set(cleanupRef, { familyId: oldFamilyId, uid, removedMemberId: uid });
    switchBatch.set(userRef, { familyId: newFamilyId }, { merge: true });
    switchBatch.set(
        db.collection("families").doc(newFamilyId).collection("members").doc(uid),
        { uid, roleRaw: "Папа" }
    );
    await switchBatch.commit();

    await waitFor(async () => {
        const [shared, cleanup] = await Promise.all([sharedRef.get(), cleanupRef.get()]);
        return shared.get("addedBy") === "" && !cleanup.exists;
    });
    assert.equal((await userRef.get()).get("familyId"), newFamilyId);
    assert.equal((await cleanupRef.get()).exists, false);
});

test("a verified subscription is shared with the family and removed on departure", async () => {
    const familyId = "premium-family";
    const uid = "subscribing-parent";
    const transactionID = "1000000123456789";
    await db.collection("families").doc(familyId).set({ bootstrapComplete: true });
    await db.collection("families").doc(familyId).collection("members").doc(uid).set({ uid });
    await db.collection("users").doc(uid).set({ familyId });

    await bindEntitlementToCurrentFamily(db, uid, {
        originalTransactionId: transactionID,
        productId: "com.ruslanabdulov.momsy.premium.monthly",
        expiresDate: Date.now() + 60_000,
        revocationDate: null,
    });

    const familyWithPremium = await db.collection("families").doc(familyId).get();
    assert.equal(familyWithPremium.get("premiumEntitlement.originalTransactionId"), transactionID);

    await detachFamilyEntitlements(db, familyId, uid);

    const [familyWithoutPremium, detachedEntitlement] = await Promise.all([
        db.collection("families").doc(familyId).get(),
        db.collection("subscriptionEntitlements").doc(transactionID).get(),
    ]);
    assert.equal(familyWithoutPremium.get("premiumEntitlement"), undefined);
    assert.equal(detachedEntitlement.get("familyId"), "");
});

test("cleanup does nothing when canonical membership is active", async () => {
    const familyId = "rejoined-family";
    const uid = "active-member";
    const familyRef = db.collection("families").doc(familyId);
    const memberRef = familyRef.collection("members").doc(uid);
    const userRef = db.collection("users").doc(uid);
    const logRef = familyRef.collection("babies").doc("baby-a")
        .collection("feedingLogs").doc("active-log");
    const profileRef = familyRef.collection("babies").doc("baby-a")
        .collection("profile").doc("info");

    await familyRef.set({ createdBy: uid, bootstrapComplete: true });
    await memberRef.set({ uid, roleRaw: "Мама" });
    await userRef.set({ familyId });
    await logRef.set({ addedBy: uid, addedByName: "Mom" });
    await profileRef.set({ members: [{ uid, name: "Mom" }] });
    await familyRef.collection("liveActivityTokens").doc("active-activity").set({ ownerUid: uid });
    await familyRef.collection("devicePushTokens").doc("active-device").set({ ownerUid: uid });

    await cleanupDepartedFamilyMember(db, familyId, uid);

    assert.equal((await logRef.get()).get("addedBy"), uid);
    assert.deepEqual((await profileRef.get()).get("members"), [{ uid, name: "Mom" }]);
    assert.equal((await familyRef.get()).get("createdBy"), uid);
    assert.equal((await userRef.get()).get("familyId"), familyId);
    assert.equal((await familyRef.collection("liveActivityTokens").doc("active-activity").get()).exists, true);
    assert.equal((await familyRef.collection("devicePushTokens").doc("active-device").get()).exists, true);
});

test("cleanup does nothing while another legacy membership remains", async () => {
    const familyId = "legacy-duplicate-family";
    const uid = "legacy-active-member";
    const familyRef = db.collection("families").doc(familyId);
    const firstLegacyRef = familyRef.collection("members").doc("legacy-a");
    const secondLegacyRef = familyRef.collection("members").doc("legacy-b");
    const userRef = db.collection("users").doc(uid);
    const logRef = familyRef.collection("babies").doc("baby-a")
        .collection("feedingLogs").doc("active-log");

    await familyRef.set({ createdBy: uid, bootstrapComplete: true });
    await firstLegacyRef.set({ uid, roleRaw: "Папа" });
    await secondLegacyRef.set({ uid, roleRaw: "Папа" });
    await userRef.set({ familyId });
    await logRef.set({ addedBy: uid, addedByName: "Dad" });

    await firstLegacyRef.delete();
    await cleanupDepartedFamilyMember(db, familyId, uid);

    assert.equal((await logRef.get()).get("addedBy"), uid);
    assert.equal((await familyRef.get()).get("createdBy"), uid);
    assert.equal((await userRef.get()).get("familyId"), familyId);
});

test("cleanup drains authored collections larger than one write batch", async () => {
    const familyId = "large-family";
    const uid = "departed-heavy-author";
    const familyRef = db.collection("families").doc(familyId);
    const logs = familyRef.collection("babies").doc("baby-a").collection("feedingLogs");
    const seed = db.batch();

    seed.set(familyRef, { createdBy: "remaining-parent", bootstrapComplete: true });
    for (let index = 0; index < 401; index += 1) {
        seed.set(logs.doc(`log-${String(index).padStart(3, "0")}`), {
            addedBy: uid,
            addedByName: "Former member",
        });
    }
    await seed.commit();

    await cleanupDepartedFamilyMember(db, familyId, uid);

    assert.equal((await logs.where("addedBy", "==", uid).get()).empty, true);
    assert.equal((await logs.where("addedBy", "==", "").get()).size, 401);
});

test("a corrupted stored uid cannot redirect cleanup away from the path uid", async () => {
    const familyId = "corrupted-member-family";
    const actualUid = "actual-departed-member";
    const wrongUid = "still-active-member";
    const familyRef = db.collection("families").doc(familyId);
    const deletedMemberRef = familyRef.collection("members").doc(actualUid);
    const actualLogRef = familyRef.collection("babies").doc("baby-a")
        .collection("feedingLogs").doc("departed-log");
    const activeLogRef = familyRef.collection("babies").doc("baby-a")
        .collection("feedingLogs").doc("active-log");

    await familyRef.set({ createdBy: actualUid, bootstrapComplete: true });
    await deletedMemberRef.set({ uid: wrongUid, roleRaw: "Папа" });
    await familyRef.collection("members").doc(wrongUid).set({ uid: wrongUid, roleRaw: "Мама" });
    await db.collection("users").doc(actualUid).set({ familyId });
    await db.collection("users").doc(wrongUid).set({ familyId });
    await actualLogRef.set({ addedBy: actualUid, addedByName: "Former Dad" });
    await activeLogRef.set({ addedBy: wrongUid, addedByName: "Mom" });

    await deletedMemberRef.delete();
    await waitFor(async () => {
        const [actualLog, family, user] = await Promise.all([
            actualLogRef.get(),
            familyRef.get(),
            db.collection("users").doc(actualUid).get(),
        ]);
        return actualLog.get("addedBy") === ""
            && family.get("createdBy") === ""
            && user.get("familyId") === undefined;
    });

    assert.equal((await familyRef.get()).get("createdBy"), "");
    assert.equal((await db.collection("users").doc(actualUid).get()).get("familyId"), undefined);
    assert.equal((await activeLogRef.get()).get("addedBy"), wrongUid);
    assert.equal((await db.collection("users").doc(wrongUid).get()).get("familyId"), familyId);
});

test("deleting a baby removes the co-parent's private wellbeing subtree", async () => {
    const familyId = "deleted-baby-family";
    const babyId = "deleted-baby";
    const familyRef = db.collection("families").doc(familyId);
    const babyRef = familyRef.collection("babies").doc(babyId);
    const coParentPrivateRef = babyRef.collection("momSleepLogs").doc("co-parent-private");
    const ownPrivateRef = babyRef.collection("waterIntakeLogs").doc("own-private");
    const sharedRef = babyRef.collection("feedingLogs").doc("shared");
    const profileRef = babyRef.collection("profile").doc("info");
    const tombstoneRef = familyRef.collection("deletedBabies").doc(babyId);
    const deletedBabyToken = familyRef.collection("liveActivityTokens").doc("deleted-baby-token");
    const otherBabyToken = familyRef.collection("liveActivityTokens").doc("other-baby-token");
    const batch = db.batch();

    batch.set(familyRef, { bootstrapComplete: true });
    batch.set(babyRef, { id: babyId, name: "Baby" });
    batch.set(coParentPrivateRef, { addedBy: "dad", addedByName: "Dad" });
    batch.set(ownPrivateRef, { addedBy: "mom", addedByName: "Mom" });
    batch.set(sharedRef, { addedBy: "mom", addedByName: "Mom" });
    batch.set(profileRef, { members: [{ uid: "mom" }, { uid: "dad" }] });
    batch.set(deletedBabyToken, { babyId, ownerUid: "mom" });
    batch.set(otherBabyToken, { babyId: "other-baby", ownerUid: "mom" });
    await batch.commit();

    await babyRef.delete();

    await waitFor(async () => {
        const [tombstone, coParentPrivate, ownPrivate, shared, profile, token] = await Promise.all([
            tombstoneRef.get(),
            coParentPrivateRef.get(),
            ownPrivateRef.get(),
            sharedRef.get(),
            profileRef.get(),
            deletedBabyToken.get(),
        ]);
        return tombstone.exists
            && !coParentPrivate.exists
            && !ownPrivate.exists
            && !shared.exists
            && !profile.exists
            && !token.exists;
    });
    assert.equal((await otherBabyToken.get()).exists, true);
});

test("backfill recursively removes an already parentless baby subtree", async () => {
    const familyId = "existing-orphan-family";
    const babyId = "existing-orphan";
    const familyRef = db.collection("families").doc(familyId);
    const babyRef = familyRef.collection("babies").doc(babyId);
    const privateRef = babyRef.collection("waterIntakeLogs").doc("co-parent-private");
    const tombstoneRef = familyRef.collection("deletedBabies").doc(babyId);

    await familyRef.set({ bootstrapComplete: true });
    await privateRef.set({ addedBy: "dad", addedByName: "Dad" });

    await cleanupDeletedBaby(db, familyId, babyId);

    assert.equal((await tombstoneRef.get()).exists, true);
    assert.equal((await privateRef.get()).exists, false);
});

test("sleep end dispatch targets every exact-session activity and keeps reusable device tokens", async () => {
    const familyId = "push-family";
    const babyId = "baby-a";
    const sleepLogId = "sleep-a";
    const familyRef = db.collection("families").doc(familyId);
    const liveTokens = familyRef.collection("liveActivityTokens");
    const devices = familyRef.collection("devicePushTokens");
    const startedAt = Timestamp.fromDate(new Date("2026-08-14T10:00:00Z"));
    const seed = db.batch();
    for (const [id, ownerUid] of [["mom-phone", "mom"], ["mom-tablet", "mom"], ["dad-phone", "dad"]]) {
        seed.set(liveTokens.doc(id), {
            activityId: id,
            ownerUid,
            babyId,
            sleepLogId,
            kind: "sleep",
            environment: "sandbox",
            token: id === "dad-phone" ? "d".repeat(64) : id === "mom-phone" ? "a".repeat(64) : "b".repeat(64),
            effectiveStartDate: startedAt,
        });
    }
    seed.set(liveTokens.doc("other-session"), {
        activityId: "other-session",
        ownerUid: "mom",
        babyId,
        sleepLogId: "sleep-b",
        kind: "sleep",
        environment: "sandbox",
        token: "c".repeat(64),
        effectiveStartDate: startedAt,
    });
    seed.set(devices.doc("mom-device"), {
        ownerUid: "mom", environment: "sandbox", token: "e".repeat(64),
    });
    await seed.commit();

    const sends = [];
    const result = await dispatchSleepEnd(db, {
        familyId,
        babyId,
        sleepLogId,
        endedAt: new Date("2026-08-14T11:00:00Z"),
        credentials: {},
        now: new Date("2026-08-14T11:00:01Z"),
    }, {
        sendAPNs: async (request) => {
            sends.push(request);
            return { status: 200 };
        },
    });

    assert.equal(result.delivered, 3);
    assert.equal(sends.filter((request) => request.kind === "liveactivity").length, 3);
    assert.equal(sends.filter((request) => request.kind === "background").length, 1);
    assert.equal((await liveTokens.doc("mom-phone").get()).exists, false);
    assert.equal((await liveTokens.doc("mom-tablet").get()).exists, false);
    assert.equal((await liveTokens.doc("dad-phone").get()).exists, false);
    assert.equal((await liveTokens.doc("other-session").get()).exists, true);
    assert.equal((await devices.doc("mom-device").get()).exists, true);
});

test("transient APNs failure keeps the exact token for function retry", async () => {
    const familyId = "retry-family";
    const tokenRef = db.collection("families").doc(familyId)
        .collection("liveActivityTokens").doc("retry-activity");
    await tokenRef.set({
        activityId: "retry-activity",
        ownerUid: "mom",
        babyId: "baby-a",
        sleepLogId: "sleep-a",
        kind: "sleep",
        environment: "sandbox",
        token: "a".repeat(64),
        effectiveStartDate: Timestamp.fromDate(new Date("2026-08-14T10:00:00Z")),
    });

    await assert.rejects(() => dispatchSleepEnd(db, {
        familyId,
        babyId: "baby-a",
        sleepLogId: "sleep-a",
        endedAt: new Date("2026-08-14T11:00:00Z"),
        credentials: {},
    }, {
        sendAPNs: async () => ({ status: 503, reason: "ServiceUnavailable" }),
    }), AggregateError);

    assert.equal((await tokenRef.get()).exists, true);
});

test("a token registered after closure is reconciled from the terminal log or tombstone", async () => {
    const familyId = "late-token-family";
    const familyRef = db.collection("families").doc(familyId);
    const babyRef = familyRef.collection("babies").doc("baby-a");
    const endedToken = familyRef.collection("liveActivityTokens").doc("ended-token");
    const deletedToken = familyRef.collection("liveActivityTokens").doc("deleted-token");
    const start = Timestamp.fromDate(new Date("2026-08-14T10:00:00Z"));
    await babyRef.collection("sleepLogs").doc("ended-sleep").set({
        startedAt: start,
        endedAt: Timestamp.fromDate(new Date("2026-08-14T11:00:00Z")),
    });
    await babyRef.collection("deletions").doc("deleted-sleep").set({
        deletedAt: Timestamp.fromDate(new Date("2026-08-14T10:01:00Z")),
    });
    for (const [reference, sleepLogId, token] of [
        [endedToken, "ended-sleep", "a".repeat(64)],
        [deletedToken, "deleted-sleep", "b".repeat(64)],
    ]) {
        await reference.set({
            activityId: reference.id,
            ownerUid: "mom",
            babyId: "baby-a",
            sleepLogId,
            kind: "sleep",
            environment: "sandbox",
            token,
            effectiveStartDate: start,
        });
        assert.equal(await reconcileLiveActivityToken(db, {
            familyId,
            activityId: reference.id,
            credentials: {},
        }, {
            sendAPNs: async () => ({ status: 200 }),
        }), true);
        assert.equal((await reference.get()).exists, false);
    }
});

async function waitFor(predicate, timeoutMilliseconds = 20_000) {
    const deadline = Date.now() + timeoutMilliseconds;
    while (Date.now() < deadline) {
        if (await predicate()) {
            return;
        }
        await new Promise((resolve) => setTimeout(resolve, 100));
    }
    assert.fail("Timed out waiting for the family departure trigger");
}
