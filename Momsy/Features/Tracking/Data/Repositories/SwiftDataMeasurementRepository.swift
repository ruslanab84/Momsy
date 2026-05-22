import SwiftData
import Foundation

final class SwiftDataMeasurementRepository: MeasurementRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getAll() async throws -> [MeasurementEntry] {
        let all = try context.fetch(FetchDescriptor<MeasurementRecord>())
        return all.map { $0.toDomain() }.sorted { $0.date > $1.date }
    }

    func add(_ entry: MeasurementEntry) async throws {
        context.insert(MeasurementRecord(entry))
        try context.save()
    }

    func delete(id: UUID) async throws {
        let all = try context.fetch(FetchDescriptor<MeasurementRecord>())
        if let record = all.first(where: { $0.id == id }) {
            context.delete(record)
            try context.save()
        }
    }
}
