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
        case .walk:    WalkBlob(s: size)
        case .bath:    BathBlob(s: size)
        case .vitamin: VitaminBlob(s: size)
        case .stool:   StoolBlob(s: size)
        case .pump:    PumpBlob(s: size)
        case .mom:     MomBlob(s: size)
        case .dad:     DadBlob(s: size)
        case .nanny:   NannyBlob(s: size)
        case .other:   OtherBlob(s: size)
        }
    }
}

// MARK: - People (shared)

private enum BlobFace {
    static let skin = Color(bbHex: "FFD9B8")
    static let ink  = Color(bbHex: "3D2A20")
}

private struct BlobSmile: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                       control: CGPoint(x: rect.midX, y: rect.maxY * 1.7))
        return p
    }
}

// MARK: - Mom (woman, long hair)

private struct MomBlob: View {
    let s: CGFloat
    var body: some View {
        let f = s * 0.52
        let hair = Color(bbHex: "6B4423")
        ZStack {
            // long hair framing the face
            RoundedRectangle(cornerRadius: f * 0.5, style: .continuous)
                .fill(hair)
                .frame(width: f * 1.18, height: f * 1.34)
                .offset(y: f * 0.08)
            // face
            Ellipse().fill(BlobFace.skin).frame(width: f, height: f * 1.06)
            // bangs over forehead
            Ellipse().fill(hair).frame(width: f * 1.02, height: f * 0.58).offset(y: -f * 0.42)
            // eyes
            Circle().fill(BlobFace.ink).frame(width: f * 0.1, height: f * 0.1).offset(x: -f * 0.17, y: -f * 0.02)
            Circle().fill(BlobFace.ink).frame(width: f * 0.1, height: f * 0.1).offset(x:  f * 0.17, y: -f * 0.02)
            // cheeks
            Circle().fill(Color.bbCoral).opacity(0.55).frame(width: f * 0.2, height: f * 0.2).offset(x: -f * 0.26, y: f * 0.15)
            Circle().fill(Color.bbCoral).opacity(0.55).frame(width: f * 0.2, height: f * 0.2).offset(x:  f * 0.26, y: f * 0.15)
            // smile
            BlobSmile()
                .stroke(BlobFace.ink, style: StrokeStyle(lineWidth: f * 0.05, lineCap: .round))
                .frame(width: f * 0.22, height: f * 0.1).offset(y: f * 0.2)
        }
    }
}

// MARK: - Dad (man, short hair, mustache)

private struct DadBlob: View {
    let s: CGFloat
    var body: some View {
        let f = s * 0.52
        let hair = Color(bbHex: "4A3325")
        ZStack {
            // short hair cap
            Ellipse().fill(hair).frame(width: f * 1.04, height: f * 0.64).offset(y: -f * 0.38)
            // face
            Ellipse().fill(BlobFace.skin).frame(width: f, height: f * 1.04)
            // eyes
            Circle().fill(BlobFace.ink).frame(width: f * 0.1, height: f * 0.1).offset(x: -f * 0.17, y: -f * 0.08)
            Circle().fill(BlobFace.ink).frame(width: f * 0.1, height: f * 0.1).offset(x:  f * 0.17, y: -f * 0.08)
            // cheeks
            Circle().fill(Color.bbCoral).opacity(0.5).frame(width: f * 0.18, height: f * 0.18).offset(x: -f * 0.27, y: f * 0.08)
            Circle().fill(Color.bbCoral).opacity(0.5).frame(width: f * 0.18, height: f * 0.18).offset(x:  f * 0.27, y: f * 0.08)
            // mustache
            Capsule().fill(hair).frame(width: f * 0.3, height: f * 0.07).offset(y: f * 0.12)
            // smile
            BlobSmile()
                .stroke(BlobFace.ink, style: StrokeStyle(lineWidth: f * 0.05, lineCap: .round))
                .frame(width: f * 0.2, height: f * 0.08).offset(y: f * 0.26)
        }
    }
}

