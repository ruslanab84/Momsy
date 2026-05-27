import SwiftData
import Foundation

final class SwiftDataWaterIntakeRepository: WaterIntakeRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func add(_ entry: WaterIntakeEntry) async throws {
        context.insert(WaterIntakeRecord(entry))
        try context.save()
    }

    func getEntries(from: Date, to: Date) async throws -> [WaterIntakeEntry] {
        let all = try context.fetch(FetchDescriptor<WaterIntakeRecord>())
        return all
            .map { $0.toDomain() }
            .filter { $0.date >= from && $0.date <= to }
            .sorted { $0.date < $1.date }
    }
}
