import Foundation

struct MarkVaccinationDoneUseCase {
    let repository: any VaccinationRepository

    @discardableResult
    func execute(catalogId: Int, doneDate: Date, notes: String = "") async -> VaccinationEntry {
        let entry = VaccinationEntry(id: UUID(), catalogId: catalogId, doneDate: doneDate, notes: notes)
        try? await repository.save(entry)
        return entry
    }
}
