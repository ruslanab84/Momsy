# ACCOUNT DELETION FOLLOW-UP — CLI TASK

**Репозиторий:** `ruslanab84/Momsy`
**Базовый коммит:** `c1a5d63239da7438d78e506ec9f6adcde77f6287` («Fix account deletion GDPR compliance…»)
**Ветка:** `fix/account-deletion-followup`

## Контекст

Предыдущий таск закрыт по существу: `AccountErasureOutcome`, `familyIdHint`, `PendingAccountDeletion`, `PendingAuthAccountDeletionStore`, чистка `profile/info.members`, снос ростера при teardown — всё на месте и корректно.

Остались 4 дефекта. **Три из них — ошибки предыдущей спеки, а не исполнения:** в ней были показаны только изменённые хунки, из-за чего взаимодействие с нетронутыми строками ниже по функции и с точкой входа в новое состояние не проверялось.

| ID | Severity | Проблема |
|---|---|---|
| B1 | Blocker | 3 существующих теста утверждают поведение, обратное новому коду — сьюты красные |
| B2 | Blocker | Облако стёрто, маркер снят, `eraseLocal()` пропущен → локальные данные заливаются обратно в новую семью |
| B3 | Major | `retryAuthDeletionIfNeeded()` недостижим из продакшена — Auth-запись не удаляется никогда |
| B4 | Minor | `switchFromAnonymousAccount` передаёт `familyIdHint: nil`, потерян прежний фоллбэк |

## Жёсткие ограничения

- Только перечисленные файлы. Ничего не переписывать целиком.
- `firestore.rules`, `L10n.swift`, `.lproj` — **не трогать**.
- **Прогнать тесты и вставить сводку `xcodebuild test` в описание коммита.** `build ✓` не считается за прогон.

---

## Целевая матрица состояний

Эталон поведения. Любое изменение сверяется с этой таблицей — реализация обязана покрывать все шесть строк.

| Исход облака | Исход Auth | Блокирующий маркер | `pendingAuthStore` | `eraseLocal()` | Что бросаем |
|---|---|---|---|---|---|
| Ошибка (сеть/права) | не пробовали | **оставить** | — | **да** | `cloudError` |
| `isCloudDataPresent == true` | не пробовали | **оставить** | — | **да** | `.accountDeletionPending` |
| Чисто | успех | снять | снять | **да** | ничего |
| Чисто | ошибка | снять | **поставить** | **да** ← B2 | `authError` |
| `.supersededByNewFamily` (recovery) | не пробовали | снять | — | нет | ничего |
| Нет блокирующего маркера, есть auth-маркер | best-effort | — | снять при успехе / при `accountIsInUse` | нет | ничего |

Ключевой инвариант: **`eraseLocal()` выполняется на каждом пути, где `execute()` вообще дошёл до попытки стирания.** Единственный старый ранний `throw` перед ним и есть B2.

---

## Task B2 — не пропускать локальную очистку при неудаче удаления Auth-записи

**Файл:** `Momsy/Core/Account/DeleteAccountUseCase.swift`, строки 466–516

### Before (строки 466–470)

```swift
    func execute() async throws {
        var cloudError: Error?
        var authError: Error?
        var completionError: Error?
```

### After

```swift
    func execute() async throws {
        var cloudError: Error?
        var authError: Error?
        var completionError: Error?
        /// The server confirmed the cloud footprint is gone. From this point the deletion
        /// IS complete data-wise, so the device must be wiped even if the Auth record
        /// could not be retired — otherwise the local store survives, `FamilyManager`
        /// detaches from the revoked membership on the next launch and re-uploads
        /// everything into a brand-new family, silently undoing the deletion.
        var cloudConfirmedClean = false
```

### Before (строки 486–489)

```swift
                } else {
                    // Cloud is server-confirmed clean: the user owns no data from here on,
                    // so the blocking marker must go regardless of what Auth does next.
                    pendingStore.clearPending()
```

### After

```swift
                } else {
                    // Cloud is server-confirmed clean: the user owns no data from here on,
                    // so the blocking marker must go regardless of what Auth does next.
                    cloudConfirmedClean = true
                    pendingStore.clearPending()
```

### Before (строки 506–512)

