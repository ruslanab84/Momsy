import Foundation

final class BabySyncRepository: BabySyncRepositoryProtocol {
    private let service: BabySyncService

    init(service: BabySyncService) {
        self.service = service
    }

    var feedingLogs: AsyncStream<[FeedingLog]> {
        map(service.streamLogs(from: "feedingLogs") as AsyncStream<[FeedingLogDTO]>) { $0.domain }
    }

    var sleepLogs: AsyncStream<[SleepLog]> {
        map(service.streamLogs(from: "sleepLogs") as AsyncStream<[SleepLogDTO]>) { $0.domain }
    }

    var diaperLogs: AsyncStream<[DiaperLog]> {
        map(service.streamLogsByField(from: "diaperLogs", orderField: "loggedAt") as AsyncStream<[DiaperLogDTO]>) { $0.domain }
    }

    func addFeedingLog(_ log: FeedingLog) async throws {
        try await service.addLog(FeedingLogDTO(from: log), to: "feedingLogs")
    }

    func addSleepLog(_ log: SleepLog) async throws {
        try await service.addLog(SleepLogDTO(from: log), to: "sleepLogs")
    }

    func addDiaperLog(_ log: DiaperLog) async throws {
        try await service.addLog(DiaperLogDTO(from: log), to: "diaperLogs")
    }

    func addSymptomLog(_ log: SymptomLog) async throws {
        try await service.addLog(SymptomLogDTO(from: log), to: "symptomLogs")
    }

    func addQuickEventLog(_ log: QuickEventLog) async throws {
        try await service.addLog(QuickEventLogDTO(from: log), to: "quickLogs")
    }

    func addDiaryLog(_ log: DiaryLog) async throws {
        try await service.addLog(DiaryLogDTO(from: log), to: "diaryLogs")
    }

    func addMeasurementLog(_ log: MeasurementLog) async throws {
        try await service.addLog(MeasurementLogDTO(from: log), to: "measurementLogs")
    }

    func addVaccinationLog(_ log: VaccinationLog) async throws {
        try await service.addLog(VaccinationLogDTO(from: log), to: "vaccinationLogs")
    }

    func fetchTodayFeedings() async throws -> [FeedingLog] {
        let dtos: [FeedingLogDTO] = try await service.fetchToday(from: "feedingLogs")
        return dtos.map(\.domain)
    }

    func fetchTodaySleep() async throws -> [SleepLog] {
        let dtos: [SleepLogDTO] = try await service.fetchToday(from: "sleepLogs")
        return dtos.map(\.domain)
    }

    private func map<DTO: Decodable, Model>(
        _ base: AsyncStream<[DTO]>,
        transform: @escaping (DTO) -> Model
    ) -> AsyncStream<[Model]> {
        AsyncStream { continuation in
            Task {
                for await items in base {
                    continuation.yield(items.map(transform))
                }
                continuation.finish()
            }
        }
    }
}
