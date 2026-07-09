import SwiftUI
import Combine

// MARK: - Supporting Types

struct Symptom: Identifiable {
    let id: String
    let label: String
    let sub: String
    let tone: Color
    let icon: String
    var isOn: Bool
}

enum SymptomUrgency { case calm, watchful, urgent }

struct SymptomResult: Equatable {
    let title: String
    let detail: String
    let warning: String
    let urgency: SymptomUrgency

    static func == (lhs: SymptomResult, rhs: SymptomResult) -> Bool {
        lhs.title == rhs.title
    }

    var cardBg: Color {
        switch urgency {
        case .calm, .watchful: return Color.bbButter.opacity(0.8)
        case .urgent:          return Color.bbRose.opacity(0.7)
        }
    }
    var warningColor: Color {
        switch urgency {
        case .calm:            return Color.bbMintDeep
        case .watchful, .urgent: return Color.bbCoralDeep
        }
    }
    var urgencyIcon: String {
        switch urgency {
        case .calm:     return "checkmark.circle.fill"
        case .watchful: return "questionmark.circle.fill"
        case .urgent:   return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - ViewModel

@MainActor
final class SymptomViewModel: ObservableObject {
    @Published var isOnIDs: Set<String> = ["fever", "cry", "sleep"]
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

    var symptoms: [Symptom] {
        [
            Symptom(id: "fever",  label: lm.strings.symptomLabelTemperature,
                    sub: "37.8°C · 40 \(lm.strings.unitMin)",                     tone: .bbCoral,     icon: "🌡", isOn: isOnIDs.contains("fever")),
            Symptom(id: "rash",   label: lm.strings.symptomLabelRash,
                    sub: lm.strings.symptomSubChooseArea,                          tone: .bbRose,      icon: "◌",  isOn: isOnIDs.contains("rash")),
            Symptom(id: "vomit",  label: lm.strings.symptomLabelVomiting,
                    sub: lm.strings.symptomSubNone,                                tone: .bbButter,    icon: "↑",  isOn: isOnIDs.contains("vomit")),
            Symptom(id: "cry",    label: lm.strings.symptomLabelLongCrying,
                    sub: "> 1 \(lm.strings.unitHr)",                               tone: .bbLilac,     icon: "♪",  isOn: isOnIDs.contains("cry")),
            Symptom(id: "stool",  label: lm.strings.symptomLabelStool,
                    sub: lm.strings.symptomSubStoolNormal,                         tone: .bbMint,      icon: "⬭",  isOn: isOnIDs.contains("stool")),
            Symptom(id: "eat",    label: lm.strings.symptomLabelRefusingFood,
                    sub: lm.strings.symptomSubSelect,                              tone: .bbSky,       icon: "✕",  isOn: isOnIDs.contains("eat")),
            Symptom(id: "sleep",  label: lm.strings.symptomLabelSleepIssues,
                    sub: lm.strings.symptomSubShortPhases,                         tone: .bbLilac,     icon: "☾",  isOn: isOnIDs.contains("sleep")),
            Symptom(id: "other",  label: lm.strings.symptomLabelOther,
                    sub: lm.strings.symptomSubDescribe,                            tone: .bbCreamSoft, icon: "+",  isOn: isOnIDs.contains("other")),
        ]
    }

    func urgencyLabel(for urgency: SymptomUrgency) -> String {
        switch urgency {
        case .calm:     return lm.strings.symptomUrgencyWatching
        case .watchful: return lm.strings.symptomUrgencyLikely
        case .urgent:   return lm.strings.symptomUrgencySeeDoctor
        }
    }

    var result: SymptomResult {
        let on = isOnIDs

        if on.isEmpty {
            return SymptomResult(
                title: lm.strings.symptomResultNothingTitle,
                detail: lm.strings.symptomResultNothingDetail,
                warning: "", urgency: .calm
            )
        }

        let hasFever = on.contains("fever")
        let hasRash   = on.contains("rash")
        let hasVomit  = on.contains("vomit")
        let hasCry    = on.contains("cry")
        let hasSleep  = on.contains("sleep")
        let hasEat    = on.contains("eat")

        if hasFever && hasRash {
            return SymptomResult(
                title: lm.strings.symptomResultExamTitle,
                detail: lm.strings.symptomResultExamDetail,
                warning: lm.strings.symptomResultExamWarning,
                urgency: .urgent
            )
        }
        if hasVomit && hasFever {
            return SymptomResult(
                title: lm.strings.symptomResultGastroTitle,
                detail: lm.strings.symptomResultGastroDetail,
                warning: lm.strings.symptomResultGastroWarning,
                urgency: .urgent
            )
        }
        if hasVomit {
            return SymptomResult(
                title: lm.strings.symptomResultDigestTitle,
                detail: lm.strings.symptomResultDigestDetail,
                warning: lm.strings.symptomResultDigestWarning,
                urgency: .watchful
            )
        }
        if hasFever && hasCry && hasSleep {
            return SymptomResult(
                title: lm.strings.symptomResultTeethTitle,
                detail: lm.strings.symptomResultTeethDetail,
                warning: lm.strings.symptomResultTeethWarning,
                urgency: .watchful
            )
        }
        if hasFever && hasEat {
            return SymptomResult(
                title: lm.strings.symptomResultArviTitle,
                detail: lm.strings.symptomResultArviDetail,
                warning: lm.strings.symptomResultArviWarning,
                urgency: .watchful
            )
        }
        if hasFever {
            return SymptomResult(
                title: lm.strings.symptomResultViralTitle,
                detail: lm.strings.symptomResultViralDetail,
                warning: lm.strings.symptomResultViralWarning,
                urgency: .watchful
            )
        }
        if hasCry && hasSleep {
            return SymptomResult(
                title: lm.strings.symptomResultLeapTitle,
                detail: lm.strings.symptomResultLeapDetail,
                warning: lm.strings.symptomResultLeapWarning,
                urgency: .calm
            )
        }
        if hasCry {
            return SymptomResult(
                title: lm.strings.symptomResultCryingTitle,
                detail: lm.strings.symptomResultCryingDetail,
                warning: lm.strings.symptomResultCryingWarning,
                urgency: .calm
            )
        }
        return SymptomResult(
            title: lm.strings.symptomResultWatchingTitle,
            detail: lm.strings.symptomResultWatchingDetail,
            warning: lm.strings.symptomResultWatchingWarning,
            urgency: .calm
        )
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
        }
    }

    func logToDiary() {
        let symptomLabels = symptoms.filter(\.isOn).map(\.label).joined(separator: ", ")
        let currentResult = result
        let noteText = symptomLabels.isEmpty
            ? "🩺 \(currentResult.title)"
            : "🩺 \(currentResult.title)\n\(symptomLabels)"
        let item = StoredDiaryItem(kind: .note, text: noteText)

        let symptomLog = SymptomLog(
            id: UUID().uuidString,
            loggedAt: Date(),
            description: symptomLabels.isEmpty ? currentResult.title
                                              : "\(currentResult.title): \(symptomLabels)",
            severity: Self.severity(for: currentResult.urgency),
            addedBy: "",
            addedByName: ""
        )

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { diaryLogged = true }
        Task {
            _ = try? await addDiaryEntry.execute(item)
            try? await syncRepo.addSymptomLog(symptomLog)
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation { diaryLogged = false }
        }
    }

    private static func severity(for urgency: SymptomUrgency) -> SymptomSeverity {
        switch urgency {
        case .calm:     return .mild
        case .watchful: return .moderate
        case .urgent:   return .high
        }
    }
}
