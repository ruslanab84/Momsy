# WEEKLY_INSIGHT_LANG_SWITCH — cost-optimization task

**For:** Claude Code CLI · branch `main` · repo `ruslanab84/Momsy`
**Goal:** Stop calling Gemini when the user changes the app language. Past weekly reports keep their original language; only future weeks use the new language.

**Why.** `GenerateWeeklyInsightUseCase.relocalizeStaleReports` re-generates **every** stored weekly report whose language differs from the current app language by calling Gemini once per report (each up to ×3 via `GeminiRetry`). One language switch therefore triggers an N×3-call burst proportional to report history. The decision: leave existing reports as-is — no re-translation, no Gemini cost on language change.

**Touch only** `GenerateWeeklyInsightUseCase.swift` and its test file. Nothing else.

---

## Change 1 — `Momsy/Features/WeeklyInsights/Domain/UseCases/GenerateWeeklyInsightUseCase.swift`

### 1a. Replace `generateIfNeeded`

**Remove:**
```swift
    @MainActor
    @discardableResult
    func generateIfNeeded(now: Date = Date()) async -> WeeklyInsight? {
        let language = LocalizationManager.shared.current
        // Refresh any previously stored reports that are now in the wrong language
        // (e.g. the user switched app language after they were generated).
        await relocalizeStaleReports(to: language)

        guard let (weekStart, weekEnd) = Self.weekBounds(now: now) else { return nil }
        // Skip only when a report for this week already exists in the current language.
        if let existing = (try? await repo.report(forWeekStarting: weekStart)) ?? nil,
           existing.language == language { return nil }

        let birthDate = appState.babyProfile?.birthDate
        let insight = await generate(weekStart: weekStart, weekEnd: weekEnd,
                                     birthDate: birthDate, language: language)
        try? await repo.save(insight)
        return insight
    }
```

**With:**
```swift
    @MainActor
    @discardableResult
    func generateIfNeeded(now: Date = Date()) async -> WeeklyInsight? {
        let language = LocalizationManager.shared.current
        guard let (weekStart, weekEnd) = Self.weekBounds(now: now) else { return nil }
        // A report for this week already exists — keep it in whatever language it was
        // generated in. Changing the app language never re-generates or re-translates
        // past reports (no Gemini cost on language switch); only future weeks use the
        // new language.
        if ((try? await repo.report(forWeekStarting: weekStart)) ?? nil) != nil { return nil }

        let birthDate = appState.babyProfile?.birthDate
        let insight = await generate(weekStart: weekStart, weekEnd: weekEnd,
                                     birthDate: birthDate, language: language)
        try? await repo.save(insight)
        return insight
    }
```

### 1b. Delete `relocalizeStaleReports` entirely

**Remove (no other callers exist — verified):**
```swift
    /// Re-localizes stored reports whose language no longer matches `language`.
    /// Stats are deterministic and already on-device, so only the AI narrative and
    /// the localized leap label are recomputed. Skips a report when the AI call
    /// fails so a good narrative is never downgraded to the offline fallback.
    func relocalizeStaleReports(to language: Language) async {
        let reports = (try? await repo.all()) ?? []
        for report in reports where report.language != language {
            let leap = BabyAgeContext.currentLeapName(ageWeeks: report.stats.ageWeeks, lang: language.rawValue)
            let stats = report.stats.withLeapName(leap)
            let ctx = WeeklyInsightContext(stats: stats, language: language)
            guard let ai = try? await service.generate(context: ctx) else { continue }
            let relocalized = WeeklyInsight(stats: stats, ai: ai, isAIGenerated: true,
                                            generatedAt: report.generatedAt, language: language)
            try? await repo.save(relocalized)
        }
    }
```

> Leave `generate(...)`, `weekBounds(...)`, and the rest of the file unchanged. If the compiler flags `BabyAgeContext` / `withLeapName` as now-unused imports in this file, that's expected — only remove a symbol if it becomes genuinely unreferenced file-wide.

---

## Change 2 — `MomsyTests/Features/WeeklyInsights/GenerateWeeklyInsightUseCaseTests.swift`

### 2a. Delete the three tests for the removed behavior
- `relocalizeOnLanguageChange()` — `@Test("relocalizes a stored report whose language differs from the app language")`
- `relocalizeNoOpSameLanguage()` — `@Test("relocalize is a no-op when the stored language already matches")`
- `relocalizeKeepsStaleOnFailure()` — `@Test("relocalize keeps a stale report when the AI service fails (no downgrade)")`

Keep the `sampleStats(weekStart:weekEnd:)` private helper — the new test below uses it.

### 2b. Add the replacement test
```swift
    @Test("changing app language keeps existing reports as-is (no Gemini call)")
    func languageChangeKeepsReportsAsIs() async throws {
        let previous = LocalizationManager.shared.current
        defer { LocalizationManager.shared.set(previous) }

        let now = Date()
        let bounds = GenerateWeeklyInsightUseCase.weekBounds(now: now)!
        LocalizationManager.shared.set(.russian)            // app language is now RU…
        let appState = makeAppState(profile: BabyProfile(name: "Mia"))
        let repo = MockWeeklyInsightRepository()
        let englishAI = WeeklyInsightAI(sleepSummary: "English summary", sleepRecommendation: "",
                                        feedingSummary: "", feedingRecommendation: "", overallSummary: "")
        // …but this week's report was generated earlier in English.
        try await repo.save(WeeklyInsight(stats: sampleStats(weekStart: bounds.start, weekEnd: bounds.end),
                                          ai: englishAI, isAIGenerated: true,
                                          generatedAt: Date(), language: .english))
        let service = MockWeeklyInsightService()
        let uc = makeUseCase(repo: repo, service: service, appState: appState)

        let result = await uc.generateIfNeeded(now: now)

        #expect(result == nil)                       // existing report → not regenerated
        #expect(service.callCount == 0)              // zero Gemini calls on language change
        let stored = try await repo.all()
        #expect(stored.count == 1)
        #expect(stored.first?.language == .english)  // old report untouched
        #expect(stored.first?.ai.sleepSummary == "English summary")
    }
```

> The test mutates the `LocalizationManager.shared` singleton because `generateIfNeeded` reads the current language directly (no injection point). The `defer` restore is required so the change can't leak into other suites. The suite is already `@MainActor` + `.serialized`, consistent with this.

---

## Definition of Done
- [ ] `generateIfNeeded` no longer calls `relocalizeStaleReports`; its dedup guard skips when a report for the week exists in **any** language.
- [ ] `relocalizeStaleReports(to:)` removed; no remaining references (`grep -rn relocaliz` returns nothing).
- [ ] Three obsolete relocalize tests removed; `languageChangeKeepsReportsAsIs` added; `sampleStats` retained.
- [ ] Full test suite green (was 210/210 — must stay green with the swapped test).

## Manual QA
- [ ] Generate this week's report in RU → switch app language to EN → open Weekly Insights: the existing report still shows in RU, **no** new network call fires, no new report is created for the same week.
- [ ] Wait into the next completed week (or adjust device date) with language EN → the new week's report is generated in EN. Past RU reports remain RU.
