import Testing
@testable import Momsy
import Foundation

@Suite("WHO growth standards")
struct WHOGrowthStandardsTests {

    private static let tables: [(String, [WHOPoint])] = [
        ("weight boys",  WHOGrowthStandards.weight(.boy)),
        ("weight girls", WHOGrowthStandards.weight(.girl)),
        ("height boys",  WHOGrowthStandards.height(.boy)),
        ("height girls", WHOGrowthStandards.height(.girl)),
        ("head boys",    WHOGrowthStandards.head(.boy)),
        ("head girls",   WHOGrowthStandards.head(.girl)),
    ]

    @Test("every table covers months 0...24 with ascending percentiles")
    func tableShape() {
        for (name, table) in Self.tables {
            #expect(table.map(\.month) == Array(0...24), "\(name) months")
            for point in table {
                #expect(point.p3 < point.p15, "\(name) m\(point.month) p3<p15")
                #expect(point.p15 < point.p50, "\(name) m\(point.month) p15<p50")
                #expect(point.p50 < point.p85, "\(name) m\(point.month) p50<p85")
                #expect(point.p85 < point.p97, "\(name) m\(point.month) p85<p97")
            }
        }
    }

    // Pinned against the published WHO tables (tab_wfa/lhfa/hcfa_*_p_*.xlsx) so a
    // bad regeneration of the generated file fails here instead of shipping.
    @Test("birth-month values match the published WHO tables")
    func publishedBirthValues() throws {
        let boys = try #require(WHOGrowthStandards.weight(.boy).first)
        #expect(boys.p3 == 2.5)
        #expect(boys.p15 == 2.9)
        #expect(boys.p50 == 3.3)
        #expect(boys.p85 == 3.9)
        #expect(boys.p97 == 4.3)

        let girls = try #require(WHOGrowthStandards.weight(.girl).first)
        #expect(girls.p3 == 2.4)
        #expect(girls.p15 == 2.8)
        #expect(girls.p50 == 3.2)
        #expect(girls.p85 == 3.7)
        #expect(girls.p97 == 4.2)

        #expect(WHOGrowthStandards.height(.boy)[0].p50 == 49.9)
        #expect(WHOGrowthStandards.height(.girl)[0].p50 == 49.1)
        #expect(WHOGrowthStandards.head(.boy)[0].p50 == 34.5)
        #expect(WHOGrowthStandards.head(.girl)[0].p50 == 33.9)
    }

    // Pinned per sex rather than merely asserted different, so swapping the boys'
    // and girls' arrays for a metric fails instead of passing an inequality check.
    @Test("one-year medians match the published WHO tables per sex")
    func mediansDifferBySex() {
        #expect(WHOGrowthStandards.weight(.boy)[12].p50 == 9.6)
        #expect(WHOGrowthStandards.weight(.girl)[12].p50 == 8.9)
        #expect(WHOGrowthStandards.height(.boy)[12].p50 == 75.7)
        #expect(WHOGrowthStandards.height(.girl)[12].p50 == 74.0)
        #expect(WHOGrowthStandards.head(.boy)[12].p50 == 46.1)
        #expect(WHOGrowthStandards.head(.girl)[12].p50 == 44.9)
    }

    @Test("sex maps from the stored profile gender string")
    func sexFromProfile() {
        #expect(BabyProfile(gender: "boy").sex == .boy)
        #expect(BabyProfile(gender: "girl").sex == .girl)
        #expect(BabyProfile(gender: "unknown").sex == nil)
        #expect(BabyProfile(gender: "").sex == nil)
    }
}

@Suite("TrackingViewModel percentiles", .serialized)
@MainActor
struct TrackingViewModelPercentileTests {

    private func makeVM(gender: String, weightKg: String, ageMonths: Int) async -> TrackingViewModel {
        let birth = Calendar.current.date(byAdding: .month, value: -ageMonths, to: Date()) ?? Date()
        let profile = BabyProfile(name: "Baby", birthDate: birth, gender: gender)
        let measurements = MockMeasurementRepository()
        measurements.entries = [
            MeasurementEntry(date: Date(), dateLabel: "1 Jan", weight: weightKg,
                             height: "—", headCirc: "—", delta: "")
        ]
        let vm = TrackingViewModel(measurementRepo: measurements,
                                   temperatureRepo: MockTemperatureRepository(),
                                   appState: makeAppState(profile: profile))
        await vm.loadAll()
        return vm
    }

    // 8.9 kg at 12 months is the girls' median (P50) but only ~P25 for boys:
    // the boys-only table used to push girls one bucket down.
    @Test("a girl is classified against the girls' table")
    func girlUsesGirlsTable() async {
        let vm = await makeVM(gender: "girl", weightKg: "8.9 kg", ageMonths: 12)
        #expect(vm.currentPercentileLabel == "P50–P85")
    }

    @Test("a boy is classified against the boys' table")
    func boyUsesBoysTable() async {
        let vm = await makeVM(gender: "boy", weightKg: "8.9 kg", ageMonths: 12)
        #expect(vm.currentPercentileLabel == "P15–P50")
    }

    @Test("unknown sex yields no reference and no percentile label")
    func unknownSexHidesPercentiles() async {
        for gender in ["", "unknown"] {
            let vm = await makeVM(gender: gender, weightKg: "8.9 kg", ageMonths: 12)
            #expect(vm.babySex == nil)
            #expect(vm.currentReference == nil)
            #expect(vm.currentPercentileLabel == "")
        }
    }

    @Test("the reference follows the selected tab")
    func referenceFollowsTab() async {
        let vm = await makeVM(gender: "girl", weightKg: "8.9 kg", ageMonths: 12)
        #expect(vm.currentReference?.first?.p50 == WHOGrowthStandards.weight(.girl)[0].p50)
        vm.selectedTab = 1
        #expect(vm.currentReference?.first?.p50 == WHOGrowthStandards.height(.girl)[0].p50)
        vm.selectedTab = 2
        #expect(vm.currentReference?.first?.p50 == WHOGrowthStandards.head(.girl)[0].p50)
        vm.selectedTab = 3
        #expect(vm.currentReference == nil)
    }
}

// MARK: - Mocks

final class MockMeasurementRepository: MeasurementRepository, @unchecked Sendable {
    var entries: [MeasurementEntry] = []

    func getAll() async throws -> [MeasurementEntry] { entries }
    func add(_ entry: MeasurementEntry) async throws { entries.insert(entry, at: 0) }
    func upsert(_ entries: [MeasurementEntry]) async throws { self.entries = entries }
    func delete(id: UUID) async throws { entries.removeAll { $0.id == id } }
}

final class MockTemperatureRepository: TemperatureRepository, @unchecked Sendable {
    var entries: [TemperatureEntry] = []

    func getAll() async throws -> [TemperatureEntry] { entries }
    func getEntries(from: Date, to: Date) async throws -> [TemperatureEntry] {
        entries.filter { $0.date >= from && $0.date <= to }
    }
    func add(_ entry: TemperatureEntry) async throws { entries.insert(entry, at: 0) }
    func upsert(_ entries: [TemperatureEntry]) async throws { self.entries = entries }
    func delete(id: UUID) async throws { entries.removeAll { $0.id == id } }
}
