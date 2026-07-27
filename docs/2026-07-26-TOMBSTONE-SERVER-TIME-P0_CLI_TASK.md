# P0 — Tombstones on Server Time

> **For agentic workers:** Steps use checkbox (`- [ ]`) syntax for tracking. Execute task-by-task, commit after each task.

**Goal:** Перевести `deletedAt` у tombstone'ов с часов клиента на серверное время, чтобы удаление, сделанное одним родителем, не терялось безвозвратно из-за расхождения часов между устройствами.

**Architecture:** Три части. (1) Запись — `FieldValue.serverTimestamp()` вместо `Timestamp(date: Date())`. (2) Чтение — неразрешённый sentinel в локальном кэше не должен двигать watermark. (3) Миграция — существующие tombstone'ы с клиентскими метками могут уже содержать время «из будущего» и отравить watermark, поэтому он один раз сбрасывается, а дальше защищён клампом по серверному потолку.

**Tech Stack:** Swift 6 / Firebase Firestore iOS SDK, Swift Testing, `@firebase/rules-unit-testing`.

**Базовый коммит:** `0120be19595ba308eebeb0ee4c07c004dcbeea8a`

---

## Контекст дефекта

`BabySyncService.swift:158`:

```swift
try await collection("deletions").document(id).setData(["deletedAt": Timestamp(date: Date())])
```

`deletedAt` пишется часами устройства. При этом весь механизм догоняющей синхронизации построен на сравнении этой метки с watermark'ом, который накапливается из меток **других** устройств (`CloudSyncDownloader.swift:344`, `:407-411`).

### Как теряется удаление

Часы устройства А отстают от сервера на 10 минут.

1. Устройство Б удаляет запись в реальный момент `T`. Tombstone: `deletedAt = T`.
2. Устройство А синхронизируется, видит tombstone, ставит `deletions`-watermark `= T` (`CloudSyncDownloader.swift:408-411`).
3. Устройство А удаляет свою запись в реальный момент `T + 1 мин`. Его часы показывают `T − 9 мин`. Tombstone пишется с `deletedAt = T − 9 мин`.
4. Устройство Б синхронизируется. Его watermark стоит на `T`. Запрос `whereField("deletedAt", isGreaterThanOrEqualTo: T)` (`BabySyncService.swift:171`) **не возвращает** tombstone устройства А: `T − 9 мин < T`.
5. Watermark у Б продолжает расти от более поздних tombstone'ов. Окно, в котором лежал tombstone А, пройдено навсегда.

**Удаление, сделанное на А, не доедет до Б никогда.** Не «с задержкой» — watermark монотонен (`advancedWatermark:98` — `max(previous, candidate)`), пропущенное окно не переоткрывается. Запись остаётся у Б живой, при этом на А её нет: устойчивое расхождение данных между родителями без единого сообщения об ошибке.

### Почему это P0, а не P1

Симметричный случай — часы А **спешат** — ещё хуже. Tombstone уходит в будущее, скажем на час вперёд. Устройство Б его подхватывает и ставит watermark на `now + 1 час`. Следующий час **все** tombstone'ы от всех устройств отсекаются фильтром. Один пользователь с неверно выставленным временем ломает распространение удалений во всей семье.

Ручная правка времени на iOS — обычное дело (родители переводят часы, чтобы обойти лимиты экранного времени; часовые пояса в поездках при выключенном автоопределении).

### Почему `updatedAt` этой болезнью не болеет

Обычные логи пишутся через `addLog` (`BabySyncService.swift:66-77`) с `FieldValue.serverTimestamp()`, и `fetchChanged` (`:507`) фильтрует по нему же. Там всё корректно с самого начала. `deletions` — единственная коллекция, выпавшая из этого правила.

### Взаимодействие с P1

Задача `2026-07-26-UNBOUNDED-WAITS-P1_CLI_TASK.md` (Task 2) заменяет `writeTombstone` на `enqueueDelete`. Порядок вмерживания:

- **Этот документ идёт первым** (текущий план). Правится `writeTombstone:156-159`. Когда P1 Task 2 будет применён, `FieldValue.serverTimestamp()` уже присутствует в строке, которую он переносит в `enqueueDelete` — конфликта нет, но при переносе **сохрани sentinel**, а не восстанавливай `Timestamp(date: Date())` из старого diff'а.
- **Если P1 уже вмержен** — применяй Step 3 Task 1 к строке внутри `enqueueDelete` вместо `writeTombstone`. Остальные задачи не меняются.

