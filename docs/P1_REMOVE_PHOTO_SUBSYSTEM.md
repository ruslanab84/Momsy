# P1 — Remove Photo Subsystem (Firebase Storage + all photo code)

**Verified against fresh clone, commit `2be5b6c`.**

## Context

Photos will not ship in v1. The photo subsystem currently creates a P1 GDPR gap:
`FirebasePhotoStorageService.deleteAll()` only clears the legacy `users/{uid}/diary`
path, while `families/{familyId}/photos` is never erased — and after
`FirestoreAccountEraser` deletes `members/{uid}`, storage.rules make those photos
permanently orphaned. Instead of fixing erasure, remove the entire subsystem:
all photo code, the `PhotoStorageService` layer, the FirebaseStorage SPM product,
and lock Storage down at the rules level.

No production users exist (pre-App Store). Dev devices with legacy `.photo` diary
rows will surface them as `.note` via the existing `?? .note` fallback in
`DiaryItemRecord.toDomain()` — acceptable, no migration needed. Removing optional
stored properties from `@Model` classes is a SwiftData lightweight migration.

Execution order: steps are independent of the pending P1_REMOVED_MEMBER_RECOVERY
work — no file overlap except `AppContainer.swift` (different regions). Safe to run first.

---

## Step 1 — Delete files

```bash
git rm Momsy/Features/Diary/Data/Services/PhotoStorageService.swift
git rm Momsy/Features/Diary/Data/Services/FirebasePhotoStorageService.swift
```

`LocalPhotoStorageService` and the `saveWithProgress` / `PhotoUploadEvent` extension
live inside `PhotoStorageService.swift` and have no consumers outside the files
above and the call sites removed below — verified, no other references.

## Step 2 — AppContainer.swift (`Momsy/Core/DI/AppContainer.swift`)

**2a. Remove property (lines 39–41):**

```swift
    let photoStorage: any PhotoStorageService = FirebaseBootstrapper.isConfigured
        ? FirebasePhotoStorageService()
        : LocalPhotoStorageService()
```

**2b. `makeFoodDiaryViewModel()` (lines 540–548) — remove `photoStorage:` argument:**

```swift
    func makeFoodDiaryViewModel() -> FoodDiaryViewModel {
        FoodDiaryViewModel(
            add: addFoodEntry,
            get: getFoodEntries,
            delete: deleteFoodEntry,
            syncRepo: babySyncRepository
        )
    }
```

**2c. `makeDeleteAccountUseCase()` (line ~562) — remove `photoStorage: photoStorage,` line.**

## Step 3 — DeleteAccountUseCase.swift (`Momsy/Core/Account/DeleteAccountUseCase.swift`)

Remove the `photoStorage` dependency entirely:

- Delete stored property `private let photoStorage: any PhotoStorageService`
- Delete `photoStorage:` init parameter and assignment
- Delete the call inside `execute()`:

```swift
                try await photoStorage.deleteAll()
```

Nothing else in the flow changes — `deleteCloudData` → `isCloudDataPresent`
verification chain stays identical. `AccountDeletionRecovery` never referenced
photos; no change there.

## Step 4 — ComplementaryFeeding (FoodDiary)

**4a. `Momsy/Features/ComplementaryFeeding/Presentation/ViewModel/FoodDiaryViewModel.swift`**

Remove:
- `@Published private(set) var photosByID: [UUID: UIImage] = [:]` (line 7)
- `@Published var pendingPhoto: UIImage? = nil` (line 18)
- `private let photoStorage: any PhotoStorageService` (line 23) + init param/assignment (lines 29, 34)
- In `load()` (line 51): `await loadPhotos()`
- In `saveEntry()` (lines 59–62): the `photoPath` local and the `pendingPhoto` upload block; drop `photoPath:` from `add.execute(...)`
- In `deleteEntry()` (lines 78–80, 84): the `photoStorage.delete` block and `photosByID.removeValue(forKey: entry.id)`
- In `pushFoodEntryToFirestore()` (line ~98): `photoPath: entry.photoPath,`
- Entire `private func loadPhotos()` (lines 104–111)
- In `resetForm()`: `pendingPhoto = nil` if present

