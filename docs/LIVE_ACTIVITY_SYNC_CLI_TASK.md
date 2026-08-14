# LIVE ACTIVITY CROSS-DEVICE TERMINATION — Fix Plan

> **For agentic workers:** выполнять задача-за-задачей. Шаги помечены `- [ ]`.
> Каждая задача = отдельный коммит. Не рефакторить ничего вне списка файлов.

**Anchor commit:** `aaa49e3b3c45ac7ad9b1d914c6a42a46c6766940` (`main`, 2026-08-13)

**Баг:** Родитель A запускает сон → у родителя B появляется Live Activity. A останавливает сон → у B Live Activity продолжает считать, и виджет тоже.

**Корневая причина:** у устройства B нет ни одного канала доставки события, пока приложение не в форграунде. Live Activity создаётся с `pushType: nil` (`SleepLiveActivityManager.swift:25`), `UIBackgroundModes` содержит только `audio` (`Momsy/Info.plist:7-10`), APNs/FCM в проекте нет, а `SleepLiveSyncService` снимает Firestore-листенер при уходе в фон (`MomsyApp.swift:249`). Единственный код, гасящий Live Activity — `SleepViewModel.handleCloudMerge()` — требует живого приложения.

**Architecture:** Две фазы. Фаза 1 — локальные правки без бэкенда: честный `staleDate` вместо ложного таймера, закрытие гонки на форграунде, разумный бюджет виджета, ограничение окна зеркалирования. Фаза 2 — APNs Live Activity push: устройство отдаёт `pushToken` в Firestore, Cloud Function на закрытие `sleepLogs` шлёт `event: "end"` всем токенам семьи кроме автора.

**Tech Stack:** Swift 6 / SwiftUI / ActivityKit / WidgetKit / Swift Testing · Node 22 / firebase-functions v7 / APNs HTTP/2 · Firestore

---

## Порядок выполнения

| # | Задача | Фаза | Sev | Нужен бэкенд |
|---|--------|------|-----|--------------|
| T1 | `staleDate` вместо вечного тикающего таймера | 1 | P1 | нет |
| T2 | Гонка catch-up на форграунде | 1 | P1 | нет |
| T3 | Бюджет обновлений виджета | 1 | P2 | нет |
| T4 | Не зеркалить чужую сессию дольше лимита ActivityKit | 1 | P2 | нет |
| T5 | Явное epoch-кодирование `ContentState` | 2 | P0 | подготовка |
| T6 | Push-токен Live Activity → Firestore | 2 | P0 | да |
| T7 | Firestore rules + очистка токенов | 2 | P0 | да |
| T8 | APNs-отправитель в Cloud Functions | 2 | P0 | да |
| T9 | Триггер на закрытие `sleepLogs` | 2 | P0 | да |
| T10 | Тесты | 1+2 | P1 | — |

**Фаза 1 (T1-T4) самодостаточна и релизится отдельно.** Она не чинит корень, но убирает худшее: вместо уверенно неправильного тикающего таймера B увидит «Обновление…».

---

## Структура файлов

**Создать:**
- `Momsy/Core/Widget/LiveActivityPolicy.swift` — единая политика `staleDate`
- `Momsy/Services/Firebase/LiveActivityTokenService.swift` — выгрузка push-токена
- `functions/apns.js` — APNs HTTP/2 клиент с ES256 JWT
- `functions/live-activity.js` — сборка и рассылка `end`-пуша
- `functions/test/apns.test.js`
- `functions/test/live-activity.test.js`
- `MomsyTests/Features/Sleep/SleepActivityContentStateTests.swift`

**Изменить:**
- `Momsy/Core/Widget/SleepLiveActivityManager.swift`
- `Momsy/Core/Widget/WalkLiveActivityManager.swift`
- `Momsy/Core/Widget/BathLiveActivityManager.swift`
- `Momsy/Core/Widget/PumpingLiveActivityManager.swift`
- `Momsy/Core/Widget/FeedingLiveActivityManager.swift`
- `Momsy/Core/Widget/SleepActivityAttributes.swift`
- `Momsy/Features/Sleep/Presentation/ViewModel/SleepViewModel.swift`
- `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift`
- `Momsy/Services/Firebase/BabySync/BabySyncService.swift`
- `Momsy/Services/Firebase/BabySync/SleepLiveSyncService.swift`
- `MomsyWidget/MomsyWidgetProvider.swift`
- `firestore.rules`
- `tests/firebase-rules.test.mjs`
- `functions/index.js`
- `functions/family-departure-cleanup.js`
- `functions/package.json`
- `Momsy.xcodeproj/project.pbxproj`

**Про pbxproj:** таргет `Momsy` использует `PBXFileSystemSynchronizedRootGroup`, новые файлы под `Momsy/` регистрировать не нужно. Новые файлы под `MomsyTests/` — нужно (T10, Шаг 5).

---

## Подготовка

- [ ] **Шаг 0.1: Свежий клон**

```bash
git clone https://github.com/ruslanab84/Momsy.git && cd Momsy
git log -1 --format=%H
# ожидается: aaa49e3b3c45ac7ad9b1d914c6a42a46c6766940
git checkout -b fix/live-activity-cross-device
```

- [ ] **Шаг 0.2: Зафиксировать исходное состояние**

```bash
grep -c "staleDate: nil" Momsy/Core/Widget/*.swift | paste -sd' '
grep -n "pushType: nil" Momsy/Core/Widget/SleepLiveActivityManager.swift
grep -n "UIBackgroundModes" -A4 Momsy/Info.plist
```
Ожидается: 8 вхождений `staleDate: nil` суммарно, `pushType: nil` на строке 25, `UIBackgroundModes` = только `audio`.

---

# ФАЗА 1 — локальные правки

# T1 · `staleDate` вместо вечного тикающего таймера (P1)

**Files:**
- Create: `Momsy/Core/Widget/LiveActivityPolicy.swift`
- Modify: `Momsy/Core/Widget/SleepLiveActivityManager.swift:24,46`
- Modify: `Momsy/Core/Widget/WalkLiveActivityManager.swift:24`
- Modify: `Momsy/Core/Widget/BathLiveActivityManager.swift:24`
- Modify: `Momsy/Core/Widget/PumpingLiveActivityManager.swift:24`
- Modify: `Momsy/Core/Widget/FeedingLiveActivityManager.swift:26,40,48`

## Обоснование

Все пять виджет-вью уже содержат ветку «данные устарели»:

```
MomsyWidget/SleepLiveActivityView.swift:60:    if context.isStale {
MomsyWidget/WalkLiveActivityView.swift:50:     if context.isStale {
MomsyWidget/BathLiveActivityView.swift:50:     if context.isStale {
MomsyWidget/PumpingLiveActivityView.swift:54:  if context.isStale {
MomsyWidget/FeedingLiveActivityView.swift:91:  if context.isStale {
```

но все восемь мест создания/обновления контента передают `staleDate: nil`, поэтому `context.isStale` **никогда** не становится `true`. UI для честного состояния написан, а триггер выключен. Пользователь B видит уверенно неправильные цифры вместо «Обновление…».

- [ ] **Шаг 1: Написать падающий тест политики**

Дописать в `MomsyTests/Features/Sleep/SleepViewModelTests.swift` **не надо** — создать новый файл на Шаге 5 T10. Сейчас достаточно реализации; тест политики добавляется в T10.

- [ ] **Шаг 2: Создать единую политику**

`Momsy/Core/Widget/LiveActivityPolicy.swift`:

```swift
import Foundation

/// Live Activities are started with `pushType: nil`, so a co-parent's device cannot be
/// told that the session ended while the app is not running. Without a stale date the
/// widget would keep rendering a confidently wrong timer for hours. Marking the content
/// stale flips every Live Activity view to its already-localized "Updating…" branch.
enum LiveActivityPolicy {
    /// How long a locally-driven Live Activity may be trusted without a refresh.
    static let staleInterval: TimeInterval = 30 * 60

    /// Hard ceiling ActivityKit enforces on an active Live Activity.
    static let maxActiveDuration: TimeInterval = 8 * 3600

    static func staleDate(from reference: Date = Date()) -> Date {
        reference.addingTimeInterval(staleInterval)
    }
}
```

- [ ] **Шаг 3: Применить в `SleepLiveActivityManager`**

BEFORE (`SleepLiveActivityManager.swift:22-26`):

