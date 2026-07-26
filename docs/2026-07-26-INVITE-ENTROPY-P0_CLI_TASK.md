# P0 — Invite Code Entropy Hardening

> **For agentic workers:** Steps use checkbox (`- [ ]`) syntax for tracking. Execute task-by-task, commit after each task.

**Goal:** Поднять энтропию инвайт-кода с 2³⁰ до 2⁶⁰ и закрыть brute-force oracle в Firestore rules, чтобы посторонний не мог перебором получить полный админ-доступ к чужой семье.

**Architecture:** Формат кода выносится в единственный источник правды `InviteCodeFormat` (Domain-слой Sharing). Генератор (Data), валидатор перед сетевым запросом (Core/Family), плейсхолдер (Presentation) и regex в `firestore.rules` ссылаются на один и тот же формат. Проверка формата в rules ставится **первой** в `allow get`, до `familyExists()`, чтобы отсечь перебор до биллируемого чтения.

**Tech Stack:** Swift 6 / SwiftUI, Swift Testing, Firestore Security Rules (RE2), `@firebase/rules-unit-testing` + Firestore emulator.

**Базовый коммит:** `ae94e7a56e6b73f169d4c1947cbfe3fe2c94926b`

---

## Контекст угрозы

`FirestoreInviteService.swift:167-171` генерирует `MOMSY-` + 6 символов из 32-символьного алфавита = **2³⁰ ≈ 1.07 млрд**.

Цепочка эксплуатации:
1. `firestore.rules:241` — `allow get: if isSignedIn()`. Анонимная авторизация в приложении включена → регистрация атакующего бесплатна и неограниченна.
2. Ответ `get` — чистый оракул: `permission-denied` = кода нет/истёк, успех = код валиден.
3. `isSelfInviteJoin` при отсутствии `roleRaw` в инвайте назначает роль `'Папа'` → `canManageFamilyRoster` → чтение/запись всех логов ребёнка, удаление участников (включая настоящую маму), удаление семьи.
4. Каждая попытка вызывает `familyExists()` внутри rules — **биллируемое чтение даже при отказе** → cost-DoS на владельца проекта.

Ожидаемое число попыток до попадания = 2³⁰ / (число активных инвайтов). При нескольких тысячах живых 24-часовых кодов это минуты работы.

**После фикса:** 2⁶⁰ ≈ 1.15×10¹⁸. Плюс отсечка по regex до `familyExists()` делает перебор бесплатным для владельца проекта и бессмысленным для атакующего.

### Предпосылка (подтвердить перед стартом)

Приложение **ещё не в App Store**. Поэтому обратная совместимость со старыми 6-символьными кодами не требуется, и rules можно ужесточить сразу и жёстко. Если это не так — остановись и сообщи: понадобится окно миграции с двумя regex.

### Что НЕ входит в scope

- Сокращение TTL 24 ч (см. Follow-up в конце).
- Одноразовость инвайтов — меняет UX (сейчас один код шарится и папе, и няне) и требует правки `isSelfInviteJoin`. Отдельная задача.
- Cloud Functions / rate-limiting — в проекте нет `functions` (см. `firebase.json`), а при 2⁶⁰ они не нужны для закрытия этого блокера.

---

## File Structure

| Файл | Ответственность |
|---|---|
| `Momsy/Features/Sharing/Domain/Models/InviteCodeFormat.swift` | **Create.** Единственный источник правды: алфавит, длина, regex, генерация, валидация. Без состояния, без зависимостей. |
| `Momsy/Features/Sharing/Data/Services/FirestoreInviteService.swift` | **Modify.** Генерация делегируется в Domain; кэш перестаёт переиспользовать код старого формата. |
| `Momsy/Core/Family/FamilyManager.swift` | **Modify.** Валидация формата до сетевого запроса — экономит чтение и не даёт своему же клиенту генерировать нагрузку. |
| `Momsy/Features/Onboarding/Presentation/Views/OBStepJoinFamily.swift` | **Modify.** Плейсхолдер под новый формат. |
| `firestore.rules` | **Modify.** `isStrongInviteCode(code)` на `get` и `create`. |
| `MomsyTests/Features/Sharing/InviteCodeFormatTests.swift` | **Create.** Swift Testing. |
| `MomsyTests/Features/Sharing/FamilySwitchPolicyTests.swift` | **Modify.** Миграция трёх существующих вызовов под новую сигнатуру. |
| `tests/firebase-rules.test.mjs` | **Modify.** 12 констант кодов + 2 новых теста. |

