# ТЗ: Движок прогноза сна (Sleep Forecast Engine)

**Версия:** v1
**Приоритет:** Tier 1
**Принцип:** офлайн, детерминированно, без AI-вызовов (как `DAILY_TIPS_ALGORITHM.md`)
**Фича:** `Features/Sleep/`

---

## 1. Цель

Предсказывать **следующее окно сна** ребёнка на основе возраста и последних логов сна.
Ответ на главный вопрос родителя: «Когда укладывать в следующий раз?» — аналог Huckleberry SweetSpot / Robin Baby sleep forecast, но локально и бесплатно по вычислениям.

### In scope (v1)
- Прогноз времени следующего сна (окно: начало–середина–конец).
- Классификация: дневной сон (`nap`) vs ночной (`bedtime`).
- Персонализация по фактическим окнам бодрствования за последние 14 дней.
- Уровень уверенности (`low / medium / high`) + источник (по возрасту / персонализировано).
- Fallback на чистые возрастные нормы при нехватке данных.

### Out of scope (v1)
- Полное расписание дня на все сны вперёд (→ Premium, v2).
- Детект перехода между режимами снов (3→2→1) — обрабатывается косвенно через наблюдаемые данные.
- Прогноз утреннего пробуждения, AI-анализ, пуш-напоминания.

---

## 2. Научная база — финальный каталог

Возрастные бэнды — отдельный `SleepAgeBand` (НЕ `BabyAgeStage`, тот слишком грубый: внутри
его `newborn 0–3 мес` wake window меняется в 3 раза). Значения вынесены в `WakeWindowCatalog`
и являются источником истины (эта таблица = зеркало кода). Wake windows и нормы сна — общепринятые
педиатрические ориентиры (нормы согласованы с AAP); `napsPerDay` и `nap≈` — «договорные», уточнить
перед релизом.

| `SleepAgeBand` | Возраст   | ≤ дней | Wake window | napsPerDay | nap≈   | Норма сна/сут |
|----------------|-----------|--------|-------------|------------|--------|---------------|
| `weeks0to6`    | 0–6 нед   | 42     | 35–60 мин   | 4…8        | 50 мин | 14–17 ч       |
| `weeks6to12`   | 6–12 нед  | 84     | 60–90 мин   | 4…5        | 60 мин | 14–16 ч       |
| `months3to4`   | 3–4 мес   | 120    | 75–120 мин  | 3…4        | 60 мин | 14–16 ч       |
| `months4to6`   | 4–6 мес   | 180    | 105–150 мин | 3…4        | 75 мин | 13–15 ч       |
| `months6to9`   | 6–9 мес   | 270    | 120–180 мин | 2…3        | 90 мин | 13–15 ч       |
| `months9to12`  | 9–12 мес  | 365    | 150–210 мин | 2…2        | 90 мин | 12–14 ч       |
| `months12to18` | 12–18 мес | 545    | 180–270 мин | 1…2        | 120 мин| 12–14 ч       |
| `months18to24` | 18–24 мес | 730    | 270–360 мин | 1…1        | 120 мин| 11–14 ч       |
| `months24plus` | 2+ года   | —      | 300–360 мин | 0…1        | 120 мин| 11–14 ч       |

- `typicalMinutes = (min + max) / 2` — базовое окно для бленда (§3).
- `nap≈` (`typicalNapMinutes`) используется только когда ребёнок сейчас спит (§4).
- Защитные рамки клампа: `safeLower = min·0.8`, `safeUpper = max·1.2`.

> Значения живут в `WakeWindowCatalog`, меняются без правок логики движка.

---

## 3. Алгоритм (детерминированный)

Вход: `birthDate`, `entries: [SleepEntry]` (≤14 дней), `now: Date`, текущее состояние (спит / бодрствует).