```swift
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil, relevanceScore: 75),
                pushType: nil
            )
```

AFTER:

```swift
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(
                    state: state,
                    staleDate: LiveActivityPolicy.staleDate(),
                    relevanceScore: 75
                ),
                pushType: nil
            )
```

BEFORE (`SleepLiveActivityManager.swift:45-48`):

```swift
                await existing.end(
                    ActivityContent(state: state, staleDate: nil, relevanceScore: 0),
                    dismissalPolicy: .immediate
                )
```

AFTER (без изменений — при завершении `staleDate` не нужен, активность немедленно снимается). Оставить как есть.

- [ ] **Шаг 4: Применить в остальных четырёх менеджерах**

`WalkLiveActivityManager.swift:24`, `BathLiveActivityManager.swift:24`, `PumpingLiveActivityManager.swift:24` — одинаковая замена:

BEFORE:
```swift
                content: ActivityContent(state: state, staleDate: nil, relevanceScore: 75),
```
AFTER:
```swift
                content: ActivityContent(
                    state: state,
                    staleDate: LiveActivityPolicy.staleDate(),
                    relevanceScore: 75
                ),
```

`FeedingLiveActivityManager.swift:26` — та же замена. Дополнительно строки 40 и 48:

BEFORE:
```swift
        Task { await activity.update(ActivityContent(state: state, staleDate: nil)) }
```
AFTER:
```swift
        Task {
            await activity.update(
                ActivityContent(state: state, staleDate: LiveActivityPolicy.staleDate())
            )
        }
```

Обе строки (40 и 48) правятся одинаково.

- [ ] **Шаг 5: Проверить**

```bash
grep -rc "staleDate: nil" Momsy/Core/Widget/*.swift
```
Ожидается: `1` только в `SleepLiveActivityManager.swift` (строка 46, путь завершения), `0` во всех остальных.

- [ ] **Шаг 6: Коммит**

```bash
git add Momsy/Core/Widget
git commit -m "fix(live-activity): mark content stale instead of showing a wrong timer

All five Live Activity views already render an 'Updating…' branch on
context.isStale, but every ActivityContent passed staleDate: nil, so the
flag never fired. A co-parent whose app is not running now sees an honest
stale state instead of a timer that keeps counting after the session ended."
```

---

# T2 · Гонка catch-up на форграунде (P1)

**Files:**
- Modify: `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift:248-256`
- Modify: `Momsy/Services/Firebase/BabySync/SleepLiveSyncService.swift:24`
- Modify: `Momsy/Services/Firebase/BabySync/BabySyncService.swift:511-524`

## Обоснование

Две дыры, обе дают «B открыл приложение, а таймер всё равно идёт»:

1. `MomsyApp.swift:241-243` запускает `Task { resyncAll() }` и `sleepLiveSync.start()` одновременно. Catch-up внутри `start()` вызывает `resyncSleepLive()`, который **бейлится** по `isSyncInFlight` (аренда 120 с). Если `resyncAll` выиграл гонку и стоп-запись пришла уже после того, как он прочитал `sleepLogs`, дельта теряется обеими сторонами.
2. `SleepLiveSyncService.swift:24` подписывает стрим с `since: Date()`, то есть только на записи **строго новее момента подписки**. Стоп-запись, сделанная пока B был в фоне, уже в прошлом и в стрим не попадёт никогда.

- [ ] **Шаг 1: Дождаться аренды вместо выхода**

BEFORE (`CloudSyncDownloader.swift:248-256`):

```swift
    @MainActor
    func resyncSleepLive() async {
        guard CloudSyncConsent.isGranted() else { return }
        guard FirebaseApp.app() != nil else { return }
        guard hasRun else { return }
        guard FamilyManager.shared.familyId != nil else { return }
        guard !Self.isSyncInFlight(syncStartedAt: syncStartedAt, now: Date(),
                                   lease: Self.syncLease) else { return }
```

AFTER:

```swift
    @MainActor
    func resyncSleepLive() async {
        guard CloudSyncConsent.isGranted() else { return }
        guard FirebaseApp.app() != nil else { return }
        guard hasRun else { return }
        guard FamilyManager.shared.familyId != nil else { return }
        // A remote close is time-critical: a co-parent's Live Activity keeps counting
        // until this merge lands. Wait out a concurrent full sync (bounded) instead of
        // dropping the delta — the upsert is idempotent, so an overlap is harmless.
        let deadline = Date().addingTimeInterval(3)
        while Self.isSyncInFlight(syncStartedAt: syncStartedAt, now: Date(),
                                  lease: Self.syncLease), Date() < deadline {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }
```

- [ ] **Шаг 2: Разрешить стриму отдавать окно назад**

BEFORE (`BabySyncService.swift:511-517`):

```swift
    func streamLogUpdates(from subcollection: String, since: Date) -> AsyncStream<Void> {
        guard cloudSyncAllowed() else { return AsyncStream { $0.finish() } }
        guard hasPath else { return AsyncStream { $0.finish() } }
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let listener = collection(subcollection)
                .whereField("updatedAt", isGreaterThan: Timestamp(date: since))
                .addSnapshotListener { snapshot, _ in
```

AFTER (без изменений в сигнатуре — правится только вызывающая сторона на Шаге 3). Оставить как есть.

- [ ] **Шаг 3: Подписывать стрим с окном назад**

BEFORE (`SleepLiveSyncService.swift:15-31`):

```swift
    func start() {
        stop()
        streamTask = Task { [weak self] in
            // Catch-up first: a co-parent write made while this device was detached
            // (backgrounded) predates the listener's attach time, and the foreground
            // `resyncAll` is debounced — without this delta merge that open sleep
            // session stays invisible until the next full sync.
            await self?.downloader.resyncSleepLive()
            guard !Task.isCancelled else { return }
            let stream = BabySyncService().streamLogUpdates(from: "sleepLogs", since: Date())
            for await _ in stream {
                guard !Task.isCancelled, let self else { return }
                try? await Task.sleep(for: .milliseconds(300))
                await self.downloader.resyncSleepLive()
            }
        }
    }
```

AFTER:

```swift
    /// How far back the listener looks at attach time. A co-parent's stop written while
    /// this device was backgrounded predates the attach moment, so `since: Date()` would
    /// never deliver it and the mirrored Live Activity would keep counting.
    private static let attachLookback: TimeInterval = 15 * 60

    func start() {
        stop()
        streamTask = Task { [weak self] in
            // Catch-up first: a co-parent write made while this device was detached
            // (backgrounded) predates the listener's attach time, and the foreground
            // `resyncAll` is debounced — without this delta merge that open sleep
            // session stays invisible until the next full sync.
            await self?.downloader.resyncSleepLive()
            guard !Task.isCancelled else { return }
            let stream = BabySyncService().streamLogUpdates(
                from: "sleepLogs",
                since: Date().addingTimeInterval(-Self.attachLookback)
            )
            for await _ in stream {
                guard !Task.isCancelled, let self else { return }
                try? await Task.sleep(for: .milliseconds(300))
                await self.downloader.resyncSleepLive()
            }
        }
    }
```

Стоимость: начальный снапшот вернёт записи за последние 15 минут вместо пустого набора — обычно 0-2 документа. Мерж идемпотентен, повторное применение безвредно.

- [ ] **Шаг 4: Проверить**

```bash
grep -c "since: Date())" Momsy/Services/Firebase/BabySync/SleepLiveSyncService.swift
grep -c "attachLookback" Momsy/Services/Firebase/BabySync/SleepLiveSyncService.swift
```
Ожидается: `0` и `2`.

- [ ] **Шаг 5: Коммит**

```bash
git add Momsy/Services/Firebase/BabySync
git commit -m "fix(sync): stop losing a co-parent's sleep close on foreground

resyncSleepLive() bailed whenever a full sync held the lease, and the live
listener attached with since: Date(), so a stop written while this device
was backgrounded reached neither path. Wait out the lease (bounded) and
attach the listener with a 15 minute lookback."
```

---

# T3 · Бюджет обновлений виджета (P2)

**Files:**
- Modify: `MomsyWidget/MomsyWidgetProvider.swift:14-26`

## Обоснование

