import SwiftUI

// MARK: - TrackingView

struct TrackingView: View {
    @State private var selectedTab = 0
    @State private var measurements: [MeasurementEntry] = sampleMeasurements
    @State private var tempLog: [TemperatureEntry] = sampleTempLog
    @State private var showAddMeasurement = false
    @State private var showAddTemp = false

    private let tabs = ["Вес", "Рост", "Окруж. головы", "Темп."]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                tabPicker
                if selectedTab == 3 {
                    TempBarChart(entries: Array(tempLog.prefix(7).reversed()))
                } else {
                    growthChartCard
                }
                measurementsList
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddMeasurement) {
            AddMeasurementSheet { entry in measurements.insert(entry, at: 0) }
        }
        .sheet(isPresented: $showAddTemp) {
            AddTempSheet { entry in tempLog.insert(entry, at: 0) }
        }
    }

    // MARK: - Header

    private var headerSummary: String {
        switch selectedTab {
        case 0: return "\(measurements.first?.weight ?? "—") · сегодня"
        case 1: return "\(measurements.first?.height ?? "—") · сегодня"
        case 2: return "\(measurements.first?.headCirc ?? "—") · сегодня"
        case 3:
            guard let t = tempLog.first else { return "нет данных" }
            return String(format: "%.1f°C · %@ %@", t.value, t.dateLabel, t.timeLabel)
        default: return ""
        }
    }

    private var pillText: String {
        if selectedTab == 3, let v = tempLog.first?.value {
            return v >= 38.5 ? "высокая" : v >= 37.5 ? "субфебрильная" : "норма"
        }
        return "в норме"
    }
    private var pillColor: Color {
        if selectedTab == 3, let v = tempLog.first?.value {
            return v >= 38.5 ? .bbRose : v >= 37.5 ? .bbButter : .bbMint
        }
        return .bbMint
    }
    private var pillFg: Color {
        if selectedTab == 3, let v = tempLog.first?.value {
            return v >= 38.5 ? .bbCoralDeep : v >= 37.5 ? .bbButterDeep : .bbMintDeep
        }
        return .bbMintDeep
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                BBSectionLabel(text: "Здоровье")
                Text("Рост и вес")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(headerSummary)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }
            Spacer()
            BBPill(text: pillText, color: pillColor, fg: pillFg)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
        }
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tabs.indices, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedTab = i }
                    } label: {
                        Text(tabs[i])
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(i == selectedTab ? .white : .bbInkSoft)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(i == selectedTab ? Color.bbInk : Color.bbCard)
                            .clipShape(Capsule())
                            .bbShadowSoft()
                    }
                }
            }
        }
    }

    // MARK: - Growth Chart Card (tabs 0-2)

    private struct ChartConfig {
        let title: String
        let unit: String
        let data: [WeightPoint]
        let gridVals: [Int]
    }

    private var currentChartConfig: ChartConfig {
        switch selectedTab {
        case 1: return ChartConfig(title: "Рост, см",           unit: "см", data: sampleHeightData, gridVals: [50, 55, 60, 65])
        case 2: return ChartConfig(title: "Окруж. головы, см",  unit: "см", data: sampleHeadData,   gridVals: [34, 37, 40, 43])
        default: return ChartConfig(title: "Вес, кг",           unit: "кг", data: sampleWeightData,  gridVals: [3, 5, 7, 9])
        }
    }

    private var growthChartCard: some View {
        let cfg = currentChartConfig
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(cfg.title)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Spacer()
                Text("0–5 мес · перцентили ВОЗ")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }

            WHOLineChart(data: cfg.data, gridVals: cfg.gridVals, unit: cfg.unit)
                .frame(height: 160)
                .animation(.easeInOut(duration: 0.3), value: selectedTab)

            HStack(spacing: 12) {
                legendItem(color: .bbCoralDeep, isDashed: false, label: "Лёва")
                legendItem(color: .bbMint,      isDashed: false, label: "Норма 15–85%")
                legendItem(color: .bbMintDeep,  isDashed: true,  label: "Медиана")
            }
            .padding(.top, 4)
        }
        .bbCard(pad: 14)
    }

    private func legendItem(color: Color, isDashed: Bool, label: String) -> some View {
        HStack(spacing: 4) {
            if isDashed {
                HStack(spacing: 1) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle().fill(color).frame(width: 2.5, height: 1.5)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(color).frame(width: 12, height: 3)
            }
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
    }

    // MARK: - Measurements List

    private var measurementsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: selectedTab == 3 ? "История температуры" : "Последние замеры")
            if selectedTab == 3 {
                tempList
            } else {
                growthList
            }
        }
    }

    private var growthList: some View {
        VStack(spacing: 0) {
            ForEach(measurements.indices, id: \.self) { i in
                let m = measurements[i]
                HStack(spacing: 12) {
                    Text(m.dateLabel)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.bbInkMute)
                        .frame(width: 50, alignment: .leading)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(growthValue(m))
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInk)
                        if !m.delta.isEmpty {
                            Text(m.delta)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.bbInkSoft)
                        }
                    }
                    Spacer()
                    if let visit = m.visitLabel {
                        BBPill(text: "★ \(visit)", color: .bbSky, fg: .bbSkyDeep, size: 10)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                if i < measurements.count - 1 {
                    Divider().opacity(0.2).padding(.horizontal, 14)
                }
            }
        }
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .bbShadow()
    }

    private func growthValue(_ m: MeasurementEntry) -> String {
        switch selectedTab {
        case 1: return m.height
        case 2: return m.headCirc
        default: return "\(m.weight) · \(m.height)"
        }
    }

    private var tempList: some View {
        VStack(spacing: 0) {
            ForEach(tempLog.indices, id: \.self) { i in
                let entry = tempLog[i]
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(entry.dateLabel)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.bbInkMute)
                        Text(entry.timeLabel)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(.bbInkMute)
                    }
                    .frame(width: 50, alignment: .leading)
                    Text(String(format: "%.1f°C", entry.value))
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(tempValueColor(entry.value))
                    if !entry.note.isEmpty {
                        Text(entry.note)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInkSoft)
                            .lineLimit(1)
                    }
                    Spacer()
                    BBPill(
                        text: tempLabel(entry.value),
                        color: tempBgColor(entry.value),
                        fg: tempValueColor(entry.value),
                        size: 10
                    )
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                if i < tempLog.count - 1 {
                    Divider().opacity(0.2).padding(.horizontal, 14)
                }
            }
        }
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .bbShadow()
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button { showAddMeasurement = true } label: {
                Text("+ Вес / рост")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.bbCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .bbShadowSoft()
            }
            Button { showAddTemp = true } label: {
                Text("+ Температура")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.bbCoralDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    // MARK: - Helpers

    private func tempValueColor(_ v: Double) -> Color {
        v >= 38.5 ? .bbCoralDeep : v >= 37.5 ? .bbButterDeep : .bbMintDeep
    }
    private func tempBgColor(_ v: Double) -> Color {
        v >= 38.5 ? .bbRose : v >= 37.5 ? .bbButter : .bbMint
    }
    private func tempLabel(_ v: Double) -> String {
        v >= 38.5 ? "высокая" : v >= 37.5 ? "субфебр." : "норма"
    }
}

