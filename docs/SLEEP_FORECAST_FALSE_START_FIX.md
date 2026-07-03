# CLI Task: Sleep Forecast — False Start / Short Nap Fix

**Приоритет:** P1 (пользовательский дефект, видимый на TodayView)
**Ветка:** `fix/sleep-forecast-false-start`
**Принцип:** код имеет приоритет над `.md`-спеками при расхождении.

---

## 1. Проблема

Малыш проснулся через 5 минут после старта таймера сна → пользователь останавливает таймер → прогноз показывает следующий сон через полное wake window (~2–3 ч). Физиологически сон < 10 минут ("false start") почти не снимает sleep pressure — окно бодрствования не должно сбрасываться.

**Root cause** — `DeterministicSleepForecastEngine.onsetAnchor(_:profile:now:)`: любой завершённый сон трактуется как полноценный якорь, `onset = lastWake + personalizedWW` без учёта длительности сна.

Побочные дефекты той же природы:

1. **Статистика (`observedWakeWindows`)** — false start разрезает одно реальное окно бодрствования на два коротких gap; реальное окно теряется из персонализации.
2. **`napsTakenToday`** — false start "съедает" слот дневного сна, прогноз преждевременно переключается на `bedtime`.
3. **`minutesAwake`** — после false start счётчик "бодрствует X мин" сбрасывается на 5 минут, хотя ребёнок фактически недоспал с прошлого пробуждения.

## 2. Целевое поведение

| Длительность последнего завершённого сна | Поведение |
|---|---|
| `< 10 мин` (false start) | Окно считается от **последнего реального пробуждения до** false start. Если onset уже в прошлом → `now + 15 мин` ("укладывать скорее"). Не учитывается в `napsTakenToday`, gap'ах статистики и `minutesAwake`. |
| `10 мин ..< typicalNap × 0.5` (короткий сон) | Частичный кредит: `effectiveWW = personalizedWW × (0.5 + 0.5 × duration / cutoff)`. Линейная рампа 0.5 → 1.0, непрерывна на верхней границе. |
| `≥ typicalNap × 0.5` | Полное окно — текущее поведение без изменений. |

Только false starts в истории (нет ни одного реального сна) → `onset = falseStart.end + 0.5 × personalizedWW`, кламп `≥ now + 15 мин`.

Все константы — в `Const` движка: `falseStartMaxMinutes = 10`, `shortNapFraction = 0.5`, `minPartialWindowFactor = 0.5`, `minLeadMinutes = 15`.

**Инварианты (не менять):**
- Ветка "ребёнок сейчас спит" (`endDate == nil`) — без изменений.
- Ветка "логов нет" (morning fallback) — без изменений.
- `isOverdue` после false start остаётся `false`: onset клампится в будущее (`now + 15`), UI показывает actionable время вместо "просрочено".
- Никаких изменений в VM/UI/локализации: `SleepViewModel` и `TodayViewModel` уже пересчитывают прогноз после `stopSleep`, форма `SleepPrediction` не меняется.

---

## 3. Файлы

| Действие | Путь |
|---|---|
| Заменить | `Momsy/Features/Sleep/Data/Services/DeterministicSleepForecastEngine.swift` |
| Дополнить | `MomsyTests/Features/Sleep/SleepForecastEngineTests.swift` |
| Обновить | `SLEEP_FORECAST_ENGINE.md` (§3 шаг 4, §7) |

Больше ничего не трогать: `WakeWindowCatalog`, модели, VM, `NextSleepCard` — без изменений.

---

## 4. Task 1 — Движок (полная замена файла)

`Momsy/Features/Sleep/Data/Services/DeterministicSleepForecastEngine.swift`:

