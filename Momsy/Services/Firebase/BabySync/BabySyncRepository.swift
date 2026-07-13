import Foundation

final class BabySyncRepository: BabySyncRepositoryProtocol {
    private let service: BabySyncService

    init(service: BabySyncService) {
        self.service = service
    }

    func addFeedingLog(_ log: FeedingLog) async throws {
        try await service.setLog(FeedingLogDTO(from: log), id: log.id, to: "feedingLogs")
    }

    func addSleepLog(_ log: SleepLog) async throws {
        try await service.setLog(SleepLogDTO(from: log), id: log.id, to: "sleepLogs")
    }

    func addDiaperLog(_ log: DiaperLog) async throws {
        try await service.setLog(DiaperLogDTO(from: log), id: log.id, to: "diaperLogs")
    }

    func addSymptomLog(_ log: SymptomLog) async throws {
        try await service.setLog(SymptomLogDTO(from: log), id: log.id, to: "symptomLogs")
    }

    func addDiaryLog(_ log: DiaryLog) async throws {
        try await service.setLog(DiaryLogDTO(from: log), id: log.id, to: "diaryLogs")
    }

    func addMeasurementLog(_ log: MeasurementLog) async throws {
        try await service.setLog(MeasurementLogDTO(from: log), id: log.id, to: "measurementLogs")
    }

    func addVaccinationLog(_ log: VaccinationLog) async throws {
        try await service.setLog(VaccinationLogDTO(from: log), id: log.id, to: "vaccinationLogs")
    }

    func addFoodDiaryLog(_ log: FoodDiaryLog) async throws {
        try await service.setLog(FoodDiaryLogDTO(from: log), id: log.id, to: "foodDiaryLogs")
    }

    func fetchTodayFeedings() async throws -> [FeedingLog] {
        let dtos: [FeedingLogDTO] = try await service.fetchToday(from: "feedingLogs")
        return dtos.map(\.domain)
    }

    func fetchTodaySleep() async throws -> [SleepLog] {
        let dtos: [SleepLogDTO] = try await service.fetchToday(from: "sleepLogs")
        return dtos.map(\.domain)
    }

    func syncBabyProfile(_ profile: BabyProfile) async throws {
        try await service.setBabyProfile(profile)
    }

    func fetchBabyProfile() async throws -> BabyProfile? {
        try await service.fetchBabyProfile()?.domain
    }

    func deleteBaby(id: UUID) async throws {
        try await service.deleteBaby(id: id)
    }
}
