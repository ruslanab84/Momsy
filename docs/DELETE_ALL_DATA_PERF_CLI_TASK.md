# DELETE ALL DATA — ускорение стирания аккаунта

**Приоритет:** P1 (UX-блокер: 20–60 с под индикатором без прогресса, пользователь считает приложение зависшим)
**База:** `main`, коммит `347dc93dc5e2492a0608e9cee4be28f985ab631b` — *Fix Swift 6 concurrency annotations*
**Целевая ветка:** `perf/account-deletion-parallel`

---

## 1. Постановка задачи

`FirestoreAccountEraser.deleteCloudData` выполняет ~106 **последовательных** round-trip'ов к Firestore, каждый принудительно с `source: .server`. Ни один из независимых запросов не выполняется параллельно: `grep -c "TaskGroup\|async let" Momsy/Core/Account/DeleteAccountUseCase.swift` → **0**.

Раскладка для типовой семьи (один ребёнок, один родитель, `mayTearDownSharedData == true`):

| Фаза | RTT | Строки |
|---|---|---|
| Преамбула (user doc, invites, membership, family, members, babies) | 6 | `:36–110` |
| `deleteBabyTree` — 20 подколлекций × `getDocuments(.server)` + коммиты | ~30 | `:228–236` |
| `deleteLegacyFamilyTree` — те же 20 подколлекций на `babies/{familyId}` | 22 | `:242–256` |
| `verifyHealthDataAbsent` — 40 коллекций + 4 документа | 44 | `:297–324` |
| Exit batch + `isCloudDataPresent` | 4 | `:337–343`, `:193` |
| **Итого** | **~106** | |

При 200 мс на RTT — ~21 с, при 400 мс — ~42 с. Два ребёнка → ~155 RTT.

### Цель

Свести к **~29 RTT-эквивалентам** за счёт ограниченного параллелизма (лимит 8) в четырёх независимых циклах. Ожидаемое ускорение — **3,5–4×**.

### Важно: гейт по `babysync_perbaby_migration_v1_done` НЕЛЬЗЯ использовать

В предыдущем обсуждении этот флаг предлагался как способ пропустить `deleteLegacyFamilyTree`. **Это ошибка.** `BabySyncService.migrateFromFamilyPathIfNeeded` (`BabySyncService.swift:437–439`) явно оставляет старое дерево на месте после миграции:

> *«the old tree is left in place so not-yet-updated devices keep working during rollout. Erasure later cleans it via `deleteLegacyFamilyTree()`.»*

Кроме того, флаг выставляется в `true` и в ветке «мигрировать нечего» (`:457`). То есть `true` не означает «легаси-дерева нет» — ровно наоборот, именно в этом состоянии данные там чаще всего и лежат. Пропуск по флагу привёл бы к неполному GDPR-стиранию.

**Легаси-дерево не пропускаем — параллелизуем.** Это даёт тот же выигрыш по времени без риска для корректности.

### Что НЕ входит

- Не менять семантику `source: .server` — это осознанное решение (кеш не должен выдавать себя за подтверждённое удаление).
- Не сворачивать проверку `verifyHealthDataAbsent` в проход удаления — отдельная задача, требует отдельного разбора гонки с со-родителем.
- Не выносить `eraseLocalData()` с MainActor — `ModelContext` не `Sendable`, отдельная задача.
- Не переносить стирание в Cloud Function — правильное долгосрочное решение, но это отдельный эпик.
- Не трогать `DeleteAccountUseCase.execute()`, `AccountDeletionRecovery`, `SettingsViewModel`.

---

## 2. Задача A — хелпер ограниченного параллелизма

**Файл:** `Momsy/Core/Account/DeleteAccountUseCase.swift`

Помещаем **в существующий файл**, а не в новый: новый Swift-файл потребовал бы регистрации в `Momsy.xcodeproj/project.pbxproj`, а в проекте уже есть незарегистрированные файлы (`MomsyWatch`/`MomsyWatchWidget`) — не плодим тот же класс проблем в задаче про производительность. Тестируется через `@testable import Momsy`.

**Вставить после строки 32** (закрывающая `}` протокола `CloudAccountEraser`, перед `struct FirestoreAccountEraser`):

