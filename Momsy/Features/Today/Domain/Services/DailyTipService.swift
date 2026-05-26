import Foundation

protocol DailyTipService {
    /// Fetches a personalized daily tip based on aggregated day data.
    func fetch(context: DailyContext) async throws -> String
}
