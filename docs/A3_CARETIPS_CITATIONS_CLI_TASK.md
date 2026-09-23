# A3 — CareTips: sources on every tip (38 tips)

Severity: **P0** · Phase A · Depends on: A2
Baseline `eccd869` — re-anchor at HEAD.

## Goal
Every CareTip shows its source(s) (WHO first; NHS/AAP only where WHO has nothing) at the bottom of the detail screen and a source badge in the
list. A tip without a publishable source is NOT shown in Release builds.

## Step 0 — Anchor
```bash
grep -c "let whenToCallDoctor: LocalizedList" Momsy/Features/CareTips/Domain/Models/CareTipModels.swift   # expect: 1
for f in Momsy/Features/CareTips/Data/Catalog/CareTipsCatalog+*.swift; do grep -cE "id: [0-9]+," "$f"; done | paste -sd+ | bc   # expect: 38
grep -c "redFlagBlock$" Momsy/Features/CareTips/Presentation/Views/CareTipDetailView.swift   # expect: 1 (in body, ~L22)
```

## Changes
### 1. Model — `CareTipModels.swift`
- ADD `let sources: [MedicalSourceID]` to `CareTip`; ADD init parameter `sources: [MedicalSourceID]`
  as the LAST parameter with NO default (compiler forces every catalog entry to declare it).
- ADD `var isPublishable: Bool { CitationPolicy.isPublishable(sources) }`.

### 2. Catalog — 7 files `CareTipsCatalog+*.swift`
Add `sources:` to each of the 38 entries. Candidate mapping below is a STARTING POINT ONLY.
For every tip the CLI must open the WHO document (A2 catalog URL) and confirm it supports the
tip's core claim. If WHO does not support it → try the fallback (NHS, then AAP). Order `sources` by
`publisher.priority`. If nothing supports it → `sources: []` (tip hidden in Release) and report it.
Where NHS/AAP advice is country-specific (e.g. emergency number 999/911), keep the app copy
generic ("your local emergency number").
Do NOT change medical copy in this task except to delete a sentence that contradicts its cited WHO source (report every such deletion).

| id | Title (EN) | Candidate sources |
|---|---|---|
| 1001 | Hold your baby upright after every feed | nhsRefluxInBabies (fallback) |
| 1002 | Three burping positions | nhsWindingBaby (fallback) |
| 1003 | Catch hunger cues | whoInfantYoungChildFeeding, whoPostnatalCare2022 |
| 1004 | Paced bottle feeding | nhsBottleFeeding (fallback) |
| 1005 | Preparing and storing formula safely | whoPowderedFormulaPreparation |
| 1006 | Spit-up or vomiting | whoPocketBookHospitalCareChildren |
| 1007 | Starting solids | whoComplementaryFeeding2023, whoInfantYoungChildFeeding |
| 1008 | Evening cluster feeding | whoInfantYoungChildFeeding |
| 1101 | ABC of safe sleep | nhsSIDS, aapSafeSleep (fallback) |
| 1102 | Firm, flat, empty sleep surface | aapSafeSleep, nhsSIDS (fallback) |
| 1103 | Share a room, not a bed | nhsSIDS, aapSafeSleep (fallback) |
| 1104 | Room temperature and dressing for sleep | nhsSIDS (fallback) |
| 1105 | Swaddling | aapSwaddling (fallback) |
| 1106 | Wake windows | whoPhysicalActivitySleepUnder5 |
| 1107 | Twenty-minute bedtime routine | whoPhysicalActivitySleepUnder5, nhsHelpingBabySleep |
| 1201 | Umbilical cord care | whoPostnatalCare2022 |
| 1202 | Bathing a newborn | whoPostnatalCare2022 |
| 1203 | Preventing nappy rash | nhsNappyRash (fallback) |
| 1204 | Trimming nails | nhsWashingBathingBaby (fallback) |
| 1205 | Nose and ear care | nhsWashingBathingBaby (fallback) |
| 1301 | Soothing a colicky evening | nhsColic (fallback) |
| 1302 | Releasing trapped wind | nhsWindingBaby, nhsColic (fallback) |
| 1303 | Measuring a fever and thresholds | whoPocketBookHospitalCareChildren, nhsFeverInChildren |
| 1304 | Teething relief | nhsTeething (fallback) |
| 1305 | Cradle cap | nhsCradleCap (fallback) |
| 1401 | Tummy time | whoPhysicalActivitySleepUnder5 |
| 1402 | Keeping head shape round | nhsFlatHeadSyndrome (fallback) |
| 1403 | Serve and return | whoEarlyChildhoodDevelopment2020 |
| 1404 | Skin-to-skin | whoPostnatalCare2022, whoPretermLBWCare2022 |
| 1405 | Read aloud daily | whoEarlyChildhoodDevelopment2020 |
| 1501 | Car seat basics | whoRoadTrafficInjuriesFactSheet, whoWorldReportChildInjury2008 |
| 1502 | Changing table | whoWorldReportChildInjury2008 |
| 1503 | Baby-proof before your baby moves | whoWorldReportChildInjury2008 |
| 1504 | Water safety | whoDrowningFactSheet |
| 1505 | Be ready for an emergency | nhsBabyFirstAid (fallback) |
| 1601 | Split the night into shifts | nhsParentTiredness (fallback) |
| 1602 | Baby blues or something more | whoMaternalMentalHealth |
| 1603 | Never shake a baby | whoChildMaltreatmentFactSheet |

### 3. Visibility — `CareTipsCatalog.swift`
```swift
static let all: [CareTip] = {
    let everything = feeding + sleep + hygiene + comfort + development + safety + parent
    #if DEBUG
    return everything            // reviewers of the content still see unsourced tips
    #else
    return everything.filter(\.isPublishable)
    #endif
}()
```
Check every consumer of `CareTipsCatalog.all / tips(in:) / tip(id:)` (grep) — including Today daily
tip or deep links — still handles a missing tip (nil) gracefully.

### 4. `CareTipDetailView.swift`
- In `body` after `redFlagBlock` and before `disclaimer`: `MedicalSourcesSection(ids: tip.sources)`.
- DEBUG only: if `!tip.isPublishable` show a red "UNSOURCED — hidden in Release" capsule under the header.
- Toolbar: `SourcesInfoButton(ids: tip.sources)` (easy-to-find requirement).

### 5. `CareTipsView.swift` list row
Add a small caption with the primary publisher ("WHO" / "NHS" / "AAP") next to the age label.

## Tests
- Release filter: build a catalog with one sourced + one unsourced tip → filtered list == 1.
- Every tip in `CareTipsCatalog.all` (Release config test via `CitationPolicy`) has `isPublishable`.
- Tip IDs stay unique.

## DoD
```bash
grep -rc "sources:" Momsy/Features/CareTips/Data/Catalog/ | awk -F: '{s+=$2} END {print s}'   # expect: 38
grep -c "MedicalSourcesSection" Momsy/Features/CareTips/Presentation/Views/CareTipDetailView.swift  # expect: ≥1
xcodebuild … -configuration Release build   # green
```

## Deliverable for owner review (PR description)
Table: id · title · claim summary (1 line) · source id · exact section/page of the WHO document
that supports it · decision (sourced / hidden). Owner approves before merge.

## Manual QA
1. Release build: Doctor → Care Tips shows only sourced tips; each detail ends with "Sources"
   and the ⓘ button opens the same list; links open WHO pages in Safari.
2. DEBUG build: unsourced tips visible with red capsule.
3. 7 languages: section title localized, source titles stay in original English.
