# P1: Присоединившийся член семьи удаляется из roster → рассинхронизация данных

**Repo:** `ruslanab84/Momsy` · проверено на HEAD `0a79505` ("P1: Fix family roster visibility regression in invite rules")
**Симптомы:**
1. Родитель 1 добавляет прогулку — родитель 2 её не видит.
2. Через несколько часов после join по инвайту пользователь исчезает из Settings → Family.

**Firestore rules НЕ виноваты** — коммит `0a79505` их уже починил. Баг клиентский.

---

## Корневая причина

`SuppressedFamilyRestoreStore` (флаг «начать с чистой семьи», выставляется при удалении аккаунта) **переживает последующий invite-join** и на следующем запуске уничтожает легитимное членство.

Цепочка воспроизведения (один девайс):

1. Пользователь удаляет аккаунт → `suppressRestore(uid)` (`DeleteAccountUseCase.swift:213`). Fallback `signOut()` при `reauthRequired` (`:229`) — **uid остаётся прежним**.
2. Тот же uid входит снова и джойнится к семье F по инвайту. `FamilyManager.joinFamily()` создаёт member doc и `users/{uid}.familyId = F` (`FamilyManager.swift:264–283`), но **флаг suppression не снимает**. Параллельный `setup()` отсекается guard'ом `joinInFlight` (`:101–104`), поэтому `clearSuppression` на `:187` не выполняется никогда.
3. Следующий запуск: `setup()` видит `restoreSuppressed == true` → `reset()` стирает локальный кэш (`:108–110`) → читает `users/{uid}.familyId == F` (`:146–147`) → ветка `:166–170` **удаляет member doc пользователя в семье F** → создаёт новую личную семью P → `users/{uid}.familyId = P`.

Результат: member doc в F удалён (симптом 2), пользователь пишет/читает логи в P, а не в F (симптом 1).

Кросс-девайсный вариант: suppression лежит в UserDefaults девайса B (где удаляли аккаунт), join сделан на девайсе A — запуск B уничтожает членство для обоих.

**Вторичный разрушитель (P2):** `AccountDeletionRecovery.runIfNeeded()` (`DeleteAccountUseCase.swift:272–290`) при непогашенном pending-маркере: (а) на каждом запуске заново ставит suppression (`:274`), обнуляя любой clear; (б) через `deleteCloudData` удаляет member doc семьи, на которую сейчас указывает `users/{uid}.familyId` (`:91,:93`) — т.е. уже присоединённой семьи.

---

## Fix A (P1, обязательный) — `Momsy/Core/Family/FamilyManager.swift`

### A1. `joinFamily`: явный join гасит deletion-state

Инвайт-join — однозначное намерение принадлежать семье; «начать заново» и «дотереть аккаунт» им отменяются.

Вставить после `persist(...)` / перед `isReady = true` (сейчас строки `285–286`):

```swift
        persist(familyId: targetFamilyId, ownerUid: uid)
        // An explicit invite join supersedes any pending "start fresh" / deletion
        // intent for this uid on this device — otherwise the next launch's
        // suppressed-restore path would delete the freshly created member doc.
        UserDefaultsSuppressedFamilyRestoreStore().clearSuppression(for: uid)
        let pendingStore = UserDefaultsPendingAccountDeletionStore()
        if pendingStore.loadPending() == uid { pendingStore.clearPending() }
        isReady = true
```

### A2. `setup()`: suppressed-ветка не должна уничтожать invite-членство

Только invite-join пишет поле `inviteCode` в member doc (`memberDocumentData`, `:412–414`). Наличие `inviteCode` ⇒ членство создано явным join'ом **после** намерения удаления ⇒ адоптируем, а не удаляем. Это закрывает кросс-девайсное окно, где A1 не помогает.

**Было** (`:158–170`):

```swift
        if let existingId, !restoreSuppressed {
            persist(familyId: existingId, ownerUid: uid)
            try await ensureMemberDocument(
                familyId: existingId,
                uid: uid,
                displayName: displayName,
                defaultRoleRaw: FamilyRole.mom.rawValue
            )
        } else {
            if let existingId, restoreSuppressed {
                try? await db.collection("families").document(existingId)
                    .collection("members").document(uid).delete()
            }
```

**Стало:**

