# PAYWALL ROOT SWAP — paywall перехватывает root view и рвёт reauth-флоу удаления аккаунта

**Приоритет:** P0 (release-blocker: GDPR-удаление аккаунта физически невозможно на устройстве; free-пользователь получает paywall при каждом возврате в приложение)
**База:** `main`, коммит `da69af4e8bc1f9b317faec442578f5a902484eb5` — *Add diagnostic error tracking to distinguish empty product catalog from network timeout*
**Целевая ветка:** `fix/paywall-root-swap`
**Источник:** видеозапись с реального устройства, Momsy 1.0 (29), bundle `RuslanAbd.Momsy`, Release-конфигурация

---

## 1. Постановка задачи

### 1.1 Что видно на записи

| t | Экран |
|---|---|
| 0–2.2 с | Splash |
| 2.5–6 с | Paywall, «Subscription isn't available right now» + «Loading subscription price…» одновременно |
| 6 с | «Maybe Later» → `paywallShown = true` → MainTabView |
| 7–12 с | Settings → «Delete all data» → confirmationDialog |
| 12.5 с | Sheet «Confirm your identity» → «Sign in with Google» |
| 13.3 с | Системный алерт *«Momsy» Wants to Use "accounts.google.com" to Sign In* → **Continue** |
| 13.8 с | Веб-вью `accounts.google.com` начинает грузиться |
| **14.2 с** | **Sheet и веб-вью сносятся, на весь экран встаёт PaywallView** |
| 16–19 с | «Maybe Later» → Today, данные Zara на месте — удаление не выполнено |

### 1.2 Цепочка причин

**Звено 1 — `SubscriptionManager.updateAccessState()` (`SubscriptionManager.swift:392–399`)**
`accessState` объявлен `@Published` и присваивается **безусловно** на каждом вызове. `@Published` публикует в `willSet`, без сравнения на равенство. Для не-премиум пользователя значение всегда одно и то же — `.requiresPurchase`, — но событие уходит каждый раз.

**Звено 2 — `ContentView.swift:53–56`**
Возврат сцены в `.active` (а системный алерт Google переводит сцену в `.inactive` и обратно) вызывает `refreshAccess()` → `updatePersonalStatus` → `updateAccessState()` → публикация.

**Звено 3 — `ContentView.swift:47–52`**
```swift
.onReceive(container.subscriptionManager.$accessState) { accessState in
    if PaywallPresentationState.shouldResetDecision(for: accessState) {
        paywallShown = false
    }
    premiumAccessState = accessState
}
```
`shouldResetDecision` возвращает `true` для `.requiresPurchase` (`ContentView.swift:100–102`), то есть решение пользователя «Maybe Later» аннулируется на **каждой** публикации.

**Звено 4 — `ContentView.swift:27–39`**
`paywallShown = false` меняет ветку `if/else` в root-`ZStack`: `MainTabView` уничтожается целиком.

**Звено 5 — `SettingsView.swift:47`**
`.sheet(isPresented: $vm.showsDeletionReauthentication)` висит на вью внутри `MainTabView`. Снос ветки → SwiftUI дисмиссит sheet.

**Звено 6 — `AuthManager.swift:453–459`**
```swift
let rootVC = windowScene.windows.first?.rootViewController
let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
```
`GIDSignIn` презентует `ASWebAuthenticationSession` на root hosting controller всего приложения. Уничтожение модальной цепочки уносит и веб-сессию → `signIn` возвращает cancelled → `googleDeletionReauthenticatedUID` не выставляется → `AuthManager.deleteAccount` кидает `.reauthRequired` (`AuthManager.swift:413–414`) → `SettingsViewModel.deleteAllData` снова поднимает sheet → бесконечный цикл.

### 1.3 Второй симптом того же корня

`refreshAccess()` вызывается на каждом `.active`. Значит free-пользователь, нажавший «Maybe Later», получает paywall обратно при каждом возврате из фона / после любого системного алерта. Это независимо от удаления аккаунта — App Store review отклонит.

### 1.4 Что НЕ входит в задачу

