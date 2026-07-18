# P1 — Privacy: устранить рассинхрон после удаления фото-подсистемы

## Контекст

Фото-подсистема (`PhotoStorageService`, `PhotosPicker`, `photoPath`, Firebase Storage)
уже удалена из кода — подтверждено `git clone --depth 1` на `momsy_check`:

- `PhotoStorageService.swift` / `FirebasePhotoStorageService.swift` — отсутствуют
- `PhotosPicker`, `photoPath` — 0 совпадений в `Momsy/`
- `storage.rules` — уже deny-all (`allow read, write: if false`)
- `FirebaseStorage` — отсутствует в `project.pbxproj`

Но **4 файла всё ещё описывают фото как существующую фичу**, а один —
содержит ложное утверждение про CloudKit. Для App Store-релиза это должно
быть исправлено, иначе Privacy Nutrition Label и `PrivacyInfo.xcprivacy`
не будут соответствовать реальному поведению приложения.

## Root cause

1. `Momsy/PrivacyInfo.xcprivacy` — задекларирован
   `NSPrivacyCollectedDataTypePhotosOrVideos` (строки 96–108), которого
   больше не существует.
2. `PRIVACY.md` — таблица и текст всё ещё говорят, что фото дневника
   хранятся в Firebase Storage.
3. `docs/AppStore-Privacy-Checklist.md` — чек-лист для App Store Connect
   всё ещё содержит пункт "Photos or Videos", и **ложно утверждает**, что
   `AppPersistence.swift` использует `cloudKitDatabase: .private(...)`.
   Проверено: `Momsy/Core/Persistence/AppPersistence.swift` использует
   только `ModelConfiguration(schema: schema)` — без CloudKit вообще.
   Единственное упоминание CloudKit в коде — комментарий в
   `AuthManager.swift:96`, описывающий **прежнюю** архитектуру (сейчас sync
   идёт через Firestore, не CloudKit).
4. `Momsy/Core/Localization/L10n.swift` — строка `deleteAllDataConfirm` во
   всех 7 языках обещает удаление "diary photos", которых больше нет.
5. `FoodDiaryView.swift` — мёртвый `import PhotosUI` (не используется).

---

## Fix 1 — `Momsy/PrivacyInfo.xcprivacy`

Удалить блок `NSPrivacyCollectedDataTypePhotosOrVideos` (строки 96–108).

**До:**
```xml
		<!-- AI chat messages sent to Firebase AI (Gemini) for baby advice -->
		<dict>
			<key>NSPrivacyCollectedDataType</key>
			<string>NSPrivacyCollectedDataTypeOtherUserContent</string>
```
(этому блоку в файле предшествует блок Photos or Videos — см. строки 96–109)

**После:** блок `<!-- Diary photos ... -->` (строки 96–109 целиком, включая
закрывающий `</dict>` и пустую строку) удалить. Следующим collected-type
остаётся `OtherUserContent` (AI chat).

### Fix 1b (рекомендуется) — File Timestamp reason

`NSPrivacyAccessedAPICategoryFileTimestamp` (строки 29–38) был добавлен
ради фото-дневника. Проверка кода (`Momsy/`, `MomsyWidget/`, `MomsyWatch/`)
не нашла ни одного вызова `.creationDate`, `.modificationDate`,
`resourceValues`, `attributesOfItem` — реального использования required-
reason File Timestamp API в коде приложения сейчас нет
(`PDFReportService.swift` использует только `temporaryDirectory`, что не
триггерит эту категорию). Рекомендую удалить весь блок целиком, чтобы
манифест отражал фактическое поведение бинарника:

```xml
	<!-- File timestamps — diary photo storage in Documents, PDF temp files -->
	<dict>
		<key>NSPrivacyAccessedAPIType</key>
		<string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
		<key>NSPrivacyAccessedAPITypeReasons</key>
		<array>
			<!-- 3B52.1: metadata of files inside the app's own container -->
			<string>3B52.1</string>
		</array>
	</dict>
```
→ удалить. Если в будущем появится код, читающий атрибуты файлов
(например, экспорт с датами), вернуть блок с актуальным комментарием.

---

## Fix 2 — `PRIVACY.md`

**Таблица в разделе 1** — удалить строку:
```
| Diary photos | Photos you attach to diary entries | ✓ | Firebase Storage |
```

**Раздел 2**, было:
```
Your data — including baby health records and your EPDS / well-being entries —
is stored in **Firebase Firestore** (and diary photos in **Firebase Storage**)
under a private account...
```
стало:
```
Your data — including baby health records and your EPDS / well-being entries —
is stored in **Firebase Firestore** under a private account...
```

**Раздел 4**, было:
```
This permanently erases your account and every record — on this device and in the
cloud — including health and well-being data and diary photos.
```
стало:
```
This permanently erases your account and every record — on this device and in the
cloud — including health and well-being data.
```

---

## Fix 2b — публичная страница `ruslanab84/-momsy-site` (index.html)

Это отдельный репозиторий, который реально отдаётся по ссылке
`AppLegalLinks.privacyPolicyURL` = `https://ruslanab84.github.io/-momsy-site/`.
Проверено клоном — `index.html`, последний коммит 3 июля 2026, содержит ту
же стухшую формулировку, что и старый `PRIVACY.md`. Это важнее самого
`PRIVACY.md` в основном репо, т.к. именно эту страницу видят App Review и
пользователи.

**Строка 90** — удалить строку таблицы:
```html
<tr><td>Diary photos</td><td>Photos you attach to diary entries</td><td class="c">✓</td><td class="c">Firebase Storage</td></tr>
```

