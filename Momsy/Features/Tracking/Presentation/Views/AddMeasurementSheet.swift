import SwiftUI

// MARK: - Add Measurement Sheet

struct AddMeasurementSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager
    let onAdd: (MeasurementEntry) -> Void

    @State private var weightStr = ""
    @State private var heightStr = ""
    @State private var headStr = ""

    private var isValid: Bool { !weightStr.isEmpty || !heightStr.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section(loc.strings.measurements) {
                    HStack {
                        Text(loc.strings.weight).foregroundColor(.bbInkSoft)
                        TextField(loc.strings.weightPlaceholder, text: $weightStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text(loc.strings.height).foregroundColor(.bbInkSoft)
                        TextField(loc.strings.heightPlaceholder, text: $heightStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text(loc.strings.headCirc).foregroundColor(.bbInkSoft)
                        TextField(loc.strings.headCircPlaceholder, text: $headStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section {
                    Text(loc.strings.fillAtLeastOneField)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
            }
            .navigationTitle(loc.strings.newMeasurement)
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
        let w  = weightStr.isEmpty ? "—" : "\(weightStr) \(loc.strings.unitKg)"
        let h  = heightStr.isEmpty ? "—" : "\(heightStr) \(loc.strings.unitCm)"
        let hc = headStr.isEmpty   ? "—" : "\(headStr) \(loc.strings.unitCm)"
        onAdd(MeasurementEntry(
            dateLabel: loc.strings.today,
            weight: w, height: h, headCirc: hc,
            delta: "", visitLabel: nil
        ))
        dismiss()
    }
}
