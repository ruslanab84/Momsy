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
    func synchronize(_ pending: PendingSubscriptionSync) async throws
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

    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
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
        listener?.remove()
        listener = nil

        guard FirebaseBootstrapper.isConfigured,
              CloudSyncConsent.isGranted(),
              let familyId
        else {
            onChange(false)
            return
        }

        listener = Firestore.firestore().collection("families").document(familyId)
            .addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
                // A permanently failing listener — denied rules, revoked membership — used to
                // return silently and leave the caller resolving forever, which blanks the whole
                // app behind the splash. Report "no family premium" instead: the personal
                // entitlement resolves independently and still grants access on its own.
                if let error {
                    Self.log.error(
                        "Family entitlement listener failed: \(error.localizedDescription, privacy: .public)"
                    )
                    Task { @MainActor in onChange(false) }
                    return
                }
                guard let snapshot,
                      let isPremium = Self.resolvedAccess(
                        snapshot.data(),
                        isFromCache: snapshot.metadata.isFromCache
                      )
                else { return }
                Task { @MainActor in onChange(isPremium) }
            }
    }

    func stopObserving() {
        listener?.remove()
        listener = nil
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
              let expiresAt = (entitlement["expiresAt"] as? Timestamp)?.dateValue()
        else { return false }
        guard expiresAt > now else { return false }
        switch entitlement["revokedAt"] {
        case nil, is NSNull: return true
        default: return false
        }
    }

    nonisolated static func resolvedAccess(
        _ data: [String: Any]?,
        isFromCache: Bool,
        now: Date = Date()
    ) -> Bool? {
        let isPremium = isActive(data, now: now)
        if isPremium { return true }
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
