# TASK: Годовая подписка — annual product + селектор планов на пейволле

**Приоритет:** P2 (нужно до запуска годового плана; не блокирует v1 с одним monthly)
**Оценка:** M
**Не пересекается** с TASK_RATE_US_ACTIVATION.md.

## Контекст (проверено по клону, commit `cfde6a5`)

Сейчас существует только monthly. Захардкоженность на один продукт:

| Файл | Строка | Что |
|---|---|---|
| `Momsy/Features/Subscription/Domain/ProductID.swift` | 1-7 | только `monthly` |
| `Momsy/Features/Subscription/Domain/SubscriptionManager.swift` | 47 | `grantsPremium = tx.productID == ProductID.monthly` |
| там же | 86 | `products.first(where: { $0.id == ProductID.monthly })` |
| там же | 109 | entitlement-фильтр только по monthly |
| там же | 100-104 | `cache()` хранит один `Product`, `monthlyPrice`, `subscriptionName` |
| `Momsy/Features/Subscription/Presentation/PaywallView.swift` | 104-120 | `planSummary` — статичный, период захардкожен `paywallMonthlyPeriod` |
| там же | 174-179 | disclosure только monthly-вариант |
| `Momsy/Core/Localization/L10n.swift` | 1369, 1399-1406 | `paywallMonthlyPeriod`, `paywallRenewalDisclosure(price:)` — только месяц |

Решения (согласованы ранее): annual предвыбран, 7-дневный триал, entitlement — любой из продуктов.

---

## Шаг 0. App Store Connect (вне кода, сделать до QA)

1. My Apps → Momsy → Subscriptions → та же subscription group, что и monthly.
2. Новый auto-renewable: **Product ID `com.ruslanabdulov.momsy.premium.annual`**, duration 1 Year.
3. Level в группе: annual выше monthly (upgrade-семантика monthly → annual).
4. Introductory Offer: Free Trial, 7 days — на annual. Проверить, что на monthly триал тоже настроен (текущий UI обещает его).
5. Цена: annual заметно ниже 12× monthly (целевой бейдж экономии 20–40%); проверить региональные price points ключевых рынков (RU/DE/ES/FR/PT/CN).
6. Локализации продукта (display name) на те же 7 языков.

---

## Fix 1 — ProductID

**Файл:** `Momsy/Features/Subscription/Domain/ProductID.swift` — полная замена:

```swift
enum ProductID {
    static let monthly = "com.ruslanabdulov.momsy.premium.monthly"
    static let annual = "com.ruslanabdulov.momsy.premium.annual"

    static let all = [
        monthly,
        annual
    ]
}
```

---

## Fix 2 — SubscriptionManager: мультипродукт

**Файл:** `Momsy/Features/Subscription/Domain/SubscriptionManager.swift` — полная замена:

