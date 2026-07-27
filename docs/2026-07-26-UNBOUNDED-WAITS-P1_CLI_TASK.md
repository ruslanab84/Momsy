# P1 — Unbounded Firestore Waits (Sync Stall + Invite Hang)

> **For agentic workers:** Steps use checkbox (`- [ ]`) syntax for tracking. Execute task-by-task, commit after each task.
>
> **Заменяет** `2026-07-26-SYNC-STALL-P1_CLI_TASK.md`. Tasks 1–3 идентичны предыдущей версии (файлы в `BabySync/` не менялись с `ae94e7a`, все строки актуальны). Tasks 4–5 новые. Если Tasks 1–3 уже выполнены — начинай с Task 4.

**Goal:** Убрать неограниченные ожидания серверного ack, из-за которых офлайн одно удаление вешает синхронизацию на весь процесс, а открытие экрана «Поделиться» вешает UI навсегда.

**Architecture:** Три слоя. (1) Lease-watchdog: `isSyncing: Bool` → `syncStartedAt: Date?` с истекающей арендой, поэтому любое будущее зависание самоисцеляется. (2) Записи удаления и replay переводятся на постановку в очередь Firestore с completion-хендлером — по образцу `addLog` (`BabySyncService.swift:66-77`). (3) Там, где подтверждение записи действительно нужно (инвайт-документ должен существовать до показа QR), ожидание не убирается, а **ограничивается по времени** и превращается в видимую пользователю ошибку.

**Tech Stack:** Swift 6 / Firebase Firestore iOS SDK, Swift Testing.

**Базовый коммит:** `0120be19595ba308eebeb0ee4c07c004dcbeea8a`

---

## Контекст дефекта

Firestore вызывает completion-хендлер записи **только после подтверждения бэкендом**. Async-обёртки SDK (`try await ref.delete()`, `try await ref.setData()`, `try await batch.commit()`) построены на этих хендлерах и офлайн не возвращают управление — задача остаётся приостановленной навсегда.

В коде это уже осознано в одном месте, `BabySyncService.swift:71`:

```swift
// Firestore persists locally and syncs later; awaiting the server ack can hang callers offline.
ref.setData(payload) { error in ... }
```

Но в трёх других местах вывод не применён.

### A. Sync-пайплайн (Tasks 1–3)

| Строка | Вызов |
|---|---|
| `BabySyncService.swift:151` | `try await collection(subcollection).document(id).delete()` |
| `BabySyncService.swift:158` | `try await collection("deletions").document(id).setData(...)` |
| `BabySyncService.swift:280-281` | `retryPendingDeletions` вызывает оба в цикле |
| `BabySyncService.swift:260` | `replayPendingWrites` — `try await ... .setData(payload, merge: true)` |

Цепочка отказа:

1. Пользователь удаляет запись офлайн → `propagateDelete` (`:189`) кладёт id в `PendingDeletionsStore` и запускает `Task`, который навсегда виснет на `:151`.
2. Запись остаётся в `PendingDeletionsStore` между запусками — это её штатное поведение.
3. Следующий запуск: `downloadAndMergeWhenReady` (`CloudSyncDownloader.swift:131`) ставит `isSyncing = true` и на `:336` делает `await service.retryPendingDeletions()`.
4. Внутри — тот же зависающий `delete()`. Управление не возвращается.
5. `defer { isSyncing = false }` (`:132`) **не выполняется**, потому что функция не завершилась.
6. Все последующие входы отсекаются: `resyncAll` (`:232`), `resyncSleepLive` (`:211`), `forceResyncAll` (`:251`). Синхронизация мертва до перезапуска — и повторяется на каждом запуске, пока сеть не вернётся.

Ущерб: второй родитель не получает никаких обновлений. Ошибок в UI нет.

### B. Экран «Поделиться» (Task 4)

`FirestoreInviteService.writeToFirestore:154` — `try await ...setData(data, merge: true)`. `prepareInvite():98` и `regenerateAndSync():106` ждут `pendingWrite?.value`. Дальше `SharingViewModel.presentInvite():41-51`:

```swift
isPreparingInvite = true
let code = try await inviteService.prepareInvite()   // офлайн не вернётся
...
isPreparingInvite = false                            // не выполнится
```

Спиннер крутится вечно, `saveError` не выставляется, кнопка заблокирована гардом `!isPreparingInvite` до перезапуска. То же в `regenerateInvite:70-80` и в `OnboardingViewModel.prepareInvite(regenerate:):396-416`. Плюс `revokeInvite:86` — `try await ...delete()`.

**Вероятность срабатывания выросла после P0.** `canReuseCachedInvite` теперь отбрасывает legacy-коды, поэтому каждая уже установленная сборка при первом открытии «Поделиться» идёт через `regenerate()` → новую запись в Firestore. Раньше кэш чаще переиспользовался и запись пропускалась.

**Здесь fire-and-forget неприемлем.** Показать QR для инвайта, которого нет в Firestore, хуже, чем показать ошибку: ко-родитель отсканирует и получит «код недействителен». Поэтому ожидание не убирается, а ограничивается по времени и даёт явную ошибку.

### C. `LocalInviteService` (Task 5)

`LocalInviteService.swift:27` остался на старом формате `MOMSY-1234` (10⁴ вариантов) — единственное место, которое P0 не централизовал. Выбирается в `AppContainer.swift:40-42` когда `FirebaseBootstrapper.isConfigured == false`, то есть только в dev-сборках без `GoogleService-Info.plist`. В прод не попадает, но `FamilyManager.joinFamily` теперь отклоняет такие коды через `InviteCodeFormat.isValid` → локальный режим join сломан.

### Почему lease-watchdog нужен отдельно от исправления причин

Даже после Tasks 2–4 остаются awaited-записи на пути запуска: `migrateFromFamilyPathIfNeeded` → `copyDocs` → `batch.commit()` (`:411`) и `purgeLegacyQuickLogsOnce` → `deleteAllDocs` → `batch.commit()` (`:311`). Они срабатывают реже (разовые, под флагом), но класс дефекта тот же. Watchdog делает так, что любое такое зависание перестаёт быть терминальным. Поэтому Task 1 идёт первым.

### Что НЕ входит в scope

