import SwiftUI

// MARK: - Baby Face Icon

struct BabyFaceIcon: View {
    var size: CGFloat = 20

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.99, green: 0.87, blue: 0.72))
                .frame(width: size, height: size)
            Circle()
                .fill(Color(red: 0.50, green: 0.34, blue: 0.20))
                .frame(width: size * 0.55, height: size * 0.55)
                .offset(y: -size * 0.22)
                .clipShape(Rectangle().offset(y: size * 0.11))
            Circle()
                .fill(Color(red: 0.98, green: 0.75, blue: 0.72).opacity(0.7))
                .frame(width: size * 0.18, height: size * 0.18)
                .offset(x: -size * 0.22, y: size * 0.08)
            Circle()
                .fill(Color(red: 0.98, green: 0.75, blue: 0.72).opacity(0.7))
                .frame(width: size * 0.18, height: size * 0.18)
                .offset(x: size * 0.22, y: size * 0.08)
            Capsule()
                .fill(Color(red: 0.36, green: 0.22, blue: 0.12))
                .frame(width: size * 0.14, height: size * 0.05)
                .offset(x: -size * 0.17, y: -size * 0.05)
            Capsule()
                .fill(Color(red: 0.36, green: 0.22, blue: 0.12))
                .frame(width: size * 0.14, height: size * 0.05)
                .offset(x: size * 0.17, y: -size * 0.05)
            Capsule()
                .fill(Color(red: 0.88, green: 0.50, blue: 0.44))
                .frame(width: size * 0.22, height: size * 0.06)
                .offset(y: size * 0.18)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Background

struct BabyPatternBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.18),
                    Color(red: 0.18, green: 0.08, blue: 0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            ZStack {
                iconAt("star.fill",  8,  x: -110, y: -16, r: -15)
                iconAt("heart.fill", 9,  x:  -65, y:  14, r:  10)
                iconAt("drop.fill",  7,  x:  -20, y: -20, r:   5)
                iconAt("sparkle",    9,  x:   30, y:  18, r: -10)
                iconAt("moon.fill",  8,  x:   75, y:  -8, r:  20)
                iconAt("star.fill",  7,  x:  115, y:  16, r: -20)
                iconAt("heart.fill", 8,  x:  -90, y:  24, r:  25)
                iconAt("drop.fill",  9,  x:   50, y: -22, r:  -5)
            }
            .foregroundStyle(.white.opacity(0.10))
        }
    }

    @ViewBuilder
    private func iconAt(_ name: String, _ pt: CGFloat,
                        x: CGFloat, y: CGFloat, r: Double) -> some View {
        Image(systemName: name)
            .font(.system(size: pt))
            .offset(x: x, y: y)
            .rotationEffect(.degrees(r))
    }
}
