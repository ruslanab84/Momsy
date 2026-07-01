import SwiftUI

struct AddBathEntrySheet: View {
    @ObservedObject var vm: BathViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager

    @State private var startTime = Date().addingTimeInterval(-1800)
    @State private var endTime = Date()
    @State private var note = ""

    private var isValid: Bool { endTime > startTime }
    private var durationMinutes: Int { max(1, Int(endTime.timeIntervalSince(startTime)) / 60) }

    var body: some View {
        NavigationStack {
            ZStack {
                BathScreenBackground()

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
                                    endTime = newStart.addingTimeInterval(1800)
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

                        fieldSection(label: loc.strings.note) {
                            TextField(loc.strings.optional, text: $note)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(BathPosterPalette.ink)
                                .submitLabel(.done)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(loc.strings.addBathTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.bbSky, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }
                        .foregroundStyle(Color.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.strings.save) {
                        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
                        vm.logManualEntry(startDate: startTime, endDate: endTime, note: trimmedNote)
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(isValid ? Color.white : Color.white.opacity(0.45))
                    .disabled(!isValid)
                }
            }
        }
        .tint(Color.bbSkyDeep)
    }

    private var sheetHero: some View {
        ZStack {
            ZStack {
                BathPosterPalette.paper

                BathOrganicBlob(variant: .topLeading)
                    .fill(Color.bbSky.opacity(0.34))
                    .frame(width: 230, height: 160)
                    .offset(x: -92, y: -54)

                BathOrganicBlob(variant: .bottomTrailing)
                    .fill(Color.bbSkyDeep.opacity(0.16))
                    .frame(width: 220, height: 190)
                    .offset(x: 98, y: 82)

                BathBottleIcon(tint: Color.bbSkyDeep.opacity(0.30))
                    .frame(width: 32, height: 52)
                    .rotationEffect(.degrees(-10))
                    .offset(x: -108, y: 34)

                BathCreamIcon(tint: Color.bbMintDeep.opacity(0.25))
                    .frame(width: 46, height: 32)
                    .offset(x: 108, y: 34)
            }

            VStack(spacing: 12) {
                CuteBlobView(kind: .bath, size: 54, tone: Color.bbSky.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .stroke(Color.white.opacity(0.86), lineWidth: 1)
                    )

                Text(loc.strings.addBathTitle)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(BathPosterPalette.ink)
                    .multilineTextAlignment(.center)

                BathDottedLine()
                    .stroke(Color.bbSkyDeep.opacity(0.24), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [1, 7]))
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
        }
        .foregroundStyle(Color.bbSkyDeep)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(BathPosterPalette.paper.opacity(0.95))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .bbShadowSoft()
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
                .tint(Color.bbSkyDeep)
                .foregroundStyle(BathPosterPalette.ink)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BathPosterPalette.paper.opacity(0.96))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.68), lineWidth: 1)
                )
                .bbShadowSoft()
        }
    }
}

#Preview {
    AddBathEntrySheet(vm: AppContainer().makeBathViewModel())
        .environmentObject(LocalizationManager.shared)
}