- Не чинить пустой каталог StoreKit (`catalogEmpty`) — это конфигурация App Store Connect, чек-лист в §9, кода не требует.
- Не переносить `PaywallView` в `.fullScreenCover` поверх `MainTabView` — правильное долгосрочное решение, но меняет routing и `onboardingDone`-миграцию; отдельная задача `P1`.
- Не трогать `DeleteAccountUseCase`, `AccountDeletionRecovery`, `FirestoreAccountEraser`.
- Не менять `PaywallPresentationState.resetForAuthenticationChange` — он вызывается из `AppContainer.swift:134` при реальной смене uid и работает корректно.
- Новых Swift-файлов не создаётся → регистрация в `Momsy.xcodeproj/project.pbxproj` не нужна ни для одного таргета.

---

## 2. T1 — дедупликация публикаций `accessState`

**Файл:** `Momsy/Features/Subscription/Domain/SubscriptionManager.swift`
**Строки:** 392–399

### BEFORE
```swift
    private func updateAccessState() {
        accessState = PremiumAccessPolicy.state(
            personalPremium: personalPremium,
            familyPremium: familyPremium,
            isResolving: isResolvingPersonal || isResolvingFamily
        )
        isPremium = accessState == .premium
    }
```

### AFTER
```swift
    /// Publishes only on a real transition. `@Published` fires in `willSet` regardless of
    /// equality, and every `refreshAccess()` re-runs this with an unchanged value — which
    /// made the root view re-evaluate its routing branch on every foreground return.
    private func updateAccessState() {
        let resolved = PremiumAccessPolicy.state(
            personalPremium: personalPremium,
            familyPremium: familyPremium,
            isResolving: isResolvingPersonal || isResolvingFamily
        )
        guard resolved != accessState else { return }
        accessState = resolved
        isPremium = resolved == .premium
    }
```

**Инвариант:** `accessState` и `isPremium` остаются согласованными, потому что оба меняются только внутри этого метода. Проверить: `grep -n "isPremium = " Momsy/Features/Subscription/Domain/SubscriptionManager.swift` → ровно одно вхождение.

---

## 3. T2 — `ContentView` перестаёт аннулировать решение пользователя

**Файл:** `Momsy/ContentView.swift`
**Строки:** 47–52

### BEFORE
```swift
        .onReceive(container.subscriptionManager.$accessState) { accessState in
            if PaywallPresentationState.shouldResetDecision(for: accessState) {
                paywallShown = false
            }
            premiumAccessState = accessState
        }
```

### AFTER
```swift
        .onReceive(container.subscriptionManager.$accessState.removeDuplicates()) { accessState in
            premiumAccessState = accessState
        }
```

Сброс `paywallShown` остаётся ровно в одном месте — `AppContainer.swift:134`, по реальной смене uid (`removeDuplicates().dropFirst()` на `$firebaseUser`). Это и есть корректная семантика: «сменился аккаунт → показать paywall заново».

`.removeDuplicates()` здесь — вторая линия обороны на случай, если позднее кто-то добавит второй источник записи в `accessState`. `@Published` отдаёт текущее значение при подписке, поэтому первичная инициализация `premiumAccessState` не теряется.

**Требуется** `import Combine` в `ContentView.swift`.

### BEFORE (строка 1)
```swift
import SwiftUI
```

### AFTER
```swift
import Combine
import SwiftUI
```

---

## 4. T3 — удаление мёртвого `shouldResetDecision`

**Файл:** `Momsy/ContentView.swift`
**Строки:** 100–102

### BEFORE
```swift
    static func resetForAuthenticationChange(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: paywallShownKey)
    }

    static func shouldResetDecision(for accessState: PremiumAccessState) -> Bool {
        accessState == .requiresPurchase
    }
}
```

### AFTER
```swift
    static func resetForAuthenticationChange(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: paywallShownKey)
    }
}
```

Оставлять его нельзя: он инкапсулирует именно то правило, которое привело к багу, и следующий рефактор его переиспользует.

**Файл:** `MomsyTests/Features/Subscription/FamilyPremiumAccessTests.swift`
**Строки:** 99–105

### BEFORE
```swift
    @Test("a resolved missing entitlement invalidates the previous paywall decision")
    func missingEntitlementForcesPaywallRouting() {
        #expect(PaywallPresentationState.shouldResetDecision(for: .requiresPurchase))
        #expect(!PaywallPresentationState.shouldResetDecision(for: .resolving))
        #expect(!PaywallPresentationState.shouldResetDecision(for: .premium))
    }
```

