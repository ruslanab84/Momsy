# App Store Connect — App Privacy Checklist

Use this checklist for the next build. App Store Connect answers must match
`Momsy/PrivacyInfo.xcprivacy`, `PRIVACY.md`, the runtime consent flows, and the
privacy manifests included by third-party SDKs.

## Data collection

Declare each item for **App Functionality**, **Used for tracking = No**:

- [ ] **Health & Fitness → Health** — baby health/care logs and caregiver sleep
      records. **Linked to identity = Yes** because optional Firestore sync is
      scoped to a Firebase user/family.
- [ ] **Sensitive Info** — do **not** declare. EPDS and mood/well-being records
      (`MomMoodRecord`) never leave the device, and on-device-only data is not
      "collected" under Apple's definition. If App Store Connect currently has
      Sensitive Info checked from an earlier submission, uncheck it. Re-verify
      before each submission: `momMood` absent from
      `BabySyncService.allSubcollections` and absent from `CloudSyncDownloader`.
- [ ] **Contact Info → Name** — baby's name and provider display name.
      **Linked = Yes** when cloud sync is enabled.
- [ ] **Contact Info → Email Address** — only when Apple/Google provides it to
      Firebase Authentication. **Linked = Yes**.
- [ ] **Identifiers → User ID** — anonymous or provider-backed Firebase Auth ID.
      **Linked = Yes**.
- [ ] **User Content → Other User Content** — synced diary text and free-form
      care records. **Linked = Yes**.

Optional collection still counts as collection for App Store privacy answers.

## Consent and runtime checks

- [ ] Fresh onboarding shows the Firebase Authentication/Firestore disclosure
      before anonymous auth, family setup, or cloud sync.
- [ ] **Keep data on this device** reaches the app without a Firebase user or
      Firestore writes.
- [ ] Existing installs without a stored choice receive the migration prompt.
- [ ] Settings → Data & Privacy → Cloud sync can withdraw consent; after
      withdrawal, new data remains local and live sync stops.
- [ ] The release archive contains no Firebase AI Logic or Gemini integration,
      and no app data is sent to a generative-AI provider.
- [ ] Delete all data reports success only after server verification and
      Firebase Auth deletion; pending/reauth states remain visible and retryable.

## Third-party SDK cross-check

- [ ] Archive contains Firebase Core, Authentication, Firestore, App Check, and
      Google Sign-In.
- [ ] Archive does **not** contain Firebase Analytics, Firebase Realtime
      Database, Firebase Storage, Firebase AI Logic, advertising, or tracking
      SDKs.
- [ ] Review the current Firebase Apple data-disclosure page for every Firebase
      build target present in the archive, including transitive targets.

## Tracking and manifests

- [ ] App and widget manifests declare `NSPrivacyTracking = false`.
- [ ] Required-reason API declarations match the APIs used in each bundle.
- [ ] Third-party SDK privacy manifests are present and valid in the archive.
- [ ] Generate Xcode's privacy report from the release archive and reconcile it
      against App Store Connect before submission.

## Public policy

- [ ] Publish the current `PRIVACY.md` content at
      `https://ruslanab84.github.io/-momsy-site/`.
- [ ] Confirm the page is reachable from Settings and the paywall.
- [ ] Confirm the effective date, support email, deletion behavior, consent
      behavior, Firebase SDK list, and no-generative-AI statement match the
      submitted binary.
