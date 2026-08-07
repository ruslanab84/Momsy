import SwiftUI
import Combine

@MainActor
final class CareTipsViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedCategory: CareTipCategory? = nil
    @Published var isAgeFilterOn: Bool = true

    private let appState: AppState
    private let catalog: [CareTip]
    private var lm: LocalizationManager { .shared }

    init(appState: AppState, catalog: [CareTip] = CareTipsCatalog.all) {
        self.appState = appState
        self.catalog = catalog
        self.isAgeFilterOn = appState.babyProfile?.birthDate != nil
    }

    var babyAgeMonths: Int? {
        guard let birth = appState.babyProfile?.birthDate else { return nil }
        return BabyAgeContext.ageMonths(birthDate: birth)
    }

    var canFilterByAge: Bool { babyAgeMonths != nil }

    var sections: [(category: CareTipCategory, tips: [CareTip])] {
        let lang = lm.current
        let age = isAgeFilterOn ? babyAgeMonths : nil
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        let filtered = catalog.filter { tip in
            if let selectedCategory, tip.category != selectedCategory { return false }
            if let age, !tip.matches(ageMonths: age) { return false }
            return tip.matches(query: query, lang: lang)
        }

        return CareTipCategory.allCases.compactMap { category in
            let tips = filtered.filter { $0.category == category }
            return tips.isEmpty ? nil : (category: category, tips: tips)
        }
    }

    var isEmpty: Bool { sections.isEmpty }

    func toggleCategory(_ category: CareTipCategory) {
        selectedCategory = (selectedCategory == category) ? nil : category
    }
}
