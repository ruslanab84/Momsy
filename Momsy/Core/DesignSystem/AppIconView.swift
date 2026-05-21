import SwiftUI

// 1024×1024 icon — use #Preview below to inspect it.
// Export to Assets.xcassets via Settings → Export App Icon (DEBUG only).
struct AppIconView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(bbHex: "FFF0E4"), Color(bbHex: "FFCBA4")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                Spacer()

                CuteBlobView(kind: .heart, size: 560, tone: .bbCoral)

                Spacer().frame(height: 40)

                Text("momsy")
                    .font(.system(size: 160, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(bbHex: "3D2A20").opacity(0.82))
                    .tracking(-2)

                Spacer()
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

#Preview("App Icon 1024×1024") {
    AppIconView()
        .frame(width: 380, height: 380)
        .clipShape(RoundedRectangle(cornerRadius: 84, style: .continuous))
}

#Preview("App Icon — exact size") {
    AppIconView()
}