```swift
import Foundation

final class DeterministicSleepForecastEngine: SleepForecastEngine {

    private enum Const {
        static let minSamplesForPersonalization = 4
        static let highConfidenceSamples        = 8
        static let maxObservedWeight            = 0.7
        static let weightSampleDivisor          = 10.0
        static let minBufferMinutes             = 15.0
        static let bufferFraction               = 0.15
        static let eveningBedtimeHour           = 18
        static let nightStartHour               = 19
        static let morningWakeHour              = 6
        /// Completed sleep shorter than this is a "false start": sleep
        /// pressure was not relieved, so the wake window must not reset.
        static let falseStartMaxMinutes         = 10
        /// Naps shorter than `typicalNapMinutes * shortNapFraction` earn
        /// only partial wake-window credit.
        static let shortNapFraction             = 0.5
        /// Floor of the partial-credit ramp (fraction of the full window).
        static let minPartialWindowFactor       = 0.5
        /// When a recomputed onset lands in the past, suggest settling the
        /// baby this many minutes from now.
        static let minLeadMinutes               = 15
    }

    func predict(birthDate: Date, entries: [SleepEntry], now: Date) -> SleepPrediction? {
        let ageDays = Self.ageInDays(birthDate, now)
        guard ageDays >= 0 else { return nil }
        let profile = WakeWindowCatalog.profile(forAgeInDays: ageDays)

        let samples = observedWakeWindows(entries, profile: profile, now: now)
        let (windowMinutes, basis) = personalizedWindow(profile: profile, samples: samples)

        guard let onset = onsetDate(entries, profile: profile,
                                    windowMinutes: windowMinutes, now: now) else { return nil }
        let buffer = bufferMinutes(forWindow: windowMinutes)

        guard let kind = classify(onset: onset, entries: entries, profile: profile, now: now) else { return nil }

        let asleepNow = isSleepingNow(entries)
        let awake = asleepNow ? nil : minutesAwake(entries, now: now)

        return SleepPrediction(
            kind: kind,
            windowStart: onset.addingMinutes(-buffer),
            predictedOnset: onset,
            windowEnd: onset.addingMinutes(buffer),
            confidence: confidence(sampleCount: samples.count),
            basis: basis,
            napsRemaining: napsRemaining(entries, profile: profile, now: now),
            isOverdue: !asleepNow && onset <= now,
            minutesAwake: awake
        )
    }

    // MARK: - Готово
    private static func ageInDays(_ birthDate: Date, _ now: Date) -> Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: now).day ?? -1
    }
    private func bufferMinutes(forWindow windowMinutes: Int) -> Int {
        Int(max(Const.minBufferMinutes, Const.bufferFraction * Double(windowMinutes)))
    }
    private func confidence(sampleCount n: Int) -> PredictionConfidence {
        if n >= Const.highConfidenceSamples { return .high }
        if n >= Const.minSamplesForPersonalization { return .medium }
        return .low
    }

    // MARK: - §4.1
    /// False starts are skipped entirely so the wake windows around them
    /// merge back into one real gap instead of two broken fragments.
    private func observedWakeWindows(_ entries: [SleepEntry], profile: WakeWindowProfile, now: Date) -> [Int] {
        let cal = Calendar.current
        let completed = entries
            .filter { $0.endDate != nil && !$0.isFalseStart(maxMinutes: Const.falseStartMaxMinutes) }
            .sorted { $0.startDate < $1.startDate }
        guard completed.count >= 2 else { return [] }

        let lower = Double(profile.minMinutes) * 0.5
        let upper = Double(profile.maxMinutes) * 1.5

        var gaps: [Int] = []
        for i in 1..<completed.count {
            guard let aEnd = completed[i - 1].endDate else { continue }
            let bStart = completed[i].startDate
            guard cal.isDate(aEnd, inSameDayAs: bStart) else { continue }
            let aHour = calendarHour(aEnd)
            let bHour = calendarHour(bStart)
            guard aHour >= Const.morningWakeHour, aHour < Const.nightStartHour,
                  bHour >= Const.morningWakeHour, bHour < Const.nightStartHour else { continue }
            let gap = Int(bStart.timeIntervalSince(aEnd) / 60)
            if Double(gap) >= lower, Double(gap) <= upper { gaps.append(gap) }
        }
        return gaps
    }

    // MARK: - §4.2
    private func personalizedWindow(profile: WakeWindowProfile, samples: [Int]) -> (minutes: Int, basis: PredictionBasis) {
        let n = samples.count
        guard n >= Const.minSamplesForPersonalization else {
            return (profile.typicalMinutes, .ageOnly)
        }
        let mean: Double
        if n >= 5 {
            let sorted = samples.sorted()
            let trimmed = sorted.dropFirst().dropLast()
            mean = Double(trimmed.reduce(0, +)) / Double(trimmed.count)
        } else {
            mean = Double(samples.reduce(0, +)) / Double(n)
        }
        let w = min(Double(n) / Const.weightSampleDivisor, Const.maxObservedWeight)
        let blended = w * mean + (1 - w) * Double(profile.typicalMinutes)
        let clamped = min(max(Int(blended.rounded()), profile.safeLowerMinutes), profile.safeUpperMinutes)
        return (clamped, .personalized(samples: n))
    }

    // MARK: - §4.3 (точка отсчёта + кредит за длительность сна)
    private func onsetDate(_ entries: [SleepEntry], profile: WakeWindowProfile,
                           windowMinutes: Int, now: Date) -> Date? {
        guard let latest = entries.max(by: { $0.startDate < $1.startDate }) else {
            // Нет логов вообще: сегодня в morningWakeHour, если now уже позже; иначе now.
            let morning = Calendar.current.date(
                bySettingHour: Const.morningWakeHour, minute: 0, second: 0, of: now
            ) ?? now
            let anchor = now > morning ? morning : now
            return anchor.addingMinutes(windowMinutes)
        }

        if latest.endDate == nil {
            return latest.startDate
                .addingMinutes(profile.typicalNapMinutes)
                .addingMinutes(windowMinutes)
        }

        let completed = entries
            .filter { $0.endDate != nil }
            .sorted { ($0.endDate ?? .distantPast) < ($1.endDate ?? .distantPast) }
        guard let last = completed.last,
              let lastEnd = last.endDate,
              let lastDuration = last.durationMinutes else { return nil }

        let shortNapCutoff = max(Const.falseStartMaxMinutes + 1,
                                 Int(Double(profile.typicalNapMinutes) * Const.shortNapFraction))

        // Полноценный сон → полное окно (прежнее поведение).
        if lastDuration >= shortNapCutoff {
            return lastEnd.addingMinutes(windowMinutes)
        }

        // False start: окно продолжает отсчитываться от последнего реального пробуждения.
        if lastDuration < Const.falseStartMaxMinutes {
            let lastRealWake = completed
                .filter { !$0.isFalseStart(maxMinutes: Const.falseStartMaxMinutes) }
                .compactMap(\.endDate)
                .max()
            if let realWake = lastRealWake {
                let onset = realWake.addingMinutes(windowMinutes)
                return max(onset, now.addingMinutes(Const.minLeadMinutes))
            }
            // В истории только false starts: минимальный частичный кредит.
            let reduced = Int(Double(windowMinutes) * Const.minPartialWindowFactor)
            return max(lastEnd.addingMinutes(reduced), now.addingMinutes(Const.minLeadMinutes))
        }

        // Короткий сон: частичный кредит, линейная рампа 0.5 → 1.0.
        let restoration = Double(lastDuration) / Double(shortNapCutoff)
        let factor = Const.minPartialWindowFactor + (1 - Const.minPartialWindowFactor) * restoration
        let effective = Int((Double(windowMinutes) * factor).rounded())
        return lastEnd.addingMinutes(effective)
    }

    // MARK: - §4.4
    private func napsTakenToday(_ entries: [SleepEntry], now: Date) -> Int {
        let cal = Calendar.current
        return entries.filter { entry in
            guard cal.isDate(entry.startDate, inSameDayAs: now) else { return false }
            guard !entry.isFalseStart(maxMinutes: Const.falseStartMaxMinutes) else { return false }
            let hour = calendarHour(entry.startDate)
            return hour >= Const.morningWakeHour && hour < Const.nightStartHour
        }.count
    }

    private func napsRemaining(_ entries: [SleepEntry], profile: WakeWindowProfile, now: Date) -> Int? {
        max(0, profile.napsPerDay.upperBound - napsTakenToday(entries, now: now))
    }

    private func isSleepingNow(_ entries: [SleepEntry]) -> Bool {
        entries.max(by: { $0.startDate < $1.startDate })?.endDate == nil && !entries.isEmpty
    }

    /// Minutes the baby has been awake. Counted from the last *real* wake-up:
    /// a false start does not reset the counter. Falls back to any completed
    /// end when only false starts exist. `nil` when nothing has ended yet.
    private func minutesAwake(_ entries: [SleepEntry], now: Date) -> Int? {
        let realEnds = entries
            .filter { !$0.isFalseStart(maxMinutes: Const.falseStartMaxMinutes) }
            .compactMap(\.endDate)
        guard let lastEnd = realEnds.max() ?? entries.compactMap(\.endDate).max() else { return nil }
        let mins = Int(now.timeIntervalSince(lastEnd) / 60)
        return mins >= 0 ? mins : nil
    }

    private func classify(onset: Date, entries: [SleepEntry], profile: WakeWindowProfile, now: Date) -> SleepPredictionKind? {
        let h = calendarHour(onset)
        if h >= Const.nightStartHour || h < Const.morningWakeHour { return nil }
        let remaining = napsRemaining(entries, profile: profile, now: now) ?? 0
        if remaining <= 0 || h >= Const.eveningBedtimeHour { return .bedtime }
        return .nap
    }

    private func calendarHour(_ date: Date) -> Int { Calendar.current.component(.hour, from: date) }
}

private extension Date {
    func addingMinutes(_ minutes: Int) -> Date { addingTimeInterval(TimeInterval(minutes * 60)) }
}

private extension SleepEntry {
    /// Completed sleep too short to relieve sleep pressure. Ongoing sleeps
    /// (`endDate == nil`) are never treated as false starts.
    func isFalseStart(maxMinutes: Int) -> Bool {
        guard let d = durationMinutes else { return false }
        return d < maxMinutes
    }
}
```

