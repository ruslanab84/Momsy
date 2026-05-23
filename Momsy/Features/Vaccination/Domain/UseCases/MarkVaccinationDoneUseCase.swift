import Foundation

struct MarkVaccinationDoneUseCase {
    let repository: any VaccinationRepository

    func execute(catalogId: Int, doneDate: Date, notes: String = "") async {
        let entry = VaccinationEntry(id: UUID(), catalogId: catalogId, doneDate: doneDate, notes: notes)
        try? await repository.save(entry)
    }
}
