import SwiftUI
import Combine

@MainActor
final class VaccinationViewModel: ObservableObject {
    @Published private(set) var statuses: [VaccinationStatus] = []
    @Published var showMarkDone: VaccinationStatus? = nil
    @Published var showAddCustom = false
    @Published var doneDate = Date()

    private let getStatus: GetVaccinationStatusUseCase
    private let markDone: MarkVaccinationDoneUseCase
    private let unmark: UnmarkVaccinationUseCase
    private let addCustom: AddCustomVaccinationUseCase
    private let pushNotifications: any PushNotificationServiceProtocol
    private let appState: AppState

    init(
        getStatus: GetVaccinationStatusUseCase,
        markDone: MarkVaccinationDoneUseCase,
        unmark: UnmarkVaccinationUseCase,
        addCustom: AddCustomVaccinationUseCase,
        pushNotifications: any PushNotificationServiceProtocol,
        appState: AppState
    ) {
        self.getStatus = getStatus
        self.markDone = markDone
        self.unmark = unmark
        self.addCustom = addCustom
        self.pushNotifications = pushNotifications
        self.appState = appState
    }

    var grouped: [(ageMonths: Int, label: String, items: [VaccinationStatus])] {
        let lm = LocalizationManager.shared
        let dict = Dictionary(grouping: statuses, by: { $0.item.ageMonths })
        return dict.keys.sorted().map { months in
            let label = ageLabel(months: months, lang: lm.current)
            return (ageMonths: months, label: label, items: dict[months] ?? [])
        }
    }

    func load() async {
        let birth = appState.babyProfile?.birthDate ?? Date()
        statuses = await getStatus.execute(birthDate: birth)
    }

    func confirmDone(_ status: VaccinationStatus) async {
        await markDone.execute(catalogId: status.item.id, doneDate: doneDate)
        pushNotifications.cancelVaccinationReminder(catalogId: status.item.id)
        await load()
        showMarkDone = nil
    }

    func undone(_ status: VaccinationStatus) async {
        guard let entry = status.entry else { return }
        await unmark.execute(entryId: entry.id)
        // Only reschedule reminders for catalog vaccinations, not custom ones
        if !entry.isCustom {
            let lm = LocalizationManager.shared
            let name = lm.current == .english ? status.item.nameEN
                     : lm.current == .german  ? status.item.nameDE
                     : status.item.nameRU
            pushNotifications.scheduleVaccinationReminder(
                catalogId: status.item.id,
                name: name,
                dueDate: status.dueDate
            )
        }
        await load()
    }

    func saveCustomVaccination(name: String, date: Date) async {
        await addCustom.execute(name: name, date: date)
        await load()
        showAddCustom = false
    }

    private func ageLabel(months: Int, lang: Language) -> String {
        switch lang {
        case .english, .spanish, .portuguese:
            if months == 0   { return "Birth" }
            if months == 999 { return "Additional" }
            return months == 1 ? "1 month" : "\(months) months"
        case .german:
            if months == 0   { return "Geburt" }
            if months == 999 { return "Weitere" }
            return months == 1 ? "1 Monat" : "\(months) Monate"
        case .russian:
            if months == 0   { return "Рождение" }
            if months == 999 { return "Дополнительные" }
            if months == 1   { return "1 месяц" }
            if months < 5    { return "\(months) месяца" }
            return "\(months) месяцев"
        }
    }
}
