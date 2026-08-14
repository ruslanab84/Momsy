const assert = require("node:assert/strict");
const { test } = require("node:test");
const {
    apnsHeaders,
    classifyAPNsResponse,
} = require("../apns");
const {
    backgroundSleepEndPayload,
    foundationSeconds,
    liveActivityEndPayload,
    selectLiveActivityTokens,
    terminalSleepChange,
} = require("../live-activity");

test("Live Activity end payload uses APNs Unix time and Foundation content dates", () => {
    const now = new Date("2026-08-14T12:00:00.000Z");
    const startedAt = new Date("2026-08-14T10:00:00.000Z");
    const endedAt = new Date("2026-08-14T11:30:00.000Z");
    const payload = liveActivityEndPayload({ startedAt, endedAt, now });

    assert.equal(payload.aps.timestamp, Math.floor(now.getTime() / 1000));
    assert.equal(payload.aps["dismissal-date"], Math.floor(now.getTime() / 1000) - 1);
    assert.equal(payload.aps.event, "end");
    assert.equal(
        payload.aps["content-state"].effectiveStartDate,
        foundationSeconds(startedAt)
    );
    assert.equal(payload.aps["content-state"].endDate, foundationSeconds(endedAt));
});

test("background widget payload is silent and session scoped", () => {
    const endedAt = new Date("2026-08-14T11:30:00.000Z");
    assert.deepEqual(backgroundSleepEndPayload({
        familyId: "family-a",
        babyId: "baby-a",
        sleepLogId: "sleep-a",
        endedAt,
    }), {
        aps: { "content-available": 1 },
        action: "end-sleep",
        familyId: "family-a",
        babyId: "baby-a",
        sleepLogId: "sleep-a",
        endedAt: Math.floor(endedAt.getTime() / 1000),
    });
});

test("routing includes every device for only the exact baby and session", () => {
    const tokens = [
        { id: "mom-phone", kind: "sleep", ownerUid: "mom", babyId: "baby-a", sleepLogId: "sleep-a" },
        { id: "mom-tablet", kind: "sleep", ownerUid: "mom", babyId: "baby-a", sleepLogId: "sleep-a" },
        { id: "dad-phone", kind: "sleep", ownerUid: "dad", babyId: "baby-a", sleepLogId: "sleep-a" },
        { id: "other-baby", kind: "sleep", ownerUid: "mom", babyId: "baby-b", sleepLogId: "sleep-a" },
        { id: "other-sleep", kind: "sleep", ownerUid: "mom", babyId: "baby-a", sleepLogId: "sleep-b" },
        { id: "other-kind", kind: "feeding", ownerUid: "mom", babyId: "baby-a", sleepLogId: "sleep-a" },
    ];

    assert.deepEqual(
        selectLiveActivityTokens(tokens, "baby-a", "sleep-a").map((token) => token.id),
        ["mom-phone", "mom-tablet", "dad-phone"]
    );
});

test("terminal transition covers completed creates, updates, and deletes", () => {
    const start = new Date("2026-08-14T10:00:00.000Z");
    const end = new Date("2026-08-14T11:00:00.000Z");
    const eventTime = new Date("2026-08-14T11:00:01.000Z");

    assert.equal(terminalSleepChange(null, { startedAt: start, endedAt: end }, eventTime), end);
    assert.equal(
        terminalSleepChange({ startedAt: start, endedAt: null }, { startedAt: start, endedAt: end }, eventTime),
        end
    );
    assert.equal(terminalSleepChange({ startedAt: start, endedAt: null }, null, eventTime), eventTime);
    assert.equal(terminalSleepChange({ startedAt: start, endedAt: null }, { startedAt: start }, eventTime), null);
});

test("APNs headers and response classification preserve retry semantics", () => {
    const liveHeaders = apnsHeaders({
        kind: "liveactivity",
        bundleId: "RuslanAbd.Momsy",
        authorization: "jwt",
        expiration: 123,
    });
    assert.equal(liveHeaders["apns-push-type"], "liveactivity");
    assert.equal(liveHeaders["apns-topic"], "RuslanAbd.Momsy.push-type.liveactivity");
    assert.equal(liveHeaders["apns-priority"], "10");
    assert.equal(liveHeaders["apns-expiration"], "123");

    assert.equal(classifyAPNsResponse(200), "success");
    assert.equal(classifyAPNsResponse(410, "Unregistered"), "invalid-token");
    assert.equal(classifyAPNsResponse(400, "BadDeviceToken"), "invalid-token");
    assert.equal(classifyAPNsResponse(429, "TooManyRequests"), "transient");
    assert.equal(classifyAPNsResponse(503, "ServiceUnavailable"), "transient");
    assert.equal(classifyAPNsResponse(400, "BadPayload"), "fatal");
});
