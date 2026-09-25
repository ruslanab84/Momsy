# VACCINATION_SCHEDULES_CLI_TASK.md — v3

**Anchor commit:** `4b661b76fa5bdc0160e7a5d1f392ef2cab93ec73` (main, "A9: App Store Server Notifications V2…")
**Executor:** Claude Code CLI
**Severity:** P2 feature + Guideline 1.4.1 compliance. Contains one **P0 trap** (T3.1) — read it before touching `BabyProfile`.

Before starting: `git log -1 --format=%H` must equal the anchor. If not, re-verify every line number with `grep -n` before editing.

---

## 0. Goal

The vaccination schedule becomes a **per-child setting, synced to co-parents via Firestore**. Selectable: WHO (existing) + US (AAP), CA, DE, FR, IT, ES, BR. Every schedule **must** carry a verified link to its official publisher page, shown in Settings and on the Vaccination screen. China is **deferred** (no key, no publisher, no data in this task).

## 1. Hard rules

1. **No medical data from model memory.** Every item is transcribed from the official page fetched during this task. If a page cannot be fetched/parsed, that schedule is not registered and the report says so.
2. **Every URL passes `scripts/verify_medical_sources.sh`** (HTTP 200, no redirect, publisher host, no soft 404).
3. **Source is mandatory at the type level**: `sourceID: MedicalSourceID` is non-optional; the selectable set is derived from registered definitions.
4. Done-marks never disappear when the schedule changes (T5).
5. Routine childhood vaccines 0–6 y only. Risk-based / optional / shared-decision → `isOptional: true`. National baseline only; no provincial/regional variants.
6. No hardcoded user-facing strings — `L10n.swift` `s(en, ru, de, es, fr, pt, zh)`. Source document titles stay untranslated (existing convention).
7. `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, Swift 5 mode — don't add `nonisolated` unless the compiler demands it.
8. New files under `Momsy/` need no pbxproj edits. **No new test files** — extend `MomsyTests/Features/Vaccination/VaccinationScheduleTests.swift` (already registered: pbxproj lines 119/309/892/1057).

## 2. Decisions

| ID | Decision |
|---|---|
| D1 | US source = **AAP** (existing `.aap` publisher, host `www.healthychildren.org`). CDC 2026 schedule is stayed by federal court and under appeal — not used. |
| D2 | Schedule is stored **on the child** (`BabyProfile.vaccinationScheduleKey`), synced through the existing `families/{familyId}/babies/{babyId}` parent doc. Only roles passing `canPerform(.manageBabyProfiles)` can change it; others see it read-only. |
| D3 | China deferred. `CN` region auto-detects to WHO. |
| D4 | `nil` on the child = "auto" (device region → clamped to registered schedules). Nothing is written until the user explicitly picks. |
| D5 | **No realtime listener.** Co-parent changes arrive via the existing full sync (launch / foreground). Do not add `addSnapshotListener` on the baby doc. |
| D6 | **Choosing a schedule is Premium.** Auto-detect applies to everyone. A stored choice keeps working after the subscription expires (data-kept policy) but can't be changed. The source link is always visible regardless of tier (compliance). |
| D7 | Done-marks from another schedule show a caption "From schedule: <name>". |

---

## T1 — MedicalSources: national publishers (P2)

**Files:** `Momsy/Core/MedicalSources/Domain/MedicalSource.swift` (6–37 `MedicalPublisher`, 39–55 `MedicalSourceID`), `Domain/CitationPolicy.swift` (line 4), `Data/MedicalSourceCatalog.swift`, `scripts/verify_medical_sources.sh` (`host_for`, 12–19).

1. New `MedicalPublisher` cases (badge = untranslated):

| case | badge | allowedHost | allowedPathPrefix |
|---|---|---|---|
| `phac` | `PHAC` | `www.canada.ca` | — |
| `stiko` | `STIKO` | `www.rki.de` | — |
| `frHealthMinistry` | `Ministère` | confirm live (`sante.gouv.fr` vs `www.sante.gouv.fr`) | — |
| `itHealthMinistry` | `Ministero` | `www.salute.gov.it` | — |
| `esHealthMinistry` | `SNS` | `www.sanidad.gob.es` | — |
| `brHealthMinistry` | `PNI` | `www.gov.br` | `/saude/` |

   `priority` = 1 for all national publishers. Add all to `CitationPolicy.allowedPublishers`.
2. Add `var allowedPathPrefix: String?` (`nil` except BR). Update doc comment line 3: *"National vaccination schedules cite their national authority; the WHO-first policy applies to every other topic."*
3. New `MedicalSourceID` cases: `aapImmunizationSchedule, phacImmunizationSchedule, stikoImpfkalender, frCalendrierVaccinal, itPNPV, esCalendarioComun, brCalendarioNacional`. Catalog entries with the **exact live-verified URL**, original title, edition year.
   Starting points (find the canonical page, don't trust blindly): AAP immunization schedule on healthychildren.org · Canadian Immunization Guide, routine infant/child schedule · RKI "Impfkalender" · "Calendrier des vaccinations et recommandations vaccinales" (current year) · PNPV current edition · "Calendario común de vacunación a lo largo de toda la vida" (current year) · "Calendário Nacional de Vacinação — criança".
4. `verify_medical_sources.sh`: extend `host_for`; add `prefix_for`; fail with `reason="path outside $prefix"` when the path doesn't start with it.

**DoD:**
```bash
grep -c "allowedPathPrefix" Momsy/Core/MedicalSources/Domain/MedicalSource.swift          # expect: >=2
grep -cE "phac\)|stiko\)|brHealthMinistry\)" scripts/verify_medical_sources.sh            # expect: 3
grep -rn "nhc\|cnNational\|cnNHC" Momsy scripts | wc -l                                   # expect: 0
bash scripts/verify_medical_sources.sh                                                    # expect: exit 0
```

---

## T2 — Domain: schedule definition + keys (P2)

**New:** `Momsy/Features/Vaccination/Domain/Models/VaccinationScheduleDefinition.swift`
```swift
import Foundation

