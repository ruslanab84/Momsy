import FirebaseAppCheck
import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
final class FamilyPremiumService {
    private static let endpoint = URL(string: "https://us-central1-momsy-cf74a.cloudfunctions.net/syncSubscriptionEntitlement")!

    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
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
            .addSnapshotListener { snapshot, error in
                let isPremium = error == nil && Self.isActive(snapshot?.data())
                Task { @MainActor in onChange(isPremium) }
            }
    }

    func synchronize(transactionJWS: String) async throws {
        guard FirebaseBootstrapper.isConfigured,
              CloudSyncConsent.isGranted(),
              let user = Auth.auth().currentUser
        else { return }

        let idToken = try await user.getIDToken()
        let appCheckToken = try await AppCheck.appCheck().token(forcingRefresh: false).token
        var request = URLRequest(url: Self.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue(appCheckToken, forHTTPHeaderField: "X-Firebase-AppCheck")
        request.httpBody = try JSONEncoder().encode(["signedTransaction": transactionJWS])

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else { throw FamilyPremiumError.synchronizationFailed }
    }

    private static func isActive(_ data: [String: Any]?, now: Date = Date()) -> Bool {
        guard let entitlement = data?["premiumEntitlement"] as? [String: Any],
              let expiresAt = (entitlement["expiresAt"] as? Timestamp)?.dateValue()
        else { return false }
        return expiresAt > now && entitlement["revokedAt"] == nil
    }
}

private enum FamilyPremiumError: LocalizedError {
    case synchronizationFailed

    var errorDescription: String? {
        "Could not confirm your subscription with Momsy. Please try again."
    }
}