**pbxproj wiring не требуется.** В `Momsy.xcodeproj/project.pbxproj` используется `PBXFileSystemSynchronizedRootGroup` (Xcode 16) — новые файлы подхватываются по факту наличия на диске.

---

### Task 1: Формат инвайт-кода в Domain

**Files:**
- Create: `Momsy/Features/Sharing/Domain/Models/InviteCodeFormat.swift`
- Test: `MomsyTests/Features/Sharing/InviteCodeFormatTests.swift`

- [ ] **Step 1: Написать падающий тест**

Создать `MomsyTests/Features/Sharing/InviteCodeFormatTests.swift`:

```swift
import Testing
import Foundation
@testable import Momsy

@Suite("InviteCodeFormat")
struct InviteCodeFormatTests {

    @Test("generated code matches the canonical MOMSY-XXXX-XXXX-XXXX shape")
    func generatedShape() {
        let code = InviteCodeFormat.generate()
        #expect(code.count == 20)
        #expect(code.hasPrefix("MOMSY-"))
        #expect(code.split(separator: "-").count == 4)
        #expect(InviteCodeFormat.isValid(code))
    }

    @Test("generated codes only use the ambiguity-free alphabet")
    func generatedAlphabet() {
        let allowed = Set("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        for _ in 0..<200 {
            let body = InviteCodeFormat.generate()
                .dropFirst("MOMSY-".count)
                .filter { $0 != "-" }
            #expect(body.allSatisfy { allowed.contains($0) })
        }
    }

    @Test("2000 generated codes are all distinct")
    func generatorEntropy() {
        let codes = Set((0..<2000).map { _ in InviteCodeFormat.generate() })
        #expect(codes.count == 2000)
    }

    @Test("legacy six-character codes are rejected")
    func rejectsLegacyCodes() {
        #expect(!InviteCodeFormat.isValid("MOMSY-ABC234"))
        #expect(!InviteCodeFormat.isValid("MOMSY-BBB234"))
        #expect(!InviteCodeFormat.isValid("MOMSY-JOIN01"))
    }

    @Test("malformed codes are rejected")
    func rejectsMalformed() {
        #expect(!InviteCodeFormat.isValid(""))
        #expect(!InviteCodeFormat.isValid("MOMSY"))
        #expect(!InviteCodeFormat.isValid("momsy-a2b3-c4d5-e6f7"))       // lowercase
        #expect(!InviteCodeFormat.isValid("MOMSY-A2B3-C4D5"))            // 2 группы
        #expect(!InviteCodeFormat.isValid("MOMSY-A2B3-C4D5-E6F7-G8H9"))  // 4 группы
        #expect(!InviteCodeFormat.isValid("MOMSY-A2B3-C4D5-E6FI"))       // I вне алфавита
        #expect(!InviteCodeFormat.isValid("MOMSY-A2B3-C4D5-E6F0"))       // 0 вне алфавита
        #expect(!InviteCodeFormat.isValid("XXXXX-A2B3-C4D5-E6F7"))       // чужой префикс
        #expect(!InviteCodeFormat.isValid("MOMSY-A2B3-C4D5-E6F7\n"))     // хвостовой перевод строки
    }

    @Test("a hand-written canonical code is accepted")
    func acceptsCanonical() {
        #expect(InviteCodeFormat.isValid("MOMSY-A2B3-C4D5-E6F7"))
    }

    @Test("the Swift pattern and the Firestore rules pattern are identical")
    func patternIsShared() {
        #expect(InviteCodeFormat.pattern == "^MOMSY(-[A-HJ-NP-Z2-9]{4}){3}$")
    }
}
```

- [ ] **Step 2: Запустить тест — убедиться, что падает**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/InviteCodeFormat`

Expected: FAIL — `cannot find 'InviteCodeFormat' in scope`.

- [ ] **Step 3: Реализовать**

Создать `Momsy/Features/Sharing/Domain/Models/InviteCodeFormat.swift`:

```swift
import Foundation

