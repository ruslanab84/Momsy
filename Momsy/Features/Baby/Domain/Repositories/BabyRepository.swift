import Foundation

enum BabyError: LocalizedError {
    case maxChildrenReached

    var errorDescription: String? {
        switch self {
        case .maxChildrenReached:
            return "You can add up to \(ActiveBaby.maxChildren) children."
        }
    }
}

protocol BabyRepository {
    /// The currently active child (or the only/first child as a fallback).
    func getProfile() async throws -> BabyProfile?
    /// Every child in the family roster, oldest first (child #1 first).
    func getAllProfiles() async throws -> [BabyProfile]
    /// Upsert keyed by `profile.id`. Throws `BabyError.maxChildrenReached` when
    /// inserting a new child would exceed `ActiveBaby.maxChildren`.
    func saveProfile(_ profile: BabyProfile) async throws
    func deleteProfile(id: UUID) async throws
}
