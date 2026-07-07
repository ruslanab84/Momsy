# P1: Firebase App Check — protect the Gemini endpoint

**Why:** Gemini is called through `FirebaseAI.firebaseAI(backend: .googleAI())` (`GeminiWeeklyInsightService.swift:14`, `GeminiDailyTipService`). The Firebase config shipped in the bundle is extractable, so anyone can call the AI Logic endpoint on the project's quota — direct cost abuse, launch-blocking. App Check attests genuine app installs; with server-side enforcement, unattested callers are rejected. Firestore/Storage get the same attestation as a second layer above security rules.

**Verified current state (HEAD `e97976f`):**
- `firebase-ios-sdk` pinned at minimum **12.13.0** — App Check and AI Logic integration supported
- `FirebaseAppCheck` product **not** linked (pbxproj: 0 matches)
- Firebase is configured only in the main app: `MomsyApp.swift:45` → `FirebaseBootstrapper.configureIfAvailable()`. Widget and Watch targets never init Firebase → app target only
- Deployment target iOS 17.0 → `AppAttestProvider` unconditional, no DeviceCheck fallback needed
- Entitlements: `Momsy/Momsy.entitlements` (Debug), `Momsy/Momsy.Release.entitlements` (Release)

---

## Task 1 — Link FirebaseAppCheck to the Momsy target

`Momsy.xcodeproj/project.pbxproj` — mirror the existing FirebaseAuth entries. Generate two new 24-char uppercase hex IDs (`uuidgen | tr -d '-' | cut -c1-24`), below `<ID_A>` (build file) and `<ID_B>` (product ref). Package reference already exists: `B7318F472FBCEA96003CCB0B /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */`.

Four insertions, each next to its FirebaseAuth counterpart:

1. **PBXBuildFile section** (near line 68):
```
		<ID_A> /* FirebaseAppCheck in Frameworks */ = {isa = PBXBuildFile; productRef = <ID_B> /* FirebaseAppCheck */; };
```
2. **Frameworks build phase** of the Momsy target (near line 307):
```
				<ID_A> /* FirebaseAppCheck in Frameworks */,
```
3. **`packageProductDependencies`** of the Momsy target (near line 827):
```
				<ID_B> /* FirebaseAppCheck */,
```
4. **XCSwiftPackageProductDependency section** (near line 1435):
```
		<ID_B> /* FirebaseAppCheck */ = {
			isa = XCSwiftPackageProductDependency;
			package = B7318F472FBCEA96003CCB0B /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */;
			productName = FirebaseAppCheck;
		};
```

Fallback if pbxproj editing misbehaves: Xcode → target Momsy → General → Frameworks → `+` → FirebaseAppCheck.

---

## Task 2 — Provider factory

**New file:** `Momsy/Services/Firebase/AppCheckProviderFactory.swift`
```swift
import FirebaseAppCheck
import FirebaseCore

final class MomsyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if DEBUG
        // App Attest requires a physical device; simulator/dev builds use the debug provider.
        return AppCheckDebugProvider(app: app)
        #else
        return AppAttestProvider(app: app)
        #endif
    }
}
```
TestFlight/App Store builds compile Release → App Attest.

---

## Task 3 — Register the factory before `FirebaseApp.configure`

**File:** `Momsy/Services/Firebase/FirebaseBootstrapper.swift`

Add `import FirebaseAppCheck` to the imports.

**Current:**
```swift
        FirebaseApp.configure(options: options)
        configureFirestoreCache()
        return true
```

**Replace with:**
```swift
        AppCheck.setAppCheckProviderFactory(MomsyAppCheckProviderFactory())
        FirebaseApp.configure(options: options)
        configureFirestoreCache()
        return true
```

Order is mandatory: the factory must be registered **before** `configure`, otherwise Firebase SDKs initialize without App Check and never attach tokens. Both Gemini services are covered automatically after this — the FirebaseAI SDK attaches tokens itself; no changes in `GeminiWeeklyInsightService` / `GeminiDailyTipService`.

---

## Task 4 — App Attest entitlement

Add to both files:

`Momsy/Momsy.entitlements`:
```xml
	<key>com.apple.developer.devicecheck.appattest-environment</key>
	<string>development</string>
```

`Momsy/Momsy.Release.entitlements`:
```xml
	<key>com.apple.developer.devicecheck.appattest-environment</key>
	<string>production</string>
```

The App ID needs the App Attest capability; with automatic signing Xcode regenerates the provisioning profile on next build.

---

## Task 5 — Firebase console (manual, not CLI)

1. App Check → Apps → register the iOS app with the **App Attest** provider (default 1h token TTL is fine).
2. Run a Debug build once, copy the token from the Xcode console (`App Check debug token: ...`), add it under **Manage debug tokens**. For CI, pin via the `FIRAAppCheckDebugToken` environment variable.
3. Enforcement:
   - **Firebase AI Logic → Enforce** immediately (pre-launch, no legacy clients to break).
   - **Firestore and Storage → Monitor** first; flip to Enforce once metrics show ~100% verified traffic during QA.

---

## Notes

- The `configureIfAvailable` guard paths (missing/invalid plist) return before the new line — factory registration only happens when Firebase actually configures.
- Unit tests never init Firebase (pure Swift Testing) — unaffected.
- Optional follow-up, not in scope: limited-use App Check tokens for AI Logic (replay protection). Verify API availability in the pinned SDK version before adopting.

## Definition of Done

- [ ] FirebaseAppCheck linked to the Momsy target; Debug and Release build
- [ ] Factory registered before `FirebaseApp.configure`; `import FirebaseAppCheck` added
- [ ] Entitlements: `appattest-environment` = `development` (Debug) / `production` (Release)
- [ ] Console: App Attest provider registered, debug token added
- [ ] Enforcement ON for Firebase AI Logic; Firestore/Storage in Monitor
- [ ] Daily tip and weekly insight generate on a Debug simulator build AND a Release physical-device build
- [ ] App Check metrics show verified AI Logic requests

## Manual QA

1. **Enforcement negative check:** enable AI Logic enforcement, run Debug on simulator with the debug token NOT yet registered → daily tip generation must fail with a permission error. Register the token → retry → success.
2. **App Attest path:** physical device, Release configuration → generate daily tip + weekly insight → success.
3. Console → App Check metrics: AI Logic traffic shows as verified.
4. **Regression:** two-simulator Firestore sync (family scenarios) unaffected — Firestore stays in Monitor mode.
