# P1 — Today feeding card shows stale "X ч назад" after timer stop

## Symptom
Stopping the feeding timer creates a log entry (visible in "Сегодня уже было"), but `TodayFeedingCard` keeps showing the *previous* feeding's "N ч M мин назад" (e.g. entry at 20:27 exists, card shows "5 ч 44 мин назад" = the 14:45 feeding).

## Root causes (verified against `main`)
1. **Watch stop path bypasses the ViewModel.** `QuickLogCoordinator.stopFeeding()` (`Momsy/Core/WatchSync/QuickLogCoordinator.swift:65`) saves via `logFeeding.execute` directly to the repository. `FeedingViewModel.todayEntries` is never refreshed, so `lastFeedAgoString` (`FeedingViewModel.swift:42`, reads `todayEntries.last`) stays stale until the view is recreated.
2. **Co-parent sync bypasses the ViewModel.** `CloudSyncDownloader` upserts feeding records and posts `.cloudSyncDidMerge` (`Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift:7`), but `FeedingViewModel` does not observe it.
3. **In-app stop flashes stale state.** `stopFeeding()` (`FeedingViewModel.swift:108`) flips `feedingSessionExists = false` synchronously, while the save + `todayEntries.append(saved)` happens in a detached `Task`. The card renders the stale "ago" until the append lands; if the save throws, it stays stale permanently.
4. **"Ago" string never re-ticks.** `lastFeedAgoString` is computed from `Date()` at render time. `TodayView` already has a 60s `now` ticker (`TodayView.swift`, `@State private var now`), but the card doesn't depend on it.

## Fix

### 1. `Momsy/Core/WatchSync/QuickLogCoordinator.swift`
Post a notification after the watch-side save commits. In `stopFeeding()`, replace the trailing `Task`:

```swift
        Task {
            if let saved = try? await logFeeding.execute(durationSeconds: seconds, side: side) {
                pushFeedingToFirestore(saved)
                NotificationCenter.default.post(name: .feedingLogDidChange, object: nil)
            }
        }
```

Add at the bottom of the file (same pattern as `CloudSyncDownloader.cloudSyncDidMerge`):

```swift
extension Notification.Name {
    /// Posted after a feeding log is written outside `FeedingViewModel`
    /// (Watch quick actions), so in-memory ViewModels can reload.
    static let feedingLogDidChange = Notification.Name("feedingLogDidChange")
}
```

### 2. `Momsy/Features/Feeding/Presentation/ViewModel/FeedingViewModel.swift`

**2a.** Add a cancellables property next to `pausedFeedingSeconds`:

```swift
    private var cancellables = Set<AnyCancellable>()
```

**2b.** At the end of `init`, subscribe to both external-write signals:

```swift
        NotificationCenter.default.publisher(for: .feedingLogDidChange)
            .merge(with: NotificationCenter.default.publisher(for: .cloudSyncDidMerge))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { [weak self] in await self?.loadTodayEntries() }
            }
            .store(in: &cancellables)
```

**2c.** Replace the computed `lastFeedAgoString` (line 42) with a reference-date method so the card ticks with `TodayView.now`:

```swift
    func lastFeedAgoString(now: Date = Date()) -> String {
        guard let last = todayEntries.last else { return "—" }
        let mins = max(0, Int(now.timeIntervalSince(last.date) / 60))
        if mins < 60 { return lm.strings.minsAgo(mins) }
        let h = mins / 60, m = mins % 60
        return lm.strings.hrsAgoFormatted(h: h, m: m)
    }
```

**2d.** In `stopFeeding()` (line 108), make the failure path self-heal — in the `catch` block add a reload:

```swift
            } catch {
                saveError = error.localizedDescription
                await loadTodayEntries()
            }
```

### 3. `Momsy/Features/Today/Presentation/Views/TodayView.swift`

**3a.** `TodayFeedingCard` (line 481): add a `now` input after `vm`:

```swift
    @ObservedObject var vm: FeedingViewModel
    let now: Date
```

**3b.** Line 513: `Text(vm.lastFeedAgoString)` → `Text(vm.lastFeedAgoString(now: now))`

**3c.** Call site in `mainCards` (line 243):

```swift
            TodayFeedingCard(
                vm: feedingVM,
                now: now,
                openFeeding: { showFeeding = true },
                reloadTodayEntries: { Task { await vm.loadTodayEntries() } }
            )
```

## Notes
- Do **not** post `.feedingLogDidChange` from `FeedingViewModel` itself — its own writes already update `todayEntries` in memory; posting would cause a redundant fetch (Firebase cost discipline does not apply here, but SwiftData churn does).
- `WidgetDataStore.reload()` debounces 300 ms before `.widgetDataDidChange`; we deliberately use a dedicated notification tied to the *repository commit*, not the widget-state change, so the reload can't race the save.
- `Combine` is already imported in `FeedingViewModel.swift`.

## Unit tests — append to `MomsyTests/Features/Feeding/FeedingViewModelTests.swift`

```swift
    // MARK: - External write reload

    @Test("feedingLogDidChange notification reloads todayEntries")
    func notificationReloadsToday() async throws {
        let repo = MockFeedingRepository()
        let vm = makeVM(repo: repo)

        // Simulate a Watch-side write: repository only, no ViewModel involvement
        try await repo.add(FeedingEntry(date: Date(), durationSeconds: 600,
                                        side: .bottle, mood: nil, milliliters: 90))
        #expect(vm.todayEntries.isEmpty)

        NotificationCenter.default.post(name: .feedingLogDidChange, object: nil)
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(vm.todayEntries.count == 1)
        #expect(vm.todayEntries.last?.side == .bottle)
    }

    @Test("lastFeedAgoString reflects newest entry after reload")
    func agoStringUsesNewestEntry() async throws {
        let repo = MockFeedingRepository()
        let vm = makeVM(repo: repo)
        let old = Calendar.current.date(byAdding: .hour, value: -5, to: Date())!

        try await repo.add(FeedingEntry(date: old, durationSeconds: 300,
                                        side: .left, mood: nil, milliliters: nil))
        try await repo.add(FeedingEntry(date: Date(), durationSeconds: 300,
                                        side: .right, mood: nil, milliliters: nil))
        await vm.loadTodayEntries()

        let ago = vm.lastFeedAgoString(now: Date())
        #expect(!ago.contains("5"))   // must not show the 5-hour-old entry
    }
```

Adjust the `FeedingEntry` initializer arguments to the actual signature in `FeedingModels.swift` if it differs (mood/milliliters order).

## Definition of Done
- [ ] `QuickLogCoordinator.stopFeeding()` posts `.feedingLogDidChange` after successful save
- [ ] `FeedingViewModel` reloads `todayEntries` on `.feedingLogDidChange` and `.cloudSyncDidMerge`
- [ ] `lastFeedAgoString` takes a `now` parameter; card ticks with the existing 60s timer
- [ ] `stopFeeding()` reloads entries on save failure
- [ ] Existing `FeedingViewModelTests` pass; two new tests pass
- [ ] Manual QA: start timer on phone → stop on Watch → Today card immediately shows "0 мин назад" (no restart needed)
- [ ] Manual QA: stop timer in-app → card shows fresh "ago" with no stale flash
