import Combine
import Foundation

@MainActor
final class PaywallActionHandler: ObservableObject {
    @Published private(set) var pendingInviteCode: String?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    var hasPendingInvite: Bool { pendingInviteCode != nil }

    private let pendingInviteStore: PendingFamilyInviteStore
    private let subscribe: @MainActor () async throws -> Bool
    private let joinFamily: @MainActor (String) async throws -> Void

    init(
        pendingInviteStore: PendingFamilyInviteStore,
        subscribe: @escaping @MainActor () async throws -> Bool,
        joinFamily: @escaping @MainActor (String) async throws -> Void
    ) {
        self.pendingInviteStore = pendingInviteStore
        self.subscribe = subscribe
        self.joinFamily = joinFamily
        pendingInviteCode = pendingInviteStore.load()
    }

    func refreshInviteContext() {
        pendingInviteCode = pendingInviteStore.load()
    }

    func perform() async -> Bool {
        guard !isLoading else { return false }
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            if let pendingInviteCode {
                try await joinFamily(pendingInviteCode)
                self.pendingInviteCode = nil
                pendingInviteStore.clear()
                return true
            }
            return try await subscribe()
        } catch {
            self.error = error
            return false
        }
    }
}