```swift
import Combine
import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var isPremium = false
    @Published private(set) var isLoading = false
    @Published private(set) var products: [Product] = []
    @Published private(set) var trialEligible = false
    @Published var selectedProductID = ProductID.annual

    var canPurchase: Bool { selectedProduct != nil }

    var selectedProduct: Product? { products.first { $0.id == selectedProductID } }
    var monthlyProduct: Product? { products.first { $0.id == ProductID.monthly } }
    var annualProduct: Product? { products.first { $0.id == ProductID.annual } }

    var savingsPercent: Int? {
        guard let monthly = monthlyProduct?.price,
              let annual = annualProduct?.price else { return nil }
        return Self.savingsPercent(monthlyPrice: monthly, annualPrice: annual)
    }

    private let service: any SubscriptionServicing
    private var listenerTask: Task<Void, Never>?
    private var productLoadTask: Task<[Product], Error>?

    init(service: any SubscriptionServicing) {
        self.service = service
        listenerTask = Task {
            _ = try? await loadProductsIfNeeded()
            await updateStatus()
            for await result in Transaction.updates {
                guard case .verified(let tx) = result else { continue }
                await updateStatus()
                await tx.finish()
            }
        }
    }

    deinit {
        listenerTask?.cancel()
    }

    func purchase() async throws -> Bool {
        guard !isLoading else { return false }
        isLoading = true
        defer { isLoading = false }

        let loaded = try await loadProductsIfNeeded()
        guard let product = loaded.first(where: { $0.id == selectedProductID }) else {
            throw SubscriptionError.productUnavailable
        }
        let result = try await service.purchase(product)
        switch result {
        case .success(let verification):
            let tx = try verified(verification)
            let grantsPremium = Self.grantsPremium(productID: tx.productID)
                && tx.revocationDate == nil
            if grantsPremium {
                isPremium = true
            }
            await tx.finish()
            await updateStatus()
            return grantsPremium
        case .pending, .userCancelled:
            return false
        @unknown default:
            return false
        }
    }

    func restore() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        try? await service.restorePurchases()
        await updateStatus()
    }

    /// Any product in the app's catalog grants premium.
    nonisolated static func grantsPremium(productID: String) -> Bool {
        ProductID.all.contains(productID)
    }

    /// Percentage saved on annual vs paying monthly for a year. Nil when annual
    /// isn't cheaper or inputs are invalid.
    nonisolated static func savingsPercent(monthlyPrice: Decimal, annualPrice: Decimal) -> Int? {
        guard monthlyPrice > 0, annualPrice > 0 else { return nil }
        let yearAtMonthly = monthlyPrice * 12
        guard annualPrice < yearAtMonthly else { return nil }
        let fraction = (yearAtMonthly - annualPrice) / yearAtMonthly
        let percent = NSDecimalNumber(decimal: fraction * 100).intValue
        return percent > 0 ? percent : nil
    }

    @discardableResult
    private func loadProductsIfNeeded() async throws -> [Product] {
        if !products.isEmpty { return products }
        if let productLoadTask {
            let loaded = try await productLoadTask.value
            await adopt(loaded)
            return loaded
        }

        let service = service
        let task = Task<[Product], Error> {
            let fetched = try await service.fetchProducts(ids: ProductID.all)
            guard !fetched.isEmpty else { throw SubscriptionError.productUnavailable }
            return fetched
        }
        productLoadTask = task
        defer { productLoadTask = nil }

        let loaded = try await task.value
        await adopt(loaded)
        return loaded
    }

    private func adopt(_ loaded: [Product]) async {
        products = loaded
        if let subscription = loaded.first?.subscription {
            trialEligible = await subscription.isEligibleForIntroOffer
        }
    }

    private func updateStatus() async {
        var hasSub = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               Self.grantsPremium(productID: tx.productID),
               tx.revocationDate == nil {
                hasSub = true
            }
        }
        isPremium = hasSub
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw SubscriptionError.failedVerification
        case .verified(let v): return v
        }
    }
}

enum SubscriptionError: Error {
    case failedVerification
    case productUnavailable
}
```

Заметки:
- `monthlyPrice` / `subscriptionName` / `product` удалены — единственный потребитель `PaywallView` переписывается ниже. Перед пушем: `grep -rn "monthlyPrice\|subscriptionName" --include="*.swift" Momsy/` должен вернуть только PaywallView до замены.
- `trialEligible` — реальная eligibility из StoreKit (одна subscription group ⇒ одна проверка), а не факт наличия оффера в конфиге: вернувшийся пользователь, потративший триал, не увидит ложное «7 дней бесплатно».
- Гейт `MomsyApp.swift:206` (`container.subscriptionManager.isPremium`) и wiring `AppContainer.swift:79` не меняются.

---

## Fix 3 — L10n: новые ключи

**Файл:** `Momsy/Core/Localization/L10n.swift` — вставить после `paywallMonthlyPeriod` (строка 1375, перед `trialBadge`):

```swift
    var paywallAnnualPeriod: String { s("12 months",
                                        "12 месяцев",
                                        "12 Monate",
                                        "12 meses",
                                        "12 mois",
                                        "12 meses",
                                        "12个月") }
    var paywallPlanMonthly: String { s("Monthly",
                                       "Ежемесячно",
                                       "Monatlich",
                                       "Mensual",
                                       "Mensuel",
                                       "Mensal",
                                       "按月") }
    var paywallPlanAnnual: String { s("Annual",
                                      "Ежегодно",
                                      "Jährlich",
                                      "Anual",
                                      "Annuel",
                                      "Anual",
                                      "按年") }
    func paywallSavePercent(_ percent: Int) -> String {
        s("Save \(percent)%",
          "Выгода \(percent)%",
          "\(percent) % sparen",
          "Ahorra \(percent) %",
          "Économisez \(percent) %",
          "Poupe \(percent) %",
          "省 \(percent)%")
    }
    var subscribeCTA: String { s("Subscribe",
                                 "Оформить подписку",
                                 "Abonnieren",
                                 "Suscribirse",
                                 "S’abonner",
                                 "Subscrever",
                                 "订阅") }
```