### Что НЕ входит в scope

- Ограничение размера коллекции `deletions` (P2 #11 из первого ревью) — растёт без TTL, `limit: 1000`. Отдельная задача, см. Follow-up.
- `updatedAt`-watermark'и остальных 17 коллекций — там серверное время уже используется.

---

## File Structure

| Файл | Ответственность |
|---|---|
| `Momsy/Services/Firebase/BabySync/BabySyncService.swift` | **Modify.** Запись sentinel'а; явный отбор неразрешённых меток при чтении. |
| `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift` | **Modify.** Кламп watermark'а по серверному потолку; одноразовый сброс `deletions`-watermark'а. |
| `MomsyTests/Features/Sync/TombstoneWatermarkTests.swift` | **Create.** Swift Testing для чистой функции клампа. |
| `MomsyTests/Features/Sync/WatermarkAdvanceTests.swift` | **Не трогается.** `advancedWatermark` остаётся как есть — общая для 17 коллекций. |
| `tests/firebase-rules.test.mjs` | **Modify.** Один тест: sentinel проходит правила записи tombstone'а. |

**pbxproj wiring.** Таргет `Momsy` синхронизирован (`project.pbxproj:319-326`) — production-файлы не трогаются, новых нет. Таргет `MomsyTests` использует явные `PBXFileReference`, поэтому `TombstoneWatermarkTests.swift` нужно завести вручную — см. Task 4.

---

### Task 1: Запись tombstone'а на серверном времени

**Files:**
- Modify: `Momsy/Services/Firebase/BabySync/BabySyncService.swift:154-159`, `:161-180`
- Test: `tests/firebase-rules.test.mjs`

Правила записи проверять не нужно: `deletions` попадает под общий блок `match /{subcollection}/{document=**}` (`firestore.rules:307-316`), где `allow create` не валидирует форму payload'а. Тест нужен как страховка от будущего ужесточения — если кто-то добавит `hasOnly`/типизацию, sentinel не должен молча начать отклоняться.

- [ ] **Step 1: Написать падающий rules-тест**

Добавить в `tests/firebase-rules.test.mjs` перед закрывающей строкой файла:

```javascript
test("a tombstone may be written with a server timestamp sentinel", async () => {
    const momDb = firestore(users.mom);

    await assertSucceeds(momDb.doc(`${babyPath}/deletions/server-stamped`).set({
        deletedAt: serverTimestamp(),
    }));

    // Роли без прав на ростер по-прежнему не могут ставить надгробия.
    await assertFails(firestore(users.nanny).doc(`${babyPath}/deletions/nanny-delete`).set({
        deletedAt: serverTimestamp(),
    }));
    await assertFails(firestore(users.grandma).doc(`${babyPath}/deletions/granny-delete`).set({
        deletedAt: serverTimestamp(),
    }));
});
```

В шапке файла расширить импорт (строка 9):

```diff
-import { Timestamp } from "firebase/firestore";
+import { serverTimestamp, Timestamp } from "firebase/firestore";
```

- [ ] **Step 2: Запустить — убедиться, что проходит уже сейчас**

Run: `npm run test:firebase-rules`

Expected: PASS. Тест закрепляет текущее поведение правил; он «падающий» только в том смысле, что без него регрессия правил прошла бы незамеченной. Если он **падает** — значит правила `deletions` строже, чем следует из `firestore.rules:307-316`; остановись и разберись, не меняя Swift-код.

- [ ] **Step 3: Перевести запись на sentinel**

`BabySyncService.swift`, строки 154-159. Заменить:

```diff
     /// Records a tombstone so other devices remove the entry and the launch merge
     /// never resurrects it. Keyed by the entry's stable id; collection-agnostic.
+    ///
+    /// `deletedAt` обязан быть СЕРВЕРНЫМ временем. Раньше здесь стоял `Timestamp(date: Date())`,
+    /// и tombstone от устройства с отстающими часами попадал «в прошлое» относительно
+    /// watermark'а других устройств — фильтр `deletedAt >= watermark` его не возвращал
+    /// никогда, и удаление не доезжало до второго родителя вообще. Часы, спешащие вперёд,
+    /// зеркально отравляли watermark и отсекали чужие удаления на всё время опережения.
     func writeTombstone(id: String) async throws {
         guard hasPath, !id.isEmpty else { return }
-        try await collection("deletions").document(id).setData(["deletedAt": Timestamp(date: Date())])
+        try await collection("deletions").document(id)
+            .setData(["deletedAt": FieldValue.serverTimestamp()])
     }
```

- [ ] **Step 4: Явно отбросить неразрешённые sentinel'ы при чтении**

`BabySyncService.swift`, строки 161-180. Заменить:

```diff
     /// Tombstoned ids deleted on any device, optionally only those at/after `since`.
     /// Ordered by `deletedAt` so the caller can advance a watermark; every tombstone is
-    /// written with a `deletedAt`, so the order clause excludes nothing.
+    /// written with a `deletedAt`, so the order clause excludes nothing.
+    ///
+    /// Пока сервер не подтвердил запись, локальный кэш отдаёт документ с НЕразрешённым
+    /// sentinel'ом (`deletedAt == nil` при поведении по умолчанию). Такие документы
+    /// отбрасываются: собственные незавершённые удаления и так учтены через
+    /// `PendingDeletionsStore.ids()` в `downloadAndMerge`, а пустить их в расчёт максимума
+    /// значило бы двигать watermark по метке, которой ещё не существует.
     func fetchTombstones(since: Date?, limit: Int = 1000) async throws -> [(id: String, deletedAt: Date)] {
         guard hasPath else { return [] }
         var query: Query = collection("deletions")
             .order(by: "deletedAt", descending: false)
             .limit(to: limit)
         if let since {
             query = collection("deletions")
                 .whereField("deletedAt", isGreaterThanOrEqualTo: Timestamp(date: since))
                 .order(by: "deletedAt", descending: false)
                 .limit(to: limit)
         }
         let snapshot = try await query.getDocuments()
         return snapshot.documents.compactMap { doc in
-            guard let ts = doc.data()[\"deletedAt\"] as? Timestamp else { return nil }
+            // `serverTimestampBehavior: .none` — неразрешённый sentinel приходит как `nil`
+            // и здесь же отсеивается.
+            guard let ts = doc.data(with: .none)["deletedAt"] as? Timestamp else { return nil }
             return (doc.documentID, ts.dateValue())
         }
     }
```

- [ ] **Step 5: Собрать**

Run: `xcodebuild build -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: BUILD SUCCEEDED.

- [ ] **Step 6: Убедиться, что клиентских меток в tombstone'ах не осталось**

Run: `grep -n 'deletedAt.*Timestamp(date:' Momsy/Services/Firebase/BabySync/BabySyncService.swift`

Expected: пусто. (Строка `:171` с `Timestamp(date: since)` — это параметр **фильтра**, а не записываемое значение; в выводе grep'а её быть не должно, так как там нет `deletedAt`… она содержит `deletedAt` в `whereField`. Уточнённая проверка ниже.)

Run: `grep -n 'setData(\["deletedAt"' Momsy/Services/Firebase/BabySync/BabySyncService.swift`

Expected: одна строка, с `FieldValue.serverTimestamp()`.

- [ ] **Step 7: Коммит**

```bash
git add Momsy/Services/Firebase/BabySync/BabySyncService.swift \
        tests/firebase-rules.test.mjs
git commit -m "fix(sync): stamp tombstones with server time so deletes survive clock skew"
```

---

### Task 2: Кламп watermark'а по серверному потолку

**Files:**
- Modify: `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift:92-100` (новая функция), `:407-412`
- Test: `MomsyTests/Features/Sync/TombstoneWatermarkTests.swift`

Одного серверного времени мало по двум причинам.

**Первая — унаследованные данные.** В проде уже лежат tombstone'ы с клиентскими метками. Если среди них есть метка из будущего, первый же sync после обновления поставит watermark туда, и все новые серверные метки будут отсекаться до тех пор, пока реальное время не догонит. Task 3 сбрасывает watermark один раз, но сами документы остаются — их метки продолжат участвовать в `max` при следующем полном пуле.

**Вторая — постоянная защита.** Кламп по потолку означает, что никакая одиночная аномальная метка не может увести watermark вперёд дальше, чем реально наблюдалось. Максимум, что она сделает — заставит перечитать окно. Перечитывание безвредно: `applyDeletions` идемпотентен.

Потолком берём наибольшую метку, которая **не превышает** локальное «сейчас» плюс допуск. Локальные часы здесь используются как грубый ориентир, а не как источник истины: часы позади потолка → watermark придерживается, окно перечитывается (безопасно); часы впереди → кламп не связывает, но серверные метки в будущее и не уходят.

`advancedWatermark` не трогаем — она общая для всех 17 коллекций, а особая семантика нужна только `deletions`.

- [ ] **Step 1: Написать падающий тест**

Создать `MomsyTests/Features/Sync/TombstoneWatermarkTests.swift`:

```swift
import Testing
import Foundation
@testable import Momsy

@Suite("TombstoneWatermark")
struct TombstoneWatermarkTests {
    private let epoch = Date(timeIntervalSince1970: 0)
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    @Test("a normal batch advances to its newest tombstone")
    func advancesToMax() {
        let observed = [now.addingTimeInterval(-300), now.addingTimeInterval(-60)]
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: now.addingTimeInterval(-600), observed: observed,
            now: now, tolerance: 300) == now.addingTimeInterval(-60))
    }

    @Test("a tombstone stamped far in the future cannot poison the watermark")
    func clampsFutureOutlier() {
        let sane = now.addingTimeInterval(-60)
        let poisoned = now.addingTimeInterval(3_600)
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: nil, observed: [sane, poisoned],
            now: now, tolerance: 300) == sane)
    }

    @Test("a batch of only future outliers keeps the previous watermark")
    func allOutliersKeepPrevious() {
        let previous = now.addingTimeInterval(-600)
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: previous, observed: [now.addingTimeInterval(7_200)],
            now: now, tolerance: 300) == previous)
    }

    @Test("a timestamp inside the tolerance window is accepted")
    func toleranceAcceptsSmallSkew() {
        let slightlyAhead = now.addingTimeInterval(120)
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: nil, observed: [slightlyAhead],
            now: now, tolerance: 300) == slightlyAhead)
    }

    @Test("the watermark never moves backward")
    func neverMovesBackward() {
        let previous = now.addingTimeInterval(-60)
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: previous, observed: [now.addingTimeInterval(-600)],
            now: now, tolerance: 300) == previous)
    }

    @Test("an empty batch keeps the previous watermark")
    func emptyKeepsPrevious() {
        let previous = now.addingTimeInterval(-60)
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: previous, observed: [], now: now, tolerance: 300) == previous)
    }

    @Test("an empty first pull falls back to the epoch floor")
    func emptyFirstPullFallsToEpoch() {
        #expect(CloudSyncDownloader.advancedTombstoneWatermark(
            previous: nil, observed: [], now: now, tolerance: 300) == epoch)
    }
}
```

- [ ] **Step 2: Запустить тест — убедиться, что падает**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/TombstoneWatermark`

