# A2 — MedicalSource model, WHO catalog, reusable Sources section

Severity: **P0** · Phase A · Depends on: —
Baseline `eccd869` — re-anchor at HEAD.

## Goal
One whitelisted, verifiable registry of medical sources and one reusable UI block that every
medical surface uses. Publisher policy: **WHO first, for all countries.** Fallback ONLY when WHO has no document on the
topic: NHS (www.nhs.uk), then AAP (www.healthychildren.org). Peer-reviewed originals are allowed
for instruments/theories (EPDS licence citation, Leaps attribution).

## Step 0 — Anchor
```bash
grep -c "whoGrowthStandardsURL\|whoImmunizationScheduleURL\|epdsCitation" Momsy/Core/AppLegalLinks.swift  # expect: 3
grep -rn "AppLegalLinks\.\(who\|epds\)" Momsy --include="*.swift"  # expect: WHOMethodologySheet ~L18, VaccinationView ~L23, EPDSSheet ~L288
```

## Folder structure (new)
```
Momsy/Core/MedicalSources/
├── Domain/
│   ├── MedicalSource.swift          // model + MedicalSourceID + Publisher
│   └── CitationPolicy.swift         // allowed publishers, publishability rule
├── Data/
│   └── MedicalSourceCatalog.swift   // the ONLY place URLs live
└── Presentation/
    ├── MedicalSourcesSection.swift  // reusable list of tappable sources
    └── SourcesInfoButton.swift      // ⓘ toolbar button → sheet with MedicalSourcesSection
MomsyTests/Core/MedicalSources/MedicalSourceCatalogTests.swift   (4 pbxproj points)
scripts/verify_medical_sources.sh
```

## Domain
```swift
enum MedicalPublisher: String, Sendable, CaseIterable {
    case who, nhs, aap, peerReviewed
    var priority: Int { switch self { case .who: 0; case .nhs: 1; case .aap: 2; case .peerReviewed: 3 } }
    var allowedHost: String? { switch self { case .who: "www.who.int"; case .nhs: "www.nhs.uk"; case .aap: "www.healthychildren.org"; case .peerReviewed: nil } }
}

enum MedicalSourceID: String, Sendable, CaseIterable, Hashable {
    case whoGrowthStandards, whoImmunizationSchedule, epdsCox1987
    case whoInfantYoungChildFeeding, whoComplementaryFeeding2023, whoPowderedFormulaPreparation
    case whoPhysicalActivitySleepUnder5, whoPostnatalCare2022, whoPretermLBWCare2022
    case whoEarlyChildhoodDevelopment2020, whoMaternalMentalHealth
    case whoDrowningFactSheet, whoChildMaltreatmentFactSheet, whoRoadTrafficInjuriesFactSheet
    case whoPocketBookHospitalCareChildren, whoWorldReportChildInjury2008
}

struct MedicalSource: Identifiable, Hashable, Sendable {
    let id: MedicalSourceID
    let publisher: MedicalPublisher
    let title: String          // original title, NOT localized (bibliographic)
    let url: URL?              // nil only for peerReviewed print citations
    let citation: String?      // full bibliographic string when required (EPDS)
    let year: String
}

enum CitationPolicy {
    static let allowedPublishers: Set<MedicalPublisher> = [.who, .nhs, .aap, .peerReviewed]
    static func isPublishable(_ ids: [MedicalSourceID]) -> Bool   // non-empty AND all resolve AND all allowed
}
```

## Data — `MedicalSourceCatalog.swift`
`static let all: [MedicalSource]`, `static func source(_ id:) -> MedicalSource?`.
Migrate the 3 existing values from `AppLegalLinks` (keep `AppLegalLinks` properties as thin
forwards `MedicalSourceCatalog.source(.x)?.url` so no call site breaks in this task).

Candidate URLs — **every one must pass `scripts/verify_medical_sources.sh`**; if a URL fails or
redirects, open who.int search, find the canonical page for the SAME document, use the final
URL. If no canonical page exists, DELETE the case and report it. Never invent a URL.
| ID | Title (original) | Candidate URL |
|---|---|---|
| whoGrowthStandards | WHO Child Growth Standards | https://www.who.int/tools/child-growth-standards/standards |
| whoImmunizationSchedule | WHO recommendations for routine immunization | https://www.who.int/teams/immunization-vaccines-and-biologicals/policies/who-recommendations-for-routine-immunization |
| epdsCox1987 | Detection of postnatal depression (EPDS) | url nil, citation = existing `AppLegalLinks.epdsCitation` |
| whoInfantYoungChildFeeding | Infant and young child feeding (fact sheet) | https://www.who.int/news-room/fact-sheets/detail/infant-and-young-child-feeding |
| whoComplementaryFeeding2023 | WHO Guideline for complementary feeding of infants and young children 6–23 months (2023) | https://www.who.int/publications/i/item/9789240081864 |
| whoPowderedFormulaPreparation | Safe preparation, storage and handling of powdered infant formula (2007) | https://www.who.int/publications/i/item/9789241595414 |
| whoPhysicalActivitySleepUnder5 | Guidelines on physical activity, sedentary behaviour and sleep for children under 5 (2019) | https://www.who.int/publications/i/item/9789241550536 |
| whoPostnatalCare2022 | WHO recommendations on maternal and newborn care for a positive postnatal experience (2022) | https://www.who.int/publications/i/item/9789240045989 |
| whoPretermLBWCare2022 | WHO recommendations for care of the preterm or low-birth-weight infant (2022) | https://www.who.int/publications/i/item/9789240058262 |
| whoEarlyChildhoodDevelopment2020 | Improving early childhood development: WHO guideline (2020) | https://www.who.int/publications/i/item/97892400020986 |
| whoMaternalMentalHealth | Maternal mental health | https://www.who.int/teams/mental-health-and-substance-use/promotion-prevention/maternal-mental-health |
| whoDrowningFactSheet | Drowning (fact sheet) | https://www.who.int/news-room/fact-sheets/detail/drowning |
| whoChildMaltreatmentFactSheet | Child maltreatment (fact sheet) | https://www.who.int/news-room/fact-sheets/detail/child-maltreatment |
| whoRoadTrafficInjuriesFactSheet | Road traffic injuries (fact sheet) | https://www.who.int/news-room/fact-sheets/detail/road-traffic-injuries |
| whoPocketBookHospitalCareChildren | Pocket book of hospital care for children (2013) | https://www.who.int/publications/i/item/978-92-4-154837-3 |
| whoWorldReportChildInjury2008 | World report on child injury prevention (2008) | https://www.who.int/publications/i/item/9789241563574 |

