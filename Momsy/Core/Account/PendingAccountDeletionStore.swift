import Foundation

/// Durable record that an account deletion was started but not yet *server-confirmed*.
///
/// Account deletion can look complete on-device while the cloud erase never reached the
/// backend — Firestore's write awaits resolve against the local persistent cache, and a
/// transient error, an offline device, or the session ending right after can leave the
/// server copy of `users/{uid}` alive. The next sign-in then re-resolves the family and
/// re-downloads the data ("ghost" babies reappearing after re-login).
///
/// The marker survives the local-data wipe (`AppContainer.eraseLocalData()` does not touch
/// this key) so launch recovery can finish the erase before any cloud data is downloaded.
protocol PendingAccountDeletionStore {
    /// Records that the given uid's account is mid-deletion.
    func markPending(uid: String)
    /// The uid of an in-flight deletion, or `nil` when none is pending.
    func loadPending() -> String?
    /// Clears the marker once the erase is server-confirmed.
    func clearPending()
}

struct UserDefaultsPendingAccountDeletionStore: PendingAccountDeletionStore {
    /// Deliberately NOT among the keys cleared by `AppContainer.eraseLocalData()`, so the
    /// marker outlives the device wipe and is still present on the next launch.
    private static let key = "pendingAccountDeletion_uid_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func markPending(uid: String) { defaults.set(uid, forKey: Self.key) }
    func loadPending() -> String? { defaults.string(forKey: Self.key) }
    func clearPending() { defaults.removeObject(forKey: Self.key) }
}

/// Records provider accounts that must start with a fresh family on the next sign-in.
///
/// This is intentionally separate from the pending-delete marker. A delete can be
/// "finished enough" for the UI to return to onboarding while the same Google/Apple
/// credential still maps to the same Firebase uid. If `users/{uid}.familyId` is still
/// present for any reason, blindly adopting it would re-download the old baby roster.
protocol SuppressedFamilyRestoreStore {
    func suppressRestore(for uid: String)
    func isRestoreSuppressed(for uid: String) -> Bool
    func clearSuppression(for uid: String)
}

struct UserDefaultsSuppressedFamilyRestoreStore: SuppressedFamilyRestoreStore {
    /// Deliberately survives `AppContainer.eraseLocalData()`; it is cleared only after
    /// a new clean family has been created for this uid.
    private static let key = "suppressedFamilyRestore_uids_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func suppressRestore(for uid: String) {
        var uids = Set(defaults.stringArray(forKey: Self.key) ?? [])
        uids.insert(uid)
        defaults.set(Array(uids), forKey: Self.key)
    }

    func isRestoreSuppressed(for uid: String) -> Bool {
        defaults.stringArray(forKey: Self.key)?.contains(uid) == true
    }

    func clearSuppression(for uid: String) {
        var uids = Set(defaults.stringArray(forKey: Self.key) ?? [])
        uids.remove(uid)
        if uids.isEmpty {
            defaults.removeObject(forKey: Self.key)
        } else {
            defaults.set(Array(uids), forKey: Self.key)
        }
    }
}
