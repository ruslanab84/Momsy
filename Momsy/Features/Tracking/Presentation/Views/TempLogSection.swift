import SwiftUI

// MARK: - Temperature Bar Chart

struct TempBarChart: View {
    let entries: [TemperatureEntry]
    let lang: String
    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject var units: UnitSystemManager

    private func barColor(_ celsius: Double) -> Color {
        celsius >= 38.5 ? .bbCoralDeep : celsius >= 37.5 ? .bbButterDeep : .bbMintDeep
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Temperature, \(units.tempUnit)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Spacer()
                Text(loc.strings.recentReadings)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }

            if entries.isEmpty {
                Text(loc.strings.noTemperatureData)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                GeometryReader { geo in
                    let count = entries.count
                    let spacing: CGFloat = 6
                    let barW = max(28, (geo.size.width - spacing * CGFloat(count - 1)) / CGFloat(count))
                    HStack(alignment: .bottom, spacing: spacing) {
                        ForEach(entries) { entry in
                            let ratio = max(0.05, min(1, (entry.value - 36.0) / 4.0))
                            VStack(spacing: 3) {
                                Text(String(format: "%.1f°", units.displayTemp(fromCelsius: entry.value)))
                                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                    .foregroundColor(barColor(entry.value))
                                    .minimumScaleFactor(0.7)
                                Spacer(minLength: 0)
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(barColor(entry.value).opacity(0.75))
                                    .frame(width: barW, height: max(14, CGFloat(ratio) * 80))
                                Text(entry.timeLabel)
                                    .font(.system(size: 7, weight: .bold, design: .rounded))
                                    .foregroundColor(.bbInkMute)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(height: 130)
            }

            HStack(spacing: 12) {
                legendDot(color: .bbMintDeep,   label: units.tempNormalLabel)
                legendDot(color: .bbButterDeep, label: units.tempSubfebrLabel)
                legendDot(color: .bbCoralDeep,  label: units.tempHighLabel)
            }
        }
        .bbCard(pad: 14)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
    }
}

// MARK: - Add Temperature Sheet

struct AddTempSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject var units: UnitSystemManager
    let onAdd: (TemperatureEntry) -> Void

    @State private var tempStr = ""
    @State private var note = ""

    private var parsedInput: Double? {
        Double(tempStr.replacingOccurrences(of: ",", with: "."))
    }
    private var parsedCelsius: Double? {
        parsedInput.map { units.toCelsius($0) }
    }
    private var isValid: Bool { parsedInput != nil }

    private func valueColor(_ celsius: Double) -> Color { units.tempCategory(celsius).color }
    private func valueLabel(_ celsius: Double) -> String { units.tempCategory(celsius).label(loc: loc.strings) }

    var body: some View {
        NavigationStack {
            Form {
                Section(loc.strings.temperature) {
                    HStack {
                        Text(units.tempUnit).foregroundColor(.bbInkSoft)
                        TextField(units.tempPlaceholder, text: $tempStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    if let celsius = parsedCelsius {
                        HStack {
                            Text(valueLabel(celsius))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(valueColor(celsius))
                            Spacer()
                        }
                    }
                }
                Section(loc.strings.noteSectionLabel) {
                    TextField(loc.strings.optionalNote, text: $note)
                }
            }
            .navigationTitle(loc.strings.logTemp)
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
        guard let input = parsedInput else { return }
        let celsius = units.toCelsius(input)
        let now = Date()
        let df = DateFormatter()
        df.dateFormat = "d MMM"
        let tf = DateFormatter()
        tf.dateFormat = "HH:mm"
        onAdd(TemperatureEntry(
            dateLabel: df.string(from: now),
            timeLabel: tf.string(from: now),
            value: celsius,
            note: note
        ))
        dismiss()
    }
}