### AFTER
```swift
    @Test("only an authentication change invalidates the paywall decision")
    func paywallDecisionSurvivesAccessStateRepublish() throws {
        let suiteName = "FamilyPremiumAccessTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(true, forKey: "paywallShown")

        // A `.requiresPurchase` state on its own must never clear the user's dismissal:
        // that reset ran on every scene activation and swapped the root view mid-flow.
        #expect(defaults.bool(forKey: "paywallShown"))

        PaywallPresentationState.resetForAuthenticationChange(defaults: defaults)

        #expect(defaults.object(forKey: "paywallShown") == nil)
    }
```

---

## 5. T4 — Google Sign-In презентуется на топовом контроллере

**Файл:** `Momsy/Core/Auth/AuthManager.swift`
**Строки:** 445–468 (блок `#if canImport(GoogleSignIn)`)

### BEFORE
```swift
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController
        else { throw AuthError.tokenMissing }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
```

### AFTER
```swift
        guard let presenter = Self.topmostPresentedViewController() else {
            throw AuthError.tokenMissing
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
```

**Вставить перед закрывающей `#endif`** (после `googleCredentialFromInteractiveSignIn`):

```swift
    /// The reauthentication sheet is itself presented modally, so presenting the Google
    /// session on the window's root controller stacks it on a view SwiftUI can tear down
    /// independently. Anchoring to the topmost live presentation keeps the session tied to
    /// the sheet that started it. `windows.first` is also not necessarily the key window.
    @MainActor
    private static func topmostPresentedViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        guard let window = scene?.windows.first(where: \.isKeyWindow) ?? scene?.windows.first,
              var top = window.rootViewController
        else { return nil }
        while let presented = top.presentedViewController, !presented.isBeingDismissed {
            top = presented
        }
        return top
    }
```

`import UIKit` уже присутствует внутри того же `#if canImport(GoogleSignIn)` (`AuthManager.swift:9`) — добавлять не нужно.

---

## 6. T5 — paywall перестаёт врать про «Loading subscription price…»

На записи одновременно видны сообщение об ошибке и «Loading subscription price…»: `renewalDisclosureText` смотрит только на `selectedProduct == nil` и не знает про `productLoadFailed`.

**Файл:** `Momsy/Features/Subscription/Presentation/Views/PaywallView.swift`
**Строки:** 249–252

### BEFORE
```swift
    private var renewalDisclosureText: String {
        guard let product = subscriptionManager.selectedProduct else {
            return lm.paywallPriceLoadingDisclosure
        }
```

### AFTER
```swift
    private var renewalDisclosureText: String {
        guard let product = subscriptionManager.selectedProduct else {
            return subscriptionManager.productLoadFailed
                ? lm.paywallPriceUnavailableDisclosure
                : lm.paywallPriceLoadingDisclosure
        }
```

Плюс визуальное состояние CTA: кнопка остаётся сплошь белой при пустом каталоге, хотя `.disabled(...)` уже стоит.

**Строки:** 195–205

### BEFORE
```swift
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(
                actionHandler.isLoading
                    || subscriptionManager.isLoading
                    || (subscriptionManager.products.isEmpty && !actionHandler.hasPendingInvite)
            )
            .padding(.horizontal, 24)
```

### AFTER
```swift
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(isPrimaryActionDisabled)
            .opacity(isPrimaryActionDisabled ? 0.45 : 1)
            .padding(.horizontal, 24)
```

**Добавить после `primaryButtonTitle`** (после строки 247):

```swift
    private var isPrimaryActionDisabled: Bool {
        actionHandler.isLoading
            || subscriptionManager.isLoading
            || (subscriptionManager.products.isEmpty && !actionHandler.hasPendingInvite)
    }
```

---

## 7. T6 — локализация (все 7 языков)

**Файл:** `Momsy/Core/Localization/L10n.swift`
**Вставить после строки 1640** (закрывающая `}` у `paywallPriceLoadingDisclosure`, перед `func paywallRenewalDisclosure(price:)` на строке 1641):

```swift
    var paywallPriceUnavailableDisclosure: String {
        s("Renewal terms will appear once prices load.",
          "Условия продления появятся после загрузки цен.",
          "Die Verlängerungsbedingungen erscheinen, sobald die Preise geladen sind.",
          "Las condiciones de renovación aparecerán cuando se carguen los precios.",
          "Les conditions de renouvellement s’afficheront une fois les prix chargés.",
          "As condições de renovação aparecerão assim que os preços forem carregados.",
          "价格加载完成后将显示续订条款。")
    }
```

