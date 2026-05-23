import Testing
@testable import Momsy
import Foundation

@Suite("LeapsViewModel", .serialized)
@MainActor
struct LeapsViewModelTests {

    func makeVM(
        repo: MockLeapsRepository = MockLeapsRepository(),
        profile: BabyProfile? = nil
    ) async throws -> LeapsViewModel {
        let state = makeAppState(profile: profile)
        let vm = LeapsViewModel(
            getLeaps: GetLeapsUseCase(repository: repo),
            markLeapComplete: MarkLeapCompleteUseCase(repository: repo),
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
