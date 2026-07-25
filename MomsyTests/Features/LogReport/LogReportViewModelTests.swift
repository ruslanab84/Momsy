import Testing
import Foundation
@testable import Momsy

@MainActor
struct LogReportViewModelTests {

    private func makeSUT() -> (LogReportViewModel, MockFeedingRepository, MockSleepRepository,
                               MockDiaperRepository, MockVitaminRepository) {
        let feeding = MockFeedingRepository()
        let sleep = MockSleepRepository()
        let diaper = MockDiaperRepository()
        let vitamin = MockVitaminRepository()
        let useCase = GetLogReportEntriesUseCase(
            feedingRepo: feeding, sleepRepo: sleep,
            diaperRepo: diaper, stoolRepo: MockStoolRepository(),
            walkRepo: MockWalkRepository(), bathRepo: MockBathRepository(),
            pumpingRepo: MockPumpingRepository(), vitaminRepo: vitamin
        )
        return (LogReportViewModel(getEntries: useCase), feeding, sleep, diaper, vitamin)
    }

    @Test func dayModeAggregatesAllSourcesNewestFirst() async {
        let (vm, feeding, sleep, _, vitamin) = makeSUT()
        let now = Date()
        feeding.entries = [FeedingEntry(date: now.addingTimeInterval(-3_600), durationSeconds: 600)]
        sleep.entries = [SleepEntry(startDate: now.addingTimeInterval(-7_200),
                                    endDate: now.addingTimeInterval(-5_400))]
        vitamin.entries = [VitaminEntry(date: now.addingTimeInterval(-600), label: "Vitamins · D3")]

        vm.mode = .day
        vm.selectedDate = now
        await vm.load()

        #expect(vm.items.count == 3)
        #expect(vm.items.first?.kind == .vitamin)
        #expect(vm.items.last?.kind == .sleep)
    }

    @Test func vitaminEntriesComeFromLocalRepository() async {
        let (vm, _, _, _, vitamin) = makeSUT()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        vitamin.entries = [VitaminEntry(date: yesterday, label: "Vitamins · given")]

        vm.mode = .day
        vm.selectedDate = yesterday
        await vm.load()

        #expect(vm.items.contains { $0.kind == .vitamin })
    }

    @Test func diaperLabelsAreNumberedPerDayAscending() async {
        let (vm, _, _, diaper, _) = makeSUT()
        let dayStart = Calendar.current.startOfDay(for: Date())
        diaper.entries = [
            DiaperEntry(date: dayStart.addingTimeInterval(10 * 3_600)),
            DiaperEntry(date: dayStart.addingTimeInterval(8 * 3_600)),
        ]

        vm.mode = .day
        vm.selectedDate = dayStart
        await vm.load()

        let diapers = vm.items.filter { $0.kind == .drop }.sorted { $0.start < $1.start }
        #expect(diapers.first?.label.contains("#1") == true)
        #expect(diapers.last?.label.contains("#2") == true)
    }

    @Test func weekRangeSpansSevenDays() {
        let (vm, _, _, _, _) = makeSUT()
        vm.mode = .week
        #expect(vm.weekDays.count == 7)
        let bounds = vm.range
        #expect(Int(bounds.to.timeIntervalSince(bounds.from)) == 7 * 86_400)
    }

    @Test func sleepCrossingMidnightAppearsInBothDayColumns() async {
        let (vm, _, sleep, _, _) = makeSUT()
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        sleep.entries = [SleepEntry(startDate: yesterday.addingTimeInterval(23 * 3_600),
                                    endDate: today.addingTimeInterval(3_600))]

        vm.mode = .week
        vm.selectedDate = today
        await vm.load()

        // The same session yields a clipped segment on both days of the timeline.
        #expect(!vm.timelineSegments(on: yesterday).isEmpty || !vm.weekDays.contains(yesterday))
        #expect(!vm.timelineSegments(on: today).isEmpty)
    }

    @Test func sessionEndingAtDayStartIsExcludedButInstantAtDayStartRemains() async throws {
        let (vm, _, sleep, diaper, _) = makeSUT()
        let cal = Calendar.current
        vm.mode = .week
        vm.selectedDate = Date()
        let dayStart = try #require(cal.date(byAdding: .day, value: 1, to: vm.range.from))
        sleep.entries = [
            SleepEntry(startDate: dayStart.addingTimeInterval(-3_600), endDate: dayStart)
        ]
        diaper.entries = [DiaperEntry(date: dayStart)]

        await vm.load()

        #expect(!vm.items(on: dayStart).contains { $0.kind == .sleep })
        #expect(vm.items(on: dayStart).contains { $0.kind == .drop })
        #expect(!vm.timelineSegments(on: dayStart).contains { $0.kind == .sleep })
        #expect(vm.timelineSegments(on: dayStart).contains { $0.kind == .drop })
    }
}
