import SwiftUI
import Combine

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

    init(getChatHistory: GetChatHistoryUseCase,
         appendMessage: AppendChatMessageUseCase,
         clearChat: ClearChatHistoryUseCase,
         chatService: any AIChatService) {
        self.getChatHistoryUC = getChatHistory
        self.appendMessageUC = appendMessage
        self.clearChatUC = clearChat
        self.chatService = chatService
        Task { await loadHistory() }
    }

    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespaces).isEmpty && !isStreaming
    }

    var babyContext: BabyContext {
        let name = UserDefaults.standard.string(forKey: "babyName") ?? ""
        let interval = UserDefaults.standard.double(forKey: "babyBirthDate")
        let birth = interval > 0 ? Date(timeIntervalSince1970: interval) : Date()
        let weeks = max(0, Calendar.current.dateComponents([.weekOfYear], from: birth, to: Date()).weekOfYear ?? 0)
        let leap = sampleLeaps.first(where: { $0.isCurrent })
        return BabyContext(
            babyName: name.isEmpty ? "Baby" : name,
            ageWeeks: weeks,
            ageMonths: weeks / 4,
            currentLeap: leap?.nameEn ?? "",
            leapDescription: leap?.descriptionEn ?? ""
        )
    }

    func send() {
        let text = draft.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !isStreaming else { return }
        draft = ""
        errorMessage = nil

        let userMsg = ChatMessage(role: .user, content: text)
        messages.append(userMsg)
        Task { try? await appendMessageUC.execute(userMsg) }

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
                try? await appendMessageUC.execute(assistantMsg)
                streamingText = ""
            } catch {
                errorMessage = "Something went wrong. Please try again."
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
}
