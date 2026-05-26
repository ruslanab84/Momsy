import SwiftUI

struct AddFeedingSheet: View {
    @ObservedObject var vm: FeedingViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager

    @State private var startTime = Date().addingTimeInterval(-600)   // 10 min ago default
    @State private var endTime   = Date()
    @State private var side: FeedingSide = .left
    @State private var note = ""

    private var isValid: Bool { endTime > startTime }
    private var durationMinutes: Int { max(1, Int(endTime.timeIntervalSince(startTime)) / 60) }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

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
                                endTime = newStart.addingTimeInterval(600)
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
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12, weight: .semibold))
                            Text("\(durationMinutes) \(loc.strings.unitMin)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.bbInkMute)
                        .padding(.horizontal, 4)
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
                            date: startTime,
                            durationMinutes: durationMinutes,
                            side: side,
                            mood: trimmedNote.isEmpty ? nil : trimmedNote
                        )
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(isValid ? .bbCoralDeep : Color.bbInkMute)
                    .disabled(!isValid)
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
