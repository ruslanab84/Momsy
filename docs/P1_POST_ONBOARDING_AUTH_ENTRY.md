# P1 — Post-Onboarding Auth Entry + Join Self-Heal

**Repo:** `ruslanab84/Momsy` · verified against `fbc6704`
**Scope:** 2 new files, 4 edits, 1 test file. No changes to Watch/Widget targets.

---

## Root cause (verified)

**Bug 1 — dead-end "Please sign in first."**
`SharingViewModel.joinFamily()` (manual code paste) hard-guards `Auth.auth().currentUser?.uid` and shows a **hardcoded English** string. The deep-link path (`MomsyApp.joinFamilyFromLink`, line ~142) behaves differently: it calls `signInAnonymouslyIfNeeded()` first, then joins. When the silent anonymous sign-in at launch fails (offline launch — `signInAnonymouslyIfNeeded` only logs errors), manual join dead-ends while deep-link join would self-heal. Paths must be aligned.

**Bug 2 — no sign-in entry point after onboarding.**
`SettingsView` sections: theme / units / language / vaccination / children / about / danger. No account section. `AuthStep` (Apple/Google UI) exists only inside onboarding. A user who skipped auth has **no way to sign in later**, even when the app tells them to.

**Note (no action):** `SubscriptionAuthGate` is dead code — never called anywhere. Leave as is; it becomes usable once this task lands.

---

## Verified signatures

| Symbol | Location | Shape |
|---|---|---|
| `AuthManager` | `Core/Auth/AuthManager.swift:35` | `final class AuthManager: ObservableObject`, `@Published private(set) var firebaseUser`, `var isSignedIn: Bool` (non-anonymous), `func signInAnonymouslyIfNeeded() async`, `func prepareAppleRequest(_:)`, `func handleAppleCompletion(_:) async throws`, `func signInWithGoogle() async throws`. `linkOrSignIn` preserves uid on anonymous→provider link. |
| `AuthStep` | `Features/Onboarding/Presentation/Views/OBStepAuth.swift` | `title, subtitle, isSigningIn, authError: Error?, allowsSkip, prepareAppleRequest, onAppleCompletion, onGoogle, onSkip`; uses `@EnvironmentObject loc: LocalizationManager` |
| `SharingViewModel.init` | `Features/Sharing/.../SharingViewModel.swift` | `(repo:inviteService:appState:)`, factory at `AppContainer.swift:416` |
| `SettingsView.init` | `Features/Settings/.../SettingsView.swift` | `init(container: AppContainer)`; factory at `AppContainer.swift:537` |
| `cloudSyncDownloader` | `AppContainer.swift:48` | `lazy var cloudSyncDownloader: any CloudSyncDownloaderProtocol`, has `downloadAndMergeWhenReady()` |
| L10n | `Core/Localization/L10n.swift` | `var key: String { s(EN, RU, DE, ES, FR, PT, ZH) }` — **7 languages** |

---

## Task 1 — NEW `Momsy/Features/Sharing/Domain/JoinAuthProviding.swift`

```swift
import Foundation

@MainActor
protocol JoinAuthProviding: AnyObject {
    var currentUID: String? { get }
    func signInAnonymouslyIfNeeded() async
}

extension AuthManager: JoinAuthProviding {
    var currentUID: String? { firebaseUser?.uid }
}
```

If `AuthManager` isolation conflicts with `@MainActor` protocol under the project's concurrency mode, drop `@MainActor` from the protocol and mark `currentUID` requirement `@MainActor` instead.

## Task 2 — EDIT `SharingViewModel.swift`

2a. Add dependency (next to existing `repo` / `inviteService` / `appState` lets, and to `init`):

```swift
private let auth: any JoinAuthProviding
```

2b. Replace `joinFamily(force:)` entirely:

```swift
func joinFamily(force: Bool = false) {
    guard !joinCode.trimmingCharacters(in: .whitespaces).isEmpty else { return }
    guard !isJoining else { return }
    isJoining = true
    joinError = nil
    Task {
        await auth.signInAnonymouslyIfNeeded()
        guard let uid = auth.currentUID else {
            joinError = lm.strings.joinAuthUnavailable
            isJoining = false
            return
        }
        do {
            try await FamilyManager.shared.joinFamily(code: joinCode, uid: uid, force: force)
            joinCode = ""
            joinSuccess = true
            await loadMembers()
        } catch FamilyError.wouldAbandonExistingFamily {
            showJoinConfirm = true
        } catch {
            joinError = error.localizedDescription
        }
        isJoining = false
        if joinSuccess {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            joinSuccess = false
        }
    }
}
```

