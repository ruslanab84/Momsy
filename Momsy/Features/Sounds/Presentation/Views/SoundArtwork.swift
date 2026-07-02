import SwiftUI

// MARK: - Sound Artwork

struct SoundArtwork: View {
    let sound: SoundItem
    let tone: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tone.opacity(0.92), tone],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            GeometryReader { proxy in
                let size = proxy.size
                ZStack {
                    SoundArtworkGlow()
                    artwork(size: size)
                }
                .frame(width: size.width, height: size.height)
            }
        }
        .aspectRatio(1.65, contentMode: .fit)
        .clipped()
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func artwork(size: CGSize) -> some View {
        switch sound.nameEn {
        case "Rain":
            RainArtwork(size: size)
        case "Ocean":
            OceanArtwork(size: size)
        case "Forest":
            ForestArtwork(size: size)
        case "Brook":
            BrookArtwork(size: size)
        case "Hair dryer":
            HairDryerArtwork(size: size)
        case "Lullaby":
            LullabyArtwork(size: size)
        case "Heartbeat":
            HeartbeatArtwork(size: size)
        default:
            WombArtwork(size: size)
        }
    }
}

private struct SoundArtworkGlow: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 74, height: 74)
                .offset(x: -64, y: -36)

            Circle()
                .fill(Color.bbInk.opacity(0.05))
                .frame(width: 112, height: 112)
                .offset(x: 78, y: 40)
        }
    }
}

private struct RainArtwork: View {
    let size: CGSize

    var body: some View {
        let scale = artworkScale(for: size)

        ZStack {
            cloud(scale: scale)
                .frame(width: size.width * 0.48, height: size.height * 0.34)
                .position(x: size.width * 0.48, y: size.height * 0.35)

            ForEach(0..<6, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.82 : 0.58))
                    .frame(width: 5 * scale, height: 15 * scale)
                    .rotationEffect(.degrees(18))
                    .position(
                        x: size.width * (0.28 + CGFloat(index) * 0.075),
                        y: size.height * (0.62 + CGFloat(index % 2) * 0.13)
                    )
            }
        }
    }

    private func cloud(scale: CGFloat) -> some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(0.76))
                .frame(width: 88 * scale, height: 34 * scale)
                .offset(y: 8 * scale)
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 42 * scale, height: 42 * scale)
                .offset(x: -26 * scale, y: 0)
            Circle()
                .fill(Color.white.opacity(0.86))
                .frame(width: 52 * scale, height: 52 * scale)
                .offset(x: 8 * scale, y: -8 * scale)
            Circle()
                .fill(Color.white.opacity(0.72))
                .frame(width: 36 * scale, height: 36 * scale)
                .offset(x: 36 * scale, y: 4 * scale)
        }
    }
}

private struct OceanArtwork: View {
    let size: CGSize

    var body: some View {
        let scale = artworkScale(for: size)

        ZStack {
            ForEach(0..<3, id: \.self) { index in
                SoundWaveLine(amplitude: size.height * 0.09)
                    .stroke(
                        Color.white.opacity(0.42 + Double(index) * 0.16),
                        style: StrokeStyle(lineWidth: 4.5 * scale, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: size.width * 0.72, height: size.height * 0.24)
                    .position(
                        x: size.width * 0.5,
                        y: size.height * (0.38 + CGFloat(index) * 0.17)
                    )
            }

            Circle()
                .fill(Color.white.opacity(0.34))
                .frame(width: 18 * scale, height: 18 * scale)
                .position(x: size.width * 0.74, y: size.height * 0.31)
        }
    }
}

private struct ForestArtwork: View {
    let size: CGSize

    var body: some View {
        let scale = artworkScale(for: size)

        ZStack {
            ForEach(0..<4, id: \.self) { index in
                tree(index: index, scale: scale)
                    .position(
                        x: size.width * (0.28 + CGFloat(index) * 0.15),
                        y: size.height * (0.54 + CGFloat(index % 2) * 0.05)
                    )
            }

            SoundWaveLine(amplitude: size.height * 0.035)
                .stroke(
                    Color.white.opacity(0.35),
                    style: StrokeStyle(lineWidth: 3 * scale, lineCap: .round, lineJoin: .round)
                )
                .frame(width: size.width * 0.58, height: size.height * 0.1)
                .position(x: size.width * 0.5, y: size.height * 0.78)
        }
    }