`interval: Int = isActive ? 1 : 15` просит WidgetKit перерисовывать таймлайн раз в 60 секунд при активной сессии. Виджет рисует `Text(timerInterval: start...Date.distantFuture, countsDown: false)` (`MomsySleepWidgetView.swift:50`) — системный самотикающий таймер, которому обновления таймлайна вообще не нужны. WidgetKit такой бюджет не выдаёт, троттлит запросы, и этот же выжженный бюджет задерживает коррекцию **после** реальной остановки. При этом мгновенное обновление при остановке уже обеспечено: `WidgetDataStore.clearSleep()` вызывает `reload()` → `WidgetCenter.shared.reloadAllTimelines()`.

- [ ] **Шаг 1: Убрать поминутный опрос**

BEFORE (`MomsyWidgetProvider.swift:14-26`):

```swift
    func getTimeline(in context: Context, completion: @escaping (Timeline<MomsyWidgetEntry>) -> Void) {
        let entry = liveEntry()
        // 60s refresh when feeding/sleep is active; 15min otherwise
        let isActive: Bool
        switch entry.feedingState {
        case .running: isActive = true
        default:
            if case .active = entry.sleepState { isActive = true } else { isActive = false }
        }
        let interval: Int = isActive ? 1 : 15
        let next = Calendar.current.date(byAdding: .minute, value: interval, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
```

AFTER:

```swift
    /// The active timer is drawn by the system via `Text(timerInterval:)`, so a running
    /// session needs no extra timeline refreshes. State changes arrive immediately through
    /// `WidgetCenter.reloadAllTimelines()` from `WidgetDataStore.reload()`. A tight refresh
    /// budget only burns the allowance that the post-stop correction depends on.
    private static let refreshMinutes = 15

    func getTimeline(in context: Context, completion: @escaping (Timeline<MomsyWidgetEntry>) -> Void) {
        let entry = liveEntry()
        let next = Calendar.current.date(
            byAdding: .minute, value: Self.refreshMinutes, to: .now
        ) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
```

- [ ] **Шаг 2: Проверить**

```bash
grep -c "isActive ? 1 : 15" MomsyWidget/MomsyWidgetProvider.swift
```
Ожидается: `0`.

- [ ] **Шаг 3: Коммит**

```bash
git add MomsyWidget/MomsyWidgetProvider.swift
git commit -m "perf(widget): stop requesting a timeline refresh every 60 seconds

The running timer is drawn by the system and state changes already trigger
reloadAllTimelines(), so per-minute polling only burned the refresh budget
that the post-stop correction depends on."
```

---

# T4 · Не зеркалить чужую сессию дольше лимита ActivityKit (P2)

**Files:**
- Modify: `Momsy/Features/Sleep/Presentation/ViewModel/SleepViewModel.swift:30-33,480-484`

## Обоснование

`restoreOpenSession` зеркалит чужую открытую сессию, пока она короче `maxPlausibleSleep` = 24 часа (`SleepViewModel.swift:32`). Но ActivityKit держит Live Activity максимум 8 часов активной. Создавать Live Activity для сессии, которая заведомо переживёт системный лимит, бессмысленно: она провисит до принудительного завершения системой и всё это время будет врать.

- [ ] **Шаг 1: Добавить отдельный лимит зеркалирования**

BEFORE (`SleepViewModel.swift:30-36`):

```swift
    /// Longest plausible single sleep; anything beyond this is treated as a corrupt
    /// recovered end and the orphan is discarded instead of closed.
    private static let maxPlausibleSleep: TimeInterval = 24 * 3600
    /// Window within which two independently-started open sessions are treated as
    /// the same race rather than two genuine separate naps.
    private static let duplicateStartWindow: TimeInterval = 180
```

AFTER:

```swift
    /// Longest plausible single sleep; anything beyond this is treated as a corrupt
    /// recovered end and the orphan is discarded instead of closed.
    private static let maxPlausibleSleep: TimeInterval = 24 * 3600
    /// A co-parent's open session is only mirrored while a Live Activity could still
    /// represent it honestly. ActivityKit force-ends an activity after 8 hours, so a
    /// longer session would be shown as a running timer the system is about to kill.
    private static let maxMirroredRemoteSleep = LiveActivityPolicy.maxActiveDuration
    /// Window within which two independently-started open sessions are treated as
    /// the same race rather than two genuine separate naps.
    private static let duplicateStartWindow: TimeInterval = 180
```

- [ ] **Шаг 2: Использовать его в ветке чужой сессии**

BEFORE (`SleepViewModel.swift:477-486`):

```swift
        if SleepSessionOwnership.isRemoteOwned(startedBy: entry.startedBy, currentUid: currentUid()) {
            // A co-parent's live session: this device has no local signals to judge
            // staleness, so it must never reconcile it — only mirror it while plausible.
            if SleepSessionOwnership.shouldMirrorRemoteOpen(
                start: entry.startDate, now: Date(), maxDuration: Self.maxPlausibleSleep
            ) {
                activateTimer(entry: entry, babyId: babyId)
            }
            return
        }
```

AFTER:

```swift
        if SleepSessionOwnership.isRemoteOwned(startedBy: entry.startedBy, currentUid: currentUid()) {
            // A co-parent's live session: this device has no local signals to judge
            // staleness, so it must never reconcile it — only mirror it while plausible.
            if SleepSessionOwnership.shouldMirrorRemoteOpen(
                start: entry.startDate, now: Date(), maxDuration: Self.maxMirroredRemoteSleep
            ) {
                activateTimer(entry: entry, babyId: babyId)
            }
            return
        }
```

- [ ] **Шаг 3: Проверить**

```bash
grep -c "maxMirroredRemoteSleep" Momsy/Features/Sleep/Presentation/ViewModel/SleepViewModel.swift
```
Ожидается: `2`.

- [ ] **Шаг 4: Коммит**

```bash
git add Momsy/Features/Sleep/Presentation/ViewModel/SleepViewModel.swift
git commit -m "fix(sleep): cap remote session mirroring at the ActivityKit limit

A co-parent's open session was mirrored for up to 24h while ActivityKit
force-ends a Live Activity after 8h, so the last 16h were a running timer
the system was about to kill."
```

---

# ФАЗА 2 — APNs Live Activity push

> Требует APNs Auth Key (`.p8`) из Apple Developer → Keys → Apple Push Notifications service. Entitlement `aps-environment` **уже присутствует** в `Momsy.entitlements` (production) и в debug-варианте (development) — добавлять не нужно.

# T5 · Явное epoch-кодирование `ContentState` (P0)

**Files:**
- Modify: `Momsy/Core/Widget/SleepActivityAttributes.swift`

## Обоснование

ActivityKit декодирует `content-state` из пуша обычным `JSONDecoder` со стратегией по умолчанию. Для `Date` это `.deferredToDate`, то есть число интерпретируется как **секунды с 2001-01-01**, а не с Unix-эпохи. Cloud Function, которая пошлёт привычные Unix-секунды, промахнётся на 31 год, и пуш будет отброшен как невалидный без единого сообщения об ошибке. Явное кодирование убирает эту неоднозначность целиком.

- [ ] **Шаг 1: Написать падающий тест**

Создать `MomsyTests/Features/Sleep/SleepActivityContentStateTests.swift`:

```swift
import Foundation
import Testing
@testable import Momsy

@Suite("Sleep Live Activity content state")
struct SleepActivityContentStateTests {
    @Test("dates encode as Unix epoch seconds so an APNs payload is unambiguous")
    func encodesUnixEpochSeconds() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let state = SleepActivityAttributes.ContentState(effectiveStartDate: start)

        let data = try JSONEncoder().encode(state)
        let json = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        #expect(json["effectiveStartDate"] as? Double == 1_700_000_000)
        #expect(json["endDate"] == nil)
    }

    @Test("a payload built from Unix epoch seconds decodes to the same instant")
    func decodesUnixEpochSeconds() throws {
        let payload = """
        {"effectiveStartDate": 1700000000, "endDate": 1700003600}
        """.data(using: .utf8)!

        let state = try JSONDecoder().decode(
            SleepActivityAttributes.ContentState.self, from: payload
        )

        #expect(state.effectiveStartDate == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(state.endDate == Date(timeIntervalSince1970: 1_700_003_600))
    }

    @Test("an open session runs to the distant future, a closed one stops at its end")
    func timerIntervalReflectsClosure() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = Date(timeIntervalSince1970: 1_700_003_600)

        let open = SleepActivityAttributes.ContentState(effectiveStartDate: start)
        #expect(open.timerInterval.upperBound == .distantFuture)

        let closed = SleepActivityAttributes.ContentState(effectiveStartDate: start, endDate: end)
        #expect(closed.timerInterval.upperBound == end)
    }
}
```

