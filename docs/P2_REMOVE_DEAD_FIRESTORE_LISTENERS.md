# P2 — Удаление мёртвых Firestore-листенеров (TodayViewModel + стримы BabySyncRepository)

## Контекст

`TodayViewModel.startSyncListeners()` держит два постоянных snapshot-листенера (`feedingLogs`, `sleepLogs`, `order by startedAt`, `limit 50`) на всю сессию приложения. Результаты пишутся в `syncedFeedingLogs` / `syncedSleepLogs`, которые **нигде не читаются** (проверено grep по main @ 87526d2) — UI обновляется через `.cloudSyncDidMerge`. Каждая запись любого члена семьи биллит reads на каждом устройстве без какой-либо функции. Дополнительно `BabySyncRepository.map` не прокидывает `onTermination` во внутренний Task — при деините VM Firestore-листенер остаётся жить навсегда.

Стримы `feedingLogs` / `sleepLogs` / `diaperLogs` больше нигде не потребляются → удаляем всю поверхность: протокол, обе имплементации, `map`-хелпер и `streamLogs`/`streamLogsByField` в `BabySyncService`. **`streamLogUpdates` не трогать** — его использует `SleepLiveSyncService`.

## Файлы

1. `Momsy/Features/Today/Presentation/ViewModel/TodayViewModel.swift`
2. `Momsy/Core/BabySync/Domain/Protocols/BabySyncRepositoryProtocol.swift`
3. `Momsy/Services/Firebase/BabySync/BabySyncRepository.swift`
4. `Momsy/Services/Firebase/BabySync/NoOpBabySyncRepository.swift`
5. `Momsy/Services/Firebase/BabySync/BabySyncService.swift`
6. `MomsyTests/Features/Today/TodayViewModelTests.swift`
7. `MomsyTests/Features/Onboarding/OnboardingViewModelTests.swift`

---

## 1. TodayViewModel.swift

Удалить properties (строки 25, 32–33):

```swift
    private var syncTasks: [Task<Void, Never>] = []
```
```swift
    private var syncedFeedingLogs: [FeedingLog] = []
    private var syncedSleepLogs: [SleepLog] = []
```

Удалить вызов в `init` (строка 57):

```swift
        startSyncListeners()
```

В `deinit` (строки 67–71) удалить первую строку:

```swift
        syncTasks.forEach { $0.cancel() }
```

(остальное в deinit — `tipRefreshTask?.cancel()` и снятие `mergeObserver` — оставить.)

Удалить метод целиком (строки 143–156):

```swift
    private func startSyncListeners() {
        syncTasks.append(Task { [weak self] in
            guard let feedingLogs = self?.syncRepo.feedingLogs else { return }
            for await logs in feedingLogs {
                self?.syncedFeedingLogs = logs
            }
        })
        syncTasks.append(Task { [weak self] in
            guard let sleepLogs = self?.syncRepo.sleepLogs else { return }
            for await logs in sleepLogs {
                self?.syncedSleepLogs = logs
            }
        })
    }
```

`syncRepo` как зависимость оставить — используется в `addSyncedFeeding` (`syncRepo.addFeedingLog`).

## 2. BabySyncRepositoryProtocol.swift

Удалить три строки (4–6):

```swift
    var feedingLogs: AsyncStream<[FeedingLog]> { get }
    var sleepLogs:   AsyncStream<[SleepLog]>   { get }
    var diaperLogs:  AsyncStream<[DiaperLog]>  { get }
```

## 3. BabySyncRepository.swift

Удалить три computed vars (строки 10–20):

```swift
    var feedingLogs: AsyncStream<[FeedingLog]> {
        map(service.streamLogs(from: "feedingLogs") as AsyncStream<[FeedingLogDTO]>) { $0.domain }
    }

    var sleepLogs: AsyncStream<[SleepLog]> {
        map(service.streamLogs(from: "sleepLogs") as AsyncStream<[SleepLogDTO]>) { $0.domain }
    }

    var diaperLogs: AsyncStream<[DiaperLog]> {
        map(service.streamLogsByField(from: "diaperLogs", orderField: "loggedAt") as AsyncStream<[DiaperLogDTO]>) { $0.domain }
    }
```

