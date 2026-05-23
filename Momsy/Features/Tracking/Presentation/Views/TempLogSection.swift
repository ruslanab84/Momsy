import SwiftUI

// MARK: - Temperature Bar Chart

struct TempBarChart: View {
    let entries: [TemperatureEntry]
    let lang: String
    @EnvironmentObject var loc: LocalizationManager

    private func barColor(_ v: Double) -> Color {
        v >= 38.5 ? .bbCoralDeep : v >= 37.5 ? .bbButterDeep : .bbMintDeep
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(loc.strings.temperatureCelsius)
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
                                Text(String(format: "%.1f°", entry.value))
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
                legendDot(color: .bbMintDeep,   label: loc.strings.tempNormalRange)
                legendDot(color: .bbButterDeep, label: loc.strings.tempSubfebrRange)
                legendDot(color: .bbCoralDeep,  label: loc.strings.tempHighRange)
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
    let onAdd: (TemperatureEntry) -> Void

    @State private var tempStr = ""
    @State private var note = ""

    private var parsedTemp: Double? {
        Double(tempStr.replacingOccurrences(of: ",", with: "."))
    }
    private var isValid: Bool { parsedTemp != nil }

    private func valueColor(_ v: Double) -> Color {
        v >= 38.5 ? .bbCoralDeep : v >= 37.5 ? .bbButterDeep : .bbMintDeep
    }
    private func valueLabel(_ v: Double) -> String {
        v >= 38.5 ? loc.strings.highTemp : v >= 37.5 ? loc.strings.subfebrLabel : loc.strings.normalOk
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(loc.strings.temperature) {
                    HStack {
                        Text("°C").foregroundColor(.bbInkSoft)
                        TextField(loc.strings.tempPlaceholder, text: $tempStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    if let v = parsedTemp {
                        HStack {
                            Text(valueLabel(v))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(valueColor(v))
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
        guard let v = parsedTemp else { return }
        let now = Date()
        let df = DateFormatter()
        df.dateFormat = "d MMM"
        let tf = DateFormatter()
        tf.dateFormat = "HH:mm"
        onAdd(TemperatureEntry(
            dateLabel: df.string(from: now),
            timeLabel: tf.string(from: now),
            value: v,
            note: note
        ))
        dismiss()
    }
}
