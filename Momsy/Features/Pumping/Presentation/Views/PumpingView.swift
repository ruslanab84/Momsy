import SwiftUI

enum PumpingPosterPalette {
    static let paper = Color(bbHex: "FFF9F0")
    static let paperSoft = Color(bbHex: "FFF1F6")
    static let ink = Color(bbHex: "3D2A20")
    static let inkSoft = Color(bbHex: "6B5446")
    static let inkMute = Color(bbHex: "8F7B6C")
}

struct PumpingView: View {
    @ObservedObject var vm: PumpingViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loc: LocalizationManager
    @State private var showAddManual = false

    private var completedEntries: [PumpingEntry] {
        Array(vm.todayEntries.filter { $0.endDate != nil }.reversed())
    }

    var body: some View {
        ZStack {
            PumpingScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    topBar
                    posterCard
                    sideSelector
                    actionButton
                    volumeCard
                    todayList
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .errorToast($vm.saveError)
        .task { await vm.loadTodayEntries() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { vm.syncTimerWithStartDate() }
        }
        .sheet(isPresented: $showAddManual) {
            AddPumpingSheet(vm: vm)
                .environmentObject(loc)
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.strings.pumpingTracker)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.74))
                    .kerning(0.5)
                Text(loc.strings.pumping)
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
                .foregroundStyle(Color.bbRoseDeep)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(PumpingPosterPalette.paper.opacity(0.92))
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
                PumpingDottedLine()
                    .stroke(Color.bbRoseDeep.opacity(0.28), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [1, 7]))
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
            PumpingPosterPalette.paper

            PumpingOrganicBlob(variant: .topLeading)
                .fill(Color.bbRose.opacity(0.38))
                .frame(width: 260, height: 190)
                .offset(x: -88, y: -60)

            PumpingOrganicBlob(variant: .topTrailing)
                .fill(Color.bbLilac.opacity(0.24))
                .frame(width: 190, height: 168)
                .offset(x: 118, y: -70)

            PumpingOrganicBlob(variant: .bottomTrailing)
                .fill(Color.bbRoseDeep.opacity(0.16))
                .frame(width: 235, height: 220)
                .offset(x: 112, y: 174)

            Image(systemName: "drop.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.bbRoseDeep.opacity(0.34))
                .rotationEffect(.degrees(-14))
                .offset(x: -112, y: 92)

            Image(systemName: "heart.fill")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.bbLilacDeep.opacity(0.30))
                .offset(x: 112, y: 58)
        }
    }

    private var posterHeader: some View {
        VStack(spacing: 12) {
            CuteBlobView(kind: .pump, size: 58, tone: Color.bbRose.opacity(0.30))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.88), lineWidth: 1)
                )

            Text(loc.strings.pumpingTracker)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.bbRoseDeep)
                .kerning(0.6)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, 22)
                .padding(.vertical, 9)
                .background(Color.bbRose.opacity(0.20))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.78), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                )
        }
    }

    private var timerBlock: some View {
        VStack(spacing: 8) {
            if vm.isPumpingActive {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.bbRoseDeep)
                        .frame(width: 8, height: 8)
                    Text(activeSideText)
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(PumpingPosterPalette.inkSoft)
                }

                Text(vm.pumpingTimerString)
                    .font(.system(size: 58, weight: .heavy, design: .monospaced))
                    .foregroundStyle(PumpingPosterPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.3), value: vm.pumpingSeconds)
            } else {
                Text(vm.lastPumpingDurationString)
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(PumpingPosterPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)

                Text(vm.lastPumpingSubtitle)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(PumpingPosterPalette.inkSoft)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }

    private var activeSideText: String {
        "\(vm.selectedSide.displayName(lang: loc.lang)) · \(loc.strings.active)"
    }

    private var posterMetrics: some View {
        VStack(spacing: 12) {
            posterMetric(icon: "clock.fill", label: loc.strings.totalToday, value: vm.totalPumpingToday)
            posterMetric(icon: "drop.fill", label: loc.strings.sessions, value: "\(completedEntries.count)")
        }
        .padding(.horizontal, 10)
    }

    private func posterMetric(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Color.bbRoseDeep)
                .frame(width: 34, height: 34)
                .background(Color.bbRose.opacity(0.20))
                .clipShape(Circle())

            Text(label)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(PumpingPosterPalette.inkSoft)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(PumpingPosterPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var sideSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.strings.pumpingSideLabel)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.bbRoseDeep)
                .kerning(0.6)

            HStack(spacing: 8) {
                ForEach(PumpingSide.allCases, id: \.self) { side in
                    sideButton(side)
                }
            }
        }
        .padding(16)
        .background(PumpingPosterPalette.paper.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.68), lineWidth: 1)
        )
        .bbShadowSoft()
    }

    private func sideButton(_ side: PumpingSide) -> some View {
        let isSelected = vm.selectedSide == side
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                vm.selectedSide = side
            }
        } label: {
            Text(side.displayName(lang: loc.lang))
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(isSelected ? Color.bbRoseDeep : PumpingPosterPalette.inkMute)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(isSelected ? Color.bbRose.opacity(0.18) : PumpingPosterPalette.paperSoft.opacity(0.75))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.bbRoseDeep.opacity(0.24) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var actionButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if vm.isPumpingActive {
                    vm.stop()
                    dismiss()
                } else {
                    vm.start()
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: vm.isPumpingActive ? "stop.fill" : "drop.fill")
                    .font(.system(size: 16, weight: .bold))
                Text(vm.isPumpingActive ? loc.strings.pumpingStop : loc.strings.pumpingStart)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(vm.isPumpingActive ? Color.bbRoseDeep : Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(vm.isPumpingActive ? PumpingPosterPalette.paper.opacity(0.95) : Color.bbRoseDeep)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(vm.isPumpingActive ? 0.85 : 0.26), lineWidth: 1)
            )
            .bbShadowSoft()
            .animation(.easeInOut(duration: 0.2), value: vm.isPumpingActive)
        }
        .buttonStyle(.plain)
    }

    private var volumeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(loc.strings.pumpingVolume)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.bbRoseDeep)
                .kerning(0.6)

            HStack(spacing: 18) {
                volumeButton(systemImage: "minus") {
                    if vm.volumeML > 0 {
                        vm.volumeML = max(0, vm.volumeML - 10)
                    }
                }

                VStack(spacing: 2) {
                    Text("\(vm.volumeML) \(loc.strings.mlUnit)")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(PumpingPosterPalette.ink)
                        .frame(minWidth: 96, alignment: .center)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: vm.volumeML)

                    Text(loc.strings.pumpingVolume)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(PumpingPosterPalette.inkMute)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)

                volumeButton(systemImage: "plus") {
                    if vm.volumeML < 1000 {
                        vm.volumeML += 10
                    }
                }
            }
        }
        .padding(16)
        .background(PumpingPosterPalette.paper.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.68), lineWidth: 1)
        )
        .bbShadowSoft()
    }

    private func volumeButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.bbRoseDeep)
                .frame(width: 42, height: 42)
                .background(Color.bbRose.opacity(0.16))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.bbRoseDeep.opacity(0.18), lineWidth: 1)
                )
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
                            .foregroundStyle(Color.bbRoseDeep)
                            .kerning(0.5)
                        Spacer()
                        Image(systemName: "drop.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.bbRoseDeep.opacity(0.55))
                    }
                    .padding(.bottom, 10)

                    ForEach(Array(completedEntries.enumerated()), id: \.element.id) { idx, entry in
                        HStack(spacing: 12) {
                            Text(DateFormatter.bbTime.string(from: entry.date))
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(PumpingPosterPalette.inkMute)
                                .frame(width: 46, alignment: .leading)

                            Image(systemName: "drop.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.bbRoseDeep)
                                .frame(width: 28, height: 28)
                                .background(Color.bbRose.opacity(0.18))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(loc.strings.durationFormatted(entry.durationMinutes))
                                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                                    .foregroundStyle(PumpingPosterPalette.ink)
                                Text(entry.side.displayName(lang: loc.lang))
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(PumpingPosterPalette.inkMute)
                            }

                            Spacer(minLength: 8)

                            Text("\(entry.volumeML) \(loc.strings.mlUnit)")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundStyle(Color.bbRoseDeep)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .padding(.vertical, 9)

                        if idx < completedEntries.count - 1 {
                            PumpingDottedLine()
                                .stroke(Color.bbRoseDeep.opacity(0.18), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [1, 6]))
                                .frame(height: 1)
                                .padding(.leading, 58)
                        }
                    }
                }
                .padding(16)
                .background(PumpingPosterPalette.paper.opacity(0.94))
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

struct PumpingScreenBackground: View {
    var body: some View {
        ZStack {
            Color.bbRose.ignoresSafeArea()

            PumpingOrganicBlob(variant: .screenTop)
                .fill(Color.bbRoseDeep.opacity(0.20))
                .frame(width: 330, height: 260)
                .offset(x: 120, y: -218)
                .ignoresSafeArea()

            PumpingOrganicBlob(variant: .screenBottom)
                .fill(Color.bbLilac.opacity(0.22))
                .frame(width: 330, height: 270)
                .offset(x: -148, y: 230)
                .ignoresSafeArea()

            Image(systemName: "drop.fill")
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.24))
                .rotationEffect(.degrees(-12))
                .offset(x: 118, y: -156)
                .accessibilityHidden(true)

            Image(systemName: "heart.fill")
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.20))
                .offset(x: -126, y: 124)
                .accessibilityHidden(true)
        }
    }
}

enum PumpingOrganicBlobVariant {
    case topLeading
    case topTrailing
    case bottomTrailing
    case screenTop
    case screenBottom
}

struct PumpingOrganicBlob: Shape {
    let variant: PumpingOrganicBlobVariant

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

struct PumpingDottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
