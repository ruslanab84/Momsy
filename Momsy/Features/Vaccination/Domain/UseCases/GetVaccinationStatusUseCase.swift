import Foundation

struct GetVaccinationStatusUseCase {
    let repository: any VaccinationRepository

    func execute(birthDate: Date) async -> [VaccinationStatus] {
        let entries = (try? await repository.getAll()) ?? []
        let cal = Calendar.current
        return VaccinationCatalog.items.map { item in
            let dueDate = cal.date(byAdding: .month, value: item.ageMonths, to: birthDate) ?? birthDate
            let entry = entries.first { $0.catalogId == item.id }
            return VaccinationStatus(item: item, entry: entry, dueDate: dueDate)
        }
    }
}
