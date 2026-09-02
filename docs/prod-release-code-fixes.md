# Pre-Release Code Fixes

**Anchor commit:** `a1aefca18d1aaf026bb58435c42dda6fe8edfc22` (`main`, 2026-08-28)
**Scope:** code-side blockers before App Store submission. Firebase Console / GCP configuration is out of scope for this document.

Before starting, verify the working tree matches the anchor:

```bash
git rev-parse HEAD
# expect: a1aefca18d1aaf026bb58435c42dda6fe8edfc22
git status --porcelain
# expect: empty
```

If `HEAD` differs, re-verify every line number below with `grep -n` before editing. All edits are anchored on string content, not line numbers — line numbers are informational only.

---

## T1 — Declare the seven implemented languages in the bundle (P0)

**Problem.** `Momsy.xcodeproj/project.pbxproj:971` declares `knownRegions = (en, Base)` and the app bundle carries no `CFBundleLocalizations`. Strings are resolved at runtime from `Momsy/Core/Localization/L10n.swift`, so in-app copy is translated regardless — but the *bundle* claims English only. Two consequences:

1. App Store lists the app as English-only in all storefronts.
2. `Locale.current` resolves to `en` on every device, because the system intersects the user's preferred languages with the bundle's declared localizations. Two formatters depend on it:
   - `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift:633` — `fmt.locale = Locale.current`
   - `Momsy/Features/Tracking/Data/Persistence/MeasurementRecord.swift:47` — `fmt.locale = Locale.current`

   A Russian-language user sees English month names in those two paths today.

**File:** `Momsy/Info.plist`
`GENERATE_INFOPLIST_FILE = YES` and `INFOPLIST_FILE = Momsy/Info.plist` (`project.pbxproj:1428-1429`), so this file is merged into the generated plist — the key belongs here, not in build settings.

Locale codes are taken from `Momsy/Core/Localization/Language.swift:37-47` (`localeIdentifier`): `pt` → `pt_PT`, `zh` → `zh_CN`.

### BEFORE

```xml
<plist version="1.0">
<dict>
	<key>ITSAppUsesNonExemptEncryption</key>
	<false/>
	<key>UIBackgroundModes</key>
```

### AFTER

```xml
<plist version="1.0">
<dict>
	<key>CFBundleLocalizations</key>
	<array>
		<string>en</string>
		<string>ru</string>
		<string>de</string>
		<string>es</string>
		<string>fr</string>
		<string>pt-PT</string>
		<string>zh-Hans</string>
	</array>
	<key>ITSAppUsesNonExemptEncryption</key>
	<false/>
	<key>UIBackgroundModes</key>
```

### T1b — `knownRegions` (cosmetic, optional)

Xcode project metadata only; it does not affect the built bundle, but leaving it at `en, Base` will keep confusing future audits. Apply with an anchored Python edit — never `sed` on `project.pbxproj`.

```bash
python3 - <<'EOF'
import pathlib
p = pathlib.Path("Momsy.xcodeproj/project.pbxproj")
s = p.read_text()
before = "\t\t\tknownRegions = (\n\t\t\t\ten,\n\t\t\t\tBase,\n\t\t\t);"
after = ("\t\t\tknownRegions = (\n\t\t\t\ten,\n\t\t\t\tBase,\n\t\t\t\tru,\n\t\t\t\tde,\n"
         "\t\t\t\tes,\n\t\t\t\tfr,\n\t\t\t\t\"pt-PT\",\n\t\t\t\t\"zh-Hans\",\n\t\t\t);")
assert s.count(before) == 1, s.count(before)
p.write_text(s.replace(before, after))
EOF
```

### Definition of Done

```bash
plutil -lint Momsy/Info.plist
/usr/libexec/PlistBuddy -c "Print :CFBundleLocalizations" Momsy/Info.plist | grep -c '^ ' 
# expect: 7
grep -c "zh-Hans" Momsy/Info.plist
# expect: 1
```

### Acceptance criteria

- Built `.app` contains `CFBundleLocalizations` with seven entries (`plutil -p "$APP/Info.plist" | grep -A9 CFBundleLocalizations`).
- On a device with system language Russian, `Locale.current.identifier` inside the app starts with `ru`.

### Open question

`pt-PT` vs `pt-BR` and `zh-Hans` vs `zh-Hant` must match the App Store Connect storefront localizations. If Brazil is a target market, `pt-BR` should be declared instead of (or in addition to) `pt-PT`, and `Language.localeIdentifier` updated in step.

---

## T2 — Bind the widget version to `MARKETING_VERSION` (P1)

