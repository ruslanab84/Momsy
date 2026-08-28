# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Momsy — iOS SwiftUI app for baby care tracking (feeding, sleep, walks, baths, pumping, vitamins,
symptoms, stool), child profiles/development, family sharing via Firebase, and Premium via StoreKit 2.
Local-first: SwiftData is the source of truth; Firebase Cloud Sync is opt-in only (onboarding or
Settings). Without it, everything stays on-device. No ad SDKs, no Firebase Analytics. AI features
(Gemini/FirebaseAI) were deliberately removed for the App Store release (see git history around
`6acda0a4`) — do not reintroduce AI dependencies without explicit instruction.

## Commands

The `.xcodeproj` is at the repo root — always pass an absolute `-project` path or run from repo root
(NOT from inside `Momsy/`).

Build:
```bash
xcodebuild -project Momsy.xcodeproj -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Full test suite (Swift Testing, `@Test`/`#expect` — not XCTest):
```bash
xcodebuild -project Momsy.xcodeproj -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 17' test
```
- Use simulator `iPhone 17` (this machine has no `iPhone 16`).
- Full suite takes ~7-8 min and is memory-heavy — run it backgrounded/redirected to a log file, not
  through the harness's truncated task-output capture. Exit code 0 does not guarantee tests ran —
  confirm real `✔`/`✘` Swift Testing markers and a non-zero executed-test count in the log.
- Known flake, not a regression signal: `MomsyTests/SleepViewModelTests/stopWaitsForPendingStartBeforeClosing`
  (timing race under full-suite contention) and `LogReportViewModelTests.dayModeAggregatesAllSourcesNewestFirst`
  (relative timestamps roll to the previous day near local midnight).
- New test files are NOT auto-discovered — register manually in `Momsy.xcodeproj/project.pbxproj`
  (PBXFileReference, PBXGroup children, PBXBuildFile, Sources build phase) or add via Xcode.
- Any `project.pbxproj`/`.xcscheme` edit: validate with `plutil -lint <path>` /
  `xmllint --noout <path>` before committing, and always verify with a real `xcodebuild` build.

Firebase rules/functions tests (Node, needs Firebase CLI + JDK 21+):
```bash
npm test                      # rules + functions
npm run test:firebase-rules   # tests/firebase-rules.test.mjs via firestore/storage emulators
npm run test:firebase-functions
```

## Architecture

Code is organized as `Core/`, `Features/`, `Services/`, `Resources/`. Within each feature:
`Data/` (repositories, DTOs) / `Domain/` (models, business logic) / `Presentation/` (`Views/` +
`ViewModel/`). Views only render state and forward user actions to ViewModels — no networking,
persistence, or business logic in Views. `AppContainer` (`Momsy/Core/DI`) is the single composition
root that wires production dependencies (repositories, sync services, `SubscriptionManager`, etc.);
it's also the place to look for how a feature is assembled end-to-end.

Feature areas under `Momsy/Features/`: Baby, Bath, CareTips, ComplementaryFeeding, Diary, Doctor,
Feeding, Leaps, LogReport, Me, MomMood, Onboarding, Pumping, Report, Settings, Sharing, Sleep, Sounds,
Subscription, Symptom, Today, Tracking, Vaccination, Vitamin, Walk, WeeklyInsights.

Shared subsystems under `Momsy/Core/`: Account, Auth, BabySync, DesignSystem, Domain, Extensions,
Family, Localization, Navigation, Persistence, Privacy, Units, WatchSync, Widget. Full screen-by-screen
map: `docs/VIEW_MAP.md`.

Navigation: `MomsyApp` → `MomsyRootView` (deep links, Cloud Sync consent, widget routes) →
`ContentView` (splash/onboarding/paywall/main) → `MainTabView` (Today, Leaps, Diary\*, Doctor\*, Me;
\*Diary/Doctor require a role with private-data access). `momsy://` URL scheme deep-links into Today's
quick-action sheets (sleep, feeding, walk, bath) via `onOpenURL` in `MomsyApp`.

Cloud sync: `Core/BabySync` + `Services/Firebase/BabySync` handle DTO mapping, Firestore log paths,
offline write/delete replay, watermarks, and cloud-to-local merge. `Core/Family` handles active-baby
selection, family setup/switching, invites, and membership revocation — family/child scope is enforced
both client-side and in `firestore.rules`.

SwiftData schema: `Momsy/Core/Persistence/AppPersistence.swift` has a `schemaVersion` string that must
be bumped whenever a new `@Model` class is added to the schema array.

Subscriptions: `SubscriptionManager` lives on `AppContainer` as a `let` (whole-process lifetime, not
recreated on account deletion/re-registration) and loads StoreKit products once at init via
`try? await loadProductsIfNeeded()`. Family Premium is determined by Momsy-family state in Firebase,
not Apple Family Sharing.

Localization: `Core/Localization/LocalizedText.swift` (`LocalizedText`/`LocalizedList`, English
fallback, per-language params: en/ru/de/es/fr/pt/zh) plus `L10n.swift`. 7 languages are supported;
translations for new content should cover all of them or explicitly fall back to English.

Firebase config: `firebase.json` (rules/emulators), `firestore.rules`, `firestore.indexes.json`,
`storage.rules`. Cloud Functions live in `functions/` (apns, baby-deletion-cleanup,
family-departure-cleanup, subscription-entitlement, live-activity). No `gh` CLI auth in this repo —
review changes via local `git diff`/`git log`, not `gh pr`.

## Git workflow

This repo pushes directly to `origin/main` — no PR workflow. Before committing: scope with
`git status`/`git diff --stat`, stage files by explicit name (not `-A`/`.`) to avoid sweeping in
`.derivedData/`/`__pycache__/` build artifacts, and get explicit user confirmation before `git push`
even when the request already said "commit and push."
