import SwiftData
import Foundation

final class SwiftDataTemperatureRepository: TemperatureRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getAll() async throws -> [TemperatureEntry] {
        let all = try context.fetch(FetchDescriptor<TemperatureRecord>())
        return all.map { $0.toDomain() }.sorted { $0.date > $1.date }
    }

    func getEntries(from: Date, to: Date) async throws -> [TemperatureEntry] {
        let all = try context.fetch(FetchDescriptor<TemperatureRecord>())
        return all.filter { $0.date >= from && $0.date <= to }.map { $0.toDomain() }
    }

    func add(_ entry: TemperatureEntry) async throws {
        context.insert(TemperatureRecord(entry))
        try context.save()
    }

    func delete(id: UUID) async throws {
        let all = try context.fetch(FetchDescriptor<TemperatureRecord>())
        if let record = all.first(where: { $0.id == id }) {
            context.delete(record)
            try context.save()
        }
    }
}