Что изменилось относительно текущего файла (для ревью диффа):
- `onsetAnchor` → `onsetDate` (возвращает готовый onset, а не якорь; вызов в `predict` обновлён).
- 4 новые константы в `Const`.
- `observedWakeWindows`: фильтр `!isFalseStart` в `completed` (автоматическое слияние gap'ов).
- `napsTakenToday`: guard на false start.
- `minutesAwake`: приоритет реальных пробуждений.
- Новый `private extension SleepEntry`.
- Всё остальное — байт-в-байт как было.

---

## 5. Task 2 — Тесты

Добавить в конец `struct SleepForecastEngineTests` (перед закрывающей `}`), `MomsyTests/Features/Sleep/SleepForecastEngineTests.swift`. Используются существующие хелперы `makeToday / at / birth / entry`.

Возраст 150 дней → `months4to6`: age-only window 127, `typicalNapMinutes` 75, short-nap cutoff = 37.

```swift
    // MARK: - 12. False start не сбрасывает окно бодрствования

    @Test("a 5-minute false start keeps counting from the previous real wake")
    func falseStartDoesNotResetWindow() throws {
        let today = try makeToday()
        // Реальный сон 08:00–09:15; false start 11:00–11:05; сейчас 11:10.
        let entries = [
            entry(try at(today, 8, 0), try at(today, 9, 15)),
            entry(try at(today, 11, 0), try at(today, 11, 5))
        ]
        let now = try at(today, 11, 10)
        let pred = try #require(engine.predict(birthDate: try birth(today, daysOld: 150),
                                               entries: entries, now: now))
        // Онсет от реального пробуждения 09:15 + 127 = 11:22 → клампится к now + 15 = 11:25.
        let expected = now.addingTimeInterval(15 * 60)
        #expect(abs(pred.predictedOnset.timeIntervalSince(expected)) < 90)
        // НЕ 11:05 + 127 ≈ 13:12.
        #expect(pred.predictedOnset < try at(today, 12, 0))
        #expect(!pred.isOverdue)
        #expect(pred.minutesAwake == 115)          // 09:15 → 11:10, false start игнорируется
        #expect(pred.napsRemaining == 3)           // false start не съедает слот (4 − 1)
    }

    // MARK: - 13. Короткий сон → частичный кредит окна

    @Test("a 20-minute nap earns a shortened wake window")
    func shortNapPartialCredit() throws {
        let today = try makeToday()
        let entries = [entry(try at(today, 12, 0), try at(today, 12, 20))]
        let now = try at(today, 12, 30)
        let pred = try #require(engine.predict(birthDate: try birth(today, daysOld: 150),
                                               entries: entries, now: now))
        // cutoff 37, restoration 20/37 → factor ≈ 0.77 → окно ≈ 98 мин (вместо 127).
        let anchor = try at(today, 12, 20)
        let deltaMin = pred.predictedOnset.timeIntervalSince(anchor) / 60
        #expect(deltaMin >= 90 && deltaMin <= 110)
    }

    // MARK: - 14. False start в истории не ломает статистику окон

    @Test("false starts are merged out of observed wake-window gaps")
    func falseStartGapsMerged() throws {
        let today = try makeToday()
        var entries: [SleepEntry] = []
        // 9 дней: реальный сон, false start посреди окна, реальный сон.
        for d in 0..<9 {
            let day = try #require(cal.date(byAdding: .day, value: -d, to: today))
            entries.append(entry(try at(day, 8, 0), try at(day, 9, 15)))
            entries.append(entry(try at(day, 10, 0), try at(day, 10, 5)))
            entries.append(entry(try at(day, 11, 15), try at(day, 12, 30)))
        }
        let now = try at(today, 14, 0)
        let pred = try #require(engine.predict(birthDate: try birth(today, daysOld: 150),
                                               entries: entries, now: now))
        // Слитый gap = 120 мин/день → 9 сэмплов; бленд ≈ 0.7·120 + 0.3·127 ≈ 122.
        #expect(pred.basis == .personalized(samples: 9))
        let anchor = try at(today, 12, 30)
        let deltaMin = pred.predictedOnset.timeIntervalSince(anchor) / 60
        #expect(deltaMin >= 110 && deltaMin <= 135)   // без слияния было бы ≈ 87
    }

    // MARK: - 15. Только false starts в истории → минимальный частичный кредит

    @Test("false starts alone yield a reduced window from their end")
    func onlyFalseStartsReducedWindow() throws {
        let today = try makeToday()
        let entries = [entry(try at(today, 10, 0), try at(today, 10, 5))]
        let now = try at(today, 10, 10)
        let pred = try #require(engine.predict(birthDate: try birth(today, daysOld: 150),
                                               entries: entries, now: now))
        // 0.5 × 127 = 63 мин от 10:05 → ≈ 11:08.
        let anchor = try at(today, 10, 5)
        let deltaMin = pred.predictedOnset.timeIntervalSince(anchor) / 60
        #expect(deltaMin >= 55 && deltaMin <= 70)
        #expect(!pred.isOverdue)
    }
```

Существующие тесты 1–11 менять не нужно: последние сны во всех фикстурах ≥ cutoff их возрастного бэнда (проверено: 75 мин при cutoff 37; 60 мин при cutoff 30 и т.д.), false starts в них отсутствуют.

---

## 6. Task 3 — Обновить спеку `SLEEP_FORECAST_ENGINE.md`

В §3 заменить шаг 4 на:

```
4. ТОЧКА ОТСЧЁТА + КРЕДИТ ЗА ДЛИТЕЛЬНОСТЬ
   Спит (endDate == nil): onset = entry.start + typicalNapMinutes + personalizedWW
   Бодрствует, длительность последнего завершённого сна D, cutoff = typicalNap·0.5:
     D ≥ cutoff  → onset = lastWake + personalizedWW                       (полное окно)
     10 ≤ D < cutoff → onset = lastWake + personalizedWW·(0.5 + 0.5·D/cutoff)  (частичный кредит)
     D < 10 мин  → false start: onset = предыдущее РЕАЛЬНОЕ пробуждение + personalizedWW,
                   clamp ≥ now + 15 мин. False starts исключаются из gap-статистики (§3.2),
                   napsTaken (§3.6) и minutesAwake.
```

В §7 добавить строки:

```
| Сон < 10 мин (false start) | Окно не сбрасывается: отсчёт от прошлого реального пробуждения, клампится к now+15 |
| Сон 10 мин – ½·typicalNap  | Частичный кредит окна (линейная рампа 0.5→1.0)                                     |
```

---

## 7. Definition of Done

- [ ] `DeterministicSleepForecastEngine.swift` заменён; вне перечисленных методов дифф пустой.
- [ ] 4 новых теста добавлены, все 15 тестов `SleepForecastEngineTests` зелёные.
- [ ] `SleepViewModelTests` зелёные (без изменений — форма `SleepPrediction` не менялась).
- [ ] `SLEEP_FORECAST_ENGINE.md` обновлён (§3.4, §7).
- [ ] Ничего не изменено в `WakeWindowCatalog`, моделях, VM, `NextSleepCard`, локализации.
- [ ] Полный тест-таргет: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 15'` — без падений.
- [ ] Коммиты: `fix(sleep): false start does not reset wake window` + `test(sleep): false start / short nap coverage` + `docs(sleep): spec update`.

## 8. Manual QA (симулятор)

1. Профиль ребёнка ~5 мес. Запустить таймер сна → карточка показывает прогноз после ожидаемого пробуждения (как раньше).
2. Остановить таймер через ~5 минут → **карточка показывает следующий сон через ~15–30 мин**, не через 2+ часа; "бодрствует X мин" считается от предыдущего реального пробуждения.
3. Залогировать вручную сон 20 минут → прогноз заметно раньше полного окна (~75% от него).
4. Залогировать нормальный сон 60–90 минут → прогноз как раньше (полное окно) — регрессии нет.
5. День с false start посреди истории → бейдж уверенности/сэмплы не проседают.
