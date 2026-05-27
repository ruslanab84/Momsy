import SwiftUI

// MARK: - Splash View

struct SplashView: View {

    // Entrance
    @State private var sceneScale: CGFloat = 0.65
    @State private var sceneOpacity: Double = 0

    // Continuous elements
    @State private var sunRotation: Double = 0
    @State private var moonSway: CGFloat = 0
    @State private var cloudFloat: CGFloat = 0
    @State private var breathe = false

    // Stars
    @State private var s1: Double = 0.35
    @State private var s2: Double = 0.70
    @State private var s3: Double = 0.25

    // Z letters (one-shot rise + fade over 2.2s window)
    @State private var z1Y: CGFloat = 0;  @State private var z1Op: Double = 0
    @State private var z2Y: CGFloat = 0;  @State private var z2Op: Double = 0
    @State private var z3Y: CGFloat = 0;  @State private var z3Op: Double = 0

    // Text
    @State private var titleOpacity: Double = 0
    @State private var taglineOpacity: Double = 0

    // Palette
    private let skyTop  = Color(red: 0.87, green: 0.94, blue: 1.00)
    private let skyBot  = Color(red: 1.00, green: 0.96, blue: 0.93)
    private let sunCol  = Color(red: 1.00, green: 0.80, blue: 0.28)
    private let moonCol = Color(red: 0.65, green: 0.78, blue: 0.92)
    private let starCol = Color(red: 0.68, green: 0.83, blue: 0.95)
    private let zCol    = Color(red: 0.58, green: 0.77, blue: 0.95)

    var body: some View {
        ZStack {
            LinearGradient(colors: [skyTop, skyBot], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()
                sceneBubble
                titleBlock
                Spacer()
            }
        }
        .onAppear { launch() }
    }

    // MARK: - Scene Bubble

    private var sceneBubble: some View {
        ZStack {
            // Stage circle
            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: 234, height: 234)
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 6)

            // ─ Sun ─
            Image(systemName: "sun.max.fill")
                .resizable()
                .frame(width: 44, height: 44)
                .foregroundStyle(sunCol)
                .rotationEffect(.degrees(sunRotation))
                .offset(x: -62, y: -60)

            // ─ Moon ─
            Image(systemName: "moon.fill")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundStyle(moonCol)
                .offset(x: 64, y: moonSway - 55)

            // ─ Stars ─
            starDot(size: 10, x: -22, y: -76).opacity(s1)
            starDot(size:  7, x:  28, y: -80).opacity(s2)
            starDot(size:  8, x: -74, y: -14).opacity(s3)

            // ─ Baby on cloud ─
            VStack(spacing: -8) {
                SleepingBabyView(breathe: breathe)
                BabyCloudView()
            }
            .offset(y: cloudFloat + 18)

            // ─ Z letters ─
            zLetters
        }
        .scaleEffect(sceneScale)
        .opacity(sceneOpacity)
    }

    private func starDot(size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Image(systemName: "star.fill")
            .resizable()
            .frame(width: size, height: size)
            .foregroundStyle(starCol)
            .offset(x: x, y: y)
    }

    private var zLetters: some View {
        ZStack {
            Text("z")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(zCol.opacity(0.85))
                .offset(x: 18, y: z1Y - 28)
                .opacity(z1Op)
            Text("z")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(zCol.opacity(0.70))
                .offset(x: 32, y: z2Y - 40)
                .opacity(z2Op)
            Text("z")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(zCol.opacity(0.55))
                .offset(x: 44, y: z3Y - 50)
                .opacity(z3Op)
        }
    }

    // MARK: - Title

    private var titleBlock: some View {
        VStack(spacing: 5) {
            Text("Momsy")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.26, green: 0.17, blue: 0.12))
                .opacity(titleOpacity)
            Text(LocalizationManager.shared.strings.splashTagline)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 0.50, green: 0.38, blue: 0.30))
                .opacity(taglineOpacity)
        }
    }

    // MARK: - Animations

    private func launch() {
        // Entrance spring
        withAnimation(.spring(response: 0.58, dampingFraction: 0.70)) {
            sceneScale   = 1.0
            sceneOpacity = 1.0
        }

        // Title / tagline
        withAnimation(.easeOut(duration: 0.42).delay(0.28)) { titleOpacity   = 1 }
        withAnimation(.easeOut(duration: 0.40).delay(0.48)) { taglineOpacity = 1 }

        // Sun – slow infinite rotation
        withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) {
            sunRotation = 360
        }
        // Moon sway
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(0.1)) {
            moonSway = 6
        }
        // Cloud float
        withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true).delay(0.2)) {
            cloudFloat = -5
        }
        // Baby breathe
        withAnimation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true).delay(0.4)) {
            breathe = true
        }
        // Stars twinkle
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { s1 = 1.0 }
        withAnimation(.easeInOut(duration: 2.1).repeatForever(autoreverses: true).delay(0.45)) { s2 = 0.30 }
        withAnimation(.easeInOut(duration: 1.9).repeatForever(autoreverses: true).delay(0.85)) { s3 = 0.90 }

        // Z1 – first sleep puff
        withAnimation(.easeIn(duration:  0.22).delay(0.72)) { z1Op = 0.85 }
        withAnimation(.linear(duration:  1.60).delay(0.72)) { z1Y  = -38 }
        withAnimation(.easeOut(duration: 0.50).delay(1.58)) { z1Op =  0 }

        // Z2
        withAnimation(.easeIn(duration:  0.22).delay(0.98)) { z2Op = 0.68 }
        withAnimation(.linear(duration:  1.50).delay(0.98)) { z2Y  = -35 }
        withAnimation(.easeOut(duration: 0.48).delay(1.75)) { z2Op =  0 }

        // Z3
        withAnimation(.easeIn(duration:  0.20).delay(1.22)) { z3Op = 0.52 }
        withAnimation(.linear(duration:  1.40).delay(1.22)) { z3Y  = -32 }
        withAnimation(.easeOut(duration: 0.45).delay(1.90)) { z3Op =  0 }
    }
}