// MARK: - WHO Line Chart

private struct WHOLineChart: View {
    let data: [WeightPoint]
    let gridVals: [Int]
    let unit: String

    private let padL: CGFloat = 30, padR: CGFloat = 8, padT: CGFloat = 12, padB: CGFloat = 22

    private func xPos(_ i: Int, width: CGFloat) -> CGFloat {
        guard data.count > 1 else { return padL }
        return padL + CGFloat(i) / CGFloat(data.count - 1) * (width - padL - padR)
    }

    private func yPos(_ v: Double, height: CGFloat, minV: Double, maxV: Double) -> CGFloat {
        let range = max(maxV - minV, 0.01)
        return padT + CGFloat(1 - (v - minV) / range) * (height - padT - padB)
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let allVals = data.flatMap { [$0.babyKg, $0.p15, $0.p85] }
            let minV = (allVals.min() ?? 2.5) - 0.5
            let maxV = (allVals.max() ?? 9.0) + 0.5

            ZStack(alignment: .topLeading) {
                // P15–P85 band
                Path { p in
                    guard !data.isEmpty else { return }
                    p.move(to: CGPoint(x: xPos(0, width: w), y: yPos(data[0].p15, height: h, minV: minV, maxV: maxV)))
                    for i in data.indices.dropFirst() {
                        p.addLine(to: CGPoint(x: xPos(i, width: w), y: yPos(data[i].p15, height: h, minV: minV, maxV: maxV)))
                    }
                    for i in data.indices.reversed() {
                        p.addLine(to: CGPoint(x: xPos(i, width: w), y: yPos(data[i].p85, height: h, minV: minV, maxV: maxV)))
                    }
                    p.closeSubpath()
                }
                .fill(Color.bbMint.opacity(0.35))

                // P50 dashed median
                Path { p in
                    guard !data.isEmpty else { return }
                    p.move(to: CGPoint(x: xPos(0, width: w), y: yPos(data[0].p50, height: h, minV: minV, maxV: maxV)))
                    for i in data.indices.dropFirst() {
                        p.addLine(to: CGPoint(x: xPos(i, width: w), y: yPos(data[i].p50, height: h, minV: minV, maxV: maxV)))
                    }
                }
                .stroke(Color.bbMintDeep.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

                // Grid lines + Y labels
                ForEach(gridVals, id: \.self) { v in
                    let yg = yPos(Double(v), height: h, minV: minV, maxV: maxV)
                    Path { p in
                        p.move(to: CGPoint(x: padL, y: yg))
                        p.addLine(to: CGPoint(x: w - padR, y: yg))
                    }
                    .stroke(Color.bbInkMute.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [2, 4]))
                    Text("\(v)")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.bbInkMute)
                        .position(x: padL - 10, y: yg)
                }

                // Baby curve
                Path { p in
                    guard !data.isEmpty else { return }
                    p.move(to: CGPoint(x: xPos(0, width: w), y: yPos(data[0].babyKg, height: h, minV: minV, maxV: maxV)))
                    for i in data.indices.dropFirst() {
                        p.addLine(to: CGPoint(x: xPos(i, width: w), y: yPos(data[i].babyKg, height: h, minV: minV, maxV: maxV)))
                    }
                }
                .stroke(Color.bbCoralDeep, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))