Expected: FAIL — `cannot find 'advancedTombstoneWatermark'`. (Если suite не находится вовсе — файл ещё не заведён в таргет, это Task 4; на этом шаге ожидается именно ошибка компиляции.)

- [ ] **Step 3: Реализовать чистую функцию**

`CloudSyncDownloader.swift`, вставить после `advancedWatermark` (после строки 100):

```swift

    /// Допуск, в пределах которого метка «в будущем» считается нормальным расхождением
    /// между часами сервера и устройства, а не аномалией.
    static let tombstoneClockTolerance: TimeInterval = 300

    /// Watermark для `deletions`, устойчивый к отравлению одиночной аномальной меткой.
    ///
    /// Отличается от `advancedWatermark` тем, что игнорирует метки дальше `now + tolerance`.
    /// Такие метки остались от сборок, писавших `deletedAt` часами клиента: устройство со
    /// спешащими часами ставило надгробие в будущее, watermark уезжал туда же, и всё это
    /// время удаления от других родителей отсекались фильтром `deletedAt >= watermark`.
    /// Проигнорированная метка ничего не ломает — окно просто перечитается на следующем
    /// sync'е, а `applyDeletions` идемпотентен.
    ///
    /// Пуре → покрыта тестами.
    static func advancedTombstoneWatermark(previous: Date?,
                                           observed: [Date],
                                           now: Date,
                                           tolerance: TimeInterval = tombstoneClockTolerance) -> Date {
        let ceiling = now.addingTimeInterval(tolerance)
        let sane = observed.filter { $0 <= ceiling }.max()
        return advancedWatermark(previous: previous, maxObserved: sane)
    }
```

