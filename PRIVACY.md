# Momsy Privacy Policy

**Effective date:** 2 June 2026

Momsy ("the app", "we", "us") helps parents track their baby's care and the
parent's own well-being. We take the privacy of your family's data seriously.
This policy explains what we collect, where it is stored, and the choices you
have. We **do not** sell your data and we **do not** use it for cross-app
tracking or advertising.

## 1. Information we process

| Category | Examples | Stored on device | Synced to your private cloud |
|----------|----------|:---:|:---:|
| Baby profile | Baby's name, birth date, gender | ✓ | Firestore |
| Baby health & care | Feeding, sleep, diaper & stool logs, temperature, growth measurements, vaccinations, bath, walks, pumping | ✓ | Firestore |
| Parent well-being | Mood and energy entries, sleep, water intake, and the **EPDS postpartum-depression screening score** | ✓ | Firestore |
| AI daily tips | A short summary of your baby's age and care context used to generate the daily tip | — | Google AI (Gemini) |
| Family sharing | Invite codes, family/member records | — | Firestore |
| Account | Anonymous device identity, or Sign in with Apple / Google identity | — | Firebase Authentication |

**Sensitive data notice.** Baby health records and the parent's EPDS
mental-health screening are health-related and sensitive. We process them only
to provide the app's tracking, charts, and reminders — never for advertising,
profiling, or sharing with third parties beyond the infrastructure providers
listed below.

## 2. Where your data is stored

- **On your device.** All entries are stored locally on your iPhone.
- **Firebase (Google).** Momsy uses Google Firebase as its single cloud backend.
  Your data — including baby health records and your EPDS / well-being entries —
  is stored in **Firebase Firestore** under a private account so it stays in sync across your own devices and any
  family members you invite. To give you sync without a mandatory login, the app
  signs in **anonymously** by default; you can optionally link a Sign in with
  Apple or Google account. We cannot use your data for any purpose other than
  operating the app. Google's handling of this infrastructure is governed by
  [Google's Privacy Policy](https://policies.google.com/privacy).
- **Google AI (Gemini).** To generate the daily tip, a short, non-identifying
  summary of your baby's age and care context is sent to Google's Gemini model.
  No EPDS scores or account identifiers are sent.

## 3. How we use your data

- To provide core functionality: tracking, charts, reminders, and the daily tip.
- To sync your data across your own devices and, optionally, with family members
  you invite.
- To generate the AI daily tip.

We do **not** use your data for advertising and we do **not** track you across
other apps or websites (`NSPrivacyTracking = false`). We do **not** share your
data with third parties other than the infrastructure providers named above.

## 4. Data retention and deletion

- Local data remains until you delete entries in the app or delete the app.
- Cloud data in Firebase is retained while your account is active.
- **Delete everything yourself, anytime.** Open **Settings → Data & Privacy →
  Delete all data**. This permanently erases your account and every record — on
  this device and in the cloud — including health and well-being data. The action
  cannot be undone, and the app returns to its first-launch state.
- You may also email us (below) to request deletion.

## 5. Children's data

Momsy is intended for use by parents and caregivers. Information about a child is
entered by the parent and processed solely to provide care-tracking features for
that family. The app is not directed at children.

## 6. Your choices

- Use the app with the default anonymous account to avoid linking your identity.
- Link or unlink a Sign in with Apple / Google account at any time.
- Delete individual entries, or erase all data and your account, from
  **Settings → Data & Privacy → Delete all data**.

## 7. Contact

Questions or deletion requests: **rusikabdulov@gmail.com**

We may update this policy; material changes will be reflected by a new effective
date above.
