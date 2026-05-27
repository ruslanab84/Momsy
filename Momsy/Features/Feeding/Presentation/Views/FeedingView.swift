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

    var body: some View {
        ZStack {
            Color.bbCoral.ignoresSafeArea()

            Circle()
                .fill(Color.bbCoralDeep.opacity(0.18))
                .frame(width: 200)
                .offset(x: 80, y: -200)
                .ignoresSafeArea()
            Circle()
                .fill(Color.bbButterDeep.opacity(0.18))
                .frame(width: 220)
                .offset(x: -120, y: 160)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    topBar
                    timerRing
                    sideToggle
                    actionButtons
                    noteCard
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
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.bbInk)
                    )
            }
            Spacer()
            Text(loc.strings.feeding)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Spacer()
            Button { showAddManual = true } label: {
                Capsule()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 88, height: 32)
                    .overlay(
                        Text(loc.strings.enterManuallyLabel)
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInk)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 6)
                    )
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showAddManual) {
                AddFeedingSheet(vm: vm)
                    .environmentObject(loc)
            }
        }
    }

    // MARK: - Timer Ring

    private var timerRing: some View {
        VStack(spacing: 8) {
            let sideLabel = vm.feedingSide.displayName(lang: loc.lang).uppercased()
            Text("\(sideLabel) · \(vm.isFeedingActive ? loc.strings.active : loc.strings.paused)")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(Color.bbInk.opacity(0.55))
                .kerning(1)

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 14)
                    .frame(width: 260, height: 260)

                Circle()
                    .trim(from: 0, to: CGFloat(min(progress, 1)))
                    .stroke(Color.white,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .frame(width: 260, height: 260)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: vm.feedingSeconds)

                VStack(spacing: 6) {
                    Text(vm.feedingTimerString)
                        .font(.system(size: 52, weight: .heavy, design: .monospaced))
                        .foregroundColor(.bbInk)
                        .contentTransition(.numericText())
                        .animation(.linear(duration: 0.4), value: vm.feedingSeconds)

                    Text(loc.strings.typicalDuration)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color.bbInk.opacity(0.55))
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Side Toggle

    private var sideToggle: some View {
        HStack(spacing: 0) {
            ForEach(FeedingSide.allCases, id: \.self) { side in
                let isSelected = vm.feedingSide == side
                Text(side.displayName(lang: loc.lang))
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(isSelected ? .bbCoralDeep : Color.bbInk.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isSelected ? Color.white : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            vm.feedingSide = side
                        }
                    }
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.5))
        .clipShape(Capsule())
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        Group {
            if !vm.feedingSessionExists {
                // No active session — show Start button
                Button(action: {
                    vm.startFeeding(side: vm.feedingSide)
                }) {
                    Text(loc.strings.start)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.bbCoralDeep)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            } else {
                HStack(spacing: 10) {
                    Button(action: {
                        if vm.isFeedingActive {
                            vm.pauseFeeding()
                        } else {
                            vm.resumeFeeding()
                        }
                    }) {
                        Text(vm.isFeedingActive ? loc.strings.pause : loc.strings.resume)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInk)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    Button(action: {
                        vm.stopFeeding(mood: moodNote)
                        dismiss()
                    }) {
                        Text(loc.strings.stopDone)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.bbSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
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
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
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
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
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
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
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
        .bbCard(pad: 14, bg: Color.white.opacity(0.9))
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showCustomInput)
    }

}

#Preview {
    FeedingView(vm: AppContainer().makeFeedingViewModel())
}
