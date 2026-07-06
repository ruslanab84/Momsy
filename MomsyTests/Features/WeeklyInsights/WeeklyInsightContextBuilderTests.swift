import Testing
@testable import Momsy
import Foundation

@Suite("WeeklyInsightContextBuilder")
struct WeeklyInsightContextBuilderTests {

    private func window() -> (start: Date, end: Date) {
        let start = Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 1_750_000_000))
        let end = Calendar.current.date(byAdding: .day, value: 7, to: start)!
        return (start, end)
    }

    private func sleep(_ start: Date, minutes: Int, quality: SleepQuality = .normal) -> SleepEntry {
        SleepEntry(startDate: start, endDate: start.addingTimeInterval(TimeInterval(minutes * 60)), quality: quality)
    }

    @Test("aggregates night/day sleep, naps and feeding averages")
    func aggregates() async throws {
        let (start, end) = window()
        let sleepRepo = MockSleepRepository()
        sleepRepo.entries = [
            sleep(start.addingTimeInterval(21 * 3600), minutes: 600),          // night 10h
            sleep(start.addingTimeInterval(24 * 3600 + 13 * 3600), minutes: 60) // day nap 1h
        ]
        let feedingRepo = MockFeedingRepository()
        feedingRepo.entries = (0..<14).map {
            FeedingEntry(date: start.addingTimeInterval(Double($0) * 3600), durationSeconds: 600)
        }
        let foodRepo = MockComplementaryFeedingRepository()
        let diaperRepo = MockDiaperRepository()

        let stats = await WeeklyInsightContextBuilder.buildStats(
            weekStart: start, weekEnd: end,
            birthDate: Calendar.current.date(byAdding: .month, value: -7, to: end),
            language: .english,
            sleepRepo: sleepRepo, feedingRepo: feedingRepo, foodRepo: foodRepo, diaperRepo: diaperRepo
        )

        #expect(stats.avgSleepMinutesPerDay == 660 / 7)
        #expect(stats.avgNightSleepMinutes == 600 / 7)
        #expect(stats.avgDaySleepMinutes == 60 / 7)
        #expect(stats.totalFeedings == 14)
        #expect(abs(stats.avgFeedingsPerDay - 2.0) < 0.001)
        #expect(stats.whoMinSleepMinutes == WhoNorms.minSleepMinutes(ageMonths: 7))
    }

    @Test("extracts new foods and flags allergens/reactions")
    func foodsAndAllergens() async throws {
        let (start, end) = window()
        let foodRepo = MockComplementaryFeedingRepository()
        foodRepo.entries = [
            ComplementaryFoodEntry(id: UUID(), date: start.addingTimeInterval(3600), foodName: "Broccoli",
                                   category: .vegetable, reaction: .none, isAllergen: false, notes: "", photoPath: nil),
            ComplementaryFoodEntry(id: UUID(), date: start.addingTimeInterval(7200), foodName: "Egg",
                                   category: .egg, reaction: .none, isAllergen: true, notes: "", photoPath: nil),
            ComplementaryFoodEntry(id: UUID(), date: start.addingTimeInterval(10800), foodName: "Strawberry",
                                   category: .fruit, reaction: .mild, isAllergen: false, notes: "", photoPath: nil),
            // Outside the window — must be ignored.
            ComplementaryFoodEntry(id: UUID(), date: start.addingTimeInterval(-100000), foodName: "Apple",
                                   category: .fruit, reaction: .none, isAllergen: false, notes: "", photoPath: nil)
        ]

        let stats = await WeeklyInsightContextBuilder.buildStats(
            weekStart: start, weekEnd: end, birthDate: nil, language: .english,
            sleepRepo: MockSleepRepository(), feedingRepo: MockFeedingRepository(),
            foodRepo: foodRepo, diaperRepo: MockDiaperRepository()
        )

        #expect(stats.newFoodsIntroduced.contains("Broccoli"))
        #expect(stats.newFoodsIntroduced.contains("Egg"))
        #expect(!stats.newFoodsIntroduced.contains("Apple"))
        #expect(stats.allergensFlagged.contains("Egg"))
        #expect(stats.allergensFlagged.contains("Strawberry"))
        #expect(!stats.allergensFlagged.contains("Broccoli"))
    }

    @Test("sleep trend compares against the previous week")
    func trend() async throws {
        let (start, end) = window()
        let prevStart = Calendar.current.date(byAdding: .day, value: -7, to: start)!
        let sleepRepo = MockSleepRepository()
        sleepRepo.entries = [
            sleep(start.addingTimeInterval(21 * 3600), minutes: 700),       // this week
            sleep(prevStart.addingTimeInterval(21 * 3600), minutes: 70)     // previous week (less)
        ]
        let stats = await WeeklyInsightContextBuilder.buildStats(
            weekStart: start, weekEnd: end, birthDate: nil, language: .english,
            sleepRepo: sleepRepo, feedingRepo: MockFeedingRepository(),
            foodRepo: MockComplementaryFeedingRepository(), diaperRepo: MockDiaperRepository()
        )
        #expect(stats.sleepTrendVsPrevWeekMinutes == (700 / 7) - (70 / 7))
    }

    @Test("adds leap signals from check-ins and diary milestones")
    func leapSignals() async throws {
        let (start, end) = window()
        let birthDate = Calendar.current.date(byAdding: .weekOfYear, value: -16, to: end)!
        let checkInRepo = MockLeapCheckInRepository()
        checkInRepo.checkIns = [
            LeapDailyCheckIn(
                leapID: 4,
                date: start.addingTimeInterval(12 * 3600),
                symptoms: [.sleepWorse, .appetiteShift]
            )
        ]
        let diaryRepo = MockDiaryRepository()
        diaryRepo.items = [
            StoredDiaryItem(
                date: start.addingTimeInterval(24 * 3600),
                kind: .milestone,
                text: "Grabs toys",
                isMilestone: true,
                iconName: "star"
            )
        ]

        let stats = await WeeklyInsightContextBuilder.buildStats(
            weekStart: start, weekEnd: end, birthDate: birthDate, language: .english,
            sleepRepo: MockSleepRepository(), feedingRepo: MockFeedingRepository(),
            foodRepo: MockComplementaryFeedingRepository(), diaperRepo: MockDiaperRepository(),
            leapCheckInRepo: checkInRepo, diaryRepo: diaryRepo
        )

        #expect(stats.currentLeapID == 4)
        #expect(stats.leapSignals.contains("sleep"))
        #expect(stats.leapSignals.contains("feedings"))
        #expect(stats.leapSignals.contains("new skills"))
    }
}