Removes the hardcoded `"Please sign in first."` and the `import FirebaseAuth` usage for `Auth.auth()` in this method (keep the import only if still used elsewhere in the file).

## Task 3 — EDIT `AppContainer.swift` (two factories)

```swift
func makeSharingViewModel() -> SharingViewModel {
    SharingViewModel(repo: familyRepository, inviteService: inviteService, appState: appState, auth: authManager)
}

func makeAccountAuthViewModel() -> AccountAuthViewModel {
    AccountAuthViewModel(auth: authManager) { [weak self] in
        await self?.cloudSyncDownloader.downloadAndMergeWhenReady()
    }
}
```

## Task 4 — NEW `Momsy/Features/Settings/Presentation/ViewModel/AccountAuthViewModel.swift`

```swift
import Foundation
import AuthenticationServices

@MainActor
protocol AccountAuthProviding: AnyObject {
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest)
    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) async throws
    func signInWithGoogle() async throws
}

extension AuthManager: AccountAuthProviding {}

@MainActor
final class AccountAuthViewModel: ObservableObject {
    @Published private(set) var isSigningIn = false
    @Published private(set) var authError: Error?
    @Published private(set) var didSignIn = false

    private let auth: any AccountAuthProviding
    private let onSignedIn: () async -> Void

    init(auth: any AccountAuthProviding, onSignedIn: @escaping () async -> Void) {
        self.auth = auth
        self.onSignedIn = onSignedIn
    }

    func prepareApple(_ request: ASAuthorizationAppleIDRequest) {
        auth.prepareAppleRequest(request)
    }

    func completeApple(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let error) = result,
           (error as? ASAuthorizationError)?.code == .canceled {
            return
        }
        run { try await self.auth.handleAppleCompletion(result) }
    }

    func signInWithGoogle() {
        run { try await self.auth.signInWithGoogle() }
    }

    private func run(_ op: @escaping () async throws -> Void) {
        guard !isSigningIn else { return }
        isSigningIn = true
        authError = nil
        Task {
            do {
                try await op()
                await onSignedIn()
                didSignIn = true
            } catch {
                authError = error
            }
            isSigningIn = false
        }
    }
}
```

## Task 5 — NEW `Momsy/Features/Settings/Presentation/Views/AccountAuthSheet.swift`

```swift
import SwiftUI
import AuthenticationServices

struct AccountAuthSheet: View {
    @StateObject private var vm: AccountAuthViewModel
    @EnvironmentObject private var loc: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeAccountAuthViewModel())
    }

    var body: some View {
        NavigationStack {
            AuthStep(
                title: loc.strings.settingsAuthSheetTitle,
                subtitle: loc.strings.settingsAuthSheetSubtitle,
                isSigningIn: vm.isSigningIn,
                authError: vm.authError,
                allowsSkip: false,
                prepareAppleRequest: vm.prepareApple,
                onAppleCompletion: vm.completeApple,
                onGoogle: vm.signInWithGoogle,
                onSkip: {}
            )
            .background(Color.bbCream.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.bbInkMute)
                    }
                }
            }
        }
        .onChange(of: vm.didSignIn) { _, signedIn in
            if signedIn { dismiss() }
        }
    }
}
```

`AuthStep` gets `LocalizationManager` from the environment — sheets inherit it from the presenting view, no extra injection needed.

## Task 6 — EDIT `SettingsView.swift`

6a. Properties + init:

```swift
@ObservedObject private var authManager: AuthManager
@State private var showAuthSheet = false
private let container: AppContainer

init(container: AppContainer) {
    self.container = container
    _authManager = ObservedObject(wrappedValue: container.authManager)
    _vm = StateObject(wrappedValue: container.makeSettingsViewModel())
}
```

6b. In `body`, insert `accountSection` between `childrenSection` and `aboutSection`.

