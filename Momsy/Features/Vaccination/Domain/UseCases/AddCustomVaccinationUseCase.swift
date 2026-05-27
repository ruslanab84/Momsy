import Foundation

struct AddCustomVaccinationUseCase {
    let repository: any VaccinationRepository

    func execute(name: String, date: Date) async {
        // Use a unique negative Int as catalogId so it never clashes with catalog (1–20)
        // and stays unique across multiple custom entries.
        let uniqueId = -abs(UUID().uuidString.hashValue)
        let entry = VaccinationEntry(
            id: UUID(),
            catalogId: uniqueId,
            doneDate: date,
            notes: "",
            customName: name
        )
        try? await repository.save(entry)
    }
}
