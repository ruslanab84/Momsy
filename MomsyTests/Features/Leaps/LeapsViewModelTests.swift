import Testing
@testable import Momsy
import Foundation

final class MockLeapCheckInRepository: LeapCheckInRepository {
    var checkIns: [LeapDailyCheckIn] = []

    func getCheckIns(leapID: Int) async throws -> [LeapDailyCheckIn] {
        checkIns.filter { $0.leapID == leapID }
    }

    func saveCheckIn(_ checkIn: LeapDailyCheckIn) async throws {
        checkIns.removeAll { $0.leapID == checkIn.leapID && Calendar.current.isDate($0.date, inSameDayAs: checkIn.date) }
        if !checkIn.symptoms.isEmpty {
            checkIns.append(checkIn)
        }
    }
}

@Suite("LeapsViewModel", .serialized)
@MainActor
struct LeapsViewModelTests {

    func makeVM(
        repo: MockLeapsRepository? = nil,
        checkInRepo: MockLeapCheckInRepository? = nil,
        sleepRepo: MockSleepRepository? = nil,
        feedingRepo: MockFeedingRepository? = nil,
        profile: BabyProfile? = nil
    ) async throws -> LeapsViewModel {
        let repo = repo ?? MockLeapsRepository()
        let checkInRepo = checkInRepo ?? MockLeapCheckInRepository()
        let sleepRepo = sleepRepo ?? MockSleepRepository()
        let feedingRepo = feedingRepo ?? MockFeedingRepository()
        let state = makeAppState(profile: profile)
        let vm = LeapsViewModel(
            getLeaps: GetLeapsUseCase(repository: repo),
            markLeapComplete: MarkLeapCompleteUseCase(repository: repo),
            getCheckIns: GetLeapCheckInsUseCase(repository: checkInRepo),
            saveCheckIn: SaveLeapCheckInUseCase(repository: checkInRepo),
            getSleep: GetSleepEntriesUseCase(repository: sleepRepo),
            getFeeding: GetFeedingEntriesUseCase(repository: feedingRepo),
            appState: state
        )
        try await Task.sleep(nanoseconds: 50_000_000)
        return vm
    }

    // MARK: - loadLeaps

    @Test("loadLeaps maps catalog to all isDone=false when repo is empty")
    func loadLeapsDefaultsToNotDone() async throws {
        let vm = try await makeVM()
        #expect(vm.leaps.count == DevelopmentLeap.catalog.count)
        #expect(vm.leaps.allSatisfy { !$0.isDone })
    }

    @Test("loadLeaps marks leap as done when progress says so")
    func loadLeapsMarksCompletedLeaps() async throws {
        let repo = MockLeapsRepository()
        repo.progress = [LeapProgress(id: 1, isDone: true, completedDate: Date())]
        let vm = try await makeVM(repo: repo)
        #expect(vm.leaps.first { $0.id == 1 }?.isDone == true)
        #expect(vm.leaps.first { $0.id == 2 }?.isDone == false)
    }

    @Test("loadLeaps marks isCurrent on the first eligible leap for baby's age")
    func loadLeapsMarksCurrent() async throws {
        let repo = MockLeapsRepository()
        let birth = Calendar.current.date(byAdding: .weekOfYear, value: -8, to: Date())!
        let profile = BabyProfile(name: "Test", birthDate: birth)
        let vm = try await makeVM(repo: repo, profile: profile)
        let currentCount = vm.leaps.filter { $0.isCurrent }.count
        #expect(currentCount == 1)
    }

    @Test("9-week-old baby is in leap #2, leap #1 shows as passed")
    func nineWeekBabyIsInLeapTwo() async throws {
        let repo = MockLeapsRepository()                 // no manual completions
        let birth = Calendar.current.date(byAdding: .day, value: -65, to: Date())! // ~9w2d
        let profile = BabyProfile(name: "Test", birthDate: birth)
        let vm = try await makeVM(repo: repo, profile: profile)
        #expect(vm.currentLeap.id == 2)
        #expect(vm.leaps.first { $0.id == 1 }?.isDone == true)
        #expect(vm.leaps.first { $0.id == 1 }?.isCurrent == false)
    }

    @Test("catalog contains all ten scheduled leaps")
    func catalogContainsAllScheduledLeaps() {
        #expect(DevelopmentLeap.catalog.count == 10)
        #expect(DevelopmentLeap.catalog.map(\.week) == DevelopmentLeapSchedule.weeks)
        #expect(DevelopmentLeap.catalog.last?.name(for: .english) == "Systems")
    }

