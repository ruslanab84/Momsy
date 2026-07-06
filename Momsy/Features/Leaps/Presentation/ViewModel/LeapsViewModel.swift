import SwiftUI
import Combine

@MainActor
final class LeapsViewModel: ObservableObject {
    @Published var leaps: [DevelopmentLeap] = DevelopmentLeap.catalog
    @Published var expandedLeapID: Int? = nil
    @Published private(set) var checkIns: [LeapDailyCheckIn] = []
    @Published private(set) var selectedSymptoms: Set<LeapCheckInSymptom> = []
    @Published private(set) var behaviorInsights: [LeapBehaviorInsight] = []

    private let getLeapsUC: GetLeapsUseCase
    private let markLeapCompleteUC: MarkLeapCompleteUseCase
    private let getCheckInsUC: GetLeapCheckInsUseCase
    private let saveCheckInUC: SaveLeapCheckInUseCase
    private let getSleepUC: GetSleepEntriesUseCase
    private let getFeedingUC: GetFeedingEntriesUseCase
    private let appState: AppState
    private let calendar: Calendar
    private var lm: LocalizationManager { .shared }
    private var mergeObserver: NSObjectProtocol?

    init(
        getLeaps: GetLeapsUseCase,
        markLeapComplete: MarkLeapCompleteUseCase,
        getCheckIns: GetLeapCheckInsUseCase,
        saveCheckIn: SaveLeapCheckInUseCase,
        getSleep: GetSleepEntriesUseCase,
        getFeeding: GetFeedingEntriesUseCase,
        appState: AppState,
        calendar: Calendar = .current
    ) {
        self.getLeapsUC = getLeaps
        self.markLeapCompleteUC = markLeapComplete
        self.getCheckInsUC = getCheckIns
        self.saveCheckInUC = saveCheckIn
        self.getSleepUC = getSleep
        self.getFeedingUC = getFeeding
        self.appState = appState
        self.calendar = calendar
        Task { await loadLeaps() }
        // Switching the active child re-pulls its cloud logs and posts this; reload
        // so the leap timeline reflects the new baby's age and progress.
        mergeObserver = NotificationCenter.default.addObserver(
            forName: .cloudSyncDidMerge, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in await self?.loadLeaps() }
        }
    }

    var todayActions: [LeapTodayAction] {
        var actions = [
            LeapTodayAction(
                id: "play",
                title: lm.strings.leapActionPlayTitle,
                detail: leapTip(currentLeap),
                systemImage: "sparkles"
            ),
            LeapTodayAction(
                id: "sleep",
                title: lm.strings.leapActionSleepTitle,
                detail: isHardPhase(currentLeapPhase) ? lm.strings.leapActionSleepHard : lm.strings.leapActionSleepCalm,
                systemImage: "moon.fill"
            )
        ]
        let shouldPrioritizeFeeding = selectedSymptoms.contains(.appetiteShift)
            || behaviorInsights.contains(where: { $0.id == "feeding" })
        actions.append(
            LeapTodayAction(
                id: shouldPrioritizeFeeding ? "feeding" : "contact",
                title: shouldPrioritizeFeeding ? lm.strings.leapActionFeedingTitle : lm.strings.leapActionContactTitle,
                detail: shouldPrioritizeFeeding ? lm.strings.leapActionFeeding : lm.strings.leapActionContact,
                systemImage: shouldPrioritizeFeeding ? "fork.knife" : "heart.fill"
            )
        )
        return actions
    }

    deinit {
        if let mergeObserver { NotificationCenter.default.removeObserver(mergeObserver) }
    }

    var currentLeap: DevelopmentLeap {
        leaps.first(where: { $0.isCurrent }) ?? leaps.first(where: { !$0.isDone }) ?? leaps.last ?? DevelopmentLeap.catalog[0]
    }

    var currentLeapPhase: BabyAgeContext.LeapPhase {
        leapPhase(for: currentLeap)
    }

    func leapPhase(for leap: DevelopmentLeap) -> BabyAgeContext.LeapPhase {
        BabyAgeContext.leapPhase(
            for: leap,
            birthDate: appState.babyProfile?.birthDate,
            isCompleted: leap.isDone
        )
    }

    func leapPhaseTitle(_ phase: BabyAgeContext.LeapPhase) -> String {
        switch phase {
        case .upcoming:
            return lm.strings.leapPhaseSoon
        case .hardDays:
            return lm.strings.leapPhaseHardDays
        case .consolidation:
            return lm.strings.leapPhaseConsolidation
        case .completed:
            return lm.strings.leapCompletedStatus
        }
    }

    func leapPhaseDetail(_ phase: BabyAgeContext.LeapPhase) -> String {
        switch phase {
        case .upcoming(let startDate, let daysUntilStart):
            guard let date = formattedDate(startDate) else { return "" }
            guard let daysUntilStart, daysUntilStart > 0 else {
                return lm.strings.leapStartsOn(date)
            }
            return lm.strings.leapStartsIn(days: daysUntilStart, date: date)
        case .hardDays(_, _, _, let daysUntilPeak, _, let daysRemaining):
            let peak = (daysUntilPeak ?? 0) == 0
                ? lm.strings.leapPeakToday
                : lm.strings.leapPeakIn(days: daysUntilPeak ?? 0)
            return "\(peak) · \(lm.strings.leapHardDaysLeft(days: daysRemaining))"
        case .consolidation:
            return lm.strings.leapConsolidationDetail
        case .completed:
            return lm.strings.leapCompletedDetail
        }
    }

    func loadLeaps() async {
        let progress = (try? await getLeapsUC.execute()) ?? []
        let doneIDs = Set(progress.filter(\.isDone).map(\.id))
        let ageWeeks = BabyAgeContext.ageWeeks(birthDate: appState.babyProfile?.birthDate)
        let current = BabyAgeContext.currentLeap(ageWeeks: ageWeeks, completedIDs: doneIDs)
        leaps = DevelopmentLeap.catalog.map { leap in
            var copy = leap
            copy.isCurrent = leap.id == current?.id
            copy.isDone = doneIDs.contains(leap.id) || (!copy.isCurrent && leap.week <= ageWeeks)
            return copy
        }
        await refreshPersonalizedContext()
    }

    func calendarDays(scope: LeapCalendarScope) -> [LeapCalendarDay] {
        guard let birthDate = appState.babyProfile?.birthDate else { return [] }
        let leap = currentLeap
        let today = calendar.startOfDay(for: Date())
        let reference = calendarReferenceDate(for: leap, birthDate: birthDate, today: today)
        let start: Date
        let end: Date
        switch scope {
        case .week:
            let interval = calendar.dateInterval(of: .weekOfYear, for: reference)
            start = interval?.start ?? reference
            end = calendar.date(byAdding: .day, value: 7, to: start) ?? reference
        case .month:
            let interval = calendar.dateInterval(of: .month, for: reference)
            start = interval?.start ?? reference
            end = interval?.end ?? calendar.date(byAdding: .day, value: 30, to: start) ?? reference
        }
        let dayCount = max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
        return (0..<dayCount).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return LeapCalendarDay(
                date: date,
                dayNumber: calendar.component(.day, from: date),
                phase: calendarPhase(for: date, leap: leap, birthDate: birthDate),
                isToday: calendar.isDate(date, inSameDayAs: today),
                hasCheckIn: checkIns.contains { calendar.isDate($0.date, inSameDayAs: date) }
            )
        }
    }

    func calendarScopeTitle(_ scope: LeapCalendarScope) -> String {
        switch scope {
        case .week: return lm.strings.leapCalendarWeekMode
        case .month: return lm.strings.leapCalendarMonthMode
        }
    }

    func calendarPhaseTitle(_ phase: LeapCalendarDayPhase) -> String {
        switch phase {
        case .calm: return lm.strings.leapCalmDay
        case .hard: return lm.strings.leapHardDay
        case .peak: return lm.strings.leapPeakDay
        case .recovery: return lm.strings.leapRecoveryDay
        }
    }

    func symptomTitle(_ symptom: LeapCheckInSymptom) -> String {
        symptom.title(for: lm.current)
    }

    func toggleSymptom(_ symptom: LeapCheckInSymptom) async {
        var symptoms = selectedSymptoms
        if symptoms.contains(symptom) {
            symptoms.remove(symptom)
        } else {
            symptoms.insert(symptom)
        }
        selectedSymptoms = symptoms
        let checkIn = LeapDailyCheckIn(
            leapID: currentLeap.id,
            date: calendar.startOfDay(for: Date()),
            symptoms: symptoms
        )
        try? await saveCheckInUC.execute(checkIn)
        await loadCheckIns()
    }

    private func formattedDate(_ date: Date?) -> String? {
        guard let date else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: lm.current.localeIdentifier)
        formatter.setLocalizedDateFormatFromTemplate("d MMM")
        return formatter.string(from: date)
    }

    private func refreshPersonalizedContext() async {
        await loadCheckIns()
        await loadBehaviorInsights()
    }

    private func loadCheckIns() async {
        checkIns = (try? await getCheckInsUC.execute(leapID: currentLeap.id)) ?? []
        let today = calendar.startOfDay(for: Date())
        selectedSymptoms = checkIns.first { calendar.isDate($0.date, inSameDayAs: today) }?.symptoms ?? []
    }

    private func loadBehaviorInsights() async {
        guard currentLeap.isCurrent,
              let birthDate = appState.babyProfile?.birthDate else {
            behaviorInsights = []
            return
        }
        let leap = currentLeap
        let start = calendar.startOfDay(for: BabyAgeContext.leapStartDate(for: leap, birthDate: birthDate, calendar: calendar))
        let today = calendar.startOfDay(for: Date())
        guard today >= start else {
            behaviorInsights = []
            return
        }
        let baselineStart = calendar.date(byAdding: .day, value: -7, to: start) ?? start
        let recentStart = maxDate(start, calendar.date(byAdding: .day, value: -3, to: today) ?? start)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today

        var insights: [LeapBehaviorInsight] = []
        if let sleepInsight = await sleepInsight(from: baselineStart, start: start, recentStart: recentStart, end: tomorrow) {
            insights.append(sleepInsight)
        }
        if let feedingInsight = await feedingInsight(from: baselineStart, start: start, recentStart: recentStart, end: tomorrow) {
            insights.append(feedingInsight)
        }
        behaviorInsights = Array(insights.prefix(2))
    }

    private func sleepInsight(from baselineStart: Date, start: Date, recentStart: Date, end: Date) async -> LeapBehaviorInsight? {
        guard let entries = try? await getSleepUC.execute(from: baselineStart, to: end) else { return nil }
        let baseline = averageSleepMinutes(entries, from: baselineStart, to: start)
        let recent = averageSleepMinutes(entries, from: recentStart, to: end)
        guard baseline >= 180, recent > 0, baseline - recent >= 45 else { return nil }
        return LeapBehaviorInsight(
            id: "sleep",
            title: lm.strings.leapInsightTitle,
            detail: lm.strings.leapSleepInsight,
            systemImage: "moon.zzz.fill"
        )
    }

    private func feedingInsight(from baselineStart: Date, start: Date, recentStart: Date, end: Date) async -> LeapBehaviorInsight? {
        guard let entries = try? await getFeedingUC.execute(from: baselineStart, to: end) else { return nil }
        let baseline = averageFeedingCount(entries, from: baselineStart, to: start)
        let recent = averageFeedingCount(entries, from: recentStart, to: end)
        guard baseline >= 2, recent > 0, abs(baseline - recent) >= 1.5 else { return nil }
        return LeapBehaviorInsight(
            id: "feeding",
            title: lm.strings.leapInsightTitle,
            detail: lm.strings.leapFeedingInsight,
            systemImage: "fork.knife"
        )
    }

    private func averageSleepMinutes(_ entries: [SleepEntry], from start: Date, to end: Date) -> Double {
        let filtered = entries.filter { $0.startDate >= start && $0.startDate < end }
        let total = filtered.compactMap(\.durationMinutes).reduce(0, +)
        return Double(total) / daysCount(from: start, to: end)
    }

    private func averageFeedingCount(_ entries: [FeedingEntry], from start: Date, to end: Date) -> Double {
        let count = entries.filter { $0.date >= start && $0.date < end }.count
        return Double(count) / daysCount(from: start, to: end)
    }

    private func daysCount(from start: Date, to end: Date) -> Double {
        Double(max(1, calendar.dateComponents([.day], from: start, to: end).day ?? 1))
    }

    private func calendarReferenceDate(for leap: DevelopmentLeap, birthDate: Date, today: Date) -> Date {
        if leap.isCurrent { return today }
        if case .upcoming(let startDate, _) = leapPhase(for: leap), let startDate {
            return calendar.startOfDay(for: startDate)
        }
        return today
    }

    private func calendarPhase(for date: Date, leap: DevelopmentLeap, birthDate: Date) -> LeapCalendarDayPhase {
        let day = calendar.startOfDay(for: date)
        let start = calendar.startOfDay(for: BabyAgeContext.leapStartDate(for: leap, birthDate: birthDate, calendar: calendar))
        let dayInLeap = (calendar.dateComponents([.day], from: start, to: day).day ?? 0) + 1
        guard dayInLeap >= 1 else { return .calm }
        if dayInLeap == BabyAgeContext.peakDay(totalHardDays: leap.hardDays) { return .peak }
        if dayInLeap <= leap.hardDays { return .hard }
        if dayInLeap <= leap.hardDays + 14 { return .recovery }
        return .calm
    }

    private func isHardPhase(_ phase: BabyAgeContext.LeapPhase) -> Bool {
        if case .hardDays = phase { return true }
        return false
    }

    private func maxDate(_ lhs: Date, _ rhs: Date) -> Date {
        lhs > rhs ? lhs : rhs
    }

    func leapName(_ l: DevelopmentLeap) -> String { l.name(for: lm.current) }
    func leapDesc(_ l: DevelopmentLeap) -> String { l.description(for: lm.current) }
    func leapSigns(_ l: DevelopmentLeap) -> [String] { l.signs(for: lm.current) }
    func leapSkills(_ l: DevelopmentLeap) -> [String] { l.skills(for: lm.current) }
    func leapTip(_ l: DevelopmentLeap) -> String { l.tip(for: lm.current) }

    func markComplete(id: Int) async {
        try? await markLeapCompleteUC.execute(leapId: id)
        pushLeapToFirestore(LeapProgress(id: id, isDone: true, completedDate: Date()))
        await loadLeaps()
    }

    private func pushLeapToFirestore(_ progress: LeapProgress) {
        guard FamilyManager.shared.familyId != nil else { return }
        let log = LeapLog(
            id: String(progress.id), leapId: progress.id,
            isDone: progress.isDone, completedDate: progress.completedDate,
            addedBy: "", addedByName: ""
        )
        Task { try? await BabySyncService().setLog(LeapLogDTO(from: log), id: log.id, to: "leapLogs") }
    }

    func toggleExpand(_ id: Int) {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
            expandedLeapID = expandedLeapID == id ? nil : id
        }
    }
}