/// A national/international schedule. `sourceID` is intentionally non-optional:
/// a schedule cannot exist in the app without an official citation.
struct VaccinationScheduleDefinition: Sendable {
    let key: VaccinationScheduleKey
    let sourceID: MedicalSourceID
    let idRange: ClosedRange<Int>      // catalogIds never collide across schedules
    let lastReviewed: String           // ISO date data was checked against sourceID
    let items: [VaccinationScheduleItem]
}
```

**`VaccinationScheduleProvider.swift` line 6** — keys (WHO range untouched: legacy RU→WHO migration depends on it):

| key / rawValue | range | publisher |
|---|---|---|
| `who` | 100–199 | WHO |
| `usAAP` | 200–299 | AAP |
| `caNational` | 300–399 | PHAC |
| `deSTIKO` | 400–499 | STIKO |
| `frNational` | 500–599 | FR ministry |
| `itNational` | 600–699 | IT ministry |
| `esNational` | 700–799 | SNS |
| `brNational` | 800–899 | PNI |

Replace `usCDC`; keep `ukNHS`, `ruNational` (unregistered). `900–999` stays reserved for CN — add a comment, no case.
`displayName` (lines 9–16) → `func displayName(_ s: <L10n strings type>) -> String` via new keys `vaccinationScheduleName_<rawValue>`, e.g. RU `"Германия (STIKO)"`.

**DoD:**
```bash
grep -c "let sourceID: MedicalSourceID$" Momsy/Features/Vaccination/Domain/Models/VaccinationScheduleDefinition.swift  # expect: 1
grep -rn "usCDC\|\"International (WHO)\"" Momsy MomsyTests | wc -l                                                  # expect: 0
```

---

## T3 — Per-child storage + Firestore sync

### T3.1 ⚠️ P0 trap — `BabyProfile` is JSON-decoded from UserDefaults

`LocalBabyRepository.swift` line 8 and `FamilyManager.swift` line 32 decode `BabyProfile` with synthesized `Codable`, falling back to `[]`/`nil` on failure. **A new non-optional field makes every existing payload fail to decode → all children silently lost.** The field **must be `String?`** (synthesized `Codable` uses `decodeIfPresent`). Do not write a custom `init(from:)`.

### T3.2 Model / persistence / DTO

| File | Change |
|---|---|
| `Features/Baby/Domain/Models/BabyProfile.swift` (10–24) | `var vaccinationScheduleKey: String?`; init param `vaccinationScheduleKey: String? = nil` (last, defaulted — existing call sites unchanged). |
| `Features/Baby/Data/Persistence/BabyRecord.swift` (4–22) | `var vaccinationScheduleKey: String? = nil`; map in `init(_:)` and `toDomain()`. Optional + default = lightweight SwiftData migration. **Do not** add a `VersionedSchema` for this — but QA #1 (upgrade) is mandatory because `AppPersistence.makeContainer` deletes the store on migration failure (line 37). |
| `Services/Firebase/BabySync/Models/BabyProfile+DTO.swift` (7–35) | `let vaccinationScheduleKey: String?`; map both directions. Field name `vaccinationScheduleKey`. |

Sync semantics (verified, no code change needed):
- Write: `BabySyncService.setBabyProfile` (line 617) uses `setData(from:, merge: true)`. Optional `nil` is **omitted** by the encoder → an older app version or an "auto" device never erases a co-parent's choice.
- Read: `CloudSyncDownloader.syncBabyProfile` (lines 328–350) adopts remote when `remote != local` → the choice propagates on next sync (launch / foreground full sync). `BabyProfile: Equatable` picks up the new field automatically.
- Firestore rules `babies/{babyId}` update (lines 586–588) has no key whitelist → no rules change. Verify: `sed -n '579,590p' firestore.rules | grep -c "hasOnly\|keys()"` → expect 0.

### T3.3 Resolver replaces the device-level provider state

Rewrite `VaccinationScheduleProvider.swift` (78 lines) as a stateless, `@Observable`-free resolver (it no longer owns state):

```swift
protocol VaccinationScheduleResolving {
    var availableKeys: [VaccinationScheduleKey] { get }
    func definition(for baby: BabyProfile?) -> VaccinationScheduleDefinition
    func item(forCatalogId id: Int) -> (item: VaccinationScheduleItem, key: VaccinationScheduleKey)?
}

