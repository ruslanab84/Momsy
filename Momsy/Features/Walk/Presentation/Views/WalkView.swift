import SwiftUI

enum WalkPosterPalette {
    static let paper = Color(bbHex: "FFF9F0")
    static let ink = Color(bbHex: "3D2A20")
    static let inkSoft = Color(bbHex: "6B5446")
    static let inkMute = Color(bbHex: "8F7B6C")
}

struct WalkView: View {
    @ObservedObject var vm: WalkViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject private var units: UnitSystemManager
    @State private var showAddManual = false

    private var completedEntries: [WalkEntry] {
        Array(vm.todayEntries.filter { $0.endDate != nil }.reversed())
    }

    var body: some View {
        ZStack {
            WalkScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    topBar
                    posterCard
                    actionButton
                    todayList
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .errorToast($vm.saveError)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { vm.syncTimerWithStartDate() }
        }
        .sheet(isPresented: $showAddManual) {
            AddWalkEntrySheet(vm: vm)
                .environmentObject(loc)
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.strings.walkTracker)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
                    .kerning(0.5)
                Text(loc.strings.walk)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 8)

            Button { showAddManual = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .heavy))
                    Text(loc.strings.enterManuallyLabel)
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .foregroundStyle(Color.bbMintDeep)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.86))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button { dismiss() } label: {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var posterCard: some View {
        ZStack {
            posterBackground

            VStack(spacing: 18) {
                posterHeader
                timerBlock
                WalkDottedLine()
                    .stroke(Color.bbMintDeep.opacity(0.28), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [1, 7]))
                    .frame(height: 1)
                    .padding(.horizontal, 26)
                posterMetrics
            }
            .padding(.horizontal, 24)
            .padding(.top, 34)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 1)
        )
        .bbShadow()
        .overlay(alignment: .topLeading) {
            WalkSprig()
                .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(width: 64, height: 86)
                .padding(.leading, 22)
                .padding(.top, 20)
        }
        .overlay(alignment: .bottomTrailing) {
            WalkSprig()
                .stroke(Color.white.opacity(0.84), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(width: 58, height: 78)
                .rotationEffect(.degrees(185))
                .padding(.trailing, 18)
                .padding(.bottom, 18)
        }
    }

    private var posterBackground: some View {
        ZStack {
            WalkPosterPalette.paper

            WalkOrganicBlob(variant: .topLeading)
                .fill(Color.bbMint.opacity(0.42))
                .frame(width: 260, height: 190)
                .offset(x: -88, y: -60)

            WalkOrganicBlob(variant: .topTrailing)
                .fill(Color.bbSky.opacity(0.24))
                .frame(width: 190, height: 168)
                .offset(x: 118, y: -70)

            WalkOrganicBlob(variant: .bottomTrailing)
                .fill(Color.bbMintDeep.opacity(0.18))
                .frame(width: 235, height: 220)
                .offset(x: 112, y: 174)

            Image(systemName: "star.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.bbMintDeep.opacity(0.38))
                .offset(x: 112, y: 58)

            Circle()
                .fill(Color.bbSky.opacity(0.46))
                .frame(width: 11, height: 11)
                .offset(x: -112, y: 132)
        }
    }

    private var posterHeader: some View {
        VStack(spacing: 12) {
            CuteBlobView(kind: .walk, size: 58, tone: Color.bbMint.opacity(0.32))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.88), lineWidth: 1)
                )

            Text(loc.strings.walkTracker)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.bbMintDeep)
                .kerning(0.6)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, 22)
                .padding(.vertical, 9)
                .background(Color.bbMint.opacity(0.22))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.78), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                )
        }
    }

    private var timerBlock: some View {
        VStack(spacing: 8) {
            if vm.isWalkActive {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.bbMintDeep)
                        .frame(width: 8, height: 8)
                    Text(loc.strings.walking)
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(WalkPosterPalette.inkSoft)
                }

                Text(vm.walkTimerString)
                    .font(.system(size: 58, weight: .heavy, design: .monospaced))
                    .foregroundStyle(WalkPosterPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.3), value: vm.walkSeconds)
            } else {
                Text(vm.lastWalkDurationString)
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(WalkPosterPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)

                Text(vm.lastWalkSubtitle)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(WalkPosterPalette.inkSoft)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }

    private var posterMetrics: some View {
        VStack(spacing: 12) {
            posterMetric(
                icon: "clock.fill",
                label: loc.strings.totalToday,
                value: vm.totalWalksToday
            )
            posterMetric(
                icon: "stroller",
                label: loc.strings.sessions,
                value: "\(completedEntries.count)"
            )
        }
        .padding(.horizontal, 10)
    }

    private func posterMetric(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Color.bbMintDeep)
                .frame(width: 34, height: 34)
                .background(Color.bbMint.opacity(0.22))
                .clipShape(Circle())

            Text(label)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(WalkPosterPalette.inkSoft)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(WalkPosterPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var actionButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if vm.isWalkActive { vm.stop() } else { vm.start() }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: vm.isWalkActive ? "stop.fill" : "stroller")
                    .font(.system(size: 16, weight: .bold))
                Text(vm.isWalkActive ? loc.strings.stopWalk : loc.strings.startWalk)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(vm.isWalkActive ? Color.bbMintDeep : Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(vm.isWalkActive ? Color.white : Color.bbMintDeep)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(vm.isWalkActive ? 0.85 : 0.26), lineWidth: 1)
            )
            .bbShadowSoft()
            .animation(.easeInOut(duration: 0.2), value: vm.isWalkActive)
        }
        .buttonStyle(.plain)
    }

    private var todayList: some View {
        Group {
            if !completedEntries.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(loc.strings.todayUpper)
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.bbMintDeep)
                            .kerning(0.5)
                        Spacer()
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.bbMintDeep.opacity(0.55))
                    }
                    .padding(.bottom, 10)

                    ForEach(Array(completedEntries.enumerated()), id: \.element.id) { idx, entry in
                        HStack(spacing: 12) {
                            Text(entry.startDate, format: units.current.timeFormatStyle())
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(WalkPosterPalette.inkMute)
                                .frame(width: units.isImperial ? 68 : 46, alignment: .leading)

                            Image(systemName: "stroller")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.bbMintDeep)
                                .frame(width: 28, height: 28)
                                .background(Color.bbMint.opacity(0.2))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.durationMinutes.map { loc.strings.durationFormatted($0) } ?? "-")
                                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                                    .foregroundStyle(WalkPosterPalette.ink)
                                Text(loc.strings.walk)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(WalkPosterPalette.inkMute)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 9)

                        if idx < completedEntries.count - 1 {
                            WalkDottedLine()
                                .stroke(Color.bbMintDeep.opacity(0.18), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [1, 6]))
                                .frame(height: 1)
                                .padding(.leading, 58)
                        }
                    }
                }
                .padding(16)
                .background(WalkPosterPalette.paper.opacity(0.94))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.68), lineWidth: 1)
                )
                .bbShadowSoft()
            }
        }
    }
}

