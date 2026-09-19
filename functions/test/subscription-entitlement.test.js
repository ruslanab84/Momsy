const assert = require("node:assert/strict");
const { X509Certificate } = require("node:crypto");
const { test } = require("node:test");
const { FieldValue, Timestamp } = require("firebase-admin/firestore");
const {
    Environment,
    VerificationException,
    VerificationStatus,
} = require("@apple/app-store-server-library");
const {
    appAccountTokenFor,
    appleRootCAHash,
    bindEntitlementToCurrentFamily,
    loadAppleRootCAs,
    matchesAppAccountToken,
    premiumEntitlementFor,
    refreshBoundEntitlement,
    updateFamilyPremium,
    verifyNotification,
    verifyTransaction,
} = require("../subscription-entitlement");

test("app account tokens are stable and reject another Momsy account", () => {
    const token = appAccountTokenFor("uid-a");

    assert.equal(token, "65cf791d-d515-559f-9e18-4d4491df6c9d");
    assert.equal(matchesAppAccountToken({ appAccountToken: token }, "uid-a"), true);
    assert.equal(matchesAppAccountToken({ appAccountToken: token }, "uid-b"), false);
    assert.equal(matchesAppAccountToken({ appAccountToken: null }, "uid-b"), true);
});

test("a signed account token cannot bind to another Firebase user", async () => {
    await assert.rejects(
        bindEntitlementToCurrentFamily({}, "uid-b", {
            appAccountToken: appAccountTokenFor("uid-a"),
        }),
        (error) => error.code === "owned_by_another_account"
            && error.httpStatus === 409
            && error.retryable === false
    );
});

test("the bundled Apple root has the pinned identity and self-signature", () => {
    const [certificate] = loadAppleRootCAs();
    const root = new X509Certificate(certificate);

    assert.equal(
        require("node:crypto").createHash("sha256").update(certificate).digest("hex"),
        appleRootCAHash
    );
    assert.equal(root.subject, root.issuer);
    assert.equal(root.verify(root.publicKey), true);
});

test("production verification runs first with the App Store ID", async () => {
    const calls = [];
    const decoded = { environment: Environment.PRODUCTION };
    const result = await verifyTransaction("signed", {
        appAppleId: 6784641297,
        makeVerifier(environment, appAppleId) {
            calls.push({ environment, appAppleId });
            return { verifyAndDecodeTransaction: async () => decoded };
        },
    });

    assert.equal(result, decoded);
    assert.deepEqual(calls, [{
        environment: Environment.PRODUCTION,
        appAppleId: 6784641297,
    }]);
});

test("sandbox is attempted only after an invalid-environment result", async () => {
    const calls = [];
    const decoded = { environment: Environment.SANDBOX };
    const result = await verifyTransaction("signed", {
        appAppleId: 6784641297,
        makeVerifier(environment, appAppleId) {
            calls.push({ environment, appAppleId });
            return {
                verifyAndDecodeTransaction: async () => {
                    if (environment === Environment.PRODUCTION) {
                        throw new VerificationException(VerificationStatus.INVALID_ENVIRONMENT);
                    }
                    return decoded;
                },
            };
        },
    });

    assert.equal(result, decoded);
    assert.deepEqual(calls, [
        { environment: Environment.PRODUCTION, appAppleId: 6784641297 },
        { environment: Environment.SANDBOX, appAppleId: undefined },
    ]);
});

test("retryable Apple verification failures remain retryable and skip sandbox", async () => {
    const calls = [];
    await assert.rejects(
        verifyTransaction("signed", {
            appAppleId: 6784641297,
            makeVerifier(environment) {
                calls.push(environment);
                return {
                    verifyAndDecodeTransaction: async () => {
                        throw new VerificationException(
                            VerificationStatus.RETRYABLE_VERIFICATION_FAILURE
                        );
                    },
                };
            },
        }),
        (error) => error.code === "verification_unavailable"
            && error.httpStatus === 503
            && error.retryable === true
    );
    assert.deepEqual(calls, [Environment.PRODUCTION]);
});

test("family summaries explicitly delete a stale revocation field", () => {
    const writes = [];
    const transaction = {
        set(ref, data, options) { writes.push({ ref, data, options }); },
    };
    const db = {
        collection() {
            return { doc(id) { return { id }; } };
        },
    };
    updateFamilyPremium(transaction, db, "family-a", { docs: [] }, {
        id: "1000000123456789",
        familyId: "family-a",
        productId: "com.ruslanabdulov.momsy.premium.monthly",
        expiresAt: Timestamp.fromMillis(Date.now() + 60_000),
    });

    const summary = writes[0].data.premiumEntitlement;
    assert.equal(summary.active, true);
    assert.equal(summary.revokedAt.isEqual(FieldValue.delete()), true);
});