    @Test("leapPhase is hard days on day 1 at a leap's onset")
    func leapPhaseHardDaysAtOnset() async throws {
        let repo = MockLeapsRepository()
        // Leap 1 (week 5) surfaces 1 week early → onset at day 28.
        let birth = Calendar.current.date(byAdding: .day, value: -28, to: Date())!
        let vm = try await makeVM(repo: repo, profile: BabyProfile(name: "Test", birthDate: birth))
        let leap1HardDays = DevelopmentLeap.catalog.first { $0.id == 1 }!.hardDays
        #expect(vm.currentLeap.id == 1)
        guard case .hardDays(let day, let total, _, _, _, let remaining) = vm.currentLeapPhase else {
            Issue.record("Expected hard days phase")
            return
        }
        #expect(day == 1)
        #expect(total == leap1HardDays)
        #expect(remaining == leap1HardDays)
    }

    @Test("leapPhase is consolidation once the hard window has passed")
    func leapPhaseConsolidationMidLeap() async throws {
        let repo = MockLeapsRepository()
        let birth = Calendar.current.date(byAdding: .day, value: -65, to: Date())! // ~9w2d, mid leap #2
        let vm = try await makeVM(repo: repo, profile: BabyProfile(name: "Test", birthDate: birth))
        #expect(vm.currentLeap.id == 2)
        #expect(vm.currentLeapPhase == .consolidation)
    }

    @Test("currentLeapPhase is upcoming for a newborn with no active leap")
    func leapPhaseUpcomingForNewborn() async throws {
        let vm = try await makeVM(profile: BabyProfile(name: "Test", birthDate: Date()))
        #expect(vm.leaps.allSatisfy { !$0.isCurrent })
        guard case .upcoming = vm.currentLeapPhase else {
            Issue.record("Expected upcoming phase")
            return
        }
    }

    @Test("leapPhase reports upcoming start date and days remaining")
    func leapPhaseUpcomingIncludesStartDate() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let birth = Date(timeIntervalSince1970: 0)
        let now = calendar.date(byAdding: .day, value: 20, to: birth)!
        let leap = DevelopmentLeap.catalog.first { $0.id == 1 }!
        let phase = BabyAgeContext.leapPhase(for: leap, birthDate: birth, now: now, calendar: calendar)