```
1. ВОЗРАСТ → ПРОФИЛЬ
   ageDays = ageInDays(birthDate, now)            // Calendar, DST-safe
   profile = WakeWindowCatalog.profile(forAgeInDays: ageDays)
   Если ageDays < 0 (нет/некорректный birthDate) → return nil.

2. НАБЛЮДАЕМЫЕ ОКНА БОДРСТВОВАНИЯ
   Для соседних ЗАВЕРШЁННЫХ снов (endDate != nil) за 14 дней: gap = nextSleep.start − prevSleep.end
   Берём только ДНЕВНЫЕ gap (не пересекающие ночь).
   Фильтр выбросов: 0.5·min ≤ gap ≤ 1.5·max  (отсекает пропущенные логи)
   observedWW = усечённое среднее (trimmed mean) валидных gap
   samples = число валидных gap

3. БЛЕНД (персонализация)
   w = min(samples / 10, 0.7)            // вес факта растёт с объёмом данных
   personalizedWW = w·observedWW + (1−w)·profile.typicalMinutes
   clamp → [profile.safeLower, profile.safeUpper]   // защитные рамки

4. ТОЧКА ОТСЧЁТА + КРЕДИТ ЗА ДЛИТЕЛЬНОСТЬ
   Спит (endDate == nil): onset = entry.start + typicalNapMinutes + personalizedWW
   Бодрствует, длительность последнего завершённого сна D, cutoff = typicalNap·0.5:
     D ≥ cutoff  → onset = lastWake + personalizedWW                       (полное окно)
     10 ≤ D < cutoff → onset = lastWake + personalizedWW·(0.5 + 0.5·D/cutoff)  (частичный кредит)
     D < 10 мин  → false start: onset = предыдущее РЕАЛЬНОЕ пробуждение + personalizedWW,
                   clamp ≥ now + 15 мин. False starts исключаются из gap-статистики (§3.2),
                   napsTaken (§3.6) и minutesAwake.

5. ОКНО
   buffer = max(15 мин, 0.15·personalizedWW)
   window = [onset − buffer, onset, onset + buffer]

6. КЛАССИФИКАЦИЯ nap / bedtime
   napsTaken = число дневных снов сегодня
   napsRemaining = profile.napsPerDay.upper − napsTaken
   Если napsRemaining ≤ 0 ИЛИ onset позже возрастного порога вечера → kind = .bedtime
   Иначе kind = .nap

7. УВЕРЕННОСТЬ
   samples ≥ 8 и низкая дисперсия → .high
   4 ≤ samples ≤ 7              → .medium
   samples < 4                  → .low + basis = .ageOnly (чистая норма)
```

**Свойства:** чистая функция, без сети, без async, без AI-токенов. Сложность O(n) по логам за 14 дней.

---

## 4. Доменные модели (сигнатуры)

```swift
enum SleepPredictionKind: Equatable { case nap, bedtime }
enum PredictionConfidence: Equatable { case low, medium, high }
enum PredictionBasis: Equatable { case ageOnly, personalized(samples: Int) }

/// Отдельный дробный бэнд только для сна (BabyAgeStage слишком грубый).
enum SleepAgeBand: CaseIterable {
    case weeks0to6, weeks6to12, months3to4, months4to6
    case months6to9, months9to12, months12to18, months18to24, months24plus
    var upperBoundDays: Int?   // 42, 84, 120, 180, 270, 365, 545, 730, nil
}

struct WakeWindowProfile: Equatable {
    let band: SleepAgeBand
    let minMinutes: Int
    let maxMinutes: Int
    let napsPerDay: ClosedRange<Int>
    let typicalNapMinutes: Int
    var typicalMinutes: Int { (minMinutes + maxMinutes) / 2 }
    var safeLowerMinutes: Int { Int(Double(minMinutes) * 0.8) }
    var safeUpperMinutes: Int { Int(Double(maxMinutes) * 1.2) }
}

struct SleepPrediction: Equatable {
    let kind: SleepPredictionKind
    let windowStart: Date
    let predictedOnset: Date
    let windowEnd: Date
    let confidence: PredictionConfidence
    let basis: PredictionBasis
    let napsRemaining: Int?
}
```

---

## 5. Архитектура и файлы

