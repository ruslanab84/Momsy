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

    var grouped: [(timing: VaccinationTiming, label: String, items: [VaccinationStatus])] {
        let lm = LocalizationManager.shared
        let dict = Dictionary(grouping: statuses, by: { $0.item.timing })
        return dict.keys.sorted { $0.sortKeyDays < $1.sortKeyDays }.map { timing in
            (timing: timing, label: timing.label(lm.current), items: dict[timing] ?? [])
        }
    }

    func load() async {
        let birth = appState.babyProfile?.birthDate ?? Date()
        statuses = await getStatus.execute(birthDate: birth)
    }

    func confirmDone(_ status: VaccinationStatus) async {
        let entry = await markDone.execute(catalogId: status.item.id, doneDate: doneDate)
        pushNotifications.cancelVaccinationReminder(catalogId: status.item.id)
        let vName = status.item.name(for: LocalizationManager.shared.current)
        pushVaccinationToFirestore(entry: entry, vaccineName: vName)
        await load()
        showMarkDone = nil
    }

    func undone(_ status: VaccinationStatus) async {
        guard let entry = status.entry else { return }
        await unmark.execute(entryId: entry.id)
        // Only reschedule reminders for catalog vaccinations, not custom ones
        if !entry.isCustom {
            pushNotifications.scheduleVaccinationReminder(
                catalogId: status.item.id,
                name: status.item.name(for: LocalizationManager.shared.current),
                dueDate: status.dueDate
            )
        }
        await load()
    }

    func saveCustomVaccination(name: String, date: Date) async {
        let entry = await addCustom.execute(name: name, date: date)
        pushVaccinationToFirestore(entry: entry, vaccineName: name)
        await load()
        showAddCustom = false
    }

    private func pushVaccinationToFirestore(entry: VaccinationEntry, vaccineName: String) {
        guard FamilyManager.shared.familyId != nil else { return }
        let uid  = UserDefaults.standard.string(forKey: "uid") ?? ""
        let name = UserDefaults.standard.string(forKey: "displayName") ?? ""
        let log = VaccinationLog(
            id: entry.id.uuidString, catalogId: entry.catalogId,
            doneDate: entry.doneDate, vaccineName: vaccineName,
            notes: entry.notes, addedBy: uid, addedByName: name
        )
        Task { try? await BabySyncService().setLog(VaccinationLogDTO(from: log), id: log.id, to: "vaccinationLogs") }
    }
}