```swift

/// Runs independent async work with a bounded number of tasks in flight.
///
/// Replaces `for … { try await … }` loops over Firestore collections that have no ordering
/// dependency between iterations. Preserves the fail-fast semantics of the sequential loop:
/// the first error cancels the rest of the group and is rethrown to the caller.
///
/// The limit exists because the erase path fans out over 20 subcollections × 2 trees; an
/// unbounded group would open 40+ concurrent Firestore connections at once.
enum BoundedConcurrency {
    static let defaultLimit = 8

    static func forEach<T: Sendable>(
        _ items: [T],
        limit: Int = defaultLimit,
        _ operation: @Sendable @escaping (T) async throws -> Void
    ) async throws {
        guard limit > 1, items.count > 1 else {
            for item in items {
                try await operation(item)
            }
            return
        }
        try await withThrowingTaskGroup(of: Void.self) { group in
            var next = 0
            let window = min(limit, items.count)
            while next < window {
                let item = items[next]
                group.addTask { try await operation(item) }
                next += 1
            }
            while try await group.next() != nil {
                guard next < items.count else { continue }
                let item = items[next]
                group.addTask { try await operation(item) }
                next += 1
            }
        }
    }
}
```

**Строка 34** — добавить явное `Sendable` (структура без состояния; нужно, чтобы `self` захватывался в `@Sendable`-замыкания без предупреждений после включения strict concurrency):

```swift
// BEFORE
struct FirestoreAccountEraser: CloudAccountEraser {
// AFTER
struct FirestoreAccountEraser: CloudAccountEraser, Sendable {
```

---

## 3. Задача B — параллелизация четырёх циклов

**Файл:** `Momsy/Core/Account/DeleteAccountUseCase.swift`

Правки применять **снизу вверх** (номера строк даны для исходного файла на `347dc93`; вставка из задачи A сдвигает всё ниже строки 32).

### B.1 — `deleteAllDocs`: пагинация вместо выгрузки целиком (строки 423–434)

Сейчас `getDocuments(.server)` без `limit` тянет ВСЕ документы коллекции со всеми полями в память — только чтобы получить `doc.reference`. Для года логов кормления это десятки тысяч документов до первого коммита.

```swift
// BEFORE
    private func deleteAllDocs(in query: Query) async throws {
        let docs = try await query.getDocuments(source: .server).documents
        guard !docs.isEmpty else { return }
        let db = Firestore.firestore()
        for start in stride(from: 0, to: docs.count, by: 400) {
            let batch = db.batch()
            for doc in docs[start..<min(start + 400, docs.count)] {
                batch.deleteDocument(doc.reference)
            }
            try await batch.commit()
        }
    }
```

```swift
// AFTER
    /// Pages through the collection instead of materialising it. Each committed page is gone
    /// from the server, so re-running the same `limit`ed query returns the next page.
    /// The page cap bounds a pathological loop (a page that commits but does not shrink);
    /// hitting it defers to launch recovery rather than spinning forever.
    private func deleteAllDocs(in query: Query) async throws {
        let db = Firestore.firestore()
        let pageSize = 400
        var pages = 0
        while true {
            let docs = try await query.limit(to: pageSize)
                .getDocuments(source: .server)
                .documents
            guard !docs.isEmpty else { return }

            let batch = db.batch()
            for doc in docs {
                batch.deleteDocument(doc.reference)
            }
            try await batch.commit()

            if docs.count < pageSize { return }
            pages += 1
            guard pages < 250 else { throw AuthError.accountDeletionPending }
        }
    }
```

### B.2 — `eraseAuthoredData` (строка 328)

Путь со-родителя: 19 последовательных запросов.

```swift
// BEFORE (строка 328)
        for subcollection in BabySyncService.allSubcollections where subcollection != "deletions" {
```

```swift
// AFTER — заменить строку 328 и закрывающую `}` цикла на строке 355
        let subcollections = BabySyncService.allSubcollections.filter { $0 != "deletions" }
        try await BoundedConcurrency.forEach(subcollections) { subcollection in
```

Тело цикла (строки 329–354) оставить без изменений. Закрывающую `}` цикла на строке 355 заменить на `}` замыкания — синтаксически совпадает, править не нужно.

> Внутренний `stride`-цикл по батчам оставить **последовательным**: он ограничивает темп записи в пределах одной коллекции.

### B.3 — `verifyHealthDataAbsent` (строки 297–324)

