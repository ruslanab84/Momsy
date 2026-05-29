import Testing
@testable import Momsy
import Foundation

@Suite("OnboardingViewModel", .serialized)
@MainActor
struct OnboardingViewModelTests {

    func makeVM(
        onDone: @escaping () -> Void = {}
    ) -> (OnboardingViewModel, MockBabyRepository, MockAnalyticsService, MockPushNotificationService) {
        let repo      = MockBabyRepository()
        let analytics = MockAnalyticsService()
        let push      = MockPushNotificationService()
        let state     = makeAppState()
        let vm = OnboardingViewModel(
            saveBabyProfile: SaveBabyProfileUseCase(repository: repo),
            appState: state,
            authManager: AuthManager(),
            analytics: analytics,
            pushNotifications: push,
            onDone: onDone
        )
        return (vm, repo, analytics, push)
    }

    // MARK: - canContinue

    @Test("canContinue is true on non-profile steps regardless of name")
    func canContinueAlwaysTrueOnAgeStep() {
        let (vm, _, _, _) = makeVM()
        vm.step = .age
        vm.babyName = ""
        #expect(vm.canContinue)
    }

    @Test("canContinue is false on profile step when name is empty")
    func canContinueFalseWhenNameEmpty() {
        let (vm, _, _, _) = makeVM()
        vm.step = .profile
        vm.babyName = "   "
        #expect(!vm.canContinue)
    }

    @Test("canContinue is true on profile step when name is provided")
    func canContinueTrueWhenNameSet() {
        let (vm, _, _, _) = makeVM()
        vm.step = .profile
        vm.babyName = "Mia"
        #expect(vm.canContinue)
    }

    @Test("canContinue is true on role, auth, and ready steps")
    func canContinueTrueOnLaterSteps() {
        let (vm, _, _, _) = makeVM()
        for s in [OBStep.role, OBStep.auth, OBStep.ready] {
            vm.step = s
            #expect(vm.canContinue)
        }
    }

    // MARK: - advance

    @Test("advance() moves from age to profile")
    func advanceFromAgeToProfile() {
        let (vm, _, _, _) = makeVM()
        vm.step = .age
        vm.advance()
        #expect(vm.step == .profile)
    }

    @Test("advance() moves through all steps in order")
    func advanceFullFlow() {
        let (vm, _, _, _) = makeVM()
        vm.babyName = "Test"
        vm.step = .age
        vm.advance()
        #expect(vm.step == .profile)
        vm.advance()
        #expect(vm.step == .role)
        vm.advance()
        #expect(vm.step == .auth)
        vm.advance()
        #expect(vm.step == .ready)
    }

    @Test("advance() does nothing on profile step when name is empty")
    func advanceBlockedWhenNameEmpty() {
        let (vm, _, _, _) = makeVM()
        vm.step = .profile
        vm.babyName = ""
        vm.advance()
        #expect(vm.step == .profile)
    }

    @Test("advance() does nothing when already on last step")
    func advanceDoesNothingAtEnd() {
        let (vm, _, _, _) = makeVM()
        vm.step = .ready
        vm.advance()
        #expect(vm.step == .ready)
    }

    @Test("goBack() moves from profile to age")
    func goBackMovesToPreviousStep() {
        let (vm, _, _, _) = makeVM()
        vm.step = .profile
        vm.goBack()
        #expect(vm.step == .age)
    }

    @Test("goBack() does nothing when on first step")
    func goBackDoesNothingAtStart() {
        let (vm, _, _, _) = makeVM()
        vm.step = .age
        vm.goBack()
        #expect(vm.step == .age)
    }

    // MARK: - finish

    @Test("finish() calls onDone callback")
    func finishCallsOnDone() async throws {
        var called = false
        let (vm, _, _, _) = makeVM(onDone: { called = true })
        vm.babyName = "Leo"
        vm.finish()
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(called)
    }

    @Test("finish() saves baby profile to repository")
    func finishSavesProfile() async throws {
        var doneCalled = false
        let (vm, repo, _, _) = makeVM(onDone: { doneCalled = true })
        vm.babyName = "Emma"
        vm.finish()
        try await Task.sleep(nanoseconds: 100_000_000)
        let saved = try await repo.getProfile()
        #expect(saved?.name == "Emma")
    }

    @Test("finish() trims whitespace from baby name before saving")
    func finishTrimsName() async throws {
        let (vm, repo, _, _) = makeVM()
        vm.babyName = "  Mia  "
        vm.finish()
        try await Task.sleep(nanoseconds: 100_000_000)
        let saved = try await repo.getProfile()
        #expect(saved?.name == "Mia")
    }

    @Test("finish() tracks onboardingComplete analytics event")
    func finishTracksAnalytics() async throws {
        let (vm, _, analytics, _) = makeVM()
        vm.babyName = "Max"
        vm.finish()
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(analytics.events.count == 1)
    }

    @Test("finish() schedules morning diary push notification")
    func finishSchedulesPush() async throws {
        let (vm, _, _, push) = makeVM()
        vm.babyName = "Lena"
        vm.finish()
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(push.scheduledDiaryHour == 9)
    }
}
