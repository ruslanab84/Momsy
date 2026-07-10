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
- **AI**: Gemini (on-device fallback aware, iOS 17+)
- **Companion surfaces**: WidgetKit widgets, Live Activities (`Core/Widget/*ActivityAttributes.swift`), Apple Watch connectivity (`Core/WatchSync`) — note the `MomsyWatch`/`MomsyWatchWidget` source directories exist on disk but are **not currently wired into `Momsy.xcodeproj`** as build targets
- **Localization**: 7 languages (en, ru, de, es, fr, pt, zh) via a custom `L10n`/`LocalizationManager` system (see below), not `.lproj`/`String Catalog` bundles

## Common Commands

Build and test via `xcodebuild` (no CocoaPods/fastlane; dependencies are Swift Package Manager, resolved in `Momsy.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/`):

```bash
# Build the app for a simulator
xcodebuild -project Momsy.xcodeproj -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run the full unit test suite
xcodebuild -project Momsy.xcodeproj -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test class or method
xcodebuild -project Momsy.xcodeproj -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' \
  test -only-testing:MomsyTests/SleepViewModelTests
xcodebuild -project Momsy.xcodeproj -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' \
  test -only-testing:MomsyTests/SleepViewModelTests/testStartSleepCreatesOpenEntry
```

Targets: `Momsy` (app), `MomsyTests` (unit tests, Swift Testing framework), `MomsyWidget` (widget extension).

A `GoogleService-Info.plist` is required at `Momsy/Momsy/GoogleService-Info.plist` (never committed — see `.template` file); without it, `FirebaseBootstrapper.isConfigured` is `false` and `AppContainer` falls back to local-only (`No-Op`/`Local*`) repository implementations, so the app still builds and runs without cloud sync.

## Architecture

### Dependency injection

`Core/DI/AppContainer.swift` is the single composition root — a `@MainActor` class with `lazy var` properties wiring every repository/service. It branches on `FirebaseBootstrapper.isConfigured` to choose between Firestore-backed and local/no-op implementations of the same protocol, so features never import Firebase directly. `AppContainer.makeProduction()` is called once from `MomsyApp.init()`; `AppState` holds cross-cutting app state (active baby, family, etc.).

### Feature modules (`Momsy/Features/<Name>/`)

Each feature (Sleep, Feeding, Diary, Bath, Walk, Pumping, Vaccination, WeeklyInsights, Sharing, Onboarding, ...) follows the same internal layering:

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

`Services/Firebase/BabySync/` implements sync between a child's local SwiftData store and Firestore for co-parent sharing:
- `BabySyncService` / `BabySyncRepository` push local writes; `CloudSyncDownloader` pulls and merges remote changes per-entity.
- `SyncWatermarkStore` tracks last-synced timestamps per collection so re-sync/family-switch only pulls deltas.
- `PendingWritesStore` and `PendingDeletionsStore` queue writes/deletes made while offline for later replay (tombstone-based deletion, not hard deletes).
- `SleepLiveSyncService` streams open sleep sessions in near-real-time across devices; `SleepSessionOwnership`/`DuplicateOpenSessionPolicy` (in `Features/Sleep/Domain/Services/`) resolve races when both co-parents start/stop a session concurrently.
- `Core/Family/FamilyManager` + `ActiveBaby` + `FamilySwitchPolicy` govern which family/child scope is active and purge/reset sync state on switch.

When touching sync code, check both the Firestore write path (`*SyncRepository`) and the download/merge path (`CloudSyncDownloader`) — the two must stay symmetric (e.g. deletion filtering, watermark advancement) or entries reappear/duplicate across devices.

### Localization

`Core/Localization/L10n.swift` (~1500 lines) defines every string as a computed property calling a private `s(en:ru:de:es:fr:pt:zh:)` helper — all 7 translations live inline per string, not in separate `.lproj` files. `LocalizationManager` (an `ObservableObject` injected via `.environmentObject`) holds the current `Language` and drives re-render on switch; `Language.swift` defines the enum (display name, flag, locale identifier) for the 7 supported languages.

### Other Core/ areas

- `Core/Auth` — `AuthManager` (Firebase Auth + Google Sign-In + Apple)
- `Core/Account` — account deletion / GDPR erasure flow
- `Core/AI` — Gemini request retry/safety wrappers
- `Core/Units` — metric/imperial unit system
- `Core/Widget` — Live Activity attributes/managers per activity type (feeding, sleep, walk, bath, pumping)
- `Core/WatchSync` — `PhoneSessionManager`/`QuickLogCoordinator` for `WatchConnectivity` messaging to the (currently unbuilt) watch target
- `Core/Persistence` — `AppPersistence` (SwiftData container bootstrap with recovery-on-corruption), `UserDefaultsMigration`

## Testing

`MomsyTests/` mirrors the `Core/`/`Features/`/`Services/` source tree using the **Swift Testing** framework (not XCTest). Business logic — use cases, domain services/policies, ViewModels — is unit tested; there is no XCUITest target currently in the project.

## Code Style

- PascalCase for types and structs, camelCase for properties and methods
- `@State private var` for local SwiftUI state
- `let` for constants
- 4-space indentation
- Avoid Combine — use Swift `async`/`await` instead
- Avoid force unwrapping (`!`)
- No comments unless the WHY is non-obvious