struct WalkScreenBackground: View {
    var body: some View {
        ZStack {
            Color.bbMint.ignoresSafeArea()

            WalkOrganicBlob(variant: .screenTop)
                .fill(Color.bbMintDeep.opacity(0.22))
                .frame(width: 320, height: 250)
                .offset(x: 120, y: -210)
                .ignoresSafeArea()

            WalkOrganicBlob(variant: .screenBottom)
                .fill(Color.bbSky.opacity(0.22))
                .frame(width: 330, height: 270)
                .offset(x: -150, y: 230)
                .ignoresSafeArea()
        }
    }
}

enum WalkOrganicBlobVariant {
    case topLeading
    case topTrailing
    case bottomTrailing
    case screenTop
    case screenBottom
}

struct WalkOrganicBlob: Shape {
    let variant: WalkOrganicBlobVariant

    func path(in rect: CGRect) -> Path {
        let x = rect.minX
        let y = rect.minY
        let w = rect.width
        let h = rect.height

        var path = Path()

        switch variant {
        case .topLeading:
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + w * 0.86, y: y))
            path.addCurve(
                to: CGPoint(x: x + w * 0.70, y: y + h * 0.70),
                control1: CGPoint(x: x + w * 1.02, y: y + h * 0.22),
                control2: CGPoint(x: x + w * 0.98, y: y + h * 0.60)
            )
            path.addCurve(
                to: CGPoint(x: x, y: y + h),
                control1: CGPoint(x: x + w * 0.42, y: y + h * 0.82),
                control2: CGPoint(x: x + w * 0.22, y: y + h * 0.78)
            )
            path.closeSubpath()

