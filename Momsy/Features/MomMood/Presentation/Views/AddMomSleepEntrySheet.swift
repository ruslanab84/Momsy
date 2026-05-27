import SwiftUI

struct AddMomSleepEntrySheet: View {
    @ObservedObject var vm: MomSleepViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager

    @State private var startDate = Calendar.current.date(byAdding: .hour, value: -8, to: Date()) ?? Date()
    @State private var endDate   = Date()
    @State private var quality: SleepQuality = .normal
    @State private var note = ""

    private var durationMinutes: Int {
        max(0, Int(endDate.timeIntervalSince(startDate) / 60))
    }
    private var isValid: Bool { endDate > startDate }

    var body: some View {
        NavigationStack {
            Form {
                Section(loc.strings.sleepStart) {
                    DatePicker(loc.strings.feedingStartedLabel, selection: $startDate,
                               displayedComponents: [.date, .hourAndMinute])
                    DatePicker(loc.strings.feedingEndedLabel, selection: $endDate,
                               displayedComponents: [.date, .hourAndMinute])
                }
                Section(loc.strings.sleepDuration) {
                    Text(loc.strings.durationFormatted(durationMinutes))
                        .foregroundColor(.bbInkSoft)
                }
                Section(loc.strings.sleepQuality) {
                    Picker(loc.strings.sleepQuality, selection: $quality) {
                        ForEach(SleepQuality.allCases, id: \.self) { q in
                            Text(q.localizedLabel(loc.strings)).tag(q)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    TextField(loc.strings.momMoodNoteSub, text: $note)
                }
            }
            .navigationTitle(loc.strings.addSleepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.strings.save) { save() }
                        .disabled(!isValid)
                        .fontWeight(.bold)
                }
            }
        }
    }

    private func save() {
        vm.logManualEntry(startDate: startDate, endDate: endDate, quality: quality, note: note)
        dismiss()
    }
}