- [ ] **Шаг 2: Запустить и убедиться, что падает**

Зарегистрировать файл в pbxproj (см. T10, Шаг 5), затем:

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MomsyTests/SleepActivityContentStateTests 2>&1 | tail -20
```
Ожидается: FAIL на `encodesUnixEpochSeconds` — значение будет `redacted` reference-time (примерно `689_000_000`), не `1_700_000_000`.

- [ ] **Шаг 3: Ввести явное кодирование**

BEFORE (`Momsy/Core/Widget/SleepActivityAttributes.swift`, весь файл):

```swift
import ActivityKit
import Foundation

struct SleepActivityAttributes: ActivityAttributes {
    var babyName: String
    var babyGender: String? = nil

    struct ContentState: Codable, Hashable, Sendable {
        var effectiveStartDate: Date
        var endDate: Date? = nil

        var timerInterval: ClosedRange<Date> {
            effectiveStartDate...max(endDate ?? .distantFuture, effectiveStartDate)
        }
    }
}
```

AFTER:

```swift
import ActivityKit
import Foundation

struct SleepActivityAttributes: ActivityAttributes {
    var babyName: String
    var babyGender: String? = nil

    /// Dates are encoded as Unix epoch seconds on purpose. ActivityKit decodes a pushed
    /// `content-state` with a default `JSONDecoder`, where a bare `Date` number means
    /// seconds since 2001-01-01 — a backend sending ordinary Unix time would be 31 years
    /// off and the push would be dropped silently.
    struct ContentState: Codable, Hashable, Sendable {
        var effectiveStartDate: Date
        var endDate: Date?

        init(effectiveStartDate: Date, endDate: Date? = nil) {
            self.effectiveStartDate = effectiveStartDate
            self.endDate = endDate
        }

        private enum CodingKeys: String, CodingKey {
            case effectiveStartDate
            case endDate
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            effectiveStartDate = Date(
                timeIntervalSince1970: try container.decode(Double.self, forKey: .effectiveStartDate)
            )
            endDate = try container
                .decodeIfPresent(Double.self, forKey: .endDate)
                .map(Date.init(timeIntervalSince1970:))
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(effectiveStartDate.timeIntervalSince1970, forKey: .effectiveStartDate)
            try container.encodeIfPresent(endDate?.timeIntervalSince1970, forKey: .endDate)
        }

        var timerInterval: ClosedRange<Date> {
            effectiveStartDate...max(endDate ?? .distantFuture, effectiveStartDate)
        }
    }
}
```

- [ ] **Шаг 4: Прогнать тест**

```bash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MomsyTests/SleepActivityContentStateTests 2>&1 | tail -10
```
Ожидается: 3 passing.

- [ ] **Шаг 5: Коммит**

```bash
git add Momsy/Core/Widget/SleepActivityAttributes.swift MomsyTests Momsy.xcodeproj/project.pbxproj
git commit -m "feat(live-activity): encode content state dates as Unix epoch seconds

ActivityKit decodes a pushed content-state with a default JSONDecoder, where
a bare Date number is seconds since 2001-01-01. Explicit epoch coding removes
the 31-year ambiguity before the backend starts sending pushes."
```

---

# T6 · Push-токен Live Activity → Firestore (P0)

**Files:**
- Create: `Momsy/Services/Firebase/LiveActivityTokenService.swift`
- Modify: `Momsy/Core/Widget/SleepLiveActivityManager.swift`

## Обоснование

`Activity.request(..., pushType: nil)` создаёт активность без push-токена — ActivityKit физически не может завершить её удалённо. Переход на `pushType: .token` даёт токен, который надо отдать бэкенду, чтобы Cloud Function могла погасить активность на устройстве, где приложение не запущено.

- [ ] **Шаг 1: Создать сервис выгрузки токена**

`Momsy/Services/Firebase/LiveActivityTokenService.swift`:

```swift
import FirebaseAuth
import FirebaseFirestore
import Foundation

/// Publishes this device's Live Activity push token so the backend can end a mirrored
/// activity when a co-parent stops the session. Tokens are write-only for clients; the
/// Cloud Function reads them with the Admin SDK.
@MainActor
enum LiveActivityTokenService {
    enum Kind: String {
        case sleep
    }

    private static var environment: String {
        #if DEBUG
        "sandbox"
        #else
        "production"
        #endif
    }

    static func publish(token: Data, kind: Kind, babyId: UUID?, activityStartedAt: Date) async {
        guard FirebaseBootstrapper.isConfigured,
              CloudSyncConsent.isGranted(),
              let uid = Auth.auth().currentUser?.uid,
              let familyId = FamilyManager.shared.familyId
        else { return }

        let payload: [String: Any] = [
            "token": token.map { String(format: "%02x", $0) }.joined(),
            "kind": kind.rawValue,
            "babyId": babyId?.uuidString ?? "",
            "environment": environment,
            "activityStartedAt": Timestamp(date: activityStartedAt),
            "updatedAt": FieldValue.serverTimestamp(),
        ]
        do {
            try await Firestore.firestore()
                .collection("families").document(familyId)
                .collection("liveActivityTokens").document(uid)
                .setData(payload, merge: true)
        } catch {
            // Non-fatal: the local activity still works, only remote termination is lost.
            // The next activity start republishes the token.
        }
    }

    static func revoke() async {
        guard FirebaseBootstrapper.isConfigured,
              let uid = Auth.auth().currentUser?.uid,
              let familyId = FamilyManager.shared.familyId
        else { return }
        try? await Firestore.firestore()
            .collection("families").document(familyId)
            .collection("liveActivityTokens").document(uid)
            .delete()
    }
}
```

- [ ] **Шаг 2: Запрашивать токен и отдавать его**

BEFORE (`SleepLiveActivityManager.swift`, весь файл):

```swift
import ActivityKit
import Foundation
import os

@MainActor
final class SleepLiveActivityManager {
    private var activity: Activity<SleepActivityAttributes>?
    private let logger = Logger(subsystem: "RuslanAbd.Momsy", category: "LiveActivity")

    func startActivity(startDate: Date, babyName: String, babyGender: String?) {
```

AFTER:

```swift
import ActivityKit
import Foundation
import os

@MainActor
final class SleepLiveActivityManager {
    private var activity: Activity<SleepActivityAttributes>?
    private var pushTokenTask: Task<Void, Never>?
    private let logger = Logger(subsystem: "RuslanAbd.Momsy", category: "LiveActivity")

    deinit {
        pushTokenTask?.cancel()
    }

    func startActivity(startDate: Date, babyName: String, babyGender: String?, babyId: UUID? = nil) {
```

BEFORE (`SleepLiveActivityManager.swift:21-31`):

```swift
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil, relevanceScore: 75),
                pushType: nil
            )
            logger.log("Sleep: started activity \(self.activity?.id ?? "nil")")
        } catch {
            logger.error("Sleep: Activity.request failed: \(error.localizedDescription)")
        }
    }
```

AFTER (учитывает `staleDate` из T1):

```swift
        do {
            let requested = try Activity.request(
                attributes: attributes,
                content: ActivityContent(
                    state: state,
                    staleDate: LiveActivityPolicy.staleDate(),
                    relevanceScore: 75
                ),
                // A co-parent's device must be able to end this activity while the app is
                // not running; that is only possible with a push token.
                pushType: .token
            )
            activity = requested
            observePushToken(for: requested, babyId: babyId, startDate: startDate)
            logger.log("Sleep: started activity \(requested.id)")
        } catch {
            logger.error("Sleep: Activity.request failed: \(error.localizedDescription)")
        }
    }

    private func observePushToken(
        for activity: Activity<SleepActivityAttributes>,
        babyId: UUID?,
        startDate: Date
    ) {
        pushTokenTask?.cancel()
        pushTokenTask = Task { [weak self] in
            for await token in activity.pushTokenUpdates {
                guard !Task.isCancelled else { return }
                await LiveActivityTokenService.publish(
                    token: token, kind: .sleep, babyId: babyId, activityStartedAt: startDate
                )
                self?.logger.log("Sleep: published live activity push token")
            }
        }
    }
