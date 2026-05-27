import SwiftUI
import Combine

@MainActor
final class VitaminViewModel: ObservableObject {

    @Published var vitaminName: String = ""
    @Published var todayEntries: [QuickLogEntry] = []

    var onEntrySaved: (() -> Void)?

    private let quickLogRepo: QuickLogRepository

    init(quickLogRepo: QuickLogRepository) {
        self.quickLogRepo = quickLogRepo
        loadToday()
    }

    func loadToday() {
        todayEntries = quickLogRepo.load().filter { $0.kind == .vitamin }
    }

    func add() {
        let name = vitaminName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let label = LocalizationManager.shared.strings.vitaminAdded(name: name)
        let entry = QuickLogEntry(id: UUID(), time: Date(), kind: .vitamin, label: label)
        quickLogRepo.append(entry)
        todayEntries.insert(entry, at: 0)
        vitaminName = ""
        onEntrySaved?()
    }
}
