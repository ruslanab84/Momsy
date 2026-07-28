import Testing
@testable import Momsy
import Foundation

@Suite("Cloud sync consent")
struct CloudSyncConsentTests {
    @Test("defaults to not determined and persists the user's choice")
    func persistsChoice() {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        #expect(CloudSyncConsent.status(defaults: defaults) == .notDetermined)
        CloudSyncConsent.set(.granted, defaults: defaults)
        #expect(CloudSyncConsent.isGranted(defaults: defaults))
        CloudSyncConsent.set(.denied, defaults: defaults)
        #expect(!CloudSyncConsent.isGranted(defaults: defaults))
    }
}

@Suite("OnboardingViewModel", .serialized)
@MainActor
struct OnboardingViewModelTests {

    final class MockInviteService: InviteServiceProtocol, @unchecked Sendable {
        var code = "MOMSY-TEST1"
        var preparedCount = 0
        var regeneratedCount = 0
        var updatedRoles: [FamilyRole] = []

        func currentCode() -> String { code }
        func inviteURL(for code: String) -> String { "momsy://join?code=\(code)" }
        func expiry() -> Date { Date().addingTimeInterval(86400) }
        func regenerate() -> String {
            code = "MOMSY-TEST2"
            return code
        }
        func prepareInvite() async throws -> String {
            preparedCount += 1
            return code
        }
        func regenerateAndSync() async throws -> String {
            regeneratedCount += 1
            return regenerate()
        }
        func updateInviteRole(code: String, role: FamilyRole) async throws {
            updatedRoles.append(role)
        }
    }

    final class JoinRecorder {
        var ensuredDisplayNames: [String] = []
        var ensuredRoles: [FamilyRole] = []
        var ensuredProfiles: [BabyProfile] = []
        var joinRequests: [(code: String, force: Bool)] = []
        var syncAfterJoinCount = 0
    }

    struct Harness {
        let vm: OnboardingViewModel
        let repo: MockBabyRepository
        let analytics: MockAnalyticsService
        let push: MockPushNotificationService
        let invite: MockInviteService
        let recorder: JoinRecorder
        let pendingStore: PendingFamilyInviteStore
        let pendingSetupStore: PendingOnboardingSetupStore
    }

    func makeHarness(
        pendingCode: String? = nil,
        cloudSyncEnabled: Bool = false,
        familySetupError: Error? = nil,
        setCloudSyncConsent: @escaping (CloudSyncConsent.Status) -> Void = { _ in },
        onDone: @escaping () -> Void = {}
    ) -> Harness {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        let pendingStore = PendingFamilyInviteStore(defaults: defaults)
        let pendingSetupStore = PendingOnboardingSetupStore(defaults: defaults)
        if let pendingCode {
            pendingStore.save(pendingCode)
        }

        let repo      = MockBabyRepository()
        let analytics = MockAnalyticsService()
        let push      = MockPushNotificationService()
        let state     = makeAppState()
        let invite    = MockInviteService()
        let recorder  = JoinRecorder()
        let vm = OnboardingViewModel(
            saveBabyProfile: SaveBabyProfileUseCase(repository: repo),
            appState: state,
            authManager: AuthManager(),
            inviteService: invite,
            pendingInviteStore: pendingStore,
            pendingSetupStore: pendingSetupStore,
            ensureFamilyReady: { displayName, role, profile in
                recorder.ensuredDisplayNames.append(displayName)
                recorder.ensuredRoles.append(role)
                recorder.ensuredProfiles.append(profile)
                if let familySetupError { throw familySetupError }
            },
            joinFamily: { code, force in
                recorder.joinRequests.append((code, force))
            },
            syncAfterJoiningFamily: {
                recorder.syncAfterJoinCount += 1
            },
            analytics: analytics,
            pushNotifications: push,
            initialCloudSyncEnabled: cloudSyncEnabled,
            setCloudSyncConsent: setCloudSyncConsent,
            onDone: onDone
        )
        return Harness(
            vm: vm,
            repo: repo,
            analytics: analytics,
            push: push,
            invite: invite,
            recorder: recorder,
            pendingStore: pendingStore,
            pendingSetupStore: pendingSetupStore
        )
    }

