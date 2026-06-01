# MEMORY.md — Momsy Project Context

> Этот файл — живая память проекта. Обновлять при каждом значимом решении.
> Claude читает его в начале каждой сессии перед генерацией кода.

---

## 1. Проект

| Параметр | Значение |
|---|---|
| Название | Momsy |
| Тип | AI-powered baby care assistant |
| Платформа | iOS (SwiftUI only) |
| Язык | Swift |
| Min deployment | iOS 16+ |
| Архитектура | Clean Architecture + MVVM |
| Состояние | В активной разработке |

---

## 2. Пользователь

Мамы (и папы) с детьми от 0 до 2+ лет. Основной язык интерфейса — **русский**. Локализация поддерживает: `ru`, `en`, `de` (будущее: `tr`, `ar`, `pt`, `es`, `fr`).

---

## 3. Текущая структура приложения

### Экраны (реализованы)

| Экран | Файл | Статус |
|---|---|---|
| Онбординг | `OnboardingView.swift` | ✅ Готов |
| Главный экран (Today) | `TodayView.swift` | ✅ Готов |
| Кормление (таймер) | `FeedingView.swift` | ✅ Готов |
| Скачки развития | `LeapsView.swift` | ✅ Готов |
| Белый шум | `WhiteNoiseView.swift` | ✅ Готов |
| Симптомы | `SymptomView.swift` | ✅ Готов |
| Рост / замеры | `GrowthView.swift` | ✅ Готов |
| AI Чат | `AIChatView.swift` | ✅ Готов |
| Настройки | `SettingsView.swift` | ✅ Готов |
| Шаринг / инвайт | `SharingView.swift` | ✅ Готов |

### Компоненты (Core)

| Файл | Содержимое |
|---|---|
| `DesignSystem.swift` | Цвета, `bbCard`, `BBPill`, `BBSectionLabel`, `BBChipRow`, `BBToggleRow`, shadow-модификаторы |
| `CuteBlobView.swift` | Иконки-блобы: `.baby`, `.sleep`, `.bottle`, `.moon`, `.sun`, `.drop`, `.star`, `.heart`, `.cloud`, `.bear` |
| `Models.swift` | `BabyAgeStage`, `FeedingSide`, `DevelopmentLeap`, `FamilyMember`, `SoundItem`, `WeightPoint`, `MeasurementEntry`, `sampleLeaps`, `sampleSounds`, `sampleWeightData` |

---

## 4. Design System

### Цветовая палитра

```
bbCream      #FFF6EC   — фон приложения
bbCreamSoft  #FFFAF2   — мягкий фон карточек
bbCard       white     — карточки
bbInk        #3D2A20   — основной текст
bbInkSoft    #6B5446   — вторичный текст
bbInkMute    #A89484   — подсказки, метки

bbCoral      #FFB39E   — кормление (primary)
bbCoralDeep  #F08A6E   — акцент кормления, CTA
bbMint       #A8DDCB   — сон, прогресс
bbMintDeep   #5FB99B   — акцент сна
bbButter     #FFE0A3   — AI-подсказки, leaps
bbButterDeep #F2B85C   — акцент butter
bbLilac      #D5C4F0   — скачки, роль/онбординг
bbLilacDeep  #9F82D8   — акцент lilac
bbSky        #BBDDF0   — подгузники, данные
bbSkyDeep    #6FA8CE   — акцент sky
bbRose       #F8C9D6   — симптомы, новорождённый
bbRoseDeep   #E089A3   — акцент rose
```

### Ключевые UI-паттерны

```swift
.bbCard(pad: 14)                     // стандартная карточка
.bbCard(pad: 14, bg: .bbCreamSoft)   // мягкий фон
.bbShadow()                          // тень карточки
.bbShadowSoft()                      // мягкая тень
BBPill(text:, color:, fg:, size:)    // бейдж-пилюля
BBSectionLabel(text:)                // заголовок секции
CuteBlobView(kind:, size:, tone:)    // иконка
```

### Типографика

Шрифт: `.system(..., design: .rounded)`