Вставить после существующей `paywallRenewalDisclosure(price:)` (после строки 1406):

```swift
    func paywallRenewalDisclosureAnnual(price: String) -> String {
        s("7 days free, then \(price)/year. Subscription renews automatically every year unless canceled at least 24 hours before the period ends.",
          "7 дней бесплатно, затем \(price)/год. Подписка автоматически продлевается каждый год, если не отменить её минимум за 24 часа до конца периода.",
          "7 Tage gratis, danach \(price)/Jahr. Das Abo verlängert sich jedes Jahr automatisch, sofern es nicht mindestens 24 Stunden vor Periodenende gekündigt wird.",
          "7 días gratis, luego \(price)/año. La suscripción se renueva automáticamente cada año salvo que se cancele al menos 24 horas antes de que termine el periodo.",
          "7 jours gratuits, puis \(price)/an. L'abonnement se renouvelle automatiquement chaque année sauf annulation au moins 24 heures avant la fin de la période.",
          "7 dias grátis, depois \(price)/ano. A subscrição renova automaticamente todos os anos, salvo cancelamento pelo menos 24 horas antes do fim do período.",
          "7 天免费，之后 \(price)/年。订阅每年自动续订，除非在当前周期结束前至少 24 小时取消。")
    }
    func paywallRenewalDisclosureMonthlyNoTrial(price: String) -> String {
        s("\(price)/month. Subscription renews automatically every month unless canceled at least 24 hours before the period ends.",
          "\(price)/мес. Подписка автоматически продлевается каждый месяц, если не отменить её минимум за 24 часа до конца периода.",
          "\(price)/Monat. Das Abo verlängert sich jeden Monat automatisch, sofern es nicht mindestens 24 Stunden vor Periodenende gekündigt wird.",
          "\(price)/mes. La suscripción se renueva automáticamente cada mes salvo que se cancele al menos 24 horas antes de que termine el periodo.",
          "\(price)/mois. L'abonnement se renouvelle automatiquement chaque mois sauf annulation au moins 24 heures avant la fin de la période.",
          "\(price)/mês. A subscrição renova automaticamente todos os meses, salvo cancelamento pelo menos 24 horas antes do fim do período.",
          "\(price)/月。订阅每月自动续订，除非在当前周期结束前至少 24 小时取消。")
    }
    func paywallRenewalDisclosureAnnualNoTrial(price: String) -> String {
        s("\(price)/year. Subscription renews automatically every year unless canceled at least 24 hours before the period ends.",
          "\(price)/год. Подписка автоматически продлевается каждый год, если не отменить её минимум за 24 часа до конца периода.",
          "\(price)/Jahr. Das Abo verlängert sich jedes Jahr automatisch, sofern es nicht mindestens 24 Stunden vor Periodenende gekündigt wird.",
          "\(price)/año. La suscripción se renueva automáticamente cada año salvo que se cancele al menos 24 horas antes de que termine el periodo.",
          "\(price)/an. L'abonnement se renouvelle automatiquement chaque année sauf annulation au moins 24 heures avant la fin de la période.",
          "\(price)/ano. A subscrição renova automaticamente todos os anos, salvo cancelamento pelo menos 24 horas antes do fim do período.",
          "\(price)/年。订阅每年自动续订，除非在当前周期结束前至少 24 小时取消。")
    }
```

---

## Fix 4 — PaywallView: селектор планов

**Файл:** `Momsy/Features/Subscription/Presentation/PaywallView.swift` — полная замена:

```swift
import SwiftUI
import StoreKit

struct PaywallView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    let onComplete: () -> Void

    @EnvironmentObject private var loc: LocalizationManager
    @State private var errorMessage: String?

    private var lm: L10n { loc.strings }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.bbLilacDeep, Color.bbRoseDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        skipButton
                        Spacer(minLength: 12)
                        heroSection
                        Spacer().frame(height: 24)
                        featureList
                        Spacer().frame(height: 18)
                        planSelector
                        Spacer(minLength: 16)
                        ctaSection
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: proxy.size.height)
                }
            }
        }
        .alert(isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Alert(
                title: Text(lm.purchaseErrorTitle),
                message: Text(errorMessage ?? ""),
                dismissButton: .default(Text(lm.done))
            )
        }
    }

    // MARK: — Sections

    private var skipButton: some View {
        HStack {
            Spacer()
            Button(action: onComplete) {
                Text(lm.mayBeLater)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
            }
        }
        .padding(.top, 12)
    }

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(systemName: "star.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }

            Text(subscriptionNameText)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            if subscriptionManager.trialEligible {
                Text(lm.trialBadge)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.bbLilacDeep)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.95))
                    .clipShape(Capsule())
            }
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 18) {
            featureRow(icon: "infinity", text: lm.featureAll)
            featureRow(icon: "person.2.fill", text: lm.featureSync)
            featureRow(icon: "book.fill", text: lm.featureDiary)
        }
        .padding(.horizontal, 40)
    }

    private var planSelector: some View {
        VStack(spacing: 10) {
            if let annual = subscriptionManager.annualProduct {
                planCard(
                    product: annual,
                    title: lm.paywallPlanAnnual,
                    period: lm.paywallAnnualPeriod,
                    badge: subscriptionManager.savingsPercent.map(lm.paywallSavePercent)
                )
            }
            if let monthly = subscriptionManager.monthlyProduct {
                planCard(
                    product: monthly,
                    title: lm.paywallPlanMonthly,
                    period: lm.paywallMonthlyPeriod,
                    badge: nil
                )
            }
        }
        .padding(.horizontal, 24)
    }

    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    do {
                        let purchaseSucceeded = try await subscriptionManager.purchase()
                        if purchaseSucceeded { onComplete() }
                    } catch {
                        errorMessage = localizedPurchaseError(error)
                    }
                }
            } label: {
                ZStack {
                    if subscriptionManager.isLoading {
                        ProgressView().tint(.bbLilacDeep)
                    } else {
                        Text(subscriptionManager.trialEligible ? lm.startTrial : lm.subscribeCTA)
                            .font(.headline)
                            .foregroundColor(.bbLilacDeep)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(subscriptionManager.isLoading || !subscriptionManager.canPurchase)
            .padding(.horizontal, 24)

            Text(renewalDisclosureText)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            legalLinks

            Button {
                Task {
                    await subscriptionManager.restore()
                    if subscriptionManager.isPremium { onComplete() }
                }
            } label: {
                Text(lm.restorePurchases)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
                    .underline()
            }
        }
        .padding(.bottom, 44)
    }

    private var renewalDisclosureText: String {
        guard let product = subscriptionManager.selectedProduct else {
            return lm.paywallPriceLoadingDisclosure
        }
        let price = product.displayPrice
        let isAnnual = product.id == ProductID.annual
        if subscriptionManager.trialEligible {
            return isAnnual
                ? lm.paywallRenewalDisclosureAnnual(price: price)
                : lm.paywallRenewalDisclosure(price: price)
        }
        return isAnnual
            ? lm.paywallRenewalDisclosureAnnualNoTrial(price: price)
            : lm.paywallRenewalDisclosureMonthlyNoTrial(price: price)
    }

    private var subscriptionNameText: String {
        let name = subscriptionManager.selectedProduct?.displayName ?? ""
        return name.isEmpty ? lm.paywallPlanFallbackName : name
    }

    private var legalLinks: some View {
        HStack(spacing: 18) {
            if let termsOfUseURL = AppLegalLinks.termsOfUseURL {
                Link(destination: termsOfUseURL) {
                    Text(lm.termsOfUseEULA)
                        .underline()
                }
            }

            if let privacyPolicyURL = AppLegalLinks.privacyPolicyURL {
                Link(destination: privacyPolicyURL) {
                    Text(lm.privacyPolicy)
                        .underline()
                }
            }
        }
        .font(.caption.weight(.semibold))
        .foregroundColor(.white.opacity(0.8))
    }

    // MARK: — Helpers

    private func planCard(product: Product, title: String, period: String, badge: String?) -> some View {
        let isSelected = subscriptionManager.selectedProductID == product.id
        return Button {
            subscriptionManager.selectedProductID = product.id
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.white)
                        if let badge {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.bbLilacDeep)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.95))
                                .clipShape(Capsule())
                        }
                    }
                    Text(period)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer(minLength: 12)

                Text(product.displayPrice)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(isSelected ? 0.22 : 0.10))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(isSelected ? 0.9 : 0.22), lineWidth: isSelected ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func localizedPurchaseError(_ error: Error) -> String {
        switch error {
        case SubscriptionError.failedVerification: return lm.purchaseVerificationFailed
        case SubscriptionError.productUnavailable:  return lm.purchaseProductUnavailable
        default:                                    return lm.purchaseProductUnavailable
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}
```