/// Единственный источник правды для формата семейного инвайт-кода.
///
/// `MOMSY-XXXX-XXXX-XXXX` — 12 символов из 32-символьного алфавита без
/// визуально неоднозначных знаков (нет I/O/0/1), то есть 32¹² ≈ 2⁶⁰ вариантов.
/// Прежний шестисимвольный код давал 2³⁰ и перебирался за минуты, что означало
/// полный админ-доступ к чужой семье (роль по умолчанию при join — родитель).
///
/// `pattern` дублируется в `firestore.rules` (`isStrongInviteCode`). Обе стороны
/// закреплены тестами: `InviteCodeFormatTests.patternIsShared` и
/// `tests/firebase-rules.test.mjs`.
enum InviteCodeFormat {
    static let prefix = "MOMSY"
    static let separator = "-"
    static let groupCount = 3
    static let groupLength = 4

    /// Без I, O, 0, 1 — код диктуется голосом и вводится вручную.
    static let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")

    /// `MOMSY` + три группы по 4 символа с разделителями.
    static let length = prefix.count + groupCount * (separator.count + groupLength)

    static let pattern = "^MOMSY(-[A-HJ-NP-Z2-9]{4}){3}$"

    /// Плейсхолдер поля ввода. Формат, а не текст — локализации не требует.
    static let placeholder = "MOMSY-XXXX-XXXX-XXXX"

    /// `Int.random(in:)` использует `SystemRandomNumberGenerator`, который на
    /// платформах Apple опирается на криптографический системный источник.
    static func generate() -> String {
        let groups = (0..<groupCount).map { _ in
            String((0..<groupLength).map { _ in alphabet[Int.random(in: alphabet.indices)] })
        }
        return ([prefix] + groups).joined(separator: separator)
    }

    /// Явная проверка длины идёт вместе с regex: якорь `$` в ICU допускает
    /// завершающий перевод строки, а идентификатор документа Firestore — нет.
    static func isValid(_ code: String) -> Bool {
        code.count == length
            && code.range(of: pattern, options: .regularExpression) != nil
    }
}
```

- [ ] **Step 4: Запустить тест — убедиться, что проходит**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/InviteCodeFormat`

Expected: PASS, 7 тестов.

- [ ] **Step 5: Коммит**

```bash
git add Momsy/Features/Sharing/Domain/Models/InviteCodeFormat.swift \
        MomsyTests/Features/Sharing/InviteCodeFormatTests.swift
git commit -m "feat(security): add InviteCodeFormat with 2^60 invite entropy"
```

---

### Task 2: Генерация и инвалидация кэша в FirestoreInviteService

**Files:**
- Modify: `Momsy/Features/Sharing/Data/Services/FirestoreInviteService.swift:20-47`, `:108-121`, `:155-166`
- Test: `MomsyTests/Features/Sharing/FamilySwitchPolicyTests.swift:28-42`

Причина изменения `canReuseCachedInvite`: код кэшируется в `UserDefaults` под `firestore_invite_code_v1` на 24 часа. Без проверки формата уже установленный билд продолжит показывать старый шестисимвольный код, который новые rules откажутся отдавать на `get` → join сломается. Добавление `cachedCode` в предикат делает инвалидацию самовосстанавливающейся, без bump'а ключей и без миграционного кода.

- [ ] **Step 1: Написать падающий тест**

Заменить в `MomsyTests/Features/Sharing/FamilySwitchPolicyTests.swift` строки 28-42 на:

```swift
    @Test("cached invite is reusable only for its family while unexpired")
    func familyAndExpiryMustMatch() {
        let now = Date(timeIntervalSince1970: 1_000)
        let future = now.addingTimeInterval(60)
        let strong = "MOMSY-A2B3-C4D5-E6F7"

        #expect(FirestoreInviteService.canReuseCachedInvite(
            cachedCode: strong, cachedFamilyId: "A", currentFamilyId: "A", expiry: future, now: now
        ))
        #expect(!FirestoreInviteService.canReuseCachedInvite(
            cachedCode: strong, cachedFamilyId: "A", currentFamilyId: "B", expiry: future, now: now
        ))
        #expect(!FirestoreInviteService.canReuseCachedInvite(
            cachedCode: strong, cachedFamilyId: "A", currentFamilyId: "A", expiry: now, now: now
        ))
    }

    @Test("a cached legacy-format code is never reused")
    func legacyCachedCodeForcesRegeneration() {
        let now = Date(timeIntervalSince1970: 1_000)
        let future = now.addingTimeInterval(60)

        #expect(!FirestoreInviteService.canReuseCachedInvite(
            cachedCode: "MOMSY-ABC234", cachedFamilyId: "A", currentFamilyId: "A",
            expiry: future, now: now
        ))
        #expect(!FirestoreInviteService.canReuseCachedInvite(
            cachedCode: nil, cachedFamilyId: "A", currentFamilyId: "A",
            expiry: future, now: now
        ))
    }
```

