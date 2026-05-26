import SwiftUI
import Combine
import FirebaseAI

@MainActor
final class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var draft = ""
    @Published var isStreaming = false
    @Published var streamingText = ""
    @Published var errorMessage: String? = nil

    private let getChatHistoryUC: GetChatHistoryUseCase
    private let appendMessageUC: AppendChatMessageUseCase
    private let clearChatUC: ClearChatHistoryUseCase
    private let chatService: any AIChatService
    private let appState: AppState
    private let getLeapsUC: GetLeapsUseCase
    private var leapProgress: [LeapProgress] = []
    private var lastUserText = ""

    init(getChatHistory: GetChatHistoryUseCase,
         appendMessage: AppendChatMessageUseCase,
         clearChat: ClearChatHistoryUseCase,
         chatService: any AIChatService,
         appState: AppState,
         getLeaps: GetLeapsUseCase) {
        self.getChatHistoryUC = getChatHistory
        self.appendMessageUC = appendMessage
        self.clearChatUC = clearChat
        self.chatService = chatService
        self.appState = appState
        self.getLeapsUC = getLeaps
        Task { await loadHistory() }
        Task { await loadLeapProgress() }
    }

    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespaces).isEmpty && !isStreaming
    }

    var babyContext: BabyContext {
        let profile = appState.babyProfile
        let name = profile?.name ?? ""
        let birth = profile?.birthDate ?? Date()
        let weeks = max(0, Calendar.current.dateComponents([.weekOfYear], from: birth, to: Date()).weekOfYear ?? 0)
        let completedIds = Set(leapProgress.filter(\.isDone).map(\.id))
        // Current leap: first not-yet-done leap at or near baby's age
        let leap = DevelopmentLeap.catalog.first(where: { !completedIds.contains($0.id) && $0.week <= weeks + 4 })
            ?? DevelopmentLeap.catalog.last(where: { $0.week <= weeks })
        return BabyContext(
            babyName: name.isEmpty ? "Baby" : name,
            ageWeeks: weeks,
            ageMonths: weeks / 4,
            currentLeap: leap?.nameEn ?? "",
            leapDescription: leap?.descriptionEn ?? ""
        )
    }

    func retry() {
        guard !isStreaming, !lastUserText.isEmpty else { return }
        if let last = messages.last, last.role == .user { messages.removeLast() }
        draft = lastUserText
        send()
    }

    func send() {
        let text = draft.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !isStreaming else { return }
        lastUserText = text
        draft = ""
        errorMessage = nil

        let userMsg = ChatMessage(role: .user, content: text)
        messages.append(userMsg)
        Task {
            do { try await appendMessageUC.execute(userMsg) }
            catch { errorMessage = error.localizedDescription }
        }

        isStreaming = true
        streamingText = ""

        let historySnapshot = Array(messages.dropLast().suffix(20))

        Task {
            do {
                let responseStream = chatService.stream(
                    userText: text,
                    history: historySnapshot,
                    context: babyContext
                )
                for try await chunk in responseStream {
                    streamingText += chunk
                }
                let assistantMsg = ChatMessage(role: .assistant, content: streamingText)
                messages.append(assistantMsg)
                do { try await appendMessageUC.execute(assistantMsg) }
                catch { errorMessage = friendlyError(error) }
                streamingText = ""
            } catch {
                errorMessage = friendlyError(error)
                streamingText = ""
            }
            isStreaming = false
        }
    }

    func clear() {
        messages = []
        streamingText = ""
        errorMessage = nil
        Task { try? await clearChatUC.execute() }
    }

    private func loadHistory() async {
        if let history = try? await getChatHistoryUC.execute() {
            messages = history
        }
    }

    private func loadLeapProgress() async {
        if let progress = try? await getLeapsUC.execute() {
            leapProgress = progress
        }
    }

    private func friendlyError(_ error: Error) -> String {
        let lm = LocalizationManager.shared
        if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
            return lm.strings.aiChatErrorNoInternet
        }
        // Unwrap BackendError HTTP code for specific messages
        if let genError = error as? GenerateContentError,
           case .internalError(let underlying) = genError,
           (underlying as NSError).code == 429 {
            return lm.strings.aiChatErrorBusy
        }
        return lm.strings.aiChatErrorGeneric
    }
}
