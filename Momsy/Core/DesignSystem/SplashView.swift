import SwiftUI

struct SplashView: View {
    @State private var blobScale: CGFloat = 0.65
    @State private var blobOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var taglineOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.bbCream.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                CuteBlobView(kind: .heart, size: 128, tone: .bbCoral)
                    .scaleEffect(blobScale)
                    .opacity(blobOpacity)

                Spacer().frame(height: 24)

                Text("Momsy")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.bbInk)
                    .opacity(textOpacity)

                Spacer().frame(height: 6)

                Text(LocalizationManager.shared.t("Your baby's little diary", "Дневник вашего малыша"))
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.bbInkSoft)
                    .opacity(taglineOpacity)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.68)) {
                blobScale   = 1.0
                blobOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.45).delay(0.2)) {
                textOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.38)) {
                taglineOpacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
}