- [ ] **Step 2: Запустить тест — убедиться, что падает**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/FamilySwitchPolicyTests`

Expected: FAIL — `extra argument 'cachedCode' in call`.

- [ ] **Step 3: Реализовать — генератор**

`FirestoreInviteService.swift`, строки 167-171. Удалить целиком:

```swift
    private func generateCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        let suffix = (0..<6).map { _ in chars[Int.random(in: chars.indices)] }
        return "MOMSY-" + String(suffix)
    }
```

Строка 60, заменить вызов:

```diff
-        let code = generateCode()
+        let code = InviteCodeFormat.generate()
```

- [ ] **Step 4: Реализовать — предикат кэша**

`FirestoreInviteService.swift`, строки 155-166. Заменить:

```diff
     static func canReuseCachedInvite(
+        cachedCode: String?,
         cachedFamilyId: String?,
         currentFamilyId: String?,
         expiry: Date?,
         now: Date = Date()
     ) -> Bool {
+        // Код, выданный старой сборкой, короче и новые rules откажут ему в `get`.
+        // Отбрасываем его здесь, чтобы `regenerate()` выпустил сильный код.
+        guard let cachedCode, InviteCodeFormat.isValid(cachedCode) else { return false }
         guard let currentFamilyId, cachedFamilyId == currentFamilyId, let expiry else {
             return false
         }
         return expiry > now
     }