```

- [ ] **Шаг 3: Отзывать токен при завершении**

BEFORE (`SleepLiveActivityManager.swift`, метод `endActivity`, начало):

```swift
    func endActivity() {
        var activities = Activity<SleepActivityAttributes>.activities
```

AFTER:

```swift
    func endActivity() {
        pushTokenTask?.cancel()
        pushTokenTask = nil
        Task { await LiveActivityTokenService.revoke() }
        var activities = Activity<SleepActivityAttributes>.activities
```

- [ ] **Шаг 4: Передать `babyId` из вызывающего кода**

BEFORE (`SleepViewModel.swift:221-225`):

```swift
        liveActivity.startActivity(
            startDate: entry.startDate,
            babyName: appState.babyProfile?.name ?? "",
            babyGender: appState.babyProfile?.gender
        )
```

AFTER:

```swift
        liveActivity.startActivity(
            startDate: entry.startDate,
            babyName: appState.babyProfile?.name ?? "",
            babyGender: appState.babyProfile?.gender,
            babyId: babyId
        )
```

- [ ] **Шаг 5: Проверить**

```bash
grep -c "pushType: .token" Momsy/Core/Widget/SleepLiveActivityManager.swift
grep -c "pushType: nil" Momsy/Core/Widget/SleepLiveActivityManager.swift
```
Ожидается: `1` и `0`.

- [ ] **Шаг 6: Коммит**

```bash
git add Momsy/Core/Widget/SleepLiveActivityManager.swift Momsy/Services/Firebase/LiveActivityTokenService.swift Momsy/Features/Sleep/Presentation/ViewModel/SleepViewModel.swift
git commit -m "feat(live-activity): request a push token and publish it to Firestore

Without a push token ActivityKit cannot end a mirrored activity on a device
whose app is not running, which is exactly the co-parent case."
```

---

# T7 · Firestore rules и очистка токенов (P0)

**Files:**
- Modify: `firestore.rules` (внутрь `match /families/{familyId}`)
- Modify: `functions/family-departure-cleanup.js:26-28`
- Modify: `tests/firebase-rules.test.mjs`

## Обоснование

Push-токен — идентифицирующие данные устройства. Он должен быть write-only для клиента (читает только Admin SDK), писаться только своим владельцем и только членом семьи, и удаляться при выходе из семьи вместе с остальными следами пользователя — иначе это дыра в уже закрытом GDPR-контуре.

- [ ] **Шаг 1: Добавить правило**

Вставить в `firestore.rules` внутрь блока `match /families/{familyId} { ... }`, сразу **после** закрывающей `}` блока `match /members/{memberId}` и перед `match /deletedBabies/{babyId}`:

```
      // Live Activity push tokens. Write-only for clients: only the trusted backend
      // reads them to end a co-parent's mirrored activity. A token identifies a device,
      // so it is scoped to its owner and purged on departure like any other trace.
      match /liveActivityTokens/{tokenOwnerId} {
        allow read: if false;
        allow create, update: if isSignedIn()
                      && tokenOwnerId == request.auth.uid
                      && isFamilyMember(familyId)
                      && request.resource.data.keys().hasOnly([
                           'token', 'kind', 'babyId', 'environment',
                           'activityStartedAt', 'updatedAt'
                         ])
                      && request.resource.data.token is string
                      && request.resource.data.token.size() > 0
                      && request.resource.data.token.size() <= 400
                      && request.resource.data.kind in ['sleep']
                      && request.resource.data.environment in ['production', 'sandbox'];
        allow delete: if isSignedIn()
                      && (tokenOwnerId == request.auth.uid || canManageFamilyRoster(familyId));
      }
```

- [ ] **Шаг 2: Удалять токен при выходе из семьи**

BEFORE (`functions/family-departure-cleanup.js:26-28`):

```js
    await scrubInvites(db, memberRef, familyId, uid);
    await clearFamilyCreator(familyRef, memberRef, uid);
    await clearStaleUserRoute(db.collection("users").doc(uid), memberRef, familyId, uid);
```

AFTER:

```js
    await scrubInvites(db, memberRef, familyId, uid);
    await clearFamilyCreator(familyRef, memberRef, uid);
    await clearStaleUserRoute(db.collection("users").doc(uid), memberRef, familyId, uid);
    // A Live Activity push token identifies a device and must not outlive membership.
    await familyRef.collection("liveActivityTokens").doc(uid).delete();
```

- [ ] **Шаг 3: Тест правил**

Дописать в `tests/firebase-rules.test.mjs` новый тест (рядом с существующими блоками про семью):

```js
test("live activity tokens are write-only and owner-scoped", async () => {
    const tokenPath = `families/${familyId}/liveActivityTokens/${momUid}`;
    const validToken = {
        token: "a".repeat(64),
        kind: "sleep",
        babyId: "",
        environment: "sandbox",
        activityStartedAt: new Date(),
        updatedAt: new Date(),
    };

    await assertSucceeds(momDb.doc(tokenPath).set(validToken));
    // Not even the owner may read a token back.
    await assertFails(momDb.doc(tokenPath).get());
    // A co-parent may not write into someone else's token slot.
    await assertFails(dadDb.doc(tokenPath).set(validToken));
    // Unknown fields are rejected.
    await assertFails(momDb.doc(tokenPath).set({ ...validToken, harvested: true }));
    // Unknown environments are rejected.
    await assertFails(momDb.doc(tokenPath).set({ ...validToken, environment: "staging" }));
    await assertSucceeds(momDb.doc(tokenPath).delete());
});
```

Имена `familyId`, `momUid`, `momDb`, `dadDb`, `assertSucceeds`, `assertFails` взять из уже существующих тестов в этом файле — если они называются иначе, использовать локальные имена файла, не переименовывая ничего.

- [ ] **Шаг 4: Прогнать эмулятор**

```bash
node --test tests/firebase-rules.test.mjs
```
Ожидается: новый тест зелёный, остальные без регрессий.

- [ ] **Шаг 5: Коммит**

```bash
git add firestore.rules functions/family-departure-cleanup.js tests/firebase-rules.test.mjs
git commit -m "feat(rules): write-only owner-scoped live activity tokens

Tokens identify a device, so clients may write only their own slot, nobody
may read them back, and departure cleanup purges them with the rest of the
member's traces."
```

---

# T8 · APNs-отправитель в Cloud Functions (P0)

**Files:**
- Create: `functions/apns.js`
- Create: `functions/test/apns.test.js`
- Modify: `functions/package.json`

## Обоснование

Live Activity push нельзя отправить через FCM — нужен прямой HTTP/2 запрос к APNs с топиком `<bundleID>.push-type.liveactivity` и заголовком `apns-push-type: liveactivity`. Node 22 содержит `http2` из коробки; для ES256 JWT добавляется `jsonwebtoken`.

- [ ] **Шаг 1: Добавить зависимость**

BEFORE (`functions/package.json`, блок `dependencies`):

```json
  "dependencies": {
    "@apple/app-store-server-library": "^2.0.0",
    "firebase-admin": "14.2.0",
    "firebase-functions": "7.3.2"
  }
```

AFTER:

```json
  "dependencies": {
    "@apple/app-store-server-library": "^2.0.0",
    "firebase-admin": "14.2.0",
    "firebase-functions": "7.3.2",
    "jsonwebtoken": "^9.0.2"
  }
```

```bash
cd functions && npm install && cd ..
```

- [ ] **Шаг 2: Написать падающий тест полезной нагрузки**

Создать `functions/test/apns.test.js`:

```js
const assert = require("node:assert/strict");
const { test } = require("node:test");
const { endActivityPayload, apnsHost, isUnrecoverable } = require("../apns");

test("an end payload carries Unix epoch seconds, matching the Swift content state", () => {
    const startedAt = new Date("2026-08-14T20:00:00Z");
    const endedAt = new Date("2026-08-14T22:30:00Z");

    const payload = endActivityPayload({ startedAt, endedAt });

    assert.equal(payload.aps.event, "end");
    assert.equal(payload.aps.timestamp, Math.floor(endedAt.getTime() / 1000));
    assert.equal(payload.aps["dismissal-date"], Math.floor(endedAt.getTime() / 1000));
    assert.equal(
        payload.aps["content-state"].effectiveStartDate,
        Math.floor(startedAt.getTime() / 1000)
    );
    assert.equal(
        payload.aps["content-state"].endDate,
        Math.floor(endedAt.getTime() / 1000)
    );
});

test("the environment selects the matching APNs host", () => {
    assert.equal(apnsHost("production"), "https://api.push.apple.com");
    assert.equal(apnsHost("sandbox"), "https://api.sandbox.push.apple.com");
    assert.equal(apnsHost("anything-else"), "https://api.sandbox.push.apple.com");
});

test("a dead token is unrecoverable and must be pruned, a server error is not", () => {
    assert.equal(isUnrecoverable(410, "Unregistered"), true);
    assert.equal(isUnrecoverable(400, "BadDeviceToken"), true);
    assert.equal(isUnrecoverable(403, "ExpiredProviderToken"), false);
    assert.equal(isUnrecoverable(503, "ServiceUnavailable"), false);
});
```

- [ ] **Шаг 3: Запустить и убедиться, что падает**

```bash
cd functions && node --test test/apns.test.js
```
Ожидается: FAIL, `Cannot find module '../apns'`.

- [ ] **Шаг 4: Реализовать отправитель**

Создать `functions/apns.js`:

```js
const http2 = require("node:http2");
const jwt = require("jsonwebtoken");

const bundleID = "RuslanAbd.Momsy";
const liveActivityTopic = `${bundleID}.push-type.liveactivity`;
const tokenTTLSeconds = 50 * 60;

let cachedToken;

function apnsHost(environment) {
    return environment === "production"
        ? "https://api.push.apple.com"
        : "https://api.sandbox.push.apple.com";
}

function unixSeconds(date) {
    return Math.floor(date.getTime() / 1000);
}

function endActivityPayload({ startedAt, endedAt }) {
    const end = unixSeconds(endedAt);
    return {
        aps: {
            timestamp: end,
            event: "end",
            "dismissal-date": end,
            // Unix epoch seconds: SleepActivityAttributes.ContentState encodes dates the
            // same way, so ActivityKit decodes this without a reference-date mismatch.
            "content-state": {
                effectiveStartDate: unixSeconds(startedAt),
                endDate: end,
            },
        },
    };
}

function isUnrecoverable(status, reason) {
    if (status === 410) return true;
    return status === 400 && ["BadDeviceToken", "DeviceTokenNotForTopic"].includes(reason);
}

function providerToken({ authKey, keyId, teamId, now = Date.now() }) {
    if (cachedToken && cachedToken.expiresAt > now && cachedToken.keyId === keyId) {
        return cachedToken.value;
    }
    const issuedAt = Math.floor(now / 1000);
    const value = jwt.sign({ iss: teamId, iat: issuedAt }, authKey, {
        algorithm: "ES256",
        header: { alg: "ES256", kid: keyId },
    });
    cachedToken = { value, keyId, expiresAt: now + tokenTTLSeconds * 1000 };
    return value;
}

async function sendLiveActivityPush({ deviceToken, environment, payload, authKey, keyId, teamId }) {
    const client = http2.connect(apnsHost(environment));
    try {
        return await new Promise((resolve, reject) => {
            const body = Buffer.from(JSON.stringify(payload));
            const request = client.request({
                ":method": "POST",
                ":path": `/3/device/${deviceToken}`,
                "authorization": `bearer ${providerToken({ authKey, keyId, teamId })}`,
                "apns-topic": liveActivityTopic,
                "apns-push-type": "liveactivity",
                "apns-priority": "10",
                "apns-expiration": "0",
                "content-type": "application/json",
                "content-length": body.length,
            });
            let status = 0;
            let responseBody = "";
            request.on("response", (headers) => { status = headers[":status"]; });
            request.setEncoding("utf8");
            request.on("data", (chunk) => { responseBody += chunk; });
            request.on("error", reject);
            request.on("end", () => {
                let reason = "";
                try {
                    reason = JSON.parse(responseBody || "{}").reason ?? "";
                } catch {
                    reason = "";
                }
                resolve({ status, reason });
            });
            request.end(body);
        });
    } finally {
        client.close();
    }
}

module.exports = {
    apnsHost,
    endActivityPayload,
    isUnrecoverable,
    liveActivityTopic,
    sendLiveActivityPush,
};
```

- [ ] **Шаг 5: Прогнать тест**

```bash
cd functions && node --test test/apns.test.js
```
Ожидается: 3 passing.

- [ ] **Шаг 6: Коммит**

```bash
git add functions/apns.js functions/test/apns.test.js functions/package.json functions/package-lock.json
git commit -m "feat(functions): add an APNs HTTP/2 sender for Live Activity pushes

Live Activity pushes cannot go through FCM: they need the
<bundle>.push-type.liveactivity topic and apns-push-type: liveactivity."
```

---

# T9 · Триггер на закрытие `sleepLogs` (P0)

**Files:**
- Create: `functions/live-activity.js`
- Create: `functions/test/live-activity.test.js`
- Modify: `functions/index.js`

## Обоснование

Это замыкающее звено: когда родитель A закрывает сессию, документ `sleepLogs/{logId}` получает `endedAt`. Триггер рассылает `end`-пуш всем токенам семьи кроме автора, и Live Activity у B гаснет, даже если приложение B не запущено.

- [ ] **Шаг 1: Написать падающий тест отбора получателей**

Создать `functions/test/live-activity.test.js`:

```js
const assert = require("node:assert/strict");
const { test } = require("node:test");
const { didCloseSession, recipientsFor } = require("../live-activity");

test("only a null-to-set endedAt counts as closing the session", () => {
    assert.equal(didCloseSession({ endedAt: null }, { endedAt: new Date() }), true);
    assert.equal(didCloseSession({ endedAt: undefined }, { endedAt: new Date() }), true);
    assert.equal(didCloseSession({ endedAt: new Date() }, { endedAt: new Date() }), false);
    assert.equal(didCloseSession({ endedAt: null }, { endedAt: null }), false);
});

test("the parent who stopped the session is not pushed to", () => {
    const tokens = [
        { uid: "mom", token: "aaa", environment: "production", kind: "sleep" },
        { uid: "dad", token: "bbb", environment: "sandbox", kind: "sleep" },
    ];

    const recipients = recipientsFor(tokens, "mom");

    assert.equal(recipients.length, 1);
    assert.equal(recipients[0].uid, "dad");
});

test("tokens for other activity kinds are ignored", () => {
    const tokens = [
        { uid: "dad", token: "bbb", environment: "sandbox", kind: "walk" },
    ];
    assert.equal(recipientsFor(tokens, "mom").length, 0);
});
```

- [ ] **Шаг 2: Запустить и убедиться, что падает**

```bash
cd functions && node --test test/live-activity.test.js
```
Ожидается: FAIL, `Cannot find module '../live-activity'`.

- [ ] **Шаг 3: Реализовать**

Создать `functions/live-activity.js`:

```js
const { endActivityPayload, isUnrecoverable, sendLiveActivityPush } = require("./apns");

function toDate(value) {
    if (!value) return null;
    if (value instanceof Date) return value;
    if (typeof value.toDate === "function") return value.toDate();
    return null;
}

function didCloseSession(before, after) {
    return toDate(before?.endedAt) === null && toDate(after?.endedAt) !== null;
}

function recipientsFor(tokens, authorUid) {
    return tokens.filter((entry) =>
        entry.kind === "sleep"
        && typeof entry.token === "string"
        && entry.token.length > 0
        && entry.uid !== authorUid
    );
}

async function endMirroredSleepActivities(db, familyId, log, credentials) {
    const startedAt = toDate(log.startedAt);
    const endedAt = toDate(log.endedAt);
    if (!startedAt || !endedAt) return 0;

    const snapshot = await db.collection("families").doc(familyId)
        .collection("liveActivityTokens").get();
    const tokens = snapshot.docs.map((document) => ({ uid: document.id, ...document.data() }));
    const recipients = recipientsFor(tokens, log.addedBy);
    if (recipients.length === 0) return 0;

    const payload = endActivityPayload({ startedAt, endedAt });
    let delivered = 0;
    for (const recipient of recipients) {
        try {
            const { status, reason } = await sendLiveActivityPush({
                deviceToken: recipient.token,
                environment: recipient.environment,
                payload,
                ...credentials,
            });
            if (status === 200) {
                delivered += 1;
            } else if (isUnrecoverable(status, reason)) {
                await db.collection("families").doc(familyId)
                    .collection("liveActivityTokens").doc(recipient.uid).delete();
            } else {
                console.error("Live Activity push rejected", { status, reason });
            }
        } catch (error) {
            console.error("Live Activity push failed", { message: error?.message });
        }
    }
    return delivered;
}

module.exports = {
    didCloseSession,
    endMirroredSleepActivities,
    recipientsFor,
};
```

- [ ] **Шаг 4: Зарегистрировать триггер**

В `functions/index.js` добавить к существующим импортам:

```js
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { defineSecret, defineString } = require("firebase-functions/params");
const { didCloseSession, endMirroredSleepActivities } = require("./live-activity");

const apnsAuthKey = defineSecret("APNS_AUTH_KEY");
const apnsKeyId = defineString("APNS_KEY_ID");
const apnsTeamId = defineString("APNS_TEAM_ID");
```

И в конец файла:

```js
exports.endMirroredSleepActivity = onDocumentUpdated({
    document: "families/{familyId}/babies/{babyId}/sleepLogs/{logId}",
    region: "us-central1",
    secrets: [apnsAuthKey],
    retry: false,
}, async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!didCloseSession(before, after)) return;
    const delivered = await endMirroredSleepActivities(
        getFirestore(),
        event.params.familyId,
        after,
        {
            authKey: apnsAuthKey.value(),
            keyId: apnsKeyId.value(),
            teamId: apnsTeamId.value(),
        }
    );
    console.log("Ended mirrored sleep activities", { delivered });
});
```

- [ ] **Шаг 5: Задать параметры и секрет**

Дописать в `functions/.env.momsy-cf74a` (создан в подписочном таске; если его нет — создать):

```
APNS_KEY_ID=<Key ID из Apple Developer → Keys>
APNS_TEAM_ID=<Team ID из Apple Developer → Membership>
```

Секрет с приватным ключом:

```bash
firebase functions:secrets:set APNS_AUTH_KEY < /path/to/AuthKey_XXXXXXXXXX.p8
```

`.p8` в репозиторий **не коммитить**. Проверить:

```bash
git check-ignore -v /path/to/AuthKey_XXXXXXXXXX.p8 2>/dev/null; git status --porcelain | grep -c "\.p8"
```
Ожидается: `0`.

- [ ] **Шаг 6: Прогнать тесты**

```bash
cd functions && npm test
```
Ожидается: `live-activity.test.js` — 3 passing, `apns.test.js` — 3 passing, остальные без регрессий.

- [ ] **Шаг 7: Коммит**

```bash
git add functions/live-activity.js functions/test/live-activity.test.js functions/index.js functions/.env.momsy-cf74a
git commit -m "feat(functions): end a co-parent's mirrored sleep activity on close

