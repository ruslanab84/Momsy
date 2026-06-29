import SwiftUI
import Combine

struct FeedingView: View {
    @ObservedObject var vm: FeedingViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.scenePhase) private var scenePhase

    @State private var selectedMoodIdx: Int? = nil
    @State private var customMood = ""
    @State private var showCustomInput = false
    @State private var showAddManual = false
    @State private var bottleML: Int = 120

    private let typicalSeconds = 18 * 60

    private var presetMoods: [String] {
        [loc.strings.moodCalm, loc.strings.moodAsleep, loc.strings.moodSpitUp]
    }

    private var moodNote: String? {
        if let idx = selectedMoodIdx { return presetMoods[idx] }
        let trimmed = customMood.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }

    var progress: Double { Double(vm.feedingSeconds) / Double(typicalSeconds) }
    private var clampedProgress: Double { min(max(progress, 0), 1) }

    var body: some View {
        ZStack {
            Color.bbCoral.ignoresSafeArea()
            Color.bbCreamSoft
                .opacity(0.18)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Color.bbCoral
                    .frame(height: 540)
                Color.bbCreamSoft
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    topBar
                    timerRing
                    sideToggle
                    actionButtons
                    if vm.feedingSide == .bottle {
                        bottleMlCard
                    } else {
                        noteCard
                    }
                    FeedingChartSection(
                        days: vm.feedingDays,
                        selectedPeriod: $vm.selectedChartPeriod,
                        lang: loc.lang
                    )
                    .environmentObject(loc)
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .task {
            await vm.loadTodayEntries()
            await vm.loadChartData()
        }
        .onAppear {
            vm.restoreOrStartFeeding(side: vm.feedingSide)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                vm.syncTimerWithStartDate()
            }
        }
        .onChange(of: vm.selectedChartPeriod) { _, _ in
            Task { await vm.loadChartData() }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Circle()
                    .fill(Color.white.opacity(0.78))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .heavy))
                            .foregroundColor(.bbInk)
                    )
                    .bbShadowSoft()
            }
            .buttonStyle(FeedingPressButtonStyle())
            Spacer()
            Text(loc.strings.feeding)
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
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
            .buttonStyle(FeedingPressButtonStyle())
            .sheet(isPresented: $showAddManual) {
                AddFeedingSheet(vm: vm)
                    .environmentObject(loc)
            }
        }
    }

    // MARK: - Timer Ring

    private var timerRing: some View {
        VStack(spacing: 16) {
            let sideLabel = vm.feedingSide.displayName(lang: loc.lang).uppercased()
            HStack(spacing: 8) {
                Circle()
                    .fill(vm.isFeedingActive ? Color.bbMintDeep : Color.bbButterDeep)
                    .frame(width: 8, height: 8)
                Text("\(sideLabel) · \(vm.isFeedingActive ? loc.strings.active : loc.strings.paused)")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.bbInk.opacity(0.62))
                    .kerning(1)
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
                    .trim(from: 0, to: CGFloat(clampedProgress))
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .frame(width: 246, height: 246)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: vm.feedingSeconds)

                VStack(spacing: 6) {
                    Text(vm.feedingTimerString)
                        .font(.system(size: 58, weight: .heavy, design: .monospaced))
                        .foregroundColor(.bbInk)
                        .contentTransition(.numericText())
                        .animation(.linear(duration: 0.4), value: vm.feedingSeconds)

                    Text(loc.strings.typicalDuration)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color.bbInk.opacity(0.58))
                }
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

    // MARK: - Side Toggle

    private var sideToggle: some View {
        HStack(spacing: 10) {
            ForEach(FeedingSide.allCases, id: \.self) { side in
                sideButton(side)
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.54))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.42), lineWidth: 1)
        )
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        Group {
            if !vm.feedingSessionExists {
                Button(action: {
                    vm.startFeeding(side: vm.feedingSide)
                }) {
                    Label(loc.strings.start, systemImage: "play.fill")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .background(Color.bbCoralDeep)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .bbShadowSoft()
                }
                .buttonStyle(FeedingPressButtonStyle())
            } else {
                HStack(spacing: 10) {
                    Button(action: {
                        if vm.isFeedingActive {
                            vm.pauseFeeding()
                        } else {
                            vm.resumeFeeding()
                        }
                    }) {
                        Label(vm.isFeedingActive ? loc.strings.pause : loc.strings.resume,
                              systemImage: vm.isFeedingActive ? "pause.fill" : "play.fill")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInk)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(FeedingPressButtonStyle())

                    Button(action: {
                        vm.stopFeeding(
                            mood: vm.feedingSide == .bottle ? nil : moodNote,
                            milliliters: vm.feedingSide == .bottle ? bottleML : nil
                        )
                        dismiss()
                    }) {
                        Label(loc.strings.stopDone, systemImage: "checkmark")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(Color.bbSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(FeedingPressButtonStyle())
                }
            }
        }
    }

    // MARK: - Note Card

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.strings.note)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.6)

            Group {
                if let note = moodNote {
                    Text(note)
                        .foregroundColor(.bbInkSoft)
                } else {
                    Text(loc.strings.tapTagMood)
                        .foregroundColor(.bbInkMute)
                }
            }
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .fixedSize(horizontal: false, vertical: true)
            .animation(.easeInOut(duration: 0.2), value: moodNote)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(presetMoods.indices, id: \.self) { i in
                        let isSelected = selectedMoodIdx == i
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.82)) {
                                selectedMoodIdx = isSelected ? nil : i
                                if !isSelected {
                                    customMood = ""
                                    showCustomInput = false
                                }
                            }
                        } label: {
                            Text(presetMoods[i])
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(isSelected ? .white : .bbInkSoft)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color.bbCoralDeep : Color.bbCreamSoft)
                                .clipShape(Capsule())
                                .animation(.spring(response: 0.25), value: isSelected)
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            showCustomInput.toggle()
                            if showCustomInput { selectedMoodIdx = nil }
                            else { customMood = "" }
                        }
                    } label: {
                        Text(showCustomInput ? loc.strings.cancelTag : loc.strings.customTag)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.bbInkSoft)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.clear)
                            .overlay(
                                Capsule().strokeBorder(
                                    Color.bbInkMute.opacity(0.3),
                                    style: StrokeStyle(lineWidth: 1.5, dash: [4])
                                )
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            if showCustomInput {
                HStack(spacing: 6) {
                    TextField(loc.strings.customMoodPlaceholder,
                              text: $customMood)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInk)
                        .submitLabel(.done)
                        .onSubmit {
                            withAnimation {
                                if !customMood.trimmingCharacters(in: .whitespaces).isEmpty {
                                    showCustomInput = false
                                }
                            }
                        }
                    if !customMood.isEmpty {
                        Button { customMood = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.bbInkMute)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.bbCreamSoft)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .bbCard(pad: 16, bg: Color.white.opacity(0.92), radius: 24)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showCustomInput)
    }

    // MARK: - Bottle ML Card

    private var bottleMlCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.strings.bottleVolume)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.6)

            HStack(spacing: 20) {
                Button {
                    if bottleML > 10 { bottleML -= 10 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.bbSkyDeep)
                        .clipShape(Circle())
                        .bbShadowSoft()
                }
                .buttonStyle(FeedingPressButtonStyle())

                Text("\(bottleML) \(loc.strings.mlUnit)")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                    .frame(minWidth: 90, alignment: .center)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.25), value: bottleML)

                Button {
                    if bottleML < 500 { bottleML += 10 }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.bbSkyDeep)
                        .clipShape(Circle())
                        .bbShadowSoft()
                }
                .buttonStyle(FeedingPressButtonStyle())
            }
            .padding(14)
            .background(Color.bbSky.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .bbCard(pad: 16, bg: Color.white.opacity(0.92), radius: 24)
    }

    private func sideButton(_ side: FeedingSide) -> some View {
        let isSelected = vm.feedingSide == side
        let tint = accent(for: side)

        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                vm.feedingSide = side
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon(for: side))
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(isSelected ? tint : .bbInkMute)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? tint.opacity(0.16) : Color.white.opacity(0.62))
                    .clipShape(Circle())

                Text(side.displayName(lang: loc.lang))
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(isSelected ? tint : .bbInkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(isSelected ? Color.white.opacity(0.92) : Color.white.opacity(0.34))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? tint.opacity(0.30) : Color.white.opacity(0.22), lineWidth: 1)
            )
        }
        .buttonStyle(FeedingPressButtonStyle())
    }

    private func accent(for side: FeedingSide) -> Color {
        switch side {
        case .left:   return .bbCoralDeep
        case .right:  return .bbRoseDeep
        case .bottle: return .bbSkyDeep
        }
    }

    private func icon(for side: FeedingSide) -> String {
        switch side {
        case .left:   return "arrow.left"
        case .right:  return "arrow.right"
        case .bottle: return "drop.fill"
        }
    }
}

private struct FeedingPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    FeedingView(vm: AppContainer().makeFeedingViewModel())
}
