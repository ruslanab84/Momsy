# Apple Watch Companion — Xcode Setup

All Swift source for the Watch app is already written. Because creating new
build targets cannot be done safely by editing `project.pbxproj`, the steps below
must be performed once in Xcode. After that, the synchronized folder groups pick
up the staged source files automatically.

## What's already done (compiles & builds today)

iPhone side, in the existing `Momsy` target (verified with `xcodebuild ... BUILD SUCCEEDED`):

- `Momsy/Core/WatchSync/WatchMessage.swift` — shared command/state protocol
- `Momsy/Core/WatchSync/QuickLogCoordinator.swift` — runs feeding/sleep/diaper through existing use cases
- `Momsy/Core/WatchSync/PhoneSessionManager.swift` — `WCSession` receiver + state pusher
- `Momsy/MomsyApp.swift` — constructs & activates the session
- `Momsy/Core/Widget/WidgetDataStore.swift` — posts `.widgetDataDidChange` on every change

Staged watch sources (not yet in any target):

- `MomsyWatch/` — `MomsyWatchApp`, `WatchSessionManager`, `WatchDataStore`, `WatchStrings`, `Views/*`
- `MomsyWatchWidget/MomsyWatchWidget.swift` — complications

## Step 1 — Create the watchOS App target

`File ▸ New ▸ Target… ▸ watchOS ▸ App`

- Product Name: **MomsyWatch**
- Bundle Identifier: `RuslanAbd.Momsy.watchkitapp`
- Interface: SwiftUI, Language: Swift
- "Embed in Companion Application": **Momsy**
- When prompted, **do not** let Xcode add its own `App`/`ContentView` files, or delete the generated `MomsyWatchApp.swift`/`ContentView.swift` afterward (we already have `MomsyWatch/MomsyWatchApp.swift`).

Point the target's synchronized group at the existing `MomsyWatch/` folder (drag the
folder into the target if Xcode created a different one), so all staged files are included.

## Step 2 — Create the complications widget target

`File ▸ New ▸ Target… ▸ watchOS ▸ Widget Extension`

- Product Name: **MomsyWatchWidget**
- Bundle Identifier: `RuslanAbd.Momsy.watchkitapp.widget`
- Embed in: **MomsyWatch**
- Delete the auto-generated widget file; use the staged `MomsyWatchWidget/MomsyWatchWidget.swift`.

## Step 3 — App Group (watch-local)

Add capability **App Groups** to **both** MomsyWatch and MomsyWatchWidget:

- Group: `group.RuslanAbd.Momsy.watch`

(This is separate from the iOS `group.RuslanAbd.Momsy`; app groups do not cross
devices, so the watch needs its own.)

## Step 4 — Shared-file target membership

In the File Inspector (right panel), set **Target Membership** for these shared files:

| File | Momsy | MomsyWatch | MomsyWatchWidget |
|------|:----:|:----------:|:----------------:|
| `Momsy/Core/WatchSync/WatchMessage.swift` | ✅ (already) | ✅ add | ✅ add |
| `MomsyWatch/WatchDataStore.swift` | — | ✅ (auto) | ✅ add |

`WatchMessage.swift` and `WatchDataStore.swift` are the only files shared across
targets; everything else belongs to exactly one target.

## Step 5 — Build & run

1. Select the **MomsyWatch** scheme + a paired iPhone/Watch simulator pair, build.
2. Run the `Momsy` iOS app on the iPhone sim so `PhoneSessionManager` is live.

## Verification (per the plan)

- Start feeding (Left) on the Watch → timer runs on Watch; iPhone Live Activity +
  `WidgetDataStore` engage; the phone Feeding screen shows the running session.
- Stop on the Watch → a feeding entry is persisted with correct duration/side;
  success haptic fires; Firestore receives it (existing path).
- Repeat for sleep (with quality) and diaper (+1 on both devices).
- **Offline:** put the iPhone sim in Airplane mode, log a diaper + feeding on the
  Watch, re-enable → queued `transferUserInfo` delivers; no duplicates (UUID dedup).
- Add each complication to a watch face and confirm: time-since-last-feeding,
  active-timer, diapers-today, and the launch shortcut.