```

- [ ] **Step 5: Реализовать — три call-site**

`currentCode()`, строки 20-35:

```diff
     func currentCode() -> String {
         let familyId = defaults.string(forKey: kFamilyIdDefaultsKey)
         let cachedFamilyId = defaults.string(forKey: familyKey)
         if let familyId,
            let code = defaults.string(forKey: codeKey),
            let expiry = defaults.object(forKey: expiryKey) as? Date,
            Self.canReuseCachedInvite(
+               cachedCode: code,
                cachedFamilyId: cachedFamilyId,
                currentFamilyId: familyId,
                expiry: expiry
            ) {
```

`expiry()`, строки 39-47:

```diff
     func expiry() -> Date {
         guard let expiry = defaults.object(forKey: expiryKey) as? Date,
               Self.canReuseCachedInvite(
+            cachedCode: defaults.string(forKey: codeKey),
             cachedFamilyId: defaults.string(forKey: familyKey),
             currentFamilyId: defaults.string(forKey: kFamilyIdDefaultsKey),
             expiry: expiry
         ) else { return Date() }
```

`updateInviteRole(code:role:)`, строки 112-121:

```diff
         guard
             defaults.string(forKey: codeKey) == code,
             Self.canReuseCachedInvite(
+                cachedCode: code,
                 cachedFamilyId: defaults.string(forKey: familyKey),
                 currentFamilyId: familyId,
                 expiry: expiry
             ),
```

- [ ] **Step 6: Запустить тесты — убедиться, что проходят**

Run: `xcodebuild test -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MomsyTests/FamilySwitchPolicyTests -only-testing:MomsyTests/InviteCodeFormat`

Expected: PASS.

- [ ] **Step 7: Коммит**

```bash
git add Momsy/Features/Sharing/Data/Services/FirestoreInviteService.swift \
        MomsyTests/Features/Sharing/FamilySwitchPolicyTests.swift
git commit -m "feat(security): generate 12-char invite codes and drop legacy cached codes"
```

---

### Task 3: Валидация на клиенте до сетевого запроса

**Files:**
- Modify: `Momsy/Core/Family/FamilyManager.swift:251-255`
- Modify: `Momsy/Features/Onboarding/Presentation/Views/OBStepJoinFamily.swift:37`

`joinFamily` сейчас шлёт в Firestore любую строку, прошедшую `JoinDeeplink.normalize`. Каждый такой `get` вызывает `familyExists()` внутри rules — биллируемое чтение. Отсечка по формату до запроса убирает эту нагрузку и даёт пользователю мгновенную ошибку вместо round-trip.

- [ ] **Step 1: Реализовать проверку формата**

`FamilyManager.swift`, строки 251-255:

```diff
         // Accept either a bare code or a full `momsy://join?code=…` link a user may
         // have pasted; reject anything else so it can't become a `//` Firestore path.
-        guard let trimmed = JoinDeeplink.normalize(rawCode: code) else {
+        // Формат проверяется до сети: rules всё равно откажут коду вне канонического
+        // вида, а каждый отклонённый `get` стоит биллируемого чтения в `familyExists()`.
+        guard let trimmed = JoinDeeplink.normalize(rawCode: code),
+              InviteCodeFormat.isValid(trimmed) else {
             throw FamilyError.invalidOrExpiredCode
         }
```

- [ ] **Step 2: Обновить плейсхолдер поля ввода**

`OBStepJoinFamily.swift`, строка 37:

```diff
-                    TextField("MOMSY-XXXX", text: $inviteCode)
+                    TextField(InviteCodeFormat.placeholder, text: $inviteCode)
```

- [ ] **Step 3: Проверить, что новых ключей локализации не требуется**

Run: `grep -rn "MOMSY-XXXX" --include=*.swift Momsy/`

Expected: одна строка — определение `placeholder` в `InviteCodeFormat.swift`. Плейсхолдер — константа формата, не переводимый текст; ключи в `L10n.swift` не добавляются. Существующий `inviteCodeLabel` (`L10n.swift:1179`) уже покрывает все 7 языков и не меняется.

- [ ] **Step 4: Собрать**

Run: `xcodebuild build -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: BUILD SUCCEEDED.

- [ ] **Step 5: Коммит**

```bash
git add Momsy/Core/Family/FamilyManager.swift \
        Momsy/Features/Onboarding/Presentation/Views/OBStepJoinFamily.swift
git commit -m "feat(security): reject malformed invite codes before the Firestore read"
```

---

### Task 4: Ужесточение Firestore rules

**Files:**
- Modify: `firestore.rules:214-215` (новая функция), `:240-249` (get + create)
- Test: `tests/firebase-rules.test.mjs`

Порядок предикатов в `allow get` критичен: `isStrongInviteCode(code)` **обязан** стоять перед `familyExists(...)`, потому что `exists()` внутри rules биллируется как чтение даже при отказе. Так перебор становится бесплатным для владельца проекта.

`allow update` и `allow delete` намеренно не трогаем: `update` уже требует `canManageFamilyRoster` по обеим сторонам, а `delete` должен уметь подчистить legacy-документы из `DeleteAccountUseCase`.

- [ ] **Step 1: Написать падающие rules-тесты**

Добавить в `tests/firebase-rules.test.mjs` перед закрывающей строкой файла:

```javascript
test("a weak invite code cannot be minted", async () => {
    const momDb = firestore(users.mom);
    const expiresAt = Timestamp.fromMillis(Date.now() + 3_600_000);

    await assertFails(momDb.doc("invites/MOMSY-WEAK12").set({
        familyId,
        createdBy: users.mom,
        expiresAt,
    }));
    await assertFails(momDb.doc("invites/MOMSY-A2B3-C4D5").set({
        familyId,
        createdBy: users.mom,
        expiresAt,
    }));
    await assertFails(momDb.doc("invites/MOMSY-A2B3-C4D5-E6FI").set({
        familyId,
        createdBy: users.mom,
        expiresAt,
    }));
    await assertSucceeds(momDb.doc("invites/MOMSY-A2B3-C4D5-E6F7").set({
        familyId,
        createdBy: users.mom,
        expiresAt,
    }));
});

test("a weak invite code cannot be probed even when the document exists", async () => {
    const weakCode = "MOMSY-WEAK34";
    const strongCode = "MOMSY-H7J8-K9L2-M3N4";
    const expiresAt = Timestamp.fromMillis(Date.now() + 3_600_000);

    await testEnv.withSecurityRulesDisabled(async (adminContext) => {
        const db = adminContext.firestore();
        await db.doc(`invites/${weakCode}`).set({
            familyId,
            createdBy: users.mom,
            expiresAt,
        });
        await db.doc(`invites/${strongCode}`).set({
            familyId,
            createdBy: users.mom,
            expiresAt,
        });
    });

    // Перебор шестисимвольного пространства отсекается до `familyExists()`.
    await assertFails(firestore(users.outsider).doc(`invites/${weakCode}`).get());
    await assertSucceeds(firestore(users.outsider).doc(`invites/${strongCode}`).get());
});
```

- [ ] **Step 2: Мигрировать существующие коды в тестах**

В `tests/firebase-rules.test.mjs` заменить все 12 вхождений по таблице. Каждый новый код валиден по regex и уникален:

| Строка | Было | Стало |
|---|---|---|
| 19 | `MOMSY-BBB234` | `MOMSY-B2B3-B4B5-B6B7` |
| 196 | `MOMSY-EXTRA1` | `MOMSY-E2X3-T4R5-A6B7` |
| 202 | `MOMSY-LONG01` | `MOMSY-L2N3-G4H5-J6K7` |
| 207 | `MOMSY-OLD001` | `MOMSY-L2D3-M4N5-P6Q7` |
| 212 | `MOMSY-VALID1` | `MOMSY-V2L3-D4F5-G6H7` |
| 220 | `MOMSY-ERASE1` | `MOMSY-E2R3-S4T5-U6V7` |
| 236 | `"MOMSY-ERASE1"` (assert) | `"MOMSY-E2R3-S4T5-U6V7"` |
| 243 | `MOMSY-STALE1` | `MOMSY-S2T3-L4M5-N6P7` |
| 269 | `MOMSY-JOIN01` | `MOMSY-J2N3-K4L5-M6N7` |
| 301 | `MOMSY-JOIN01` | `MOMSY-J2N3-K4L5-M6N7` |
| 324 | `MOMSY-JOIN02` | `MOMSY-J2N3-K4L5-M6P8` |
| 335 | `MOMSY-JOIN02` | `MOMSY-J2N3-K4L5-M6P8` |

Быстрая проверка после правки:

```bash
grep -n "MOMSY-" tests/firebase-rules.test.mjs | grep -vE "MOMSY(-[A-HJ-NP-Z2-9]{4}){3}"
```

Expected: только строки из двух новых тестов, где слабый код отклоняется намеренно (`MOMSY-WEAK12`, `MOMSY-WEAK34`, `MOMSY-A2B3-C4D5`, `MOMSY-A2B3-C4D5-E6FI`).

- [ ] **Step 3: Запустить rules-тесты — убедиться, что падают**

Run: `npm run test:firebase-rules`

Expected: FAIL — `assertFails` на слабых кодах не срабатывает, потому что `isStrongInviteCode` ещё не существует и создание проходит.

- [ ] **Step 4: Реализовать правило**

`firestore.rules`, вставить между строкой 214 (`}` закрывающая `hasValidInviteData`) и строкой 215 (`function inviteImmutableFieldsUnchanged()`):

```
    // Инвайт-код обязан нести ≥60 бит энтропии: MOMSY-XXXX-XXXX-XXXX над
    // 32-символьным алфавитом без визуально неоднозначных знаков. Прежние
    // шестисимвольные коды давали 2^30 и перебирались, а join по угаданному коду
    // выдаёт роль родителя — полный доступ к данным ребёнка и к ростеру.
    function isStrongInviteCode(code) {
      return code.matches('^MOMSY(-[A-HJ-NP-Z2-9]{4}){3}$');
    }
```

`firestore.rules`, строки 240-249, заменить:

```diff
     match /invites/{code} {
       allow get:    if isSignedIn()
+                    // ПЕРВЫМ предикатом: `familyExists()` — биллируемое чтение
+                    // даже при отказе, и перебор не должен его оплачивать.
+                    && isStrongInviteCode(code)
                     && familyExists(resource.data.familyId)
                     && resource.data.expiresAt > request.time;
       allow list:   if isSignedIn()
                     && resource.data.createdBy == request.auth.uid;
       allow create: if isSignedIn()
+                    && isStrongInviteCode(code)
                     && hasValidInviteData()
                     && request.resource.data.createdBy == request.auth.uid
                     && canManageFamilyRoster(request.resource.data.familyId);
```

- [ ] **Step 5: Запустить rules-тесты — убедиться, что проходят**

Run: `npm run test:firebase-rules`

Expected: PASS, весь набор включая два новых теста.

- [ ] **Step 6: Коммит**

```bash
git add firestore.rules tests/firebase-rules.test.mjs
git commit -m "feat(security): require high-entropy invite codes in Firestore rules"
```

---

### Task 5: Деплой и очистка коллекции

**Files:** нет правок кода.

- [ ] **Step 1: Удалить все существующие инвайты**

Старые шестисимвольные документы после деплоя станут нечитаемыми на `get` — мусор, который продолжит указывать на живые семьи. Удалить до деплоя rules:

```bash
firebase firestore:delete invites --recursive --project <PROD_PROJECT_ID>
```

- [ ] **Step 2: Задеплоить rules**

```bash
firebase deploy --only firestore:rules --project <PROD_PROJECT_ID>
```

- [ ] **Step 3: Проверить App Check enforcement**

В Firebase Console → App Check → Firestore: убедиться, что стоит **Enforced**, а не Monitoring. `MomsyAppCheckProviderFactory` присутствует в коде (`AppAttestProvider` в release), но без включённого enforcement он не защищает — а именно он не даёт гонять перебор мимо приложения.

Expected: статус `Enforced` для Cloud Firestore.

---

## Definition of Done

- [ ] `InviteCodeFormat.generate()` выдаёт `MOMSY-XXXX-XXXX-XXXX`, 20 символов, 2⁶⁰ пространство.
- [ ] `grep -rn "0..<6" Momsy/Features/Sharing/` не находит старый генератор.
- [ ] `firestore.rules` содержит `isStrongInviteCode` и вызывает её **первой** в `allow get` и в `allow create`.
- [ ] Regex в `InviteCodeFormat.pattern` побайтово совпадает с regex в `firestore.rules`; расхождение ловится тестом `patternIsShared`.
- [ ] `npm run test:firebase-rules` — зелёный, включая два новых теста.
- [ ] `xcodebuild test -scheme Momsy` — зелёный; 7 новых тестов `InviteCodeFormat` + 2 теста `canReuseCachedInvite`.
- [ ] Устройство с закэшированным старым кодом при открытии экрана «Поделиться» автоматически выпускает новый код (без ручного сброса).
- [ ] Новых ключей в `L10n.swift` не добавлено; 7 локализаций не тронуты.
- [ ] Коллекция `invites` очищена, rules задеплоены, App Check в статусе Enforced.

---

## Manual QA

Два симулятора / устройства, оба с включённым Cloud Sync consent.

1. **Выпуск кода.** Устройство А (мама) → Sharing → карточка инвайта. Код имеет вид `MOMSY-XXXX-XXXX-XXXX`, QR и ссылка `momsy://join?code=…` содержат тот же код. Ожидаемо: код на экране и код в ссылке идентичны.
2. **Join по ссылке.** Устройство Б → открыть deeplink. Ожидаемо: вход в семью, в разделе «Семья» оба участника видят друг друга.
3. **Join ручным вводом.** Устройство Б (сброшенное) → онбординг → «Присоединиться» → ввести код вручную. Плейсхолдер показывает `MOMSY-XXXX-XXXX-XXXX`. Ожидаемо: успех.
4. **Отказ старому формату.** Ввести `MOMSY-ABC234`. Ожидаемо: мгновенная ошибка «код недействителен» **без** сетевого запроса — проверить в Xcode Network / Firestore usage, что чтения не было.
5. **Отказ мусору.** Ввести `MOMSY-A2B3-C4D5-E6FI` (буква I). Ожидаемо: та же мгновенная ошибка.
6. **Регенерация из старого кэша.** До обновления записать код старого формата, обновить сборку, открыть Sharing. Ожидаемо: код автоматически заменился на новый формат, старый документ удалён (`revokeInvite`).
7. **Смена роли инвайта.** На устройстве А выбрать роль «Няня» для инвайта, присоединиться с Б. Ожидаемо: Б получает роль няни, а не родителя.

---

## Follow-up (отдельные задачи, не входят в этот PR)

1. **TTL 24 ч → 2-6 ч.** `FirestoreInviteService.swift:61` (`addingTimeInterval(86400)`) и `firestore.rules:206` (`duration.value(24, 'h')`) должны меняться одной задачей — рассинхрон сломает `hasValidInviteData`.
2. **Одноразовость инвайта.** Удаление `invites/{code}` в той же batch, что и создание member-документа в `FamilyManager.joinFamily:~320-340`. Требует нового правила delete через `getAfter` на member-документе джойнера и решения по UX: один код на семью придётся заменить на код на приглашение.
3. **P1 #5 из ревью** — зависание sync-пайплайна на офлайн-удалении. Следующий блокер по влиянию на пользователя.