// MARK: - Nanny (grandma, grey bun + glasses)

private struct NannyBlob: View {
    let s: CGFloat
    var body: some View {
        let f = s * 0.52
        let hair = Color(bbHex: "DAD5CF")
        let frame = Color(bbHex: "5A4A40")
        ZStack {
            // hair frame
            Ellipse().fill(hair).frame(width: f * 1.12, height: f * 0.72).offset(y: -f * 0.34)
            // bun on top
            Circle().fill(hair).frame(width: f * 0.34, height: f * 0.34).offset(y: -f * 0.56)
            // face
            Ellipse().fill(BlobFace.skin).frame(width: f, height: f * 1.05)
            // glasses
            Circle().stroke(frame, lineWidth: f * 0.045).frame(width: f * 0.3, height: f * 0.3).offset(x: -f * 0.18, y: -f * 0.02)
            Circle().stroke(frame, lineWidth: f * 0.045).frame(width: f * 0.3, height: f * 0.3).offset(x:  f * 0.18, y: -f * 0.02)
            Capsule().fill(frame).frame(width: f * 0.08, height: f * 0.035).offset(y: -f * 0.02)
            // eyes inside glasses
            Circle().fill(BlobFace.ink).frame(width: f * 0.07, height: f * 0.07).offset(x: -f * 0.18, y: -f * 0.02)
            Circle().fill(BlobFace.ink).frame(width: f * 0.07, height: f * 0.07).offset(x:  f * 0.18, y: -f * 0.02)
            // rosy cheeks
            Circle().fill(Color.bbCoral).opacity(0.6).frame(width: f * 0.19, height: f * 0.19).offset(x: -f * 0.27, y: f * 0.18)
            Circle().fill(Color.bbCoral).opacity(0.6).frame(width: f * 0.19, height: f * 0.19).offset(x:  f * 0.27, y: f * 0.18)
            // smile
            BlobSmile()
                .stroke(BlobFace.ink, style: StrokeStyle(lineWidth: f * 0.05, lineCap: .round))
                .frame(width: f * 0.2, height: f * 0.09).offset(y: f * 0.24)
        }
    }
}

// MARK: - Other (generic person avatar)