struct VaccinationScheduleResolver: VaccinationScheduleResolving {
    static let definitions: [VaccinationScheduleKey: VaccinationScheduleDefinition] = [
        .who: WHOSchedule.definition,
        // + one line per schedule authored in T4
    ]
    let regionProvider: () -> String? = { Locale.current.region?.identifier }
    // definition(for:): stored key if registered → else autoDetect → else .who
}
```
- Remove `import Combine`, `ObservableObject`, `static let shared`, `setKey`, UserDefaults read/write.
- `autoDetect`: `US→usAAP, CA→caNational, DE→deSTIKO, FR→frNational, IT→itNational, ES→esNational, BR→brNational, GB→ukNHS, RU→ruNational`, else `.who`; clamp to registered.
- An unknown stored rawValue (e.g. written by a newer app version) → fall back to auto **for display only**; never overwrite it.
- One-time cleanup: remove UserDefaults key `vaccinationScheduleKey` — add to `UserDefaultsMigration.swift` next to the RU→WHO remap (line ~89). It only ever held `"who"`, so no value is carried over.
- `WHOSchedule.swift`: add `static let definition = VaccinationScheduleDefinition(key: .who, sourceID: .whoImmunizationSchedule, idRange: 100...199, lastReviewed: "<date>", items: items)`. Don't touch `items`.

**DI:**
- `GetVaccinationStatusUseCase` (line 4): add `let resolver: any VaccinationScheduleResolving`; signature → `execute(baby: BabyProfile?)`, birth date from `baby?.birthDate ?? Date()` (moves the fallback from `VaccinationViewModel.load` line 43).
- `AppContainer` line 329: `GetVaccinationStatusUseCase(repository: vaccinationRepository, resolver: VaccinationScheduleResolver())`. Add `lazy var vaccinationScheduleResolver` and reuse it in T6.

**DoD:**
```bash
grep -rn "VaccinationScheduleProvider" Momsy MomsyTests | wc -l                                          # expect: 0
grep -c "vaccinationScheduleKey: String?" Momsy/Features/Baby/Domain/Models/BabyProfile.swift            # expect: >=1
grep -c "vaccinationScheduleKey" Momsy/Services/Firebase/BabySync/Models/BabyProfile+DTO.swift           # expect: >=3
grep -c "vaccinationScheduleKey" Momsy/Features/Baby/Data/Persistence/BabyRecord.swift                   # expect: >=3
grep -rn "forKey: \"vaccinationScheduleKey\"\|storageKey = \"vaccinationScheduleKey\"" Momsy | grep -v UserDefaultsMigration | wc -l  # expect: 0
```

---

## T4 — Schedule data files (P2, one commit per country)

New in `Momsy/Features/Vaccination/Data/Schedules/`: `USAAPSchedule.swift, CanadaSchedule.swift, GermanySTIKOSchedule.swift, FranceSchedule.swift, ItalySchedule.swift, SpainSchedule.swift, BrazilSchedule.swift`. Mirror `WHOSchedule.swift` exactly (compact 7-language init, `// MARK:` per timing group, `static let items`, `static let definition`).

