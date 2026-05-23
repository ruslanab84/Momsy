import Foundation

struct UnmarkVaccinationUseCase {
    let repository: any VaccinationRepository

    func execute(entryId: UUID) async {
        try? await repository.delete(id: entryId)
    }
}
