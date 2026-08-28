# Momsy Privacy Policy

**Effective date:** 28 August 2026

Momsy ("the app", "we", "us") helps parents and caregivers track a baby's care
and their own well-being. This policy explains what Momsy processes, when data
leaves your device, which service providers receive it, and the choices you
have. We do **not** sell data, serve ads, or track you across other companies'
apps or websites.

## 1. Information Momsy processes

| Category | Examples | On device | With optional cloud sync |
|---|---|:---:|:---:|
| Baby profile | Name, birth date, stage, gender | Yes | Google Cloud Firestore |
| Baby health and care | Feeding, sleep, diaper and stool, temperature, growth, vaccinations, symptoms, pumping, foods and reactions, doctor visits, bath and walk records | Yes | Google Cloud Firestore |
| Diary | Diary text and dates | Yes | Google Cloud Firestore |
| Caregiver records | Parent sleep and water intake | Yes | Google Cloud Firestore |
| Parent well-being | Mood, energy, and EPDS postpartum-depression screening score | Yes | No; these records remain local |
| Family sharing | Invite codes, family membership, member name and role | Limited local state | Google Cloud Firestore |
| Account | Anonymous Firebase user ID, or Apple/Google account ID, name, and email when provided by that sign-in service | Limited local state | Firebase Authentication |
| Subscription | Signed StoreKit transaction and entitlement status | Yes | Firebase Cloud Function for verification; verified entitlement fields in Google Cloud Firestore |

Momsy has no diary-photo feature and does not include or use Firebase Storage.
The daily tip shown in Today uses built-in local content. Momsy does not send
data to Gemini or another generative-AI service.

## 2. Optional Firebase cloud sync

Cloud sync is off until you choose whether to allow it during onboarding. If
you allow it:

- Momsy initializes a private Firebase identity. If you skip Apple or Google
  sign-in, Firebase Authentication creates an anonymous account identifier.
- The cloud-enabled categories in the table above are sent to Google Cloud
  Firestore so they can be backed up, restored on your devices, and shared with
  family members you invite.
- Firebase App Check sends app/device attestation material and short-lived
  tokens to verify that requests come from the genuine app.
- When a subscription is purchased, restored, or renewed for a cloud-enabled
  family, Momsy sends Apple's signed StoreKit transaction (JWS) to a Momsy
  Firebase Cloud Function. The function verifies the signature and account
  binding, then stores the subscription product, original transaction ID,
  expiry/revocation status, and linked Firebase user/family. The signed JWS is
  used for verification and is not stored in Firestore.
- Firebase SDK requests may include service data such as device and OS type,
  app bundle/version, SDK version, and IP address.

You can turn cloud sync off in **Settings → Data & Privacy → Cloud sync**.
After you turn it off, Momsy stops new Firestore sync and live cloud updates.
Data already stored in Firebase remains there until you delete it through the
app or request deletion from us. Turning cloud sync off does not delete data.

Joining or using a shared family requires cloud sync because the shared family
workspace exists in Firestore.

## 3. No generative-AI processing

The current version of Momsy does not generate weekly reports with AI and does
not send baby-care, diary, well-being, account, or family data to Gemini or any
other generative-AI provider.

## 4. Service providers and SDKs

Momsy includes only the following third-party services that process app data:

- **Google Firebase:** Firebase Core, Authentication, Cloud Firestore, App
  Check. These provide authentication, optional cloud sync, and backend abuse
  protection.
- **Google Sign-In:** used only when you choose Google as an account provider.
- **Apple:** Sign in with Apple and StoreKit, used when you choose Apple
  sign-in or manage a subscription.

Momsy does not include Firebase Analytics, Firebase Realtime Database,
Firebase Storage, advertising SDKs, or third-party tracking SDKs.

Google's processing is governed by
[Google's Privacy Policy](https://policies.google.com/privacy) and applicable
Firebase service terms. Apple's processing is governed by [Apple's Privacy
Policy](https://www.apple.com/legal/privacy/).

## 5. How data is used

We use data only to:

- provide local tracking, charts, reminders, and daily tips;
- provide cloud backup, restore, and invited-family sync when you allow it;
- authenticate and protect private Firebase access;
- verify subscription access and share it with an invited family through
  StoreKit and Firebase.

We do not use data for advertising, data-broker sales, or cross-app tracking.

## 6. Retention and deletion

- Local records remain until you delete them, use **Delete all data**, or
  delete the app.
- Firebase data remains while the related account/family is active or until a
  deletion request completes.
- Open **Settings → Data & Privacy → Delete all data** to erase local data and
  request permanent deletion of your Firebase cloud footprint and Firebase
  Authentication account. Momsy reports completion only after the backend
  confirms the cloud footprint is gone and Firebase Auth deletion succeeds.
- Firebase may require a network connection or recent Apple/Google
  reauthentication. In that case, Momsy keeps the deletion request pending,
  blocks cloud restore for that account, prompts you to reauthenticate when
  needed, and retries before cloud sync on a later launch. Do not treat the
  account as deleted until Momsy confirms completion.
- In a shared family, records that belong to the shared workspace and are still
  needed by other family members may remain; Momsy removes your membership and
  account data. Contact us if you need help with shared-family deletion.
- Deleting a Momsy account does not cancel an Apple subscription. Subscriptions
  are managed separately in the App Store.

You may also email us to request or finish deletion.

## 7. Children's data

Momsy is intended for parents and caregivers, not children. Information about
a child is entered by an adult and processed only to provide the features
described in this policy. The adult is responsible for having authority to
enter and share that child's information.

## 8. Your choices

- Keep Momsy local-only by declining cloud sync.
- Enable or withdraw cloud-sync consent in Settings.
- Use an anonymous Firebase account after enabling sync, or link Apple/Google.
- Delete individual entries, all local/cloud data, and the account as described
  above.

## 9. Contact

Privacy questions and deletion requests:
**momsy.app.support@gmail.com**

We may update this policy. Material changes will be reflected by a new
effective date.
