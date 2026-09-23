import FirebaseAppCheck
import FirebaseAuth
import FirebaseFirestore
import Foundation
import os

@MainActor
protocol FamilyPremiumServicing: AnyObject {
    var currentUID: String? { get }
    var currentContext: SubscriptionSyncContext? { get }
    func observe(familyId: String?, onChange: @escaping @MainActor (Bool) -> Void)
    func stopObserving()
    /// Recomputes access from the last snapshot with the current time. Expiry does not
    /// change the family document, so no snapshot ever announces it.
    func reevaluate()
    func synchronize(_ pending: PendingSubscriptionSync) async throws
}

struct FamilyDocumentSnapshot {
    let data: [String: Any]?
    let isFromCache: Bool
}

/// The Firestore seam of `FamilyPremiumService`, so its expiry and cache rules are testable.
@MainActor
protocol FamilyDocumentListening {
    /// Returns nil when the family document cannot be observed (Firebase unconfigured or
    /// Cloud Sync declined); otherwise a closure that removes the listener.
    func listen(
        familyId: String,
        onEvent: @escaping @MainActor (Result<FamilyDocumentSnapshot, Error>) -> Void
    ) -> (() -> Void)?
}

struct FirestoreFamilyDocumentListener: FamilyDocumentListening {
    func listen(
        familyId: String,
        onEvent: @escaping @MainActor (Result<FamilyDocumentSnapshot, Error>) -> Void
    ) -> (() -> Void)? {
        guard FirebaseBootstrapper.isConfigured, CloudSyncConsent.isGranted() else { return nil }
        let registration = Firestore.firestore().collection("families").document(familyId)
            .addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
                let event: Result<FamilyDocumentSnapshot, Error>
                if let error {
                    event = .failure(error)
                } else if let snapshot {
                    event = .success(FamilyDocumentSnapshot(
                        data: snapshot.data(),
                        isFromCache: snapshot.metadata.isFromCache
                    ))
                } else {
                    return
                }
                Task { @MainActor in onEvent(event) }
            }
        return { registration.remove() }
    }
}

@MainActor
final class FamilyPremiumService: FamilyPremiumServicing {
    private static let endpoint = URL(string: "https://us-central1-momsy-cf74a.cloudfunctions.net/syncSubscriptionEntitlement")!

