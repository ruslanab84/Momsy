# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Role

You are a Senior iOS Engineer and Mobile Architect.

Your responsibilities:
- Build scalable and production-ready iOS applications
- Follow Clean Architecture principles
- Separate UI, business logic, networking, and data layers
- Write clean, maintainable, testable Swift code
- Use modern Apple technologies and best practices
- Think like a staff-level engineer during implementation

---

# Core Architecture Rules

## 1. Strict Separation of Concerns

UI must NEVER contain:
- networking logic
- business logic
- parsing
- database logic
- API calls

Views should only:
- render state
- send user actions
- observe ViewModels

---

## 2. Preferred Architecture

Use MVVM + Clean Architecture, following the layering already established per feature (see Architecture below):

```text
Presentation/   # SwiftUI Views + ViewModel
Domain/         # Models, Repository protocols, UseCases, business policies
Data/           # Repository implementations, persistence, external services
```

---

## Project Overview

Momsy is an AI-powered baby care assistant for iOS, built with SwiftUI, SwiftData, and Firebase. It tracks sleep, feeding, diapers, growth, vaccinations, and more for one or more children, syncs across co-parent devices in real time via Firestore, and supports 7 languages.

## Tech Stack

- **Language**: Swift, SwiftUI
- **Local persistence**: SwiftData (per-entity repositories)
- **Cloud sync**: Firebase (Firestore, Auth, Storage, App Check, Analytics), Google Sign-In
- **AI**: Gemini (on-device fallback aware, iOS 17+) — the Weekly Insight AI-report flow (`generateWeeklyInsight`, `WeeklyInsightAIConsent`) is currently commented out in `MomsyApp.swift` ("temporarily disabled for the App Store release"); don't take the dead-looking code as a sign it should be deleted
- **Subscriptions**: StoreKit 2 via `Features/Subscription/` (`SubscriptionManager`, `PremiumAccessPolicy`, family-wide entitlement sync through `FamilyPremiumService`/`SubscriptionSyncQueue`); local product testing uses `Momsy.storekit`, wired into the `Momsy` scheme's run configuration (not the app bundle)
- **Companion surfaces**: WidgetKit widgets, Live Activities (`Core/Widget/*ActivityAttributes.swift`), Apple Watch connectivity (`Core/WatchSync`) — note the `MomsyWatch`/`MomsyWatchWidget` source directories exist on disk but are **not currently wired into `Momsy.xcodeproj`** as build targets; adding the target can't be scripted via `project.pbxproj` edits and requires the one-time manual Xcode setup in `docs/AppleWatch-Setup.md`
- **Localization**: 7 languages (en, ru, de, es, fr, pt, zh) via a custom `L10n`/`LocalizationManager` system (see below), not `.lproj`/`String Catalog` bundles
- **Deployment target**: iOS 17.0

## Common Commands

Build and test via `xcodebuild` (no CocoaPods/fastlane; dependencies are Swift Package Manager, resolved in `Momsy.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/`):

```bash
# Build the app for a simulator
xcodebuild -project Momsy.xcodeproj -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run the full unit test suite (~580 @Test cases, several minutes)
xcodebuild -project Momsy.xcodeproj -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 17' test

# Run a single test suite or method (use the Swift type name, not the @Suite("Display Name") string)
xcodebuild -project Momsy.xcodeproj -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 17' \
  test -only-testing:MomsyTests/SleepViewModelTests
xcodebuild -project Momsy.xcodeproj -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 17' \
  test -only-testing:MomsyTests/SleepViewModelTests/testStartSleepCreatesOpenEntry
```

Pick whatever simulator is actually installed (`xcrun simctl list devices available`) — the exact model varies by machine/Xcode version.

Targets: `Momsy` (app), `MomsyTests` (unit tests, Swift Testing framework), `MomsyWidget` (widget extension).

