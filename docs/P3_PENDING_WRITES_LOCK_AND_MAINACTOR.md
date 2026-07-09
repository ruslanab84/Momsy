# P3: PendingWritesStore locking + @MainActor consistency

**Scope:** The two P3 findings from the 2026-07-07 full-project review. All signatures verified against HEAD `8cc26e9`. No manual QA — unit tests only.

1. **P3** — `PendingWritesStore`: unsynchronized read-modify-write over UserDefaults → concurrent offline writes can silently drop a pending entry
2. **P3** — `@MainActor` missing on `SymptomViewModel` and `UnitSystemManager` (main-safe by construction today, fragile)

**Deliberately deferred:** `LocalizationManager` stays non-isolated. Its `shared.strings` is read synchronously from non-UI code — `LocalPushNotificationService` (8 call sites, lines 26-148) and `CloudSyncDownloader` (lines 577, 596). Annotating it `@MainActor` turns those into isolation violations; the correct fix is injecting `Language`/strings into those services — a separate refactor task, out of P3 scope. Reads of `current` remain benign in practice (only mutated from Settings UI on main).

---

## Task 1 — Serialize `PendingWritesStore` mutations

**File:** `Momsy/Services/Firebase/BabySync/PendingWritesStore.swift`

**Why:** `add`/`remove`/`removeAll` read `raw`, transform, and write back. Two offline `setLog` calls run on the cooperative pool and can interleave the get/set → lost update → an offline log never replays. `NSLock` per method closes it; no method calls another public method, so a non-recursive lock is safe. With the lock in place the class becomes correctly `@unchecked Sendable` (remaining state: immutable `defaults`/`key` refs; UserDefaults itself is thread-safe), which also cleans up capture warnings for the shared singleton.

**Current (line 11):**
```swift
final class PendingWritesStore {
```
**Replace with:**
```swift
final class PendingWritesStore: @unchecked Sendable {
```

**Current (lines 26-28):**
```swift
    private let key = "pending_writes_v1"
    private let defaults: UserDefaults
```
**Replace with:**
```swift
    private let key = "pending_writes_v1"
    private let defaults: UserDefaults
    private let lock = NSLock()
```

**Current (`add`, lines 37-44):**
```swift
    func add(collection: String, docId: String, payload: [String: Any],
             familyId: String, babyId: String) {
        let safe = (Self.plistSafe(payload) as? [String: Any]) ?? [:]
        var items = raw.filter { ($0["docId"] as? String) != docId }
        items.append(["collection": collection, "docId": docId, "payload": safe,
                      "familyId": familyId, "babyId": babyId])
        raw = items
    }
```
**Replace with:**
```swift
    func add(collection: String, docId: String, payload: [String: Any],
             familyId: String, babyId: String) {
        let safe = (Self.plistSafe(payload) as? [String: Any]) ?? [:]
        lock.lock(); defer { lock.unlock() }
        var items = raw.filter { ($0["docId"] as? String) != docId }
        items.append(["collection": collection, "docId": docId, "payload": safe,
                      "familyId": familyId, "babyId": babyId])
        raw = items
    }
```

**Current (`all`, first line of the body):**
```swift
    func all() -> [Entry] {
        raw.compactMap { dict in
```
**Replace with:**
```swift
    func all() -> [Entry] {
        lock.lock(); defer { lock.unlock() }
        return raw.compactMap { dict in
```

**Current (lines 58-66):**
```swift
    func remove(docId: String) {
        raw = raw.filter { ($0["docId"] as? String) != docId }
    }

    func removeAll(forBaby id: UUID) {
        raw = raw.filter { ($0["babyId"] as? String) != id.uuidString }
    }

    func clear() { defaults.removeObject(forKey: key) }
```
**Replace with:**
```swift
    func remove(docId: String) {
        lock.lock(); defer { lock.unlock() }
        raw = raw.filter { ($0["docId"] as? String) != docId }
    }

    func removeAll(forBaby id: UUID) {
        lock.lock(); defer { lock.unlock() }
        raw = raw.filter { ($0["babyId"] as? String) != id.uuidString }
    }

    func clear() {
        lock.lock(); defer { lock.unlock() }
        defaults.removeObject(forKey: key)
    }
```

**Test:** `MomsyTests/Features/Sync/PendingWritesStoreTests.swift` — add to the existing `.serialized` suite (uses the `freshStore()` helper):
```swift
    @Test func concurrentAddsKeepEveryEntry() async {
        let store = freshStore()
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask {
                    store.add(collection: "feedingLogs", docId: "doc-\(i)",
                              payload: ["i": i], familyId: "fam", babyId: "baby")
                }
            }
        }
        #expect(store.all().count == 100)
    }
```

---

## Task 2 — `@MainActor` on `SymptomViewModel`

**File:** `Momsy/Features/Symptom/Presentation/ViewModel/SymptomViewModel.swift`

Pattern parity confirmed: `FeedingViewModel` is `@MainActor` (line 4) and is built by a plain `AppContainer` factory, same as `makeSymptomViewModel()` (AppContainer.swift:541) — compiles identically. No `SymptomViewModelTests` exist, nothing to adjust.

**Current (line 50):**
```swift
final class SymptomViewModel: ObservableObject {
```
**Replace with:**
```swift
@MainActor
final class SymptomViewModel: ObservableObject {
```

With the class isolated, the explicit hop in `logToDiary` becomes redundant — the `Task` inherits `MainActor`:

**Current (line 225):**
```swift
            await MainActor.run { withAnimation { diaryLogged = false } }
```
**Replace with:**
```swift
            withAnimation { diaryLogged = false }
```

---

## Task 3 — `@MainActor` on `UnitSystemManager`

**File:** `Momsy/Core/Units/UnitSystemManager.swift`

Usage verified: outside Views, `shared` is touched only by `SettingsViewModel` (line 18), which is already `@MainActor`. Widget and Watch targets don't reference it.

**Current (line 42):**
```swift
final class UnitSystemManager: ObservableObject {
```
**Replace with:**
```swift
@MainActor
final class UnitSystemManager: ObservableObject {
```

---

## Definition of Done

- [ ] `PendingWritesStore`: `NSLock` guards `add`/`all`/`remove`/`removeAll`/`clear`; class marked `@unchecked Sendable`
- [ ] `concurrentAddsKeepEveryEntry` green; existing `PendingWritesStoreTests` green unchanged
- [ ] `SymptomViewModel` and `UnitSystemManager` annotated `@MainActor`; redundant `MainActor.run` removed
- [ ] `LocalizationManager` untouched (deferred — see rationale above)
- [ ] Project builds Debug + Release without new concurrency warnings
- [ ] Full unit test suite green (Swift Testing, Momsy scheme)