        case .topTrailing:
            path.move(to: CGPoint(x: x + w, y: y))
            path.addLine(to: CGPoint(x: x + w, y: y + h))
            path.addCurve(
                to: CGPoint(x: x + w * 0.12, y: y + h * 0.62),
                control1: CGPoint(x: x + w * 0.78, y: y + h * 0.94),
                control2: CGPoint(x: x + w * 0.12, y: y + h * 1.03)
            )
            path.addCurve(
                to: CGPoint(x: x + w * 0.34, y: y),
                control1: CGPoint(x: x + w * 0.12, y: y + h * 0.30),
                control2: CGPoint(x: x + w * 0.18, y: y + h * 0.08)
            )
            path.closeSubpath()

        case .bottomTrailing:
            path.move(to: CGPoint(x: x + w, y: y + h))
            path.addLine(to: CGPoint(x: x + w * 0.18, y: y + h))
            path.addCurve(
                to: CGPoint(x: x + w * 0.32, y: y + h * 0.22),
                control1: CGPoint(x: x - w * 0.05, y: y + h * 0.78),
                control2: CGPoint(x: x + w * 0.02, y: y + h * 0.34)
            )
            path.addCurve(
                to: CGPoint(x: x + w, y: y + h * 0.02),
                control1: CGPoint(x: x + w * 0.66, y: y + h * 0.03),
                control2: CGPoint(x: x + w * 0.74, y: y + h * 0.06)
            )
            path.closeSubpath()

        case .screenTop:
            path.move(to: CGPoint(x: x, y: y + h * 0.04))
            path.addCurve(
                to: CGPoint(x: x + w, y: y + h * 0.18),
                control1: CGPoint(x: x + w * 0.30, y: y - h * 0.12),
                control2: CGPoint(x: x + w * 0.78, y: y - h * 0.08)
            )
            path.addCurve(
                to: CGPoint(x: x + w * 0.66, y: y + h),
                control1: CGPoint(x: x + w * 1.12, y: y + h * 0.50),
                control2: CGPoint(x: x + w * 0.98, y: y + h * 0.88)
            )
            path.addCurve(
                to: CGPoint(x: x, y: y + h * 0.78),
                control1: CGPoint(x: x + w * 0.34, y: y + h * 1.12),
                control2: CGPoint(x: x + w * 0.08, y: y + h * 0.96)
            )
            path.closeSubpath()

        case .screenBottom:
            path.move(to: CGPoint(x: x + w * 0.10, y: y + h))
            path.addCurve(
                to: CGPoint(x: x + w * 0.04, y: y + h * 0.24),
                control1: CGPoint(x: x - w * 0.10, y: y + h * 0.78),
                control2: CGPoint(x: x - w * 0.08, y: y + h * 0.44)
            )
            path.addCurve(
                to: CGPoint(x: x + w * 0.82, y: y + h * 0.10),
                control1: CGPoint(x: x + w * 0.24, y: y + h * 0.02),
                control2: CGPoint(x: x + w * 0.62, y: y - h * 0.06)
            )
            path.addCurve(
                to: CGPoint(x: x + w * 0.88, y: y + h),
                control1: CGPoint(x: x + w * 1.06, y: y + h * 0.32),
                control2: CGPoint(x: x + w * 1.16, y: y + h * 0.78)
            )
            path.closeSubpath()
        }

        return path
    }
}

struct WalkDottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

struct WalkSprig: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let x = rect.minX
        let y = rect.minY
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: x + w * 0.15, y: y + h))
        path.addCurve(
            to: CGPoint(x: x + w * 0.72, y: y + h * 0.06),
            control1: CGPoint(x: x + w * 0.24, y: y + h * 0.62),
            control2: CGPoint(x: x + w * 0.46, y: y + h * 0.24)
        )

        path.move(to: CGPoint(x: x + w * 0.34, y: y + h * 0.62))
        path.addQuadCurve(
            to: CGPoint(x: x + w * 0.06, y: y + h * 0.48),
            control: CGPoint(x: x + w * 0.12, y: y + h * 0.58)
        )

        path.move(to: CGPoint(x: x + w * 0.42, y: y + h * 0.48))
        path.addQuadCurve(
            to: CGPoint(x: x + w * 0.78, y: y + h * 0.38),
            control: CGPoint(x: x + w * 0.66, y: y + h * 0.50)
        )

        path.move(to: CGPoint(x: x + w * 0.53, y: y + h * 0.30))
        path.addQuadCurve(
            to: CGPoint(x: x + w * 0.20, y: y + h * 0.18),
            control: CGPoint(x: x + w * 0.32, y: y + h * 0.28)
        )

        return path
    }
}
