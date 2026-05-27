import SwiftData
import Foundation

final class SwiftDataStoolRepository: StoolRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func add(date: Date) async throws {
        context.insert(StoolRecord(date: date))
        try context.save()
    }

    func getEntries(from: Date, to: Date) async throws -> [Date] {
        let all = try context.fetch(FetchDescriptor<StoolRecord>())
        return all
            .filter { $0.date >= from && $0.date <= to }
            .map(\.date)
            .sorted()
    }
}
