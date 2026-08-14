const { classifyAPNsResponse, sendAPNs } = require("./apns");

const foundationEpochOffset = 978_307_200;
const concurrencyLimit = 8;

function toDate(value) {
    if (value instanceof Date) return value;
    if (value && typeof value.toDate === "function") return value.toDate();
    return null;
}

function foundationSeconds(value) {
    const date = toDate(value);
    if (!date) throw new Error("Invalid ActivityKit date");
    return date.getTime() / 1000 - foundationEpochOffset;
}

function liveActivityEndPayload({ startedAt, endedAt, now = new Date() }) {
    const nowSeconds = Math.floor(now.getTime() / 1000);
    return {
        aps: {
            timestamp: nowSeconds,
            event: "end",
            "dismissal-date": nowSeconds - 1,
            "content-state": {
                effectiveStartDate: foundationSeconds(startedAt),
                endDate: foundationSeconds(endedAt),
            },
        },
    };
}

function backgroundSleepEndPayload({ familyId, babyId, sleepLogId, endedAt }) {
    const end = toDate(endedAt);
    if (!end) throw new Error("Invalid sleep end date");
    return {
        aps: { "content-available": 1 },
        action: "end-sleep",
        familyId,
        babyId,
        sleepLogId,
        endedAt: Math.floor(end.getTime() / 1000),
    };
}

function selectLiveActivityTokens(tokens, babyId, sleepLogId) {
    return tokens.filter((token) =>
        token.babyId === babyId
        && token.sleepLogId === sleepLogId
        && token.kind === "sleep"
    );
}

function terminalSleepChange(before, after, eventTime) {
    const beforeEnd = toDate(before?.endedAt);
    const afterEnd = toDate(after?.endedAt);
    if (after && afterEnd && !beforeEnd) return afterEnd;
    if (before && !after) return toDate(eventTime);
    return null;
}

function isDocumentId(value) {
    return typeof value === "string"
        && value.length > 0
        && value.length <= 1_500
        && !value.includes("/");
}

function validPushToken(record) {
    return record
        && typeof record.token === "string"
        && record.token.length >= 32
        && record.token.length <= 512
        && /^[0-9a-f]+$/i.test(record.token)
        && (record.environment === "sandbox" || record.environment === "production");
}

async function dispatchSleepEnd(
    db,
    { familyId, babyId, sleepLogId, endedAt, credentials, now = new Date() },
    dependencies = {}
) {
    validateScope(familyId, babyId, sleepLogId, endedAt);
    const sender = dependencies.sendAPNs ?? sendAPNs;
    const familyRef = db.collection("families").doc(familyId);
    const [liveSnapshot, deviceSnapshot] = await Promise.all([
        familyRef.collection("liveActivityTokens")
            .where("babyId", "==", babyId)
            .where("sleepLogId", "==", sleepLogId)
            .get(),
        familyRef.collection("devicePushTokens").get(),
    ]);
    const failures = [];
    let delivered = 0;

    await mapLimit(liveSnapshot.docs, async (document) => {
        const result = await deliverLiveActivityToken(
            document,
            endedAt,
            credentials,
            now,
            sender
        );
        if (result === "delivered") delivered += 1;
        if (result instanceof Error) failures.push(result);
    });

    const backgroundPayload = backgroundSleepEndPayload({
        familyId, babyId, sleepLogId, endedAt,
    });
    await mapLimit(deviceSnapshot.docs, async (document) => {
        const record = document.data();
        if (!validPushToken(record)) {
            await document.ref.delete();
            return;
        }
        try {
            const response = await sender({
                deviceToken: record.token,
                environment: record.environment,
                kind: "background",
                payload: backgroundPayload,
                ...credentials,
                now,
            });
            const classification = classifyAPNsResponse(response.status, response.reason);
            if (classification === "invalid-token") {
                await document.ref.delete();
            } else if (classification === "transient" || classification === "fatal") {
                failures.push(apnsError(response, document.id));
            }
        } catch (error) {
            failures.push(error);
        }
    });

    if (failures.length > 0) {
        throw new AggregateError(failures, "Sleep end push delivery failed");
    }
    return { delivered, backgroundDevices: deviceSnapshot.size };
}

async function reconcileLiveActivityToken(
    db,
    { familyId, activityId, credentials, now = new Date() },
    dependencies = {}
) {
    if (!isDocumentId(familyId) || !isDocumentId(activityId)) {
        throw new Error("Invalid Live Activity token scope");
    }
    const tokenRef = db.collection("families").doc(familyId)
        .collection("liveActivityTokens").doc(activityId);
    const tokenDocument = await tokenRef.get();
    if (!tokenDocument.exists) return false;
    const token = tokenDocument.data();
    if (!isDocumentId(token.babyId) || !isDocumentId(token.sleepLogId)) {
        await tokenRef.delete();
        return false;
    }
    const babyRef = db.collection("families").doc(familyId)
        .collection("babies").doc(token.babyId);
    const [sleepDocument, tombstone] = await Promise.all([
        babyRef.collection("sleepLogs").doc(token.sleepLogId).get(),
        babyRef.collection("deletions").doc(token.sleepLogId).get(),
    ]);
    const endedAt = toDate(sleepDocument.get("endedAt")) ?? toDate(tombstone.get("deletedAt"));
    if (!endedAt) return false;
    const result = await deliverLiveActivityToken(
        tokenDocument,
        endedAt,
        credentials,
        now,
        dependencies.sendAPNs ?? sendAPNs
    );
    if (result instanceof Error) throw result;
    return result === "delivered";
}

async function deliverLiveActivityToken(document, endedAt, credentials, now, sender) {
    const record = document.data();
    const startedAt = toDate(record.effectiveStartDate);
    if (!validPushToken(record) || !startedAt) {
        await document.ref.delete();
        return "invalid";
    }
    try {
        const response = await sender({
            deviceToken: record.token,
            environment: record.environment,
            kind: "liveactivity",
            payload: liveActivityEndPayload({ startedAt, endedAt, now }),
            ...credentials,
            now,
        });
        const classification = classifyAPNsResponse(response.status, response.reason);
        if (classification === "success" || classification === "invalid-token") {
            await document.ref.delete();
            return classification === "success" ? "delivered" : "invalid";
        }
        return apnsError(response, document.id);
    } catch (error) {
        return error;
    }
}

function validateScope(familyId, babyId, sleepLogId, endedAt) {
    if (!isDocumentId(familyId)
        || !isDocumentId(babyId)
        || !isDocumentId(sleepLogId)
        || !toDate(endedAt)) {
        throw new Error("Invalid sleep end push scope");
    }
}

function apnsError(response, tokenId) {
    return new Error(`APNs rejected ${tokenId}: ${response.status} ${response.reason ?? "Unknown"}`);
}

async function mapLimit(items, operation) {
    let cursor = 0;
    const workers = Array.from({ length: Math.min(concurrencyLimit, items.length) }, async () => {
        while (cursor < items.length) {
            const item = items[cursor];
            cursor += 1;
            await operation(item);
        }
    });
    await Promise.all(workers);
}

module.exports = {
    backgroundSleepEndPayload,
    dispatchSleepEnd,
    foundationSeconds,
    liveActivityEndPayload,
    reconcileLiveActivityToken,
    selectLiveActivityTokens,
    terminalSleepChange,
};