Keep `isUploading` — it still gates the save button against double-taps.

**4b. `Momsy/Features/ComplementaryFeeding/Presentation/Views/FoodDiaryView.swift`**

- Line 111: `FoodEntryRow(entry: entry, photo: vm.photosByID[entry.id], lm: lm)` →
  `FoodEntryRow(entry: entry, lm: lm)`
- `FoodEntryRow` (line 128): remove `let photo: UIImage?` (line 130) and the
  `if let img = photo { ... }` branch (line 137) — leave only the category-icon branch
- `AddFoodEntrySheet`: remove `@State private var photoItem` (250),
  `@State private var isLoadingPhoto` (251), the entire "Photo picker" `VStack`
  (fieldLabel + `PhotosPicker` block, lines ~342–392 incl. `.onChange(of: photoItem)`)
- Remove `import PhotosUI` if it becomes unused

**4c. `Momsy/Features/ComplementaryFeeding/Domain/UseCases/AddFoodEntryUseCase.swift`**

Remove `photoPath: String?` from `execute` signature (line 8) and from the entry
construction (line 13).

**4d. `Momsy/Features/ComplementaryFeeding/Domain/Models/ComplementaryFoodModels.swift`**

Remove `var photoPath: String?` (line 11) from `ComplementaryFoodEntry`.

**4e. `Momsy/Features/ComplementaryFeeding/Data/Persistence/ComplementaryFoodRecord.swift`**

Remove `var photoPath: String?` (line 14), the init param (line 19),
assignment (line 28), `apply` assignment (line 39), and `photoPath:` in
`toDomain` (line 48).

**4f. `Momsy/Features/ComplementaryFeeding/Data/Repositories/SwiftDataComplementaryFeedingRepository.swift`**

Remove `photoPath: entry.photoPath,` at lines 31 and 56.

## Step 5 — Sync models

**5a. `Momsy/Core/BabySync/Domain/Models/FoodDiaryLog.swift`** — remove
`let photoPath: String?` (line 11).

**5b. `Momsy/Services/Firebase/BabySync/Models/FoodDiaryLog+DTO.swift`** — remove
`let photoPath: String?` (line 11), init assignment (line 23), `photoPath:` in
`domain` (line 37). Firestore `Codable` ignores the leftover field in existing
documents; no data migration required.

**5c. `Momsy/Services/Firebase/BabySync/CloudSyncDownloader.swift`** — line 542:
remove `photoPath: log.photoPath,` from the FoodDiary merge mapping.

## Step 6 — Diary models

**6a. `Momsy/Features/Diary/Domain/Models/StoredDiaryModels.swift`**

- `StoredDiaryItemKind` (line 4): `case photo, note, milestone` → `case note, milestone`
- Remove `var photoPath: String?` (line 15), init param (line 21), assignment (line 29)

**6b. `Momsy/Features/Diary/Data/Persistence/DiaryItemRecord.swift`**

- Remove `var photoPath: String?` (line 14)
- Remove `photoPath = item.photoPath` in `apply` (line 30)
- Update `merge` doc comment (line 35): drop the `photoPath` mention
- Remove `photoPath: photoPath,` in `toDomain` (line 50). The existing
  `StoredDiaryItemKind(rawValue: kindRaw) ?? .note` fallback (line 47) absorbs
  legacy `"photo"` rows — leave as is.

**6c. `Momsy/Features/Diary/Presentation/ViewModel/DiaryViewModel.swift`**

- Line 61: remove `.filter { $0.kind != .photo }`
- Lines 117–119: remove the `case .photo:` branch from `toDiaryItem`

## Step 7 — Localization

`Momsy/Core/Localization/L10n.swift` line 161: remove the `photo` accessor —
its only consumer was FoodDiaryView:344 (verified). `optional` is used elsewhere
(7 call sites) — keep.

## Step 8 — Remove FirebaseStorage SPM product