```swift
        // Keep the current session, retry marker, and local UI available so provider
        // reauthentication/revocation can finish before the deletion is reported complete.
        if let authError { throw authError }

        // Always leave the device clean, even if the cloud erase didn't fully confirm.
        try eraseLocal()
        FamilyManager.shared.reset()
```

### After

```swift
        // Before the cloud is confirmed clean, keep the session, the blocking marker and the
        // local UI available so provider reauthentication can finish before anything is wiped.
        if let authError, !cloudConfirmedClean { throw authError }

        // Always leave the device clean, even if the cloud erase didn't fully confirm.
        try eraseLocal()
        FamilyManager.shared.reset()

        // Cloud already gone: the wipe above completed the erasure. Still surface the Auth
        // failure so Settings can offer reauthentication; `pendingAuthStore` retries otherwise.
        if let authError { throw authError }
```

> `SettingsViewModel.deleteAllData()` уже ловит `AuthError.reauthRequired` и показывает шит — порядок вызовов там менять не нужно.

---

## Task B3 — сделать ретрай удаления Auth-записи достижимым

**Файл:** `Momsy/Core/DI/AppContainer.swift`, строки 653–658

Ранний `guard` возвращает управление до `runIfNeeded()`, а ретрай внутри `runIfNeeded()` срабатывает **только** когда блокирующего маркера нет. Пересечение пусто — путь мёртв.

### Before

```swift
    @MainActor
    func recoverPendingAccountDeletion() async -> Bool {
        guard let pendingAtStart = pendingAccountDeletionStore.loadPending() else { return false }
        let currentUidAtStart = authManager.currentUID
        await accountDeletionRecovery.runIfNeeded()
```

### After

```swift
    @MainActor
    func recoverPendingAccountDeletion() async -> Bool {
        let pendingAtStart = pendingAccountDeletionStore.loadPending()
        let currentUidAtStart = authManager.currentUID
        // Always enter recovery: with no blocking marker it still drives the non-blocking
        // Auth-record retry, which is the only production entry point for that path.
        await accountDeletionRecovery.runIfNeeded()
        guard let pendingAtStart else { return false }
```

Остальное тело метода без изменений (`pendingAtStart.uid` уже используется ниже).

---

## Task B4 — вернуть корректный `familyIdHint` при switch анонимного аккаунта

**Файл:** `Momsy/Core/Auth/AuthManager.swift`

`cachedFamilyId` уже захвачен на строке 187 и используется в `purgeLocalData`. `nil` здесь потерял прежний фоллбэк на `FamilyManager.shared.familyId`: у анонимного пользователя без `users/{uid}` данные семьи переживут switch.

### Before (строка 168–176)

```swift
    static func switchFromAnonymousAccount<Result>(
        anonymousUid: String,
        cloudEraser: any CloudAccountEraser,
        deleteAuthUser: () async throws -> Void,
        purgeLocalData: () async -> Void,
        signIn: () async throws -> Result
    ) async throws -> Result {
        _ = try await cloudEraser.deleteCloudData(uid: anonymousUid, familyIdHint: nil)
```

### After

```swift
    static func switchFromAnonymousAccount<Result>(
        anonymousUid: String,
        cloudEraser: any CloudAccountEraser,
        familyIdHint: String?,
        deleteAuthUser: () async throws -> Void,
        purgeLocalData: () async -> Void,
        signIn: () async throws -> Result
    ) async throws -> Result {
        _ = try await cloudEraser.deleteCloudData(uid: anonymousUid, familyIdHint: familyIdHint)
```

### Before (строка ~193)

```swift
                return try await Self.switchFromAnonymousAccount(
                    anonymousUid: anonymousUid,
                    cloudEraser: cloudEraser,
                    deleteAuthUser: {
```

### After

```swift
                return try await Self.switchFromAnonymousAccount(
                    anonymousUid: anonymousUid,
                    cloudEraser: cloudEraser,
                    familyIdHint: cachedFamilyId,
                    deleteAuthUser: {
```

---

## Task B1 — привести существующие тесты к новому поведению

Три ассерта фиксируют поведение **до** переноса `clearPending()`. Не удалять — переписать под целевую матрицу.

### B1.1 · `MomsyTests/Features/Account/DeleteAccountTests.swift`, строки 170–187

**Before**