```
Features/Sleep/
├── Domain/
│   ├── Models/
│   │   ├── SleepAgeBand.swift
│   │   ├── WakeWindowProfile.swift
│   │   └── SleepPrediction.swift
│   ├── Services/
│   │   └── SleepForecastEngine.swift          // protocol
│   └── UseCases/
│       └── PredictNextSleepUseCase.swift
├── Data/
│   ├── Catalog/
│   │   └── WakeWindowCatalog.swift            // статическая таблица §2
│   └── Services/
│       └── DeterministicSleepForecastEngine.swift   // реализация §3
└── Presentation/
    └── Views/
        └── NextSleepCard.swift                // переиспользуемый компонент
```

### Контракты

```swift
protocol SleepForecastEngine {
    func predict(birthDate: Date, entries: [SleepEntry], now: Date) -> SleepPrediction?
}

final class PredictNextSleepUseCase {
    init(getSleep: GetSleepEntriesUseCase, engine: SleepForecastEngine, lookbackDays: Int = 14)
    func execute(birthDate: Date, now: Date = Date()) async throws -> SleepPrediction?
}
```

> Движок — синхронная чистая функция; асинхронность только на чтении логов через существующий `GetSleepEntriesUseCase`. Firebase не задействован.

---

## 6. Интеграция

- **DI (`AppContainer`):** добавить `sleepForecastEngine = DeterministicSleepForecastEngine()` и `predictNextSleep = PredictNextSleepUseCase(...)`. Прокинуть в `makeTodayViewModel` и `makeSleepViewModel`.
- **TodayViewModel / SleepViewModel:** `@Published var nextSleep: SleepPrediction?`. Пересчёт: `onAppear`, при `scenePhase == .active`, после `addManualSleep` / `stopSleep`.
- **UI (`NextSleepCard`):** «Следующий сон ~ 14:30 (14:15–14:45)», бейдж уверенности, подпись источника. Цвета — только из `DesignSystem`, строки — через `lm.strings.*` (RU/EN/DE). Карточка на `TodayView` (верх) и `SleepView`.

---

## 7. Edge cases

| Ситуация | Поведение |
|---|---|
| Нет `birthDate` | `nil`, карточка скрыта |
| Логов сна нет | basis `.ageOnly`, confidence `.low`, подпись «по возрасту» |
| < 4 валидных окон | только возрастная норма |
| Ребёнок сейчас спит | прогноз после ожидаемого конца сна |
| Ночное время | подавить `nap`, не предлагать дневной сон до утра |
| Выбросы / пропущенные логи | отсекаются фильтром §3.2 |
| Переезд / DST | только `Calendar` + абсолютные `Date`, без ручной арифметики часов |
| Сон < 10 мин (false start) | Окно не сбрасывается: отсчёт от прошлого реального пробуждения, клампится к now+15 |
| Сон 10 мин – ½·typicalNap | Частичный кредит окна (линейная рампа 0.5→1.0) |

---

## 8. Тесты (детерминированные → простые)

`MomsyTests/Features/Sleep/SleepForecastEngineTests.swift`:
- известный возраст + чистые логи → ожидаемое окно (±buffer);
- фильтрация выбросов (пропущенный лог не ломает прогноз);
- пороги уверенности (3/5/8 сэмплов → low/medium/high);
- состояние «спит» vs «бодрствует»;
- отсутствие логов → `.ageOnly`;
- nap → bedtime при исчерпании дневных снов.

---

## 9. Монетизация

- **Free (хук):** прогноз ближайшего одного окна сна — даёт почувствовать ценность, в отличие от полностью платного SweetSpot.
- **Premium:** полное расписание дня на все сны вперёд, точность/инсайты по истории, аналитика паттернов.

Согласуется с позиционированием «дешевле Huckleberry»: бесплатный вход в фичу, за которую конкурент берёт всю подписку.

---

## 10. Оценка усилий

| Блок | Время |
|---|---|
| Каталог + модели + движок (§2–4) | ~1 день |
| Интеграция (DI, VM, `NextSleepCard`, локализация) | ~1 день |
| Юнит-тесты (§8) | ~0.5 дня |
| **Итого** | **~2.5 дня** |

**Стоимость рантайма:** 0 сетевых запросов, 0 AI-токенов, O(n) по 14 дням логов.
