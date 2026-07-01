import SwiftUI

enum BathPosterPalette {
    static let paper = Color(bbHex: "FFF9F0")
    static let paperSoft = Color(bbHex: "EEF8FF")
    static let ink = Color(bbHex: "3D2A20")
    static let inkSoft = Color(bbHex: "6B5446")
    static let inkMute = Color(bbHex: "8F7B6C")
}

struct BathView: View {
    @ObservedObject var vm: BathViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loc: LocalizationManager
    @State private var showAddManual = false

    private var completedEntries: [BathEntry] {
        Array(vm.todayEntries.filter { $0.endDate != nil }.reversed())
    }

    var body: some View {
        ZStack {
            BathScreenBackground()

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
            AddBathEntrySheet(vm: vm)
                .environmentObject(loc)
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.strings.bathTracker)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.74))
                    .kerning(0.5)
                Text(loc.strings.bath)
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
                .foregroundStyle(Color.bbSkyDeep)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(BathPosterPalette.paper.opacity(0.92))
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
                BathDottedLine()
                    .stroke(Color.bbSkyDeep.opacity(0.28), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [1, 7]))
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
    }

    private var posterBackground: some View {
        ZStack {
            BathPosterPalette.paper

            BathOrganicBlob(variant: .topLeading)
                .fill(Color.bbSky.opacity(0.34))
                .frame(width: 260, height: 190)
                .offset(x: -88, y: -60)

            BathOrganicBlob(variant: .topTrailing)
                .fill(Color.bbMint.opacity(0.22))
                .frame(width: 190, height: 168)
                .offset(x: 118, y: -70)

            BathOrganicBlob(variant: .bottomTrailing)
                .fill(Color.bbSkyDeep.opacity(0.16))
                .frame(width: 235, height: 220)
                .offset(x: 112, y: 174)

            BathBottleIcon(tint: Color.bbSkyDeep.opacity(0.32))
                .frame(width: 34, height: 56)
                .rotationEffect(.degrees(-12))
                .offset(x: -116, y: 86)

            BathCreamIcon(tint: Color.bbMintDeep.opacity(0.28))
                .frame(width: 48, height: 34)
                .offset(x: 116, y: 66)

            BathBubbles(color: Color.bbSkyDeep.opacity(0.28))
                .frame(width: 70, height: 60)
                .offset(x: 94, y: -92)
        }
    }

    private var posterHeader: some View {
        VStack(spacing: 12) {
            CuteBlobView(kind: .bath, size: 58, tone: Color.bbSky.opacity(0.28))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.88), lineWidth: 1)
                )

            Text(loc.strings.bathTracker)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.bbSkyDeep)
                .kerning(0.6)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, 22)
                .padding(.vertical, 9)
                .background(Color.bbSky.opacity(0.22))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.78), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                )
        }
    }

    private var timerBlock: some View {
        VStack(spacing: 8) {
            if vm.isBathActive {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.bbSkyDeep)
                        .frame(width: 8, height: 8)
                    Text(loc.strings.bathing)
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(BathPosterPalette.inkSoft)
                }

                Text(vm.bathTimerString)
                    .font(.system(size: 58, weight: .heavy, design: .monospaced))
                    .foregroundStyle(BathPosterPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.3), value: vm.bathSeconds)
            } else {
                Text(vm.lastBathDurationString)
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(BathPosterPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)

                Text(vm.lastBathSubtitle)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(BathPosterPalette.inkSoft)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }

    private var posterMetrics: some View {
        VStack(spacing: 12) {
            posterMetric(icon: "clock.fill", label: loc.strings.totalToday, value: vm.totalBathsToday)
            posterMetric(icon: "bathtub", label: loc.strings.sessions, value: "\(completedEntries.count)")
        }
        .padding(.horizontal, 10)
    }

    private func posterMetric(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Color.bbSkyDeep)
                .frame(width: 34, height: 34)
                .background(Color.bbSky.opacity(0.22))
                .clipShape(Circle())

            Text(label)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(BathPosterPalette.inkSoft)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(BathPosterPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var actionButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if vm.isBathActive { vm.stop() } else { vm.start() }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: vm.isBathActive ? "stop.fill" : "bathtub")
                    .font(.system(size: 16, weight: .bold))
                Text(vm.isBathActive ? loc.strings.stopBath : loc.strings.startBath)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(vm.isBathActive ? Color.bbSkyDeep : Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(vm.isBathActive ? BathPosterPalette.paper.opacity(0.95) : Color.bbSkyDeep)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(vm.isBathActive ? 0.85 : 0.26), lineWidth: 1)
            )
            .bbShadowSoft()
            .animation(.easeInOut(duration: 0.2), value: vm.isBathActive)
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
                            .foregroundStyle(Color.bbSkyDeep)
                            .kerning(0.5)
                        Spacer()
                        BathBubbles(color: Color.bbSkyDeep.opacity(0.38))
                            .frame(width: 30, height: 22)
                    }
                    .padding(.bottom, 10)

                    ForEach(Array(completedEntries.enumerated()), id: \.element.id) { idx, entry in
                        HStack(spacing: 12) {
                            Text(DateFormatter.bbTime.string(from: entry.startDate))
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(BathPosterPalette.inkMute)
                                .frame(width: 46, alignment: .leading)

                            Image(systemName: "bathtub")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.bbSkyDeep)
                                .frame(width: 28, height: 28)
                                .background(Color.bbSky.opacity(0.2))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.durationMinutes.map { loc.strings.durationFormatted($0) } ?? "-")
                                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                                    .foregroundStyle(BathPosterPalette.ink)
                                Text(loc.strings.bath)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(BathPosterPalette.inkMute)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 9)

                        if idx < completedEntries.count - 1 {
                            BathDottedLine()
                                .stroke(Color.bbSkyDeep.opacity(0.18), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [1, 6]))
                                .frame(height: 1)
                                .padding(.leading, 58)
                        }
                    }
                }
                .padding(16)
                .background(BathPosterPalette.paper.opacity(0.94))
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

