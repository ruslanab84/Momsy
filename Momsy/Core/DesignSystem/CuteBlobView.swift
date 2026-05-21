import SwiftUI

struct CuteBlobView: View {
    let kind: BlobKind
    var size: CGFloat = 80
    var tone: Color = .bbButter

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                .fill(tone)
            blobContent
        }
        .frame(width: size, height: size)
        .clipped()
    }

    @ViewBuilder
    private var blobContent: some View {
        switch kind {
        case .baby:    BabyBlob(s: size)
        case .sleep:   SleepBlob(s: size)
        case .bottle:  BottleBlob(s: size)
        case .moon:    MoonBlob(s: size)
        case .sun:     SunBlob(s: size)
        case .drop:    DropBlob(s: size)
        case .star:    StarBlob(s: size)
        case .heart:   HeartBlob(s: size)
        case .cloud:   CloudBlob(s: size)
        case .bear:    BearBlob(s: size)
        }
    }
}

// MARK: - Baby

private struct BabyBlob: View {
    let s: CGFloat
    var body: some View {
        let f = s * 0.55
        ZStack {
            Ellipse()
                .fill(Color(bbHex: "FFD9B8"))
                .frame(width: f, height: f * 1.05)
            // hair
            Ellipse()
                .fill(Color(bbHex: "5A3D2B"))
                .frame(width: f * 0.9, height: f * 0.4)
                .offset(y: -f * 0.33)
            // left eye
            Circle().fill(Color(bbHex: "5A3D2B")).frame(width: f*0.11, height: f*0.11).offset(x: -f*0.16, y: -f*0.04)
            // right eye
            Circle().fill(Color(bbHex: "5A3D2B")).frame(width: f*0.11, height: f*0.11).offset(x:  f*0.16, y: -f*0.04)
            // left cheek
            Circle().fill(Color.bbCoral).opacity(0.7).frame(width: f*0.22, height: f*0.22).offset(x: -f*0.24, y: f*0.13)
            // right cheek
            Circle().fill(Color.bbCoral).opacity(0.7).frame(width: f*0.22, height: f*0.22).offset(x:  f*0.24, y: f*0.13)
        }
    }
}

// MARK: - Sleep

private struct SleepBlob: View {
    let s: CGFloat
    var body: some View {
        ZStack {
            Circle().fill(Color(bbHex: "FFE9B5")).frame(width: s*0.25, height: s*0.25).offset(x: s*0.22, y: -s*0.26)
            Ellipse().fill(Color(bbHex: "FFD9B8")).frame(width: s*0.55, height: s*0.44).offset(y: s*0.05)
            // closed eyes
            Capsule().fill(Color(bbHex: "5A3D2B")).frame(width: s*0.14, height: s*0.035).offset(x: -s*0.1, y: s*0.05)
            Capsule().fill(Color(bbHex: "5A3D2B")).frame(width: s*0.14, height: s*0.035).offset(x:  s*0.1, y: s*0.05)
            // cheeks
            Circle().fill(Color.bbCoral).opacity(0.6).frame(width: s*0.18, height: s*0.18).offset(x: -s*0.18, y: s*0.13)
            Circle().fill(Color.bbCoral).opacity(0.6).frame(width: s*0.18, height: s*0.18).offset(x:  s*0.18, y: s*0.13)
        }
    }
}

// MARK: - Bottle

private struct BottleBlob: View {
    let s: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: s*0.12, style: .continuous)
                .fill(Color.white)
                .frame(width: s*0.35, height: s*0.6)
                .offset(y: s*0.06)
            // milk
            RoundedRectangle(cornerRadius: s*0.08, style: .continuous)
                .fill(Color(bbHex: "FFF1DE"))
                .frame(width: s*0.28, height: s*0.25)
                .offset(y: s*0.19)
            // cap
            RoundedRectangle(cornerRadius: s*0.05, style: .continuous)
                .fill(Color.bbCoral)
                .frame(width: s*0.22, height: s*0.1)
                .offset(y: -s*0.27)
        }
    }
}

// MARK: - Moon

private struct MoonBlob: View {
    let s: CGFloat
    var body: some View {
        Circle()
            .fill(Color(bbHex: "FFE9B5"))
            .frame(width: s*0.55, height: s*0.55)
            .overlay(
                Circle()
                    .fill(Color.bbLilac)
                    .frame(width: s*0.44, height: s*0.44)
                    .offset(x: s*0.1)
            )
    }
}

// MARK: - Sun

private struct SunBlob: View {
    let s: CGFloat
    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Capsule()
                    .fill(Color.bbButter)
                    .frame(width: s*0.08, height: s*0.2)
                    .offset(y: -s*0.32)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
            Circle().fill(Color.bbButterDeep).frame(width: s*0.42, height: s*0.42)
        }
    }
}