Guideline 3.1.2 сохранена: имя и период плана — в карточках, цена — в карточке и в disclosure, Terms/Privacy — `legalLinks`, авто-продление — disclosure. `planRow`/`planSummary`/строки `paywallSubscriptionNameLabel|PeriodLabel|PriceLabel` больше не используются на пейволле — L10n-ключи не удалять (обратная совместимость не требуется, но чистку ключей делаем отдельной задачей, не здесь).

---

## Fix 5 — StoreKit configuration (локальное тестирование)

Если в проекте есть `.storekit` конфиг — добавить annual продукт с теми же параметрами (ID, 1 year, 7-day free trial, цена). Если конфига нет — пропустить, тестировать через sandbox.

---

## Тесты

**Файл:** `MomsyTests/Features/Subscription/SubscriptionManagerLogicTests.swift` (новый):

```swift
import Testing
@testable import Momsy

struct SubscriptionManagerLogicTests {
    @Test func monthlyGrantsPremium() {
        #expect(SubscriptionManager.grantsPremium(productID: ProductID.monthly))
    }

    @Test func annualGrantsPremium() {
        #expect(SubscriptionManager.grantsPremium(productID: ProductID.annual))
    }

    @Test func unknownProductDoesNotGrantPremium() {
        #expect(!SubscriptionManager.grantsPremium(productID: "com.other.product"))
    }

    @Test func savingsPercentTypicalCase() {
        // 4.99 * 12 = 59.88; annual 39.99 → ~33%
        let percent = SubscriptionManager.savingsPercent(monthlyPrice: 4.99, annualPrice: 39.99)
        #expect(percent == 33)
    }

    @Test func savingsNilWhenAnnualNotCheaper() {
        #expect(SubscriptionManager.savingsPercent(monthlyPrice: 4.99, annualPrice: 59.88) == nil)
        #expect(SubscriptionManager.savingsPercent(monthlyPrice: 4.99, annualPrice: 70.00) == nil)
    }

    @Test func savingsNilForInvalidInputs() {
        #expect(SubscriptionManager.savingsPercent(monthlyPrice: 0, annualPrice: 39.99) == nil)
        #expect(SubscriptionManager.savingsPercent(monthlyPrice: 4.99, annualPrice: 0) == nil)
    }
}
```

---

## Definition of Done

- [ ] ASC: annual продукт создан в той же группе, уровень выше monthly, 7-day trial, цены проверены по регионам
- [ ] `ProductID.all` содержит оба продукта
- [ ] `SubscriptionManager`: entitlement через `grantsPremium(productID:)`, покупка выбранного плана, `trialEligible` из StoreKit
- [ ] Пейволл: annual предвыбран, бейдж экономии виден при загруженных ценах, CTA/бейдж/дисклеймер меняются по `trialEligible` и выбранному плану
- [ ] Новые L10n-ключи присутствуют на всех 7 языках в одном коммите
- [ ] `grep -rn "monthlyPrice\|subscriptionName" --include="*.swift" Momsy/` — пусто
- [ ] `SubscriptionManagerLogicTests` зелёные
- [ ] Проект собирается для Momsy, MomsyWatch, MomsyWidget (пейволл не используется в Watch/Widget — регрессий быть не должно, но сборку проверить)

## Manual QA (sandbox)

1. Чистая установка → пейволл: annual предвыбран, две карточки, бейдж «Выгода N%», CTA «Начать бесплатно…», дисклеймер с «/год».
2. Переключение на monthly → цена/период/дисклеймер меняются на месячные.
3. Покупка annual → `isPremium == true`, WeeklyInsights генерируется, повторный запуск сохраняет премиум.
4. Sandbox-аккаунт с потраченным триалом → бейдж триала скрыт, CTA «Оформить подписку», дисклеймер без «7 дней бесплатно».
5. Upgrade monthly → annual через пейволл: StoreKit показывает диалог апгрейда, после — entitlement остаётся активным.
6. Restore на втором устройстве с annual — премиум восстанавливается.
7. Каждый из 7 языков: карточки, бейдж, дисклеймер без обрезаний на iPhone SE.