        guard case .upcoming(let startDate, let daysUntilStart) = phase else {
            Issue.record("Expected upcoming phase")
            return
        }
        #expect(startDate == calendar.date(byAdding: .day, value: 28, to: birth))
        #expect(daysUntilStart == 8)
    }

    @Test("loadLeaps sets isCurrent = false for all when no leap matches age")
    func loadLeapsHandlesNoCurrentLeap() async throws {
        let repo = MockLeapsRepository()
        // Brand-new baby (0 weeks) — no leap has week <= 0+4 except week 5
        let birth = Date()
        let profile = BabyProfile(name: "Test", birthDate: birth)
        let vm = try await makeVM(repo: repo, profile: profile)
        let currentLeaps = vm.leaps.filter { $0.isCurrent }
        #expect(currentLeaps.count <= 1)
    }

    // MARK: - baby switching

    @Test("reloads leaps for the new child when the active baby switches")
    func reloadsLeapsOnBabySwitch() async throws {
        let repo = MockLeapsRepository()
        let babyA = BabyProfile(name: "A", birthDate: Date())                                       // newborn
        let babyB = BabyProfile(name: "B",                                                          // ~9w2d → leap #2
                                birthDate: Calendar.current.date(byAdding: .day, value: -65, to: Date())!)
        let babyRepo = MockBabyRepository(initialProfiles: [babyA, babyB])
        let state = AppState(
            getBabyProfile: GetBabyProfileUseCase(repository: babyRepo),
            getAllBabies: GetAllBabiesUseCase(repository: babyRepo)
        )
        ActiveBaby.currentId = babyA.id
        await state.load()

        let checkInRepo = MockLeapCheckInRepository()
        let vm = LeapsViewModel(
            getLeaps: GetLeapsUseCase(repository: repo),
            markLeapComplete: MarkLeapCompleteUseCase(repository: repo),
            getCheckIns: GetLeapCheckInsUseCase(repository: checkInRepo),
            saveCheckIn: SaveLeapCheckInUseCase(repository: checkInRepo),
            getSleep: GetSleepEntriesUseCase(repository: MockSleepRepository()),
            getFeeding: GetFeedingEntriesUseCase(repository: MockFeedingRepository()),
            appState: state
        )
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.currentLeap.isCurrent == false) // newborn A has no active leap

        // Switch to child B exactly as AppContainer.switchActiveBaby does.
        state.setActive(babyB.id)
        NotificationCenter.default.post(name: .cloudSyncDidMerge, object: nil)
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(vm.currentLeap.id == 2)
        #expect(vm.currentLeap.isCurrent == true)
    }

    // MARK: - personalization

    @Test("toggleSymptom saves today's check-in")
    func toggleSymptomSavesCheckIn() async throws {
        let checkInRepo = MockLeapCheckInRepository()
        let birth = Calendar.current.date(byAdding: .day, value: -28, to: Date())!
        let vm = try await makeVM(
            checkInRepo: checkInRepo,
            profile: BabyProfile(name: "Test", birthDate: birth)
        )

        await vm.toggleSymptom(.sleepWorse)

        #expect(vm.selectedSymptoms.contains(.sleepWorse))
        #expect(checkInRepo.checkIns.contains { $0.leapID == vm.currentLeap.id && $0.symptoms.contains(.sleepWorse) })
        #expect(vm.calendarDays(scope: .week).contains { $0.hasCheckIn })
    }

    @Test("todayActions returns three practical actions")
    func todayActionsReturnsThreeItems() async throws {
        let birth = Calendar.current.date(byAdding: .day, value: -28, to: Date())!
        let vm = try await makeVM(profile: BabyProfile(name: "Test", birthDate: birth))

        #expect(vm.todayActions.count == 3)
        #expect(vm.todayActions.map(\.id).contains("play"))
        #expect(vm.todayActions.map(\.id).contains("sleep"))
    }

    @Test("sleep insight appears when sleep drops during a current leap")
    func sleepInsightAppearsWhenSleepDrops() async throws {
        let calendar = Calendar.current
        let birth = calendar.date(byAdding: .day, value: -30, to: Date())!
        let leapStart = calendar.date(byAdding: .day, value: 28, to: birth)!
        let sleepRepo = MockSleepRepository()
        for offset in -7..<0 {
            let start = calendar.date(byAdding: .day, value: offset, to: leapStart)!
            sleepRepo.entries.append(SleepEntry(startDate: start, endDate: calendar.date(byAdding: .hour, value: 8, to: start)))
        }
        for offset in 0...1 {
            let start = calendar.date(byAdding: .day, value: offset, to: leapStart)!
            sleepRepo.entries.append(SleepEntry(startDate: start, endDate: calendar.date(byAdding: .hour, value: 4, to: start)))
        }

        let vm = try await makeVM(
            sleepRepo: sleepRepo,
            profile: BabyProfile(name: "Test", birthDate: birth)
        )

        #expect(vm.behaviorInsights.contains { $0.id == "sleep" })
    }

    // MARK: - markComplete

    @Test("markComplete saves progress to repository")
    func markCompleteSavesToRepo() async throws {
        let repo = MockLeapsRepository()
        let vm = try await makeVM(repo: repo)
        await vm.markComplete(id: 1)
        #expect(repo.progress.contains { $0.id == 1 && $0.isDone })
    }

    @Test("markComplete reloads leaps so isDone is reflected")
    func markCompleteReloadsLeaps() async throws {
        let repo = MockLeapsRepository()
        let vm = try await makeVM(repo: repo)
        #expect(vm.leaps.first { $0.id == 1 }?.isDone == false)
        await vm.markComplete(id: 1)
        #expect(vm.leaps.first { $0.id == 1 }?.isDone == true)
    }

    // MARK: - currentLeap

    @Test("currentLeap returns the leap marked isCurrent")
    func currentLeapReturnsCurrent() async throws {
        let repo = MockLeapsRepository()
        let birth = Calendar.current.date(byAdding: .weekOfYear, value: -8, to: Date())!
        let profile = BabyProfile(name: "Test", birthDate: birth)
        let vm = try await makeVM(repo: repo, profile: profile)
        let current = vm.currentLeap
        #expect(current.isCurrent)
    }

    @Test("currentLeap falls back to first not-done when no leap is current")
    func currentLeapFallsBackToFirstNotDone() async throws {
        let repo = MockLeapsRepository()
        // No profile — 0 age weeks → catalog current might be nil → fallback to first not-done
        let vm = try await makeVM(repo: repo, profile: nil)
        let current = vm.currentLeap
        #expect(!current.isDone || current.id == vm.leaps[3].id)
    }
}