struct BathScreenBackground: View {
    var body: some View {
        ZStack {
            Color.bbSky.ignoresSafeArea()

            BathOrganicBlob(variant: .screenTop)
                .fill(Color.bbSkyDeep.opacity(0.20))
                .frame(width: 330, height: 260)
                .offset(x: 120, y: -218)
                .ignoresSafeArea()

            BathOrganicBlob(variant: .screenBottom)
                .fill(Color.bbMint.opacity(0.22))
                .frame(width: 330, height: 270)
                .offset(x: -148, y: 230)
                .ignoresSafeArea()

            BathBottleIcon(tint: Color.white.opacity(0.28))
                .frame(width: 48, height: 76)
                .rotationEffect(.degrees(-12))
                .offset(x: 118, y: -156)
                .accessibilityHidden(true)

            BathCreamIcon(tint: Color.white.opacity(0.24))
                .frame(width: 66, height: 44)
                .offset(x: -126, y: 124)
                .accessibilityHidden(true)

            BathBubbles(color: Color.white.opacity(0.28))
                .frame(width: 90, height: 74)
                .offset(x: 120, y: 220)
                .accessibilityHidden(true)
        }
    }
}

enum BathOrganicBlobVariant {
    case topLeading
    case topTrailing
    case bottomTrailing
    case screenTop
    case screenBottom
}

struct BathOrganicBlob: Shape {
    let variant: BathOrganicBlobVariant

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

struct BathDottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

struct BathBubbles: View {
    let color: Color

    var body: some View {
        ZStack {
            Circle().stroke(color, lineWidth: 3).frame(width: 22, height: 22).offset(x: -18, y: 10)
            Circle().stroke(color, lineWidth: 3).frame(width: 14, height: 14).offset(x: 12, y: -14)
            Circle().stroke(color, lineWidth: 3).frame(width: 30, height: 30).offset(x: 20, y: 14)
            Circle().fill(color.opacity(0.42)).frame(width: 8, height: 8).offset(x: -4, y: -22)
        }
    }
}

struct BathBottleIcon: View {
    let tint: Color

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(tint)
                .frame(width: 18, height: 10)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(tint)
                .frame(width: 34, height: 46)
                .overlay(
                    Capsule()
                        .fill(Color.white.opacity(0.38))
                        .frame(width: 18, height: 5)
                        .offset(y: 4)
                )
        }
    }
}

struct BathCreamIcon: View {
    let tint: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(tint)
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.white.opacity(0.32))
                    .frame(width: 24, height: 9)
            )
    }
}