Authoring protocol per country:
1. Fetch the T1-verified URL; extract the 0–6 y routine table.
2. Timing in the source's own unit (`.weeks` / `.months` / `.atBirth`). No conversion.
3. Names: antigen + dose (`"MMR — dose 1"`), combination vaccines keep source naming. All 7 languages; WHO file is the style reference.
4. `isOptional: true` for risk-group / optional / shared-decision entries.
5. Header comment: source title, edition, `MedicalSourceID`, `lastReviewed`.
6. Register in `VaccinationScheduleResolver.definitions`. **Fetch failed → skip the country entirely.**

**DoD per file:** `grep -c "sourceID: \." <File>` → 1; `grep -c "lastReviewed:" <File>` → 1.

---

## T5 — Done-marks from another schedule stay visible (P1 if skipped)

`GetVaccinationStatusUseCase.swift` line 14 matches entries only against the active schedule → switching the child's schedule, or a co-parent's mark from before the switch, disappears from UI (data survives in SwiftData/Firestore).

After `catalogStatuses`:
```swift
let activeIds = Set(items.map(\.id))
let foreignStatuses: [VaccinationStatus] = entries
    .filter { !$0.isCustom && !activeIds.contains($0.catalogId) }
    .compactMap { entry in
        guard let resolved = resolver.item(forCatalogId: entry.catalogId) else { return nil }
        let item = VaccinationScheduleItem(id: resolved.item.id, names: resolved.item.names,
                                           timing: .additional, isOptional: false)
        return VaccinationStatus(item: item, entry: entry, dueDate: entry.doneDate,
                                 originKey: resolved.key)
    }
return catalogStatuses + foreignStatuses + customStatuses
```
Unresolvable ids fall through silently — never delete.

**Origin caption (D7):**
- `VaccinationModels.swift` `VaccinationStatus` (lines 124–132): add `var originKey: VaccinationScheduleKey? = nil` (defaulted → the two existing constructors in the use case, lines 15 and 29, compile unchanged). `nil` = active schedule or custom.
- `VaccinationView.swift` `VaccinationRowView` (92–158): under the date line (≈ line 131), when `let origin = status.originKey`, add
  `Text(lm.strings.vaccinationFromSchedule(origin.displayName(lm.strings)))` — 12 pt, `.bbInkMute`, same font style as the date line.
- L10n: `func vaccinationFromSchedule(_ name: String) -> String` in 7 languages, e.g. EN "From schedule: \(name)", RU "Из графика: \(name)".
- **Bug guard:** `VaccinationViewModel.undone` (lines 57–69) reschedules a reminder for every non-custom entry with `status.dueDate`. For a foreign status that's the past `doneDate` and an id outside the active schedule. Change the condition to `if !entry.isCustom && status.originKey == nil`.

---

## T6 — UI (P2)

### Settings — `SettingsView.swift` 256–282, `SettingsViewModel.swift` 34–43, 76

