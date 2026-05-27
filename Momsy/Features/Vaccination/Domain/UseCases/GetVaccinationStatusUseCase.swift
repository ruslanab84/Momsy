import Foundation

struct GetVaccinationStatusUseCase {
    let repository: any VaccinationRepository

    func execute(birthDate: Date) async -> [VaccinationStatus] {
        let entries = (try? await repository.getAll()) ?? []
        let cal = Calendar.current

        // Standard catalog vaccinations
        let catalogStatuses: [VaccinationStatus] = VaccinationCatalog.items.map { item in
            let dueDate = cal.date(byAdding: .month, value: item.ageMonths, to: birthDate) ?? birthDate
            let entry = entries.first { $0.catalogId == item.id && !$0.isCustom }
            return VaccinationStatus(item: item, entry: entry, dueDate: dueDate)
        }

        // Custom (user-added) vaccinations — each has a synthetic VaccinationScheduleItem
        let customStatuses: [VaccinationStatus] = entries
            .filter { $0.isCustom }
            .map { entry in
                let name = entry.customName ?? ""
                let syntheticItem = VaccinationScheduleItem(
                    id: entry.catalogId,
                    nameEN: name, nameRU: name, nameDE: name,
                    ageMonths: 999,
                    isOptional: false
                )
                return VaccinationStatus(item: syntheticItem, entry: entry, dueDate: entry.doneDate)
            }

        return catalogStatuses + customStatuses
    }
}