    private func tree(index: Int, scale: CGFloat) -> some View {
        let treeScale = scale * (0.9 + CGFloat(index % 2) * 0.16)
        return ZStack {
            Capsule()
                .fill(Color.bbInk.opacity(0.18))
                .frame(width: 7 * treeScale, height: 28 * treeScale)
                .offset(y: 26 * treeScale)

            TriangleShape()
                .fill(Color.white.opacity(0.68))
                .frame(width: 44 * treeScale, height: 48 * treeScale)
                .offset(y: 4 * treeScale)

            TriangleShape()
                .fill(Color.white.opacity(0.48))
                .frame(width: 34 * treeScale, height: 38 * treeScale)
                .offset(y: -14 * treeScale)
        }
    }
}

private struct BrookArtwork: View {
    let size: CGSize

    var body: some View {
        let scale = artworkScale(for: size)

        ZStack {
            ForEach(0..<3, id: \.self) { index in
                SoundWaveLine(amplitude: size.height * 0.045)
                    .stroke(
                        Color.white.opacity(0.4 + Double(index) * 0.14),
                        style: StrokeStyle(lineWidth: 4 * scale, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: size.width * 0.68, height: size.height * 0.13)
                    .rotationEffect(.degrees(-5))
                    .position(
                        x: size.width * 0.5,
                        y: size.height * (0.42 + CGFloat(index) * 0.13)
                    )
            }

            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(Color.bbInk.opacity(0.10))
                    .frame(
                        width: (12 + CGFloat(index % 2) * 5) * scale,
                        height: (8 + CGFloat(index % 2) * 4) * scale
                    )
                    .position(
                        x: size.width * (0.26 + CGFloat(index) * 0.12),
                        y: size.height * (0.73 + CGFloat(index % 2) * 0.05)
                    )
            }
        }
    }
}

private struct HairDryerArtwork: View {
    let size: CGSize

    var body: some View {
        let scale = artworkScale(for: size)

        ZStack {
            dryer(scale: scale)
                .frame(width: size.width * 0.48, height: size.height * 0.48)
                .position(x: size.width * 0.36, y: size.height * 0.48)

            ForEach(0..<3, id: \.self) { index in
                SoundWaveLine(amplitude: size.height * 0.035)
                    .stroke(
                        Color.white.opacity(0.44 + Double(index) * 0.12),
                        style: StrokeStyle(lineWidth: 3.5 * scale, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: size.width * 0.34, height: size.height * 0.11)
                    .position(
                        x: size.width * 0.68,
                        y: size.height * (0.36 + CGFloat(index) * 0.14)
                    )
            }
        }
    }

    private func dryer(scale: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.72))
                .frame(width: 70 * scale, height: 38 * scale)
                .offset(x: -7 * scale, y: -6 * scale)

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.52))
                .frame(width: 26 * scale, height: 44 * scale)
                .rotationEffect(.degrees(-18))
                .offset(x: 2 * scale, y: 25 * scale)

            Capsule()
                .fill(Color.bbInk.opacity(0.12))
                .frame(width: 26 * scale, height: 18 * scale)
                .offset(x: 38 * scale, y: -7 * scale)

            Circle()
                .stroke(Color.bbInk.opacity(0.16), lineWidth: 3 * scale)
                .frame(width: 20 * scale, height: 20 * scale)
                .offset(x: -22 * scale, y: -6 * scale)
        }
    }
}

private struct LullabyArtwork: View {
    let size: CGSize

    var body: some View {
        ZStack {
            CrescentShape()
                .fill(Color.white.opacity(0.78), style: FillStyle(eoFill: true))
                .frame(width: size.width * 0.24, height: size.width * 0.24)
                .position(x: size.width * 0.34, y: size.height * 0.4)

            MusicNoteShape()
                .fill(Color.white.opacity(0.64))
                .frame(width: size.width * 0.16, height: size.height * 0.42)
                .position(x: size.width * 0.62, y: size.height * 0.52)

            ForEach(0..<4, id: \.self) { index in
                StarSparkShape()
                    .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.58 : 0.38))
                    .frame(width: 11 + CGFloat(index % 2) * 5, height: 11 + CGFloat(index % 2) * 5)
                    .position(
                        x: size.width * (0.28 + CGFloat(index) * 0.15),
                        y: size.height * (0.24 + CGFloat(index % 2) * 0.48)
                    )
            }
        }
    }
}

private struct HeartbeatArtwork: View {
    let size: CGSize

