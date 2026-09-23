import SwiftUI
import Combine

// MARK: - Supporting Types

struct Symptom: Identifiable {
    let id: String
    let label: String
    let tone: Color
    let icon: String
    var isOn: Bool
}

// MARK: - ViewModel

@MainActor
final class SymptomViewModel: ObservableObject {
    @Published var isOnIDs: Set<String> = []
    @Published var severity: SymptomSeverity = .mild
    @Published var note: String = "" {
        didSet { if note.count > Self.noteLimit { note = String(note.prefix(Self.noteLimit)) } }
    }
    @Published var diaryLogged = false

    private let appState: AppState
    private let addDiaryEntry: AddDiaryEntryUseCase
    private let syncRepo: any BabySyncRepositoryProtocol
    private var lm: LocalizationManager { .shared }

    init(appState: AppState,
         addDiaryEntry: AddDiaryEntryUseCase,
         syncRepo: any BabySyncRepositoryProtocol) {
        self.appState = appState
        self.addDiaryEntry = addDiaryEntry
        self.syncRepo = syncRepo
    }

    var displayName: String { appState.displayName }
    var activeCount: Int { isOnIDs.count }
    var canSave: Bool {
        !isOnIDs.isEmpty || !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static let noteLimit = 500

    var symptoms: [Symptom] {
        [
            Symptom(id: "fever",  label: lm.strings.symptomLabelTemperature,
                    tone: .bbCoral,     icon: "🌡", isOn: isOnIDs.contains("fever")),
            Symptom(id: "rash",   label: lm.strings.symptomLabelRash,
                    tone: .bbRose,      icon: "◌",  isOn: isOnIDs.contains("rash")),
            Symptom(id: "vomit",  label: lm.strings.symptomLabelVomiting,
                    tone: .bbButter,    icon: "↑",  isOn: isOnIDs.contains("vomit")),
            Symptom(id: "cry",    label: lm.strings.symptomLabelLongCrying,
                    tone: .bbLilac,     icon: "♪",  isOn: isOnIDs.contains("cry")),
            Symptom(id: "stool",  label: lm.strings.symptomLabelStool,
                    tone: .bbMint,      icon: "⬭",  isOn: isOnIDs.contains("stool")),
            Symptom(id: "eat",    label: lm.strings.symptomLabelRefusingFood,
                    tone: .bbSky,       icon: "✕",  isOn: isOnIDs.contains("eat")),
            Symptom(id: "sleep",  label: lm.strings.symptomLabelSleepIssues,
                    tone: .bbLilac,     icon: "☾",  isOn: isOnIDs.contains("sleep")),
            Symptom(id: "other",  label: lm.strings.symptomLabelOther,
                    tone: .bbCreamSoft, icon: "+",  isOn: isOnIDs.contains("other")),
        ]
    }

    func toggleSymptom(_ id: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            if isOnIDs.contains(id) { isOnIDs.remove(id) }
            else { isOnIDs.insert(id) }
        }
    }

    func reset() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isOnIDs = []
            note = ""
            severity = .mild
        }
    }

    /// Records only what the parent observed — no computed assessment.
    /// Returns the persistence task so tests can await the writes.
    @discardableResult
    func logToDiary() -> Task<Void, Never>? {
        guard canSave else { return nil }
        let labels = symptoms.filter(\.isOn).map(\.label).joined(separator: ", ")
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = [labels, trimmedNote].filter { !$0.isEmpty }.joined(separator: " — ")
        let item = StoredDiaryItem(kind: .note, text: "🩺 \(description)")
        let symptomLog = SymptomLog(
            id: UUID().uuidString,
            loggedAt: Date(),
            description: description,
            severity: severity,
            addedBy: "",
            addedByName: ""
        )

        // Clear inputs immediately so a double tap can't write the same entry twice.
        reset()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { diaryLogged = true }
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation { diaryLogged = false }
        }
        return Task {
            _ = try? await addDiaryEntry.execute(item)
            try? await syncRepo.addSymptomLog(symptomLog)
        }
    }
}