**Problem.** `MomsyWidget/Info.plist:19-20` hardcodes `CFBundleShortVersionString = 1.0`, while the widget target sets `MARKETING_VERSION = 1` (`project.pbxproj:1243`, `1279`) — inert, because `GENERATE_INFOPLIST_FILE = NO` for that target (`project.pbxproj:1235`, `1271`). The values coincide today (`1.0` vs the app's `1.0`), so submission passes. The first bump to `1.0.1` silently diverges and App Store Connect rejects the build for an extension/app version mismatch.

`CFBundleVersion` is already correct — it interpolates `$(CURRENT_PROJECT_VERSION)`, which is `37` in all four configurations.

**File:** `MomsyWidget/Info.plist`

### BEFORE

```xml
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
```

### AFTER

```xml
	<key>CFBundleShortVersionString</key>
	<string>$(MARKETING_VERSION)</string>
```

**File:** `Momsy.xcodeproj/project.pbxproj` — align the widget's `MARKETING_VERSION` with the app's.

```bash
python3 - <<'EOF'
import pathlib
p = pathlib.Path("Momsy.xcodeproj/project.pbxproj")
s = p.read_text()
assert s.count("MARKETING_VERSION = 1;") == 2, s.count("MARKETING_VERSION = 1;")
p.write_text(s.replace("MARKETING_VERSION = 1;", "MARKETING_VERSION = 1.0;"))
EOF
```

### Definition of Done

```bash
grep -c '\$(MARKETING_VERSION)' MomsyWidget/Info.plist
# expect: 1
grep -c "MARKETING_VERSION = 1;" Momsy.xcodeproj/project.pbxproj
# expect: 0
grep -o "MARKETING_VERSION = [^;]*" Momsy.xcodeproj/project.pbxproj | sort | uniq -c
# expect: 4 MARKETING_VERSION = 1.0
plutil -lint MomsyWidget/Info.plist
```

### Acceptance criteria

- After bumping the app target to `1.0.1` locally, the built widget's `Info.plist` reports `1.0.1`. Revert the bump afterwards.

---

## T3 — Fail loudly when Firebase configuration is absent (P1)

**Problem.** `Momsy/Services/Firebase/FirebaseBootstrapper.swift:20-28` returns `false` with a `warning`/`error`-level log when `GoogleService-Info.plist` is missing or unparseable. `Momsy/Core/DI/AppContainer.swift:44-58` then substitutes `LocalFamilyRepository`, `LocalInviteService` and `NoOpCloudSyncDownloader`. The app launches and looks healthy, but co-parent sync, invites and subscription entitlement are all dead — with no user-visible signal and no crash report.

The fix keeps the graceful fallback for the offline-first paths but makes the misconfiguration impossible to miss: a trap in debug/TestFlight-internal builds, and a `fault`-level entry that surfaces in Console and sysdiagnose in release.

**File:** `Momsy/Services/Firebase/FirebaseBootstrapper.swift`

### BEFORE

```swift
        guard let path = googleServiceInfoPath(in: bundle) else {
            log.warning("Skipping Firebase configuration: GoogleService-Info.plist is missing from the app bundle.")
            return false
        }

        guard let options = FirebaseOptions(contentsOfFile: path) else {
            log.error("Skipping Firebase configuration: GoogleService-Info.plist could not be loaded.")
            return false
        }
```

### AFTER

```swift
        guard let path = googleServiceInfoPath(in: bundle) else {
            log.fault("Firebase configuration aborted: GoogleService-Info.plist is missing from the app bundle. Cloud sync, invites and subscription entitlement are disabled for this install.")
            assertionFailure("GoogleService-Info.plist is missing from the app bundle.")
            return false
        }

        guard let options = FirebaseOptions(contentsOfFile: path) else {
            log.fault("Firebase configuration aborted: GoogleService-Info.plist could not be parsed. Cloud sync, invites and subscription entitlement are disabled for this install.")
            assertionFailure("GoogleService-Info.plist could not be parsed.")
            return false
        }
```

`MomsyTests/Services/Firebase/FirebaseBootstrapperTests.swift` exercises `googleServiceInfoPath(in:)` only and never calls `configureIfAvailable`, so `assertionFailure` will not fire during the test run. No test changes required for this task.

### Definition of Done

```bash
grep -c "assertionFailure" Momsy/Services/Firebase/FirebaseBootstrapper.swift
# expect: 2
grep -c "log.fault" Momsy/Services/Firebase/FirebaseBootstrapper.swift
# expect: 2
grep -c "log.warning\|log.error" Momsy/Services/Firebase/FirebaseBootstrapper.swift
# expect: 0
```

### Acceptance criteria

- Temporarily remove `GoogleService-Info.plist` from the app target's Copy Bundle Resources phase, run a Debug build → the app traps at launch with the assertion message. Restore the resource afterwards.
- With the plist present, launch is unchanged and `FirebaseBootstrapper.isConfigured` is `true`.

### Deliberately out of scope

A blocking error screen in release would require seven new `L10n` keys and a new view. Given that this failure mode only occurs on a broken build configuration — never on a correctly archived one — the `fault` log plus the debug trap is the proportionate fix. Revisit only if a misconfigured build ever reaches TestFlight.

---

## T4 — Correct the App Attest environment in debug entitlements (P1)

**Problem.** `Momsy/Momsy.entitlements:13-16` sets `appattest-environment` to `production` while `aps-environment` is `development`. On a development-signed build running on a physical device, App Attest attestation is issued against the development environment and will be rejected when the entitlement claims production. `Momsy/Momsy.Release.entitlements` is already correct (`production` / `production`) and must not be touched.

**File:** `Momsy/Momsy.entitlements`

### BEFORE

```xml
    <key>com.apple.developer.devicecheck.appattest-environment</key>
    <string>production</string>
    <key>aps-environment</key>
    <string>development</string>
```

### AFTER

```xml
    <key>com.apple.developer.devicecheck.appattest-environment</key>
    <string>development</string>
    <key>aps-environment</key>
    <string>development</string>
```

### Definition of Done

```bash
/usr/libexec/PlistBuddy -c "Print :com.apple.developer.devicecheck.appattest-environment" Momsy/Momsy.entitlements
# expect: development
/usr/libexec/PlistBuddy -c "Print :com.apple.developer.devicecheck.appattest-environment" Momsy/Momsy.Release.entitlements
# expect: production
/usr/libexec/PlistBuddy -c "Print :aps-environment" Momsy/Momsy.Release.entitlements
# expect: production
```

### Acceptance criteria

- Debug build on a physical device obtains an App Check token without an App Attest environment error in Console (`subsystem: RuslanAbd.Momsy`), assuming the debug token is registered in the Firebase Console.

---

## T5 — Keep `AppCheckDebugProvider` out of release builds (P2, optional)

**Problem.** `Momsy/Services/Firebase/AppCheckProviderFactory.swift:20-38` selects the provider on `#if targetEnvironment(simulator)`, not build configuration. `AppCheckDebugProvider` is therefore compiled into the App Store binary. It is not reachable on real hardware — App Store builds never run on a simulator — so this is hardening, not a live vulnerability.

**Tradeoff, decide before applying:** after this change, a *Release* configuration running on the simulator can no longer mint an App Check token, so subscription entitlement sync (`FamilyPremiumService.swift:84`) will fail there. If Release-on-simulator is part of the QA routine, skip this task.

**File:** `Momsy/Services/Firebase/AppCheckProviderFactory.swift`

### BEFORE

```swift
    static func providerMode(
        isSimulator: Bool,
        isAppAttestSupported: Bool
    ) -> ProviderMode {
        if isSimulator { return .debug }
        return isAppAttestSupported ? .appAttest : .deviceCheck
    }

    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if targetEnvironment(simulator)
        let mode = Self.providerMode(isSimulator: true, isAppAttestSupported: false)
        #else
        let mode = Self.providerMode(
            isSimulator: false,
            isAppAttestSupported: DCAppAttestService.shared.isSupported
        )
        #endif

        switch mode {
        case .debug:
            return AppCheckDebugProvider(app: app)
        case .appAttest:
            return AppAttestProvider(app: app)
        case .deviceCheck:
            return DeviceCheckProvider(app: app)
        }
    }
```

### AFTER

```swift
    static func providerMode(
        isDebugBuild: Bool,
        isAppAttestSupported: Bool
    ) -> ProviderMode {
        if isDebugBuild { return .debug }
        return isAppAttestSupported ? .appAttest : .deviceCheck
    }

    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if DEBUG
        return AppCheckDebugProvider(app: app)
        #else
        let mode = Self.providerMode(
            isDebugBuild: false,
            isAppAttestSupported: DCAppAttestService.shared.isSupported
        )

        switch mode {
        case .debug, .appAttest:
            return AppAttestProvider(app: app)
        case .deviceCheck:
            return DeviceCheckProvider(app: app)
        }
        #endif
    }
```

**File:** `MomsyTests/Services/Firebase/FirebaseBootstrapperTests.swift` — the existing suite calls the old signature and will not compile otherwise. This is an existing test file, so no `project.pbxproj` registration is needed.

### BEFORE

```swift
    @Test("App Check uses debug only in the simulator")
    func appCheckProviderModeMatchesRuntime() {
        #expect(MomsyAppCheckProviderFactory.providerMode(
            isSimulator: true,
            isAppAttestSupported: false
        ) == .debug)
        #expect(MomsyAppCheckProviderFactory.providerMode(
            isSimulator: false,
            isAppAttestSupported: true
        ) == .appAttest)
        #expect(MomsyAppCheckProviderFactory.providerMode(
            isSimulator: false,
            isAppAttestSupported: false
        ) == .deviceCheck)
    }
```

### AFTER

```swift
    @Test("App Check uses the debug provider only in debug builds")
    func appCheckProviderModeMatchesRuntime() {
        #expect(MomsyAppCheckProviderFactory.providerMode(
            isDebugBuild: true,
            isAppAttestSupported: false
        ) == .debug)
        #expect(MomsyAppCheckProviderFactory.providerMode(
            isDebugBuild: false,
            isAppAttestSupported: true
        ) == .appAttest)
        #expect(MomsyAppCheckProviderFactory.providerMode(
            isDebugBuild: false,
            isAppAttestSupported: false
        ) == .deviceCheck)
    }
```

### Definition of Done

```bash
grep -c "targetEnvironment(simulator)" Momsy/Services/Firebase/AppCheckProviderFactory.swift
# expect: 0
grep -c "AppCheckDebugProvider" Momsy/Services/Firebase/AppCheckProviderFactory.swift
# expect: 1
grep -n -B2 "AppCheckDebugProvider" Momsy/Services/Firebase/AppCheckProviderFactory.swift | grep -c "#if DEBUG"
# expect: 1
grep -c "isSimulator" MomsyTests/Services/Firebase/FirebaseBootstrapperTests.swift
# expect: 0
```

### Acceptance criteria

- `xcodebuild -configuration Release` archive: `nm -u` on the app binary shows no `AppCheckDebugProvider` symbol reference.
- Debug build on the simulator still obtains a debug token.

---

## T6 — Verify `GoogleSignIn` linkage (verification only, no edit)

**Context.** `Momsy/Core/Auth/AuthManager.swift:351`, `365`, `411`, `445` gate the entire Google path behind `#if canImport(GoogleSignIn)`, falling back to `throw AuthError.notImplemented`. The package reference exists (`project.pbxproj:979`, `GoogleSignIn-iOS`) and the reversed client ID URL scheme is present in `Momsy/Info.plist`. If the product is ever dropped from the app target's link phase, Google sign-in degrades to a runtime error rather than a build failure.

```bash
grep -c "GoogleSignIn" Momsy.xcodeproj/project.pbxproj
# expect: > 0
xcodebuild -showBuildSettings -target Momsy 2>/dev/null | grep -i googlesignin
```

Then confirm in Xcode that `GoogleSignIn` and `GoogleSignInSwift` appear under the `Momsy` target → Frameworks, Libraries, and Embedded Content.

Google must also be enabled as a sign-in provider in the Firebase Console for the production project, or the button will fail at runtime with a configuration error.

---

## T7 — Resolve the initial language from the device (P0 for a multilingual launch)

**Problem.** `Momsy/Core/Localization/LocalizationManager.swift:16-19` falls back to `Language.english.rawValue` when nothing is stored. The device language is never consulted, so every first launch anywhere in the world is English until the user finds the language picker in Settings. For a seven-language launch this is worse than a missing translation — the translations exist and are simply never reached.

**Depends on T1.** `Locale.preferredLanguages` is intersected with the bundle's declared localizations. Until `CFBundleLocalizations` lists all seven, this returns `en` on every device and T7 is a no-op.

This task also introduces the `nonisolated` accessors that T9 depends on. `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` makes the class main-actor isolated, and `AuthError.errorDescription` is a `nonisolated` protocol requirement — it cannot touch `shared.strings`.

**File:** `Momsy/Core/Localization/LocalizationManager.swift`

### BEFORE

```swift
    @Published private(set) var current: Language

    private init() {
        let stored = UserDefaults.standard.string(forKey: Defaults.appLanguageKey)
            ?? UserDefaults(suiteName: Defaults.appGroupSuiteName)?.string(forKey: Defaults.appLanguageKey)
            ?? Language.english.rawValue
        current = Language(rawValue: stored) ?? .english
        persist(current, reloadWidgets: false)
    }
```

### AFTER

```swift
    @Published private(set) var current: Language

    /// Device language narrowed to a supported `Language`. Region and script
    /// subtags are dropped: `de-AT` → `de`, `zh-Hans-CN` → `zh`, `pt-BR` → `pt`.
    nonisolated static var systemLanguage: Language {
        for identifier in Locale.preferredLanguages {
            let code = identifier.split(separator: "-").first.map(String.init) ?? identifier
            if let language = Language(rawValue: code) { return language }
        }
        return .english
    }

    /// The user's explicit choice, or the device language on first launch.
    /// `nonisolated` so that non-isolated call sites — `LocalizedError`
    /// conformances in particular — can read it without hopping to the main actor.
    nonisolated static var currentLanguage: Language {
        let stored = UserDefaults.standard.string(forKey: Defaults.appLanguageKey)
            ?? UserDefaults(suiteName: Defaults.appGroupSuiteName)?.string(forKey: Defaults.appLanguageKey)
        return stored.flatMap(Language.init(rawValue:)) ?? systemLanguage
    }

    nonisolated static var strings: L10n { L10n(currentLanguage) }

    private init() {
        current = Self.currentLanguage
        persist(current, reloadWidgets: false)
    }
```

`Defaults` stays `private` — the new members live inside the same type, so no access-level change is needed.

Existing users are unaffected: they already have a value under `appLanguage`, and `init` persists the resolved language on first launch, so the device-language path runs exactly once.

### Definition of Done

```bash
grep -c "Language.english.rawValue" Momsy/Core/Localization/LocalizationManager.swift
# expect: 0
grep -c "nonisolated static var" Momsy/Core/Localization/LocalizationManager.swift
# expect: 3
grep -c "Locale.preferredLanguages" Momsy/Core/Localization/LocalizationManager.swift
# expect: 1
```

### Acceptance criteria

- Delete the app, set the device to German, launch → the UI is German without touching Settings.
- Repeat with Portuguese (Brazil): resolves to `pt`, not English.
- Change the language in Settings, force-quit, relaunch → the explicit choice wins over the device language.

---

## T8 — Localize the widget gallery entries (P1)

**Problem.** `MomsyWidget/MomsyWidgetBundle.swift:26-27`, `39-40`, `52-53`, `65-66` hardcode `configurationDisplayName` and `description` in Russian. A Spanish or German user browsing the widget gallery sees Cyrillic. `WidgetL10n` already lives in the same target (`MomsyWidget/MomsyWidgetView.swift:91`) and covers all seven languages, so this is a table extension plus four call-site swaps.

**File:** `MomsyWidget/MomsyWidgetView.swift` — append to `WidgetL10n`, anchored on the last stored property.

### BEFORE

```swift
    var updating: String { t("Updating…", "Обновление…", "Aktualisiert…", "Actualizando…", "Mise à jour…", "A atualizar…", "更新中…") }
```

### AFTER

```swift
    var updating: String { t("Updating…", "Обновление…", "Aktualisiert…", "Actualizando…", "Mise à jour…", "A atualizar…", "更新中…") }

    var widgetFeedingDescription: String { t("Feeding timer", "Таймер кормления", "Fütterungs-Timer", "Temporizador de tomas", "Minuteur de tétée", "Temporizador de mamadas", "喂养计时器") }
    var widgetSleepDescription: String { t("Sleep tracker", "Трекер сна", "Schlaf-Tracker", "Registro de sueño", "Suivi du sommeil", "Registo de sono", "睡眠记录") }
    var widgetSummaryName: String { t("Daily summary", "Сводка дня", "Tagesübersicht", "Resumen del día", "Résumé du jour", "Resumo do dia", "每日概览") }
    var widgetSummaryDescription: String { t("Feeding, sleep and diapers", "Кормление, сон и подгузники", "Füttern, Schlaf und Windeln", "Tomas, sueño y pañales", "Tétées, sommeil et couches", "Mamadas, sono e fraldas", "喂养、睡眠和尿布") }
    var widgetStandByName: String { t("Night mode", "Ночной режим", "Nachtmodus", "Modo noche", "Mode nuit", "Modo noturno", "夜间模式") }
    var widgetStandByDescription: String { t("Last feeding and sleep for StandBy", "Последнее кормление и сон для StandBy", "Letzte Fütterung und Schlaf für StandBy", "Última toma y sueño para StandBy", "Dernière tétée et sommeil pour StandBy", "Última mamada e sono para StandBy", "StandBy 上的最近喂养与睡眠") }
```

The gallery names for feeding and sleep reuse the existing `feeding` and `sleep` entries — no duplicates.

**File:** `MomsyWidget/MomsyWidgetBundle.swift` — four pairs.

### BEFORE

```swift
        .configurationDisplayName("Кормление")
        .description("Таймер кормления")
```

### AFTER

```swift
        .configurationDisplayName(WidgetL10n.current.feeding)
        .description(WidgetL10n.current.widgetFeedingDescription)
```

### BEFORE

```swift
        .configurationDisplayName("Сон")
        .description("Трекер сна")
```

### AFTER

```swift
        .configurationDisplayName(WidgetL10n.current.sleep)
        .description(WidgetL10n.current.widgetSleepDescription)
```

### BEFORE

```swift
        .configurationDisplayName("Сводка дня")
        .description("Кормление, сон и подгузники")
```

### AFTER

```swift
        .configurationDisplayName(WidgetL10n.current.widgetSummaryName)
        .description(WidgetL10n.current.widgetSummaryDescription)
```

### BEFORE

```swift
        .configurationDisplayName("Ночной режим")
        .description("Последнее кормление и сон для StandBy")
```

### AFTER

```swift
        .configurationDisplayName(WidgetL10n.current.widgetStandByName)
        .description(WidgetL10n.current.widgetStandByDescription)
```

Passing a runtime `String` selects the `StringProtocol` overload of both modifiers rather than the `LocalizedStringKey` one — that is intended here, since the language comes from the App Group, not from `.lproj` lookup.

### Definition of Done

```bash
grep -c "[а-яА-Я]" MomsyWidget/MomsyWidgetBundle.swift
# expect: 0
grep -c "WidgetL10n.current" MomsyWidget/MomsyWidgetBundle.swift
# expect: 8
grep -c "widgetSummaryName\|widgetStandByName\|widgetFeedingDescription\|widgetSleepDescription\|widgetSummaryDescription\|widgetStandByDescription" MomsyWidget/MomsyWidgetView.swift
# expect: 6
```

### Acceptance criteria

- Set the app language to Spanish, then open the widget gallery: all four Momsy widgets show Spanish names and descriptions.
- Gallery text is cached by the system. If a stale name persists after a language switch, remove and re-add the widget — this is expected system behaviour, not a regression.

---

## T9 — Localize authentication error messages (P1)

**Problem.** `Momsy/Core/Auth/AuthManager.swift:25-38` returns ten user-facing `errorDescription` strings in English only. They surface through `error.localizedDescription` across onboarding, the paywall and family sharing — a Russian user completing a fully translated onboarding flow gets an English alert the moment Sign in with Apple fails.

**Depends on T7** for `LocalizationManager.strings`.

**File:** `Momsy/Core/Localization/L10n.swift` — append a new section at the end of the struct, before the closing brace.

### AFTER (new entries)

```swift
    // MARK: — Auth errors
    var authAppleTokenMissing: String { s("Apple Sign-In failed. Please try again.", "Не удалось войти через Apple. Попробуйте ещё раз.", "Anmeldung mit Apple fehlgeschlagen. Bitte versuche es erneut.", "No se pudo iniciar sesión con Apple. Inténtalo de nuevo.", "La connexion avec Apple a échoué. Veuillez réessayer.", "Não foi possível iniciar sessão com a Apple. Tente novamente.", "Apple 登录失败，请重试。") }
    var authGoogleNotImplemented: String { s("Google Sign-In is coming soon.", "Вход через Google скоро появится.", "Anmeldung mit Google folgt in Kürze.", "El inicio de sesión con Google estará disponible pronto.", "La connexion avec Google arrive bientôt.", "O início de sessão com o Google estará disponível em breve.", "Google 登录即将推出。") }
    var authAppleSignInUnavailable: String { s("To use Sign in with Apple, open Settings → [Your Name] and sign in with your Apple ID.", "Чтобы войти через Apple, откройте «Настройки» → [Ваше имя] и войдите в Apple ID.", "Um „Mit Apple anmelden“ zu nutzen, öffne Einstellungen → [Dein Name] und melde dich mit deiner Apple-ID an.", "Para usar «Iniciar sesión con Apple», abre Ajustes → [Tu nombre] e inicia sesión con tu Apple ID.", "Pour utiliser « Se connecter avec Apple », ouvrez Réglages → [Votre nom] et connectez-vous avec votre identifiant Apple.", "Para usar «Iniciar sessão com a Apple», abra Definições → [O seu nome] e inicie sessão com o seu Apple ID.", "要使用「通过 Apple 登录」，请打开「设置」→[您的姓名]并登录 Apple ID。") }
    var authReauthRequired: String { s("Please sign in again to delete your account.", "Войдите заново, чтобы удалить аккаунт.", "Bitte melde dich erneut an, um dein Konto zu löschen.", "Vuelve a iniciar sesión para eliminar tu cuenta.", "Reconnectez-vous pour supprimer votre compte.", "Inicie sessão novamente para eliminar a sua conta.", "请重新登录以删除您的账户。") }
    var authAccountDeletionPending: String { s("Previous account deletion is still finishing. Please try again.", "Предыдущее удаление аккаунта ещё завершается. Попробуйте позже.", "Die vorherige Kontolöschung wird noch abgeschlossen. Bitte versuche es erneut.", "La eliminación anterior de la cuenta aún está terminando. Inténtalo de nuevo.", "La suppression précédente du compte est encore en cours. Veuillez réessayer.", "A eliminação anterior da conta ainda está a terminar. Tente novamente.", "上一次账户删除仍在完成中，请稍后重试。") }
    var authAccountDeletionFinished: String { s("Previous account deletion finished. Please sign in again.", "Предыдущее удаление аккаунта завершено. Войдите заново.", "Die vorherige Kontolöschung ist abgeschlossen. Bitte melde dich erneut an.", "La eliminación anterior de la cuenta ha finalizado. Vuelve a iniciar sesión.", "La suppression précédente du compte est terminée. Veuillez vous reconnecter.", "A eliminação anterior da conta foi concluída. Inicie sessão novamente.", "上一次账户删除已完成，请重新登录。") }
    var authCloudSyncConsentRequired: String { s("Allow cloud sync before using family sharing.", "Разрешите облачную синхронизацию, чтобы пользоваться семейным доступом.", "Erlaube die Cloud-Synchronisierung, um die Familienfreigabe zu nutzen.", "Permite la sincronización en la nube para usar el acceso familiar.", "Autorisez la synchronisation cloud pour utiliser le partage familial.", "Permita a sincronização na nuvem para usar a partilha familiar.", "请先允许云端同步，才能使用家庭共享。") }
    var authNonceGenerationFailed: String { s("Could not start Sign in with Apple. Please try again.", "Не удалось начать вход через Apple. Попробуйте ещё раз.", "„Mit Apple anmelden“ konnte nicht gestartet werden. Bitte versuche es erneut.", "No se pudo iniciar «Iniciar sesión con Apple». Inténtalo de nuevo.", "Impossible de démarrer « Se connecter avec Apple ». Veuillez réessayer.", "Não foi possível iniciar «Iniciar sessão com a Apple». Tente novamente.", "无法启动「通过 Apple 登录」，请重试。") }
    var authAnonymousSignInRestricted: String { s("Sign in with Apple or Google before creating or joining a family.", "Войдите через Apple или Google, чтобы создать семью или присоединиться к ней.", "Melde dich mit Apple oder Google an, bevor du eine Familie erstellst oder ihr beitrittst.", "Inicia sesión con Apple o Google antes de crear una familia o unirte a ella.", "Connectez-vous avec Apple ou Google avant de créer une famille ou de la rejoindre.", "Inicie sessão com a Apple ou o Google antes de criar uma família ou aderir a uma.", "创建或加入家庭前，请通过 Apple 或 Google 登录。") }
    var authProviderAccountConflict: String { s("This email is already linked to a different sign-in method. Use the provider you originally signed in with.", "Эта почта уже привязана к другому способу входа. Используйте тот сервис, через который вы регистрировались.", "Diese E-Mail ist bereits mit einer anderen Anmeldemethode verknüpft. Nutze den Anbieter, mit dem du dich ursprünglich angemeldet hast.", "Este correo ya está vinculado a otro método de inicio de sesión. Usa el proveedor con el que te registraste.", "Cet e-mail est déjà lié à une autre méthode de connexion. Utilisez le fournisseur avec lequel vous vous êtes inscrit.", "Este e-mail já está associado a outro método de início de sessão. Use o fornecedor com o qual se registou.", "该邮箱已绑定其他登录方式，请使用您最初注册时使用的方式。") }
```

**File:** `Momsy/Core/Auth/AuthManager.swift`

### BEFORE

```swift
    var errorDescription: String? {
        switch self {
        case .tokenMissing:          return "Apple Sign-In failed. Please try again."
        case .notImplemented:        return "Google Sign-In is coming soon."
        case .appleSignInUnavailable: return "To use Sign in with Apple, open Settings → [Your Name] and sign in with your Apple ID."
        case .reauthRequired:        return "Please sign in again to delete your account."
        case .accountDeletionPending: return "Previous account deletion is still finishing. Please try again."
        case .accountDeletionFinished: return "Previous account deletion finished. Please sign in again."
        case .cloudSyncConsentRequired: return "Allow cloud sync before using family sharing."
        case .nonceGenerationFailed: return "Could not start Sign in with Apple. Please try again."
        case .anonymousSignInRestricted: return "Sign in with Apple or Google before creating or joining a family."
        case .providerAccountConflict: return "This email is already linked to a different sign-in method. Use the provider you originally signed in with."
        }
    }
```

### AFTER

```swift
    var errorDescription: String? {
        let strings = LocalizationManager.strings
        switch self {
        case .tokenMissing:          return strings.authAppleTokenMissing
        case .notImplemented:        return strings.authGoogleNotImplemented
        case .appleSignInUnavailable: return strings.authAppleSignInUnavailable
        case .reauthRequired:        return strings.authReauthRequired
        case .accountDeletionPending: return strings.authAccountDeletionPending
        case .accountDeletionFinished: return strings.authAccountDeletionFinished
        case .cloudSyncConsentRequired: return strings.authCloudSyncConsentRequired
        case .nonceGenerationFailed: return strings.authNonceGenerationFailed
        case .anonymousSignInRestricted: return strings.authAnonymousSignInRestricted
        case .providerAccountConflict: return strings.authProviderAccountConflict
        }
    }
```

**Tradeoff.** `AuthError` now reads a global. The alternative — threading `L10n` through every call site — would touch every view that renders `error.localizedDescription`, and `LocalizedError` gives no place to inject a dependency. `LocalizationManager.strings` is a pure read of a `UserDefaults`-backed value, so this stays testable: set `appLanguage` in the test defaults and assert on `errorDescription`.

### Definition of Done

```bash
grep -c "return \"" Momsy/Core/Auth/AuthManager.swift
# expect: 0
grep -c "LocalizationManager.strings" Momsy/Core/Auth/AuthManager.swift
# expect: 1
grep -c "var auth[A-Z]" Momsy/Core/Localization/L10n.swift
# expect: 10
```

### Acceptance criteria

- Set the app language to French, trigger a Sign in with Apple cancellation → the alert body is French.
- No remaining English literal in `AuthManager.swift` outside of log messages.

---

## T10 — App Store Connect (no code)

Not executable by Claude Code; tracked here so the release is not declared done with the bundle localized and the storefront English.

- Seven listing localizations: name, subtitle, description, keywords, promotional text, what's new. Promotional text is already finalized for all seven.
- Subscription products: `display name` and `description` per locale. Without them StoreKit returns English product names into a fully translated paywall.
- Screenshots: one set is the Apple minimum, but English screenshots in the zh-Hans storefront measurably hurt conversion.
- Lock in `pt-PT` vs `pt-BR` and `zh-Hans` vs `zh-Hant` first — the choice propagates to `CFBundleLocalizations` (T1), `Language.localeIdentifier`, and the ASC storefront list.

---

## Build & test gate

```bash
xcodebuild \
  -project Momsy.xcodeproj \
  -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  clean build test 2>&1 | tail -30
# expect: ** TEST SUCCEEDED **
```

---

## Manual QA script

1. **Localization (T1).** Set the device system language to Russian, launch a fresh install, open Tracking → Add measurement and the growth chart. Date labels are in Russian. Repeat with German.
2. **Widget version (T2).** Build an archive, open the `.xcarchive`, confirm `Products/Applications/Momsy.app/PlugIns/MomsyWidget.appex/Info.plist` reports the same `CFBundleShortVersionString` as the app.
3. **Firebase absent (T3).** Remove the plist from Copy Bundle Resources, run Debug → assertion trap. Restore.
4. **App Attest (T4).** Debug build on a physical device, sign in, open the paywall and restore purchases. Console shows no App Check token error.
5. **First launch language (T7).** Delete the app, set the device to German, launch → German UI with no manual selection. Repeat for Spanish and Simplified Chinese.
6. **Widget gallery (T8).** With the app language set to Spanish, open the widget gallery and confirm all four Momsy entries are Spanish. Remove and re-add a widget if a cached name persists.
7. **Auth errors (T9).** App language French, cancel Sign in with Apple → French alert. Repeat with the cloud-sync consent path.
8. **Regression sweep.** Co-parent sync on two devices: start a sleep timer on device A, confirm the Live Activity ends on device B when A stops it. This exercises the APNs path that depends on `RemotePushTokenService.environment` and the Cloud Functions secrets.

---

## Task summary

| Task | Severity | Files touched | Blocks submission |
|---|---|---|---|
| T1 | P0 | `Momsy/Info.plist`, `project.pbxproj` | Yes |
| T2 | P1 | `MomsyWidget/Info.plist`, `project.pbxproj` | Not 1.0, blocks 1.0.1 |
| T3 | P1 | `FirebaseBootstrapper.swift` | No — prevents a silent-failure ship |
| T4 | P1 | `Momsy/Momsy.entitlements` | No — blocks device debugging |
| T5 | P2 | `AppCheckProviderFactory.swift`, `FirebaseBootstrapperTests.swift` | No |
| T6 | — | none (verification) | No |
| T7 | P0 | `LocalizationManager.swift` | Yes for a 7-language launch |
| T8 | P1 | `MomsyWidgetBundle.swift`, `MomsyWidgetView.swift` | No |
| T9 | P1 | `AuthManager.swift`, `L10n.swift` | No |
| T10 | — | none (App Store Connect) | Yes |

**Order.** T1 → T7 → T9 is a chain: T7 is inert without the declared localizations, and T9 needs the `nonisolated` accessors T7 adds. T2, T3, T4, T5, T8 are independent and can run in any order.
