import SwiftUI

// MARK: - AIChatView

struct AIChatView: View {
    @StateObject private var vm: AIChatViewModel
    @EnvironmentObject var loc: LocalizationManager
    @FocusState private var inputFocused: Bool

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeAIChatViewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            messageList
            inputBar
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(loc.strings.aiChatTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !vm.messages.isEmpty {
                    Button(loc.strings.clear) {
                        withAnimation(.spring(response: 0.3)) { vm.clear() }
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbCoralDeep)
                }
            }
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    if vm.messages.isEmpty && !vm.isStreaming {
                        emptyState
                    }
                    ForEach(vm.messages) { msg in
                        ChatBubble(message: msg)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    if vm.isStreaming {
                        StreamingBubble(text: vm.streamingText)
                            .id("streaming")
                    }
                    if let err = vm.errorMessage {
                        ErrorBubble(text: err, onRetry: { vm.retry() })
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .animation(.spring(response: 0.35), value: vm.messages.count)
            }
            .onChange(of: vm.messages.count) { _ in
                withAnimation { proxy.scrollTo("bottom") }
            }
            .onChange(of: vm.streamingText) { _ in
                proxy.scrollTo("bottom")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(Color.bbMintDeep.opacity(0.15))
                .frame(width: 72, height: 72)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.bbMintDeep)
                )

            VStack(spacing: 6) {
                Text(loc.strings.momsyAI)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(loc.strings.aiChatSubtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 8) {
                ForEach(suggestedPrompts, id: \.self) { prompt in
                    Button { vm.draft = prompt } label: {
                        Text(prompt)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInk)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.bbCard)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .bbShadowSoft()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 40)
        .padding(.bottom, 20)
    }

    private var suggestedPrompts: [String] {
        let name = vm.babyContext.babyName
        switch loc.lang {
        case "de":
            return [
                "Warum wacht \(name) so oft nachts auf?",
                "Wie viel sollte \(name) in diesem Alter essen?",
                "Ist das ein Entwicklungsschub?",
            ]
        case "ru":
            return [
                "Почему \(name) так часто просыпается ночью?",
                "Сколько \(name) должен есть в этом возрасте?",
                "Это скачок развития?",
            ]
        default:
            return [
                "Why does \(name) wake up so often at night?",
                "How much should \(name) eat at this age?",
                "Is this a developmental leap?",
            ]
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField(
                loc.strings.askAnything,
                text: $vm.draft,
                axis: .vertical
            )
            .font(.system(size: 15, design: .rounded))
            .lineLimit(1...4)
            .focused($inputFocused)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Button {
                inputFocused = false
                vm.send()
            } label: {
                Circle()
                    .fill(vm.canSend ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: vm.isStreaming ? "stop.fill" : "arrow.up")
                            .font(.system(size: vm.isStreaming ? 12 : 15, weight: .bold))
                            .foregroundColor(vm.canSend ? .white : .bbInkMute.opacity(0.5))
                    )
                    .animation(.easeInOut(duration: 0.2), value: vm.canSend)
            }
            .disabled(!vm.canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Color.bbCream
                .shadow(color: .black.opacity(0.06), radius: 8, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Chat Bubble

private struct ChatBubble: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 60) }
            if !isUser { avatarDot }

            Text(message.content)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(isUser ? .white : .bbInk)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isUser ? Color.bbCoralDeep : Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            if !isUser { Spacer(minLength: 60) }
        }
    }

    private var avatarDot: some View {
        Circle()
            .fill(Color.bbMintDeep)
            .frame(width: 28, height: 28)
            .overlay(
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            )
    }
}

// MARK: - Streaming Bubble

private struct StreamingBubble: View {
    let text: String

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Circle()
                .fill(Color.bbMintDeep)
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                )

            Group {
                if text.isEmpty {
                    TypingIndicator()
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                } else {
                    Text(text)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.bbInk)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                }
            }
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Spacer(minLength: 60)
        }
    }
}

// MARK: - Error Bubble

private struct ErrorBubble: View {
    let text: String
    let onRetry: () -> Void
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        VStack(spacing: 8) {
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.bbCoralDeep)
                .multilineTextAlignment(.center)
            Button(action: onRetry) {
                Text(loc.strings.tryAgain)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.bbCoralDeep)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.bbRose.opacity(0.3))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.bbRose.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Typing Indicator

private struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.bbInkMute.opacity(0.5))
                    .frame(width: 7, height: 7)
                    .offset(y: animating ? -4 : 0)
                    .animation(
                        .easeInOut(duration: 0.45)
                            .repeatForever()
                            .delay(Double(i) * 0.15),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

#Preview {
    NavigationStack {
        AIChatView(container: AppContainer())
    }
    .environmentObject(LocalizationManager.shared)
}
