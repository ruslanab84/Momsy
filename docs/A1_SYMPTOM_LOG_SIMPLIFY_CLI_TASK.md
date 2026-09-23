# A1 — Symptom screen → plain symptom logging (no hints, no "likely" diagnosis)

Severity: **P0** (Guideline 1.4.1 rejection, submission 75218e5d-…a7ef) · Phase A · Depends on: —
Baseline `eccd869` — re-anchor at HEAD (build 45).

## Goal
Keep the ability to log symptoms to the diary. Remove every computed assessment, likely-cause
card, advice ("Try a cold teether") and "see doctor if" thresholds. The app records what the
parent observed; it never interprets it.

## Step 0 — Anchor
```bash
grep -c "var result: SymptomResult" Momsy/Features/Symptom/Presentation/ViewModel/SymptomViewModel.swift   # expect: 1
grep -c "private var resultCard" Momsy/Features/Symptom/Presentation/Views/SymptomView.swift                # expect: 1
grep -c "isOnIDs: Set<String> = \[\"fever\", \"cry\", \"sleep\"\]" Momsy/Features/Symptom/Presentation/ViewModel/SymptomViewModel.swift  # expect: 1
grep -rn "SymptomView(container" Momsy --include="*.swift"   # expect: TodayView (~L135), DoctorMenuView (~L13), SymptomView #Preview
```

## Changes

### 1. `SymptomViewModel.swift` (237 lines)
- DELETE `enum SymptomUrgency`, `struct SymptomResult` (+ `cardBg`, `warningColor`, `urgencyIcon`),
  `func urgencyLabel(for:)`, `var result: SymptomResult` (L100–~188), `static func severity(for:)`.
- Pre-selection is demo data — BEFORE:
  `@Published var isOnIDs: Set<String> = ["fever", "cry", "sleep"]`
  AFTER: `@Published var isOnIDs: Set<String> = []`
- Fake subtitles are demo data — BEFORE: `sub: "37.8°C · 40 \(lm.strings.unitMin)"`, `sub: "> 1 \(lm.strings.unitHr)"`.
  AFTER: `sub: ""` for every symptom (card hides empty subtitle, see §2).
- ADD `@Published var severity: SymptomSeverity = .mild` (parent's own rating, user-selected) and
  `@Published var note: String = ""` (max 500 chars, trimmed).
- ADD `var canSave: Bool { !isOnIDs.isEmpty || !note.trimmed.isEmpty }`.
- `logToDiary()` — BEFORE builds text from `currentResult.title`. AFTER:
  ```swift
  func logToDiary() {
      guard canSave else { return }
      let labels = symptoms.filter(\.isOn).map(\.label).joined(separator: ", ")
      let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
      let description = [labels, trimmedNote].filter { !$0.isEmpty }.joined(separator: " — ")
      let item = StoredDiaryItem(kind: .note, text: "🩺 \(description)")
      let symptomLog = SymptomLog(id: UUID().uuidString, loggedAt: Date(),
                                  description: description, severity: severity,
                                  addedBy: "", addedByName: "")
      // keep the existing diaryLogged animation + Task { addDiaryEntry; syncRepo.addSymptomLog }
      // after success: reset isOnIDs = [], note = "", severity = .mild
  }
  ```
- `reset()` also clears `note` and `severity`.

### 2. `SymptomView.swift` (231 lines)
- `body`: remove `resultCard` and its `.animation(...)`. New order:
  `header, symptomGrid, severityPicker, noteField, actionButtons, disclaimer`.
- DELETE `private var resultCard` (L96–145) and `private var disclaimerCard` (L62–81).
- `header`: title → `loc.strings.symptomLogTitle`, subtitle → `loc.strings.symptomLogSubtitle`.
- ADD `severityPicker`: segmented `Picker` over `SymptomSeverity` with labels
  `symptomSeverityMild / Moderate / High`, section label `symptomSeverityQuestion`.
- ADD `noteField`: `TextField(axis: .vertical)`, `lineLimit(3...6)`, placeholder `symptomNotePlaceholder`.
- `actionButtons`: `.disabled(!vm.canSave)`.
- `SymptomCard`: render `sub` only when non-empty.
- `disclaimer` → `loc.strings.symptomLogFooter`.
- Keep `@StateObject` / `ObservableObject` as is (migration is out of scope).

### 3. `DoctorMenuView.swift` ~L13–40
Card title BEFORE `lm.strings.somethingWrong` → AFTER `lm.strings.symptomLogTitle`.

### 4. L10n (`Momsy/Core/Localization/L10n.swift`) — all 7 languages
ADD (EN reference):
- `symptomLogTitle` "Log symptoms"
- `symptomLogSubtitle` "Note what you observe to share with your pediatrician"
- `symptomSeverityQuestion` "How would you rate it?"
- `symptomSeverityMild` "Mild" · `symptomSeverityModerate` "Moderate" · `symptomSeverityHigh` "Severe"
- `symptomNotePlaceholder` "Add details (optional)"
- `symptomLogFooter` "Momsy does not assess symptoms or give medical advice. If you are worried about your baby, contact your pediatrician. In an emergency, call your local emergency number."

REMOVE keys referenced ONLY by deleted code. For each candidate run
`grep -rn "\.<key>\b" Momsy --include="*.swift"` and delete if 0 hits:
`symptomResult*`, `symptomUrgencyWatching`, `symptomUrgencyLikely`, `symptomUrgencySeeDoctor`,
`seeDoctorUrgently`, `markItGuide`, `somethingWrong`, `notADiagnosis`, `symptomDisclaimer`,
`symptomFooterDisclaimer`, `symptomSubChooseArea`, `symptomSubNone`, `symptomSubStoolNormal`,
`symptomSubSelect`, `symptomSubShortPhases`, `symptomSubDescribe`.

## Not touched
Persisted `SymptomLog` / diary records, `SymptomSeverity` enum, Diary rendering of old entries
(old entries whose text contains a former "likely" title stay as the user saved them).

## Tests (Swift Testing) — new `MomsyTests/Features/Symptom/SymptomViewModelTests.swift` (4 pbxproj points)
- Initial state: `isOnIDs.isEmpty`, `canSave == false`.
- Toggle 2 symptoms + note → `logToDiary()` → mock `addDiaryEntry` receives text containing both
  labels and the note; `SymptomLog.severity` equals the picked value.
- No symptom + empty note → nothing written.

## DoD
```bash
grep -rc "SymptomResult\|SymptomUrgency\|urgencyLabel" Momsy --include="*.swift" | grep -v ":0" | wc -l   # expect: 0
grep -rc "37.8°C" Momsy --include="*.swift" | grep -v ":0" | wc -l                                       # expect: 0
grep -rc "symptomUrgencyLikely\|seeDoctorUrgently\|symptomResult" Momsy --include="*.swift" | grep -v ":0" | wc -l  # expect: 0
grep -c "var symptomLogFooter" Momsy/Core/Localization/L10n.swift   # expect: 1
xcodebuild -scheme Momsy -destination 'platform=iOS Simulator,name=iPhone 17' build test   # green
```

## Manual QA
1. Today → Symptom quick item → nothing preselected, no result card, save disabled.
2. Select Temperature + Rash, severity Moderate, note "37.9 in the evening" → Save → Diary shows
   one note with both labels + note; no "likely"/advice text anywhere.
3. Doctor → symptoms card opens the same screen.
4. RU + ZH: all new strings localized, no truncation, Dynamic Type XL.