| Роль | Размер | Вес |
|---|---|---|
| Заголовок H1 | 28–32 | `.heavy` |
| Заголовок H2 | 18–22 | `.heavy` |
| Подзаголовок | 14–15 | `.bold` |
| Тело | 13–14 | `.semibold` / `.medium` |
| Метка | 11–12 | `.bold` |
| Monospaced (таймер) | любой | `.monospaced` + `.heavy` |

---

## 5. Данные — AppStorage ключи

| Ключ | Тип | Описание |
|---|---|---|
| `babyName` | `String` | Имя ребёнка |
| `babyBirthDate` | `Double` | `timeIntervalSince1970` |
| `babyStage` | `String` | `BabyAgeStage.rawValue` |
| `parentRole` | `String` | `"mom"` / `"dad"` / `"nanny"` / `"other"` |
| `parentName` | `String` | Имя родителя |
| `hasCompletedOnboarding` | `Bool` | Флаг онбординга |

---

## 6. Модели данных

### BabyAgeStage
```
.newborn  → 0–3 мес   | blob: .sleep  | tone: .bbRose
.baby     → 3–6 мес   | blob: .baby   | tone: .bbButter
.eat      → 6–12 мес  | blob: .bottle | tone: .bbMint
.toddler  → 1–2 года  | blob: .bear   | tone: .bbLilac
.kid      → 2+        | blob: .star   | tone: .bbSky
```

### LogEntry (TodayView)
```swift
struct LogEntry: Identifiable {
    let id: UUID
    let time: Date
    let kind: BlobKind
    let tone: Color
    let label: String
}
```

### TodayViewModel — ключевые свойства
```
isFeedingActive: Bool
feedingSeconds: Int
feedingSide: FeedingSide
diaperCount: Int
logEntries: [LogEntry]
```

---

## 7. Архитектурные правила (жёсткие)

- Views содержат **только** рендеринг и user actions
- ViewModel **не** вызывает Firebase / AI напрямую
- AI логика изолирована: `PromptBuilder` → `AIService` → `ViewModel`
- Firebase изолирована в `Services/Firebase/`
- Networking только через `async/await`, нет completion handlers
- Промпты в отдельных файлах `*Prompt.swift`, не инлайн
- Репозитории — единственная точка доступа к данным
- Нет `Combine` в новом коде — только `async/await`
- Нет `!` force unwrap
- Нет хардкода строк — только локализация
- Нет хардкода цветов — только `DesignSystem.swift`

---

## 8. Правила генерации кода

1. **Анализируй** — сначала поиск по существующим файлам
2. **Переиспользуй** — компоненты из DesignSystem, не создавай новые аналоги
3. **Инкрементально** — не переписывай неизменённые файлы
4. **Минимально** — только изменённые и новые файлы
5. **Консистентно** — стиль как в `TodayView.swift` / `LeapsView.swift`

---

## 9. Фичи — статус

### Реализованы ✅
- Today Dashboard (кормление, сон, подгузники, лог)
- Feeding Timer (с кольцом прогресса, сторона, история)
- Sleep log
- Leaps (скачки развития, 10 скачков, timeline)
- White Noise (6 звуков)
- Symptoms tracker
- Growth charts (вес, рост, голова vs ВОЗ)
- AI Chat
- Onboarding (4 шага: возраст → профиль → роль → старт)
- Settings
- Sharing / Family invite (QR-код)

### Запланированы (есть ТЗ) 📋
| Фича | Документ | Приоритет |
|---|---|---|
| Vaccination Calendar | ТЗ написано | High |
| iOS Widget (WidgetKit) | ТЗ написано | High |
| AI Daily Tip (реальный AI) | ТЗ написано | High |

### В бэклоге 📌
- Edit Profile (редактирование данных онбординга в Settings)
- Sleep Analytics Dashboard (графики за неделю/месяц)
- Push Reminders (кормление, прививки, педиатр)
- Feeding Journal (прикорм, аллергии)
- Daily Report PDF
- Partner Mode (расширение SharingView)
- Milestones Journal
- Pumping Tracker
- Mood Tracker (мама)
- Apple Watch App
- Live Activity / Dynamic Island

---

## 10. Планируемые фичи — ключевые решения

