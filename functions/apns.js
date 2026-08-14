const { createPrivateKey, createHash, sign } = require("node:crypto");
const http2 = require("node:http2");

const invalidTokenReasons = new Set(["BadDeviceToken", "DeviceTokenNotForTopic", "Unregistered"]);
const clients = new Map();
let cachedProviderToken;

function base64url(value) {
    return Buffer.from(value).toString("base64url");
}

function providerToken({ authKey, keyId, teamId, now = new Date(), force = false }) {
    if (!authKey || !keyId || !teamId) {
        throw new Error("Missing APNs credentials");
    }
    const issuedAt = Math.floor(now.getTime() / 1000);
    const cacheKey = createHash("sha256").update(keyId).update("\0").update(teamId).digest("hex");
    if (!force
        && cachedProviderToken?.cacheKey === cacheKey
        && issuedAt - cachedProviderToken.issuedAt < 50 * 60) {
        return cachedProviderToken.token;
    }

    const header = base64url(JSON.stringify({ alg: "ES256", kid: keyId }));
    const claims = base64url(JSON.stringify({ iss: teamId, iat: issuedAt }));
    const unsigned = `${header}.${claims}`;
    const signature = sign("sha256", Buffer.from(unsigned), {
        key: createPrivateKey(authKey.replace(/\\n/g, "\n")),
        dsaEncoding: "ieee-p1363",
    }).toString("base64url");
    const token = `${unsigned}.${signature}`;
    cachedProviderToken = { cacheKey, issuedAt, token };
    return token;
}

function apnsHeaders({ kind, bundleId, authorization, expiration }) {
    if (kind !== "liveactivity" && kind !== "background") {
        throw new Error("Invalid APNs push kind");
    }
    return {
        "apns-push-type": kind,
        "apns-topic": kind === "liveactivity"
            ? `${bundleId}.push-type.liveactivity`
            : bundleId,
        "apns-priority": kind === "liveactivity" ? "10" : "5",
        "apns-expiration": String(expiration),
        authorization: `bearer ${authorization}`,
    };
}

function classifyAPNsResponse(status, reason) {
    if (status === 200) return "success";
    if (status === 410 || invalidTokenReasons.has(reason)) return "invalid-token";
    if (status === 429 || status >= 500) return "transient";
    return "fatal";
}

function endpointFor(environment) {
    if (environment === "sandbox") return "https://api.sandbox.push.apple.com";
    if (environment === "production") return "https://api.push.apple.com";
    throw new Error("Invalid APNs environment");
}

function clientFor(endpoint) {
    const existing = clients.get(endpoint);
    if (existing && !existing.closed && !existing.destroyed) return existing;
    const client = http2.connect(endpoint);
    client.on("error", () => clients.delete(endpoint));
    client.on("close", () => clients.delete(endpoint));
    clients.set(endpoint, client);
    return client;
}

async function sendAPNs({
    deviceToken,
    environment,
    kind,
    payload,
    authKey,
    keyId,
    teamId,
    bundleId = "RuslanAbd.Momsy",
    now = new Date(),
    timeoutMilliseconds = 10_000,
}, refreshAttempted = false) {
    if (typeof deviceToken !== "string"
        || deviceToken.length < 32
        || deviceToken.length > 512
        || !/^[0-9a-f]+$/i.test(deviceToken)) {
        throw new Error("Invalid APNs device token");
    }
    const endpoint = endpointFor(environment);
    const authorization = providerToken({ authKey, keyId, teamId, now, force: refreshAttempted });
    const expiration = Math.floor(now.getTime() / 1000) + (kind === "liveactivity" ? 300 : 900);
    const headers = {
        ":method": "POST",
        ":path": `/3/device/${deviceToken}`,
        ...apnsHeaders({ kind, bundleId, authorization, expiration }),
    };
    const response = await request(clientFor(endpoint), headers, payload, timeoutMilliseconds);
    if (response.status === 403
        && response.reason === "ExpiredProviderToken"
        && !refreshAttempted) {
        cachedProviderToken = undefined;
        return sendAPNs({
            deviceToken,
            environment,
            kind,
            payload,
            authKey,
            keyId,
            teamId,
            bundleId,
            now: new Date(),
            timeoutMilliseconds,
        }, true);
    }
    return response;
}

function request(client, headers, payload, timeoutMilliseconds) {
    return new Promise((resolve, reject) => {
        let settled = false;
        let status = 0;
        const chunks = [];
        const stream = client.request(headers);
        const finish = (operation) => {
            if (settled) return;
            settled = true;
            clearTimeout(timeout);
            operation();
        };
        const timeout = setTimeout(() => {
            stream.close(http2.constants.NGHTTP2_CANCEL);
            finish(() => reject(new Error("APNs request timed out")));
        }, timeoutMilliseconds);

        stream.setEncoding("utf8");
        stream.on("response", (responseHeaders) => {
            status = Number(responseHeaders[":status"] ?? 0);
        });
        stream.on("data", (chunk) => chunks.push(chunk));
        stream.on("error", (error) => finish(() => reject(error)));
        stream.on("end", () => finish(() => {
            let reason;
            try {
                reason = JSON.parse(chunks.join("") || "{}").reason;
            } catch {
                reason = undefined;
            }
            resolve({ status, reason });
        }));
        stream.end(JSON.stringify(payload));
    });
}

module.exports = {
    apnsHeaders,
    classifyAPNsResponse,
    providerToken,
    sendAPNs,
};
