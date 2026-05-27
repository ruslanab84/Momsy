import SwiftUI
import Combine

@MainActor
final class WaterIntakeViewModel: ObservableObject {
    @Published private(set) var todayEntries: [WaterIntakeEntry] = []
    @Published private(set) var weeklyDayTotals: [Int] = []   // 7 values, index 0 = 6 days ago
    @Published var saveError: String?

    let dailyGoalMl = 2000

    private let logUseCase: LogWaterIntakeUseCase
    private let getUseCase: GetWaterIntakeUseCase

    init(log: LogWaterIntakeUseCase, get: GetWaterIntakeUseCase) {
        self.logUseCase = log
        self.getUseCase = get
    }

    var todayTotalMl: Int { todayEntries.map(\.amountMl).reduce(0, +) }
    var goalFraction: Double { min(1.0, Double(todayTotalMl) / Double(dailyGoalMl)) }

    func load() async {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        let todayEnd   = cal.date(byAdding: .day, value: 1, to: todayStart) ?? Date()

        guard let weekStart = cal.date(byAdding: .day, value: -6, to: todayStart) else { return }

        do {
            let all = try await getUseCase.execute(from: weekStart, to: todayEnd)

            todayEntries = all
                .filter { cal.isDateInToday($0.date) }
                .sorted { $0.date < $1.date }

            weeklyDayTotals = (0..<7).map { offset in
                guard let day = cal.date(byAdding: .day, value: offset, to: weekStart) else { return 0 }
                return all
                    .filter { cal.isDate($0.date, inSameDayAs: day) }
                    .map(\.amountMl)
                    .reduce(0, +)
            }
        } catch {
            saveError = error.localizedDescription
        }
    }

    func log(amountMl: Int) async {
        do {
            let saved = try await logUseCase.execute(amountMl: amountMl)
            todayEntries.append(saved)
            todayEntries.sort { $0.date < $1.date }
            // Update today's slot in the weekly chart (last index = today)
            if weeklyDayTotals.count == 7 {
                weeklyDayTotals[6] = todayEntries.map(\.amountMl).reduce(0, +)
            }
        } catch {
            saveError = error.localizedDescription
        }
    }
}