A `GoogleService-Info.plist` is required at `Momsy/GoogleService-Info.plist` (never committed — see the sibling `.template` file); without it, `FirebaseBootstrapper.isConfigured` is `false` and `AppContainer` falls back to local-only (`No-Op`/`Local*`) repository implementations, so the app still builds and runs without cloud sync.

### Firebase (rules + Cloud Functions) tests

```bash
npm run test:firebase-rules      # firebase emulators:exec --only firestore,storage + node --test tests/firebase-rules.test.mjs
npm run test:firebase-functions  # firebase emulators:exec --only firestore,functions + npm test --prefix functions
npm test                         # both of the above
```

Requires JDK 21+ on `JAVA_HOME` (the emulator fails fast on an older default JVM). `firestore.rules` / `storage.rules` changes should be verified here before deploy. `functions/` (Node 22, `firebase-functions` + `firebase-admin`) holds the App Store Server Notifications webhook, APNs push, and family/baby deletion-cleanup Cloud Functions — its own tests live in `functions/test/*.test.js`.

`npm run firebase:release-gate` (asserts the `.firebaserc` default project is `momsy-cf74a`, then runs `npm test`) is what CI runs on every PR and push to `main` via `.github/workflows/firebase-release-gate.yml` — it does not touch the iOS app, only Firestore/Storage rules and Cloud Functions.

## Architecture

### Dependency injection

`Core/DI/AppContainer.swift` is the single composition root — a `@MainActor` class with `lazy var` properties wiring every repository/service. It branches on `FirebaseBootstrapper.isConfigured` to choose between Firestore-backed and local/no-op implementations of the same protocol, so features never import Firebase directly. `AppContainer.makeProduction()` is called once from `MomsyApp.init()`; `AppState` holds cross-cutting app state (active baby, family, etc.).

### Feature modules (`Momsy/Features/<Name>/`)

Each feature (Sleep, Feeding, Diary, Bath, Walk, Pumping, Vaccination, WeeklyInsights, Sharing, Subscription, Onboarding, ...) follows the same internal layering:

```
Data/Persistence/      SwiftData model (e.g. SleepRecord)
Data/Repositories/      SwiftData + Local repository implementations
Domain/Models/          Plain domain types (e.g. SleepEntry)
Domain/Repositories/    Repository protocol
Domain/Services/        Pure business policies (e.g. DuplicateOpenSessionPolicy, SleepForecastEngine)
Domain/UseCases/        One type per use case (StartSleepUseCase, StopSleepUseCase, ...)
Presentation/ViewModel/ @Observable/ObservableObject, talks only to UseCases/Repositories
Presentation/Views/     SwiftUI views, no business logic
```
Use `Features/Sleep` as the reference implementation when adding a new feature or module.

### Offline-first cloud sync

`Services/Firebase/BabySync/` implements sync between a child's local SwiftData store and Firestore for co-parent sharing; the corresponding plain domain log types (`SleepLog`, `FeedingLog`, `DiaperLog`, ...) live in `Core/BabySync/Domain/Models/`, each paired with a Firestore `+DTO.swift` mapper under `Services/Firebase/BabySync/Models/`:
- `BabySyncService` / `BabySyncRepository` push local writes; `CloudSyncDownloader` pulls and merges remote changes per-entity.
- `SyncWatermarkStore` tracks last-synced timestamps per collection so re-sync/family-switch only pulls deltas.
- `PendingWritesStore` and `PendingDeletionsStore` queue writes/deletes made while offline for later replay (tombstone-based deletion, not hard deletes).
- `SleepLiveSyncService` streams open sleep sessions in near-real-time across devices; `SleepSessionOwnership`/`DuplicateOpenSessionPolicy` (in `Features/Sleep/Domain/Services/`) resolve races when both co-parents start/stop a session concurrently.
- `Core/Family/FamilyManager` + `ActiveBaby` + `FamilySwitchPolicy` govern which family/child scope is active and purge/reset sync state on switch.
- `Core/Privacy/CloudSyncConsent` gates all of the above: on launch, `MomsyApp`/`ContentView` only calls into cloud services (anonymous sign-in, `cloudSyncDownloader`, `sleepLiveSync`) once the user has explicitly granted sync consent; declining keeps the app on the local/no-op repositories from `AppContainer` even when Firebase is configured.