Порядок аргументов `s(...)`: `en, ru, de, es, fr, pt, zh` — см. `L10n.swift:8–18`.

---

## 8. T7 — тесты (Swift Testing)

**Файл:** `MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift`
Переиспользуются существующие стабы из этого же файла: `EmptyCatalogSubscriptionService`, `NoFamilyPremiumService`, `makeDefaults()`. Новых файлов нет → pbxproj не трогаем.

**Добавить `import Combine`** в шапку файла (строка 1).

**Добавить тесты в `SubscriptionManagerLogicTests`:**

```swift
    @Test func repeatedRefreshDoesNotRepublishUnchangedAccessState() async {
        let manager = SubscriptionManager(
            service: EmptyCatalogSubscriptionService(),
            familyPremiumService: NoFamilyPremiumService(),
            syncStore: PendingSubscriptionSyncStore(defaults: makeDefaults())
        )
        await manager.refreshAccess()

        let recorder = AccessStateRecorder()
        let token = manager.$accessState.sink { recorder.values.append($0) }
        defer { token.cancel() }

        // Every scene activation calls this. A republish here reset `paywallShown` and
        // swapped the root view out from under any in-flight modal auth session.
        for _ in 0..<5 { await manager.refreshAccess() }

        #expect(recorder.values == [.requiresPurchase])
    }

    @Test func accessStatePublishesOnRealTransitions() async {
        let manager = SubscriptionManager(
            service: EmptyCatalogSubscriptionService(),
            familyPremiumService: NoFamilyPremiumService(),
            syncStore: PendingSubscriptionSyncStore(defaults: makeDefaults())
        )
        await manager.refreshAccess()

        let recorder = AccessStateRecorder()
        let token = manager.$accessState.sink { recorder.values.append($0) }
        defer { token.cancel() }

        await manager.authSessionDidChange(isAuthenticated: true)

        #expect(recorder.values.contains(.resolving))
        #expect(recorder.values.last == .requiresPurchase)
    }
```

**Добавить рядом с остальными приватными стабами файла (около строки 414):**

```swift
    private final class AccessStateRecorder: @unchecked Sendable {
        var values: [PremiumAccessState] = []
    }
```

---

## 9. T8 — пустой каталог StoreKit (без кода, чек-лист)

На записи ошибка появляется через ~2 с после сплэша — задолго до 15-секундного таймаута (`SubscriptionManager.swift:56`). Значит сработала ветка `fetched.isEmpty` → `SubscriptionError.catalogEmpty` (`SubscriptionManager.swift:288–291`): `Product.products(for:)` вернул `[]`. **Это не сеть.**

Bundle ID таргета — `RuslanAbd.Momsy` (`project.pbxproj:1480,1521`). Продукты `com.ruslanabdulov.momsy.premium.monthly` / `.annual` существуют только в `Momsy.storekit`, подключённом к схеме (`Momsy.xcscheme:63–65`) — в Xcode-запуске каталог подставляет конфиг-файл, на отвязанной сборке подставлять нечего.

Проверить в App Store Connect для записи приложения `RuslanAbd.Momsy`:

- [ ] `com.ruslanabdulov.momsy.premium.monthly` заведён, статус ≥ «Ready to Submit»
- [ ] `com.ruslanabdulov.momsy.premium.annual` заведён, статус ≥ «Ready to Submit» *(по рабочим заметкам ещё не создавался — наиболее вероятная причина)*
- [ ] Оба в одной subscription group, у группы есть localization + duration + цена хотя бы для одной страны
- [ ] У каждого продукта заполнены Display Name, Description, Review screenshot
- [ ] Paid Applications Agreement в статусе Active (Business → Agreements)
- [ ] Сборка ставится из TestFlight (sandbox), а не Xcode-Run с прицепленным `.storekit` — иначе баг замаскируется

**Гейт релиза:** пока хотя бы один продукт не резолвится, `catalogEmpty` воспроизводится и paywall остаётся нерабочим независимо от T1–T7.

---

## 10. Definition of Done — grep-проверки

