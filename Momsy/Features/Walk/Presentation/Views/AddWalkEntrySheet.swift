import SwiftUI

struct AddWalkEntrySheet: View {
    @ObservedObject var vm: WalkViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager

    @State private var startTime = Date().addingTimeInterval(-1800)
    @State private var endTime   = Date()
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
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12, weight: .semibold))
                            Text("\(durationMinutes) \(loc.strings.unitMin)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.bbInkMute)
                        .padding(.horizontal, 4)
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
            .navigationTitle(loc.strings.addWalkTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }
                        .foregroundColor(.bbMintDeep)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.strings.save) {
                        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
                        vm.logManualEntry(startDate: startTime, endDate: endTime, note: trimmedNote)
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(isValid ? .bbMintDeep : .bbInkMute)
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
    AddWalkEntrySheet(vm: AppContainer().makeWalkViewModel())
        .environmentObject(LocalizationManager.shared)
}
