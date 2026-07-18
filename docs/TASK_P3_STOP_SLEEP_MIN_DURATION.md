# TASK P3: StopSleepUseCase — guard минимальной длительности, discard случайных сессий

**Приоритет:** P3
**Оценка:** S-M
**Не пересекается** с TASK_ANNUAL_SUBSCRIPTION.md.

## Контекст (проверено по клону, commit `4afa541`)

Случайный тап Start → Stop создаёт запись сна длительностью 0–1 мин. Она сохраняется локально, уходит в Firestore, попадает в статистику, графики и данные форсаст-движка. Guard'а нет нигде в stop-пути.

Ручной ввод **уже защищён**: `AddSleepEntrySheet.swift:16` — `isValid: endTime > startTime`, кнопка Save задизейблена. Ручной путь не трогаем.

| Файл | Строки | Роль |
|---|---|---|
| `Momsy/Features/Sleep/Domain/UseCases/StopSleepUseCase.swift` | 1-14 | ставит endDate/updatedAt, `repository.update`, возвращает `SleepEntry` |
| `Momsy/Features/Sleep/Presentation/ViewModel/SleepViewModel.swift` | 220-262 | `stop()`: оптимистичный UI, await use case, `pushSleepToFirestore`, `refreshForecast` |
| `Momsy/Core/WatchSync/QuickLogCoordinator.swift` | 108-133 | стоп с часов: находит открытую сессию, execute, push |
| `Momsy/Features/Sleep/Domain/Repositories/SleepRepository.swift` | 9 | `func delete(id: UUID)` — есть |
| `Momsy/Services/Firebase/BabySync/BabySyncService.swift` | 179 | `propagateDelete(id:in:)` — delete + tombstone + offline-retry через `PendingDeletionsStore` |
| `Momsy/Core/Widget/WidgetDataStore.swift` | 81, 228 | `setLastSleepEnd`, `lastSleepEndDate(for:)` |

