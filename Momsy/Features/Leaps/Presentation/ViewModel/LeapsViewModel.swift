import SwiftUI
import Combine

@MainActor
final class LeapsViewModel: ObservableObject {
    @Published var leaps: [DevelopmentLeap] = DevelopmentLeap.catalog
    @Published var expandedLeapID: Int? = nil

    private let getLeapsUC: GetLeapsUseCase
    private let appState: AppState
    private var lm: LocalizationManager { .shared }

    init(getLeaps: GetLeapsUseCase, appState: AppState) {
        self.getLeapsUC = getLeaps
        self.appState = appState
        Task { await loadLeaps() }
    }

    var currentLeap: DevelopmentLeap {
        leaps.first(where: { $0.isCurrent }) ?? leaps.first(where: { !$0.isDone }) ?? leaps[3]
    }

    func loadLeaps() async {
        let progress = (try? await getLeapsUC.execute()) ?? []
        let doneIDs = Set(progress.filter(\.isDone).map(\.id))
        let ageWeeks = appState.babyProfile.map {
            max(0, Calendar.current.dateComponents([.weekOfYear], from: $0.birthDate, to: Date()).weekOfYear ?? 0)
        } ?? 0
        let current = DevelopmentLeap.catalog
            .first(where: { !doneIDs.contains($0.id) && $0.week <= ageWeeks + 4 })
            ?? DevelopmentLeap.catalog.last(where: { $0.week <= ageWeeks })
        leaps = DevelopmentLeap.catalog.map { leap in
            var copy = leap
            copy.isDone = doneIDs.contains(leap.id)
            copy.isCurrent = leap.id == current?.id
            return copy
        }
    }

    func leapName(_ l: DevelopmentLeap) -> String { lm.lang == "en" ? l.nameEn : l.name }
    func leapDesc(_ l: DevelopmentLeap) -> String { lm.lang == "en" ? l.descriptionEn : l.description }
    func leapSigns(_ l: DevelopmentLeap) -> [String] { lm.lang == "en" ? l.signsEn : l.signs }
    func leapSkills(_ l: DevelopmentLeap) -> [String] { lm.lang == "en" ? l.skillsEn : l.skills }
    func leapTip(_ l: DevelopmentLeap) -> String { lm.lang == "en" ? l.tipEn : l.tip }

    func toggleExpand(_ id: Int) {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
            expandedLeapID = expandedLeapID == id ? nil : id
        }
    }
}