- [ ] **Step 4: Применить на месте коммита**

`CloudSyncDownloader.swift`, строки 407-412. Заменить:

```diff
         if deletionsApplied, let tombstones {
-            let maxTomb = tombstones.map(\.deletedAt).max()
-            let nextTomb = Self.advancedWatermark(previous: tombWatermark, maxObserved: maxTomb)
+            let nextTomb = Self.advancedTombstoneWatermark(
+                previous: tombWatermark,
+                observed: tombstones.map(\.deletedAt),
+                now: Date()
+            )
             watermarks.set(family: tombScope.familyId, baby: tombScope.babyId,
                            collection: "deletions", to: nextTomb)
         }
```

- [ ] **Step 5: Запустить тесты**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/TombstoneWatermark -only-testing:MomsyTests/WatermarkAdvance`

Expected: PASS, 7 + 5 тестов. `WatermarkAdvance` должен пройти без изменений — `advancedWatermark` не менялась.

- [ ] **Step 6: Коммит**

```bash
git add Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift \
        MomsyTests/Features/Sync/TombstoneWatermarkTests.swift
git commit -m "fix(sync): clamp the tombstone watermark so a future stamp cannot poison it"
```

---

### Task 3: Одноразовый сброс отравленного watermark'а

**Files:**
- Modify: `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift:139` (вызов), новый приватный метод рядом с `purgeLegacyQuickLogsOnce:288-299`

Кламп из Task 2 защищает будущие коммиты, но **уже сохранённый** в `UserDefaults` watermark он не чинит: устройство, у которого он стоит на `now + 1 час`, продолжит отсекать всё до истечения этого часа. Сброс делает восстановление мгновенным.

Стоимость сброса — один полный пул `deletions` (до 1000 документов) на устройство, однократно. `applyDeletions` идемпотентен, лишние удаления применяются к уже удалённым строкам без эффекта.

Следуем существующему паттерну одноразовой миграции (`purgeLegacyQuickLogsOnce:290-299`): флаг в `UserDefaults`, выставляется только после успеха.

- [ ] **Step 1: Реализовать сброс**

`CloudSyncDownloader.swift`, вставить сразу после `purgeLegacyQuickLogsOnce` (после строки 299):

```swift

    /// Одноразовый сброс `deletions`-watermark'а после перехода надгробий на серверное
    /// время. Сборки до этого писали `deletedAt` часами устройства, поэтому сохранённый
    /// watermark мог уехать в будущее — и тогда фильтр `deletedAt >= watermark` отсекал
    /// бы все новые (корректные, серверные) надгробия до тех пор, пока реальное время не
    /// догонит. Сброс возвращает коллекцию к одному полному пулу; `applyDeletions`
    /// идемпотентен, поэтому повторное применение уже применённых удалений безвредно.
    private func resetTombstoneWatermarkOnce() {
        let flag = "babysync_deletions_watermark_reset_v1_done"
        guard !UserDefaults.standard.bool(forKey: flag) else { return }
        let scope = service.currentScope()
        guard !scope.familyId.isEmpty, !scope.babyId.isEmpty else { return }
        watermarks.set(family: scope.familyId, baby: scope.babyId,
                       collection: "deletions", to: Date(timeIntervalSince1970: 0))
        UserDefaults.standard.set(true, forKey: flag)
    }