```swift
        if let existingId, !restoreSuppressed {
            persist(familyId: existingId, ownerUid: uid)
            try await ensureMemberDocument(
                familyId: existingId,
                uid: uid,
                displayName: displayName,
                defaultRoleRaw: FamilyRole.mom.rawValue
            )
        } else {
            if let existingId, restoreSuppressed {
                let memberRef = db.collection("families").document(existingId)
                    .collection("members").document(uid)
                // permissionDenied ⇒ doc отсутствует (rules требуют его существования
                // для read). Прочие ошибки (сеть, App Check) пробрасываются наверх:
                // transient-сбой не должен приводить к созданию новой семьи.
                let memberSnap: DocumentSnapshot?
                do {
                    memberSnap = try await memberRef.getDocument(source: .server)
                } catch let error where Self.classifyMembershipError(error) == .revoked {
                    memberSnap = nil
                }
                let resolution = Self.resolveSuppressedRestore(
                    memberDocExists: memberSnap?.exists == true,
                    memberHasInviteCode: (memberSnap?.data()?["inviteCode"] as? String) != nil
                )
                switch resolution {
                case .adoptInviteMembership:
                    // Членство создано инвайт-join'ом ПОСЛЕ намерения удаления —
                    // легитимно. Снимаем suppression и адоптируем как обычный вход.
                    suppressedRestoreStore.clearSuppression(for: uid)
                    persist(familyId: existingId, ownerUid: uid)
                    try await ensureMemberDocument(
                        familyId: existingId,
                        uid: uid,
                        displayName: displayName,
                        defaultRoleRaw: FamilyRole.mom.rawValue
                    )
                    isReady = true
                    return
                case .discardStaleMembership:
                    try? await memberRef.delete()
                case .startFresh:
                    break
                }
            }
```

Остальная часть `else`-ветки (`createFamily` и далее, `:171–188`) без изменений.

### A3. Чистая функция решения (для тестов)

Добавить в `FamilyManager` рядом с `gatedMembershipCheck` (`~:329`):

```swift
    enum SuppressedRestoreResolution {
        case adoptInviteMembership
        case discardStaleMembership
        case startFresh
    }

    /// Suppressed-restore решение по состоянию member doc. Только invite-join пишет
    /// `inviteCode`, поэтому его наличие доказывает, что членство создано явным
    /// join'ом и не подлежит зачистке при "start fresh".
    nonisolated static func resolveSuppressedRestore(
        memberDocExists: Bool,
        memberHasInviteCode: Bool
    ) -> SuppressedRestoreResolution {
        guard memberDocExists else { return .startFresh }
        return memberHasInviteCode ? .adoptInviteMembership : .discardStaleMembership
    }
```

Примечание: `ensureMemberDocument` при `inviteCode == nil && !bootstrapCreator` (`:388–402`) только дозаполняет отсутствующие поля через `merge: true` — существующий `roleRaw` из инвайта не перезаписывается, rules-проверка `memberRoleUnchanged()` проходит.

---

## Fix B (P2, hardening) — `Momsy/Core/Account/DeleteAccountUseCase.swift`

`AccountDeletionRecovery.runIfNeeded()` (`:272–290`) не должен дотирать аккаунт, если членство переустановлено инвайтом после намерения удаления.

**Было** (`:272–277`):

```swift
    func runIfNeeded() async {
        guard let pendingUid = pendingStore.loadPending() else { return }
        suppressedRestoreStore.suppressRestore(for: pendingUid)
        guard let currentUid = auth.currentUID, currentUid == pendingUid else { return }
        do {
            try await cloudEraser.deleteCloudData(uid: currentUid)
```

**Стало:**

```swift
    func runIfNeeded() async {
        guard let pendingUid = pendingStore.loadPending() else { return }
        guard let currentUid = auth.currentUID, currentUid == pendingUid else {
            suppressedRestoreStore.suppressRestore(for: pendingUid)
            return
        }
        // Аккаунт "воскрешён" инвайт-join'ом после старта удаления: пользователь
        // активно пользуется тем же uid в новой семье. Продолжать фоновую зачистку —
        // значит удалить его свежий member doc (а как sole member — всю семью).
        if (try? await cloudEraser.hasInviteEstablishedMembership(uid: currentUid)) == true {
            pendingStore.clearPending()
            suppressedRestoreStore.clearSuppression(for: currentUid)
            return
        }
        suppressedRestoreStore.suppressRestore(for: pendingUid)
        do {
            try await cloudEraser.deleteCloudData(uid: currentUid)
```

Расширить протокол `CloudAccountEraser` (`:9–15`):

```swift
    /// True когда users/{uid}.familyId указывает на семью, где members/{uid}
    /// существует и содержит inviteCode — членство переустановлено явным join'ом.
    func hasInviteEstablishedMembership(uid: String) async throws -> Bool
```

Реализация в `FirestoreCloudAccountEraser` (рядом с `deleteCloudData`, `~:56`):

```swift
    func hasInviteEstablishedMembership(uid: String) async throws -> Bool {
        let userDoc = try await db.collection("users").document(uid)
            .getDocument(source: .server)
        guard let familyId = userDoc.data()?["familyId"] as? String, !familyId.isEmpty
        else { return false }
        let member = try? await db.collection("families").document(familyId)
            .collection("members").document(uid).getDocument(source: .server)
        return (member?.data()?["inviteCode"] as? String) != nil
    }
```

В `MomsyTests/Features/Account/DeleteAccountTests.swift` дополнить `MockCloudEraser` (`:7–24`):

