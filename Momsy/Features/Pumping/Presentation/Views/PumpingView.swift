import SwiftUI

struct PumpingView: View {
    @ObservedObject var vm: PumpingViewModel
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    sideSelector
                    timerSection
                    volumeSection
                    actionButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .navigationTitle(loc.strings.pumpingTracker)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }
                }
            }
        }
    }

    // MARK: — Side Selector

    private var sideSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.strings.pumpingSideLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: 0) {
                ForEach(PumpingSide.allCases, id: \.self) { side in
                    Button {
                        vm.selectedSide = side
                    } label: {
                        Text(sideLabel(side))
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(vm.selectedSide == side ? Color.bbRose : Color.clear)
                            .foregroundStyle(vm.selectedSide == side ? Color.white : Color.primary)
                    }
                    .buttonStyle(.plain)
                    if side != PumpingSide.allCases.last {
                        Divider()
                    }
                }
            }
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
            )
        }
    }

    // MARK: — Timer

    private var timerSection: some View {
        VStack(spacing: 4) {
            Text(vm.pumpingTimerString)
                .font(.system(size: 64, weight: .thin, design: .monospaced))
                .foregroundStyle(vm.isPumpingActive ? Color.bbRose : Color.primary)
                .animation(.easeInOut(duration: 0.2), value: vm.isPumpingActive)
            if vm.isPumpingActive {
                Text(sideLabel(vm.selectedSide))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: — Volume

    private var volumeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.strings.pumpingVolume)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                mlButton(-50)
                mlButton(-10)
                Spacer()
                Text("\(vm.volumeML) мл")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(vm.volumeML > 0 ? Color.bbRose : Color.secondary)
                    .animation(.easeInOut(duration: 0.15), value: vm.volumeML)
                Spacer()
                mlButton(+10)
                mlButton(+50)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    @ViewBuilder
    private func mlButton(_ delta: Int) -> some View {
        Button {
            vm.volumeML = max(0, vm.volumeML + delta)
        } label: {
            Text(delta > 0 ? "+\(delta)" : "\(delta)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.bbRose)
                .frame(width: 44, height: 36)
                .background(Color.bbRose.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: — Action Button

    private var actionButton: some View {
        Button {
            if vm.isPumpingActive {
                vm.stop()
                dismiss()
            } else {
                vm.start()
            }
        } label: {
            Text(vm.isPumpingActive ? loc.strings.pumpingStop : loc.strings.pumpingStart)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(vm.isPumpingActive ? Color.red : Color.bbRose)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: vm.isPumpingActive)
    }

    // MARK: — Helpers

    private func sideLabel(_ side: PumpingSide) -> String {
        switch side {
        case .left:  return loc.strings.pumpingLeft
        case .right: return loc.strings.pumpingRight
        case .both:  return loc.strings.pumpingBoth
        }
    }
}
