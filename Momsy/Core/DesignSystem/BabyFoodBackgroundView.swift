import SwiftUI

struct BabyFoodBackgroundView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.bbCream

                ForEach(Self.patternItems) { item in
                    BabyFoodDecoration(
                        kind: item.kind,
                        size: item.size,
                        tone: item.tone,
                        rotation: item.rotation,
                        opacity: item.opacity
                    )
                    .position(
                        x: proxy.size.width * item.x,
                        y: proxy.size.height * item.y
                    )
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private static let patternItems: [BabyFoodPatternItem] = [
        .init(id: 0, kind: .bottle, x: 0.08, y: 0.05, size: 28, tone: .bbSky, rotation: .degrees(-14), opacity: 0.13),
        .init(id: 1, kind: .banana, x: 0.28, y: 0.08, size: 24, tone: .bbButter, rotation: .degrees(18), opacity: 0.14),
        .init(id: 2, kind: .fruit, x: 0.52, y: 0.06, size: 26, tone: .bbRose, rotation: .degrees(-7), opacity: 0.12),
        .init(id: 3, kind: .carrot, x: 0.76, y: 0.09, size: 25, tone: .bbMint, rotation: .degrees(20), opacity: 0.12),
        .init(id: 4, kind: .porridge, x: 0.94, y: 0.05, size: 30, tone: .bbCoral, rotation: .degrees(-9), opacity: 0.11),
        .init(id: 5, kind: .fruit, x: 0.16, y: 0.18, size: 24, tone: .bbLilac, rotation: .degrees(11), opacity: 0.12),
        .init(id: 6, kind: .porridge, x: 0.41, y: 0.2, size: 29, tone: .bbCoral, rotation: .degrees(8), opacity: 0.12),
        .init(id: 7, kind: .bottle, x: 0.65, y: 0.17, size: 26, tone: .bbSky, rotation: .degrees(-18), opacity: 0.12),
        .init(id: 8, kind: .banana, x: 0.88, y: 0.22, size: 23, tone: .bbButter, rotation: .degrees(24), opacity: 0.14),
        .init(id: 9, kind: .carrot, x: 0.06, y: 0.31, size: 25, tone: .bbMint, rotation: .degrees(-24), opacity: 0.12),
        .init(id: 10, kind: .bottle, x: 0.3, y: 0.33, size: 27, tone: .bbLilac, rotation: .degrees(14), opacity: 0.12),
        .init(id: 11, kind: .fruit, x: 0.55, y: 0.3, size: 24, tone: .bbRose, rotation: .degrees(-16), opacity: 0.12),
        .init(id: 12, kind: .porridge, x: 0.8, y: 0.34, size: 28, tone: .bbCoral, rotation: .degrees(12), opacity: 0.11),
        .init(id: 13, kind: .banana, x: 0.95, y: 0.4, size: 23, tone: .bbButter, rotation: .degrees(-20), opacity: 0.13),
        .init(id: 14, kind: .fruit, x: 0.13, y: 0.45, size: 25, tone: .bbRose, rotation: .degrees(17), opacity: 0.12),
        .init(id: 15, kind: .carrot, x: 0.37, y: 0.48, size: 24, tone: .bbMint, rotation: .degrees(9), opacity: 0.12),
        .init(id: 16, kind: .bottle, x: 0.62, y: 0.44, size: 26, tone: .bbSky, rotation: .degrees(-11), opacity: 0.12),
        .init(id: 17, kind: .porridge, x: 0.86, y: 0.5, size: 29, tone: .bbLilac, rotation: .degrees(-8), opacity: 0.11),
        .init(id: 18, kind: .banana, x: 0.05, y: 0.59, size: 24, tone: .bbButter, rotation: .degrees(15), opacity: 0.14),
        .init(id: 19, kind: .porridge, x: 0.24, y: 0.64, size: 29, tone: .bbCoral, rotation: .degrees(10), opacity: 0.11),
        .init(id: 20, kind: .fruit, x: 0.49, y: 0.61, size: 25, tone: .bbRose, rotation: .degrees(-12), opacity: 0.12),
        .init(id: 21, kind: .carrot, x: 0.72, y: 0.66, size: 25, tone: .bbMint, rotation: .degrees(-21), opacity: 0.12),
        .init(id: 22, kind: .bottle, x: 0.94, y: 0.62, size: 27, tone: .bbSky, rotation: .degrees(16), opacity: 0.12),
        .init(id: 23, kind: .carrot, x: 0.14, y: 0.76, size: 24, tone: .bbMint, rotation: .degrees(19), opacity: 0.12),
        .init(id: 24, kind: .banana, x: 0.34, y: 0.81, size: 23, tone: .bbButter, rotation: .degrees(-19), opacity: 0.14),
        .init(id: 25, kind: .bottle, x: 0.58, y: 0.77, size: 26, tone: .bbLilac, rotation: .degrees(-13), opacity: 0.12),
        .init(id: 26, kind: .fruit, x: 0.82, y: 0.83, size: 25, tone: .bbRose, rotation: .degrees(10), opacity: 0.12),
        .init(id: 27, kind: .porridge, x: 0.06, y: 0.92, size: 29, tone: .bbCoral, rotation: .degrees(-10), opacity: 0.11),
        .init(id: 28, kind: .bottle, x: 0.27, y: 0.96, size: 26, tone: .bbSky, rotation: .degrees(17), opacity: 0.12),
        .init(id: 29, kind: .fruit, x: 0.5, y: 0.91, size: 24, tone: .bbRose, rotation: .degrees(-18), opacity: 0.12),
        .init(id: 30, kind: .carrot, x: 0.73, y: 0.95, size: 24, tone: .bbMint, rotation: .degrees(12), opacity: 0.12),
        .init(id: 31, kind: .banana, x: 0.93, y: 0.91, size: 23, tone: .bbButter, rotation: .degrees(-15), opacity: 0.13)
    ]
}

