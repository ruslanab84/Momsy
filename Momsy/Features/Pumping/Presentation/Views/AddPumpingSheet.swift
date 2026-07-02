import SwiftUI

struct AddPumpingSheet: View {
    @ObservedObject var vm: PumpingViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var loc: LocalizationManager

    @State private var startTime = Date().addingTimeInterval(-1200)
    @State private var endTime = Date()
    @State private var side: PumpingSide = .left
    @State private var volumeML = 100

    private var isValid: Bool { endTime > startTime }
    private var durationMinutes: Int { max(1, Int(endTime.timeIntervalSince(startTime)) / 60) }

    var body: some View {
        NavigationStack {
            ZStack {
                PumpingScreenBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        sheetHero

                        fieldSection(label: loc.strings.feedingStartedLabel) {
                            DatePicker(
                                "",
                                selection: $startTime,
                                in: ...Date(),
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onChange(of: startTime) { _, newStart in
                                if endTime <= newStart {
                                    endTime = newStart.addingTimeInterval(1200)
                                }
                            }
                        }

                        fieldSection(label: loc.strings.feedingEndedLabel) {
                            DatePicker(
                                "",
                                selection: $endTime,
                                in: startTime...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if isValid {
                            durationPill
                        }

                        fieldSection(label: loc.strings.pumpingSideLabel) {
                            sideSelector
                        }

                        fieldSection(label: loc.strings.pumpingVolume) {
                            volumeStepper
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(loc.strings.addPumpingTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.bbRose, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }
                        .foregroundStyle(Color.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.strings.save) {
                        save()
                    }
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(isValid ? Color.white : Color.white.opacity(0.45))
                    .disabled(!isValid)
                }
            }
        }
        .tint(Color.bbRoseDeep)
    }

    private var sheetHero: some View {
        ZStack {
            ZStack {
                PumpingPosterPalette.paper

                PumpingOrganicBlob(variant: .topLeading)
                    .fill(Color.bbRose.opacity(0.34))
                    .frame(width: 230, height: 160)
                    .offset(x: -92, y: -54)

                PumpingOrganicBlob(variant: .bottomTrailing)
                    .fill(Color.bbRoseDeep.opacity(0.16))
                    .frame(width: 220, height: 190)
                    .offset(x: 98, y: 82)

                Image(systemName: "drop.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.bbRoseDeep.opacity(0.30))
                    .rotationEffect(.degrees(-14))
                    .offset(x: 112, y: 36)
            }

            VStack(spacing: 12) {
                CuteBlobView(kind: .pump, size: 54, tone: Color.bbRose.opacity(0.30))
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .stroke(Color.white.opacity(0.86), lineWidth: 1)
                    )

                Text(loc.strings.addPumpingTitle)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(PumpingPosterPalette.ink)
                    .multilineTextAlignment(.center)

                PumpingDottedLine()
                    .stroke(Color.bbRoseDeep.opacity(0.24), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [1, 7]))
                    .frame(height: 1)
                    .padding(.horizontal, 36)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 26)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .bbShadowSoft()
    }

    private var durationPill: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.system(size: 13, weight: .bold))
            Text("\(durationMinutes) \(loc.strings.unitMin)")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .contentTransition(.numericText())
        }
        .foregroundStyle(Color.bbRoseDeep)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(PumpingPosterPalette.paper.opacity(0.95))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .bbShadowSoft()
        .animation(.easeOut(duration: 0.18), value: durationMinutes)
    }

    private var sideSelector: some View {
        HStack(spacing: 8) {
            ForEach(PumpingSide.allCases, id: \.self) { option in
                let isSelected = side == option
                Text(option.displayName(lang: loc.lang))
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(isSelected ? Color.bbRoseDeep : PumpingPosterPalette.inkMute)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(isSelected ? Color.bbRose.opacity(0.18) : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                            side = option
                        }
                    }
            }
        }
        .padding(4)
        .background(PumpingPosterPalette.paperSoft)
        .clipShape(Capsule())
    }

    private var volumeStepper: some View {
        HStack(spacing: 18) {
            volumeButton(systemImage: "minus") {
                if volumeML >= 10 {
                    volumeML -= 10
                }
            }

            VStack(spacing: 2) {
                Text("\(volumeML) \(loc.strings.mlUnit)")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(PumpingPosterPalette.ink)
                    .frame(minWidth: 92, alignment: .center)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.25, dampingFraction: 0.9), value: volumeML)

                Text(loc.strings.pumpingVolume)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(PumpingPosterPalette.inkMute)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity)

            volumeButton(systemImage: "plus") {
                if volumeML < 1000 {
                    volumeML += 10
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func volumeButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(Color.bbRoseDeep)
                .frame(width: 40, height: 40)
                .background(Color.bbRose.opacity(0.16))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.bbRoseDeep.opacity(0.18), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func fieldSection<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.78))
                .kerning(0.5)
            content()
                .tint(Color.bbRoseDeep)
                .foregroundStyle(PumpingPosterPalette.ink)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(PumpingPosterPalette.paper.opacity(0.96))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.68), lineWidth: 1)
                )
                .bbShadowSoft()
        }
    }

    private func save() {
        vm.logManualEntry(
            date: startTime,
            durationMinutes: durationMinutes,
            side: side,
            volumeML: volumeML
        )
        dismiss()
    }
}
