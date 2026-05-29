import SwiftUI

// MARK: - TrackingView

struct TrackingView: View {
    @StateObject private var vm: TrackingViewModel
    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject var units: UnitSystemManager

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
        if units.isImperial {
            switch vm.selectedTab {
            case 1:
                return ChartConfig(
                    title: "Height, in", unit: "in",
                    data:  whoHeightData.scaledBy(units.heightChartFactor),
                    gridVals: [20, 26, 31, 37],
                    babyPoints: vm.babyHeightPoints.map {
                        BabyGrowthPoint(month: $0.month, value: $0.value * units.heightChartFactor)
                    }
                )
            case 2:
                return ChartConfig(
                    title: "Head circ., in", unit: "in",
                    data:  whoHeadData.scaledBy(units.heightChartFactor),
                    gridVals: [13, 15, 17, 19],
                    babyPoints: vm.babyHeadPoints.map {
                        BabyGrowthPoint(month: $0.month, value: $0.value * units.heightChartFactor)
                    }
                )
            default:
                return ChartConfig(
                    title: "Weight, lb", unit: "lb",
                    data:  whoWeightData.scaledBy(units.weightChartFactor),
                    gridVals: [9, 15, 22, 29],
                    babyPoints: vm.babyWeightPoints.map {
                        BabyGrowthPoint(month: $0.month, value: $0.value * units.weightChartFactor)
                    }
                )
            }
        } else {
            switch vm.selectedTab {
            case 1: return ChartConfig(title: loc.strings.heightCm,   unit: "cm", data: whoHeightData, gridVals: [50, 65, 80, 95], babyPoints: vm.babyHeightPoints)
            case 2: return ChartConfig(title: loc.strings.headCircCm, unit: "cm", data: whoHeadData,   gridVals: [33, 38, 43, 48], babyPoints: vm.babyHeadPoints)
            default: return ChartConfig(title: loc.strings.weightKg,  unit: "kg", data: whoWeightData,  gridVals: [4, 7, 10, 13],  babyPoints: vm.babyWeightPoints)
            }
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
        case 1: return units.displayHeightFromStored(m.height, localizedMetricUnit: loc.strings.unitCm)
        case 2: return units.displayHeightFromStored(m.headCirc, localizedMetricUnit: loc.strings.unitCm)
        default:
            let w = units.displayWeightFromStored(m.weight, localizedMetricUnit: loc.strings.unitKg)
            let h = units.displayHeightFromStored(m.height, localizedMetricUnit: loc.strings.unitCm)
            return "\(w) · \(h)"
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
                    Text(String(format: "%.1f%@", units.displayTemp(fromCelsius: entry.value), units.tempUnit))
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
