import Testing
import AuthenticationServices
import FirebaseAuth
@testable import Momsy

@MainActor
private final class AuthMock: AccountAuthProviding {
    var appleResult: Result<Void, Error> = .success(())
    var googleResult: Result<Void, Error> = .success(())
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {}
    func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) async throws {
        if case .failure(let e) = appleResult { throw e }
        if case .failure(let e) = result { throw e }
    }
    func signInWithGoogle() async throws {
        if case .failure(let e) = googleResult { throw e }
    }
}

private struct DummyError: Error {}
private final class Flag { var value = false }

private struct AuthSwitchCloudEraser: CloudAccountEraser {
    final class Calls: @unchecked Sendable {
        var events: [String] = []
        var stillPresent = false
    }

    let calls: Calls

    func deleteCloudData(uid: String) async throws {
        calls.events.append("cloudErase:\(uid)")
    }

    func isCloudDataPresent(uid: String) async throws -> Bool {
        calls.events.append("serverVerify:\(uid)")
        return calls.stillPresent
    }
}

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

    @Test func appleProviderConflictSetsExactErrorAndDoesNotSignIn() async throws {
        let mock = AuthMock()
        mock.appleResult = .failure(AuthError.providerAccountConflict)
        let post = Flag()
        let vm = AccountAuthViewModel(auth: mock) { post.value = true }

        vm.completeApple(.failure(DummyError()))
        try await waitUntil { vm.authError != nil }

        guard case AuthError.providerAccountConflict? = vm.authError as? AuthError else {
            Issue.record("Expected providerAccountConflict")
            return
        }
        #expect(!vm.didSignIn)
        #expect(!post.value)
        #expect(!vm.isSigningIn)
    }

    @Test func fallbackCredentialUsesUpdatedCredentialFromFirebaseError() {
        let original = EmailAuthProvider.credential(
            withEmail: "original@example.com",
            password: "password"
        )
        let updated = EmailAuthProvider.credential(
            withEmail: "updated@example.com",
            password: "password"
        )
        let error = NSError(
            domain: AuthErrorDomain,
            code: AuthErrorCode.credentialAlreadyInUse.rawValue,
            userInfo: [AuthErrorUserInfoUpdatedCredentialKey: updated]
        )

        let result = AuthManager.fallbackCredential(original: original, linkError: error)

        #expect(result === updated)
    }

    @Test func fallbackCredentialUsesOriginalWhenFirebaseProvidesNoReplacement() {
        let original = EmailAuthProvider.credential(
            withEmail: "original@example.com",
            password: "password"
        )
        let error = NSError(
            domain: AuthErrorDomain,
            code: AuthErrorCode.credentialAlreadyInUse.rawValue
        )

        let result = AuthManager.fallbackCredential(original: original, linkError: error)

        #expect(result === original)
    }

    @Test func anonymousAccountErasurePrecedesExistingAccountSignIn() async throws {
        let calls = AuthSwitchCloudEraser.Calls()

        let uid = try await AuthManager.switchFromAnonymousAccount(
            anonymousUid: "anonymous-uid",
            cloudEraser: AuthSwitchCloudEraser(calls: calls),
            deleteAuthUser: { calls.events.append("authDelete") },
            purgeLocalData: { calls.events.append("localPurge") },
            signIn: {
                calls.events.append("signIn")
                return "provider-uid"
            }
        )

        #expect(uid == "provider-uid")
        #expect(calls.events == [
            "cloudErase:anonymous-uid",
            "serverVerify:anonymous-uid",
            "authDelete",
            "localPurge",
            "signIn",
        ])
    }

    @Test func incompleteAnonymousErasurePreventsExistingAccountSignIn() async {
        let calls = AuthSwitchCloudEraser.Calls()
        calls.stillPresent = true

        await #expect {
            try await AuthManager.switchFromAnonymousAccount(
                anonymousUid: "anonymous-uid",
                cloudEraser: AuthSwitchCloudEraser(calls: calls),
                deleteAuthUser: { calls.events.append("authDelete") },
                purgeLocalData: { calls.events.append("localPurge") },
                signIn: { calls.events.append("signIn") }
            )
        } throws: { error in
            guard case AuthError.accountDeletionPending = error else { return false }
            return true
        }

        #expect(calls.events == [
            "cloudErase:anonymous-uid",
            "serverVerify:anonymous-uid",
        ])
    }

    @Test func anonymousAuthDeletionFailurePreventsExistingAccountSignIn() async {
        let calls = AuthSwitchCloudEraser.Calls()

        await #expect(throws: DummyError.self) {
            try await AuthManager.switchFromAnonymousAccount(
                anonymousUid: "anonymous-uid",
                cloudEraser: AuthSwitchCloudEraser(calls: calls),
                deleteAuthUser: {
                    calls.events.append("authDelete")
                    throw DummyError()
                },
                purgeLocalData: { calls.events.append("localPurge") },
                signIn: { calls.events.append("signIn") }
            )
        }

        #expect(calls.events == [
            "cloudErase:anonymous-uid",
            "serverVerify:anonymous-uid",
            "authDelete",
        ])
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
