import Foundation

final class PredictNextSleepUseCase {
    private let getSleep: GetSleepEntriesUseCase
    private let engine: SleepForecastEngine
    private let lookbackDays: Int

    init(getSleep: GetSleepEntriesUseCase, engine: SleepForecastEngine, lookbackDays: Int = 14) {
        self.getSleep = getSleep
        self.engine = engine
        self.lookbackDays = lookbackDays
    }

    func execute(birthDate: Date, now: Date = Date()) async throws -> SleepPrediction? {
        let from = Calendar.current.date(byAdding: .day, value: -lookbackDays, to: now) ?? now
        let entries = try await getSleep.execute(from: from, to: now)
        return engine.predict(birthDate: birthDate, entries: entries, now: now)
    }
}
