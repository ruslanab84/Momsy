import SwiftUI
import Combine

@MainActor
final class LeapsViewModel: ObservableObject {
    @Published var leaps: [DevelopmentLeap] = DevelopmentLeap.catalog
    @Published var expandedLeapID: Int? = nil

    private let getLeapsUC: GetLeapsUseCase
    private let markLeapCompleteUC: MarkLeapCompleteUseCase
    private let appState: AppState
    private var lm: LocalizationManager { .shared }

    init(getLeaps: GetLeapsUseCase, markLeapComplete: MarkLeapCompleteUseCase, appState: AppState) {
        self.getLeapsUC = getLeaps
        self.markLeapCompleteUC = markLeapComplete
        self.appState = appState
        Task { await loadLeaps() }
    }

    var currentLeap: DevelopmentLeap {
        leaps.first(where: { $0.isCurrent }) ?? leaps.first(where: { !$0.isDone }) ?? leaps[3]
    }

    /// Phase of the genuinely-current leap, or nil when no leap is active (newborn).
    var leapPhase: BabyAgeContext.LeapPhase? {
        guard let leap = leaps.first(where: { $0.isCurrent }) else { return nil }
        let days = BabyAgeContext.ageDays(birthDate: appState.babyProfile?.birthDate)
        return BabyAgeContext.leapPhase(for: leap, ageDays: days)
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
        let uid  = UserDefaults.standard.string(forKey: "uid") ?? ""
        let name = UserDefaults.standard.string(forKey: "displayName") ?? ""
        let log = LeapLog(
            id: String(progress.id), leapId: progress.id,
            isDone: progress.isDone, completedDate: progress.completedDate,
            addedBy: uid, addedByName: name
        )
        Task { try? await BabySyncService().setLog(LeapLogDTO(from: log), id: log.id, to: "leapLogs") }
    }

    func toggleExpand(_ id: Int) {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
            expandedLeapID = expandedLeapID == id ? nil : id
        }
    }
}
