import Foundation

struct GetLastDoctorVisitUseCase {
    let repository: any DoctorVisitRepository
    func execute() async throws -> DoctorVisit? {
        try await repository.getLast()
    }
}

struct SaveDoctorVisitUseCase {
    let repository: any DoctorVisitRepository
    func execute(_ date: Date) async throws {
        try await repository.save(DoctorVisit(id: UUID(), date: date))
    }
}