```

- [ ] **Step 2: Вызвать до первого пула**

`CloudSyncDownloader.swift`, строки 136-139. Сброс обязан отработать **до** `downloadAllBabies()`, иначе первый пул пойдёт по отравленному watermark'у:

```diff
         await service.migrateFromFamilyPathIfNeeded()
         await service.replayPendingWrites()
+        // До первого пула: отравленный watermark иначе отсечёт надгробия этого же прогона.
+        resetTombstoneWatermarkOnce()
         await downloadAllBabies()
         await purgeLegacyQuickLogsOnce()
```

- [ ] **Step 3: Проверить порядок**

Run: `grep -n "resetTombstoneWatermarkOnce\|downloadAllBabies()\|migrateFromFamilyPathIfNeeded" Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift`

Expected: `resetTombstoneWatermarkOnce()` вызывается на строке, номер которой **меньше**, чем у `await downloadAllBabies()` внутри `downloadAndMergeWhenReady`.

Причина, по которой сброс идёт после `migrateFromFamilyPathIfNeeded()`: до миграции `currentScope().babyId` может быть ещё не выведен, и `watermarks.set` тихо ничего не сделает (`SyncWatermarkStore.swift:34` — гард на пустые ключи), а флаг уже был бы выставлен.

- [ ] **Step 4: Собрать и прогнать тесты**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/Features/Sync`