In `Momsy.xcodeproj/project.pbxproj`, remove all four references to product IDs
`B7318F532FBCEA96003CCB0B` and `B7318F522FBCEA96003CCB0B` (lines 75, 324, 864,
1495–1499): the `PBXBuildFile`, the Frameworks build-phase entry, the
`packageProductDependencies` entry, and the `XCSwiftPackageProductDependency`
block. Prefer doing this via Xcode (target → Frameworks → remove
FirebaseStorage) to keep the pbxproj consistent. The `firebase-ios-sdk` package
itself stays — other products are in use.

Verify no `import FirebaseStorage` remains:

```bash
grep -rn "FirebaseStorage\|Storage.storage()" Momsy/ MomsyWatch/ MomsyWidget/ && echo "FAIL" || echo "OK"
```

## Step 9 — Lock down Storage rules

Replace `storage.rules` content entirely (keep the file — `firebase.json` lines
5–7 reference it and deploys would fail otherwise):

```
rules_version = '2';

// Photos removed from the product. Storage is not used; deny everything.
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

Deploy: `firebase deploy --only storage`. Optionally delete any dev-uploaded
objects under `families/*/photos` and `users/*/diary` from the console afterward.

## Step 10 — Tests

**10a. `MomsyTests/Features/Account/DeleteAccountTests.swift`**

- Delete `MockPhotoStorage` (line 44) and its usages (lines 84, 93, 101):
  remove it from the fixture tuple and from `DeleteAccountUseCase` construction.
- Delete any assertion that verified `photo.deleteAllCalled` (if present) —
  the erasure contract no longer includes photos.

**10b. `MomsyTests/Features/WeeklyInsights/WeeklyInsightContextBuilderTests.swift`**

Remove `photoPath: nil` arguments (lines 54, 56, 58 + any others; 7 occurrences total).

**10c. `MomsyTests/Features/Diary/DiaryViewModelTests.swift`**

Line 102 constructs a `.photo` item. Rewrite the test to assert the legacy
fallback instead: a `DiaryItemRecord` persisted with `kindRaw == "photo"`
round-trips through `toDomain()` as `.note` (Swift Testing, not XCTest):

```swift
@Test func legacyPhotoKindFallsBackToNote() {
    let record = DiaryItemRecord(StoredDiaryItem(
        id: UUID(), date: Date(), kind: .note, text: "pic"
    ))
    record.kindRaw = "photo"
    #expect(record.toDomain().kind == .note)
}
```

---

## Definition of Done

- [ ] `PhotoStorageService.swift` and `FirebasePhotoStorageService.swift` deleted
- [ ] Zero matches: `grep -rn "PhotoStorage\|photoStorage\|photoPath\|pendingPhoto\|photosByID\|PhotosPicker" Momsy/ MomsyWatch/ MomsyWidget/`
- [ ] Zero matches: `grep -rn "FirebaseStorage\|Storage.storage()" Momsy/ Momsy.xcodeproj/project.pbxproj`
- [ ] `DeleteAccountUseCase` builds without a photo dependency; recovery path unchanged
- [ ] `storage.rules` = deny-all; `firebase deploy --only storage` succeeds
- [ ] L10n `photo` accessor removed; all 7 languages still compile (single-file change)
- [ ] All targets build (app, watch, widget, watch widget)
- [ ] `swift test` / Xcode test plan green, including the new legacy-kind fallback test
- [ ] App launches on a device that previously had food entries with photos — entries render with category icons, no crash (SwiftData lightweight migration)

## Manual QA

1. **Food diary:** add an entry (name + category only) → saved, appears in list with category icon; no photo UI anywhere in the add sheet.
2. **Delete entry:** swipe-delete a food entry → removed locally, tombstone propagates (`propagateDelete` still fires), second device drops it on next sync.
3. **Co-parent sync:** device A adds a food entry → device B pulls it on foreground resync; entry decodes despite old docs in Firestore still carrying `photoPath`.
4. **Diary:** feed with pre-existing legacy `.photo` rows (dev device) → rows appear as notes, no crash, no empty photo cells.
5. **Account deletion:** run full delete → completes, `users/{uid}` gone server-side, no Storage errors in console logs, pending marker cleared.
6. **Storage lockdown:** after rules deploy, attempt any Storage read from a signed-in dev build (temporary snippet or console simulator) → permission denied.