When a sleepLogs document gains an endedAt, push event: end to every family
Live Activity token except the author's, so the mirrored activity stops even
when the co-parent's app is not running."
```

---

# T10 · Тесты (P1)

**Files:**
- Modify: `MomsyTests/Features/Sleep/SleepViewModelTests.swift`
- Modify: `Momsy.xcodeproj/project.pbxproj`

## Обоснование

`SleepViewModelTests` покрывает только локальный `stop()`. Удалённое закрытие сессии — тот самый путь, который сломан — не покрыт ничем, поэтому баг и дожил до прода.

- [ ] **Шаг 1: Тест политики stale**

Дописать в `MomsyTests/Features/Sleep/SleepActivityContentStateTests.swift` (создан в T5):

```swift
    @Test("a live activity goes stale well before ActivityKit force-ends it")
    func stalePolicyPrecedesTheHardLimit() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let stale = LiveActivityPolicy.staleDate(from: start)

        #expect(stale > start)
        #expect(stale.timeIntervalSince(start) < LiveActivityPolicy.maxActiveDuration)
    }
```

- [ ] **Шаг 2: Тест окна зеркалирования**

Дописать в `MomsyTests/Features/Sleep/SleepSessionOwnershipTests.swift`:

```swift
    @Test("a remote session longer than the ActivityKit limit is no longer mirrored")
    func remoteSessionBeyondActivityLimitIsNotMirrored() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let justUnder = start.addingTimeInterval(LiveActivityPolicy.maxActiveDuration - 60)
        let justOver = start.addingTimeInterval(LiveActivityPolicy.maxActiveDuration + 60)

        #expect(SleepSessionOwnership.shouldMirrorRemoteOpen(
            start: start, now: justUnder, maxDuration: LiveActivityPolicy.maxActiveDuration
        ))
        #expect(!SleepSessionOwnership.shouldMirrorRemoteOpen(
            start: start, now: justOver, maxDuration: LiveActivityPolicy.maxActiveDuration
        ))
    }