// MARK: - Drop

private struct DropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: w*0.5, y: 0))
        p.addCurve(to: CGPoint(x: w, y: h*0.62),
                   control1: CGPoint(x: w*0.95, y: h*0.28), control2: CGPoint(x: w, y: h*0.45))
        p.addCurve(to: CGPoint(x: w*0.5, y: h),
                   control1: CGPoint(x: w, y: h*0.82), control2: CGPoint(x: w*0.75, y: h))
        p.addCurve(to: CGPoint(x: 0, y: h*0.62),
                   control1: CGPoint(x: w*0.25, y: h), control2: CGPoint(x: 0, y: h*0.82))
        p.addCurve(to: CGPoint(x: w*0.5, y: 0),
                   control1: CGPoint(x: 0, y: h*0.45), control2: CGPoint(x: w*0.05, y: h*0.28))
        return p
    }
}

private struct DropBlob: View {
    let s: CGFloat
    var body: some View {
        DropShape().fill(Color.bbSkyDeep).frame(width: s*0.42, height: s*0.56)
    }
}

// MARK: - Star

private struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        let inner = r * 0.38
        var p = Path()
        for i in 0..<10 {
            let angle = Double(i) * .pi / 5 - .pi / 2
            let radius = i.isMultiple(of: 2) ? r : inner
            let pt = CGPoint(x: c.x + CGFloat(cos(angle)) * radius,
                             y: c.y + CGFloat(sin(angle)) * radius)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

private struct StarBlob: View {
    let s: CGFloat
    var body: some View {
        StarShape().fill(Color.bbButterDeep).frame(width: s*0.6, height: s*0.6)
    }
}

// MARK: - Heart

private struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: w*0.5, y: h))
        p.addCurve(to: CGPoint(x: 0, y: h*0.36),
                   control1: CGPoint(x: w*0.15, y: h*0.82), control2: CGPoint(x: 0, y: h*0.62))
        p.addCurve(to: CGPoint(x: w*0.5, y: h*0.18),
                   control1: CGPoint(x: 0, y: h*0.1), control2: CGPoint(x: w*0.5, y: h*0.3))
        p.addCurve(to: CGPoint(x: w, y: h*0.36),
                   control1: CGPoint(x: w*0.5, y: h*0.3), control2: CGPoint(x: w, y: h*0.1))
        p.addCurve(to: CGPoint(x: w*0.5, y: h),
                   control1: CGPoint(x: w, y: h*0.62), control2: CGPoint(x: w*0.85, y: h*0.82))
        return p
    }
}

private struct HeartBlob: View {
    let s: CGFloat
    var body: some View {
        HeartShape().fill(Color.bbCoralDeep).frame(width: s*0.6, height: s*0.55)
    }
}

// MARK: - Cloud

private struct CloudBlob: View {
    let s: CGFloat
    var body: some View {
        ZStack(alignment: .bottom) {
            Circle().fill(Color.white).frame(width: s*0.3, height: s*0.3).offset(x: -s*0.16, y: -s*0.08)
            Circle().fill(Color.white).frame(width: s*0.4, height: s*0.4).offset(x: s*0.04, y: -s*0.14)
            Circle().fill(Color.white).frame(width: s*0.28, height: s*0.28).offset(x: s*0.22, y: -s*0.06)
            Capsule().fill(Color.white).frame(width: s*0.65, height: s*0.22)
        }
    }
}

// MARK: - Bear

private struct BearBlob: View {
    let s: CGFloat
    var body: some View {
        let fur = Color(bbHex: "C9A07E")
        let muzzle = Color(bbHex: "FFE4CD")
        let nose = Color(bbHex: "3D2A20")
        ZStack {
            Circle().fill(fur).frame(width: s*0.28, height: s*0.28).offset(x: -s*0.19, y: -s*0.2)
            Circle().fill(fur).frame(width: s*0.28, height: s*0.28).offset(x:  s*0.19, y: -s*0.2)
            Circle().fill(fur).frame(width: s*0.55, height: s*0.55)
            Ellipse().fill(muzzle).frame(width: s*0.3, height: s*0.22).offset(y: s*0.1)
            Circle().fill(nose).frame(width: s*0.08, height: s*0.08).offset(x: -s*0.12, y: -s*0.04)
            Circle().fill(nose).frame(width: s*0.08, height: s*0.08).offset(x:  s*0.12, y: -s*0.04)
            Circle().fill(nose).frame(width: s*0.09, height: s*0.07).offset(y: s*0.09)
        }
    }
}
