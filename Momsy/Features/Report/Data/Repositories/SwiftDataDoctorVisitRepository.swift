import SwiftData
import Foundation

final class SwiftDataDoctorVisitRepository: DoctorVisitRepository {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func getLast() async throws -> DoctorVisit? {
        let all = try context.fetch(FetchDescriptor<DoctorVisitRecord>())
        return all.sorted { $0.date > $1.date }.first?.toDomain()
    }

    func save(_ visit: DoctorVisit) async throws {
        let existing = try context.fetch(FetchDescriptor<DoctorVisitRecord>())
        existing.forEach { context.delete($0) }
        context.insert(DoctorVisitRecord(id: visit.id, date: visit.date))
        try context.save()
    }
}