```

- [ ] **Шаг 3: Тест удалённого закрытия сессии**

Дописать в `MomsyTests/Features/Sleep/SleepViewModelTests.swift` (использовать уже имеющиеся в файле фабрики `makeViewModel` / `repo`; если они называются иначе, взять локальные имена файла):

```swift
    @Test("a co-parent's close ends the mirrored session on this device")
    func remoteCloseEndsMirroredSession() async throws {
        let repo = MockSleepRepository()
        let vm = makeViewModel(repo: repo, currentUid: { "device-b-uid" })

        let remoteStart = Date().addingTimeInterval(-600)
        var remote = SleepEntry(id: UUID(), startDate: remoteStart, endDate: nil)
        remote.startedBy = "device-a-uid"
        repo.entries = [remote]

        NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
        try await waitUntil { vm.isSleepActive }

        remote.endDate = Date()
        repo.entries = [remote]
        NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)

        try await waitUntil { !vm.isSleepActive }
        #expect(vm.sleepSeconds == 0)
    }
```

Если конструктор `SleepEntry` в проекте отличается по набору параметров, взять форму из уже существующих тестов в этом же файле, не меняя модель.

- [ ] **Шаг 4: Запустить и убедиться, что падает до фиксов**

```bash
git stash
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:MomsyTests/SleepViewModelTests 2>&1 | tail -20
git stash pop
```
Ожидается: тест удалённого закрытия проходит и до фиксов (он покрывает foreground-путь, который работает), но фиксирует поведение против регрессий. Если падает — значит найдена ещё одна дыра в foreground-пути, разобрать до продолжения.

- [ ] **Шаг 5: Зарегистрировать новый тестовый файл в pbxproj**

Таргет `MomsyTests` не синхронизируется с файловой системой. **Отступы — табы, не пробелы.** Четыре вставки для `SleepActivityContentStateTests.swift`:

1. Секция `PBXBuildFile`, после строки `A1B2C3D4E5F60718293A4B5C /* SleepDayWindowTests.swift in Sources */ = ...` (строка 63):
```
		D7E8F90A1B2C3D4E5F607182 /* SleepActivityContentStateTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = D7E8F90A1B2C3D4E5F607183 /* SleepActivityContentStateTests.swift */; };
```

2. Секция `PBXFileReference`, после строки `A1B2C3D4E5F60718293A4B5D /* SleepDayWindowTests.swift */ = ...` (строка 244):
```
		D7E8F90A1B2C3D4E5F607183 /* SleepActivityContentStateTests.swift */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = SleepActivityContentStateTests.swift; sourceTree = "<group>"; };
```

3. Группа `Sleep`, после `A1B2C3D4E5F60718293A4B5D /* SleepDayWindowTests.swift */,` (строка 539):
```
				D7E8F90A1B2C3D4E5F607183 /* SleepActivityContentStateTests.swift */,
```

4. Build phase `Sources`, после `A1B2C3D4E5F60718293A4B5C /* SleepDayWindowTests.swift in Sources */,` (строка 1108):
```
				D7E8F90A1B2C3D4E5F607182 /* SleepActivityContentStateTests.swift in Sources */,