    func makeVM(
        onDone: @escaping () -> Void = {}
    ) -> (OnboardingViewModel, MockBabyRepository, MockAnalyticsService, MockPushNotificationService) {
        let harness = makeHarness(onDone: onDone)
        return (harness.vm, harness.repo, harness.analytics, harness.push)
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

    @Test("canContinue is true on ordinary later steps")
    func canContinueTrueOnLaterSteps() {
        let (vm, _, _, _) = makeVM()
        for s in [OBStep.role, OBStep.invite, OBStep.auth, OBStep.ready] {
            vm.step = s
            #expect(vm.canContinue)
        }
        vm.step = .privacy
        #expect(!vm.canContinue)
    }

    @Test("canContinue is false on join step without an invite code")
    func canContinueFalseOnJoinWithoutCode() {
        let (vm, _, _, _) = makeVM()
        vm.startJoinFlow()
        #expect(vm.step == .join)
        #expect(!vm.canContinue)
    }

    @Test("pending invite starts onboarding in join flow")
    func pendingInviteStartsJoinFlow() {
        let harness = makeHarness(pendingCode: "momsy://join?code=MOMSY-ABCD12")
        #expect(harness.vm.flow == .joinFamily)
        #expect(harness.vm.step == .join)
        #expect(harness.vm.pendingInviteCode == "MOMSY-ABCD12")
        #expect(harness.vm.steps == [.join, .privacy, .auth, .ready])
        #expect(harness.vm.canContinue)
    }

    @Test("join advance persists normalized invite for provider auth")
    func joinAdvancePersistsInviteForAuth() {
        let harness = makeHarness()
        harness.vm.startJoinFlow()
        harness.vm.pendingInviteCode = "momsy://join?code=momsy-abcd12"

        harness.vm.advance()

        #expect(harness.vm.step == .privacy)
        #expect(harness.vm.pendingInviteCode == "MOMSY-ABCD12")
        #expect(harness.pendingStore.load() == "MOMSY-ABCD12")
    }

    @Test("loadPendingInviteIfNeeded after advance does not bounce back to join step")
    func loadPendingInviteAfterAdvanceDoesNotResetStep() {
        let harness = makeHarness()
        harness.vm.startJoinFlow()
        harness.vm.pendingInviteCode = "momsy://join?code=momsy-abcd12"

        harness.vm.advance()
        #expect(harness.vm.step == .privacy)

        // Simulates the .pendingFamilyInviteDidChange notification fired by the
        // store write inside advance() -> persistPendingInviteForAuth().
        harness.vm.loadPendingInviteIfNeeded()

        #expect(harness.vm.step == .privacy)
    }

    @Test("automatic family setup waits for onboarding to finish")
    func automaticFamilySetupWaitsForOnboarding() {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!

        #expect(AuthManager.shouldDeferAutomaticFamilySetup(defaults: defaults))

        defaults.set(true, forKey: "onboardingDone")
        #expect(!AuthManager.shouldDeferAutomaticFamilySetup(defaults: defaults))
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
        #expect(vm.step == .privacy)
        vm.chooseCloudSync(true)
        #expect(vm.step == .invite)
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

    @Test("skipInvite() moves from invite to auth")
    func skipInviteMovesToAuth() {
        let (vm, _, _, _) = makeVM()
        vm.step = .invite
        vm.skipInvite()
        #expect(vm.step == .auth)
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

    @Test("skipAuth() is ignored in join flow")
    func skipAuthIgnoredInJoinFlow() {
        let harness = makeHarness(pendingCode: "MOMSY-JOIN1")
        harness.vm.step = .auth
        harness.vm.skipAuth()
        #expect(harness.vm.step == .auth)
    }

    // MARK: - invite

    @Test("prepareInvite() saves baby profile, syncs it, and prepares role invite")
    func prepareInviteSavesAndSyncsProfile() async throws {
        let harness = makeHarness(cloudSyncEnabled: true)
        harness.vm.babyName = "Mia"
        harness.vm.parentName = "Anna"
        harness.vm.selectedInviteRole = .nanny

        await harness.vm.prepareInvite()

        let saved = try await harness.repo.getProfile()
        #expect(saved?.name == "Mia")
        #expect(harness.recorder.ensuredProfiles.map(\.name) == ["Mia"])
        #expect(harness.invite.preparedCount == 1)
        #expect(harness.invite.updatedRoles == [.nanny])
        #expect(harness.vm.inviteCode == "MOMSY-TEST1")
        #expect(harness.vm.inviteURL == "momsy://join?code=MOMSY-TEST1")
        #expect(harness.recorder.ensuredDisplayNames == ["Anna"])
        #expect(harness.pendingSetupStore.load() == nil)
    }

    @Test("family setup receives every onboarding caregiver role")
    func familySetupReceivesSelectedRole() async {
        for role in FamilyRole.allCases {
            let harness = makeHarness(cloudSyncEnabled: true)
            harness.vm.babyName = "Mia"
            harness.vm.parentRole = role

            await harness.vm.prepareInvite()

            #expect(harness.recorder.ensuredRoles == [role])
        }
    }

    @Test("selected role and profile survive a transient family setup failure")
    func selectedSetupSurvivesSetupFailure() async {
        let harness = makeHarness(
            cloudSyncEnabled: true,
            familySetupError: FamilyError.noFamilyId
        )
        harness.vm.babyName = "Mia"
        harness.vm.parentRole = .dad

        await harness.vm.prepareInvite()

        #expect(harness.pendingSetupStore.load()?.role == .dad)
        #expect(harness.pendingSetupStore.load()?.profile.name == "Mia")
    }

    @Test("declining cloud sync skips cloud onboarding and keeps the profile local")
    func decliningCloudSyncKeepsProfileLocal() async throws {
        var consent: CloudSyncConsent.Status?
        var done = false
        let harness = makeHarness(
            setCloudSyncConsent: { consent = $0 },
            onDone: { done = true }
        )
        harness.vm.babyName = "Mia"
        harness.vm.step = .privacy

        harness.vm.chooseCloudSync(false)
        harness.vm.finish()
        try await Task.sleep(nanoseconds: 100_000_000)
        let saved = try await harness.repo.getProfile()

        #expect(consent == .denied)
        #expect(harness.vm.step == .ready)
        #expect(harness.recorder.ensuredDisplayNames.isEmpty)
        #expect(harness.recorder.ensuredProfiles.isEmpty)
        #expect(saved?.name == "Mia")
        #expect(done)
    }

    @Test("confirmJoinReplacingFamily() joins with force and advances to ready")
    func confirmJoinReplacingFamilyJoinsWithForce() async throws {
        let harness = makeHarness(pendingCode: "MOMSY-JOIN1")
        harness.vm.step = .auth

        harness.vm.confirmJoinReplacingFamily()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(harness.recorder.joinRequests.count == 1)
        #expect(harness.recorder.joinRequests.first?.code == "MOMSY-JOIN1")
        #expect(harness.recorder.joinRequests.first?.force == true)
        #expect(harness.recorder.syncAfterJoinCount == 1)
        #expect(harness.vm.step == .ready)
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

    @Test("finish() in join flow completes without creating a baby profile")
    func finishJoinFlowDoesNotCreateProfile() async throws {
        var called = false
        let harness = makeHarness(pendingCode: "MOMSY-JOIN1", onDone: { called = true })
        harness.vm.step = .ready

        harness.vm.finish()

        let saved = try await harness.repo.getProfile()
        #expect(called)
        #expect(saved == nil)
        #expect(harness.analytics.events.count == 1)
    }
}