**Строка 109–110**, было:
```html
Your data — including baby health records and your EPDS / well-being entries — is stored in
<strong>Firebase Firestore</strong> (and diary photos in <strong>Firebase Storage</strong>)
under a private account...
```
стало:
```html
Your data — including baby health records and your EPDS / well-being entries — is stored in
<strong>Firebase Firestore</strong> under a private account...
```

**Строка 117**, было:
```html
<li><strong>Google AI (Gemini).</strong> To generate the daily tip, a short, non-identifying
  summary of your baby's age and care context is sent to Google's Gemini model. No diary photos,
  EPDS scores, or account identifiers are sent.</li>
```
стало:
```html
<li><strong>Google AI (Gemini).</strong> To generate the daily tip, a short, non-identifying
  summary of your baby's age and care context is sent to Google's Gemini model. No EPDS scores
  or account identifiers are sent.</li>
```

**Строка 138–139**, было:
```html
...This permanently erases your account and every record — on this device
and in the cloud — including health and well-being data and diary photos. The action cannot be
undone, and the app returns to its first-launch state.</li>
```
стало:
```html
...This permanently erases your account and every record — on this device
and in the cloud — including health and well-being data. The action cannot be
undone, and the app returns to its first-launch state.</li>
```

⚠️ Это отдельный репозиторий — правки в `Momsy` его не затронут. Нужен
отдельный commit/push в `ruslanab84/-momsy-site`.

---

## Fix 3 — `docs/AppStore-Privacy-Checklist.md`

Удалить весь раздел "Why this matters now" (ложное утверждение про
CloudKit) — sync у приложения только через Firestore, это уже покрыто
пунктом "Health & Fitness → Health" ниже, отдельного нового data flow нет.

Удалить пункт:
```
- [ ] **User Content → Photos or Videos** — diary photos (Linked = Yes, since
      stored in Firebase Storage under the account).
```

Раздел "Storage / sync note" — убрать упоминание CloudKit, оставить как
общее напоминание, что Health/Sensitive Info должны быть задекларированы
в App Store Connect.

---

## Fix 4 — `Momsy/Core/Localization/L10n.swift`, `deleteAllDataConfirm`

Убрать фразу про фото дневника во всех 7 языках (строки ~944–947):

| Locale | Убрать |
|---|---|
| EN | `and diary photos` |
| RU | `и фото из дневника` |
| DE | `sowie Tagebuchfotos` |
| ES | `y las fotos del diario` |
| FR | `et les photos du journal` |
| PT | `e fotos do diário` |
| ZH | `以及日记照片` |

```swift
var deleteAllDataConfirm: String {
    s("This permanently deletes your account and every record — on this device and in the cloud — including health and well-being data. This cannot be undone.",
      "Это навсегда удалит ваш аккаунт и все записи — на этом устройстве и в облаке — включая данные о здоровье и самочувствии. Это действие необратимо.",
      "Dies löscht dauerhaft dein Konto und alle Einträge – auf diesem Gerät und in der Cloud – einschließlich Gesundheits- und Wohlbefindensdaten. Dies kann nicht rückgängig gemacht werden.",
      "Esto elimina permanentemente tu cuenta y todos los registros — en este dispositivo y en la nube — incluidos los datos de salud y bienestar. Esto no se puede deshacer.",
      "Ceci supprime définitivement votre compte et tous les enregistrements — sur cet appareil et dans le cloud — y compris les données de santé et de bien-être. Cette action est irréversible.",
      "Isto elimina permanentemente a sua conta e todos os registos — neste dispositivo e na nuvem — incluindo dados de saúde e bem-estar. Esta ação não pode ser anulada.",
      "这将永久删除您的账户和所有记录——包括本设备和云端——其中包括健康和身心状态数据。此操作无法撤销。")
}
```

---

## Fix 5 (minor) — `FoodDiaryView.swift`

Удалить неиспользуемый `import PhotosUI` (строка 2) — 0 использований
`PhotosPicker`/`PHPicker` в файле.

---

## Definition of Done

- [ ] `PrivacyInfo.xcprivacy` не содержит `PhotosOrVideos`; File Timestamp
      блок удалён или обоснован реальным вызовом API
- [ ] `PRIVACY.md` не упоминает диary photos / Firebase Storage
- [ ] `ruslanab84/-momsy-site/index.html` обновлён и запушен отдельно,
      текст совпадает с новым `PRIVACY.md`
- [ ] `docs/AppStore-Privacy-Checklist.md` не содержит ложного CloudKit
      утверждения и пункта Photos or Videos
- [ ] `deleteAllDataConfirm` обновлён во всех 7 локалях, строки совпадают
      по смыслу с EN
- [ ] `import PhotosUI` удалён из `FoodDiaryView.swift`
- [ ] Проект собирается (`xcodebuild build`), unit-тесты локализации
      (если есть snapshot/count тесты на `L10n`) проходят

Юнит-тесты Swift Testing не требуются — правки не затрагивают логику, это
markdown/XML/строковые константы.

## Ручной чек-лист (App Store Connect, после мержа)

- [ ] App Privacy → сверить ответы с обновлённым
      `docs/AppStore-Privacy-Checklist.md` (Health, Sensitive Info, Name,
      Other User Content — без Photos or Videos)
- [ ] Privacy Policy URL (`https://ruslanab84.github.io/-momsy-site/`)
      открывается и текст на странице совпадает с новым `PRIVACY.md`
      (после пуша в `-momsy-site`)
- [ ] Настройки → Data & Privacy → Delete all data — текст подтверждения
      на экране совпадает с новым `deleteAllDataConfirm`