6c. Attach to the root `ScrollView` (next to existing modifiers):

```swift
.sheet(isPresented: $showAuthSheet) {
    AccountAuthSheet(container: container)
}
```

6d. New section (follows existing card patterns; verify `.bbMint` exists in the palette — if not, use `.bbMintDeep`):

```swift
private var accountSection: some View {
    VStack(alignment: .leading, spacing: 10) {
        BBSectionLabel(text: lm.strings.settingsAccount)

        if authManager.isSignedIn {
            HStack(spacing: 14) {
                iconSquare(systemName: "person.crop.circle.badge.checkmark", bg: .bbMint)
                VStack(alignment: .leading, spacing: 2) {
                    Text(lm.strings.settingsSignedIn)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInk)
                    if let email = authManager.firebaseUser?.email, !email.isEmpty {
                        Text(email)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.bbInkMute)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .bbShadow()
        } else {
            Button {
                showAuthSheet = true
            } label: {
                HStack(spacing: 14) {
                    iconSquare(systemName: "person.crop.circle.badge.plus", bg: .bbCoral)
                    Text(lm.strings.settingsSignIn)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInk)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.bbInkMute)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .bbShadow()

            Text(lm.strings.settingsSignInHint)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkMute)
                .padding(.horizontal, 2)
        }
    }
}
```

## Task 7 — EDIT `L10n.swift` (7 keys, place near `signInWithApple` ~line 1120)

```swift
var settingsAccount: String        { s("Account", "Аккаунт", "Konto", "Cuenta", "Compte", "Conta", "账户") }
var settingsSignIn: String         { s("Sign in", "Войти", "Anmelden", "Iniciar sesión", "Se connecter", "Iniciar sessão", "登录") }
var settingsSignInHint: String     { s("Back up your data and sync with your family", "Сохраните данные и синхронизируйтесь с семьёй", "Sichern Sie Ihre Daten und synchronisieren Sie mit Ihrer Familie", "Guarda tus datos y sincroniza con tu familia", "Sauvegardez vos données et synchronisez avec votre famille", "Faça backup dos seus dados e sincronize com a família", "备份数据并与家人同步") }
var settingsSignedIn: String       { s("Signed in", "Вы вошли", "Angemeldet", "Sesión iniciada", "Connecté", "Sessão iniciada", "已登录") }
var settingsAuthSheetTitle: String { s("Sign in to Momsy", "Войдите в Momsy", "Bei Momsy anmelden", "Inicia sesión en Momsy", "Connectez-vous à Momsy", "Inicie sessão no Momsy", "登录 Momsy") }
var settingsAuthSheetSubtitle: String { s("Your entries will be linked to your account and synced across devices", "Записи будут привязаны к аккаунту и синхронизированы между устройствами", "Ihre Einträge werden mit Ihrem Konto verknüpft und geräteübergreifend synchronisiert", "Tus registros se vincularán a tu cuenta y se sincronizarán entre dispositivos", "Vos entrées seront liées à votre compte et synchronisées entre vos appareils", "Os seus registos serão associados à sua conta e sincronizados entre dispositivos", "记录将关联到您的账户并在设备间同步") }
var joinAuthUnavailable: String    { s("Couldn't connect. Check your internet connection and try again.", "Не удалось подключиться. Проверьте интернет и попробуйте снова.", "Verbindung fehlgeschlagen. Prüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.", "No se pudo conectar. Comprueba tu conexión e inténtalo de nuevo.", "Connexion impossible. Vérifiez votre connexion Internet et réessayez.", "Não foi possível conectar. Verifique a sua ligação e tente novamente.", "无法连接。请检查网络后重试。") }
```

If the `s(...)` helper in the repo takes a different argument count, match the actual signature and fill every supported language.

## Task 8 — NEW `MomsyTests/Features/Settings/AccountAuthViewModelTests.swift`

