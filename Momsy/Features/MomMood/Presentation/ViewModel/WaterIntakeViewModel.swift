import SwiftUI
import Combine

@MainActor
final class WaterIntakeViewModel: ObservableObject {
    @Published private(set) var todayEntries: [WaterIntakeEntry] = []
    @Published private(set) var weeklyDayTotals: [Int] = []   // 7 values, index 0 = 6 days ago
    @Published var saveError: String?

    /// The parent's own target, editable in the UI — not a health recommendation.
    @Published private(set) var goalMl: Int

    static let goalRange = 1000...4000
    static let goalStep = 250

    private let logUseCase: LogWaterIntakeUseCase
    private let getUseCase: GetWaterIntakeUseCase
    private let preferences: any UserPreferencesRepository

    init(log: LogWaterIntakeUseCase, get: GetWaterIntakeUseCase, preferences: any UserPreferencesRepository) {
        self.logUseCase = log
        self.getUseCase = get
        self.preferences = preferences
        goalMl = Self.clampedGoal(preferences.load().waterGoalMl)
    }

    var todayTotalMl: Int { todayEntries.map(\.amountMl).reduce(0, +) }
    var goalFraction: Double { min(1.0, Double(todayTotalMl) / Double(goalMl)) }

    func setGoal(_ ml: Int) {
        goalMl = Self.clampedGoal(ml)
        var prefs = preferences.load()
        prefs.waterGoalMl = goalMl
        preferences.save(prefs)
    }

    private static func clampedGoal(_ ml: Int) -> Int {
        min(max(ml, goalRange.lowerBound), goalRange.upperBound)
    }

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
            pushWaterIntakeToFirestore(saved)
        } catch {
            saveError = error.localizedDescription
        }
    }

    private func pushWaterIntakeToFirestore(_ entry: WaterIntakeEntry) {
        guard FamilyManager.shared.familyId != nil else { return }
        let log = WaterIntakeLog(
            id: entry.id.uuidString, date: entry.date,
            amountMl: entry.amountMl, addedBy: "", addedByName: ""
        )
        Task { try? await BabySyncService().setLog(WaterIntakeLogDTO(from: log), id: log.id, to: "waterIntakeLogs") }
    }
}