ViewModel (keep `ObservableObject`, follow the existing closure-injection style of `updateCloudSync`):
- Remove `vaccinationScheduleKey` `didSet` → provider path (34–40), `availableScheduleKeys` `let` (43), init line 76.
- Add init params: `activeBaby: @MainActor () -> BabyProfile?`, `updateBaby: @MainActor (BabyProfile) async throws -> Void`, `canEditBaby: @MainActor () -> Bool`, `scheduleResolver: any VaccinationScheduleResolving`.
- `@Published private(set) var scheduleKey: VaccinationScheduleKey`, `var scheduleSourceID: MedicalSourceID`, `var canEditSchedule: Bool`, `@Published var scheduleError: Error?`.
- Add init param `accessState: @MainActor () -> PremiumAccessState` (from `container.subscriptionManager.accessState` — family entitlement is already folded in). Expose `var scheduleAccess: PremiumAccessState`.
- `func selectSchedule(_ key:) async` → **guard `accessState() == .premium` else return** (defence in depth; UI already blocks) → copy active baby with new key → `try await updateBaby(...)`; on error roll `scheduleKey` back and set `scheduleError`. On success, cancel pending reminders of the old definition (P3 item below).
- `AppContainer.makeSettingsViewModel()` (716): `activeBaby: { self.appState.babyProfile }`, `updateBaby: { try await self.updateChildProfile($0) }` (lines 227–235 — already guards `.manageBabyProfiles`, saves locally, updates `appState`, pushes to Firestore), `canEditBaby: { FamilyManager.shared.canPerform(.manageBabyProfiles) }`.

View:
- Picker: `Binding(get: { vm.scheduleKey }, set: { k in Task { await vm.selectSchedule(k) } })`, labels `key.displayName(lm.strings)`.
- Gating by state (evaluate role first, then tier):

| condition | row renders |
|---|---|
| `!canEditSchedule` (non-parent role) | current schedule name, disabled, read-only hint |
| `.resolving` | current name, disabled, no paywall |
| `.requiresPurchase` | current name + existing premium badge/lock style (reuse whatever Paywall-gated rows already use — `grep -rn "lock.fill\|premiumBadge" Momsy/Features` first; do not invent a new component); tap → paywall sheet |
| `.premium` + parent | active `Picker(.menu)` |

- Paywall sheet: copy the `WeeklyInsightView` pattern (lines 45–60: `PaywallView(subscriptionManager:pendingInviteStore:joinFamily:onComplete:)`). `SettingsView` currently has no `subscriptionManager` — take it from `container` in `init`, hold as `@ObservedObject`.
- Hint (line 277) → new copy: child name + "Official national schedule. Regional programs may differ — confirm with your pediatrician."; when read-only add "Only parents can change this."; when `.requiresPurchase` add "Choosing a country schedule is part of Premium."
- Below: `MedicalSourcesSection(ids: [vm.scheduleSourceID])` — reuse, no new row component.
- Section lives under the active child's context: re-read on `appState.babyProfile` change (child switch in Settings).

### Vaccination screen — `VaccinationView.swift`

