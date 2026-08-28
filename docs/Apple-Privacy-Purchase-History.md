# Apple Privacy: StoreKit transaction JWS

## Conclusion for Momsy

Momsy sends a StoreKit signed transaction JWS to its Firebase backend, verifies it, and stores subscription-entitlement fields against the authenticated Momsy user/family. Apple defines **Purchase History** as an account's or individual's purchases or purchase tendencies. This flow therefore needs the following declaration in both places:

| Answer | Value |
| --- | --- |
| Data type | **Purchases → Purchase History** |
| Purpose | **App Functionality** only (subscription verification, feature access, fraud/security) |
| Linked to the user | **Yes** — the transaction is associated with the authenticated Momsy account/family |
| Used for tracking | **No** — provided it is not combined with third-party data for advertising/measurement and is not shared with a data broker |

Do **not** select **Payment Info** for the StoreKit JWS alone: Apple excludes payment information entered through a payment service when the developer never receives it. Add Analytics, Product Personalization, advertising, or another purpose only if the transaction data is actually used for that additional purpose.

The optional-disclosure exception does not fit this flow: Apple requires disclosure unless every exception condition is met, including infrequent collection outside the app's primary functionality and an affirmative user submission each time. Subscription entitlement synchronization is app functionality and can recur for purchases, restores, and transaction updates.

## Two separate surfaces

1. In `PrivacyInfo.xcprivacy`, add `NSPrivacyCollectedDataTypePurchaseHistory` with `NSPrivacyCollectedDataTypePurposeAppFunctionality`, `NSPrivacyCollectedDataTypeLinked = true`, and `NSPrivacyCollectedDataTypeTracking = false`.
2. In App Store Connect → App Privacy, publish **Purchase History** with the same purpose/linking/tracking answers. The manifest does not replace this step: Apple says Xcode's aggregated privacy report is a reference when providing App Store Connect privacy details, while App Store Connect separately requires and publishes the answers on the product page.
3. The public privacy policy should state that StoreKit signed transaction/subscription data is sent to Firebase for verification and entitlement management, linked to the Momsy account/family, and not used for advertising or cross-company tracking.

## Official Apple sources

- [App privacy details on the App Store](https://developer.apple.com/app-store/app-privacy-details/) — collection definition, Purchase History, purposes, linking, tracking, and disclosure exceptions.
- [NSPrivacyCollectedDataType](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacycollecteddatatypes/nsprivacycollecteddatatype) — official `NSPrivacyCollectedDataTypePurchaseHistory` manifest value.
- [NSPrivacyCollectedDataTypePurposes](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacycollecteddatatypes/nsprivacycollecteddatatypepurposes) — official `NSPrivacyCollectedDataTypePurposeAppFunctionality` value.
- [Describing data use in privacy manifests](https://developer.apple.com/documentation/bundleresources/describing-data-use-in-privacy-manifests) — manifest fields and Xcode privacy report role.
- [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/) — separate App Store Connect answers and publishing workflow.
