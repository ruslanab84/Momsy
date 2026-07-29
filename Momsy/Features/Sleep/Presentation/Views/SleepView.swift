import SwiftUI

enum SleepPosterPalette {
    static let paper = Color(bbHex: "FFF9F0")
    static let paperSoft = Color(bbHex: "F3EEFF")
    static let ink = Color(bbHex: "3D2A20")
    static let inkSoft = Color(bbHex: "6B5446")
    static let inkMute = Color(bbHex: "8F7B6C")
}

struct SleepView: View {
    @ObservedObject var vm: SleepViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loc: LocalizationManager

    @State private var showAddManual = false

    private var cardInk: Color { SleepPosterPalette.ink }
    private var cardInkSoft: Color { SleepPosterPalette.inkSoft }
    private var cardInkMute: Color { SleepPosterPalette.inkMute }
    private var timerRingColor: Color { Color.bbLilacDeep }

    var body: some View {
        ZStack {
            SleepScreenBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    topBar
                    if let prediction = vm.nextSleep {
                        NextSleepCard(prediction: prediction)
                    }
                    statsRow
                    timerBlock
                    if vm.isSleepActive { qualityPicker }
                    actionButton
                    SleepChartSection(
                        days: vm.sleepDays,
                        normMin: vm.sleepNorm.min,
                        normMax: vm.sleepNorm.max,
                        selectedPeriod: $vm.selectedChartPeriod,
                        lang: loc.lang
                    )
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .errorToast($vm.saveError)
        .errorToast($vm.coParentSessionNotice)
        .task { await vm.refreshForecast() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                vm.syncTimerWithStartDate()
                Task { await vm.refreshForecast() }
            }
        }
        .onChange(of: vm.selectedChartPeriod) {
            Task { await vm.loadChartData() }
        }
        .sheet(isPresented: $showAddManual) {
            AddSleepEntrySheet(vm: vm)
                .environmentObject(loc)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.strings.sleepTracker)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.74))
                    .kerning(0.5)
                Text(loc.strings.sleep)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
            Button { showAddManual = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 12, weight: .heavy))
                    Text(loc.strings.enterManuallyLabel)
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .foregroundStyle(Color.bbLilacDeep)
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background(SleepPosterPalette.paper.opacity(0.92))
                .clipShape(Capsule())
                .bbShadowSoft()
            }
            .buttonStyle(SleepPressButtonStyle())

            Button { dismiss() } label: {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(.white)
                    )
                    .bbShadowSoft()
            }
            .buttonStyle(SleepPressButtonStyle())
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statTile(
                icon: "clock.fill",
                label: loc.strings.totalToday,
                value: vm.totalSleepToday,
                tint: .bbLilacDeep,
                primary: cardInk,
                secondary: cardInkMute
            )

            statTile(
                icon: "number",
                label: loc.strings.sessions,
                value: "\(vm.todayEntries.filter { $0.endDate != nil }.count)",
                tint: .bbSkyDeep,
                primary: cardInk,
                secondary: cardInkMute
            )
        }
    }

    private func statTile(icon: String, label: String, value: String, tint: Color, primary: Color, secondary: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.13))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(SleepPosterPalette.paper.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.60), lineWidth: 1)
        )
        .bbShadowSoft()
    }

    // MARK: - Timer Block

    private var timerBlock: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Circle()
                    .fill(vm.isSleepActive ? Color.bbMintDeep : Color.bbButterDeep)
                    .frame(width: 8, height: 8)
                Text(vm.isSleepActive ? loc.strings.sleeping.uppercased() : vm.lastSleepSubtitle.uppercased())
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(cardInkSoft)
                    .kerning(1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.bbLilac.opacity(0.16))
            .clipShape(Capsule())

            ZStack {
                Circle()
                    .fill(Color.bbLilac.opacity(0.10))
                    .frame(width: 274, height: 274)

                Circle()
                    .stroke(Color.bbLilac.opacity(0.20), lineWidth: 18)
                    .frame(width: 246, height: 246)

                Circle()
                    .stroke(timerRingColor.opacity(vm.isSleepActive ? 0.88 : 0.58),
                            style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .frame(width: 246, height: 246)

                VStack(spacing: 8) {
                    Image(systemName: vm.isSleepActive ? "moon.zzz.fill" : "moon.stars.fill")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.bbLilacDeep)
                        .frame(width: 44, height: 44)
                        .background(Color.bbLilac.opacity(0.16))
                        .clipShape(Circle())

                    Text(vm.isSleepActive ? vm.sleepTimerString : vm.lastSleepDurationString)
                        .font(.system(size: vm.isSleepActive ? 56 : 50, weight: .heavy, design: vm.isSleepActive ? .monospaced : .rounded))
                        .foregroundColor(cardInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .contentTransition(.numericText())
                        .animation(.linear(duration: 0.3), value: vm.sleepSeconds)

                    Text(vm.isSleepActive ? loc.strings.asleep : vm.lastSleepSubtitle)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(cardInkSoft)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    if let attribution = vm.activeSessionAttribution {
                        Text(attribution)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(cardInkMute)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background {
            ZStack {
                SleepPosterPalette.paper

                SleepOrganicBlob(variant: .topLeading)
                    .fill(Color.bbLilac.opacity(0.34))
                    .frame(width: 250, height: 180)
                    .offset(x: -82, y: -66)

                SleepOrganicBlob(variant: .bottomTrailing)
                    .fill(Color.bbSky.opacity(0.18))
                    .frame(width: 230, height: 204)
                    .offset(x: 98, y: 134)

                Image(systemName: "star.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.bbLilacDeep.opacity(0.34))
                    .offset(x: 112, y: -72)

                Image(systemName: "cloud.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.70))
                    .offset(x: -112, y: 92)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 1)
        )
        .bbShadow()
    }

    // MARK: - Quality Picker

    private var qualityPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(loc.strings.sleepQuality)

            HStack(spacing: 10) {
                ForEach(SleepQuality.allCases, id: \.self) { quality in
                    qualityButton(quality)
                }
            }
        }
        .padding(16)
        .background(SleepPosterPalette.paper.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .bbShadowSoft()
    }

    private func qualityButton(_ quality: SleepQuality) -> some View {
        let isSelected = vm.selectedQuality == quality
        let tint = accent(for: quality)

        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                vm.selectedQuality = quality
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon(for: quality))
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(isSelected ? tint : SleepPosterPalette.inkMute)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? tint.opacity(0.16) : SleepPosterPalette.paperSoft)
                    .clipShape(Circle())

                Text(quality.localizedLabel(loc.strings))
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(isSelected ? tint : cardInkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(isSelected ? tint.opacity(0.10) : SleepPosterPalette.paperSoft.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? tint.opacity(0.28) : SleepPosterPalette.ink.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(SleepPressButtonStyle())
        .disabled(!vm.canUsePrimaryAction)
        .opacity(vm.canUsePrimaryAction ? 1 : 0.5)
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                if vm.isSleepActive { vm.stop() } else { vm.start() }
            }
        } label: {
            Label(vm.isSleepActive ? loc.strings.stopSleep : loc.strings.sleep,
                  systemImage: vm.isSleepActive ? "stop.fill" : "moon.fill")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(vm.isSleepActive ? .bbLilacDeep : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .background(vm.isSleepActive ? SleepPosterPalette.paper.opacity(0.95) : Color.bbLilacDeep)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .bbShadowSoft()
        }
        .buttonStyle(SleepPressButtonStyle())
        .disabled(!vm.canUsePrimaryAction)
        .opacity(vm.canUsePrimaryAction ? 1 : 0.5)
    }

    private func sectionLabel(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .foregroundColor(cardInkMute)
            .kerning(0.5)
            .textCase(.uppercase)
    }

    private func accent(for quality: SleepQuality) -> Color {
        switch quality {
        case .good:     return .bbMintDeep
        case .normal:   return .bbLilacDeep
        case .restless: return .bbRoseDeep
        }
    }

    private func icon(for quality: SleepQuality) -> String {
        switch quality {
        case .good:     return "sparkles"
        case .normal:   return "moon.fill"
        case .restless: return "wind"
        }
    }
}

private struct SleepPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SleepScreenBackground: View {
    var body: some View {
        ZStack {
            Color.bbLilac.ignoresSafeArea()

            SleepOrganicBlob(variant: .screenTop)
                .fill(Color.bbLilacDeep.opacity(0.18))
                .frame(width: 330, height: 260)
                .offset(x: 120, y: -218)
                .ignoresSafeArea()

            SleepOrganicBlob(variant: .screenBottom)
                .fill(Color.bbSky.opacity(0.22))
                .frame(width: 330, height: 270)
                .offset(x: -148, y: 230)
                .ignoresSafeArea()

            SleepOrganicBlob(variant: .screenBottom)
                .fill(Color.bbButter.opacity(0.16))
                .frame(width: 240, height: 220)
                .offset(x: 150, y: 320)
                .ignoresSafeArea()

            Image(systemName: "moon.stars.fill")
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.36))
                .offset(x: 122, y: -172)
                .accessibilityHidden(true)

            Image(systemName: "cloud.fill")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.25))
                .offset(x: -128, y: 110)
                .accessibilityHidden(true)

            Image(systemName: "sparkle")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.34))
                .offset(x: -86, y: -182)
                .accessibilityHidden(true)
        }
    }
}

enum SleepOrganicBlobVariant {
    case topLeading
    case bottomTrailing
    case screenTop
    case screenBottom
}

struct SleepOrganicBlob: Shape {
    let variant: SleepOrganicBlobVariant

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

#Preview {
    let container = AppContainer()
    SleepView(vm: container.makeSleepViewModel())
        .environmentObject(LocalizationManager.shared)
}