When touching sync code, check both the Firestore write path (`*SyncRepository`) and the download/merge path (`CloudSyncDownloader`) — the two must stay symmetric (e.g. deletion filtering, watermark advancement) or entries reappear/duplicate across devices.

### Localization

`Core/Localization/L10n.swift` (~1500 lines) defines every string as a computed property calling a private `s(en:ru:de:es:fr:pt:zh:)` helper — all 7 translations live inline per string, not in separate `.lproj` files. `LocalizationManager` (an `ObservableObject` injected via `.environmentObject`) holds the current `Language` and drives re-render on switch; `Language.swift` defines the enum (display name, flag, locale identifier) for the 7 supported languages.

### Other Core/ areas

- `Core/Auth` — `AuthManager` (Firebase Auth + Google Sign-In + Apple)
- `Core/Account` — account deletion / GDPR erasure flow
- `Core/AI` — Gemini request retry/safety wrappers
- `Core/Domain` — cross-feature domain types shared by multiple features' Domain layers (`LoadingState`, `RepositoryError`, `BabyAgeContext`/`BabyAgeStage`, `DevelopmentLeapSchedule`, `SyncMerge`, `StaleSessionReconciler`) — put a type here only once two or more features need it, otherwise it belongs in the owning feature's own `Domain/`
- `Core/Units` — metric/imperial unit system
- `Core/Widget` — Live Activity attributes/managers per activity type (feeding, sleep, walk, bath, pumping)
- `Core/WatchSync` — `PhoneSessionManager`/`QuickLogCoordinator` for `WatchConnectivity` messaging to the (currently unbuilt) watch target
- `Core/Persistence` — `AppPersistence` (SwiftData container bootstrap with recovery-on-corruption; bump its private `schemaVersion` string whenever a new `@Model` class is added to the schema array), `UserDefaultsMigration`
- `Core/Privacy` — `CloudSyncConsent` (see Offline-first cloud sync above)
- `Core/Navigation` — `MainTabView`, the app's root tab bar

## Testing

`MomsyTests/` mirrors the `Core/`/`Features/`/`Services/` source tree using the **Swift Testing** framework (not XCTest). Business logic — use cases, domain services/policies, ViewModels — is unit tested; there is no XCUITest target currently in the project.

The `Momsy` app target auto-discovers new files via a `PBXFileSystemSynchronizedRootGroup`, but `MomsyTests` does not — a new test file needs manual registration in `project.pbxproj` (`PBXBuildFile` + `PBXFileReference` entries, the group's children list, and the Sources build phase) or `xcodebuild` silently reports 0 tests from it. Mirror an existing sibling test file's four entries and run `plutil -lint` after hand-editing. When filtering with `-only-testing`, use the Swift type name (e.g. `InviteCodeFormatTests`), not the `@Suite("Display Name")` string — a non-matching filter still reports `TEST SUCCEEDED` with 0 tests run.

`SleepViewModelTests.stopClosesAnOptimisticStartAfterThePendingAddCompletes` is a known pre-existing flake under full-suite/simulator contention (a real ~200ms delay racing a mocked clock) — it passes reliably in isolation; don't treat a full-suite-only failure there as a regression without re-running it standalone first.

## Code Style

- PascalCase for types and structs, camelCase for properties and methods
- `@State private var` for local SwiftUI state
- `let` for constants
- 4-space indentation
- Avoid Combine — use Swift `async`/`await` instead
- Avoid force unwrapping (`!`)
- No comments unless the WHY is non-obvious
