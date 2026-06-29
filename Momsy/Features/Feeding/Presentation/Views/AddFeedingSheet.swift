import SwiftUI

struct AddFeedingSheet: View {
    @ObservedObject var vm: FeedingViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject var units: UnitSystemManager

    @State private var startTime = Date().addingTimeInterval(-600)   // 10 min ago default
    @State private var endTime   = Date()
    @State private var side: FeedingSide = .left
    @State private var note = ""
    @State private var bottleML: Int = 120

    private var isValid: Bool { endTime > startTime }
    private var durationMinutes: Int { max(1, Int(endTime.timeIntervalSince(startTime)) / 60) }
    private var sideAccent: Color { accent(for: side) }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.bbCreamSoft.ignoresSafeArea()
                Color.bbCoral.opacity(0.28)
                    .frame(height: 132)
                    .ignoresSafeArea(edges: .top)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        sheetHeader
                        timeCard
                        sideCard
                        detailsCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .presentationBackground(Color.bbCreamSoft)
        .presentationCornerRadius(34)
    }

    private var sheetHeader: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(Color.bbInk.opacity(0.16))
                .frame(width: 42, height: 5)
                .padding(.top, 10)

            HStack(spacing: 12) {
                headerButton(title: loc.strings.cancel, systemImage: "xmark", foreground: .bbInkSoft) {
                    dismiss()
                }

                Spacer(minLength: 0)

                VStack(spacing: 7) {
                    Text(loc.strings.addFeedingTitle)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    durationChip
                }
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)

                headerButton(title: loc.strings.save, systemImage: "checkmark", foreground: isValid ? .bbCoralDeep : .bbInkMute) {
                    save()
                }
                .disabled(!isValid)
                .opacity(isValid ? 1 : 0.55)
            }
        }
        .padding(.bottom, 2)
    }

    private var durationChip: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.fill")
                .font(.system(size: 10, weight: .bold))
            Text("\(durationMinutes) \(loc.strings.unitMin)")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .contentTransition(.numericText())
        }
        .foregroundColor(sideAccent)
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(sideAccent.opacity(0.12))
        .clipShape(Capsule())
        .animation(.easeOut(duration: 0.18), value: durationMinutes)
        .animation(.easeOut(duration: 0.18), value: side)
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
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.65), lineWidth: 1)
        )
        .bbShadowSoft()
    }

    private var startTimeRow: some View {
        timeRow(label: loc.strings.feedingStartedLabel, icon: "play.fill", tint: .bbMintDeep) {
            DatePicker(
                "",
                selection: $startTime,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .tint(.bbCoralDeep)
            .onChange(of: startTime) { _, newStart in
                if endTime <= newStart {
                    endTime = newStart.addingTimeInterval(600)
                }
            }
        }
    }

    private var endTimeRow: some View {
        timeRow(label: loc.strings.feedingEndedLabel, icon: "stop.fill", tint: .bbCoralDeep) {
            DatePicker(
                "",
                selection: $endTime,
                in: startTime...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .tint(.bbCoralDeep)
        }
    }

    private var sideCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(loc.strings.feedingSideLabel)

            HStack(spacing: 10) {
                ForEach(FeedingSide.allCases, id: \.self) { option in
                    sideButton(option)
                }
            }
        }
        .padding(16)
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .bbShadowSoft()
    }

    @ViewBuilder
    private var detailsCard: some View {
        if side == .bottle {
            bottleCard
                .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
        } else {
            noteCard
                .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
        }
    }

    private var bottleCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel(loc.strings.bottleVolume)

            HStack(spacing: 18) {
                volumeButton(systemImage: "minus") {
                    let step = units.isImperial ? 30 : 10
                    if bottleML > step { bottleML -= step }
                }

                VStack(spacing: 2) {
                    Text(units.displayVolume(fromMl: bottleML))
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: bottleML)

                    Text(loc.strings.bottleVolume)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)

                volumeButton(systemImage: "plus") {
                    let step = units.isImperial ? 30 : 10
                    if bottleML < 500 { bottleML += step }
                }
            }
            .padding(14)
            .background(Color.bbSky.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .detailCardStyle()
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel(loc.strings.note)

            HStack(spacing: 10) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.bbInkMute)
                    .frame(width: 34, height: 34)
                    .background(Color.bbCreamSoft)
                    .clipShape(Circle())

                TextField(loc.strings.optional, text: $note)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInk)
                    .submitLabel(.done)
            }
            .padding(12)
            .background(Color.bbCreamSoft)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .detailCardStyle()
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
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 8)
    }

    private func sideButton(_ option: FeedingSide) -> some View {
        let isSelected = side == option
        let tint = accent(for: option)

        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) { side = option }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon(for: option))
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(isSelected ? tint : .bbInkMute)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? tint.opacity(0.16) : Color.bbCreamSoft)
                    .clipShape(Circle())

                Text(option.displayName(lang: loc.lang))
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(isSelected ? tint : .bbInkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
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
        .buttonStyle(SheetPressButtonStyle())
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
            .foregroundColor(foreground)
            .frame(width: 92, height: 44)
            .background(Color.white.opacity(0.86))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.8), lineWidth: 1))
            .bbShadowSoft()
        }
        .buttonStyle(SheetPressButtonStyle())
    }

    private func volumeButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .heavy))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.bbSkyDeep)
                .clipShape(Circle())
                .bbShadowSoft()
        }
        .buttonStyle(SheetPressButtonStyle())
    }

    private func sectionLabel(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .foregroundColor(.bbInkMute)
            .kerning(0.5)
            .textCase(.uppercase)
    }

    private func save() {
        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
        vm.logManualEntry(
            date: startTime,
            durationMinutes: durationMinutes,
            side: side,
            mood: side == .bottle ? nil : (trimmedNote.isEmpty ? nil : trimmedNote),
            milliliters: side == .bottle ? bottleML : nil
        )
        dismiss()
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

private struct SheetPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private extension View {
    func detailCardStyle() -> some View {
        self
            .padding(16)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .bbShadowSoft()
    }
}

#Preview {
    AddFeedingSheet(vm: AppContainer().makeFeedingViewModel())
        .environmentObject(LocalizationManager.shared)
        .environmentObject(UnitSystemManager.shared)
}
