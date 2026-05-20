import SwiftUI

// MARK: - TrackingView

struct TrackingView: View {
    @StateObject private var vm: TrackingViewModel
    @EnvironmentObject var loc: LocalizationManager

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeTrackingViewModel())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                tabPicker
                if vm.selectedTab == 3 {
                    TempBarChart(entries: Array(vm.tempLog.prefix(7).reversed()), lang: loc.lang)
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
        .sheet(isPresented: $vm.showAddMeasurement) {
            AddMeasurementSheet { entry in vm.addMeasurement(entry) }
        }
        .sheet(isPresented: $vm.showAddTemp) {
            AddTempSheet { entry in vm.addTemp(entry) }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                BBSectionLabel(text: loc.t("Health", "Здоровье"))
                Text(loc.t("Height & Weight", "Рост и вес"))
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(vm.headerSummary)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .animation(.easeInOut(duration: 0.2), value: vm.selectedTab)
            }
            Spacer()
            BBPill(text: vm.pillText, color: vm.pillColor, fg: vm.pillFg)
                .animation(.easeInOut(duration: 0.2), value: vm.selectedTab)
        }
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(vm.tabs.indices, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.3)) { vm.selectedTab = i }
                    } label: {
                        Text(vm.tabs[i])
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(i == vm.selectedTab ? .white : .bbInkSoft)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(i == vm.selectedTab ? Color.bbSurface : Color.bbCard)
                            .clipShape(Capsule())
                            .bbShadowSoft()
                    }
                }
            }
        }
    }

    // MARK: - Growth Chart Card (tabs 0–2)

    private struct ChartConfig {
        let title: String
        let unit: String
        let data: [WeightPoint]
        let gridVals: [Int]
    }

    private var currentChartConfig: ChartConfig {
        switch vm.selectedTab {
        case 1: return ChartConfig(title: loc.t("Height, cm", "Рост, см"),            unit: "cm", data: whoHeightData, gridVals: [50, 55, 60, 65])
        case 2: return ChartConfig(title: loc.t("Head circ., cm", "Окруж. головы, см"), unit: "cm", data: whoHeadData,   gridVals: [34, 37, 40, 43])
        default: return ChartConfig(title: loc.t("Weight, kg", "Вес, кг"),             unit: "kg", data: whoWeightData,  gridVals: [3, 5, 7, 9])
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
                Text(loc.t("0–5 mo · WHO percentiles", "0–5 мес · перцентили ВОЗ"))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }

            WHOLineChart(data: cfg.data, gridVals: cfg.gridVals, unit: cfg.unit)
                .frame(height: 160)
                .animation(.easeInOut(duration: 0.3), value: vm.selectedTab)

            HStack(spacing: 12) {
                legendItem(color: .bbCoralDeep, isDashed: false, label: loc.t("Baby", "Лёва"))
                legendItem(color: .bbMint,      isDashed: false, label: loc.t("Normal 15–85%", "Норма 15–85%"))
                legendItem(color: .bbMintDeep,  isDashed: true,  label: loc.t("Median", "Медиана"))
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
            BBSectionLabel(text: vm.selectedTab == 3 ? loc.t("Temperature history", "История температуры") : loc.t("Recent measurements", "Последние замеры"))
            if vm.selectedTab == 3 {
                tempList
            } else {
                growthList
            }
        }
    }

    private var growthList: some View {
        VStack(spacing: 0) {
            ForEach(vm.measurements.indices, id: \.self) { i in
                let m = vm.measurements[i]
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
                if i < vm.measurements.count - 1 {
                    Divider().opacity(0.2).padding(.horizontal, 14)
                }
            }
        }
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .bbShadow()
    }

    private func growthValue(_ m: MeasurementEntry) -> String {
        switch vm.selectedTab {
        case 1: return m.height
        case 2: return m.headCirc
        default: return "\(m.weight) · \(m.height)"
        }
    }

    private var tempList: some View {
        VStack(spacing: 0) {
            ForEach(vm.tempLog.indices, id: \.self) { i in
                let entry = vm.tempLog[i]
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
                if i < vm.tempLog.count - 1 {
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
            Button { vm.showAddMeasurement = true } label: {
                Text(loc.t("+ Weight / Height", "+ Вес / рост"))
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.bbCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .bbShadowSoft()
            }
            Button { vm.showAddTemp = true } label: {
                Text(loc.t("+ Temperature", "+ Температура"))
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
        v >= 38.5 ? loc.t("high", "высокая") : v >= 37.5 ? loc.t("subfebr.", "субфебр.") : loc.t("normal", "норма")
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

                Path { p in
                    guard !data.isEmpty else { return }
                    p.move(to: CGPoint(x: xPos(0, width: w), y: yPos(data[0].p50, height: h, minV: minV, maxV: maxV)))
                    for i in data.indices.dropFirst() {
                        p.addLine(to: CGPoint(x: xPos(i, width: w), y: yPos(data[i].p50, height: h, minV: minV, maxV: maxV)))
                    }
                }
                .stroke(Color.bbMintDeep.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

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

                Path { p in
                    guard !data.isEmpty else { return }
                    p.move(to: CGPoint(x: xPos(0, width: w), y: yPos(data[0].babyKg, height: h, minV: minV, maxV: maxV)))
                    for i in data.indices.dropFirst() {
                        p.addLine(to: CGPoint(x: xPos(i, width: w), y: yPos(data[i].babyKg, height: h, minV: minV, maxV: maxV)))
                    }
                }
                .stroke(Color.bbCoralDeep, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))

                ForEach(data.indices, id: \.self) { i in
                    let pt = CGPoint(x: xPos(i, width: w), y: yPos(data[i].babyKg, height: h, minV: minV, maxV: maxV))
                    let isLast = i == data.count - 1
                    Circle()
                        .fill(isLast ? Color.bbCoralDeep : Color.white)
                        .frame(width: isLast ? 9 : 5, height: isLast ? 9 : 5)
                        .overlay(Circle().strokeBorder(Color.bbCoralDeep, lineWidth: 2))
                        .position(pt)
                }

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

                ForEach(data.indices, id: \.self) { i in
                    Text("\(data[i].month)m")
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
    let lang: String

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }
    private func barColor(_ v: Double) -> Color {
        v >= 38.5 ? .bbCoralDeep : v >= 37.5 ? .bbButterDeep : .bbMintDeep
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(t("Temperature, °C", "Температура, °C"))
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Spacer()
                Text(t("recent readings", "последние замеры"))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }

            if entries.isEmpty {
                Text(t("No temperature data", "Нет данных о температуре"))
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
                legendDot(color: .bbMintDeep,   label: t("normal < 37.5°", "норма < 37.5°"))
                legendDot(color: .bbButterDeep, label: t("subfebr. 37.5–38.4°", "субфебр. 37.5–38.4°"))
                legendDot(color: .bbCoralDeep,  label: t("high ≥ 38.5°", "высокая ≥ 38.5°"))
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
    @EnvironmentObject var loc: LocalizationManager
    let onAdd: (MeasurementEntry) -> Void

    @State private var weightStr = ""
    @State private var heightStr = ""
    @State private var headStr = ""

    private var isValid: Bool { !weightStr.isEmpty || !heightStr.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section(loc.t("Measurements", "Замеры")) {
                    HStack {
                        Text(loc.t("Weight", "Вес")).foregroundColor(.bbInkSoft)
                        TextField(loc.t("kg (e.g. 6.4)", "кг (напр. 6.4)"), text: $weightStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text(loc.t("Height", "Рост")).foregroundColor(.bbInkSoft)
                        TextField(loc.t("cm (e.g. 64)", "см (напр. 64)"), text: $heightStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text(loc.t("Head circ.", "Окр. головы")).foregroundColor(.bbInkSoft)
                        TextField(loc.t("cm (e.g. 42)", "см (напр. 42)"), text: $headStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section {
                    Text(loc.t("Fill in at least one field.", "Заполните хотя бы одно поле."))
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
            }
            .navigationTitle(loc.t("New measurement", "Новый замер"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("Cancel", "Отмена")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.t("Save", "Сохранить")) { save() }
                        .disabled(!isValid)
                        .fontWeight(.bold)
                }
            }
        }
    }

    private func save() {
        let w  = weightStr.isEmpty ? "—" : "\(weightStr) \(loc.t("kg", "кг"))"
        let h  = heightStr.isEmpty ? "—" : "\(heightStr) \(loc.t("cm", "см"))"
        let hc = headStr.isEmpty   ? "—" : "\(headStr) \(loc.t("cm", "см"))"
        onAdd(MeasurementEntry(
            dateLabel: loc.t("Today", "Сегодня"),
            weight: w, height: h, headCirc: hc,
            delta: "", visitLabel: nil
        ))
        dismiss()
    }
}

// MARK: - Add Temperature Sheet

private struct AddTempSheet: View {
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
        v >= 38.5 ? loc.t("High 🌡", "Высокая 🌡") : v >= 37.5 ? loc.t("Subfebr.", "Субфебрильная") : loc.t("Normal ✓", "Норма ✓")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(loc.t("Temperature", "Температура")) {
                    HStack {
                        Text("°C").foregroundColor(.bbInkSoft)
                        TextField(loc.t("e.g. 37.2", "напр. 37.2"), text: $tempStr)
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
                Section(loc.t("Note", "Заметка")) {
                    TextField(loc.t("Optional note…", "Необязательная заметка…"), text: $note)
                }
            }
            .navigationTitle(loc.t("Log Temperature", "Записать температуру"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.t("Cancel", "Отмена")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.t("Save", "Сохранить")) { save() }
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