Других вызовов `stopSleepUC.execute` нет (проверено grep'ом): только VM:250 и координатор:129.

## Root cause

`StopSleepUseCase.execute` безусловно сохраняет:

```swift
    func execute(_ entry: SleepEntry) async throws -> SleepEntry {
        var updated = entry
        updated.endDate = Date()
        updated.updatedAt = Date()
        try await repository.update(updated)
        return updated
    }
```

Критично: активная сессия **уже запушена в Firestore при старте** (`finishStartPersistence` → `pushSleepToFirestore`; watch-путь пушит при старте аналогично). Поэтому discard обязан не только удалить локально, но и вызвать `propagateDelete` — иначе запись воскреснет из облака на следующем merge и останется в кэше co-parent'а.

## Дизайн

- Порог: **60 секунд**. Сессия короче — мусор от случайного тапа, отбрасывается молча (стандарт для baby-трекеров; нотификация не нужна, локализация не требуется).
- Отрицательная длительность (clock skew) — тоже discard.
- Решение о discard — доменная логика → use case. Побочный эффект синка (`propagateDelete`) — по существующему паттерну кодовой базы остаётся на вызывающей стороне (как в `SleepViewModel:495`, `TodayViewModel:270`).
- Use case возвращает `StopSleepOutcome` вместо `SleepEntry` — оба вызывающих обязаны обработать discard, компилятор не даст забыть.

## Fix 1 — StopSleepUseCase

**Файл:** `Momsy/Features/Sleep/Domain/UseCases/StopSleepUseCase.swift` — полная замена:

```swift
import Foundation

enum StopSleepOutcome {
    /// Session persisted with the given end.
    case saved(SleepEntry)
    /// Session was shorter than the minimum and was deleted locally.
    /// Caller must propagate the delete to the cloud.
    case discarded(SleepEntry)
}

final class StopSleepUseCase {
    /// Sessions shorter than this are treated as accidental taps and discarded.
    static let minimumDuration: TimeInterval = 60

    private let repository: SleepRepository
    init(repository: SleepRepository) { self.repository = repository }

    func execute(_ entry: SleepEntry, now: Date = Date()) async throws -> StopSleepOutcome {
        if Self.isBelowMinimum(start: entry.startDate, end: now) {
            try await repository.delete(id: entry.id)
            return .discarded(entry)
        }
        var updated = entry
        updated.endDate = now
        updated.updatedAt = now
        try await repository.update(updated)
        return .saved(updated)
    }

    /// Negative durations (clock skew) also count as below minimum.
    nonisolated static func isBelowMinimum(start: Date, end: Date) -> Bool {
        end.timeIntervalSince(start) < minimumDuration
    }
}
```

## Fix 2 — SleepViewModel.stop()

**Файл:** `Momsy/Features/Sleep/Presentation/ViewModel/SleepViewModel.swift`

### 2a. Сохранить предыдущий wake-stamp (перед строкой 245)

До (строки 244-246):
```swift
        liveActivity.endActivity()
        WidgetDataStore.shared.setLastSleepEnd(Date(), babyId: babyId)
        WidgetDataStore.shared.clearSleep(lastDurationSeconds: sleepSeconds, babyId: babyId)
```

После:
```swift
        liveActivity.endActivity()
        let previousSleepEnd = WidgetDataStore.shared.lastSleepEndDate(for: babyId)
        WidgetDataStore.shared.setLastSleepEnd(Date(), babyId: babyId)
        WidgetDataStore.shared.clearSleep(lastDurationSeconds: sleepSeconds, babyId: babyId)
```

### 2b. Обработка исхода (строки 247-261)

До:
```swift
        Task {
            do {
                _ = try await startTask?.value
                let saved = try await stopSleepUC.execute(entry)
                if let idx = todayEntries.firstIndex(where: { $0.id == saved.id }) {
                    todayEntries[idx] = saved
                }
                pushSleepToFirestore(saved, babyId: babyId)
                await refreshForecast()
            } catch {
                todayEntries.removeAll { $0.id == completed.id }
                saveError = error.localizedDescription
            }
            pendingStopEntryIds.remove(completed.id)
        }
```

После:
```swift
        Task {
            do {
                _ = try await startTask?.value
                switch try await stopSleepUC.execute(entry) {
                case .saved(let saved):
                    if let idx = todayEntries.firstIndex(where: { $0.id == saved.id }) {
                        todayEntries[idx] = saved
                    }
                    pushSleepToFirestore(saved, babyId: babyId)
                case .discarded(let discarded):
                    todayEntries.removeAll { $0.id == discarded.id }
                    if let previousSleepEnd {
                        WidgetDataStore.shared.setLastSleepEnd(previousSleepEnd, babyId: babyId)
                    }
                    // The session was already uploaded at start — durable delete +
                    // tombstone so it can't resurrect from the cloud or a co-parent cache.
                    BabySyncService().propagateDelete(id: discarded.id, in: "sleepLogs")
                }
                await refreshForecast()
            } catch {
                todayEntries.removeAll { $0.id == completed.id }
                saveError = error.localizedDescription
            }
            pendingStopEntryIds.remove(completed.id)
        }
```

Заметки:
- Оптимистично добавленная `completed` при discard убирается из `todayEntries` — UI мгновенно чист.
- Восстановление `previousSleepEnd` — чтобы случайный тап не затирал реальное время последнего пробуждения (его читает виджет). Если предыдущего значения нет (первый сон) — остаётся свежий stamp, косметика.
- `refreshForecast()` выполняется в обоих исходах: удаление ложной сессии тоже меняет прогноз.

## Fix 3 — QuickLogCoordinator.stopSleep (часы)

**Файл:** `Momsy/Core/WatchSync/QuickLogCoordinator.swift`

До (строки 124-131):
```swift
            open.quality = quality
            let secs = max(0, Int(Date().timeIntervalSince(open.startDate)))
            WidgetDataStore.shared.setLastSleepEnd(Date(), babyId: babyId)
            WidgetDataStore.shared.clearSleep(lastDurationSeconds: secs, babyId: babyId)
            sleepLA.endActivity()
            if let saved = try? await stopSleepUC.execute(open) {
                pushSleepToFirestore(saved, babyId: babyId)
            }
```

После:
```swift
            open.quality = quality
            let secs = max(0, Int(Date().timeIntervalSince(open.startDate)))
            let previousSleepEnd = WidgetDataStore.shared.lastSleepEndDate(for: babyId)
            WidgetDataStore.shared.setLastSleepEnd(Date(), babyId: babyId)
            WidgetDataStore.shared.clearSleep(lastDurationSeconds: secs, babyId: babyId)
            sleepLA.endActivity()
            switch try? await stopSleepUC.execute(open) {
            case .saved(let saved):
                pushSleepToFirestore(saved, babyId: babyId)
            case .discarded(let discarded):
                if let previousSleepEnd {
                    WidgetDataStore.shared.setLastSleepEnd(previousSleepEnd, babyId: babyId)
                }
                BabySyncService().propagateDelete(id: discarded.id, in: "sleepLogs")
            case nil:
                break
            }
```

`BabySyncService` — тот же таргет, конструируется inline по существующему паттерну (`SleepViewModel:495`).

## Тесты

**Файл:** `MomsyTests/Features/Sleep/StopSleepUseCaseTests.swift` (новый). Переиспользует существующий `MomsyTests/Mocks/MockSleepRepository.swift` (проверен: `entries`, `delete` реализованы).

```swift
import Foundation
import Testing
@testable import Momsy

struct StopSleepUseCaseTests {

    // MARK: — Pure threshold logic

    @Test func below60SecondsIsBelowMinimum() {
        let start = Date()
        #expect(StopSleepUseCase.isBelowMinimum(start: start, end: start.addingTimeInterval(59)))
    }

    @Test func exactly60SecondsIsNotBelowMinimum() {
        let start = Date()
        #expect(!StopSleepUseCase.isBelowMinimum(start: start, end: start.addingTimeInterval(60)))
    }

    @Test func negativeDurationIsBelowMinimum() {
        let start = Date()
        #expect(StopSleepUseCase.isBelowMinimum(start: start, end: start.addingTimeInterval(-30)))
    }

    // MARK: — Use case behavior

    @Test func shortSessionIsDeletedAndReportedDiscarded() async throws {
        let repo = MockSleepRepository()
        let start = Date().addingTimeInterval(-10)
        let entry = SleepEntry(startDate: start)
        repo.entries = [entry]

        let outcome = try await StopSleepUseCase(repository: repo).execute(entry)

        guard case .discarded(let discarded) = outcome else {
            Issue.record("Expected .discarded, got \(outcome)")
            return
        }
        #expect(discarded.id == entry.id)
        #expect(repo.entries.isEmpty)
    }

    @Test func normalSessionIsSavedWithEndAndUpdatedAt() async throws {
        let repo = MockSleepRepository()
        let start = Date().addingTimeInterval(-1800)
        let entry = SleepEntry(startDate: start, updatedAt: start)
        repo.entries = [entry]
        let now = Date()

        let outcome = try await StopSleepUseCase(repository: repo).execute(entry, now: now)

        guard case .saved(let saved) = outcome else {
            Issue.record("Expected .saved, got \(outcome)")
            return
        }
        #expect(saved.endDate == now)
        #expect(saved.updatedAt == now)
        #expect(repo.entries.first?.endDate == now)
    }

    @Test func boundarySessionAtExactlyMinimumIsSaved() async throws {
        let repo = MockSleepRepository()
        let now = Date()
        let entry = SleepEntry(startDate: now.addingTimeInterval(-StopSleepUseCase.minimumDuration))
        repo.entries = [entry]

        let outcome = try await StopSleepUseCase(repository: repo).execute(entry, now: now)

        guard case .saved = outcome else {
            Issue.record("Expected .saved at exact threshold")
            return
        }
        #expect(repo.entries.count == 1)
    }
}
```

**pbxproj:** новый тест-файл требует четырёх вставок по паттерну `AppLegalLinksTests.swift` из коммита `4afa541` (PBXBuildFile, PBXFileReference, children группы `MomsyTests/Features/Sleep`, Sources phase тест-таргета). Сгенерировать свежие 24-hex ID, не переиспользовать существующие.

**Регрессия существующих тестов:** `SleepViewModelTests.swift` содержит свои фейки `SleepRepository` и, вероятно, дергает `stop()`. После смены сигнатуры прогнать весь тест-таргет; если тесты матчат старый возврат `SleepEntry` — обновить на `StopSleepOutcome`.

## Definition of Done

- [ ] `StopSleepUseCase` возвращает `StopSleepOutcome`; порог 60 с; отрицательная длительность → discard
- [ ] Оба вызывающих (`SleepViewModel.stop`, `QuickLogCoordinator.stopSleep`) обрабатывают discard: локальное удаление уже сделано use case'ом, облако — через `propagateDelete(id:in: "sleepLogs")`
- [ ] `previousSleepEnd` восстанавливается в discard-ветке обоих путей
- [ ] `grep -rn "stopSleepUC.execute" --include="*.swift" Momsy/` — ровно 2 вызова, оба со switch
- [ ] `StopSleepUseCaseTests` зелёные, тест-файл добавлен в pbxproj
- [ ] Весь тест-таргет зелёный (включая `SleepViewModelTests`)
- [ ] Сборка Momsy + MomsyWatch + MomsyWidget проходит

## Manual QA

1. Start → Stop через 5 с (телефон): запись не появляется в списке за сегодня, таймер сброшен, Live Activity закрыта; после pull-to-refresh/пересинка запись не воскресает.
2. Тот же сценарий на втором симуляторе (co-parent): сессия, успевшая прилететь при старте, исчезает после следующего merge (tombstone).
3. Start → Stop через 5 с в офлайне → включить сеть → перезапуск: `PendingDeletionsStore` дожимает удаление, в Firestore документа нет, tombstone есть.
4. Start → Stop через 2+ мин: запись сохраняется как раньше, форсаст обновляется.
5. Стоп с часов через 5 с: на телефоне записи нет, виджет не показывает «последний сон 0 мин» как время пробуждения (предыдущий wake-stamp восстановлен).
6. Обычный стоп с часов (2+ мин) — регрессии нет.