- `deletedAt` на серверном времени вместо клиентского (P0 #2 из ревью) — трогает ту же `writeTombstone`, но меняет семантику watermark'а. Отдельная задача, см. Follow-up.
- Перевод `copyDocs` / `deleteAllDocs` на постановку в очередь — требует перестройки флага миграции и контракта GDPR-стирания, где подтверждение обязано быть настоящим. Закрыто watchdog'ом, см. Follow-up.
- Ошибки синхронизации в UI (P1 #6 из ревью). Task 4 закрывает только путь инвайта.

---

## File Structure

| Файл | Ответственность |
|---|---|
| `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift` | **Modify.** `isSyncing: Bool` → `syncStartedAt: Date?`; чистая `isSyncInFlight`. |
| `Momsy/Services/Firebase/BabySync/BabySyncService.swift` | **Modify.** Удаление, tombstone и replay ставятся в очередь; `DeleteAckPair` сводит два ack в один исход. |
| `Momsy/Services/Firebase/FirestoreAck.swift` | **Create.** Ограниченное по времени ожидание completion-based записи. Один примитив, переиспользуемый вне BabySync. |
| `Momsy/Features/Sharing/Data/Services/FirestoreInviteService.swift` | **Modify.** Запись инвайта ждёт ack не дольше таймаута; `revokeInvite` не ждёт вовсе. |
| `Momsy/Features/Sharing/Data/Services/LocalInviteService.swift` | **Modify.** Генерация через `InviteCodeFormat`. |
| `Momsy/Core/Localization/L10n.swift` | **Modify.** Один новый ключ, 7 языков. |
| `MomsyTests/Features/Sync/ResyncDebounceTests.swift` | **Modify.** Миграция сигнатуры + тесты аренды. |
| `MomsyTests/Features/Sync/DeleteAckPairTests.swift` | **Create.** |
| `MomsyTests/Features/Sync/AckLatchTests.swift` | **Create.** |
| `MomsyTests/Features/Sharing/LocalInviteServiceTests.swift` | **Create.** |

**pbxproj wiring.** Таргет `Momsy` использует `PBXFileSystemSynchronizedRootGroup` (`project.pbxproj:319-326`), поэтому новые **production**-файлы подхватываются с диска автоматически. Таргет `MomsyTests` использует явные `PBXFileReference` — каждый новый **тестовый** файл нужно завести вручную (как это было сделано для `InviteCodeFormatTests.swift` в P0). Инструкции — в Task 6.

---

### Task 1: Lease-watchdog вместо булева флага

**Files:**
- Modify: `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift:34`, `:80-90`, `:131-132`, `:209-211`, `:229-236`, `:249-255`
- Test: `MomsyTests/Features/Sync/ResyncDebounceTests.swift`

- [ ] **Step 1: Написать падающий тест**

Заменить содержимое `MomsyTests/Features/Sync/ResyncDebounceTests.swift` целиком:

```swift
import Testing
import Foundation
@testable import Momsy

@Suite("ResyncDebounce")
struct ResyncDebounceTests {

    @Test func skipsWhileSyncing() {
        let now = Date()
        #expect(CloudSyncDownloader.shouldSkipResync(
            syncStartedAt: now.addingTimeInterval(-5), lastSyncAt: nil,
            now: now, minInterval: 8, lease: 120) == true)
    }

    @Test func skipsWithinWindow() {
        let now = Date()
        #expect(CloudSyncDownloader.shouldSkipResync(
            syncStartedAt: nil, lastSyncAt: now.addingTimeInterval(-3),
            now: now, minInterval: 8, lease: 120) == true)
    }

    @Test func runsAfterWindow() {
        let now = Date()
        #expect(CloudSyncDownloader.shouldSkipResync(
            syncStartedAt: nil, lastSyncAt: now.addingTimeInterval(-20),
            now: now, minInterval: 8, lease: 120) == false)
    }

    @Test func runsWhenNeverSynced() {
        #expect(CloudSyncDownloader.shouldSkipResync(
            syncStartedAt: nil, lastSyncAt: nil,
            now: Date(), minInterval: 8, lease: 120) == false)
    }

    @Test("a sync older than the lease no longer blocks a new attempt")
    func wedgedSyncReleasesLease() {
        let now = Date()
        #expect(CloudSyncDownloader.shouldSkipResync(
            syncStartedAt: now.addingTimeInterval(-121), lastSyncAt: nil,
            now: now, minInterval: 8, lease: 120) == false)
    }

    @Test("lease boundary is exclusive at expiry")
    func leaseBoundary() {
        let now = Date()
        #expect(CloudSyncDownloader.isSyncInFlight(
            syncStartedAt: now.addingTimeInterval(-119), now: now, lease: 120) == true)
        #expect(CloudSyncDownloader.isSyncInFlight(
            syncStartedAt: now.addingTimeInterval(-120), now: now, lease: 120) == false)
    }

    @Test("no sync started means nothing is in flight")
    func nothingInFlight() {
        #expect(CloudSyncDownloader.isSyncInFlight(
            syncStartedAt: nil, now: Date(), lease: 120) == false)
    }
}
```

- [ ] **Step 2: Запустить тест — убедиться, что падает**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/ResyncDebounce`

Expected: FAIL — `incorrect argument label in call (have 'syncStartedAt:...', expected 'isSyncing:...')` и `cannot find 'isSyncInFlight'`.

- [ ] **Step 3: Заменить поле состояния**

`CloudSyncDownloader.swift`, строка 34:

```diff
     private var hasRun = false
-    private var isSyncing = false
+    /// Момент старта текущего sync'а, `nil` если ни один не выполняется. Дата, а не
+    /// `Bool`: зависший await не даёт отработать `defer`, и булев флаг оставался бы
+    /// поднятым до конца процесса, навсегда отсекая все последующие синхронизации.
+    private var syncStartedAt: Date?
     private var lastSyncAt: Date?
```

- [ ] **Step 4: Заменить чистые функции**

`CloudSyncDownloader.swift`, строки 80-90. Заменить:

```diff
+    /// Аренда: sync старше неё считается зависшим и больше не блокирует новую попытку.
+    /// Полный пул из 17 коллекций при холодном старте укладывается в единицы секунд,
+    /// так что 120 с не отрезают легитимный долгий пул и при этом дают восстановление
+    /// в пределах одной пользовательской сессии.
+    static let syncLease: TimeInterval = 120
+
+    /// Выполняется ли sync прямо сейчас — с учётом истечения аренды. Чистая → покрыта тестами.
+    static func isSyncInFlight(syncStartedAt: Date?,
+                               now: Date,
+                               lease: TimeInterval) -> Bool {
+        guard let syncStartedAt else { return false }
+        return now.timeIntervalSince(syncStartedAt) < lease
+    }
+
     /// Pure debounce/reentrancy decision, extracted for testability.
-    static func shouldSkipResync(isSyncing: Bool,
+    static func shouldSkipResync(syncStartedAt: Date?,
                                  lastSyncAt: Date?,
                                  now: Date,
-                                 minInterval: TimeInterval) -> Bool {
-        if isSyncing { return true }
+                                 minInterval: TimeInterval,
+                                 lease: TimeInterval = syncLease) -> Bool {
+        if isSyncInFlight(syncStartedAt: syncStartedAt, now: now, lease: lease) { return true }
         if let last = lastSyncAt, now.timeIntervalSince(last) < minInterval { return true }
         return false
     }
```

- [ ] **Step 5: Перевести четыре call-site**

`downloadAndMergeWhenReady`, строки 131-132:

```diff
         hasRun = true
-        isSyncing = true
-        defer { isSyncing = false; lastSyncAt = Date() }
+        syncStartedAt = Date()
+        defer { syncStartedAt = nil; lastSyncAt = Date() }
```

`resyncSleepLive`, строка 211:

```diff
-        guard !isSyncing else { return }
+        guard !Self.isSyncInFlight(syncStartedAt: syncStartedAt, now: Date(),
+                                   lease: Self.syncLease) else { return }
```

`resyncAll`, строки 232-236:

```diff
-        if Self.shouldSkipResync(isSyncing: isSyncing, lastSyncAt: lastSyncAt,
+        if Self.shouldSkipResync(syncStartedAt: syncStartedAt, lastSyncAt: lastSyncAt,
                                  now: Date(), minInterval: 300) { return }
         guard FamilyManager.shared.familyId != nil else { return }
-        isSyncing = true
-        defer { isSyncing = false; lastSyncAt = Date() }
+        syncStartedAt = Date()
+        defer { syncStartedAt = nil; lastSyncAt = Date() }
```

`forceResyncAll`, строки 249-255:

```diff
         let deadline = Date().addingTimeInterval(8)
-        while isSyncing && Date() < deadline {
+        while Self.isSyncInFlight(syncStartedAt: syncStartedAt, now: Date(),
+                                  lease: Self.syncLease), Date() < deadline {
             try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
         }
-        isSyncing = true
-        defer { isSyncing = false; lastSyncAt = Date() }
+        syncStartedAt = Date()
+        defer { syncStartedAt = nil; lastSyncAt = Date() }
```

- [ ] **Step 6: Проверить, что старое поле не осталось**

Run: `grep -n "isSyncing" Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift`

Expected: пусто.

- [ ] **Step 7: Запустить тесты**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/ResyncDebounce`

Expected: PASS, 7 тестов.

- [ ] **Step 8: Коммит**

```bash
git add Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift \
        MomsyTests/Features/Sync/ResyncDebounceTests.swift
git commit -m "fix(sync): expire the in-flight lease so a wedged sync cannot block forever"
```

---

### Task 2: Удаление и tombstone ставятся в очередь

**Files:**
- Modify: `Momsy/Services/Firebase/BabySync/BabySyncService.swift:148-159`, `:186-209`, `:274-291`
- Modify: `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift:336`
- Test: `MomsyTests/Features/Sync/DeleteAckPairTests.swift`

Постановка в очередь безопасна: Firestore сохраняет запись в персистентном кэше и повторяет её сам, в том числе после перезапуска. `PendingDeletionsStore` сохраняет вторую роль — множество «удаления в полёте», которое `downloadAndMerge` (`CloudSyncDownloader.swift:344`) объединяет с tombstone'ами, чтобы merge не воскресил запись. Запись очищается только когда **оба** ack получены.

Публичная сигнатура `propagateDelete` не меняется — шесть вызовов во ViewModel'ях не трогаются.

- [ ] **Step 1: Написать падающий тест**

Создать `MomsyTests/Features/Sync/DeleteAckPairTests.swift`:

```swift
import Testing
import Foundation
import FirebaseFirestore
@testable import Momsy

@Suite("DeleteAckPair")
struct DeleteAckPairTests {

    private func denied() -> NSError {
        NSError(domain: FirestoreErrorCode.errorDomain,
                code: FirestoreErrorCode.permissionDenied.rawValue)
    }

    private func offline() -> NSError {
        NSError(domain: FirestoreErrorCode.errorDomain,
                code: FirestoreErrorCode.unavailable.rawValue)
    }

    @Test("no outcome is reported until both writes have landed")
    func waitsForBothAcks() {
        var outcomes: [DeleteAckPair.Outcome] = []
        let pair = DeleteAckPair { outcomes.append($0) }

        pair.report(nil)
        #expect(outcomes.isEmpty)

        pair.report(nil)
        #expect(outcomes == [.acknowledged])
    }

    @Test("a rules denial on either write is permanent")
    func deniedIsPermanent() {
        var outcomes: [DeleteAckPair.Outcome] = []
        let pair = DeleteAckPair { outcomes.append($0) }
        pair.report(nil)
        pair.report(denied())
        #expect(outcomes == [.permanentlyDenied])
    }

    @Test("an offline failure stays retryable")
    func offlineIsTransient() {
        var outcomes: [DeleteAckPair.Outcome] = []
        let pair = DeleteAckPair { outcomes.append($0) }
        pair.report(offline())
        pair.report(nil)
        #expect(outcomes == [.transientFailure])
    }

    @Test("the first recorded failure decides the outcome")
    func firstFailureWins() {
        var outcomes: [DeleteAckPair.Outcome] = []
        let pair = DeleteAckPair { outcomes.append($0) }
        pair.report(denied())
        pair.report(offline())
        #expect(outcomes == [.permanentlyDenied])
    }

    @Test("the outcome is reported exactly once")
    func reportsOnce() {
        var outcomes: [DeleteAckPair.Outcome] = []
        let pair = DeleteAckPair { outcomes.append($0) }
        pair.report(nil)
        pair.report(nil)
        pair.report(nil)
        #expect(outcomes.count == 1)
    }
}
```

- [ ] **Step 2: Запустить тест — убедиться, что падает**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/DeleteAckPair`

Expected: FAIL — `cannot find 'DeleteAckPair' in scope`.

- [ ] **Step 3: Добавить DeleteAckPair**

`BabySyncService.swift`, вставить в конец файла, после закрывающей скобки `final class BabySyncService`:

```swift

/// Сводит два ack одного удаления (документ + tombstone) в один исход и вызывает
/// колбэк ровно один раз. Нужен потому, что обе записи ставятся в очередь Firestore
/// и подтверждаются независимо, а `PendingDeletionsStore` можно очищать только когда
/// подтверждены обе — иначе tombstone может не доехать, и запись воскреснет.
nonisolated final class DeleteAckPair: @unchecked Sendable {
    enum Outcome: Equatable {
        /// Обе записи подтверждены бэкендом.
        case acknowledged
        /// Rules отказали — для текущей роли это никогда не пройдёт.
        case permanentlyDenied
        /// Офлайн или временный сбой — повторить позже.
        case transientFailure
    }

    private let lock = NSLock()
    private var remaining = 2
    private var failure: Error?
    private let onComplete: (Outcome) -> Void

    init(onComplete: @escaping (Outcome) -> Void) {
        self.onComplete = onComplete
    }

    func report(_ error: Error?) {
        lock.lock()
        guard remaining > 0 else { lock.unlock(); return }
        if let error, failure == nil { failure = error }
        remaining -= 1
        let isDone = remaining == 0
        let recorded = failure
        lock.unlock()

        guard isDone else { return }
        guard let recorded else { return onComplete(.acknowledged) }
        onComplete(BabySyncService.isPermissionDenied(recorded) ? .permanentlyDenied
                                                                : .transientFailure)
    }
}
```

- [ ] **Step 4: Запустить тест**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/DeleteAckPair`

Expected: PASS, 5 тестов.

- [ ] **Step 5: Перевести удаление на очередь**

`BabySyncService.swift`, строки 148-159. Заменить:

```diff
-    /// Deletes a single log document by its stable id.
-    func deleteLog(id: String, from subcollection: String) async throws {
-        guard hasPath, !id.isEmpty else { return }
-        try await collection(subcollection).document(id).delete()
-    }
-
-    /// Records a tombstone so other devices remove the entry and the launch merge
-    /// never resurrects it. Keyed by the entry's stable id; collection-agnostic.
-    func writeTombstone(id: String) async throws {
-        guard hasPath, !id.isEmpty else { return }
-        try await collection("deletions").document(id).setData(["deletedAt": Timestamp(date: Date())])
-    }
+    /// Ставит в очередь удаление документа и tombstone для одного id и очищает запись
+    /// в `PendingDeletionsStore`, когда подтверждены ОБА.
+    ///
+    /// Записи именно ставятся в очередь, а не ожидаются: completion Firestore срабатывает
+    /// только после ack бэкенда, поэтому `try await ...delete()` офлайн не возвращает
+    /// управление и раньше вешал весь sync-пайплайн (`syncStartedAt` не сбрасывался).
+    /// Firestore сам сохраняет обе записи в персистентном кэше и повторяет их между
+    /// запусками, так что долговечность не теряется. Тот же приём уже применён в `addLog`.
+    ///
+    /// Идемпотентно: удаление отсутствующего документа успешно, а `setData` tombstone'а
+    /// перезаписывает ту же форму — повторная постановка на следующем запуске безвредна.
+    private func enqueueDelete(idStr: String, in subcollection: String) {
+        guard hasPath, !idStr.isEmpty, let id = UUID(uuidString: idStr) else { return }
+
+        let pair = DeleteAckPair { outcome in
+            switch outcome {
+            case .acknowledged:
+                PendingDeletionsStore.shared.remove(id: id)
+            case .permanentlyDenied:
+                // Rules никогда не пропустят это удаление для текущей роли — постоянный
+                // отказ. Снимаем запись, чтобы sync-цикл не повторял её вечно; локальное
+                // удаление остаётся только на этом устройстве.
+                PendingDeletionsStore.shared.remove(id: id)
+                Self.log.error("enqueueDelete(\(subcollection, privacy: .public)) denied by rules — dropping \(idStr, privacy: .public)")
+            case .transientFailure:
+                Self.log.info("enqueueDelete(\(subcollection, privacy: .public)) not acknowledged yet; kept pending")
+            }
+        }
+
+        collection(subcollection).document(idStr).delete { pair.report($0) }
+        collection("deletions").document(idStr)
+            .setData(["deletedAt": Timestamp(date: Date())]) { pair.report($0) }
+    }
```

- [ ] **Step 6: Упростить propagateDelete**

`BabySyncService.swift`, строки 186-209. Заменить:

```diff
     /// Propagates a local delete to the cloud: removes the doc and writes a tombstone,
     /// recording the id locally first so an offline delete is retried on next launch.
+    /// Возвращается немедленно — вызывающий никогда не ждёт сеть.
     func propagateDelete(id: UUID, in subcollection: String) {
         guard hasPath else { return }
         PendingDeletionsStore.shared.add(id: id, collection: subcollection)
-        Task {
-            do {
-                try await deleteLog(id: id.uuidString, from: subcollection)
-                try await writeTombstone(id: id.uuidString)
-                PendingDeletionsStore.shared.remove(id: id)
-            } catch {
-                if Self.isPermissionDenied(error) {
-                    // Rules will never allow this delete for the current role — a
-                    // permanent failure. Drop the entry so the sync loop doesn't
-                    // retry it forever; the local delete stays local-only.
-                    PendingDeletionsStore.shared.remove(id: id)
-                    Self.log.error("propagateDelete(\(subcollection, privacy: .public)) denied by rules — dropping pending entry \(id.uuidString, privacy: .public)")
-                } else {
-                    Self.log.info("propagateDelete(\(subcollection, privacy: .public)) failed transiently; kept pending")
-                }
-            }
-        }
+        enqueueDelete(idStr: id.uuidString, in: subcollection)
     }
```

- [ ] **Step 7: Сделать retryPendingDeletions неблокирующим**

`BabySyncService.swift`, строки 275-291. Заменить:

```diff
-    /// Retries cloud deletes that didn't complete earlier (e.g. made while offline).
-    func retryPendingDeletions() async {
+    /// Повторно ставит в очередь облачные удаления, которые ещё не подтверждены
+    /// (например, сделанные офлайн). Не `async`: постановка в очередь не блокирует,
+    /// поэтому sync-пайплайн на ней зависнуть не может.
+    func retryPendingDeletions() {
         guard cloudSyncAllowed() else { return }
-        for (idStr, collection) in PendingDeletionsStore.shared.all() {
-            do {
-                try await deleteLog(id: idStr, from: collection)
-                try await writeTombstone(id: idStr)
-                if let id = UUID(uuidString: idStr) { PendingDeletionsStore.shared.remove(id: id) }
-            } catch {
-                if Self.isPermissionDenied(error) {
-                    if let id = UUID(uuidString: idStr) { PendingDeletionsStore.shared.remove(id: id) }
-                    Self.log.error("retryPendingDeletions(\(collection, privacy: .public)) denied by rules — dropping \(idStr, privacy: .public)")
-                }
-                // Transient failures stay pending for the next sync.
-            }
-        }
+        for (idStr, subcollection) in PendingDeletionsStore.shared.all() {
+            enqueueDelete(idStr: idStr, in: subcollection)
+        }
     }
```

- [ ] **Step 8: Обновить вызов в даунлоадере**

`CloudSyncDownloader.swift`, строка 336:

```diff
-        await service.retryPendingDeletions()
+        service.retryPendingDeletions()
```

- [ ] **Step 9: Проверить, что зависающих await'ов в пути удаления не осталось**

Run: `grep -n "try await.*\.delete()\|try await.*deletions" Momsy/Services/Firebase/BabySync/BabySyncService.swift`

Expected: только строки внутри `deleteAllData` / `deleteLegacyFamilyTree` (`:324-325`, `:340-341`) — путь GDPR-стирания, который намеренно ждёт настоящего подтверждения и разобран в Follow-up.

- [ ] **Step 10: Полный прогон тестов**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: PASS. Особое внимание — `MomsyTests/Features/Sync/` в полном составе.

- [ ] **Step 11: Коммит**

```bash
git add Momsy/Services/Firebase/BabySync/BabySyncService.swift \
        Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift \
        MomsyTests/Features/Sync/DeleteAckPairTests.swift
git commit -m "fix(sync): enqueue deletes instead of awaiting server ack"
```

---

### Task 3: Убрать ожидание ack в replayPendingWrites

**Files:**
- Modify: `Momsy/Services/Firebase/BabySync/BabySyncService.swift:246-271`

`replayPendingWrites` остаётся `async` — она ждёт `currentAuthorIdentity()`, а это `getDocument()`, который офлайн обслуживается из кэша и не виснет. Три вызова в `CloudSyncDownloader.swift:137`, `:237`, `:256` не меняются. Виснет только сама запись.

Тонкость: раньше `PendingWritesStore.remove` вызывался после успешного await. Теперь — в completion-хендлере. Пока ack не пришёл, запись остаётся в очереди и будет поставлена повторно на следующем sync'е; `setData(merge: true)` идемпотентен, поэтому повтор безвреден.

- [ ] **Step 1: Реализовать**

`BabySyncService.swift`, строки 246-271. Заменить тело цикла:

```diff
             do {
                 // Re-stamp a server `updatedAt` at replay so the watermark sees the real
                 // write time (not the offline enqueue time). The sentinel was stripped at
                 // enqueue because `UserDefaults` can't persist a `FieldValue`.
                 var payload = SyncAuthorMetadata.stamp(
                     entry.payload,
                     author: await currentAuthorIdentity()
                 )
                 payload["updatedAt"] = FieldValue.serverTimestamp()
-                try await ActiveBaby.$syncTargetOverride.withValue(targetUUID) {
-                    try await collection(entry.collection).document(entry.docId)
-                        .setData(payload, merge: true)
-                }
-                PendingWritesStore.shared.remove(docId: entry.docId)
-            } catch {
-                if Self.isPermissionDenied(error) {
-                    // A rules-denied queued write can never succeed for this
-                    // role/membership; keeping it would replay-fail on every sync.
-                    PendingWritesStore.shared.remove(docId: entry.docId)
-                    Self.log.error("replayPendingWrites(\(entry.collection, privacy: .public)) denied by rules — dropping \(entry.docId, privacy: .public)")
-                }
-                // Transient failures stay pending; the next sync retries.
-            }
+                // Ставим в очередь без ожидания ack: офлайн `try await setData` не
+                // возвращает управление и вешает весь sync-пайплайн. Запись остаётся
+                // в `PendingWritesStore` до подтверждения и будет поставлена снова на
+                // следующем sync'е — `setData(merge:)` идемпотентен.
+                let docId = entry.docId
+                let subcollection = entry.collection
+                ActiveBaby.$syncTargetOverride.withValue(targetUUID) {
+                    collection(subcollection).document(docId)
+                        .setData(payload, merge: true) { error in
+                            guard let error else {
+                                PendingWritesStore.shared.remove(docId: docId)
+                                return
+                            }
+                            if Self.isPermissionDenied(error) {
+                                // A rules-denied queued write can never succeed for this
+                                // role/membership; keeping it would replay-fail on every sync.
+                                PendingWritesStore.shared.remove(docId: docId)
+                                Self.log.error("replayPendingWrites(\(subcollection, privacy: .public)) denied by rules — dropping \(docId, privacy: .public)")
+                            }
+                            // Transient failures stay pending; the next sync retries.
+                        }
+                }
```

Обрамляющий `do { ... }` убрать целиком — в теле больше нет `try`.

- [ ] **Step 2: Собрать**

Run: `xcodebuild build -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: BUILD SUCCEEDED, без `no calls to throwing functions occur within 'try' expression`.

- [ ] **Step 3: Прогнать тесты sync**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/Features/Sync`

Expected: PASS.

- [ ] **Step 4: Коммит**

```bash
git add Momsy/Services/Firebase/BabySync/BabySyncService.swift
git commit -m "fix(sync): enqueue replayed writes instead of awaiting server ack"
```

---

### Task 4: Ограниченное по времени ожидание записи инвайта

**Files:**
- Create: `Momsy/Services/Firebase/FirestoreAck.swift`
- Modify: `Momsy/Features/Sharing/Data/Services/FirestoreInviteService.swift:83-90`, `:141-156`
- Modify: `Momsy/Core/Localization/L10n.swift` (после строки 863)
- Modify: `Momsy/Core/Family/FamilyManager.swift:23-35`
- Test: `MomsyTests/Features/Sync/AckLatchTests.swift`

Почему не fire-and-forget, как в Tasks 2–3: `prepareInvite()` существует именно чтобы гарантировать, что документ инвайта есть в Firestore до показа QR. Показать код, которого нет, хуже, чем показать ошибку — ко-родитель отсканирует и получит «код недействителен». Поэтому ожидание сохраняется, но становится ограниченным.

Отмена `Task` здесь не работает: async-обёртка Firestore построена на `withCheckedContinuation`, которая не проверяет отмену, поэтому `pendingWrite?.cancel()` не разблокирует. Гонка через `withThrowingTaskGroup` тоже не работает: группа дожидается дочерние задачи при выходе из скоупа. Единственный рабочий примитив — резюмировать континуацию по таймеру, а не по завершению записи.

- [ ] **Step 1: Написать падающий тест**

Создать `MomsyTests/Features/Sync/AckLatchTests.swift`:

```swift
import Testing
import Foundation
@testable import Momsy

@Suite("AckLatch")
struct AckLatchTests {

    private struct Boom: Error {}

    @Test("the first completion wins and is delivered once")
    func firstWins() {
        var results: [Result<Void, Error>] = []
        let latch = AckLatch { results.append($0) }

        latch.finish(nil)
        latch.finish(Boom())
        latch.finish(nil)

        #expect(results.count == 1)
        #expect(latch.hasFinished)
        if case .failure = results[0] { Issue.record("expected success") }
    }

    @Test("an error delivered first is the reported outcome")
    func errorWins() {
        var results: [Result<Void, Error>] = []
        let latch = AckLatch { results.append($0) }

        latch.finish(Boom())
        latch.finish(nil)

        #expect(results.count == 1)
        guard case .failure(let error) = results[0] else {
            Issue.record("expected failure")
            return
        }
        #expect(error is Boom)
    }

    @Test("concurrent finishes still deliver exactly one outcome")
    func concurrentFinishes() async {
        let counter = Counter()
        let latch = AckLatch { _ in counter.increment() }

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<64 {
                group.addTask { latch.finish(nil) }
            }
        }

        #expect(counter.value == 1)
    }

    private final class Counter: @unchecked Sendable {
        private let lock = NSLock()
        private var count = 0
        var value: Int { lock.lock(); defer { lock.unlock() }; return count }
        func increment() { lock.lock(); count += 1; lock.unlock() }
    }
}
```

- [ ] **Step 2: Запустить тест — убедиться, что падает**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/AckLatch`

Expected: FAIL — `cannot find 'AckLatch' in scope`.

- [ ] **Step 3: Создать примитив**

Создать `Momsy/Services/Firebase/FirestoreAck.swift`:

```swift
import Foundation

/// Ошибка ограниченного ожидания записи Firestore.
enum FirestoreAckError: LocalizedError {
    /// Запись поставлена в очередь, но бэкенд не подтвердил её за отведённое время.
    case notConfirmed

    var errorDescription: String? {
        LocalizationManager.shared.strings.inviteNotConfirmedMessage
    }
}

/// Однократная защёлка: доставляет исход ровно один раз, кто бы ни пришёл первым —
/// completion-хендлер записи или таймер. Вынесена отдельно от `FirestoreAck`, чтобы
/// её можно было протестировать без Firestore.
nonisolated final class AckLatch: @unchecked Sendable {
    private let lock = NSLock()
    private var finished = false
    private let onFinish: (Result<Void, Error>) -> Void

    var hasFinished: Bool {
        lock.lock(); defer { lock.unlock() }
        return finished
    }

    init(onFinish: @escaping (Result<Void, Error>) -> Void) {
        self.onFinish = onFinish
    }

    func finish(_ error: Error?) {
        lock.lock()
        guard !finished else { lock.unlock(); return }
        finished = true
        lock.unlock()
        onFinish(error.map { .failure($0) } ?? .success(()))
    }
}

enum FirestoreAck {
    /// Ждёт подтверждения completion-based записи Firestore не дольше `timeout`.
    ///
    /// Сама запись при этом остаётся поставленной в очередь — Firestore сохранит её в
    /// персистентном кэше и повторит, когда сеть вернётся. Ограничивается только
    /// *ожидание*: `try await ref.setData(...)` офлайн не возвращает управление никогда,
    /// потому что completion срабатывает только после ack бэкенда.
    ///
    /// Бросает `FirestoreAckError.notConfirmed`, если ack не пришёл вовремя. Вызывающий
    /// обязан трактовать это как «документа в облаке может ещё не быть» и не показывать
    /// пользователю данные, зависящие от его существования.
    static func confirm(
        timeout: TimeInterval,
        _ write: (@escaping (Error?) -> Void) -> Void
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let latch = AckLatch { continuation.resume(with: $0) }
            let timer = Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                guard !Task.isCancelled else { return }
                latch.finish(FirestoreAckError.notConfirmed)
            }
            write { error in
                timer.cancel()
                latch.finish(error)
            }
        }
    }
}
```

- [ ] **Step 4: Добавить ключ локализации**

`L10n.swift`, вставить после строки 863 (`joinFailedMessage`):

```swift
    var inviteNotConfirmedMessage: String { s("Couldn’t confirm the invite code. Check your connection and try again.", "Не удалось подтвердить код приглашения. Проверьте соединение и попробуйте снова.", "Der Einladungscode konnte nicht bestätigt werden. Prüfe deine Verbindung und versuche es erneut.", "No se pudo confirmar el código de invitación. Comprueba tu conexión e inténtalo de nuevo.", "Impossible de confirmer le code d’invitation. Vérifiez votre connexion et réessayez.", "Não foi possível confirmar o código de convite. Verifica a tua ligação e tenta novamente.", "无法确认邀请码。请检查网络连接后重试。") }
```

- [ ] **Step 5: Применить в сервисе инвайтов**

`FirestoreInviteService.swift`, строки 141-156. Заменить `writeToFirestore`:

```diff
     private func writeToFirestore(
         code: String,
         expiry: Date,
         roleRaw: String? = nil,
         familyId: String
     ) async throws {
         guard let uid = Auth.auth().currentUser?.uid else { throw FamilyError.noFamilyId }
         var data: [String: Any] = [
             "familyId": familyId,
             "createdBy": uid,
             "expiresAt": Timestamp(date: expiry)
         ]
         if let roleRaw { data["roleRaw"] = roleRaw }
-        try await db.collection("invites").document(code).setData(data, merge: true)
+        // Ограниченное ожидание: `try await setData` офлайн не возвращает управление,
+        // и весь экран «Поделиться» зависал со спиннером навсегда. Здесь ack нужен
+        // по-настоящему — показывать QR для несуществующего инвайта нельзя, — поэтому
+        // ожидание не убирается, а ограничивается и превращается в видимую ошибку.
+        let ref = db.collection("invites").document(code)
+        try await FirestoreAck.confirm(timeout: Self.ackTimeout) { done in
+            ref.setData(data, merge: true, completion: done)
+        }
         defaults.set("\(familyId)|\(code)", forKey: syncedCodeKey)
     }
+
+    /// Столько ждём подтверждения бэкендом, прежде чем показать пользователю ошибку.
+    /// Хватает на медленную сотовую сеть и при этом не превращается в «зависание».
+    static let ackTimeout: TimeInterval = 10
```

- [ ] **Step 6: Убрать ожидание в revokeInvite**

`FirestoreInviteService.swift`, строки 81-90. Заменить:

```diff
     /// Best-effort revocation of the superseded code. Failure is non-fatal — the old
     /// document still self-expires via `expiresAt` (≤24h) and rules deny expired gets.
-    private func revokeInvite(_ oldCode: String?, replacedBy newCode: String) async {
+    /// Не ждём ack: результат никого не блокирует, а офлайн-ожидание удерживало
+    /// `pendingWrite` и вместе с ним весь экран «Поделиться». Firestore сам повторит
+    /// удаление, когда сеть вернётся.
+    private func revokeInvite(_ oldCode: String?, replacedBy newCode: String) {
         guard let oldCode, oldCode != newCode else { return }
-        do {
-            try await db.collection("invites").document(oldCode).delete()
-        } catch {
-            // Old code may belong to a previous family (rules deny) or be gone already.
-        }
+        // Old code may belong to a previous family (rules deny) or be gone already.
+        db.collection("invites").document(oldCode).delete { _ in }
     }
```

`FirestoreInviteService.swift`, строка 76 — убрать `await`:

```diff
             try await self.writeToFirestore(code: code, expiry: exp, familyId: familyId)
-            await self.revokeInvite(previousCode, replacedBy: code)
+            self.revokeInvite(previousCode, replacedBy: code)
```

- [ ] **Step 7: Собрать и проверить, что зависаний не осталось**

Run: `grep -n "try await db\.\|try await self\.db\." Momsy/Features/Sharing/Data/Services/FirestoreInviteService.swift`

Expected: пусто.

Run: `xcodebuild build -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: BUILD SUCCEEDED.

- [ ] **Step 8: Запустить тесты**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/AckLatch -only-testing:MomsyTests/InviteCodeFormat -only-testing:MomsyTests/FamilySwitchPolicyTests`

Expected: PASS.

- [ ] **Step 9: Коммит**

```bash
git add Momsy/Services/Firebase/FirestoreAck.swift \
        Momsy/Features/Sharing/Data/Services/FirestoreInviteService.swift \
        Momsy/Core/Localization/L10n.swift \
        MomsyTests/Features/Sync/AckLatchTests.swift
git commit -m "fix(sharing): bound the invite write wait instead of hanging offline"
```

---

### Task 5: LocalInviteService на канонический формат

**Files:**
- Modify: `Momsy/Features/Sharing/Data/Services/LocalInviteService.swift:26-31`
- Test: `MomsyTests/Features/Sharing/LocalInviteServiceTests.swift`

`LocalInviteService` выбирается в `AppContainer.swift:40-42` только когда Firebase не сконфигурирован (dev-сборки без `GoogleService-Info.plist`), и используется как дефолтный параметр в `SharingViewModel.init:84`. Его коды формата `MOMSY-1234` теперь отклоняются в `FamilyManager.joinFamily` — единственное место, которое P0 не централизовал.

- [ ] **Step 1: Написать падающий тест**

Создать `MomsyTests/Features/Sharing/LocalInviteServiceTests.swift`:

```swift
import Testing
import Foundation
@testable import Momsy

@Suite("LocalInviteService")
struct LocalInviteServiceTests {

    @Test("the local fallback issues codes in the canonical format")
    func generatesCanonicalCode() {
        let service = LocalInviteService()
        let code = service.regenerate()
        #expect(InviteCodeFormat.isValid(code))
    }

    @Test("a cached code is reused while it is still valid")
    func reusesCachedCode() {
        let service = LocalInviteService()
        let first = service.regenerate()
        #expect(service.currentCode() == first)
    }

    @Test("the invite URL round-trips through the deeplink parser")
    func urlRoundTrips() {
        let service = LocalInviteService()
        let code = service.regenerate()
        let url = service.inviteURL(for: code)
        #expect(JoinDeeplink.normalize(rawCode: url) == code)
    }
}
```

- [ ] **Step 2: Запустить тест — убедиться, что падает**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/LocalInviteService`

Expected: FAIL на `generatesCanonicalCode` — сервис выдаёт `MOMSY-1234`.

- [ ] **Step 3: Реализовать**

`LocalInviteService.swift`, строки 25-31:

```diff
     @discardableResult
     func regenerate() -> String {
-        let code = "MOMSY-\(String(format: "%04d", Int.random(in: 1000...9999)))"
+        // Тот же формат, что и в облачном сервисе: `FamilyManager.joinFamily`
+        // валидирует код через `InviteCodeFormat` до сети и отклонит любой другой.
+        let code = InviteCodeFormat.generate()
         UserDefaults.standard.set(code, forKey: codeKey)
         UserDefaults.standard.set(Date().addingTimeInterval(ttl), forKey: expiryKey)
         return code
     }
```

- [ ] **Step 4: Проверить, что старых форматов не осталось**

Run: `grep -rn '"MOMSY-\\(' --include=*.swift Momsy/`

Expected: пусто.

Run: `grep -rn 'MOMSY-' --include=*.swift Momsy/`

Expected: три строки — doc-комментарий в `JoinDeeplink.swift:16`, doc-комментарий и `placeholder` в `InviteCodeFormat.swift`.

- [ ] **Step 5: Запустить тесты**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/LocalInviteService`

Expected: PASS, 3 теста.

- [ ] **Step 6: Коммит**

```bash
git add Momsy/Features/Sharing/Data/Services/LocalInviteService.swift \
        MomsyTests/Features/Sharing/LocalInviteServiceTests.swift
git commit -m "fix(sharing): issue canonical invite codes from the local fallback"
```

---

### Task 6: Wiring новых тестовых файлов в pbxproj

**Files:**
- Modify: `Momsy.xcodeproj/project.pbxproj`

Таргет `MomsyTests` не использует синхронизированную группу, поэтому три новых тестовых файла (`DeleteAckPairTests.swift`, `AckLatchTests.swift`, `LocalInviteServiceTests.swift`) нужно завести вручную. Production-файл `FirestoreAck.swift` заводить **не нужно** — он лежит под `Momsy/`, а этот таргет синхронизирован (`project.pbxproj:319-326`).

Образец — как был заведён `InviteCodeFormatTests.swift` в P0 (коммит `19f3df4`): четыре вставки на файл.

- [ ] **Step 1: Открыть проект в Xcode**

Run: `open Momsy.xcodeproj`

Перетащить три файла в навигаторе в соответствующие группы (`MomsyTests/Features/Sync`, `MomsyTests/Features/Sharing`), убедившись, что галка Target Membership → `MomsyTests` стоит. Xcode сгенерирует уникальные ID сам — это надёжнее ручной правки pbxproj.

- [ ] **Step 2: Проверить, что все тесты видны**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/DeleteAckPair -only-testing:MomsyTests/AckLatch -only-testing:MomsyTests/LocalInviteService`

Expected: PASS, 5 + 3 + 3 = 11 тестов. Если какой-то suite не найден — файл не попал в таргет.

- [ ] **Step 3: Полный прогон**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: PASS.

Run: `npm run test:firebase-rules`

Expected: PASS (rules не менялись, прогон как регрессия).

- [ ] **Step 4: Коммит**

```bash
git add Momsy.xcodeproj/project.pbxproj
git commit -m "chore: wire new sync and sharing tests into the MomsyTests target"
```

---

## Definition of Done

**Sync-пайплайн**
- [ ] `grep -n "isSyncing" Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift` — пусто.
- [ ] `CloudSyncDownloader.isSyncInFlight` и `shouldSkipResync` — чистые статические функции, покрыты 7 тестами.
- [ ] `propagateDelete` возвращается синхронно и не создаёт `Task`; сигнатура не изменилась, шесть вызовов во ViewModel'ях не тронуты.
- [ ] `retryPendingDeletions` не `async`; `CloudSyncDownloader.swift:336` без `await`.
- [ ] `DeleteAckPair` очищает `PendingDeletionsStore` только после обоих ack, отличает `permissionDenied` от транзиентного отказа, вызывает колбэк ровно один раз.
- [ ] `replayPendingWrites` не ждёт ack записи; идемпотентность повторной постановки сохранена.

**Инвайты**
- [ ] `grep -n "try await db\." Momsy/Features/Sharing/Data/Services/FirestoreInviteService.swift` — пусто.
- [ ] `AckLatch` доставляет исход ровно один раз под конкурентными вызовами (тест на 64 задачи).
- [ ] `prepareInvite()` офлайн завершается ошибкой за ~10 с; `isPreparingInvite` сбрасывается, `saveError` показывается.
- [ ] `inviteNotConfirmedMessage` добавлен во все 7 языков.
- [ ] `grep -rn 'MOMSY-' --include=*.swift Momsy/` — только три ожидаемые строки.

**Общее**
- [ ] `xcodebuild test -scheme Momsy` — зелёный; 23 новых теста (7 `ResyncDebounce` + 5 `DeleteAckPair` + 3 `AckLatch` + 3 `LocalInviteService` + 5 уже существующих в затронутых suite'ах не сломаны).
- [ ] `npm run test:firebase-rules` — зелёный.

---

## Manual QA

Два устройства в одной семье, оба — родители, Cloud Sync consent включён.

**Sync**

1. **Воспроизведение на текущем `main`** (до фикса, для сверки). Устройство А: Airplane Mode → удалить кормление → убить приложение → запустить (офлайн) → выключить Airplane Mode. Ожидаемо **до фикса**: А не получает обновлений от Б до перезапуска.
2. **Офлайн-удаление не вешает sync.** То же, но после фикса. Ожидаемо: приложение работает, после возврата сети (~10 с) удаление доехало на Б, и последующие изменения с Б приезжают на А.
3. **Пропажа аренды.** А: Airplane Mode при запуске, дождаться таймаута, вернуть сеть. Через 2 минуты уйти в фон и вернуться. Ожидаемо: sync стартует, данные подтягиваются.
4. **Отказ по правилам не копится.** Войти няней, удалить запись, созданную родителем. Ожидаемо: одна строка `denied by rules — dropping` в консоли, `PendingDeletionsStore` очищается, повторов нет.
5. **Регресс на офлайн-создании.** А офлайн: добавить кормление → вернуть сеть. Ожидаемо: запись появляется на Б, `PendingWritesStore` пустеет.
6. **Регресс на переключении ребёнка.** Два ребёнка, офлайн добавить записи обоим, вернуть сеть. Ожидаемо: каждая запись у своего ребёнка.

**Инвайты**

7. **Офлайн «Поделиться».** А: Airplane Mode → Sharing → «Пригласить». Ожидаемо: спиннер ~10 с, затем ошибка «Не удалось подтвердить код приглашения…», кнопка снова активна. **Не** должен показаться QR.
8. **Повтор после возврата сети.** Выключить Airplane Mode, нажать «Пригласить» ещё раз. Ожидаемо: код показан, join с Б работает.
9. **Миграция legacy-кода.** До обновления записать код старого формата в `UserDefaults`, поставить новую сборку, открыть Sharing онлайн. Ожидаемо: новый код формата `MOMSY-XXXX-XXXX-XXXX`, старый документ удалён.
10. **Регенерация роли.** Сменить роль инвайта на «Няня», присоединиться с Б. Ожидаемо: Б получает роль няни.

Проверка очередей в отладке:

```swift
po PendingDeletionsStore.shared.all()
po PendingWritesStore.shared.all().map(\.docId)
```

---

## Follow-up (отдельные задачи)

1. **P0 #2 — `deletedAt` на серверном времени.** Внутри `enqueueDelete`: `Timestamp(date: Date())` → `FieldValue.serverTimestamp()`. Требует отката watermark'а `deletions` на `max(deletedAt) − 5 s` в `CloudSyncDownloader.swift:390-393`. Сейчас расхождение часов клиента и сервера теряет удаления между родителями безвозвратно. **Следующий по приоритету.**
2. **`copyDocs` / `deleteAllDocs` — `batch.commit()` без ограничения.** `BabySyncService.swift:311`, `:411`. Watchdog из Task 1 делает зависание невечным, но миграция офлайн задержит первый sync до истечения аренды. Для GDPR-стирания подтверждение обязано быть настоящим — там нужен `FirestoreAck.confirm` с ошибкой в UI, а не постановка в очередь. Примитив из Task 4 уже готов.
3. **P1 #6 из ревью — отказы записи не видны пользователю.** Completion-хендлеры в `BabySyncService` пишут в `os.Logger` и молчат в UI. Нужен канал ошибок синхронизации до экрана.
4. **P2 из второго ревью — среднее в CSV по полному периоду.** `LogReportViewModel.swift:97-99`: клампить `range.to` по `min(range.to, Date())`, иначе пятого числа месяца знаменатель 31 при данных за 5 дней.
5. **P3 — локализованные строки как ключи группировки** в `GenerateReportUseCase.categoryLabel` / `averageCategories`. Группировать по `BlobKind`, локализовать при рендере.
