import CryptoKit
import Foundation

nonisolated struct SubscriptionSyncContext: Equatable {
    let uid: String
    let familyID: String
}

nonisolated struct PendingSubscriptionSync: Codable, Equatable {
    let uid: String
    let familyID: String
    let originalTransactionID: String
    let signedTransaction: String

    func matches(_ context: SubscriptionSyncContext) -> Bool {
        uid == context.uid && familyID == context.familyID
    }

    var fingerprint: String {
        SHA256.hash(data: Data(signedTransaction.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

nonisolated struct PendingSubscriptionSyncStore {
    static let storageKey = "pending_subscription_sync_v1"
    static let successStorageKey = "successful_subscription_sync_v1"

    private struct Success: Codable, Equatable {
        let uid: String
        let familyID: String
        let originalTransactionID: String
        let fingerprint: String
        let synchronizedAt: Date
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> PendingSubscriptionSync? {
        guard let data = defaults.data(forKey: Self.storageKey) else { return nil }
        return try? JSONDecoder().decode(PendingSubscriptionSync.self, from: data)
    }

    func save(_ pending: PendingSubscriptionSync) {
        guard !wasSuccessfullySynchronized(pending) else { return }
        guard let data = try? JSONEncoder().encode(pending) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }

    func markSuccessful(_ pending: PendingSubscriptionSync, now: Date = Date()) {
        let success = Success(
            uid: pending.uid,
            familyID: pending.familyID,
            originalTransactionID: pending.originalTransactionID,
            fingerprint: pending.fingerprint,
            synchronizedAt: now
        )
        guard let data = try? JSONEncoder().encode(success) else { return }
        defaults.set(data, forKey: Self.successStorageKey)
    }

    func wasSuccessfullySynchronized(_ pending: PendingSubscriptionSync) -> Bool {
        guard let data = defaults.data(forKey: Self.successStorageKey),
              let success = try? JSONDecoder().decode(Success.self, from: data)
        else { return false }
        return success.uid == pending.uid
            && success.familyID == pending.familyID
            && success.originalTransactionID == pending.originalTransactionID
            && success.fingerprint == pending.fingerprint
    }

    func clearPending() {
        defaults.removeObject(forKey: Self.storageKey)
    }

    func clearAll() {
        clearPending()
        defaults.removeObject(forKey: Self.successStorageKey)
    }
}

@MainActor
final class SubscriptionSyncQueue {
    private let store: PendingSubscriptionSyncStore
    private let currentContext: () -> SubscriptionSyncContext?
    private let synchronize: (PendingSubscriptionSync) async throws -> Void
    private let retryDelays: [Duration]
    private let sleep: (Duration) async -> Void
    private var flushTask: Task<Void, Never>?
    private var retryTask: Task<Void, Never>?
    /// Readable by tests; only this type mutates it.
    private(set) var retryAttempt = 0
    private var isFlushing = false
    private var needsFlush = false

    init(
        store: PendingSubscriptionSyncStore = PendingSubscriptionSyncStore(),
        currentContext: @escaping () -> SubscriptionSyncContext?,
        synchronize: @escaping (PendingSubscriptionSync) async throws -> Void,
        retryDelays: [Duration] = [.seconds(2), .seconds(10), .seconds(60)],
        sleep: @escaping (Duration) async -> Void = { duration in
            try? await Task.sleep(for: duration)
        }
    ) {
        self.store = store
        self.currentContext = currentContext
        self.synchronize = synchronize
        self.retryDelays = retryDelays
        self.sleep = sleep
    }

    func persistAndFinish(
        _ pending: PendingSubscriptionSync,
        finish: () async -> Void
    ) async {
        store.save(pending)
        if flushTask != nil || isFlushing { needsFlush = true }
        await finish()
    }

    func enqueue(_ pending: PendingSubscriptionSync) {
        store.save(pending)
        if flushTask != nil || isFlushing { needsFlush = true }
    }

    func scheduleFlush() {
        guard flushTask == nil, !isFlushing else {
            needsFlush = true
            return
        }
        flushTask = Task { [weak self] in
            guard let self else { return }
            await self.flush()
            self.flushTask = nil
            if self.needsFlush {
                self.needsFlush = false
                self.scheduleFlush()
            }
        }
    }

    func flush() async {
        guard !isFlushing,
              let context = currentContext(),
              let pending = store.load()
        else { return }
        guard pending.matches(context) else {
            store.clearAll()
            return
        }

        isFlushing = true
        defer { isFlushing = false }
        do {
            try await synchronize(pending)
            guard currentContext() == context, store.load() == pending else { return }
            store.markSuccessful(pending)
            store.clearPending()
            retryAttempt = 0
            retryTask?.cancel()
            retryTask = nil
        } catch {
            guard currentContext() == context, store.load() == pending else { return }
            guard Self.shouldRetry(error) else {
                store.clearPending()
                retryAttempt = 0
                return
            }
            scheduleRetry()
        }
    }

    /// Drops a job that no longer belongs to the current account/family. Only the pending job
    /// goes: `clearAll()` here also erased the success marker, and because this runs from
    /// `observeCurrentFamily` on every cold start, the next `updatePersonalStatus` re-enqueued
    /// and re-POSTed an already-synchronized transaction — one Cloud Function invocation per
    /// launch per paying user. The marker is a 4-field exact match, so keeping a stale one is
    /// inert; family departure still wipes everything through `clear()`.
    func discardPendingIfScopeChanged(to context: SubscriptionSyncContext?) {
        guard let context, let pending = store.load() else { return }
        guard !pending.matches(context) else { return }
        store.clearPending()
    }

    func clear() {
        flushTask?.cancel()
        retryTask?.cancel()
        flushTask = nil
        retryTask = nil
        retryAttempt = 0
        needsFlush = false
        store.clearAll()
    }

    /// Restores the backoff budget when the app returns to the foreground. Without this the
    /// third consecutive failure retires the job for the rest of the process: `scheduleRetry`
    /// refuses to arm once `retryAttempt` reaches `retryDelays.count`, and nothing lowers it
    /// again except a success that can no longer be attempted.
    func resetRetryBudget() {
        retryAttempt = 0
    }

    private func scheduleRetry() {
        guard retryTask == nil, retryAttempt < retryDelays.count else { return }
        let delay = retryDelays[retryAttempt]
        retryAttempt += 1
        retryTask = Task { [weak self] in
            guard let self else { return }
            await self.sleep(delay)
            guard !Task.isCancelled else { return }
            self.retryTask = nil
            await self.flush()
            if self.needsFlush {
                self.needsFlush = false
                self.scheduleFlush()
            }
        }
    }

    private static func shouldRetry(_ error: Error) -> Bool {
        (error as? FamilyPremiumSyncError)?.isRetryable ?? true
    }
}
