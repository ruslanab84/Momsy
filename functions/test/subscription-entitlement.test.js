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
    appleRootCAHash,
    loadAppleRootCAs,
    premiumEntitlementFor,
    updateFamilyPremium,
    verifyTransaction,
} = require("../subscription-entitlement");

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