Удалить private-хелпер целиком (строки 76–89):

```swift
    private func map<DTO: Decodable, Model>(
        _ base: AsyncStream<[DTO]>,
        transform: @escaping (DTO) -> Model
    ) -> AsyncStream<[Model]> {
        AsyncStream { continuation in
            Task {
                for await items in base {
                    continuation.yield(items.map(transform))
                }
                continuation.finish()
            }
        }
    }
```

## 4. NoOpBabySyncRepository.swift

Удалить (строки 4–6):

```swift
    var feedingLogs: AsyncStream<[FeedingLog]> { emptyStream() }
    var sleepLogs: AsyncStream<[SleepLog]> { emptyStream() }
    var diaperLogs: AsyncStream<[DiaperLog]> { emptyStream() }
```

И теперь неиспользуемый хелпер (строки 24–29):

```swift
    private func emptyStream<T>() -> AsyncStream<[T]> {
        AsyncStream { continuation in
            continuation.yield([])
            continuation.finish()
        }
    }
```

## 5. BabySyncService.swift

Удалить `streamLogs` целиком (объявление на строке ~390, `func streamLogs<T: Decodable>(from:limit:) -> AsyncStream<[T]>` с листенером `order(by: "startedAt")`) и `streamLogsByField` целиком (строка ~428, `func streamLogsByField<T: Decodable>(from:orderField:limit:)`).

**НЕ трогать** `streamLogUpdates(from:since:)` (строка ~409) — используется live sleep-синком.

## 6–7. Тестовые моки

`MomsyTests/Features/Today/TodayViewModelTests.swift`, строки 6–8, удалить:

```swift
    var feedingLogs: AsyncStream<[FeedingLog]> { AsyncStream { $0.finish() } }
    var sleepLogs: AsyncStream<[SleepLog]>     { AsyncStream { $0.finish() } }
    var diaperLogs: AsyncStream<[DiaperLog]>   { AsyncStream { $0.finish() } }
```

`MomsyTests/Features/Onboarding/OnboardingViewModelTests.swift`, строки 10–12, удалить те же три строки из `TrackingBabySyncRepository`.

---

## Definition of Done

- [ ] `grep -rn 'feedingLogs\|sleepLogs\|diaperLogs' Momsy MomsyTests --include='*.swift'` не находит stream-объявлений/потреблений (остаются только строковые имена коллекций `"feedingLogs"` и т.п. в сервисе/даунлоадере и `.feedingLogDidChange`).
- [ ] `grep -rn 'streamLogs\|streamLogsByField' Momsy MomsyTests` — пусто; `streamLogUpdates` на месте.
- [ ] `startSyncListeners`, `syncTasks`, `syncedFeedingLogs`, `syncedSleepLogs` отсутствуют в проекте.
- [ ] Сборка зелёная: `xcodebuild -scheme Momsy -destination 'generic/platform=iOS' build`.
- [ ] Тесты зелёные: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16'`.

## Manual QA

1. Запустить приложение, открыть Today. **Ожидание:** карточки кормления/сна/подгузников заполняются как раньше (данные идут из SwiftData + `.cloudSyncDidMerge`).
2. Два устройства, одна семья: на A добавить кормление, на B свернуть/развернуть приложение. **Ожидание:** запись появляется (foreground-ресинк работает).
3. Live sleep (после P1-фикса): старт сна на A виден на B — регрессии от удаления стримов нет (live-путь идёт через `streamLogUpdates`, он не тронут).
4. Firebase console → Usage: в простое приложения read-запросы к `feedingLogs`/`sleepLogs` не тикают на каждую запись других устройств (раньше — два постоянных snapshot-листенера).