### Vaccination Calendar
- Данные: статичный массив, Национальный календарь РФ
- Хранение: `UserDefaults`, `Set<String>` JSON
- Ключ кеша: `"vaccination_done_ids"`
- Навигация: Settings → секция «Здоровье»
- Подсветка текущей группы: из `babyBirthDate`
- Out of scope v1: пуш-уведомления, Firebase sync

### iOS Widget
- Механизм: App Group + `UserDefaults(suiteName: "group.com.momsy.shared")`
- Bundle ID виджета: `com.momsy.app.widget`
- Виджеты: Feeding, Sleep, Daily Summary, Lock Screen
- Refresh: `reloadAllTimelines()` при каждом `addEntry()`
- Deep links: `momsy://feeding`, `momsy://today`
- Out of scope v1: интерактивный виджет (iOS 17+), Live Activity

### AI Daily Tip
- Заменяет хардкод `aiTipText` в `TodayView`
- Контекст: кормления, сон, подгузники, возраст, скачок, время суток
- Кеш: `UserDefaults` (не Firebase), TTL 3 часа
- Дедупликация: `contextHash` — не запрашиваем если данные не изменились
- `max_tokens: 150` — экономия
- Fallback: статичный текст если нет интернета и нет кеша
- Новые файлы: `DailyContext`, `DailyTip`, `DailyContextBuilder`, `DailyTipService`, `DailyTipRepository`, `DailyTipPrompt`

---

## 11. Firebase

| Сервис | Использование |
|---|---|
| Auth | Аутентификация пользователей |
| Firestore | История чата AI, данные синхронизации |
| Analytics | Пользовательские события |
| Crashlytics | Ошибки и крэши |
| Remote Config | Feature flags, промпты (будущее) |
| Storage | Фото (будущее) |

Правило: Firebase **только** в `Services/Firebase/`. ViewModel не знает о Firebase.

---

## 12. AI

- Провайдер абстрагирован через `AIProviderProtocol`
- Промпты централизованы в `*Prompt.swift` файлах
- Ответы ограничены baby-care доменом
- Модерация обязательна
- Язык ответов: совпадает с языком приложения (ru по умолчанию)
- Нет медицинских диагнозов в ответах
- Тон: тёплый, поддерживающий, без паники

---

## 13. Безопасность

- API ключи в `.xcconfig`, не в коде
- Firestore Rules включены
- Анонимный доступ отключён
- Контент-модерация AI ответов
- Данные изолированы по пользователю

---

## 14. Монетизация (план)

```
Free:
  Today Dashboard, Sleep/Feeding logs (7 дней),
  Leaps, White Noise (3 звука), Basic AI tips

Premium:
  Полная история, Growth charts + ВОЗ,
  Vaccination tracker, PDF отчёты,
  Partner mode, White Noise (все),
  AI Chat (unlimited), Feeding journal
```

---

## 15. Папки проекта

```
Momsy/
├── App/
│   └── MomsyApp.swift
├── Core/
│   ├── DesignSystem/
│   ├── Localization/
│   ├── Network/
│   ├── Storage/
│   ├── Extensions/
│   └── Utils/
├── Features/
│   ├── Today/
│   ├── Feeding/
│   ├── Sleep/
│   ├── Leaps/
│   ├── WhiteNoise/
│   ├── Symptoms/
│   ├── Growth/
│   ├── AIChat/
│   ├── Vaccination/        ← планируется
│   └── Settings/
├── Services/
│   ├── Firebase/
│   ├── AI/
│   └── Notifications/
├── Components/
│   ├── DesignSystem.swift
│   ├── CuteBlobView.swift
│   └── Models.swift
└── Resources/
```

---

## 16. Контрольные вопросы перед генерацией кода

- [ ] Компонент уже существует в DesignSystem?
- [ ] Цвет берётся из палитры, не хардкод?
- [ ] Строки через локализацию?
- [ ] Бизнес-логика в ViewModel/Service, не во View?
- [ ] async/await, не Combine?
- [ ] Репозиторий для доступа к данным?
- [ ] Промпт в отдельном файле?
- [ ] Стиль как в TodayView / LeapsView?