```bash
# T1 — дедупликация есть, isPremium присваивается в одном месте
grep -n "guard resolved != accessState else { return }" Momsy/Features/Subscription/Domain/SubscriptionManager.swift   # 1
grep -c "isPremium = " Momsy/Features/Subscription/Domain/SubscriptionManager.swift                                    # 1

# T2 — ContentView больше не пишет paywallShown из accessState
grep -c "paywallShown = false" Momsy/ContentView.swift                                                                 # 0
grep -n "removeDuplicates()) { accessState in" Momsy/ContentView.swift                                                 # 1
grep -c "^import Combine" Momsy/ContentView.swift                                                                      # 1

# T3 — правило удалено везде
grep -rc "shouldResetDecision" Momsy/ MomsyTests/                                                                      # 0 во всех файлах
grep -rn "resetForAuthenticationChange" Momsy/ | grep -c "AppContainer.swift"                                          # 1

# T4 — презентер топовый, windows.first?.rootViewController больше нет
grep -c "windows.first?.rootViewController" Momsy/Core/Auth/AuthManager.swift                                          # 0
grep -n "topmostPresentedViewController" Momsy/Core/Auth/AuthManager.swift                                             # 2 (декларация + вызов)

# T5 — disclosure знает про ошибку, CTA гасится
grep -n "paywallPriceUnavailableDisclosure" Momsy/Features/Subscription/Presentation/Views/PaywallView.swift            # 1
grep -n "isPrimaryActionDisabled" Momsy/Features/Subscription/Presentation/Views/PaywallView.swift                      # 3

# T6 — ключ есть и содержит ровно 7 локалей
grep -A 9 "var paywallPriceUnavailableDisclosure" Momsy/Core/Localization/L10n.swift | grep -c '",\|")'                 # 7

# T7 — тесты добавлены
grep -c "repeatedRefreshDoesNotRepublishUnchangedAccessState\|accessStatePublishesOnRealTransitions" \
  MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift                                                 # 2

# Новых файлов нет → pbxproj не изменён
git diff --name-only main -- Momsy.xcodeproj/project.pbxproj                                                           # пусто
```

Сборка: `xcodebuild -scheme Momsy -destination 'generic/platform=iOS' build` — 0 warnings по strict concurrency.
Тесты: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16'` — весь `SubscriptionManagerLogicTests` и `FamilyPremiumAccessTests` зелёные.

---

## 11. Ручной QA (реальное устройство, TestFlight, аккаунт без подписки)

| # | Шаг | Ожидаемо |
|---|---|---|
| 1 | Установить, пройти onboarding, на paywall нажать «Maybe Later» | MainTabView |
| 2 | Свернуть приложение, развернуть | **MainTabView, paywall НЕ появляется** (главная регрессия) |
| 3 | Развернуть/свернуть 5 раз подряд | paywall не появляется ни разу |
| 4 | Settings → Cloud sync toggle off → on | Root-вью не мигает, paywall не появляется |
| 5 | Settings → Delete all data → Sign in with Google → Continue в системном алерте | **Веб-вью Google остаётся на экране, sheet не сносится** |
| 6 | Завершить вход Google | Sheet закрывается, показывается индикатор удаления, приложение уходит на onboarding |
| 7 | Отменить вход Google на шаге 5 (крестик) | Возврат в sheet «Confirm your identity», ошибка reauth в тексте, MainTabView под ним цел |
| 8 | То же для Apple-аккаунта (Settings → Delete all data → Sign in with Apple) | Идентично шагам 5–7 |
| 9 | Войти в другой Google-аккаунт (Settings → sign out → sign in) | paywall показывается заново (сброс через `AppContainer.swift:134` работает) |
| 10 | С активной подпиской: свернуть/развернуть | Paywall не появляется, premium сохраняется |
| 11 | Открыть paywall при пустом каталоге ASC | Ошибка + «Renewal terms will appear once prices load.», кнопка Subscribe заметно погашена |
| 12 | Переключить язык на RU/DE/ES/FR/PT/ZH, п.11 | Новая строка локализована, не EN-фолбэк |

**Регресс-риск:** после T1 `accessState` не публикуется при неизменном значении. Если где-то в коде появится подписчик, которому нужен «пинок» без смены состояния, он его не получит. Проверено: единственные подписчики на `$accessState` — `ContentView.swift:47`. `grep -rn '\$accessState' Momsy/` → 1 вхождение.
