import Foundation

protocol DoctorVisitRepository {
    func getLast() async throws -> DoctorVisit?
    func save(_ visit: DoctorVisit) async throws
    func upsert(_ visits: [DoctorVisit]) async throws
}
