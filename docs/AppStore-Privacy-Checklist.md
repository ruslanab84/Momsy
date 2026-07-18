# App Store Connect — App Privacy Checklist

Use this checklist when submitting the next build. These settings live in
**App Store Connect → your app → App Privacy** and **cannot** be changed from
code. They must stay consistent with `Momsy/PrivacyInfo.xcprivacy` and
`PRIVACY.md`.

## Data Collection — declare these types

For each, set **Purpose = App Functionality**, **Linked to identity = No** (for
on-device/iCloud-only types), **Used for tracking = No**.

- [ ] **Health & Fitness → Health** — baby health/care logs (feeding, sleep,
      temperature, growth, diaper/stool, vaccinations).
- [ ] **Sensitive Info** — parent's EPDS mental-health screening + mood/well-being
      entries. (Apple classifies mental-health screening as sensitive.)
- [ ] **Contact Info → Name** — baby's name (and account name if Sign in used).
- [ ] **User Content → Other User Content** — AI assistant chat messages.
- [ ] **Identifiers / Contact Info** — only if you collect account email via
      Sign in with Apple / Google (Linked = Yes).

## Storage / sync note

- [ ] The App Privacy questionnaire has **no field for cloud storage location**.
      Ensure the **Health** and **Sensitive Info** types above are declared —
      that is what reflects the sensitive data flow.

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
