# App Store Connect — App Privacy Checklist

Use this checklist when submitting the next build. These settings live in
**App Store Connect → your app → App Privacy** and **cannot** be changed from
code. They must stay consistent with `Momsy/PrivacyInfo.xcprivacy` and
`PRIVACY.md`.

## Why this matters now

SwiftData is configured with `cloudKitDatabase: .private(...)`
(`Momsy/Core/Persistence/AppPersistence.swift`), so all records — including baby
health logs and the parent's **EPDS postpartum-depression screening
(`MomMoodRecord.epdsScore`)** — now sync to the user's private, encrypted iCloud
(CloudKit). "Syncing to Apple's servers" is a new data flow that must be
disclosed.

## Data Collection — declare these types

For each, set **Purpose = App Functionality**, **Linked to identity = No** (for
on-device/iCloud-only types), **Used for tracking = No**.

- [ ] **Health & Fitness → Health** — baby health/care logs (feeding, sleep,
      temperature, growth, diaper/stool, vaccinations).
- [ ] **Sensitive Info** — parent's EPDS mental-health screening + mood/well-being
      entries. (Apple classifies mental-health screening as sensitive.)
- [ ] **Contact Info → Name** — baby's name (and account name if Sign in used).
- [ ] **User Content → Photos or Videos** — diary photos (Linked = Yes, since
      stored in Firebase Storage under the account).
- [ ] **User Content → Other User Content** — AI assistant chat messages.
- [ ] **Identifiers / Contact Info** — only if you collect account email via
      Sign in with Apple / Google (Linked = Yes).

## Storage / sync note

- [ ] The App Privacy questionnaire has **no field for iCloud storage location**.
      Ensure the **Health** and **Sensitive Info** types above are declared —
      that is what reflects the new sensitive data flow. Data lives in the user's
      private, Apple-encrypted CloudKit DB plus (optionally) Firebase.

## Tracking

- [ ] Confirm **"Data Not Used to Track You."** (`NSPrivacyTracking = false` in
      the manifest.)

## Privacy Policy URL

- [ ] Set the **Privacy Policy URL** field to the public page hosting the
      contents of `PRIVACY.md`.
- [ ] Set the same URL in the in-app Settings → Privacy row
      (`SettingsView.swift`, `privacyPolicyURL` constant).

## Cross-check before submit

- [ ] `Momsy/PrivacyInfo.xcprivacy` declared types match the App Privacy answers.
- [ ] `PRIVACY.md` is published and reachable at the configured URL.