Expected: PASS.

- [ ] **Step 5: Коммит**

```bash
git add Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift
git commit -m "fix(sync): reset the deletions watermark once after the server-time switch"
```

---

### Task 4: Wiring теста в pbxproj

**Files:**
- Modify: `Momsy.xcodeproj/project.pbxproj`

Таргет `MomsyTests` не синхронизирован с файловой системой — новый тестовый файл нужно завести вручную, как это было сделано для `InviteCodeFormatTests.swift` в P0 (коммит `19f3df4`).

- [ ] **Step 1: Завести файл через Xcode**

Run: `open Momsy.xcodeproj`

Перетащить `MomsyTests/Features/Sync/TombstoneWatermarkTests.swift` в группу `MomsyTests/Features/Sync` в навигаторе, проверив галку Target Membership → `MomsyTests`. Xcode сгенерирует уникальные ID сам — надёжнее ручной правки pbxproj.

- [ ] **Step 2: Убедиться, что suite виден**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/TombstoneWatermark`

Expected: PASS, 7 тестов. Если suite не найден — файл не попал в таргет.

- [ ] **Step 3: Полный прогон**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: PASS.

Run: `npm run test:firebase-rules`

Expected: PASS.

- [ ] **Step 4: Коммит**

```bash
git add Momsy.xcodeproj/project.pbxproj
git commit -m "chore: wire TombstoneWatermarkTests into the MomsyTests target"
```

---

### Task 5: Деплой

**Files:** нет правок кода.

- [ ] **Step 1: Проверить, что правила деплоить не нужно**

`firestore.rules` в этой задаче не менялся — `deletions` попадает под общий блок `match /{subcollection}/{document=**}` (`:307-316`) без валидации payload'а. Деплой правил не требуется.

Run: `git diff --stat HEAD~4 -- firestore.rules`

Expected: пусто.

- [ ] **Step 2: НЕ чистить коллекцию `deletions`**

В отличие от `invites` в P0, здесь очистка **запрещена**. Tombstone — единственный носитель информации о том, что запись удалена. Устройство, не синхронизировавшееся с момента удаления, при пропаже надгробия зальёт удалённую запись обратно из своего локального хранилища. Старые документы с клиентскими метками остаются; кламп из Task 2 нейтрализует их влияние на watermark.

- [ ] **Step 3: Наблюдение после релиза**

В течение недели после раскатки проверить в Firebase Console → Firestore, что новые документы в `.../deletions/` имеют `deletedAt` в пределах минуты от реального времени их создания. Метки, отстоящие на часы, означают, что где-то остался путь записи с клиентскими часами.

---

## Definition of Done

- [ ] `grep -n 'setData(\["deletedAt"' Momsy/Services/Firebase/BabySync/BabySyncService.swift` — одна строка, с `FieldValue.serverTimestamp()`.
- [ ] `fetchTombstones` читает через `doc.data(with: .none)` и отбрасывает неразрешённые sentinel'ы.
- [ ] `advancedWatermark` **не изменена** — `WatermarkAdvanceTests` проходит без правок.
- [ ] `advancedTombstoneWatermark` — чистая статическая функция, покрыта 7 тестами, включая кламп будущей метки и запрет движения назад.
- [ ] Коммит watermark'а в `downloadAndMerge` использует `advancedTombstoneWatermark`.
- [ ] `resetTombstoneWatermarkOnce()` вызывается после `migrateFromFamilyPathIfNeeded()` и до `downloadAllBabies()`; флаг выставляется только при непустом scope.
- [ ] `xcodebuild test -scheme Momsy` — зелёный; 7 новых тестов.
- [ ] `npm run test:firebase-rules` — зелёный; новый тест на sentinel проходит, няня и бабушка по-прежнему не могут писать надгробия.
- [ ] Коллекция `deletions` в проде **не** очищалась.
- [ ] Новых ключей локализации нет; 7 языков не тронуты.

---

## Manual QA

Два устройства в одной семье, оба — родители, Cloud Sync consent включён. Ключевая часть — намеренный сдвиг часов, поэтому на устройстве А заранее выключить Settings → General → Date & Time → Set Automatically.

1. **Базовый сценарий.** А удаляет кормление → ждать ~10 с → на Б запись исчезла. Обратное направление тоже.
2. **Отстающие часы — главный сценарий.** На А перевести часы на 30 минут **назад**. Б удаляет запись X, дождаться прихода на А. Затем А удаляет запись Y. Вернуть на А автоматическое время, синхронизировать Б. Ожидаемо: **Y исчезла на Б**. До фикса Y не доезжала никогда.
3. **Спешащие часы.** На А перевести часы на 2 часа **вперёд**, удалить запись Z, вернуть автоматическое время. Затем Б удаляет запись W. Ожидаемо: и Z, и W разъезжаются по обоим устройствам. До фикса метка Z уводила watermark на 2 часа вперёд и W отсекалась.
4. **Проверка метки в консоли.** После шага 3 открыть Firebase Console → Firestore → `families/{id}/babies/{id}/deletions/`. Ожидаемо: `deletedAt` у Z близко к реальному времени, а не на 2 часа вперёд.
5. **Одноразовый сброс.** Устройство с предыдущей сборкой и накопленным watermark'ом обновить на новую. Ожидаемо: при первом запуске один полный пул `deletions`, дубликатов или воскресших записей нет; при втором запуске полного пула уже нет (флаг выставлен).
6. **Офлайн-удаление.** А в Airplane Mode удаляет запись, возвращает сеть. Ожидаемо: удаление доезжает на Б; в консоли `deletedAt` соответствует моменту **восстановления связи**, а не моменту действия пользователя — так и задумано, метка ставится сервером при коммите.
7. **Регресс на ролях.** Войти няней, попытаться удалить запись. Ожидаемо: поведение не изменилось относительно текущего билда (удаление остаётся локальным, `permissionDenied` в логах).

Проверка watermark'а в отладке:

```swift
po UserDefaults.standard.dictionary(forKey: "babysync_watermarks_v1_<familyId>_<babyId>")?["deletions"]
po UserDefaults.standard.bool(forKey: "babysync_deletions_watermark_reset_v1_done")
```

---

## Follow-up (отдельные задачи)

1. **P1 `2026-07-26-UNBOUNDED-WAITS-P1_CLI_TASK.md`** — зависание sync-пайплайна и экрана «Поделиться». При переносе `writeTombstone` в `enqueueDelete` (Task 2 того документа) **сохранить** `FieldValue.serverTimestamp()`, а не восстанавливать клиентскую метку.
2. **P2 #11 из первого ревью — `deletions` растёт без ограничений.** `limit: 1000`, ни TTL, ни очистки. У активной семьи через год это дорогой запрос при каждом первом sync нового устройства. Решение — TTL-политика Firestore на `deletedAt` (например 90 дней) плюс гарантия, что устройство, не синхронизировавшееся дольше TTL, проходит через полный ресид, а не инкрементальный пул.
3. **P1 #3/#4 из первого ревью** — тихая потеря правок профиля ребёнка (`last-download-wins` вместо `last-write-wins`) и запись профиля не тому ребёнку при сетевой ошибке в `fetchBabyProfile()`.
4. **P1 #6 из первого ревью** — отказы записи по правилам не видны пользователю: бабушка и няня пишут в SwiftData, получают `permissionDenied` и не узнают об этом.
