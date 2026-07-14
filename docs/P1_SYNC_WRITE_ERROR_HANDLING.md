# P1 — Обработка ошибок Firestore-записи: логирование + дроп permanently-denied операций

## Контекст

Сейчас все ошибки облачных записей неотличимы от успеха или ретраятся вечно:

- `addLog` / `setLog` (`BabySyncService.swift:60, 82`) — completion `{ _ in }` глотает всё, включая `permissionDenied`. Запись остаётся в локальном кэше Firestore, сервер её откатывает → тихое расхождение устройств без единой строчки в логах.
- `propagateDelete` (строка 170) и `retryPendingDeletions` (строка 233) — при `permissionDenied` (например, няня удаляет чужую запись: rules delete parent-only) entry остаётся в `PendingDeletionsStore` **навсегда** и ретраится на каждом синке с гарантированным отказом.
- `replayPendingWrites` (строка 201) — та же вечная петля для queued-записей, отклонённых rules.

Rules-denied — это permanent failure для текущей роли/членства: ретрай бессмысленен и только жжёт запросы. Transient-ошибки (offline, unavailable) должны оставаться retryable — текущее поведение для них не меняется.

**Скоуп:** это шаг 2 из ревью P1-3 (наблюдаемость + остановка вечных петель). Шаг 1 — продуктовое решение по роль-гейтингу UI няни/бабушки — отдельный документ, здесь не затрагивается. `firestore.rules` не меняются.

## Файлы

1. `Momsy/Services/Firebase/BabySync/BabySyncService.swift`
2. (новый) `MomsyTests/Features/Sync/BabySyncErrorClassificationTests.swift`

---

## 1. BabySyncService.swift

### 1.1. Импорт и Logger

Строки 1–2, текущее:

```swift
import FirebaseAuth
import FirebaseFirestore
```

Добавить `import os` и внутри класса (рядом с `private let defaults`, строка 40):

```swift
    private static let log = Logger(subsystem: "RuslanAbd.Momsy", category: "BabySync")
```

### 1.2. Pure-классификатор (добавить рядом со `static func replayTargetBabyId`, тот же MARK-блок)

```swift
    /// Rules-denied writes are permanent for the caller's current role/membership —
    /// retrying them forever only burns requests. Everything else (offline,
    /// unavailable, transient backend errors) must stay retryable.
    nonisolated static func isPermissionDenied(_ error: Error) -> Bool {
        let ns = error as NSError
        return ns.domain == FirestoreErrorCode.errorDomain
            && ns.code == FirestoreErrorCode.permissionDenied.rawValue
    }
```

### 1.3. `addLog` — строка 60, текущее:

```swift
        ref.setData(payload) { _ in }
```

Заменить на:

```swift
        ref.setData(payload) { error in
            guard let error else { return }
            Self.log.error("addLog(\(subcollection, privacy: .public)) failed: \(error.localizedDescription, privacy: .public)")
        }
```

### 1.4. `setLog` — строка 82, текущее:

```swift
        collection(subcollection).document(id).setData(payload, merge: true) { _ in }
```

Заменить на:

```swift
        collection(subcollection).document(id).setData(payload, merge: true) { error in
            guard let error else { return }
            Self.log.error("setLog(\(subcollection, privacy: .public)) failed: \(error.localizedDescription, privacy: .public)")
        }
```

Queued-ветка (`hasPath == false` → `PendingWritesStore`) не меняется.

### 1.5. `propagateDelete` — заменить catch (строки 178–180):

Текущее:

```swift
            } catch {
                // Leave it pending; the launch merge will retry.
            }
```

Заменить на:

```swift
            } catch {
                if Self.isPermissionDenied(error) {
                    // Rules will never allow this delete for the current role — a
                    // permanent failure. Drop the entry so the sync loop doesn't
                    // retry it forever; the local delete stays local-only.
                    PendingDeletionsStore.shared.remove(id: id)
                    Self.log.error("propagateDelete(\(subcollection, privacy: .public)) denied by rules — dropping pending entry \(id.uuidString, privacy: .public)")
                } else {
                    Self.log.info("propagateDelete(\(subcollection, privacy: .public)) failed transiently; kept pending")
                }
            }
```

