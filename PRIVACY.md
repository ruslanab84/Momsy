# Momsy Privacy Policy

**Effective date:** 1 June 2026

Momsy ("the app", "we", "us") helps parents track their baby's care and the
parent's own well-being. We take the privacy of your family's data seriously.
This policy explains what we collect, where it is stored, and the choices you
have. We **do not** sell your data and we **do not** use it for cross-app
tracking or advertising.

## 1. Information we process

| Category | Examples | Stored on device | Synced to your private iCloud | Sent to Firebase / Google |
|----------|----------|:---:|:---:|:---:|
| Baby profile | Baby's name, birth date, gender | ✓ | ✓ | Firestore (if signed in) |
| Baby health & care | Feeding, sleep, diaper & stool logs, temperature, growth measurements, vaccinations, bath, walks, pumping | ✓ | ✓ | Firestore (if signed in) |
| Parent well-being | Mood and energy entries, sleep, water intake, and the **EPDS postpartum-depression screening score** | ✓ | ✓ | — |
| Diary photos | Photos you attach to diary entries | ✓ | ✓ | Firebase Storage |
| AI chat | Messages you send to the in-app assistant | ✓ | ✓ | Google AI (Gemini) |
| Family sharing | Invite codes, family/member records | — | — | Firestore |
| Account | Sign in with Apple / Google identity | — | — | Firebase Authentication |

**Sensitive data notice.** Baby health records and the parent's EPDS
mental-health screening are health-related and sensitive. We process them only
to provide the app's tracking, charts, and reminders — never for advertising,
profiling, or sharing with third parties beyond the infrastructure providers
listed below.

## 2. Where your data is stored

- **On your device.** All entries are stored locally on your iPhone.
- **Your private iCloud (Apple CloudKit).** When you are signed in to iCloud,
  your data — including baby health records and your EPDS / well-being entries —
  is mirrored to your **private, Apple-encrypted CloudKit database** so it stays
  in sync across your own Apple devices. This database is tied to your Apple ID;
  we cannot read it, and it is not shared with other users. Apple's handling of
  this data is governed by [Apple's Privacy Policy](https://www.apple.com/legal/privacy/).
- **Firebase (Google).** If you create an account or use family sharing, profile
  and log data is stored in Google Firebase (Firestore, Storage, Authentication)
  to enable multi-device and family sync.
- **Google AI (Gemini).** Messages you send to the in-app assistant are
  processed by Google's Gemini model to generate a response.

## 3. How we use your data

- To provide core functionality: tracking, charts, reminders, and the daily tip.
- To sync your data across your own devices and, optionally, with family members
  you invite.
- To generate AI assistant responses and personalized tips.

We do **not** use your data for advertising and we do **not** track you across
other apps or websites (`NSPrivacyTracking = false`).

## 4. Data retention and deletion

- Local and iCloud data remain until you delete entries in the app, delete the
  app, or remove the app's data from your iCloud account (Settings → your name →
  iCloud → Manage Storage).
- Account-linked data in Firebase is retained while your account is active. To
  request deletion of cloud-stored data, contact us at the address below.

## 5. Children's data

Momsy is intended for use by parents and caregivers. Information about a child is
entered by the parent and processed solely to provide care-tracking features for
that family. The app is not directed at children.

## 6. Your choices

- Use the app without signing in to keep data on-device and in your private
  iCloud only.
- Sign out of iCloud to stop CloudKit sync.
- Delete individual entries or the whole app at any time.

## 7. Contact

Questions or deletion requests: **rusikabdulov@gmail.com**

We may update this policy; material changes will be reflected by a new effective
date above.