```swift
    @Test("keeps the session and deletion marker when recent authentication is required")
    func reauthRequiredDoesNotSignOutOrWipe() async {
        let (uc, _, auth, pending, authPending, _, wipes) = makeUseCase(authError: AuthError.reauthRequired)
        ...
        #expect(auth.deleteCount == 1)
        #expect(auth.signOutCount == 0)
        #expect(pending.pendingUid == "user-1")
        #expect(pending.clearCount == 0)
        #expect(authPending.pendingUid == "user-1")
        #expect(wipes() == 0)
    }
```

**After**

```swift
    @Test("wipes the device and releases the blocking marker when only Auth deletion fails")
    func reauthRequiredStillCompletesTheErasure() async {
        let (uc, _, auth, pending, authPending, _, wipes) = makeUseCase(authError: AuthError.reauthRequired)

        await #expect {
            try await uc.execute()
        } throws: { error in
            guard case AuthError.reauthRequired = error else { return false }
            return true
        }

        #expect(auth.deleteCount == 1)
        #expect(auth.signOutCount == 0)
        // Cloud was server-confirmed clean: re-registration must not be blocked…
        #expect(pending.pendingUid == nil)
        #expect(pending.clearCount == 1)
        // …the Auth record moves to the non-blocking retry…
        #expect(authPending.pendingUid == "user-1")
        // …and the device is wiped, so the deletion cannot undo itself on the next launch.
        #expect(wipes() == 1)
    }
```

### B1.2 · тот же файл, строки 189–200

**Before**

```swift
    @Test("keeps deletion pending when provider revoke or Auth deletion fails")
    func authRetirementFailureKeepsPending() async {
        let (uc, _, auth, pending, _, _, wipes) = makeUseCase(authError: DummyError())
        ...
        #expect(auth.signOutCount == 0)
        #expect(pending.pendingUid == "user-1")
        #expect(pending.clearCount == 0)
        #expect(wipes() == 0)
    }
```

**After**

```swift
    @Test("hands a failed provider revoke to the Auth retry without blocking re-registration")
    func authRetirementFailureDefersToAuthRetry() async {
        let (uc, _, auth, pending, authPending, _, wipes) = makeUseCase(authError: DummyError())

        await #expect(throws: DummyError.self) {
            try await uc.execute()
        }

        #expect(auth.signOutCount == 0)
        #expect(pending.pendingUid == nil)
        #expect(authPending.pendingUid == "user-1")
        #expect(wipes() == 1)
    }
```

### B1.3 · тот же файл, строки 560–581

**Before**

```swift
    @Test("keeps the session and marker when recovery needs recent authentication")
    func recoveryReauthRequiredKeepsSessionAndMarker() async {
        ...
        #expect(pending.pendingUid == "abc")
        #expect(authPending.pendingUid == "abc")
        #expect(pending.clearCount == 0)
    }
```

**After** — сценарий полностью дублирует `clearsMarkerAfterConfirmedCleanCloud` (строка 583). Удалить `recoveryReauthRequiredKeepsSessionAndMarker` целиком и заменить тестом, который проверяет **другую** ветку — маркер сохраняется, когда сервер ещё отдаёт данные:

```swift
    @Test("keeps the session and marker when the server still reports data during recovery")
    func recoveryKeepsMarkerWhileServerStillHasData() async {
        let cloud = MockCloudEraser.Calls()
        cloud.stillPresent = true
        let auth = MockAuth(uid: "abc")
        auth.deleteError = AuthError.reauthRequired
        let pending = MockPendingStore(pendingUid: "abc", familyId: "fam-1")
        let authPending = MockPendingAuthStore()
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: cloud), auth: auth,
            pendingStore: pending, pendingAuthStore: authPending,
            suppressedRestoreStore: MockSuppressedRestoreStore(), accountIsInUse: { false })

        await rec.runIfNeeded()

        #expect(auth.deleteCount == 0)        // Auth is never touched before the cloud is clean
        #expect(pending.pendingUid == "abc")  // marker survives for the next launch
        #expect(authPending.pendingUid == nil)
    }
```

### B1.4 · Новые тесты для непокрытых веток

`MomsyTests/Features/Account/DeleteAccountTests.swift`, сьют `DeleteAccountUseCase`:

```swift
    @Test("keeps the blocking marker and wipes locally when the cloud erase fails")
    func cloudFailureKeepsMarkerAndStillWipes() async {
        let (uc, _, _, pending, authPending, _, wipes) = makeUseCase(cloudError: DummyError())

        await #expect(throws: DummyError.self) { try await uc.execute() }

        #expect(pending.pendingUid == "user-1")
        #expect(authPending.pendingUid == nil)
        #expect(wipes() == 1)
    }

    @Test("keeps the blocking marker while the server still reports data")
    func stillPresentKeepsMarker() async {
        let (uc, _, auth, pending, _, _, wipes) = makeUseCase(stillPresent: true)

        await #expect {
            try await uc.execute()
        } throws: { error in
            guard case AuthError.accountDeletionPending = error else { return false }
            return true
        }

        #expect(auth.deleteCount == 0)
        #expect(pending.pendingUid == "user-1")
        #expect(wipes() == 1)
    }

    @Test("records the family the deletion is authorised against")
    func recordsFamilyScope() async {
        let (uc, cloud, _, _, _, _, _) = makeUseCase()
        _ = try? await uc.execute()
        #expect(cloud.familyHints.count == 1)
    }
```

Сьют `AccountDeletionRecovery` — покрыть B3-путь:

```swift
    @Test("drives the Auth retry when only the non-blocking marker is left")
    func runsAuthRetryWithoutBlockingMarker() async {
        let authPending = MockPendingAuthStore()
        authPending.markPending(uid: "abc")
        let auth = MockAuth(uid: "abc")
        let rec = AccountDeletionRecovery(
            cloudEraser: MockCloudEraser(calls: .init()), auth: auth,
            pendingStore: MockPendingStore(pendingUid: nil), pendingAuthStore: authPending,
            suppressedRestoreStore: MockSuppressedRestoreStore(), accountIsInUse: { false })

        await rec.runIfNeeded()

        #expect(auth.deleteCount == 1)
        #expect(authPending.pendingUid == nil)
    }
```

### B1.5 · `MomsyTests/Features/Settings/AccountAuthViewModelTests.swift`

Обновить вызовы `AuthManager.switchFromAnonymousAccount` — добавить `familyIdHint:` (например `"fam-anon"`), и добавить ассерт, что мок получил именно его.

---

## Definition of Done

- [ ] `execute()` вызывает `eraseLocal()` + `FamilyManager.shared.reset()` на **всех** путях, где была попытка стирания, включая `cloudConfirmedClean && authError != nil`.
- [ ] `AppContainer.recoverPendingAccountDeletion()` вызывает `runIfNeeded()` до раннего выхода.
- [ ] `switchFromAnonymousAccount` принимает и пробрасывает `familyIdHint`; вызывающая сторона передаёт `cachedFamilyId`.
- [ ] `grep -rn "familyIdHint: nil" Momsy/` — пусто.
- [ ] Все шесть строк матрицы состояний покрыты тестом; ни один тест не утверждает `pendingUid != nil` при `stillPresent == false`.
- [ ] `firestore.rules`, `L10n.swift`, `*.lproj` не изменены.
- [ ] **В описание коммита вставлена сводка `xcodebuild test`** с числом пройденных/упавших: сьюты `DeleteAccountUseCase`, `AccountDeletionRecovery`, `AccountErasureGate`, `AccountAuthViewModel` — 0 failures.

---

## Manual QA (регрессии этого таска)

**QA-B2 — удаление не отменяет само себя.**
1. Удалить аккаунт, на экране реаутентификации нажать «Отмена».
2. Принудительно закрыть приложение, запустить снова.
3. **Ожидаемо:** приложение в онбординге, локальных данных нет. **Не** должно быть: старые кормления/сны на месте и через минуту появившаяся новая семья в Firebase Console.

**QA-B3 — Auth-запись всё-таки удаляется.**
1. Повторить QA-B2 шаг 1–2.
2. Запустить приложение, не проходя онбординг, подождать ~10 секунд.
3. **Firebase Console → Authentication:** запись пользователя удалена.
4. Если пользователь успел заново зарегистрироваться тем же провайдером и создать семью — запись **не** удаляется, `pendingAuthAccountDeletion_uid_v1` очищается.

**QA-B4 — switch анонимного аккаунта.**
1. Пройти онбординг анонимно с включённым cloud sync, добавить записи.
2. Войти через Apple ID, который **уже** привязан к другому аккаунту Momsy.
3. **Firebase Console:** дерево анонимной семьи удалено полностью, не осталось осиротевших `families/{id}/babies/**`.