### 1.6. `retryPendingDeletions` — заменить catch (строки 239–241):

Текущее:

```swift
            } catch {
                // keep pending
            }
```

Заменить на:

```swift
            } catch {
                if Self.isPermissionDenied(error) {
                    if let id = UUID(uuidString: idStr) { PendingDeletionsStore.shared.remove(id: id) }
                    Self.log.error("retryPendingDeletions(\(collection, privacy: .public)) denied by rules — dropping \(idStr, privacy: .public)")
                }
                // Transient failures stay pending for the next sync.
            }
```

### 1.7. `replayPendingWrites` — заменить catch (строки 228–230):

Текущее:

```swift
            } catch {
                // Leave it pending; the next sync retries.
            }
```

Заменить на:

```swift
            } catch {
                if Self.isPermissionDenied(error) {
                    // A rules-denied queued write can never succeed for this
                    // role/membership; keeping it would replay-fail on every sync.
                    PendingWritesStore.shared.remove(docId: entry.docId)
                    Self.log.error("replayPendingWrites(\(entry.collection, privacy: .public)) denied by rules — dropping \(entry.docId, privacy: .public)")
                }
                // Transient failures stay pending; the next sync retries.
            }
```

---

## 2. Новый тест — MomsyTests/Features/Sync/BabySyncErrorClassificationTests.swift

```swift
import Testing
import FirebaseFirestore
@testable import Momsy

struct BabySyncErrorClassificationTests {
    @Test func permissionDeniedIsPermanent() {
        let denied = NSError(domain: FirestoreErrorCode.errorDomain,
                             code: FirestoreErrorCode.permissionDenied.rawValue)
        #expect(BabySyncService.isPermissionDenied(denied))
    }

    @Test func transientErrorsAreRetryable() {
        let offline = NSError(domain: FirestoreErrorCode.errorDomain,
                              code: FirestoreErrorCode.unavailable.rawValue)
        let deadline = NSError(domain: FirestoreErrorCode.errorDomain,
                               code: FirestoreErrorCode.deadlineExceeded.rawValue)
        let foreign = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
        #expect(!BabySyncService.isPermissionDenied(offline))
        #expect(!BabySyncService.isPermissionDenied(deadline))
        #expect(!BabySyncService.isPermissionDenied(foreign))
    }
}
```

---

## Definition of Done

- [ ] Ни одного `{ _ in }` completion у `setData` в `BabySyncService` (grep).
- [ ] `isPermissionDenied` — `nonisolated static`, покрыт тестами.
- [ ] `propagateDelete` / `retryPendingDeletions` / `replayPendingWrites`: permission-denied удаляет entry из соответствующего store; transient — оставляет (поведение не изменилось).
- [ ] Offline-семантика `addLog`/`setLog` не изменилась: вызовы по-прежнему не await'ят server ack (completion-форма сохранена).
- [ ] `firestore.rules` не изменён.
- [ ] Сборка и все тесты зелёные, включая существующий `BabySyncBackfillTests` (использует `PendingWritesStore` — API не менялся).

## Manual QA

1. **Transient-регрессия:** Airplane mode → добавить кормление → удалить запись сна → перезапуск с сетью. **Ожидание:** запись доехала до облака, delete доехал, pending-stores пустые (как раньше).
2. **Permanent-дроп (няня):** устройство с ролью Няня → удалить запись кормления, созданную Мамой. **Ожидание:** локально запись удалена; в Console.app лог `propagateDelete(...) denied by rules — dropping`; в UserDefaults `pending_deletions_v1` entry отсутствует; последующие синки НЕ повторяют попытку (нет повторных denied-логов).
3. **Permanent-дроп queued-записи:** на устройстве Няни в онбординг-окне (до готовности пути) записать симптом → после готовности семьи replay. **Ожидание:** после первого denied-replay entry исчез из `PendingWritesStore`, повторов нет.
4. Console.app, subsystem `RuslanAbd.Momsy`, category `BabySync`: denied-записи видны как error-level события.
