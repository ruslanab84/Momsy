const assert = require("node:assert/strict");
const { test } = require("node:test");
const { premiumEntitlementFor } = require("../subscription-entitlement");

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
