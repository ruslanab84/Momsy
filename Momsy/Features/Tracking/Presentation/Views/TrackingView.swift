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
        .errorToast($vm.saveError)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                BBSectionLabel(text: loc.strings.health)
                Text(loc.strings.heightAndWeight)
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
        let data: [WHOPoint]
        let gridVals: [Int]
        let babyPoints: [BabyGrowthPoint]
    }

    private var currentChartConfig: ChartConfig {
        switch vm.selectedTab {
        case 1: return ChartConfig(title: loc.strings.heightCm,   unit: "cm", data: whoHeightData, gridVals: [50, 65, 80, 95], babyPoints: vm.babyHeightPoints)
        case 2: return ChartConfig(title: loc.strings.headCircCm, unit: "cm", data: whoHeadData,   gridVals: [33, 38, 43, 48], babyPoints: vm.babyHeadPoints)
        default: return ChartConfig(title: loc.strings.weightKg,  unit: "kg", data: whoWeightData,  gridVals: [4, 7, 10, 13],  babyPoints: vm.babyWeightPoints)
        }
    }

    private var growthChartCard: some View {
        let cfg = currentChartConfig
        return VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(cfg.title)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(loc.strings.whoRange)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                    let pLabel = vm.currentPercentileLabel
                    if !pLabel.isEmpty {
                        Text(pLabel)
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbCoralDeep)
                    }
                }
            }

            WHOLineChart(data: cfg.data, babyPoints: cfg.babyPoints, gridVals: cfg.gridVals, unit: cfg.unit)
                .frame(height: 160)
                .animation(.easeInOut(duration: 0.3), value: vm.selectedTab)

            HStack(spacing: 12) {
                legendItem(color: .bbCoralDeep, isDashed: false, label: vm.displayName)
                legendItem(color: .bbMint,      isDashed: false, label: "P15–P85")
                legendItem(color: .bbMintDeep,  isDashed: true,  label: loc.strings.median)
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
            BBSectionLabel(text: vm.selectedTab == 3 ? loc.strings.temperatureHistory : loc.strings.recentMeasurements)
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
                Text(loc.strings.addWeightHeight)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.bbCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .bbShadowSoft()
            }
            Button { vm.showAddTemp = true } label: {
                Text(loc.strings.addTemperature)
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
        v >= 38.5 ? loc.strings.high : v >= 37.5 ? loc.strings.subfebr : loc.strings.normal
    }
}

// MARK: - WHO Line Chart

private struct WHOLineChart: View {
    let data: [WHOPoint]
    let babyPoints: [BabyGrowthPoint]
    let gridVals: [Int]
    let unit: String

    private let padL: CGFloat = 32, padR: CGFloat = 8, padT: CGFloat = 12, padB: CGFloat = 22
    private let maxMonth: Int = 24

    private func xPos(month: Int, width: CGFloat) -> CGFloat {
        padL + CGFloat(month) / CGFloat(maxMonth) * (width - padL - padR)
    }

    private func yPos(_ v: Double, height: CGFloat, minV: Double, maxV: Double) -> CGFloat {
        let range = max(maxV - minV, 0.01)
        return padT + CGFloat(1 - (v - minV) / range) * (height - padT - padB)
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let whoVals = data.flatMap { [$0.p3, $0.p97] }
            let babyVals = babyPoints.map { $0.value }
            let allVals = whoVals + babyVals
            let minV = (allVals.min() ?? 2.5) - 0.5
            let maxV = (allVals.max() ?? 15.0) + 0.5
            let sorted = babyPoints.sorted { $0.month < $1.month }

            ZStack(alignment: .topLeading) {

                // Outer band: P3–P97
                Path { p in
                    guard let first = data.first else { return }
                    p.move(to: CGPoint(x: xPos(month: first.month, width: w), y: yPos(first.p3, height: h, minV: minV, maxV: maxV)))
                    for pt in data { p.addLine(to: CGPoint(x: xPos(month: pt.month, width: w), y: yPos(pt.p3, height: h, minV: minV, maxV: maxV))) }
                    for pt in data.reversed() { p.addLine(to: CGPoint(x: xPos(month: pt.month, width: w), y: yPos(pt.p97, height: h, minV: minV, maxV: maxV))) }
                    p.closeSubpath()
                }
                .fill(Color.bbMint.opacity(0.10))

                // Inner band: P15–P85
                Path { p in
                    guard let first = data.first else { return }
                    p.move(to: CGPoint(x: xPos(month: first.month, width: w), y: yPos(first.p15, height: h, minV: minV, maxV: maxV)))
                    for pt in data { p.addLine(to: CGPoint(x: xPos(month: pt.month, width: w), y: yPos(pt.p15, height: h, minV: minV, maxV: maxV))) }
                    for pt in data.reversed() { p.addLine(to: CGPoint(x: xPos(month: pt.month, width: w), y: yPos(pt.p85, height: h, minV: minV, maxV: maxV))) }
                    p.closeSubpath()
                }
                .fill(Color.bbMint.opacity(0.30))

                // Median P50
                Path { p in
                    guard let first = data.first else { return }
                    p.move(to: CGPoint(x: xPos(month: first.month, width: w), y: yPos(first.p50, height: h, minV: minV, maxV: maxV)))
                    for pt in data.dropFirst() { p.addLine(to: CGPoint(x: xPos(month: pt.month, width: w), y: yPos(pt.p50, height: h, minV: minV, maxV: maxV))) }
                }
                .stroke(Color.bbMintDeep.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

                // Grid lines
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
                        .position(x: padL - 12, y: yg)
                }

                // Baby measurement line
                if !sorted.isEmpty {
                    Path { p in
                        guard let first = sorted.first else { return }
                        p.move(to: CGPoint(x: xPos(month: first.month, width: w), y: yPos(first.value, height: h, minV: minV, maxV: maxV)))
                        for pt in sorted.dropFirst() { p.addLine(to: CGPoint(x: xPos(month: pt.month, width: w), y: yPos(pt.value, height: h, minV: minV, maxV: maxV))) }
                    }
                    .stroke(Color.bbCoralDeep, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))

                    ForEach(sorted.indices, id: \.self) { i in
                        let pt = sorted[i]
                        let isLast = i == sorted.count - 1
                        Circle()
                            .fill(isLast ? Color.bbCoralDeep : Color.white)
                            .frame(width: isLast ? 9 : 5, height: isLast ? 9 : 5)
                            .overlay(Circle().strokeBorder(Color.bbCoralDeep, lineWidth: 2))
                            .position(x: xPos(month: pt.month, width: w),
                                      y: yPos(pt.value, height: h, minV: minV, maxV: maxV))
                    }

                    if let last = sorted.last {
                        Text(String(format: "%.1f \(unit)", last.value))
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(Color.bbCoralDeep)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .position(x: xPos(month: last.month, width: w) - 24,
                                      y: yPos(last.value, height: h, minV: minV, maxV: maxV) - 16)
                    }
                }

                // X-axis labels at 0, 6, 12, 18, 24
                ForEach([0, 6, 12, 18, 24], id: \.self) { m in
                    Text("\(m)m")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.bbInkMute)
                        .position(x: xPos(month: m, width: w), y: h - 4)
                }
            }
        }
    }
}

// MARK: - Temperature Bar Chart

private struct TempBarChart: View {
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