    /// `nonisolated` because the Firestore snapshot callback is not MainActor-isolated. The
    /// class is, and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` would otherwise isolate this
    /// static too — fine under today's minimal checking, a hard error once strict concurrency
    /// is turned on. `Logger` is `Sendable`. Matches how `resolvedAccess` is already declared.
    private nonisolated static let log = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "RuslanAbd.Momsy",
        category: "subscription"
    )

    private let documentListener: any FamilyDocumentListening
    private let now: @Sendable () -> Date
    private let sleep: @Sendable (Duration) async throws -> Void
    private let cacheGrace: Duration
    private var removeListener: (() -> Void)?
    private var lastData: [String: Any]?
    private var hasServerSnapshot = false
    private var onChange: (@MainActor (Bool) -> Void)?
    private var expiryTask: Task<Void, Never>?
    private var cacheGraceTask: Task<Void, Never>?

    init(
        documentListener: (any FamilyDocumentListening)? = nil,
        now: @escaping @Sendable () -> Date = Date.init,
        sleep: @escaping @Sendable (Duration) async throws -> Void = { try await Task.sleep(for: $0) },
        cacheGrace: Duration = .seconds(5)
    ) {
        self.documentListener = documentListener ?? FirestoreFamilyDocumentListener()
        self.now = now
        self.sleep = sleep
        self.cacheGrace = cacheGrace
    }

    deinit {
        removeListener?()
        expiryTask?.cancel()
        cacheGraceTask?.cancel()
    }

    var currentUID: String? {
        guard FirebaseBootstrapper.isConfigured else { return nil }
        return Auth.auth().currentUser?.uid
    }

    var currentContext: SubscriptionSyncContext? {
        guard FirebaseBootstrapper.isConfigured,
              CloudSyncConsent.isGranted(),
              let uid = Auth.auth().currentUser?.uid,
              let familyID = FamilyManager.shared.familyId
        else { return nil }
        return SubscriptionSyncContext(uid: uid, familyID: familyID)
    }

    func observe(
        familyId: String?,
        onChange: @escaping @MainActor (Bool) -> Void
    ) {
        stopObserving()

        guard let familyId,
              let remove = documentListener.listen(familyId: familyId, onEvent: { [weak self] event in
                  self?.handle(event)
              })
        else {
            onChange(false)
            return
        }
        removeListener = remove
        self.onChange = onChange

        // Offline, a cache-only snapshot without an active entitlement proves nothing and is
        // held back — but a server snapshot may never come, which used to keep the splash up
        // forever. After the grace period the missing server answer counts as "no family
        // premium"; the personal entitlement resolves independently.
        let sleep = sleep
        let cacheGrace = cacheGrace
        cacheGraceTask = Task { [weak self] in
            do { try await sleep(cacheGrace) } catch { return }
            guard !Task.isCancelled, let self, !self.hasServerSnapshot,
                  !Self.isActive(self.lastData, now: self.now())
            else { return }
            self.onChange?(false)
        }
    }

    func stopObserving() {
        removeListener?()
        removeListener = nil
        expiryTask?.cancel()
        expiryTask = nil
        cacheGraceTask?.cancel()
        cacheGraceTask = nil
        lastData = nil
        hasServerSnapshot = false
        onChange = nil
    }

    func reevaluate() {
        emit()
    }

    private func handle(_ event: Result<FamilyDocumentSnapshot, Error>) {
        switch event {
        case .success(let snapshot):
            lastData = snapshot.data
            if !snapshot.isFromCache { hasServerSnapshot = true }
        case .failure(let error):
            // A permanently failing listener — denied rules, revoked membership — used to
            // return silently and leave the caller resolving forever, which blanks the whole
            // app behind the splash. Report "no family premium" instead: the personal
            // entitlement resolves independently and still grants access on its own. The
            // stale data is dropped so a later `reevaluate()` cannot resurrect it.
            Self.log.error(
                "Family entitlement listener failed: \(error.localizedDescription, privacy: .public)"
            )
            lastData = nil
            hasServerSnapshot = true
        }
        emit()
    }

    private func emit() {
        guard let onChange,
              let isPremium = Self.resolvedAccess(
                lastData,
                isFromCache: !hasServerSnapshot,
                now: now()
              )
        else { return }
        if isPremium {
            scheduleExpiry(at: Self.expiresAt(lastData))
        } else {
            expiryTask?.cancel()
            expiryTask = nil
        }
        onChange(isPremium)
    }

    /// Re-emits one second after `expiresAt`: the Cloud Function leaves `active = true` with a
    /// past `expiresAt`, so without this timer a foregrounded app keeps Premium indefinitely.
    private func scheduleExpiry(at expiresAt: Date?) {
        expiryTask?.cancel()
        expiryTask = nil
        guard let expiresAt else { return }
        let delay = max(0, expiresAt.timeIntervalSince(now())) + 1
        let sleep = sleep
        expiryTask = Task { [weak self] in
            do { try await sleep(.seconds(delay)) } catch { return }
            guard !Task.isCancelled else { return }
            self?.emit()
        }
    }

    func synchronize(_ pending: PendingSubscriptionSync) async throws {
        guard FirebaseBootstrapper.isConfigured,
              CloudSyncConsent.isGranted(),
              let user = Auth.auth().currentUser
        else {
            throw FamilyPremiumSyncError(
                code: "context_unavailable",
                isRetryable: true
            )
        }

        let idToken = try await user.getIDToken()
        let appCheckToken = try await AppCheck.appCheck().token(forcingRefresh: false).token
        var request = URLRequest(url: Self.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue(appCheckToken, forHTTPHeaderField: "X-Firebase-AppCheck")
        request.httpBody = try JSONEncoder().encode([
            "signedTransaction": pending.signedTransaction,
            "expectedUid": pending.uid,
            "expectedFamilyId": pending.familyID,
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FamilyPremiumSyncError(code: "invalid_response", isRetryable: true)
        }
        guard !(200...299).contains(httpResponse.statusCode) else { return }

        let payload = try? JSONDecoder().decode(FamilyPremiumErrorPayload.self, from: data)
        let code = payload?.code ?? "http_\(httpResponse.statusCode)"
        let retryable = Self.isRetryable(
            statusCode: httpResponse.statusCode,
            code: code,
            serverValue: payload?.retryable
        )
        throw FamilyPremiumSyncError(code: code, isRetryable: retryable)
    }

    nonisolated static func isRetryable(
        statusCode: Int,
        code: String,
        serverValue: Bool?
    ) -> Bool {
        if let serverValue { return serverValue }
        return statusCode == 401
            || statusCode == 408
            || statusCode == 429
            || statusCode >= 500
            || (statusCode == 409 && ["no_family", "not_a_member"].contains(code))
    }

    nonisolated static func isActive(_ data: [String: Any]?, now: Date = Date()) -> Bool {
        guard let entitlement = data?["premiumEntitlement"] as? [String: Any],
              entitlement["active"] as? Bool == true,
              let originalTransactionID = entitlement["originalTransactionId"] as? String,
              !originalTransactionID.isEmpty,
              let productID = entitlement["productId"] as? String,
              ProductID.all.contains(productID),
              let expiresAt = expiresAt(data)
        else { return false }
        guard expiresAt > now else { return false }
        switch entitlement["revokedAt"] {
        case nil, is NSNull: return true
        default: return false
        }
    }

    nonisolated static func expiresAt(_ data: [String: Any]?) -> Date? {
        let entitlement = data?["premiumEntitlement"] as? [String: Any]
        return (entitlement?["expiresAt"] as? Timestamp)?.dateValue()
    }

    /// nil means "unknown yet": a cache-only snapshot without an active entitlement may just
    /// be stale. An `expiresAt` in the past is final regardless of source — an expired
    /// timestamp cannot become valid again without a server write.
    nonisolated static func resolvedAccess(
        _ data: [String: Any]?,
        isFromCache: Bool,
        now: Date = Date()
    ) -> Bool? {
        if isActive(data, now: now) { return true }
        if let expiresAt = expiresAt(data), expiresAt <= now { return false }
        return isFromCache ? nil : false
    }
}

private struct FamilyPremiumErrorPayload: Decodable {
    let code: String?
    let retryable: Bool?
}

struct FamilyPremiumSyncError: Error {
    let code: String
    let isRetryable: Bool
}