    var body: some View {
        let scale = artworkScale(for: size)

        ZStack {
            SoundHeartShape()
                .fill(Color.white.opacity(0.68))
                .frame(width: size.width * 0.24, height: size.height * 0.35)
                .position(x: size.width * 0.34, y: size.height * 0.5)

            HeartbeatLineShape()
                .stroke(
                    Color.white.opacity(0.78),
                    style: StrokeStyle(lineWidth: 4 * scale, lineCap: .round, lineJoin: .round)
                )
                .frame(width: size.width * 0.52, height: size.height * 0.26)
                .position(x: size.width * 0.58, y: size.height * 0.5)
        }
    }
}

private struct WombArtwork: View {
    let size: CGSize

    var body: some View {
        let scale = artworkScale(for: size)

        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .stroke(
                        Color.white.opacity(0.28 + Double(index) * 0.16),
                        style: StrokeStyle(lineWidth: 4 * scale, lineCap: .round)
                    )
                    .frame(
                        width: size.width * (0.34 + CGFloat(index) * 0.13),
                        height: size.height * (0.34 + CGFloat(index) * 0.13)
                    )
                    .position(x: size.width * 0.5, y: size.height * 0.51)
            }

            Circle()
                .fill(Color.white.opacity(0.76))
                .frame(width: size.height * 0.24, height: size.height * 0.24)
                .position(x: size.width * 0.5, y: size.height * 0.51)
        }
    }
}

private func artworkScale(for size: CGSize) -> CGFloat {
    max(min(size.width / 150, size.height / 90), 0.7)
}

private struct SoundWaveLine: Shape {
    let amplitude: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let segment = rect.width / 4

        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        for index in 0..<4 {
            let controlY = index.isMultiple(of: 2) ? rect.midY - amplitude : rect.midY + amplitude
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + segment * CGFloat(index + 1), y: rect.midY),
                control: CGPoint(x: rect.minX + segment * (CGFloat(index) + 0.5), y: controlY)
            )
        }

        return path
    }
}

private struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct CrescentShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        path.addEllipse(in: rect.offsetBy(dx: rect.width * 0.28, dy: -rect.height * 0.08))
        return path
    }
}

private struct MusicNoteShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stemWidth = rect.width * 0.18
        let noteRadius = rect.width * 0.28

        path.addRoundedRect(
            in: CGRect(
                x: rect.midX - stemWidth / 2,
                y: rect.minY,
                width: stemWidth,
                height: rect.height * 0.72
            ),
            cornerSize: CGSize(width: stemWidth, height: stemWidth)
        )
        path.addEllipse(
            in: CGRect(
                x: rect.minX,
                y: rect.maxY - noteRadius * 1.25,
                width: noteRadius * 1.35,
                height: noteRadius
            )
        )
        path.addRoundedRect(
            in: CGRect(
                x: rect.midX - stemWidth / 2,
                y: rect.minY,
                width: rect.width * 0.48,
                height: stemWidth
            ),
            cornerSize: CGSize(width: stemWidth, height: stemWidth)
        )

        return path
    }
}

private struct StarSparkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + rect.width * 0.12, y: rect.midY - rect.height * 0.12))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX + rect.width * 0.12, y: rect.midY + rect.height * 0.12))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - rect.width * 0.12, y: rect.midY + rect.height * 0.12))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX - rect.width * 0.12, y: rect.midY - rect.height * 0.12))
        path.closeSubpath()
        return path
    }
}

private struct SoundHeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.height * 0.35),
            control1: CGPoint(x: rect.width * 0.18, y: rect.height * 0.78),
            control2: CGPoint(x: rect.minX, y: rect.height * 0.58)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.height * 0.28),
            control1: CGPoint(x: rect.minX, y: rect.height * 0.12),
            control2: CGPoint(x: rect.width * 0.34, y: rect.height * 0.08)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.height * 0.35),
            control1: CGPoint(x: rect.width * 0.66, y: rect.height * 0.08),
            control2: CGPoint(x: rect.maxX, y: rect.height * 0.12)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.height * 0.58),
            control2: CGPoint(x: rect.width * 0.82, y: rect.height * 0.78)
        )
        return path
    }
}

private struct HeartbeatLineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width * 0.18, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width * 0.28, y: rect.height * 0.28))
        path.addLine(to: CGPoint(x: rect.width * 0.38, y: rect.height * 0.72))
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.18))
        path.addLine(to: CGPoint(x: rect.width * 0.64, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