```swift
// BEFORE
        let db = Firestore.firestore()
        for path in Self.healthDataCollectionPaths(
            parentPaths: parentPaths,
            includingDeletionMarkers: !authoredOnly
        ) {
            let collection = db.collection(path)
            let subcollection = String(path.split(separator: "/").last ?? "")
            let query: Query
            if BabySyncService.requiresAuthorScopedQuery(
                for: subcollection,
                authoredOnly: authoredOnly
            ) {
                query = collection.whereField("addedBy", isEqualTo: deletingUID)
            } else {
                query = collection
            }
            let snapshot = try await query.limit(to: 1).getDocuments(source: .server)
            guard snapshot.isEmpty, !snapshot.metadata.hasPendingWrites else {
                throw AuthError.accountDeletionPending
            }
        }

        guard !authoredOnly else { return }
        for path in Self.healthDataDocumentPaths(parentPaths: parentPaths) {
            let snapshot = try await db.document(path).getDocument(source: .server)
            guard !snapshot.exists, !snapshot.metadata.hasPendingWrites else {
                throw AuthError.accountDeletionPending
            }
        }
    }
```

```swift
// AFTER
        let db = Firestore.firestore()
        let collectionPaths = Self.healthDataCollectionPaths(
            parentPaths: parentPaths,
            includingDeletionMarkers: !authoredOnly
        )
        try await BoundedConcurrency.forEach(collectionPaths) { path in
            let collection = db.collection(path)
            let subcollection = String(path.split(separator: "/").last ?? "")
            let query: Query
            if BabySyncService.requiresAuthorScopedQuery(
                for: subcollection,
                authoredOnly: authoredOnly
            ) {
                query = collection.whereField("addedBy", isEqualTo: deletingUID)
            } else {
                query = collection
            }
            let snapshot = try await query.limit(to: 1).getDocuments(source: .server)
            guard snapshot.isEmpty, !snapshot.metadata.hasPendingWrites else {
                throw AuthError.accountDeletionPending
            }
        }

        guard !authoredOnly else { return }
        let documentPaths = Self.healthDataDocumentPaths(parentPaths: parentPaths)
        try await BoundedConcurrency.forEach(documentPaths) { path in
            let snapshot = try await db.document(path).getDocument(source: .server)
            guard !snapshot.exists, !snapshot.metadata.hasPendingWrites else {
                throw AuthError.accountDeletionPending
            }
        }
    }
```

> Порядок фаз не меняется: верификация по-прежнему запускается **после** удаления (`:118` → `:119`). Параллелизм только внутри фазы.

### B.4 — `deleteLegacyFamilyTree` (строки 242–250)

```swift
// BEFORE
        for subcollection in BabySyncService.allSubcollections {
            try await Self.performLegacyDeletion {
                try await deleteAllDocs(
                    in: oldParent.collection(subcollection),
                    subcollection: subcollection,
                    ownerUID: ownerUID
                )
            }
        }
```

```swift
// AFTER
        try await BoundedConcurrency.forEach(BabySyncService.allSubcollections) { subcollection in
            try await Self.performLegacyDeletion {
                try await deleteAllDocs(
                    in: oldParent.collection(subcollection),
                    subcollection: subcollection,
                    ownerUID: ownerUID
                )
            }
        }
```

Два вызова `performLegacyDeletion` ниже (строки 251–256) оставить последовательными — `profile/info` и сам parent-документ должны удаляться после подколлекций.

### B.5 — `deleteBabyTree` (строки 228–234)

```swift
// BEFORE
        for subcollection in BabySyncService.allSubcollections {
            try await deleteAllDocs(
                in: babyRef.collection(subcollection),
                subcollection: subcollection,
                ownerUID: ownerUID
            )
        }
```

```swift
// AFTER
        try await BoundedConcurrency.forEach(BabySyncService.allSubcollections) { subcollection in
            try await deleteAllDocs(
                in: babyRef.collection(subcollection),
                subcollection: subcollection,
                ownerUID: ownerUID
            )
        }
```

Строки 235–237 (`profile/info` delete, `babyRef.delete()`, `SyncWatermarkStore().reset`) оставить последовательными — они зависят от завершения подколлекций.

### Что НЕ параллелизуем

