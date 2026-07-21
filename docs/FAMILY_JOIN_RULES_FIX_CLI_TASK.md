# P1: Члены семьи не видят друг друга после join по инвайт-линку

**Причина:** регрессия из коммита `7b5f6e3` (Harden Firebase family sharing rules). Два дефекта в `firestore.rules`, ломающие цепочку invite → join в проде (эмулятор их не воспроизводит — поэтому тесты проходили).

## Диагноз

**A. `inviteImmutableFieldsUnchanged()` — точное `==` на `expiresAt`.**
`FirestoreInviteService.updateInviteRole` (вызывается на каждом показе инвайта в Onboarding и Sharing сразу после create) повторно шлёт `Timestamp(date: cachedExpiry)` с наносекундной точностью. Сохранённое значение Firestore усекает до микросекунд. `request.resource.data.expiresAt == resource.data.expiresAt` → ложь почти всегда → update отклонён → генерация инвайта падает (`inviteError`/`saveError`), либо инвайт остаётся без `roleRaw`.

**B. `hasValidInviteData()` — верхняя граница `expiresAt <= request.time + 24h` без допуска.**
Клиент ставит `Date() + 86400`. Часы устройства впереди серверных на доли секунды → отклоняются и create, и update инвайта → документ инвайта не появляется на сервере → у joiner `get(invites/{code})` = permission-denied → `FamilyError.invalidOrExpiredCode` → join фактически не происходит; оба пользователя остаются в своих личных семьях → в Family каждый видит только себя.

## Fix (2 файла, только правила + тест)

### 1. `firestore.rules`

`hasValidInviteData()` — допуск 10 минут на расхождение часов:
```diff
         && request.resource.data.expiresAt > request.time
-        && request.resource.data.expiresAt <= request.time + duration.value(24, 'h')
+        // 10 min of client-clock-skew tolerance: expiresAt is client-computed
+        // (Date() + 24h), so a device clock slightly ahead of the server must
+        // not deny the write.
+        && request.resource.data.expiresAt <= request.time + duration.value(24, 'h') + duration.value(10, 'm')
```

`inviteImmutableFieldsUnchanged()` — сравнение на миллисекундах:
```diff
       return request.resource.data.familyId == resource.data.familyId
         && request.resource.data.createdBy == resource.data.createdBy
-        && request.resource.data.expiresAt == resource.data.expiresAt;
+        // Millisecond equality, not `==`: Firestore truncates stored timestamps
+        // to microseconds while the client re-sends its nanosecond-precision
+        // Timestamp(date:), so exact equality fails on every role update.
+        && request.resource.data.expiresAt.toMillis() == resource.data.expiresAt.toMillis();
```

Безопасность не деградирует: продлить инвайт по-прежнему нельзя (расхождение < 1 мс), TTL 24ч ± 10 мин, схема/`createdBy`/cross-family-ограничения не тронуты.

### 2. `tests/firebase-rules.test.mjs`

Добавлен тест `"invite create, role update, and self-invite join keep both members visible"` — воспроизводит точную клиентскую последовательность: create инвайта → `updateInviteRole` с повторной отправкой того же `expiresAt` → batch присоединения (member doc + `users/{uid}`) → листинг roster обоими участниками → merge самовосстановления `ensureMemberDocument`. Плюс negative-кейс: join с ролью, не совпадающей с инвайтом, отклоняется. Существующие ассерты сьюта совместимы с фиксом (проверено: +25h create по-прежнему fail; смена `expiresAt` при update по-прежнему fail).

Swift-код не менялся — фикс серверный, действует сразу для всех установленных сборок после деплоя правил.

## Definition of Done
- [ ] `npm test` зелёный (весь сьют, включая новый join-flow тест)
- [ ] `firebase deploy --only firestore:rules`
- [ ] Manual QA: устройство A — создать инвайт (роль Папа), поделиться линком; устройство B — открыть линк, присоединиться; на обоих устройствах Family показывает двух членов; на B перезапустить приложение — roster сохраняется (self-heal не выбивает)
- [ ] Manual QA (роль): инвайт с ролью Няня → joiner получает Няня, roster виден обоим
