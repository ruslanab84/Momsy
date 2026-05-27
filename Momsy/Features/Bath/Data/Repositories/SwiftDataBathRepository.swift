import SwiftData
import Foundation

final class SwiftDataBathRepository: BathRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func start() async throws -> BathEntry {
        let entry = BathEntry(startDate: Date())
        context.insert(BathRecord(entry))
        try context.save()
        return entry
    }

    func stop(_ entry: BathEntry) async throws -> BathEntry {
        var finished = entry
        finished.endDate = Date()
        let all = try context.fetch(FetchDescriptor<BathRecord>())
        if let record = all.first(where: { $0.id == entry.id }) {
            record.endDate = finished.endDate
            try context.save()
        }
        return finished
    }

    func getEntries(from: Date, to: Date) async throws -> [BathEntry] {
        let all = try context.fetch(FetchDescriptor<BathRecord>())
        return all.filter { $0.startDate >= from && $0.startDate < to }.map { $0.toDomain() }
    }

    func add(_ entry: BathEntry) async throws {
        context.insert(BathRecord(entry))
        try context.save()
    }
}
