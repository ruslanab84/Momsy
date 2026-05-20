import SwiftUI
import Combine

final class LeapsViewModel: ObservableObject {
    @Published var expandedLeapID: Int? = nil

    private var lm: LocalizationManager { .shared }

    var currentLeap: DevelopmentLeap { sampleLeaps.first(where: { $0.isCurrent }) ?? sampleLeaps[3] }

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