```swift
import Testing
import AuthenticationServices
@testable import Momsy

@MainActor
private final class AuthMock: AccountAuthProviding {
    var googleResult: Result<Void, Error> = .success(())
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {}
    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) async throws {
        if case .failure(let e) = result { throw e }
    }
    func signInWithGoogle() async throws {
        if case .failure(let e) = googleResult { throw e }
    }
}

private struct DummyError: Error {}
private final class Flag { var value = false }

@MainActor
struct AccountAuthViewModelTests {

    @Test func googleSuccessSignsInAndRunsPostAction() async throws {
        let post = Flag()
        let vm = AccountAuthViewModel(auth: AuthMock()) { post.value = true }
        vm.signInWithGoogle()
        try await waitUntil { vm.didSignIn }
        #expect(post.value)
        #expect(vm.authError == nil)
        #expect(!vm.isSigningIn)
    }

    @Test func googleFailureSetsErrorAndDoesNotSignIn() async throws {
        let mock = AuthMock()
        mock.googleResult = .failure(DummyError())
        let post = Flag()
        let vm = AccountAuthViewModel(auth: mock) { post.value = true }
        vm.signInWithGoogle()
        try await waitUntil { vm.authError != nil }
        #expect(!vm.didSignIn)
        #expect(!post.value)
        #expect(!vm.isSigningIn)
    }

    @Test func appleCancelIsSilent() async throws {
        let vm = AccountAuthViewModel(auth: AuthMock()) {}
        vm.completeApple(.failure(ASAuthorizationError(.canceled)))
        try await Task.sleep(nanoseconds: 150_000_000)
        #expect(vm.authError == nil)
        #expect(!vm.isSigningIn)
        #expect(!vm.didSignIn)
    }

    @Test func reentrancyGuardBlocksSecondCall() async throws {
        let mock = AuthMock()
        let vm = AccountAuthViewModel(auth: mock) {}
        vm.signInWithGoogle()
        vm.signInWithGoogle()   // ignored while first is in flight
        try await waitUntil { vm.didSignIn }
        #expect(vm.authError == nil)
    }
}

@MainActor
private func waitUntil(timeoutNs: UInt64 = 2_000_000_000, _ cond: @escaping () -> Bool) async throws {
    let start = DispatchTime.now().uptimeNanoseconds
    while !cond() {
        if DispatchTime.now().uptimeNanoseconds - start > timeoutNs { throw DummyError() }
        try await Task.sleep(nanoseconds: 20_000_000)
    }
}
```

Optionally add a `SharingViewModel` test for the nil-uid path (mock `JoinAuthProviding` returning `nil` → expect `joinError == lm.strings.joinAuthUnavailable`, `FamilyManager` untouched) — only if existing fakes for `FamilyRepository`/`InviteServiceProtocol`/`AppState` are available in the test target; do not build new fake infrastructure for this.

---

## Definition of Done

- [ ] All targets build; Watch/Widget targets untouched
- [ ] `"Please sign in first."` hardcoded string removed from codebase (`grep -rn "sign in first" Momsy/` → 0 hits outside L10n)
- [ ] Manual join path calls `signInAnonymouslyIfNeeded()` before uid guard (parity with deep-link path)
- [ ] Settings shows Account section: sign-in row when `!isSignedIn`, signed-in card otherwise
- [ ] Auth sheet reuses `AuthStep`, `allowsSkip: false`, dismisses on success, X button works
- [ ] Post sign-in runs `downloadAndMergeWhenReady()`
- [ ] Apple sign-in cancel does not show an error banner
- [ ] New L10n keys present for all supported languages, no hardcoded UI strings added
- [ ] `AccountAuthViewModelTests` pass

## Manual QA (single simulator)

1. **Fresh install → skip auth in onboarding.** Settings → Account section shows "Sign in" row with hint. ✅
2. **Offline dead-end fix:** enable Airplane Mode → relaunch app → Sharing → paste a valid invite code → Join. Expect localized "Couldn't connect…" (not "sign in first"). Disable Airplane Mode → tap Join again → joins successfully as anonymous member. ✅
3. **Sign in from Settings (anonymous with data):** log a few entries while skipped → Settings → Sign in → Google/Apple. Sheet dismisses; section shows "Signed in" + email. All entries and family membership intact (uid preserved via linking). ✅
4. **Regression — invite deep link** still joins without visiting Settings. ✅
5. **Cancel flows:** open sheet → X closes; start Apple sign-in → cancel → no error banner. ✅
6. **Locales:** switch RU and one of DE/ES/FR/PT → new strings render, no truncation on smallest supported device. ✅