                // Dots
                ForEach(data.indices, id: \.self) { i in
                    let pt = CGPoint(x: xPos(i, width: w), y: yPos(data[i].babyKg, height: h, minV: minV, maxV: maxV))
                    let isLast = i == data.count - 1
                    Circle()
                        .fill(isLast ? Color.bbCoralDeep : Color.white)
                        .frame(width: isLast ? 9 : 5, height: isLast ? 9 : 5)
                        .overlay(Circle().strokeBorder(Color.bbCoralDeep, lineWidth: 2))
                        .position(pt)
                }

                // Current value label
                if let last = data.last, let lastIdx = data.indices.last {
                    let pt = CGPoint(
                        x: xPos(lastIdx, width: w) - 22,
                        y: yPos(last.babyKg, height: h, minV: minV, maxV: maxV) - 16
                    )
                    Text(String(format: "%.1f \(unit)", last.babyKg))
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(Color.bbCoralDeep)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .position(pt)
                }

                // X labels
                ForEach(data.indices, id: \.self) { i in
                    Text("\(data[i].month)м")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.bbInkMute)
                        .position(x: xPos(i, width: w), y: h - 4)
                }
            }
        }
    }
}

// MARK: - Temperature Bar Chart

private struct TempBarChart: View {
    let entries: [TemperatureEntry]

    private func barColor(_ v: Double) -> Color {
        v >= 38.5 ? .bbCoralDeep : v >= 37.5 ? .bbButterDeep : .bbMintDeep
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Температура, °C")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Spacer()
                Text("последние замеры")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }

            if entries.isEmpty {
                Text("Нет данных о температуре")
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
                legendDot(color: .bbMintDeep,   label: "норма < 37.5°")
                legendDot(color: .bbButterDeep, label: "субфебр. 37.5–38.4°")
                legendDot(color: .bbCoralDeep,  label: "высокая ≥ 38.5°")
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

// MARK: - Add Measurement Sheet

private struct AddMeasurementSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (MeasurementEntry) -> Void

    @State private var weightStr = ""
    @State private var heightStr = ""
    @State private var headStr = ""

    private var isValid: Bool { !weightStr.isEmpty || !heightStr.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Замеры") {
                    HStack {
                        Text("Вес").foregroundColor(.bbInkSoft)
                        TextField("кг (напр. 6.4)", text: $weightStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Рост").foregroundColor(.bbInkSoft)
                        TextField("см (напр. 64)", text: $heightStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Окр. головы").foregroundColor(.bbInkSoft)
                        TextField("см (напр. 42)", text: $headStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section {
                    Text("Заполните хотя бы одно поле.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
            }
            .navigationTitle("Новый замер")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { save() }
                        .disabled(!isValid)
                        .fontWeight(.bold)
                }
            }
        }
    }

    private func save() {
        let w  = weightStr.isEmpty ? "—" : "\(weightStr) кг"
        let h  = heightStr.isEmpty ? "—" : "\(heightStr) см"
        let hc = headStr.isEmpty   ? "—" : "\(headStr) см"
        onAdd(MeasurementEntry(
            dateLabel: "Сегодня",
            weight: w, height: h, headCirc: hc,
            delta: "", visitLabel: nil
        ))
        dismiss()
    }
}

// MARK: - Add Temperature Sheet

private struct AddTempSheet: View {
    @Environment(\.dismiss) private var dismiss
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
        v >= 38.5 ? "Высокая 🌡" : v >= 37.5 ? "Субфебрильная" : "Норма ✓"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Температура") {
                    HStack {
                        Text("°C").foregroundColor(.bbInkSoft)
                        TextField("напр. 36.6", text: $tempStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    TextField("Заметка (необязательно)", text: $note)
                }
                if let val = parsedTemp {
                    Section("Предварительный просмотр") {
                        HStack {
                            Text(String(format: "%.1f°C", val))
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(valueColor(val))
                            Spacer()
                            Text(valueLabel(val))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(valueColor(val))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Записать температуру")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { save() }
                        .disabled(!isValid)
                        .fontWeight(.bold)
                }
            }
        }
    }

    private func save() {
        guard let val = parsedTemp else { return }
        let comps = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let timeLabel = String(format: "%02d:%02d", comps.hour ?? 0, comps.minute ?? 0)
        onAdd(TemperatureEntry(dateLabel: "Сегодня", timeLabel: timeLabel, value: val, note: note))
        dismiss()
    }
}

#Preview {
    NavigationStack { TrackingView() }
}