private struct OtherBlob: View {
    let s: CGFloat
    var body: some View {
        let f = s * 0.5
        let hair = Color(bbHex: "6E5B4E")
        ZStack {
            // shoulders
            RoundedRectangle(cornerRadius: f * 0.55, style: .continuous)
                .fill(Color.white)
                .frame(width: f * 1.2, height: f * 0.72).offset(y: f * 0.64)
            // hair behind head
            Ellipse().fill(hair).frame(width: f * 0.66, height: f * 0.4).offset(y: -f * 0.34)
            // head
            Circle().fill(BlobFace.skin).frame(width: f * 0.62, height: f * 0.62).offset(y: -f * 0.16)
            // hair fringe over forehead
            Ellipse().fill(hair).frame(width: f * 0.66, height: f * 0.26).offset(y: -f * 0.38)
            // eyes
            Circle().fill(BlobFace.ink).frame(width: f * 0.08, height: f * 0.08).offset(x: -f * 0.13, y: -f * 0.18)
            Circle().fill(BlobFace.ink).frame(width: f * 0.08, height: f * 0.08).offset(x:  f * 0.13, y: -f * 0.18)
            // cheeks
            Circle().fill(Color.bbCoral).opacity(0.45).frame(width: f * 0.14, height: f * 0.14).offset(x: -f * 0.2, y: -f * 0.08)
            Circle().fill(Color.bbCoral).opacity(0.45).frame(width: f * 0.14, height: f * 0.14).offset(x:  f * 0.2, y: -f * 0.08)
            // smile
            BlobSmile()
                .stroke(BlobFace.ink, style: StrokeStyle(lineWidth: f * 0.045, lineCap: .round))
                .frame(width: f * 0.16, height: f * 0.07).offset(y: -f * 0.02)
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

// MARK: - Drop (Diaper)

private struct DiaperShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let r: CGFloat = 0.08
        p.move(to: CGPoint(x: w*r, y: 0))
        p.addLine(to: CGPoint(x: w*(1-r), y: 0))
        p.addQuadCurve(to: CGPoint(x: w, y: h*r), control: CGPoint(x: w, y: 0))
        p.addCurve(to: CGPoint(x: w*0.72, y: h*0.5),
                   control1: CGPoint(x: w, y: h*0.26), control2: CGPoint(x: w*0.72, y: h*0.38))
        p.addCurve(to: CGPoint(x: w, y: h*(1-r)),
                   control1: CGPoint(x: w*0.72, y: h*0.62), control2: CGPoint(x: w, y: h*0.74))
        p.addQuadCurve(to: CGPoint(x: w*(1-r), y: h), control: CGPoint(x: w, y: h))
        p.addLine(to: CGPoint(x: w*r, y: h))
        p.addQuadCurve(to: CGPoint(x: 0, y: h*(1-r)), control: CGPoint(x: 0, y: h))
        p.addCurve(to: CGPoint(x: w*0.28, y: h*0.5),
                   control1: CGPoint(x: 0, y: h*0.74), control2: CGPoint(x: w*0.28, y: h*0.62))
        p.addCurve(to: CGPoint(x: 0, y: h*r),
                   control1: CGPoint(x: w*0.28, y: h*0.38), control2: CGPoint(x: 0, y: h*0.26))
        p.addQuadCurve(to: CGPoint(x: w*r, y: 0), control: CGPoint(x: 0, y: 0))
        p.closeSubpath()
        return p
    }
}

private struct DropBlob: View {
    let s: CGFloat
    var body: some View {
        ZStack {
            DiaperShape()
                .fill(Color.white.opacity(0.92))
                .frame(width: s*0.5, height: s*0.5)
            // Left tape tab
            RoundedRectangle(cornerRadius: s*0.03)
                .fill(Color.bbSkyDeep)
                .frame(width: s*0.15, height: s*0.09)
                .offset(x: -s*0.27, y: -s*0.16)
            // Right tape tab
            RoundedRectangle(cornerRadius: s*0.03)
                .fill(Color.bbSkyDeep)
                .frame(width: s*0.15, height: s*0.09)
                .offset(x: s*0.27, y: -s*0.16)
        }
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

// MARK: - Walk

private struct WalkBlob: View {
    let s: CGFloat
    var body: some View {
        Image(systemName: "stroller")
            .font(.system(size: s * 0.46, weight: .medium))
            .foregroundColor(Color(bbHex: "5FB99B"))
    }
}

// MARK: - Bath

private struct BathBlob: View {
    let s: CGFloat
    var body: some View {
        Image(systemName: "drop.fill")
            .font(.system(size: s * 0.46, weight: .medium))
            .foregroundColor(Color(bbHex: "6FA8CE"))
    }
}

// MARK: - Vitamin

private struct VitaminBlob: View {
    let s: CGFloat
    var body: some View {
        Image(systemName: "pills.fill")
            .font(.system(size: s * 0.44, weight: .medium))
            .foregroundColor(Color(bbHex: "F2B85C"))
    }
}

// MARK: - Stool

private struct StoolBlob: View {
    let s: CGFloat
    var body: some View {
        Image(systemName: "waveform.path.ecg")
            .font(.system(size: s * 0.42, weight: .medium))
            .foregroundColor(Color(bbHex: "5FB99B"))
    }
}

// MARK: - Pump

private struct PumpBlob: View {
    let s: CGFloat
    var body: some View {
        Image(systemName: "drop.circle.fill")
            .font(.system(size: s * 0.44, weight: .medium))
            .foregroundColor(Color(bbHex: "D97FA8"))
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