- Цикл `for babyId in babyIds` (`:110–117`) — `deleteBabyTree` уже параллелит 20 коллекций внутри; вложенные группы умножат конкурентность до 8×N. У большинства семей 1–2 ребёнка, выигрыш не окупает риска.
- Цикл удаления roster'а (`:131–133`) — 0–3 документа.
- Преамбула (`:36–110`) — там реальные зависимости по данным.

---

## 4. Задача C — тесты

**Файл:** `MomsyTests/Features/Account/DeleteAccountTests.swift`

Добавлять в существующий файл (нового файла = новой записи в `project.pbxproj` не создаём). Framework — Swift Testing, как во всём файле. Firestore не требуется: `BoundedConcurrency` — чистый хелпер.

**Дописать в конец файла:**

```swift

// MARK: - Bounded concurrency

private actor ConcurrencyProbe {
    private(set) var inFlight = 0
    private(set) var peak = 0
    private(set) var completed: [Int] = []

    func enter() {
        inFlight += 1
        peak = max(peak, inFlight)
    }

    func leave(_ item: Int) {
        inFlight -= 1
        completed.append(item)
    }
}

private struct ProbeFailure: Error {}

@Suite("BoundedConcurrency")
struct BoundedConcurrencyTests {

    @Test("runs every item exactly once")
    func runsEveryItem() async throws {
        let probe = ConcurrencyProbe()
        try await BoundedConcurrency.forEach(Array(0..<50), limit: 8) { item in
            await probe.enter()
            try await Task.sleep(nanoseconds: 1_000_000)
            await probe.leave(item)
        }
        let completed = await probe.completed
        #expect(completed.count == 50)
        #expect(Set(completed) == Set(0..<50))
    }

    @Test("never exceeds the concurrency limit, and does run concurrently")
    func respectsLimit() async throws {
        let probe = ConcurrencyProbe()
        try await BoundedConcurrency.forEach(Array(0..<40), limit: 5) { item in
            await probe.enter()
            try await Task.sleep(nanoseconds: 3_000_000)
            await probe.leave(item)
        }
        let peak = await probe.peak
        #expect(peak <= 5, "peak in-flight \(peak) exceeded the limit")
        #expect(peak > 1, "work never overlapped — the group is effectively sequential")
    }

    @Test("first error is rethrown and the remaining work stops")
    func failsFast() async {
        let probe = ConcurrencyProbe()
        await #expect(throws: ProbeFailure.self) {
            try await BoundedConcurrency.forEach(Array(0..<100), limit: 4) { item in
                await probe.enter()
                if item == 0 { throw ProbeFailure() }
                try await Task.sleep(nanoseconds: 20_000_000)
                await probe.leave(item)
            }
        }
        let completed = await probe.completed
        #expect(completed.count < 100, "the group kept working after the first failure")
    }

    @Test("degenerate inputs fall back to the sequential path")
    func degenerateInputs() async throws {
        let emptyProbe = ConcurrencyProbe()
        try await BoundedConcurrency.forEach([Int](), limit: 8) { item in
            await emptyProbe.enter()
            await emptyProbe.leave(item)
        }
        let emptyPeak = await emptyProbe.peak
        #expect(emptyPeak == 0)

        let serialProbe = ConcurrencyProbe()
        try await BoundedConcurrency.forEach([1, 2, 3], limit: 1) { item in
            await serialProbe.enter()
            await serialProbe.leave(item)
        }
        let serialPeak = await serialProbe.peak
        let serialOrder = await serialProbe.completed
        #expect(serialPeak == 1)
        #expect(serialOrder == [1, 2, 3], "limit 1 must preserve order")
    }
}
```

Существующие сьюты `DeleteAccountUseCase`, `FirestoreAccountEraser`, `PendingAccountDeletionStoreTests` **не трогать** — они покрывают семантику стирания и должны остаться зелёными без правок, что и будет доказательством, что параллелизация не изменила поведение.

---

## 5. Измерение результата

Перед мержем — снять цифру, а не поверить на слово. Временная инструментовка в `DeleteAccountUseCase.execute()`:

```swift
#if DEBUG
let started = CFAbsoluteTimeGetCurrent()
defer { print("[erase] total \(CFAbsoluteTimeGetCurrent() - started)s") }
#endif
```

Замерить на одном и том же аккаунте до и после (восстановить данные между прогонами через повторный онбординг + сид). В commit message приложить обе цифры. Инструментовку из финального диффа убрать.

