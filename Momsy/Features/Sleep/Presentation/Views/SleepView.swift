import SwiftUI

struct SleepView: View {
    @ObservedObject var vm: SleepViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loc: LocalizationManager

    @State private var showAddManual = false

    var body: some View {
        ZStack {
            Color.bbLilac.ignoresSafeArea()
            Color.bbCreamSoft
                .opacity(0.22)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Color.bbLilac
                    .frame(height: 470)
                Color.bbCreamSoft
            }
            .ignoresSafeArea()

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
                    .foregroundColor(Color.bbInk.opacity(0.58))
                    .kerning(0.5)
                Text(loc.strings.sleep)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
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
                .foregroundColor(.bbInk)
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background(Color.white.opacity(0.76))
                .clipShape(Capsule())
                .bbShadowSoft()
            }
            .buttonStyle(SleepPressButtonStyle())

            Button { dismiss() } label: {
                Circle()
                    .fill(Color.white.opacity(0.78))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.bbInk)
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
                tint: .bbLilacDeep
            )

            statTile(
                icon: "number",
                label: loc.strings.sessions,
                value: "\(vm.todayEntries.filter { $0.endDate != nil }.count)",
                tint: .bbSkyDeep
            )
        }
    }

    private func statTile(icon: String, label: String, value: String, tint: Color) -> some View {
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
                    .foregroundColor(.bbInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.92))
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
                    .foregroundColor(Color.bbInk.opacity(0.62))
                    .kerning(1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.38))
            .clipShape(Capsule())

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 274, height: 274)

                Circle()
                    .stroke(Color.white.opacity(0.30), lineWidth: 18)
                    .frame(width: 246, height: 246)

                Circle()
                    .stroke(Color.white.opacity(vm.isSleepActive ? 0.88 : 0.52),
                            style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .frame(width: 246, height: 246)

                VStack(spacing: 8) {
                    Image(systemName: vm.isSleepActive ? "moon.zzz.fill" : "moon.stars.fill")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.bbLilacDeep)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.54))
                        .clipShape(Circle())

                    Text(vm.isSleepActive ? vm.sleepTimerString : vm.lastSleepDurationString)
                        .font(.system(size: vm.isSleepActive ? 56 : 50, weight: .heavy, design: vm.isSleepActive ? .monospaced : .rounded))
                        .foregroundColor(.bbInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .contentTransition(.numericText())
                        .animation(.linear(duration: 0.3), value: vm.sleepSeconds)

                    Text(vm.isSleepActive ? loc.strings.asleep : vm.lastSleepSubtitle)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color.bbInk.opacity(0.58))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.20), lineWidth: 1)
        )
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
        .background(Color.white.opacity(0.92))
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
                    .foregroundColor(isSelected ? tint : .bbInkMute)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? tint.opacity(0.16) : Color.bbCreamSoft)
                    .clipShape(Circle())

                Text(quality.localizedLabel(loc.strings))
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(isSelected ? tint : .bbInkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(isSelected ? tint.opacity(0.10) : Color.bbCreamSoft.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? tint.opacity(0.28) : Color.bbInk.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(SleepPressButtonStyle())
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
                .background(vm.isSleepActive ? Color.white.opacity(0.90) : Color.bbLilacDeep)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .bbShadowSoft()
        }
        .buttonStyle(SleepPressButtonStyle())
    }

    private func sectionLabel(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .foregroundColor(.bbInkMute)
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

#Preview {
    let container = AppContainer()
    SleepView(vm: container.makeSleepViewModel())
        .environmentObject(LocalizationManager.shared)
}
