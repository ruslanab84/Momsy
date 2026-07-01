import SwiftUI

struct BabyFoodBackgroundView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.bbCream

                BabyFoodDecoration(kind: .bottle, size: 92, tone: .bbSky, rotation: .degrees(-12), opacity: 0.18)
                    .position(x: proxy.size.width * 0.16, y: 86)

                BabyFoodDecoration(kind: .banana, size: 84, tone: .bbButter, rotation: .degrees(18), opacity: 0.2)
                    .position(x: proxy.size.width * 0.84, y: 128)

                BabyFoodDecoration(kind: .porridge, size: 96, tone: .bbCoral, rotation: .degrees(-8), opacity: 0.15)
                    .position(x: proxy.size.width * 0.18, y: proxy.size.height * 0.46)

                BabyFoodDecoration(kind: .fruit, size: 82, tone: .bbRose, rotation: .degrees(10), opacity: 0.17)
                    .position(x: proxy.size.width * 0.86, y: proxy.size.height * 0.56)

                BabyFoodDecoration(kind: .carrot, size: 74, tone: .bbMint, rotation: .degrees(-22), opacity: 0.14)
                    .position(x: proxy.size.width * 0.12, y: proxy.size.height * 0.82)

                BabyFoodDecoration(kind: .bottle, size: 78, tone: .bbLilac, rotation: .degrees(14), opacity: 0.13)
                    .position(x: proxy.size.width * 0.78, y: proxy.size.height * 0.9)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
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
