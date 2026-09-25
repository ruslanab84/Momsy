import Foundation

struct GetVaccinationStatusUseCase {
    let repository: any VaccinationRepository
    let resolver: any VaccinationScheduleResolving

    func execute(baby: BabyProfile?) async -> [VaccinationStatus] {
        let entries = (try? await repository.getAll()) ?? []
        let cal = Calendar.current
        let birthDate = baby?.birthDate ?? Date()
        let items = resolver.definition(for: baby).items

        // Scheduled vaccinations from the active schedule.
        let catalogStatuses: [VaccinationStatus] = items.map { item in
            let dueDate = item.timing.dueDate(from: birthDate, cal)
            let entry = entries.first { $0.catalogId == item.id && !$0.isCustom }
            return VaccinationStatus(item: item, entry: entry, dueDate: dueDate)
        }

        // Done-marks from another schedule (schedule switched, or a co-parent marked it
        // before the switch) stay visible under "Additional". Unresolvable ids are
        // skipped for display only — the entry itself is never deleted.
        let activeIds = Set(items.map(\.id))
        let foreignStatuses: [VaccinationStatus] = entries
            .filter { !$0.isCustom && !activeIds.contains($0.catalogId) }
            .compactMap { entry in
                guard let resolved = resolver.item(forCatalogId: entry.catalogId) else { return nil }
                let item = VaccinationScheduleItem(id: resolved.item.id, names: resolved.item.names,
                                                   timing: .additional, isOptional: false)
                return VaccinationStatus(item: item, entry: entry, dueDate: entry.doneDate,
                                         originKey: resolved.key)
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

        return catalogStatuses + foreignStatuses + customStatuses
    }
}
