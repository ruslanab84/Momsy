import SwiftUI

// MARK: - TrackingView

struct TrackingView: View {
    @StateObject private var vm: TrackingViewModel
    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject var units: UnitSystemManager
    @EnvironmentObject var appState: AppState
    @ObservedObject private var familyManager = FamilyManager.shared
    @State private var showEditProfile = false

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
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
        .task(id: appState.babyProfile?.id) { await vm.loadAll() }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $vm.showAddMeasurement) {
            AddMeasurementSheet { entry in vm.addMeasurement(entry) }
        }
        .sheet(isPresented: $vm.showAddTemp) {
            AddTempSheet { entry in vm.addTemp(entry) }
        }
        .sheet(isPresented: $showEditProfile) {
            if let profile = appState.babyProfile {
                EditBabyProfileView(profile: profile)
                    .environmentObject(loc)
                    .environmentObject(appState)
                    .withContainer(container)
            }
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
                Text(headerSummary)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .animation(.easeInOut(duration: 0.2), value: vm.selectedTab)
            }
            Spacer()
            BBPill(text: vm.pillText, color: vm.pillColor, fg: vm.pillFg)
                .animation(.easeInOut(duration: 0.2), value: vm.selectedTab)
        }
    }

    private var headerSummary: String {
        guard vm.selectedTab == 3, let entry = vm.tempLog.first else {
            return vm.headerSummary
        }
        return String(
            format: "%.1f°C · %@ %@",
            entry.value,
            entry.dateLabel,
            entry.date.formatted(units.current.timeFormatStyle())
        )
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
        let data: [WHOPoint]?
        let gridVals: [Int]
        let babyPoints: [BabyGrowthPoint]
    }

    private var currentChartConfig: ChartConfig {
        if units.isImperial {
            switch vm.selectedTab {
            case 1:
                return ChartConfig(
                    title: "Height, in", unit: "in",
                    data:  vm.currentReference?.scaledBy(units.heightChartFactor),
                    gridVals: [20, 26, 31, 37],
                    babyPoints: vm.babyHeightPoints.map {
                        BabyGrowthPoint(month: $0.month, value: $0.value * units.heightChartFactor)
                    }
                )
            case 2:
                return ChartConfig(
                    title: "Head circ., in", unit: "in",
                    data:  vm.currentReference?.scaledBy(units.heightChartFactor),
                    gridVals: [13, 15, 17, 19],
                    babyPoints: vm.babyHeadPoints.map {
                        BabyGrowthPoint(month: $0.month, value: $0.value * units.heightChartFactor)
                    }
                )
            default:
                return ChartConfig(
                    title: "Weight, lb", unit: "lb",
                    data:  vm.currentReference?.scaledBy(units.weightChartFactor),
                    gridVals: [9, 15, 22, 29],
                    babyPoints: vm.babyWeightPoints.map {
                        BabyGrowthPoint(month: $0.month, value: $0.value * units.weightChartFactor)
                    }
                )
            }
        } else {
            switch vm.selectedTab {
            case 1: return ChartConfig(title: loc.strings.heightCm,   unit: "cm", data: vm.currentReference, gridVals: [50, 65, 80, 95], babyPoints: vm.babyHeightPoints)
            case 2: return ChartConfig(title: loc.strings.headCircCm, unit: "cm", data: vm.currentReference, gridVals: [33, 38, 43, 48], babyPoints: vm.babyHeadPoints)
            default: return ChartConfig(title: loc.strings.weightKg,  unit: "kg", data: vm.currentReference, gridVals: [4, 7, 10, 13],  babyPoints: vm.babyWeightPoints)
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
                    Text(whoRangeLabel)
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
                if vm.currentReference != nil {
                    legendItem(color: .bbMint,     isDashed: false, label: "P15–P85")
                    legendItem(color: .bbMintDeep, isDashed: true,  label: loc.strings.median)
                }
            }
            .padding(.top, 4)

            if vm.babySex == nil {
                sexHint
            }
        }
        .bbCard(pad: 14)
    }

    private var whoRangeLabel: String {
        switch vm.babySex {
        case .boy:  return "\(loc.strings.whoRange) · \(loc.strings.genderBoy)"
        case .girl: return "\(loc.strings.whoRange) · \(loc.strings.genderGirl)"
        case nil:   return loc.strings.whoRange
        }
    }

    /// A co-parent without profile rights cannot fix the missing sex, so the hint
    /// stays informational for them instead of leading into a denied save.
    private var canEditProfile: Bool {
        appState.babyProfile != nil && familyManager.canPerform(.manageBabyProfiles)
    }

    private var sexHint: some View {
        Group {
            if canEditProfile {
                Button { showEditProfile = true } label: {
                    sexHintLabel(showsChevron: true)
                }
            } else {
                sexHintLabel(showsChevron: false)
            }
        }
    }

    private func sexHintLabel(showsChevron: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 11, weight: .bold))
            Text(loc.strings.setSexForPercentiles)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .multilineTextAlignment(.leading)
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .heavy))
            }
        }
        .foregroundColor(.bbInkSoft)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
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
                        Text(entry.date, format: units.current.timeFormatStyle())
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(.bbInkMute)
                    }
                    .frame(width: units.isImperial ? 68 : 50, alignment: .leading)
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
