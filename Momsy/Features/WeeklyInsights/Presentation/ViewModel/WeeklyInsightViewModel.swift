import Foundation
import Combine

@MainActor
final class WeeklyInsightViewModel: ObservableObject {
    @Published var reports: [WeeklyInsight] = []
    @Published var state: LoadingState<Void> = .idle

    private let generate: GenerateWeeklyInsightUseCase
    private let get: GetWeeklyInsightsUseCase

    init(generate: GenerateWeeklyInsightUseCase, get: GetWeeklyInsightsUseCase) {
        self.generate = generate
        self.get = get
    }

    /// Loads stored reports, generating this week's report first if the user is premium.
    func load(isPremium: Bool) async {
        if reports.isEmpty { state = .loading }
        if isPremium {
            _ = await generate.generateIfNeeded()
        }
        do {
            reports = try await get.all()
            state = .loaded(())
        } catch {
            state = .error(LocalizationManager.shared.strings.weeklyInsightError)
        }
    }
}
