import SwiftUI
import Combine

struct PumpingView: View {
    @ObservedObject var vm: PumpingViewModel
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    @State private var showAddManual = false

    private let typicalSeconds = 20 * 60

    var progress: Double { Double(vm.pumpingSeconds) / Double(typicalSeconds) }

    var body: some View {
        ZStack {
            Color.bbRose.ignoresSafeArea()

            Circle()
                .fill(Color.bbRoseDeep.opacity(0.18))
                .frame(width: 200)
                .offset(x: 80, y: -200)
                .ignoresSafeArea()
            Circle()
                .fill(Color.bbLilacDeep.opacity(0.18))
                .frame(width: 220)
                .offset(x: -120, y: 160)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    topBar
                    timerRing
                    sideToggle
                    actionButtons
                    volumeCard
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .task { await vm.loadTodayEntries() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { vm.syncTimerWithStartDate() }
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
            Text(loc.strings.pumpingTracker)
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
                AddPumpingSheet(vm: vm)
                    .environmentObject(loc)
            }
        }
    }

    // MARK: - Timer Ring

    private var timerRing: some View {
        VStack(spacing: 8) {
            let sideText = vm.selectedSide.displayName(lang: loc.lang).uppercased()
            Text("\(sideText) · \(vm.isPumpingActive ? loc.strings.active : loc.strings.paused)")
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
                    .animation(.linear(duration: 1), value: vm.pumpingSeconds)

                VStack(spacing: 6) {
                    Text(vm.pumpingTimerString)
                        .font(.system(size: 52, weight: .heavy, design: .monospaced))
                        .foregroundColor(.bbInk)
                        .contentTransition(.numericText())
                        .animation(.linear(duration: 0.4), value: vm.pumpingSeconds)

                    Text(loc.strings.pumpingTypicalDuration)
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
            ForEach(PumpingSide.allCases, id: \.self) { side in
                let isSelected = vm.selectedSide == side
                Text(side.displayName(lang: loc.lang))
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(isSelected ? .bbRoseDeep : Color.bbInk.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isSelected ? Color.white : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            vm.selectedSide = side
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
            if !vm.isPumpingActive {
                Button(action: { vm.start() }) {
                    Text(loc.strings.pumpingStart)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.bbRoseDeep)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            } else {
                Button(action: {
                    vm.stop()
                    dismiss()
                }) {
                    Text(loc.strings.stopDone)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.bbSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
    }

    // MARK: - Volume Card

    private var volumeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.strings.pumpingVolume)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.6)

            HStack(spacing: 20) {
                Button {
                    if vm.volumeML > 0 { vm.volumeML = max(0, vm.volumeML - 10) }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.bbRoseDeep)
                }
                .buttonStyle(.plain)

                Text("\(vm.volumeML) \(loc.strings.mlUnit)")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                    .frame(minWidth: 90, alignment: .center)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.25), value: vm.volumeML)

                Button {
                    if vm.volumeML < 1000 { vm.volumeML += 10 }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.bbRoseDeep)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .bbCard(pad: 14, bg: Color.white.opacity(0.9))
    }
}
