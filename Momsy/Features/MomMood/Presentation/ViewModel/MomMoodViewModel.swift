import SwiftUI
import Combine

enum MomMoodActiveSheet: Identifiable {
    case checkin, epds
    var id: String { switch self { case .checkin: "checkin"; case .epds: "epds" } }
}

@MainActor
final class MomMoodViewModel: ObservableObject {
    @Published var entries: [MomMoodEntry] = []
    @Published var activeSheet: MomMoodActiveSheet? = nil
    @Published var saveError: String?

    private let repository: any MomMoodRepository

    init(repository: any MomMoodRepository) {
        self.repository = repository
    }

    func loadHistory() async {
        let to = Date()
        let from = Calendar.current.date(byAdding: .day, value: -30, to: to) ?? to
        do {
            entries = try await repository.getEntries(from: from, to: to)
        } catch {
            saveError = error.localizedDescription
        }
    }

    func saveCheckin(mood: Int, energy: Int, note: String) async {
        let entry = MomMoodEntry(id: UUID(), date: Date(), mood: mood, energy: energy,
                                 note: note, epdsScore: nil)
        do {
            try await repository.add(entry)
            await loadHistory()
        } catch {
            saveError = error.localizedDescription
        }
    }

    func saveEPDS(scores: [Int], mood: Int, energy: Int) async {
        let total = Self.epdsScore(for: scores)
        let entry = MomMoodEntry(id: UUID(), date: Date(), mood: mood, energy: energy,
                                 note: "", epdsScore: total)
        do {
            try await repository.add(entry)
            await loadHistory()
        } catch {
            saveError = error.localizedDescription
        }
    }

    static func epdsScore(for answers: [Int]) -> Int {
        answers.reduce(0, +)
    }

    static func requiresEPDSSafetySupport(for answers: [Int]) -> Bool {
        answers.indices.contains(9) && answers[9] > 0
    }

    var latestEPDSScore: Int? {
        entries.first(where: { $0.epdsScore != nil })?.epdsScore
    }

    var lastEPDSDate: Date? {
        entries.first(where: { $0.epdsScore != nil })?.date
    }

    var epdsRiskColor: Color {
        guard let score = latestEPDSScore else { return .bbMint }
        if score >= 13 { return .bbCoral }
        if score >= 10 { return .bbButter }
        return .bbMint
    }

    var shouldPromptEPDS: Bool {
        guard let lastDate = lastEPDSDate else { return true }
        return Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0 >= 7
    }
}
