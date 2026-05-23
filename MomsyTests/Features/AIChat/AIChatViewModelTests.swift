import Testing
@testable import Momsy
import Foundation

@Suite("AIChatViewModel", .serialized)
@MainActor
struct AIChatViewModelTests {

    func makeVM(
        chatRepo: MockChatRepository = MockChatRepository(),
        chatService: MockAIChatService = MockAIChatService(),
        leapsRepo: MockLeapsRepository = MockLeapsRepository(),
        profile: BabyProfile? = nil
    ) async throws -> AIChatViewModel {
        let state = makeAppState(profile: profile)
        let vm = AIChatViewModel(
            getChatHistory: GetChatHistoryUseCase(repository: chatRepo),
            appendMessage: AppendChatMessageUseCase(repository: chatRepo),
            clearChat: ClearChatHistoryUseCase(repository: chatRepo),
            chatService: chatService,
            appState: state,
            getLeaps: GetLeapsUseCase(repository: leapsRepo)
        )
        try await Task.sleep(nanoseconds: 50_000_000)
        return vm
    }

    // MARK: - send

    @Test("send() appends user message immediately")
    func sendAppendsUserMessage() async throws {
        let vm = try await makeVM()
        vm.draft = "Hello"
        vm.send()
        #expect(vm.messages.count == 1)
        #expect(vm.messages[0].role == .user)
        #expect(vm.messages[0].content == "Hello")
    }

    @Test("send() clears draft after sending")
    func sendClearsDraft() async throws {
        let vm = try await makeVM()
        vm.draft = "Hello"
        vm.send()
        #expect(vm.draft.isEmpty)
    }

    @Test("send() sets isStreaming = true immediately")
    func sendSetsIsStreaming() async throws {
        let vm = try await makeVM()
        vm.draft = "Hello"
        vm.send()
        #expect(vm.isStreaming)
    }

    @Test("send() ignores empty draft")
    func sendIgnoresEmptyDraft() async throws {
        let vm = try await makeVM()
        vm.draft = "   "
        vm.send()
        #expect(vm.messages.isEmpty)
        #expect(!vm.isStreaming)
    }

    // MARK: - stream

    @Test("send() appends assistant message after stream completes")
    func sendAppendsAssistantMessage() async throws {
        let service = MockAIChatService()
        service.chunks = ["Hi", " there"]
        let vm = try await makeVM(chatService: service)
        vm.draft = "Hello"
        vm.send()
        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(vm.messages.count == 2)
        #expect(vm.messages[1].role == .assistant)
        #expect(vm.messages[1].content == "Hi there")
    }

    @Test("send() clears isStreaming after stream completes")
    func sendClearsStreamingAfterCompletion() async throws {
        let vm = try await makeVM()
        vm.draft = "Hello"
        vm.send()
        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(!vm.isStreaming)
    }

    @Test("send() sets errorMessage on stream failure")
    func sendSetsErrorOnFailure() async throws {
        let service = MockAIChatService()
        service.shouldThrow = true
        let vm = try await makeVM(chatService: service)
        vm.draft = "Hello"
        vm.send()
        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(vm.errorMessage != nil)
        #expect(!vm.isStreaming)
    }

    @Test("send() does nothing when already streaming")
    func sendBlockedDuringStream() async throws {
        let vm = try await makeVM()
        vm.draft = "First"
        vm.send()
        vm.draft = "Second"
        vm.send()
        #expect(vm.messages.count == 1)
    }

    // MARK: - clear

    @Test("clear() empties messages")
    func clearEmptiesMessages() async throws {
        let vm = try await makeVM()
        vm.messages = [ChatMessage(role: .user, content: "hi")]
        vm.clear()
        #expect(vm.messages.isEmpty)
    }

    @Test("clear() resets errorMessage and streamingText")
    func clearResetsState() async throws {
        let vm = try await makeVM()
        vm.errorMessage = "oops"
        vm.streamingText = "partial"
        vm.clear()
        #expect(vm.errorMessage == nil)
        #expect(vm.streamingText.isEmpty)
    }

    // MARK: - babyContext

    @Test("babyContext uses baby name from appState")
    func babyContextUsesName() async throws {
        let profile = BabyProfile(name: "Mia", birthDate: Date())
        let vm = try await makeVM(profile: profile)
        #expect(vm.babyContext.babyName == "Mia")
    }

    @Test("babyContext defaults to 'Baby' when name is empty")
    func babyContextDefaultsName() async throws {
        let profile = BabyProfile(name: "", birthDate: Date())
        let vm = try await makeVM(profile: profile)
        #expect(vm.babyContext.babyName == "Baby")
    }

    @Test("babyContext computes ageWeeks from birthDate")
    func babyContextComputesAge() async throws {
        let birth = Calendar.current.date(byAdding: .weekOfYear, value: -12, to: Date())!
        let profile = BabyProfile(name: "Test", birthDate: birth)
        let vm = try await makeVM(profile: profile)
        #expect(vm.babyContext.ageWeeks == 12)
    }
}