```swift
    var inviteMembership = false
    func hasInviteEstablishedMembership(uid: String) async throws -> Bool { inviteMembership }
```

Известное ограничение (принято): если пользователь изначально вступал в семью по инвайту, потом удалил аккаунт и erase не подтвердился сервером, recovery не дотрёт остаток — `inviteCode` неотличим по времени. Приемлемо: `execute()` уже выполнил основной erase, а альтернатива уничтожает живые семьи.

---

## Тесты (Swift Testing)

Новый файл `MomsyTests/Core/Family/FamilySuppressedRestoreTests.swift`:

```swift
import Testing
@testable import Momsy

struct FamilySuppressedRestoreTests {
    @Test func inviteMembershipIsAdoptedNotDeleted() {
        #expect(FamilyManager.resolveSuppressedRestore(
            memberDocExists: true, memberHasInviteCode: true
        ) == .adoptInviteMembership)
    }

    @Test func preDeletionMembershipIsDiscarded() {
        #expect(FamilyManager.resolveSuppressedRestore(
            memberDocExists: true, memberHasInviteCode: false
        ) == .discardStaleMembership)
    }

    @Test func missingMemberDocStartsFresh() {
        #expect(FamilyManager.resolveSuppressedRestore(
            memberDocExists: false, memberHasInviteCode: true
        ) == .startFresh)
        #expect(FamilyManager.resolveSuppressedRestore(
            memberDocExists: false, memberHasInviteCode: false
        ) == .startFresh)
    }
}
```

В `DeleteAccountTests.swift` добавить:

```swift
    @Test func recoverySkipsEraseWhenMembershipReestablishedByInvite() async {
        let eraser = MockCloudEraser()
        eraser.inviteMembership = true
        let pending = MockPendingStore(); pending.pendingUid = "u1"
        let suppressed = MockSuppressedRestoreStore()
        suppressed.suppressedUIDs = ["u1"]
        let auth = MockAuth(); auth.currentUID = "u1"
        let recovery = AccountDeletionRecovery(
            cloudEraser: eraser, auth: auth,
            pendingStore: pending, suppressedRestoreStore: suppressed
        )
        await recovery.runIfNeeded()
        #expect(eraser.calls.deleteCount == 0)
        #expect(pending.pendingUid == nil)
        #expect(suppressed.suppressedUIDs.isEmpty)
    }
```

(Свериться с фактическими именами полей моков в файле; `MockCloudEraser.Calls` уже считает вызовы — при необходимости адаптировать имена. Если `MockCloudEraser` объявлен как `struct` — счётчик уже в reference-типе `Calls`, `inviteMembership` добавить как `var` со значением по умолчанию в `Calls` либо параметром init.)

Локализация: изменений UI-строк нет — новые L10n-ключи не требуются.
pbxproj: только один новый файл тестов — добавить `FamilySuppressedRestoreTests.swift` в таргет `MomsyTests`.

---

## Definition of Done

- [ ] `joinFamily` после `batch.commit()` снимает suppression и pending-маркер для uid
- [ ] Suppressed-ветка `setup()` адоптирует member doc с `inviteCode`, удаляет только doc без него, transient-ошибки чтения пробрасывает
- [ ] `resolveSuppressedRestore` добавлена как `nonisolated static`, покрыта тестами (3 кейса)
- [ ] `AccountDeletionRecovery` пропускает erase при invite-переустановленном членстве, гасит pending + suppression
- [ ] `CloudAccountEraser.hasInviteEstablishedMembership` реализован, мок обновлён
- [ ] Все существующие тесты зелёные (`FamilyMembershipCheckTests`, `FamilyJoinFlowFlagTests`, `DeleteAccountTests`, `FamilyCacheReauthTests`)
- [ ] Сборка iOS + Watch + Widget таргетов без предупреждений в изменённых файлах

## Manual QA (симулятор, 2 аккаунта)

1. **Репро-сценарий:** Аккаунт B: Settings → Delete Account (добиться fallback-пути: удаление с давним входом ⇒ `reauthRequired` ⇒ signOut). Войти тем же провайдером (тот же uid). Из аккаунта A создать инвайт, B джойнится по коду. Убить приложение B, запустить снова. **Ожидание:** B остаётся в Settings → Family на обоих девайсах, member doc в консоли Firestore на месте, новая личная семья НЕ создана.
2. **Синхронизация:** A добавляет прогулку → появляется у B ≤ 30 сек. B добавляет кормление → появляется у A. Редактирование старой записи у A → приезжает к B (watermark по `updatedAt`).
3. **Регрессия зачистки:** свежий аккаунт C (без join) удаляет аккаунт при плохой сети (erase не подтверждён) → перезапуск → recovery дотирает данные, «ghost»-дети не возвращаются.
4. **Регрессия revocation:** A удаляет B из семьи → следующий запуск B: detach, создание личной семьи, алерт — как раньше.
