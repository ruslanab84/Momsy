import Testing
import AuthenticationServices
@testable import Momsy

@MainActor
private final class AuthMock: AccountAuthProviding {
    var googleResult: Result<Void, Error> = .success(())
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {}
    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) async throws {
        if case .failure(let e) = result { throw e }
    }
    func signInWithGoogle() async throws {
        if case .failure(let e) = googleResult { throw e }
    }
}

private struct DummyError: Error {}
private final class Flag { var value = false }

@MainActor
struct AccountAuthViewModelTests {

    @Test func googleSuccessSignsInAndRunsPostAction() async throws {
        let post = Flag()
        let vm = AccountAuthViewModel(auth: AuthMock()) { post.value = true }
        vm.signInWithGoogle()
        try await waitUntil { vm.didSignIn }
        #expect(post.value)
        #expect(vm.authError == nil)
        #expect(!vm.isSigningIn)
    }

    @Test func googleFailureSetsErrorAndDoesNotSignIn() async throws {
        let mock = AuthMock()
        mock.googleResult = .failure(DummyError())
        let post = Flag()
        let vm = AccountAuthViewModel(auth: mock) { post.value = true }
        vm.signInWithGoogle()
        try await waitUntil { vm.authError != nil }
        #expect(!vm.didSignIn)
        #expect(!post.value)
        #expect(!vm.isSigningIn)
    }

    @Test func appleCancelIsSilent() async throws {
        let vm = AccountAuthViewModel(auth: AuthMock()) {}
        vm.completeApple(.failure(ASAuthorizationError(.canceled)))
        try await Task.sleep(nanoseconds: 150_000_000)
        #expect(vm.authError == nil)
        #expect(!vm.isSigningIn)
        #expect(!vm.didSignIn)
    }

    @Test func reentrancyGuardBlocksSecondCall() async throws {
        let mock = AuthMock()
        let vm = AccountAuthViewModel(auth: mock) {}
        vm.signInWithGoogle()
        vm.signInWithGoogle()   // ignored while first is in flight
        try await waitUntil { vm.didSignIn }
        #expect(vm.authError == nil)
    }
}

@MainActor
private func waitUntil(timeoutNs: UInt64 = 2_000_000_000, _ cond: @escaping () -> Bool) async throws {
    let start = DispatchTime.now().uptimeNanoseconds
    while !cond() {
        if DispatchTime.now().uptimeNanoseconds - start > timeoutNs { throw DummyError() }
        try await Task.sleep(nanoseconds: 20_000_000)
    }
}