// MARK: - Sleeping Baby

struct SleepingBabyView: View {
    var breathe: Bool

    private let skin  = Color(red: 0.99, green: 0.87, blue: 0.72)
    private let suit  = Color(red: 0.74, green: 0.85, blue: 0.95)
    private let hair  = Color(red: 0.50, green: 0.34, blue: 0.20)
    private let cheek = Color(red: 0.98, green: 0.75, blue: 0.72)
    private let eye   = Color(red: 0.36, green: 0.22, blue: 0.12)
    private let smile = Color(red: 0.88, green: 0.50, blue: 0.44)

    var body: some View {
        ZStack {
            // Body / onesie
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(suit)
                .frame(width: 68, height: 44)
                .offset(y: 20)
                .scaleEffect(x: breathe ? 1.012 : 1.0, y: breathe ? 1.008 : 1.0)

            // Left hand
            Circle().fill(skin).frame(width: 20, height: 20).offset(x: -30, y: 22)
            // Right hand
            Circle().fill(skin).frame(width: 18, height: 18).offset(x: 30, y: 24)

            // Head
            Circle().fill(skin).frame(width: 54, height: 54).offset(y: -4)

            // Hair (3 overlapping circles for soft wispy look)
            Circle().fill(hair).frame(width: 22, height: 22).offset(x: -10, y: -24)
            Circle().fill(hair).frame(width: 20, height: 20).offset(x:   5, y: -26)
            Circle().fill(hair).frame(width: 16, height: 16).offset(x:  18, y: -22)

            // Eyes (closed arcs)
            ClosedEyeShape(isLeft: true)
                .stroke(eye, lineWidth: 2.2)
                .frame(width: 56, height: 56)
                .offset(y: -4)
            ClosedEyeShape(isLeft: false)
                .stroke(eye, lineWidth: 2.2)
                .frame(width: 56, height: 56)
                .offset(y: -4)

            // Cheeks
            Circle().fill(cheek.opacity(0.55)).frame(width: 11, height: 11).offset(x: -14, y: 6)
            Circle().fill(cheek.opacity(0.55)).frame(width: 11, height: 11).offset(x:  14, y: 6)

            // Smile
            SmileArcShape()
                .stroke(smile, lineWidth: 1.6)
                .frame(width: 56, height: 56)
                .offset(y: -4)
        }
        .frame(width: 100, height: 80)
    }
}

/// Two arcs for closed sleeping eyes
struct ClosedEyeShape: Shape {
    let isLeft: Bool

    func path(in rect: CGRect) -> Path {
        let cx = rect.midX + (isLeft ? -10 : 10)
        let cy = rect.midY + 2
        let w: CGFloat = 11
        var p = Path()
        p.move(to: CGPoint(x: cx - w / 2, y: cy))
        p.addQuadCurve(to: CGPoint(x: cx + w / 2, y: cy),
                       control: CGPoint(x: cx, y: cy - 6))
        return p
    }
}

/// Small upward-curve smile
struct SmileArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY + 10
        let w: CGFloat = 9
        var p = Path()
        p.move(to: CGPoint(x: cx - w / 2, y: cy))
        p.addQuadCurve(to: CGPoint(x: cx + w / 2, y: cy),
                       control: CGPoint(x: cx, y: cy + 5))
        return p
    }
}

// MARK: - Fluffy Cloud

struct BabyCloudView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.96))
                .frame(width: 82, height: 82)
                .offset(x: -30, y: 10)
            Circle()
                .fill(Color.white.opacity(0.96))
                .frame(width: 104, height: 104)
                .offset(y: 10)
            Circle()
                .fill(Color.white.opacity(0.96))
                .frame(width: 78, height: 78)
                .offset(x: 32, y: 13)
            Rectangle()
                .fill(Color.white.opacity(0.96))
                .frame(width: 164, height: 42)
                .offset(y: 33)
        }
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 5)
        .frame(width: 168, height: 74)
    }
}

// MARK: - Preview

#Preview {
    SplashView()
}