### Fallback candidates (NHS / AAP) — used only where A3 finds no WHO source
Same verification rule. If a candidate 404s, search the publisher site for the page on the SAME
topic and use its final URL; never invent paths.
| ID | Title | Candidate URL |
|---|---|---|
| nhsSIDS | Sudden infant death syndrome (SIDS) — reduce the risk | https://www.nhs.uk/conditions/sudden-infant-death-syndrome-sids/ |
| aapSafeSleep | A parent's guide to safe sleep | https://www.healthychildren.org/English/ages-stages/baby/sleep/Pages/a-parents-guide-to-safe-sleep.aspx |
| aapSwaddling | Swaddling: is it safe? | https://www.healthychildren.org/English/ages-stages/baby/diapers-clothing/Pages/Swaddling-Is-it-Safe.aspx |
| nhsRefluxInBabies | Reflux in babies | https://www.nhs.uk/conditions/reflux-in-babies/ |
| nhsColic | Colic | https://www.nhs.uk/conditions/colic/ |
| nhsNappyRash | Nappy rash | https://www.nhs.uk/conditions/nappy-rash/ |
| nhsCradleCap | Cradle cap | https://www.nhs.uk/conditions/cradle-cap/ |
| nhsFeverInChildren | Fever in children | https://www.nhs.uk/conditions/fever-in-children/ |
| nhsFlatHeadSyndrome | Flat head syndrome (plagiocephaly and brachycephaly) | https://www.nhs.uk/conditions/plagiocephaly-brachycephaly/ |
| nhsWashingBathingBaby | Washing and bathing your baby | https://www.nhs.uk/baby/caring-for-a-newborn/washing-and-bathing-your-baby/ |
| nhsHelpingBabySleep | Helping your baby to sleep | https://www.nhs.uk/baby/caring-for-a-newborn/helping-your-baby-to-sleep/ |
| nhsTeething | Teething | find on nhs.uk (baby development → teething) |
| nhsBottleFeeding | Bottle feeding (incl. responsive/paced feeding) | find on nhs.uk (breastfeeding and bottle feeding) |
| nhsWindingBaby | How to wind (burp) your baby | find on nhs.uk |
| nhsBabyFirstAid | First aid / choking — baby | find on nhs.uk |
| nhsParentTiredness | Tiredness and sleep deprivation (parents) | find on nhs.uk |
Add each verified entry as a `MedicalSourceID` case; delete cases that cannot be verified.

## `scripts/verify_medical_sources.sh`
Extract every `URL(string: "…")` from `MedicalSourceCatalog.swift`; for each run
`curl -sSL -o /dev/null -w "%{http_code} %{url_effective}" --max-time 20 "$url"`; fail (exit 1)
unless code is 200 AND `url_effective` equals the literal (no redirect) AND host is one of
`www.who.int`, `www.nhs.uk`, `www.healthychildren.org` and matches the entry's publisher.

## Presentation
- `MedicalSourcesSection(ids: [MedicalSourceID])`: section label `lm.strings.medicalSourcesTitle`,
  one row per source: publisher badge ("WHO" / "NHS" / "AAP" / "Study"), title (2 lines), year, trailing
  `arrow.up.right.square`; row is `Link(destination:)` when url != nil, else static text showing
  `citation`. Accessibility: combined element, label "<title>, <publisher>, opens in Safari".
  Uses existing design tokens (`bbCard`, `bbInkSoft`, `bbCoralDeep`).
- `SourcesInfoButton(ids:)`: toolbar `info.circle` → `.sheet` with `NavigationStack { ScrollView { MedicalSourcesSection } }`.
- `#Preview` for both with static IDs.

## L10n (7 languages)
`medicalSourcesTitle` "Sources" · `medicalSourcesOpensInSafari` "Opens in Safari" ·
`medicalSourcesButtonA11y` "Show sources".

## Tests
- Every `MedicalSourceID` resolves in `MedicalSourceCatalog.all` (exactly once).
- Every url is https and its host equals `publisher.allowedHost`; every `peerReviewed` has non-empty `citation`.
- `CitationPolicy.isPublishable([])` == false; with a valid id == true.

## DoD
```bash
bash scripts/verify_medical_sources.sh                                            # exit 0
grep -c "URL(string:" Momsy/Core/MedicalSources/Data/MedicalSourceCatalog.swift   # expect: equals number of cases with url
grep -rnE "who.int|nhs.uk|healthychildren.org" Momsy --include="*.swift" | grep -v "MedicalSources/Data/MedicalSourceCatalog.swift" | wc -l  # expect: 0
xcodebuild … build test   # green
```

## Report (append to PR description)
Table: ID → final URL → HTTP code → kept/replaced/deleted.
