import SwiftUI

struct AddFeedingSheet: View {
    @ObservedObject var vm: FeedingViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager

    @State private var date = Date()
    @State private var durationMinutes = 10
    @State private var side: FeedingSide = .left
    @State private var note = ""

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    fieldSection(label: loc.strings.feedingWhenLabel) {
                        DatePicker(
                            "",
                            selection: $date,
                            in: ...Date(),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    fieldSection(label: loc.strings.feedingDurationLabel) {
                        HStack {
                            Text("\(durationMinutes)")
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(.bbInk)
                            Text(loc.strings.unitMin)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.bbInkMute)
                                .padding(.top, 6)
                            Spacer()
                            Stepper("", value: $durationMinutes, in: 1...180)
                                .labelsHidden()
                        }
                    }

                    fieldSection(label: loc.strings.feedingSideLabel) {
                        HStack(spacing: 0) {
                            ForEach(FeedingSide.allCases, id: \.self) { s in
                                let isSelected = side == s
                                Text(s.displayName(lang: loc.lang))
                                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                                    .foregroundColor(isSelected ? .bbCoralDeep : Color.bbInk.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(isSelected ? Color.bbCoral.opacity(0.18) : Color.clear)
                                    .clipShape(Capsule())
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) { side = s }
                                    }
                            }
                        }
                        .padding(4)
                        .background(Color.bbCard)
                        .clipShape(Capsule())
                    }

                    fieldSection(label: loc.strings.note) {
                        TextField(loc.strings.optional, text: $note)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInk)
                            .submitLabel(.done)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .navigationTitle(loc.strings.addFeedingTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }
                        .foregroundColor(.bbCoralDeep)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.strings.save) {
                        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
                        vm.logManualEntry(
                            date: date,
                            durationMinutes: durationMinutes,
                            side: side,
                            mood: trimmedNote.isEmpty ? nil : trimmedNote
                        )
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbCoralDeep)
                }
            }
        }
    }

    @ViewBuilder
    private func fieldSection<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)
            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

#Preview {
    AddFeedingSheet(vm: AppContainer().makeFeedingViewModel())
        .environmentObject(LocalizationManager.shared)
}