```

- [ ] **Шаг 6: Прогнать всё**

```bash
cd functions && npm test && cd ..
node --test tests/firebase-rules.test.mjs
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' | tail -20
```
Ожидается: 0 failures.

- [ ] **Шаг 7: Коммит**

```bash
git add MomsyTests Momsy.xcodeproj/project.pbxproj
git commit -m "test(live-activity): cover remote close, stale policy and mirror window"
```

---

# Definition of Done

- [ ] **DoD-1 · `staleDate` включён везде, кроме пути завершения**
```bash
grep -rc "staleDate: nil" Momsy/Core/Widget/*.swift
```
Ожидается: `1` только в `SleepLiveActivityManager.swift`, `0` в остальных четырёх.

- [ ] **DoD-2 · Мёртвая ветка `isStale` теперь достижима**
```bash
grep -rc "isStale" MomsyWidget/*.swift | grep -c ":1"
grep -c "LiveActivityPolicy.staleDate()" Momsy/Core/Widget/*.swift | paste -sd' '
```
Ожидается: 5 вью с `isStale`, суммарно ≥7 вызовов `LiveActivityPolicy.staleDate()`.

- [ ] **DoD-3 · Стрим больше не подписывается «от сейчас»**
```bash
grep -c 'since: Date())' Momsy/Services/Firebase/BabySync/SleepLiveSyncService.swift
grep -c "attachLookback" Momsy/Services/Firebase/BabySync/SleepLiveSyncService.swift
```
Ожидается: `0` и `2`.

- [ ] **DoD-4 · `resyncSleepLive` не бросает дельту**
```bash
grep -c "lease: Self.syncLease) else { return }" Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift
```
Ожидается: `0`.

- [ ] **DoD-5 · Виджет не просит поминутный рефреш**
```bash
grep -c "isActive ? 1 : 15" MomsyWidget/MomsyWidgetProvider.swift
```
Ожидается: `0`.

- [ ] **DoD-6 · Окно зеркалирования равно лимиту ActivityKit**
```bash
grep -c "maxMirroredRemoteSleep" Momsy/Features/Sleep/Presentation/ViewModel/SleepViewModel.swift
grep -c "maxPlausibleSleep" Momsy/Features/Sleep/Presentation/ViewModel/SleepViewModel.swift
```
Ожидается: `2` и `2` (оставшиеся два — путь `reconcileStaleSleep`, он не меняется).

- [ ] **DoD-7 · Push-токен запрашивается**
```bash
grep -c "pushType: .token" Momsy/Core/Widget/SleepLiveActivityManager.swift
grep -c "pushTokenUpdates" Momsy/Core/Widget/SleepLiveActivityManager.swift
```
Ожидается: `1` и `1`.

- [ ] **DoD-8 · Токены недоступны на чтение клиенту**
```bash
grep -A2 "match /liveActivityTokens" firestore.rules | grep -c "allow read: if false"
```
Ожидается: `1`.

- [ ] **DoD-9 · Токен удаляется при выходе из семьи**
```bash
grep -c "liveActivityTokens" functions/family-departure-cleanup.js
```
Ожидается: `1`.

- [ ] **DoD-10 · Приватный ключ APNs не в репозитории**
```bash
git ls-files | grep -c "\.p8$"
```
Ожидается: `0`.

- [ ] **DoD-11 · Секрет и параметры заданы**
```bash
firebase functions:secrets:access APNS_AUTH_KEY >/dev/null && echo "SECRET OK"
grep -c "^APNS_KEY_ID=" functions/.env.momsy-cf74a
grep -c "^APNS_TEAM_ID=" functions/.env.momsy-cf74a
```
Ожидается: `SECRET OK`, затем `1` и `1`.

- [ ] **DoD-12 · Все тесты зелёные**
```bash
cd functions && npm test && cd ..
node --test tests/firebase-rules.test.mjs
xcodebuild test -project Momsy.xcodeproj -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' | tail -20
```
Ожидается: 0 failures.

- [ ] **DoD-13 · Релизная сборка**
```bash
xcodebuild -project Momsy.xcodeproj -scheme Momsy -configuration Release \
  -destination 'generic/platform=iOS' build | tail -5
```
Ожидается: `** BUILD SUCCEEDED **`.

---

# Manual QA Script

Нужны **два физических устройства** в одной семье (Live Activities и App Attest не работают в симуляторе) и задеплоенные функции.

### QA-1 · Базовый сценарий бага (главный)
1. Устройство A и B в одной семье, оба с активным ребёнком.
2. На A нажать «Сон».
3. **Ожидается:** на B в течение нескольких секунд появляется Live Activity с тикающим таймером.
4. **Свернуть приложение на B** (важно — не закрывать, просто свернуть).
5. На A нажать «Стоп».
6. **Ожидается:** на B Live Activity исчезает в течение нескольких секунд, **не открывая приложение**. Виджет на B показывает завершённую сессию.

Это сценарий из отчёта. До Фазы 2 он не пройдёт.

### QA-2 · Приложение на B полностью выгружено
1. Повторить QA-1, но на шаге 4 выгрузить приложение B из многозадачности.
2. **Ожидается:** Live Activity всё равно гаснет — пуш доставляется системой, приложение не требуется.

### QA-3 · Честное stale-состояние (проверяется уже после Фазы 1)
1. Временно отключить Cloud Function `endMirroredSleepActivity` в Firebase Console.
2. Повторить QA-1.
3. **Ожидается:** через 30 минут после старта Live Activity на B показывает «Обновление…» вместо тикающего таймера. Уверенно неправильных цифр быть не должно.
4. Вернуть функцию.

### QA-4 · Восстановление при открытии приложения
1. Повторить QA-1 до шага 5 включительно.
2. Сразу после остановки на A открыть приложение на B.
3. **Ожидается:** таймер на экране «Сон» остановлен, сессия показана как завершённая, Live Activity снята, виджет обновлён.

### QA-5 · Короткое сворачивание (закрывает гонку T2)
1. На A запустить сон.
2. На B свернуть приложение на 20 секунд, затем развернуть.
3. На A остановить сон **в те 20 секунд, пока B свёрнуто**.
4. **Ожидается:** сразу после разворачивания B таймер остановлен. До фикса T2 здесь было окно, где ни catch-up, ни стрим не срабатывали.

### QA-6 · Автор сессии не получает лишний пуш
1. Повторить QA-1.
2. В Firebase Console → Logs проверить запись `Ended mirrored sleep activities`.
3. **Ожидается:** `delivered` равно числу со-родителей, автор остановки в получателях отсутствует.

### QA-7 · Выход из семьи чистит токен
1. На B выйти из семьи (или удалить B из ростера с A).
2. Firebase Console → `families/{familyId}/liveActivityTokens`.
3. **Ожидается:** документа с uid устройства B нет.

### QA-8 · Мёртвый токен вычищается
1. Переустановить приложение на B (токен становится невалидным), не открывая его.
2. На A запустить и остановить сессию.
3. **Ожидается:** в логах функции APNs вернул 410, документ токена B удалён автоматически.

### QA-9 · Sandbox против production
1. Debug-сборка на B (entitlement `aps-environment: development`).
2. Повторить QA-1.
3. **Ожидается:** в Firestore у токена B поле `environment: "sandbox"`, пуш уходит на `api.sandbox.push.apple.com` и доставляется.

### QA-10 · Ночной сон дольше 8 часов
1. Вручную создать открытую сессию с `startedAt` 9 часов назад от имени со-родителя.
2. Открыть приложение на B.
3. **Ожидается:** Live Activity **не создаётся** (превышен лимит ActivityKit), но сессия видна на экране «Сон».

---

# Backlog (вне скоупа)

1. **Распространить push-завершение на остальные четыре типа** — Walk, Bath, Feeding, Pumping имеют ту же архитектуру (`pushType: nil`), но сейчас межустройственно не зеркалируются, поэтому баг для них не проявляется. Если появится зеркалирование — понадобится тот же тракт.
2. **Silent push (`content-available`) для виджета** — потребует `remote-notification` в `UIBackgroundModes`. Позволит вызвать `WidgetDataStore.clearSleep()` и `reloadAllTimelines()` в фоне, а не только при следующем открытии приложения. Сейчас виджет корректируется пушем Live Activity только визуально, данные в App Group обновятся при первом запуске приложения.
3. **Обновление Live Activity при изменении, а не только при закрытии** — если A правит время начала сессии, у B зеркало останется со старым `effectiveStartDate` до следующего форграунда. Тот же триггер, `event: "update"`.
4. **Удаление токена в `DeleteAccountUseCase`** — при полном удалении аккаунта токен чистится триггером departure-cleanup, но стоит явно проверить путь erasure и покрыть тестом, раз GDPR-контур уже закрывали.
5. **Мониторинг доставки** — счётчик `delivered` сейчас только в логах. Стоит завести метрику доли недоставленных пушей, чтобы протухшие токены не копились незаметно.
6. **`SleepLiveSyncService` не переподписывается при смене активного ребёнка внутри форграунда** — проверить, что `restart()` дергается на каждом переключении (`AppContainer.swift:154,220`), и покрыть тестом.