Ожидаемо: ~106 → ~29 RTT-эквивалентов, 20 с → 5–7 с при 200 мс RTT.

---

## 6. Definition of Done

- [ ] `xcodebuild build` без новых warnings.
- [ ] `xcodebuild test` — **полный вывод в commit message**, включая счётчик passed/failed.
- [ ] Все 4 теста `BoundedConcurrencyTests` зелёные; `respectsLimit` проверяет обе границы (`peak <= 5` И `peak > 1`).
- [ ] Все существующие тесты в `DeleteAccountTests.swift` зелёные **без правок** (`fullErasure`, `reauthRequiredStillCompletesTheErasure`, `authRetirementFailureDefersToAuthRetry`, `authRetirementIsBoundToOriginalUID`, `noUserWipesLocalOnly`, `cloudErrorStillWipesLocal`, `clearsPendingOnceServerConfirmsErasure`, `keepsPendingWhenServerStillHasData`, `failedLocalWipeRemainsPending`, `serverCleanLocalWipeFailureRemainsRetryable`, `privateWellbeingQueryScope`, `legacyDeletionErrorPolicy`, `serverVerificationPathPlan`).
- [ ] `grep -c "source: .server" DeleteAccountUseCase.swift` → **13** (не изменилось).
- [ ] `grep -c "BoundedConcurrency.forEach" DeleteAccountUseCase.swift` → **5**.
- [ ] `deleteLegacyFamilyTree` по-прежнему вызывается безусловно — гейта по `babysync_perbaby_migration_v1_done` в диффе нет.
- [ ] Новых файлов нет → `project.pbxproj` не изменён.
- [ ] Замер до/после приложен.

---

## 7. Manual QA script

Нужен тестовый аккаунт с реальным объёмом: минимум 300 логов кормления, 200 сна, 150 подгузников, 2 ребёнка.

**Основной сценарий:**
1. Settings → Delete all data → подтвердить. Засечь секундомером.
2. Проверить, что оверлей с индикатором держится всё время и не мигает.
3. После завершения — приложение уходит на онбординг (флаги `onboardingDone`/`paywallShown` сброшены).
4. В Firebase Console: `families/{familyId}/babies/**` пуст, `users/{uid}` отсутствует, `families/{familyId}` остался как tombstone с `createdBy: ""`.
5. Повторно войти тем же Apple/Google-аккаунтом — регистрация проходит, старые данные не возвращаются.

**Гонки и сбои:**
6. Включить Network Link Conditioner (100% Loss) в середине удаления. Ожидание: маркер `pendingAccountDeletion` остался, при следующем запуске `AccountDeletionRecovery` доводит стирание.
7. Airplane Mode до нажатия Delete. Ожидание: локальные данные стёрты, ошибка показана, маркер сохранён.
8. Со-родительский путь: войти няней/бабушкой (`mayTearDownSharedData == false`), удалить аккаунт. Ожидание: удалены только записи с `addedBy == uid`, данные родителя целы, `profile/info.members` больше не содержит ушедший uid.

**Регресс по конкурентности:**
9. Прогнать удаление 3 раза подряд на разных аккаунтах — не должно быть частичных стираний или `permissionDenied`. Восемь одновременных батчей идут по разным документам, транзакций нет, конфликтов быть не должно; если `permissionDenied` появился — это сигнал, что параллелизм разошёлся с порядком удаления membership, и задачу надо откатывать, а не «чинить ретраем».

---

## 8. Дальнейшие шаги (не входят сюда)

| Приоритет | Задача |
|---|---|
| P1 | Постадийный прогресс в UI (`SettingsView.swift:104–119`): сейчас один неопределённый спиннер на всё время. «Стирание облачных данных… 3/5» не ускорит ничего, но снимет ощущение зависания. |
| P2 | Свернуть `verifyHealthDataAbsent` в проход удаления: перепроверять только пути, где первый серверный чтение вернуло документы. Требует отдельного разбора гонки с пишущим со-родителем. |
| P2 | `eraseLocalData()` на MainActor (`AppContainer.swift:334`): 20 × `context.delete(model:)` + `save()` блокируют UI поверх сетевого времени. |
| P3 | Перенос стирания в Callable Cloud Function на Admin SDK — 106 RTT → 1, верификация уходит на сервер. Отдельный эпик; в `functions/` уже есть триггер на удаление membership. |