private struct BabyFoodPatternItem: Identifiable {
    let id: Int
    let kind: BabyFoodDecoration.Kind
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let tone: Color
    let rotation: Angle
    let opacity: Double
}

private struct BabyFoodDecoration: View {
    enum Kind {
        case bottle
        case banana
        case porridge
        case fruit
        case carrot
    }

    let kind: Kind
    let size: CGFloat
    let tone: Color
    let rotation: Angle
    let opacity: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                .fill(tone.opacity(0.36))
                .frame(width: size, height: size)

            content
        }
        .frame(width: size, height: size)
        .rotationEffect(rotation)
        .opacity(opacity)
    }

    @ViewBuilder
    private var content: some View {
        switch kind {
        case .bottle:
            CuteBlobView(kind: .bottle, size: size * 0.88, tone: .clear)
        case .banana:
            BananaShape()
                .fill(Color.bbButterDeep)
                .frame(width: size * 0.66, height: size * 0.54)
                .overlay(
                    BananaShape()
                        .fill(Color.bbCream.opacity(0.75))
                        .frame(width: size * 0.45, height: size * 0.32)
                        .offset(x: size * 0.04, y: -size * 0.04)
                )
        case .porridge:
            PorridgeBowl(size: size)
        case .fruit:
            FruitCluster(size: size)
        case .carrot:
            CarrotIcon(size: size)
        }
    }
}

private struct PorridgeBowl: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.bbInkMute.opacity(0.55))
                .frame(width: size * 0.08, height: size * 0.52)
                .offset(x: size * 0.22, y: -size * 0.03)
                .rotationEffect(.degrees(28))

            Ellipse()
                .fill(Color.white.opacity(0.95))
                .frame(width: size * 0.58, height: size * 0.25)
                .offset(y: size * 0.04)

            RoundedRectangle(cornerRadius: size * 0.17, style: .continuous)
                .fill(Color.bbCoral.opacity(0.72))
                .frame(width: size * 0.58, height: size * 0.32)
                .offset(y: size * 0.15)

            Circle()
                .fill(Color.bbButter.opacity(0.75))
                .frame(width: size * 0.2, height: size * 0.2)
                .offset(x: -size * 0.1, y: size * 0.03)
        }
    }
}

private struct FruitCluster: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.bbRoseDeep.opacity(0.82))
                .frame(width: size * 0.34, height: size * 0.34)
                .offset(x: -size * 0.12, y: size * 0.08)

            Circle()
                .fill(Color.bbButterDeep.opacity(0.84))
                .frame(width: size * 0.3, height: size * 0.3)
                .offset(x: size * 0.15, y: size * 0.06)

            Circle()
                .fill(Color.bbMintDeep.opacity(0.78))
                .frame(width: size * 0.18, height: size * 0.18)
                .offset(x: size * 0.02, y: -size * 0.16)

            Capsule()
                .fill(Color.bbInkSoft.opacity(0.7))
                .frame(width: size * 0.06, height: size * 0.18)
                .offset(x: -size * 0.08, y: -size * 0.14)

            Ellipse()
                .fill(Color.bbMint.opacity(0.9))
                .frame(width: size * 0.2, height: size * 0.11)
                .offset(x: size * 0.06, y: -size * 0.18)
                .rotationEffect(.degrees(-20))
        }
    }
}

private struct CarrotIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(Color.bbMintDeep.opacity(0.72))
                    .frame(width: size * 0.08, height: size * 0.28)
                    .offset(x: CGFloat(index - 1) * size * 0.09, y: -size * 0.23)
                    .rotationEffect(.degrees(Double(index - 1) * 24))
            }

            CarrotShape()
                .fill(Color.bbCoralDeep.opacity(0.82))
                .frame(width: size * 0.42, height: size * 0.58)
                .offset(y: size * 0.1)
        }
    }
}

private struct BananaShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.1, y: h * 0.68))
        path.addCurve(
            to: CGPoint(x: w * 0.9, y: h * 0.18),
            control1: CGPoint(x: w * 0.34, y: h * 0.88),
            control2: CGPoint(x: w * 0.66, y: h * 0.1)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.76, y: h * 0.42),
            control1: CGPoint(x: w * 0.89, y: h * 0.3),
            control2: CGPoint(x: w * 0.84, y: h * 0.38)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.22, y: h * 0.82),
            control1: CGPoint(x: w * 0.58, y: h * 0.52),
            control2: CGPoint(x: w * 0.4, y: h * 0.78)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.1, y: h * 0.68),
            control1: CGPoint(x: w * 0.16, y: h * 0.82),
            control2: CGPoint(x: w * 0.12, y: h * 0.77)
        )
        path.closeSubpath()
        return path
    }
}

private struct CarrotShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.18, y: h * 0.04))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.82, y: h * 0.04),
            control: CGPoint(x: w * 0.5, y: -h * 0.08)
        )
        path.addLine(to: CGPoint(x: w * 0.54, y: h * 0.94))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.46, y: h * 0.94),
            control: CGPoint(x: w * 0.5, y: h)
        )
        path.closeSubpath()
        return path
    }
}