test("an active paid subscription unlocks the whole Momsy family", () => {
    const result = premiumEntitlementFor({
        productId: "com.ruslanabdulov.momsy.premium.monthly",
        originalTransactionId: "1000000123456789",
        expiresDate: Date.now() + 60_000,
    }, new Date());

    assert.equal(result.isActive, true);
    assert.equal(result.originalTransactionId, "1000000123456789");
});

test("a revoked or expired transaction never unlocks a family", () => {
    assert.equal(premiumEntitlementFor({
        productId: "com.ruslanabdulov.momsy.premium.monthly",
        originalTransactionId: "1000000123456789",
        expiresDate: Date.now() - 1,
    }, new Date()).isActive, false);

    assert.equal(premiumEntitlementFor({
        productId: "com.ruslanabdulov.momsy.premium.annual",
        originalTransactionId: "1000000123456789",
        expiresDate: Date.now() + 60_000,
        revocationDate: Date.now(),
    }, new Date()).isActive, false);
});

test("unknown products cannot create a family Premium entitlement", () => {
    assert.equal(premiumEntitlementFor({
        productId: "com.other.product",
        originalTransactionId: "1000000123456789",
        expiresDate: Date.now() + 60_000,
    }, new Date()).isActive, false);
});

test("notifications verify with the notification decoder and the same environment fallback", async () => {
    const calls = [];
    const decoded = { notificationType: "DID_RENEW" };
    const result = await verifyNotification("payload", {
        appAppleId: 6784641297,
        makeVerifier(environment) {
            calls.push(environment);
            return {
                verifyAndDecodeNotification: async () => {
                    if (environment === Environment.PRODUCTION) {
                        throw new VerificationException(VerificationStatus.INVALID_ENVIRONMENT);
                    }
                    return decoded;
                },
            };
        },
    });

    assert.equal(result, decoded);
    assert.deepEqual(calls, [Environment.PRODUCTION, Environment.SANDBOX]);
});

// Minimal in-memory Firestore: one bound entitlement doc plus the family doc writes.
function notificationDb(existing) {
    const writes = [];
    const ref = (path) => ({ path, id: path.split("/").pop() });
    const db = {
        collection(name) {
            return {
                doc: (id) => ref(`${name}/${id}`),
                where: () => ({ query: name }),
            };
        },
        async runTransaction(body) {
            return body({
                async get(target) {
                    if (target.query) {
                        return { docs: existing ? [{ id: "otid", data: () => existing }] : [] };
                    }
                    if (target.path === "subscriptionEntitlements/otid") {
                        return {
                            exists: existing !== undefined,
                            get: (field) => existing?.[field],
                        };
                    }
                    return { exists: false, get: () => undefined };
                },
                set(target, data) { writes.push({ path: target.path, data }); },
            });
        },
    };
    return { db, writes };
}

const monthly = "com.ruslanabdulov.momsy.premium.monthly";
const entitlement = (expiresDate, revocationDate = null) => ({
    originalTransactionId: "otid",
    productId: monthly,
    expiresDate,
    revocationDate,
});

test("a renewal notification extends the bound family's Premium", async () => {
    const now = Date.now();
    const { db, writes } = notificationDb({
        ownerUid: "uid-a",
        familyId: "family-a",
        productId: monthly,
        expiresAt: Timestamp.fromMillis(now - 1_000),
        revokedAt: null,
    });

    assert.equal(await refreshBoundEntitlement(db, entitlement(now + 86_400_000)), true);

    const family = writes.find((write) => write.path === "families/family-a");
    assert.equal(family.data.premiumEntitlement.active, true);
    assert.equal(family.data.premiumEntitlement.expiresAt.toMillis(), now + 86_400_000);
    assert.equal(writes[0].data.ownerUid, "uid-a");
});

test("a refund notification removes family Premium", async () => {
    const expires = Date.now() + 86_400_000;
    const { db, writes } = notificationDb({
        ownerUid: "uid-a",
        familyId: "family-a",
        productId: monthly,
        expiresAt: Timestamp.fromMillis(expires),
        revokedAt: null,
    });

    await refreshBoundEntitlement(db, entitlement(expires, Date.now()));

    const family = writes.find((write) => write.path === "families/family-a");
    assert.equal(family.data.premiumEntitlement.isEqual(FieldValue.delete()), true);
});

test("an out-of-order older notification never shortens access", async () => {
    const now = Date.now();
    const { db, writes } = notificationDb({
        ownerUid: "uid-a",
        familyId: "family-a",
        expiresAt: Timestamp.fromMillis(now + 86_400_000),
    });

    assert.equal(await refreshBoundEntitlement(db, entitlement(now + 1_000)), false);
    assert.deepEqual(writes, []);
});

test("an unbound subscription is ignored until its owner syncs it", async () => {
    const { db, writes } = notificationDb(undefined);

    assert.equal(await refreshBoundEntitlement(db, entitlement(Date.now() + 1_000)), false);
    assert.deepEqual(writes, []);
});
