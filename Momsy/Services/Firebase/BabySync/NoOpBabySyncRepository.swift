import Foundation

final class NoOpBabySyncRepository: BabySyncRepositoryProtocol {
    var feedingLogs: AsyncStream<[FeedingLog]> { emptyStream() }
    var sleepLogs: AsyncStream<[SleepLog]> { emptyStream() }
    var diaperLogs: AsyncStream<[DiaperLog]> { emptyStream() }

    func addFeedingLog(_ log: FeedingLog) async throws { }
    func addSleepLog(_ log: SleepLog) async throws { }
    func addDiaperLog(_ log: DiaperLog) async throws { }
    func addSymptomLog(_ log: SymptomLog) async throws { }
    func addDiaryLog(_ log: DiaryLog) async throws { }
    func addMeasurementLog(_ log: MeasurementLog) async throws { }
    func addVaccinationLog(_ log: VaccinationLog) async throws { }
    func addFoodDiaryLog(_ log: FoodDiaryLog) async throws { }

    func fetchTodayFeedings() async throws -> [FeedingLog] { [] }
    func fetchTodaySleep() async throws -> [SleepLog] { [] }

    func syncBabyProfile(_ profile: BabyProfile) async throws { }
    func fetchBabyProfile() async throws -> BabyProfile? { nil }
    func deleteBaby(id: UUID) async throws { }

    private func emptyStream<T>() -> AsyncStream<[T]> {
        AsyncStream { continuation in
            continuation.yield([])
            continuation.finish()
        }
    }
}
