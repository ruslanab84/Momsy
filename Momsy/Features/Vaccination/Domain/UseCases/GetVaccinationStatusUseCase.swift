import Foundation

struct GetVaccinationStatusUseCase {
    let repository: any VaccinationRepository

    func execute(birthDate: Date) async -> [VaccinationStatus] {
        let entries = (try? await repository.getAll()) ?? []
        let cal = Calendar.current
        let items = VaccinationScheduleProvider.shared.items()

        // Scheduled vaccinations from the active schedule.
        let catalogStatuses: [VaccinationStatus] = items.map { item in
            let dueDate = item.timing.dueDate(from: birthDate, cal)
            let entry = entries.first { $0.catalogId == item.id && !$0.isCustom }
            return VaccinationStatus(item: item, entry: entry, dueDate: dueDate)
        }

        // Custom (user-added) vaccinations — each has a synthetic schedule item.
        let customStatuses: [VaccinationStatus] = entries
            .filter { $0.isCustom }
            .map { entry in
                let name = entry.customName ?? ""
                let syntheticItem = VaccinationScheduleItem(
                    id: entry.catalogId,
                    names: [.english: name],
                    timing: .additional,
                    isOptional: false
                )
                return VaccinationStatus(item: syntheticItem, entry: entry, dueDate: entry.doneDate)
            }

        return catalogStatuses + customStatuses
    }
}
