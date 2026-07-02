# CLI Task: Paywall App Store Compliance

**Severity:** P0 for submission (Guideline 3.1.2 auto-reject)
**Scope:** `PaywallView.swift`, `SubscriptionManager.swift`, `L10n.swift`. SwiftUI only, async/await, existing DI.
**Preserve:** Clean Architecture layering, existing 7-language `s(...)` L10n pattern, existing gradient/CTA visual design.

---

## Problems

1. **P0 — Missing legal links (Guideline 3.1.2).** `PaywallView` shows an auto-renewing subscription CTA but no Terms of Use (EULA) or Privacy Policy links. Apple rejects auto-renewable subscription paywalls without both, functional, on the purchase screen. The URLs already exist in `SettingsView.swift` (`privacyPolicyURL`, `termsOfUseURL`) — reuse them; do not invent new ones.

2. **P0 — Hardcoded price copy.** `L10n.paywallPriceNote` hardcodes "Then $4.99/month", "299 ₽", "4,99 €". This mismatches the real StoreKit storefront price (differs per region and per Apple's price tiers) and contradicts the product's own pricing. Apple also rejects misrepresented pricing. Use `product.displayPrice` from the already-loaded `Product`.

3. **P1 — Non-localized purchase errors.** `SubscriptionError.errorDescription` returns English-only strings shown in the paywall's error alert, while the app ships 7 locales. Move copy into `L10n`.

---

### Task 1: Localize `SubscriptionError`

`SubscriptionError` is a plain `LocalizedError` in `SubscriptionManager.swift` with no access to `L10n` (which is instantiated per-language via `LocalizationManager`). Rather than inject a localizer into the error, expose the *keys* and let the view resolve them. Simplest correct approach: give `SubscriptionError` a stable `case`, and have the paywall map it to a localized string.

**Files:**
- Modify: `Momsy/Core/Localization/L10n.swift` (add two strings near existing paywall strings, ~line 1137)
- Modify: `Momsy/Features/Subscription/Domain/SubscriptionManager.swift` (drop hardcoded English `errorDescription`)

- [ ] **Step 1: Add localized strings to `L10n.swift`**

Insert immediately after the `featureDiary` computed property (which ends `"无限日记与统计") }`):

```swift
    var purchaseVerificationFailed: String {
        s("Couldn’t verify the purchase. Please try again.",
          "Не удалось подтвердить покупку. Попробуйте ещё раз.",
          "Kauf konnte nicht verifiziert werden. Bitte erneut versuchen.",
          "No se pudo verificar la compra. Inténtalo de nuevo.",
          "Impossible de vérifier l’achat. Veuillez réessayer.",
          "Não foi possível verificar a compra. Tente novamente.",
          "无法验证购买，请重试。")
    }
    var purchaseProductUnavailable: String {
        s("Subscription isn’t available right now. Check your connection and try again.",
          "Подписка сейчас недоступна. Проверьте соединение и попробуйте ещё раз.",
          "Abo derzeit nicht verfügbar. Prüfe deine Verbindung und versuche es erneut.",
          "La suscripción no está disponible ahora. Revisa tu conexión e inténtalo de nuevo.",
          "L’abonnement n’est pas disponible pour le moment. Vérifiez votre connexion et réessayez.",
          "A subscrição não está disponível de momento. Verifique a ligação e tente novamente.",
          "订阅当前不可用，请检查网络后重试。")
    }
```

- [ ] **Step 2: Make `SubscriptionError` carry no user copy**

In `SubscriptionManager.swift`, replace the whole `enum SubscriptionError` block:

Find:

```swift
enum SubscriptionError: LocalizedError {
    case failedVerification
    case productUnavailable

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Could not verify the purchase. Please try again."
        case .productUnavailable:
            return "Subscription is not available yet. Please check your connection and try again."
        }
    }
}
```

Replace with:

```swift
enum SubscriptionError: Error {
    case failedVerification
    case productUnavailable
}
```

(The view now owns the localized copy; the error stays a pure domain type. Other `catch` sites that relied on `error.localizedDescription` for a `SubscriptionError` are updated in Task 3.)

- [ ] **Step 3: Build**

Run: `xcodebuild -scheme Momsy -destination 'generic/platform=iOS' build` (or ⌘B in Xcode)
Expected: builds. If any other file switched on `SubscriptionError.errorDescription`, grep for it (`grep -rn "SubscriptionError" Momsy`) and route it through the new `L10n` strings the same way as Task 3.

---

### Task 2: Expose a dynamic price string on `SubscriptionManager`

`SubscriptionManager` already loads and publishes `@Published private(set) var product: Product?`. Surface a display-ready price note derived from it, so the view has no pricing logic.

**Files:**
- Modify: `Momsy/Features/Subscription/Domain/SubscriptionManager.swift`

- [ ] **Step 1: Add a computed price-note helper**

Add this method to `SubscriptionManager` (below `restore()`), which formats the localized note from the live product and falls back to a neutral, price-free string when the product hasn't loaded:

```swift
    /// Localized price note built from the live StoreKit product. Falls back to a
    /// price-free string while the product is still loading (never show a stale/
    /// hardcoded price). `loc` is passed in so the domain layer stays UI-agnostic.
    func priceNote(_ loc: L10n) -> String {
        guard let product else { return loc.paywallPriceLoading }
        // e.g. "Then $2.99/month · Cancel anytime" — price from the storefront.
        return loc.paywallPriceNoteFormatted(product.displayPrice)
    }
```

- [ ] **Step 2: Add the two supporting L10n strings**

In `L10n.swift`, replace the existing `paywallPriceNote` property:

Find:

```swift
    var paywallPriceNote: String   { s("Then $4.99/month · Cancel anytime",
                                       "Затем 299 ₽/мес · Отменить в любое время",
                                       "Dann 4,99 €/Monat · Jederzeit kündbar",
                                       "Luego 4,99 $/mes · Cancela cuando quieras",
                                       "Puis 4,99 €/mois · Annulable à tout moment",
                                       "Depois 4,99 €/mês · Cancele quando quiser",
                                       "之后 ¥35/月 · 随时取消") }
```

Replace with:

```swift
    func paywallPriceNoteFormatted(_ price: String) -> String {
        s("Then \(price)/month · Cancel anytime",
          "Затем \(price)/мес · Отменить в любое время",
          "Dann \(price)/Monat · Jederzeit kündbar",
          "Luego \(price)/mes · Cancela cuando quieras",
          "Puis \(price)/mois · Annulable à tout moment",
          "Depois \(price)/mês · Cancele quando quiser",
          "之后 \(price)/月 · 随时取消")
    }
    var paywallPriceLoading: String {
        s("7-day free trial, then a monthly subscription · Cancel anytime",
          "7 дней бесплатно, затем ежемесячная подписка · Отмена в любое время",
          "7 Tage gratis, danach monatliches Abo · Jederzeit kündbar",
          "7 días gratis, luego suscripción mensual · Cancela cuando quieras",
          "7 jours gratuits, puis abonnement mensuel · Annulable à tout moment",
          "7 dias grátis, depois subscrição mensal · Cancele quando quiser",
          "7 天免费试用，之后按月订阅 · 随时取消")
    }
```

> `product.displayPrice` is already locale/currency-formatted by StoreKit (e.g. `$2.99`, `299,00 ₽`), so string-interpolating it is correct — do not re-format it.

- [ ] **Step 3: Build**

Run: ⌘B. Expected: builds clean.

---

### Task 3: Add legal links + dynamic price to `PaywallView`

**Files:**
- Modify: `Momsy/Features/Subscription/Presentation/Views/PaywallView.swift`

- [ ] **Step 1: Add openURL + reuse the existing legal URLs**

At the top of `PaywallView`, after the existing `@State private var errorMessage: String?`, add:

```swift
    @Environment(\.openURL) private var openURL

    // Reuse the exact URLs already used in SettingsView — single source of truth.
    private let privacyPolicyURL = URL(string: "https://momsy.app/privacy")
    private let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
```

- [ ] **Step 2: Localize the purchase error via the new mapping**

In the `ctaSection` purchase `Task`, replace:

```swift
                    } catch {
                        errorMessage = error.localizedDescription
                    }
```

with:

```swift
                    } catch {
                        errorMessage = localizedPurchaseError(error)
                    }
```

Then add this helper in the `// MARK: — Helpers` section (next to `featureRow`):

```swift
    private func localizedPurchaseError(_ error: Error) -> String {
        switch error {
        case SubscriptionError.failedVerification: return lm.purchaseVerificationFailed
        case SubscriptionError.productUnavailable:  return lm.purchaseProductUnavailable
        default:                                    return lm.purchaseProductUnavailable
        }
    }
```

- [ ] **Step 3: Use the dynamic price note**

In `ctaSection`, replace:

```swift
            Text(lm.paywallPriceNote)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
```

with:

```swift
            Text(subscriptionManager.priceNote(lm))
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
```

- [ ] **Step 4: Add the legal links row**

Still in `ctaSection`, immediately AFTER the existing "Restore Purchases" `Button { … }` closure and BEFORE the closing of the `VStack(spacing: 12)`, insert:

```swift
            legalLinks
```

Then add this computed view in the `// MARK: — Sections` block (after `ctaSection`):

```swift
    private var legalLinks: some View {
        HStack(spacing: 6) {
            Button(lm.termsOfUse) {
                if let termsOfUseURL { openURL(termsOfUseURL) }
            }
            Text("·")
            Button(lm.privacyPolicy) {
                if let privacyPolicyURL { openURL(privacyPolicyURL) }
            }
        }
        .font(.caption2)
        .foregroundColor(.white.opacity(0.55))
        .padding(.top, 2)
    }
```

(`lm.termsOfUse` and `lm.privacyPolicy` already exist in `L10n.swift`.)

- [ ] **Step 5: Build**

Run: ⌘B. Expected: builds clean; no remaining reference to `lm.paywallPriceNote`.

---

## Definition of Done

- [ ] Paywall shows tappable Terms of Use + Privacy Policy links that open the same URLs as Settings.
- [ ] Price note reads from `product.displayPrice`; no hardcoded currency amounts remain anywhere (`grep -rn "4.99\|4,99\|299 ₽\|¥35" Momsy` returns nothing in Subscription/L10n paywall code).
- [ ] Purchase-error alert text is localized in all 7 languages.
- [ ] `SubscriptionError` is a plain `Error` with no user-facing copy.
- [ ] No new networking, no new dependencies, DI unchanged.

## Manual QA

1. Open the paywall. Confirm Terms and Privacy links appear and open in-browser (or the EULA sheet).
2. With StoreKit configured (StoreKit config file or sandbox), confirm the price note shows the real product price (e.g. `Then $2.99/month · Cancel anytime`), NOT `$4.99`.
3. Kill network before loading the paywall → price note shows the price-free fallback, not a stale price; tapping the CTA surfaces the localized "not available" alert.
4. Switch device language to RU / DE / ZH → paywall price note and error alert are translated.

## Out of Scope (file separately)

- **StoreKit product catalog:** only `premium.monthly` exists. Yearly + lifetime SKUs from the pricing plan are missing; add products + a plan selector in a follow-up.
- **Firebase App Check** and **family-scoped Storage paths for co-parent photos** are tracked separately.
