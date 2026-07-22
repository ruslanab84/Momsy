import Testing
import SwiftData
@testable import Momsy
import Foundation

@Suite("VitaminCategories", .serialized)
@MainActor
struct VitaminCategoryTests {
    @Test func categoriesPersistDeduplicateAndStayBabyScoped() throws {
        let previousBabyID = ActiveBaby.currentId
        let babyA = UUID()
        let babyB = UUID()
        let suiteName = "VitaminCategoryTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer {
            defaults.removePersistentDomain(forName: suiteName)
            ActiveBaby.currentId = previousBabyID
        }

        let container = try ModelContainer(
            for: VitaminRecord.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        ActiveBaby.currentId = babyA
        let repository = SwiftDataVitaminRepository(
            context: ModelContext(container),
            defaults: defaults
        )
        let viewModel = VitaminViewModel(
            quickLogRepo: QuickLogRepository(),
            vitaminRepo: repository
        )

        viewModel.addCategory("  D3\n")
        viewModel.addCategory("d3")

        #expect(viewModel.categories == ["D3"])
        #expect(viewModel.vitaminName == "D3")

        let reopenedViewModel = VitaminViewModel(
            quickLogRepo: QuickLogRepository(),
            vitaminRepo: SwiftDataVitaminRepository(
                context: ModelContext(container),
                defaults: defaults
            )
        )
        #expect(reopenedViewModel.categories == ["D3"])

        ActiveBaby.currentId = babyB
        reopenedViewModel.loadToday()
        #expect(reopenedViewModel.categories.isEmpty)
    }
}
