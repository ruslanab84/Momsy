import Testing
import Foundation
@testable import Momsy

@Suite("LocalInviteService", .serialized)
@MainActor
struct LocalInviteServiceTests {

    @Test("the local fallback issues codes in the canonical format")
    func generatesCanonicalCode() async throws {
        let service = LocalInviteService()
        let code = try await service.issueInvite(role: .dad)
        #expect(InviteCodeFormat.isValid(code))
    }

    @Test("a cached code is reused while it is still valid")
    func reusesCachedCode() async throws {
        let service = LocalInviteService()
        let first = try await service.issueInvite(role: .nanny)
        #expect(service.currentCode() == first)
        #expect(service.currentRole() == .nanny)
    }

    @Test("the invite URL round-trips through the deeplink parser")
    func urlRoundTrips() async throws {
        let service = LocalInviteService()
        let code = try await service.issueInvite(role: .dad)
        let url = service.inviteURL(for: code)
        #expect(JoinDeeplink.normalize(rawCode: url) == code)
    }

    @Test("changing role issues a different code")
    func roleChangeRotatesCode() async throws {
        let service = LocalInviteService()
        let nannyCode = try await service.issueInvite(role: .nanny)
        let dadCode = try await service.issueInvite(role: .dad)

        #expect(dadCode != nannyCode)
        #expect(service.currentRole() == .dad)
    }
}

@Suite("Sharing invite role", .serialized)
@MainActor
struct SharingInviteRoleTests {
    final class InviteSpy: InviteServiceProtocol, @unchecked Sendable {
        var code = "MOMSY-A2B3-C4D5-E6F7"
        var role: FamilyRole = .nanny
        var preparedCount = 0
        var issuedRoles: [FamilyRole] = []
        var issueError: Error?

        func currentCode() -> String { code }
        func currentRole() -> FamilyRole { role }
        func inviteURL(for code: String) -> String { "momsy://join?code=\(code)" }
        func expiry() -> Date { Date().addingTimeInterval(3600) }

        func prepareInvite(defaultRole: FamilyRole) async throws -> String {
            preparedCount += 1
            return code
        }

        func issueInvite(role: FamilyRole) async throws -> String {
            issuedRoles.append(role)
            if let issueError { throw issueError }
            code = "MOMSY-H2J3-K4L5-M6N7"
            self.role = role
            return code
        }
    }

    struct RepositoryStub: FamilyRepository {
        func getMembers() async throws -> [StoredFamilyMember] {
            [StoredFamilyMember(
                name: "Parent",
                roleRaw: FamilyRole.mom.rawValue,
                isMe: true,
                uid: "parent"
            )]
        }

        func update(_ member: StoredFamilyMember) async throws { }
        func prepareForRosterManagement(currentMember: StoredFamilyMember) async throws { }
        func remove(_ member: StoredFamilyMember) async throws { }
    }

    final class AuthStub: JoinAuthProviding {
        var currentUID: String? = "parent"
        func requireAnonymousSignInIfNeeded() async throws { }
    }

    @Test("opening an existing nanny invite does not issue a dad code")
    func openingPreservesRole() async {
        let invite = InviteSpy()
        let viewModel = SharingViewModel(
            repo: RepositoryStub(),
            inviteService: invite,
            appState: makeAppState(),
            auth: AuthStub()
        )
        await viewModel.loadMembers()

        viewModel.presentInvite()
        await drainTasks { viewModel.showInvite }

        #expect(invite.preparedCount == 1)
        #expect(invite.issuedRoles.isEmpty)
        #expect(viewModel.inviteRole == .nanny)
    }

    @Test("changing role issues a new code")
    func changingRoleRotatesCode() async {
        let invite = InviteSpy()
        let viewModel = SharingViewModel(
            repo: RepositoryStub(),
            inviteService: invite,
            appState: makeAppState(),
            auth: AuthStub()
        )
        await viewModel.loadMembers()

        viewModel.updateInviteRole(.dad)
        await drainTasks { invite.issuedRoles == [.dad] }

        #expect(viewModel.inviteCode == "MOMSY-H2J3-K4L5-M6N7")
        #expect(viewModel.inviteRole == .dad)
    }

    @Test("failed role replacement closes the old invite without changing its role")
    func failedRoleChangeClosesInvite() async {
        let invite = InviteSpy()
        let viewModel = SharingViewModel(
            repo: RepositoryStub(),
            inviteService: invite,
            appState: makeAppState(),
            auth: AuthStub()
        )
        await viewModel.loadMembers()
        viewModel.presentInvite()
        await drainTasks { viewModel.showInvite }
        invite.issueError = FamilyError.invalidOrExpiredCode

        viewModel.updateInviteRole(.dad)
        await drainTasks { viewModel.saveError != nil }

        #expect(!viewModel.showInvite)
        #expect(viewModel.inviteRole == .nanny)
        #expect(viewModel.inviteCode == "MOMSY-A2B3-C4D5-E6F7")
    }

    private func drainTasks(until condition: @MainActor () -> Bool) async {
        for _ in 0..<100 {
            if condition() { return }
            await Task.yield()
        }
    }
}
