import SwiftUI

// MARK: - Add Measurement Sheet

struct AddMeasurementSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject var units: UnitSystemManager
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
                        Text("\(loc.strings.weight), \(units.weightUnit)").foregroundColor(.bbInkSoft)
                        TextField(units.weightPlaceholder, text: $weightStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("\(loc.strings.height), \(units.heightUnit)").foregroundColor(.bbInkSoft)
                        TextField(units.heightPlaceholder, text: $heightStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("\(loc.strings.headCirc), \(units.heightUnit)").foregroundColor(.bbInkSoft)
                        TextField(units.headPlaceholder, text: $headStr)
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
        // Always store in metric — TrackingViewModel.parseNumber() reads the numeric prefix
        let parse = { (s: String) -> Double? in
            Double(s.replacingOccurrences(of: ",", with: "."))
        }

        let w: String
        if let val = parse(weightStr) {
            w = String(format: "%.2f kg", units.toKg(val))
        } else { w = "—" }

        let h: String
        if let val = parse(heightStr) {
            h = String(format: "%.1f cm", units.toCm(val))
        } else { h = "—" }

        let hc: String
        if let val = parse(headStr) {
            hc = String(format: "%.1f cm", units.toCm(val))
        } else { hc = "—" }

        let fmt = DateFormatter()
        fmt.dateFormat = "d MMM"
        fmt.locale = Locale(identifier: loc.lang)
        onAdd(MeasurementEntry(
            dateLabel: fmt.string(from: Date()),
            weight: w, height: h, headCirc: hc,
            delta: "", visitLabel: nil
        ))
        dismiss()
    }
}
