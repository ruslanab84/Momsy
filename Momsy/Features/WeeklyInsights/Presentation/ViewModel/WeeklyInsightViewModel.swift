import Foundation
import Combine

@MainActor
final class WeeklyInsightViewModel: ObservableObject {
    @Published var reports: [WeeklyInsight] = []
    @Published var state: LoadingState<Void> = .idle

    private let generate: GenerateWeeklyInsightUseCase
    private let get: GetWeeklyInsightsUseCase
    private var loadedBabyId: UUID?

    init(generate: GenerateWeeklyInsightUseCase, get: GetWeeklyInsightsUseCase) {
        self.generate = generate
        self.get = get
    }

    /// Loads stored reports, generating this week's report first if the user is premium.
    func load(isPremium: Bool, babyId: UUID?) async {
        if loadedBabyId != babyId {
            loadedBabyId = babyId
            reports = []
            state = .loading
        } else if reports.isEmpty {
            state = .loading
        }
        guard babyId != nil else {
            state = .loaded(())
            return
        }
        if isPremium {
            _ = await generate.generateIfNeeded()
        }
        do {
            let loadedReports = try await get.all()
            guard loadedBabyId == babyId else { return }
            reports = loadedReports
            state = .loaded(())
        } catch {
            guard loadedBabyId == babyId else { return }
            state = .error(LocalizationManager.shared.strings.weeklyInsightError)
        }
    }
}