- Line 23: `MedicalSourcesSection(ids: [.whoImmunizationSchedule])` → `[vm.scheduleSourceID]`. Update the comment on lines 11–12 (it's WHO-specific).
- `VaccinationViewModel`: inject `resolver`; `@Published private(set) var scheduleSourceID: MedicalSourceID = .whoImmunizationSchedule`, set in `load()` from `resolver.definition(for: appState.babyProfile).sourceID`.
- Reload when the child or its schedule changes (co-parent sync or child switch): in `VaccinationView` add `.onReceive(appState.$babyProfile.removeDuplicates().dropFirst()) { _ in Task { await vm.load() } }` — pass `container.appState` through `init(container:)`.

### L10n (`L10n.swift`, near 1307–1317), all 7 languages
`vaccinationScheduleName_<rawValue>` ×8 registered keys, updated `vaccinationScheduleHint`, `vaccinationScheduleReadOnlyHint`, `vaccinationSchedulePremiumHint`, `vaccinationFromSchedule(_:)`, make `vaccinationSourceNote` (1308) schedule-neutral if it names WHO.

### Reminders (P3)
Pending reminder ids are `momsy.vaccination.<catalogId>` (`LocalPushNotificationService.swift` line 17). Add `cancelVaccinationReminders(catalogIds: [Int])` to `PushNotificationServiceProtocol`, `LocalPushNotificationService`, `MomsyTests/Mocks/MockPushNotificationService.swift`; call with the old definition's ids after a successful `selectSchedule`.

**DoD:**
```bash
grep -c "whoImmunizationSchedule" Momsy/Features/Vaccination/Presentation/Views/VaccinationView.swift   # expect: 0
grep -c "MedicalSourcesSection" Momsy/Features/Settings/Presentation/Views/SettingsView.swift           # expect: 1
grep -c "updateChildProfile" Momsy/Core/DI/AppContainer.swift                                          # expect: >=2
grep -c "PaywallView(" Momsy/Features/Settings/Presentation/Views/SettingsView.swift                    # expect: 1
grep -c "originKey == nil" Momsy/Features/Vaccination/Presentation/ViewModel/VaccinationViewModel.swift # expect: 1
grep -rn "addSnapshotListener" Momsy/Services/Firebase/BabySync/BabySyncService.swift | grep -c babyDoc # expect: 0
```

---

## T7 — Tests (extend existing file only)

Append to `VaccinationScheduleTests.swift` (Swift Testing). Replace the two `VaccinationScheduleProvider` tests (lines 78–95) with resolver equivalents.

1. Every registered definition: `CitationPolicy.isPublishable([def.sourceID])`, source URL non-nil, host == `publisher.allowedHost`, path has `allowedPathPrefix` when set.
2. Item ids ∈ `def.idRange`; globally unique; ranges don't overlap.
3. Every item has all 7 language names.
4. Resolver: `nil` key + region `DE` → STIKO (if registered) else WHO; region `CN` → WHO; unknown rawValue `"xxFuture"` → auto, no crash.
5. **P0 guard:** decode `[BabyProfile]` from a JSON literal **without** `vaccinationScheduleKey` → succeeds, field `nil`. Round-trip with the field set → preserved.
6. DTO: `BabyProfileDTO(from:)` with `nil` key → `domain.vaccinationScheduleKey == nil`; with `"deSTIKO"` → preserved.
7. T5: mock repo returns a WHO-id entry, baby on another registered schedule → status present, `timing == .additional`, `isDone`.
8. T5 caption: foreign status has `originKey == .who`; active and custom statuses have `originKey == nil`.
9. SettingsViewModel: `accessState` = `.requiresPurchase` → `selectSchedule(.deSTIKO)` does **not** call `updateBaby`; `.premium` + parent → calls it once with the new key; `updateBaby` throws → `scheduleKey` rolls back.
10. Existing WHO-namespace and RU→WHO migration tests stay green.

Mocks inside the test file: `MockVaccinationScheduleResolver`, in-memory `VaccinationRepository` — no real `UserDefaults`, no Firebase.

---

## 8. Manual QA

1. **Upgrade (mandatory, P0):** install build from anchor commit, create 2 children + vaccination marks → install new build over it → children, marks, family intact; schedule shows auto value.
2. Device region DE, fresh child → "Germany (STIKO)" + STIKO source row; tap opens rki.de.
3. Parent A (device 1) sets child #1 to FR → device 2 (parent B) after foreground sync shows FR for child #1; child #2 unaffected.
4. Non-parent role → picker disabled, read-only hint shown, source link still tappable.
5. WHO active, mark 3 doses → switch to DE → 3 doses under "Additional" as done with caption "From schedule: International (WHO)" → swipe-undo one → no reminder scheduled (check pending notifications) → back to WHO → original groups, no caption.
5a. Sandbox: user without subscription → schedule row shows lock, tap → paywall; source link still opens. Purchase → picker active without relaunch.
5b. Subscription expired with DE stored → still shows DE schedule, row locked.
6. Device 2 on an **old build** edits the child's name → device 1 still has FR (merge didn't erase the field).
7. Airplane mode, change schedule → error shown, picker rolls back (or local save succeeds and push retries — document which, per `updateChildProfile` behaviour: push is `try?`, so local succeeds and cloud catches up on next sync).
8. All 7 UI languages: names + hints localized, source titles original.
9. Region CN / JP → WHO.

## 9. Report back

Per country: registered ✅ / skipped ❌ (reason), verified URL, `lastReviewed`, item count. Full `verify_medical_sources.sh` output. Test summary. Result of QA #1.
