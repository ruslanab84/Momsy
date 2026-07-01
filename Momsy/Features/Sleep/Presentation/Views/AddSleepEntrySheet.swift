import SwiftUI

struct AddSleepEntrySheet: View {
    @ObservedObject var vm: SleepViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager
    private var cardInk: Color { SleepPosterPalette.ink }
    private var cardInkSoft: Color { SleepPosterPalette.inkSoft }
    private var cardInkMute: Color { SleepPosterPalette.inkMute }

    @State private var startTime = Date().addingTimeInterval(-1800)
    @State private var endTime   = Date()
    @State private var quality: SleepQuality = .normal
    @State private var note = ""

    private var isValid: Bool { endTime > startTime }
    private var durationMinutes: Int { max(1, Int(endTime.timeIntervalSince(startTime)) / 60) }
    private var qualityAccent: Color { accent(for: quality) }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                SleepScreenBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        sheetHeader
                        timeCard
                        qualityCard
                        noteCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .presentationBackground(Color.bbLilac)
        .presentationCornerRadius(34)
    }

    private var sheetHeader: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(SleepPosterPalette.ink.opacity(0.16))
                .frame(width: 42, height: 5)
                .padding(.top, 10)

            HStack(spacing: 12) {
                headerButton(title: loc.strings.cancel, systemImage: "xmark", foreground: cardInkSoft) {
                    dismiss()
                }

                Spacer(minLength: 0)

                VStack(spacing: 7) {
                    Text(loc.strings.addSleepTitle)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundStyle(cardInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    durationChip
                }
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)

                headerButton(title: loc.strings.save, systemImage: "checkmark", foreground: isValid ? .bbLilacDeep : cardInkMute) {
                    save()
                }
                .disabled(!isValid)
                .opacity(isValid ? 1 : 0.55)
            }
        }
        .padding(14)
        .background {
            ZStack {
                SleepPosterPalette.paper

                SleepOrganicBlob(variant: .topLeading)
                    .fill(Color.bbLilac.opacity(0.32))
                    .frame(width: 230, height: 150)
                    .offset(x: -92, y: -48)

                SleepOrganicBlob(variant: .bottomTrailing)
                    .fill(Color.bbSky.opacity(0.18))
                    .frame(width: 210, height: 176)
                    .offset(x: 104, y: 72)

                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.bbLilacDeep.opacity(0.30))
                    .offset(x: 114, y: -32)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.70), lineWidth: 1)
        )
        .bbShadowSoft()
    }

    private var durationChip: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.fill")
                .font(.system(size: 10, weight: .bold))
            Text("\(durationMinutes) \(loc.strings.unitMin)")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .contentTransition(.numericText())
        }
        .foregroundColor(qualityAccent)
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(qualityAccent.opacity(0.12))
        .clipShape(Capsule())
        .animation(.easeOut(duration: 0.18), value: durationMinutes)
        .animation(.easeOut(duration: 0.18), value: quality)
    }

    private var timeCard: some View {
        VStack(spacing: 0) {
            startTimeRow
            Divider()
                .padding(.leading, 52)
                .padding(.vertical, 2)
            endTimeRow
        }
        .padding(14)
        .background(SleepPosterPalette.paper.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.70), lineWidth: 1)
        )
        .bbShadowSoft()
    }

    private var startTimeRow: some View {
        timeRow(label: loc.strings.feedingStartedLabel, icon: "moon.fill", tint: .bbLilacDeep) {
            DatePicker(
                "",
                selection: $startTime,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .tint(.bbLilacDeep)
            .onChange(of: startTime) { _, newStart in
                if endTime <= newStart {
                    endTime = newStart.addingTimeInterval(1800)
                }
            }
        }
    }

    private var endTimeRow: some View {
        timeRow(label: loc.strings.feedingEndedLabel, icon: "sun.max.fill", tint: .bbButterDeep) {
            DatePicker(
                "",
                selection: $endTime,
                in: startTime...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .tint(.bbLilacDeep)
        }
    }

    private var qualityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(loc.strings.sleepQuality)

            HStack(spacing: 10) {
                ForEach(SleepQuality.allCases, id: \.self) { option in
                    qualityButton(option)
                }
            }
        }
        .padding(16)
        .background(SleepPosterPalette.paper.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .bbShadowSoft()
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel(loc.strings.note)

            HStack(spacing: 10) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(cardInkMute)
                    .frame(width: 34, height: 34)
                    .background(SleepPosterPalette.paperSoft)
                    .clipShape(Circle())

                TextField(loc.strings.optional, text: $note)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(cardInk)
                    .submitLabel(.done)
            }
            .padding(12)
            .background(SleepPosterPalette.paperSoft)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .sleepDetailCardStyle()
    }

    private func timeRow<Content: View>(
        label: String,
        icon: String,
        tint: Color,
        @ViewBuilder picker: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                sectionLabel(label)
                picker()
                    .foregroundStyle(cardInk)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 8)
    }

    private func qualityButton(_ option: SleepQuality) -> some View {
        let isSelected = quality == option
        let tint = accent(for: option)

        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                quality = option
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon(for: option))
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(isSelected ? tint : cardInkMute)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? tint.opacity(0.16) : SleepPosterPalette.paperSoft)
                    .clipShape(Circle())

                Text(option.localizedLabel(loc.strings))
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
        .buttonStyle(SleepSheetPressButtonStyle())
    }

    private func headerButton(
        title: String,
        systemImage: String,
        foreground: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .heavy))
                Text(title)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(foreground)
            .frame(width: 92, height: 44)
            .background(Color.white.opacity(0.86))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.8), lineWidth: 1))
            .bbShadowSoft()
        }
        .buttonStyle(SleepSheetPressButtonStyle())
    }

    private func sectionLabel(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .foregroundStyle(cardInkMute)
            .kerning(0.5)
            .textCase(.uppercase)
    }

    private func save() {
        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
        vm.logManualEntry(
            startDate: startTime,
            endDate: endTime,
            quality: quality,
            note: trimmedNote
        )
        dismiss()
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

private struct SleepSheetPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private extension View {
    func sleepDetailCardStyle() -> some View {
        self
            .padding(16)
            .background(SleepPosterPalette.paper.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.70), lineWidth: 1)
            )
            .bbShadowSoft()
    }
}

#Preview {
    AddSleepEntrySheet(vm: AppContainer().makeSleepViewModel())
        .environmentObject(LocalizationManager.shared)
}
