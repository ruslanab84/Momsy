import SwiftUI
import Combine

@MainActor
final class VitaminViewModel: ObservableObject {

    @Published var vitaminName: String = ""
    @Published var todayEntries: [QuickLogEntry] = []
    @Published private(set) var categories: [String] = []

    var onEntrySaved: (() -> Void)?

    private let quickLogRepo: QuickLogRepository
    private let vitaminRepo: any VitaminRepository

    init(quickLogRepo: QuickLogRepository, vitaminRepo: any VitaminRepository) {
        self.quickLogRepo = quickLogRepo
        self.vitaminRepo = vitaminRepo
        loadToday()
    }

    func loadToday() {
        todayEntries = quickLogRepo.load().filter { $0.kind == .vitamin }
        categories = vitaminRepo.loadCategories()
    }

    func addCategory(_ name: String) {
        let category = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !category.isEmpty else { return }

        if let existing = categories.first(where: { $0.caseInsensitiveCompare(category) == .orderedSame }) {
            vitaminName = existing
            return
        }

        categories.append(category)
        vitaminRepo.saveCategories(categories)
        vitaminName = category
    }

    func selectCategory(_ category: String) {
        vitaminName = category
    }

    func add() {
        let name = vitaminName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let label = LocalizationManager.shared.strings.vitaminAdded(name: name)
        let entry = QuickLogEntry(id: UUID(), time: Date(), kind: .vitamin, label: label)
        quickLogRepo.append(entry)
        Task { try? await vitaminRepo.add(VitaminEntry(id: entry.id, date: entry.time, label: label)) }
        pushVitaminToFirestore(entry)
        todayEntries.insert(entry, at: 0)
        vitaminName = ""
        onEntrySaved?()
    }

    private func pushVitaminToFirestore(_ entry: QuickLogEntry) {
        guard FamilyManager.shared.familyId != nil else { return }
        let log = QuickEventLog(
            id: entry.id.uuidString,
            kind: entry.kind.rawValue,
            loggedAt: entry.time,
            label: entry.label,
            addedBy: "",
            addedByName: ""
        )
        Task {
            try? await BabySyncService().setLog(QuickEventLogDTO(from: log), id: log.id, to: "vitaminLogs")
        }
    }
}
