# A6 — Global "Medical sources & disclaimer" screen

Severity: **P0** · Phase A · Depends on: A2
Baseline `eccd869` — re-anchor at HEAD.

## Goal
"The citations should be easy for the user to find." One screen listing every source, reachable
in ≤ 2 taps from Doctor, Me and Leaps, plus the per-surface links from A3–A5.

## Step 0 — Anchor
```bash
grep -c "NavigationLink(destination: SymptomView" Momsy/Features/Doctor/Presentation/Views/DoctorMenuView.swift  # expect: 1 (~L13, top card)
grep -c "MeRow(destination: SettingsView" Momsy/Features/Me/Presentation/Views/MeView.swift                     # expect: 1
```

## New files
```
Momsy/Core/MedicalSources/Presentation/MedicalSourcesScreen.swift
```
- `MedicalSourcesScreen`: `ScrollView` → disclaimer card (`medicalDisclaimerTitle`,
  `medicalDisclaimerBody`) → sources grouped by publisher (WHO first, then peer-reviewed),
  each group rendered with `MedicalSourcesSection`. Navigation title `medicalSourcesScreenTitle`.
- `#Preview` with the real static catalog.

## Entry points
1. `DoctorMenuView`: new `DoctorMenuRow` as the FIRST row of the list card (above CareTips ~L62):
   icon `books.vertical.fill`, title `medicalSourcesScreenTitle`, sub `medicalSourcesScreenSub`.
2. `MeView`: new `MeRow` in the section with Settings: same title/icon.
3. `LeapsView` "About leaps" sheet (A5) gets a footer link "All sources" → `MedicalSourcesScreen`.

## L10n (7 languages, EN reference)
- `medicalSourcesScreenTitle` "Medical sources"
- `medicalSourcesScreenSub` "Where our health information comes from"
- `medicalDisclaimerTitle` "Not medical advice"
- `medicalDisclaimerBody` "Momsy provides general information from the sources listed below to
  help you care for your baby. It does not diagnose conditions or replace your pediatrician. If you
  are worried about your baby's health, contact a doctor. In an emergency, call your local
  emergency number."

## Tests
- Screen model lists exactly `MedicalSourceCatalog.all.count` rows.

## DoD
```bash
grep -rc "MedicalSourcesScreen()" Momsy --include="*.swift" | grep -v ":0" | wc -l   # expect: 3 (Doctor, Me, Leaps sheet) + previews allowed
xcodebuild … build test   # green
```

## Manual QA
Doctor → first row → screen (1 tap). Me → Medical sources (1 tap). Links open Safari. 7 languages,
dark mode, Dynamic Type XXL.
