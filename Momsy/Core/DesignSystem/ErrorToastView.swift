import SwiftUI

struct ErrorToastView: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.bbCoral)
                .font(.system(size: 16, weight: .semibold))
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.bbInk)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .bbShadow()
    }
}

private struct ErrorToastModifier: ViewModifier {
    @Binding var message: String?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let msg = message {
                    ErrorToastView(message: msg)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    message = nil
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                message = nil
                            }
                        }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: message)
    }
}

extension View {
    func errorToast(_ message: Binding<String?>) -> some View {
        modifier(ErrorToastModifier(message: message))
    }
}
