# TASK: Rate Us — активация и скрытие мёртвой кнопки

**Приоритет:** P3 (polish, pre-release)
**Оценка:** S (~15 минут + 1 значение из App Store Connect)
**Не пересекается** с TASK_ANNUAL_SUBSCRIPTION.md (другие файлы, кроме отсутствия общих правок).

## Контекст (проверено по клону, commit `cfde6a5`)

Rate Us **уже реализован**:
- `Momsy/Features/Settings/Presentation/Views/SettingsView.swift:358-361` — кнопка со `star.fill` в `aboutSection`, экшен `openRateApp()`.
- `Momsy/Core/Localization/L10n.swift:930` — `rateApp` локализован на 7 языков.
- `Momsy/Core/AppLegalLinks.swift` — `appStoreReviewURL` строится из `appStoreID`.

Проблема: `appStoreID = ""` → `appStoreReviewURL == nil` → `openRateApp()` делает `guard ... return`, тап по видимой кнопке молча ничего не делает.

## Root cause

`Momsy/Core/AppLegalLinks.swift:9-15`:

```swift
    // TODO: заполнить после создания записи в App Store Connect
    static let appStoreID = ""

    static var appStoreReviewURL: URL? {
        guard !appStoreID.isEmpty else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review")
    }
```

Кнопка в `SettingsView` рендерится безусловно (строки 358-361), а обработчик (строки 415-417 области `openRateApp`) молча выходит при nil.

## Fix 1 — заполнить App Store ID

**Файл:** `Momsy/Core/AppLegalLinks.swift`

App Store Connect → My Apps → Momsy → App Information → General Information → **Apple ID** (числовой, например `6743012345`). Запись в ASC создаётся до сабмита, ID доступен сразу после создания записи — релиз не требуется.

До:
```swift
    // TODO: заполнить после создания записи в App Store Connect
    static let appStoreID = ""
```

После (подставить реальный ID):
```swift
    static let appStoreID = "XXXXXXXXXX"
```

## Fix 2 — скрыть кнопку при nil URL (защита от регрессии)

Даже с заполненным ID оставляем защиту: если ID когда-либо обнулится, кнопка исчезает вместо мёртвого тапа.

**Файл:** `Momsy/Features/Settings/Presentation/Views/SettingsView.swift`

До (строки 357-362):
```swift
                Divider().opacity(0.2).padding(.leading, 60)
                Button(action: openRateApp) {
                    chevronRow(icon: "star.fill",        bg: .bbButter, title: lm.strings.rateApp)
                }
                .buttonStyle(.plain)
```

После:
```swift
                if AppLegalLinks.appStoreReviewURL != nil {
                    Divider().opacity(0.2).padding(.leading, 60)
                    Button(action: openRateApp) {
                        chevronRow(icon: "star.fill",        bg: .bbButter, title: lm.strings.rateApp)
                    }
                    .buttonStyle(.plain)
                }
```

## Тесты

`MomsyTests/Core/AppLegalLinksTests.swift` (новый файл):

```swift
import Testing
@testable import Momsy

struct AppLegalLinksTests {
    @Test func reviewURLIsPresentAndWellFormed() {
        let url = AppLegalLinks.appStoreReviewURL
        #expect(url != nil)
        let s = url?.absoluteString ?? ""
        #expect(s.hasPrefix("https://apps.apple.com/app/id"))
        #expect(s.hasSuffix("action=write-review"))
        #expect(!AppLegalLinks.appStoreID.isEmpty)
        #expect(AppLegalLinks.appStoreID.allSatisfy(\.isNumber))
    }
}
```

Тест дополнительно защищает от релиза с пустым/нечисловым ID.

## Definition of Done

- [ ] `appStoreID` заполнен реальным Apple ID из ASC
- [ ] Кнопка Rate скрыта, когда `appStoreReviewURL == nil`
- [ ] `AppLegalLinksTests` зелёный
- [ ] Тап по кнопке на устройстве открывает App Store на форме отзыва
- [ ] Ничего не изменено в остальных секциях `SettingsView`
