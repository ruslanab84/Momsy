import UIKit
@preconcurrency import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

final class FirebasePhotoStorageService: PhotoStorageService, @unchecked Sendable {
    private let cache = NSCache<NSString, UIImage>()

    init(cacheCountLimit: Int = 100) {
        cache.countLimit = cacheCountLimit
    }

    func saveWithProgress(_ image: UIImage, forID id: UUID) -> AsyncThrowingStream<PhotoUploadEvent, Error> {
        AsyncThrowingStream { continuation in
            guard let data = image.jpegData(compressionQuality: 0.85) else {
                continuation.finish(throwing: PhotoStorageError.encodingFailed)
                return
            }
            // Resolving the uid is async (it may sign in anonymously first), so the
            // upload is kicked off from a Task. onTermination cancels the uid-resolve
            // work until the real upload handle exists, then the upload itself.
            let work = Task {
                let uid: String
                let familyId: String
                do {
                    uid = try await self.resolveUID()
                    familyId = try await self.resolveFamilyID(for: uid)
                } catch {
                    continuation.finish(throwing: error)
                    return
                }
                let path = "families/\(familyId)/photos/\(id.uuidString).jpg"
                let ref = Storage.storage().reference().child(path)
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"

                let task = ref.putData(data, metadata: metadata) { _, error in
                    if let error {
                        continuation.finish(throwing: error)
                    } else {
                        continuation.yield(.completed(path))
                        continuation.finish()
                    }
                }

                task.observe(.progress) { snapshot in
                    guard let progress = snapshot.progress, progress.totalUnitCount > 0 else { return }
                    let fraction = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                    continuation.yield(.progress(fraction))
                }

                continuation.onTermination = { _ in task.cancel() }
            }

            continuation.onTermination = { _ in work.cancel() }
        }
    }

    /// Returns the current Firebase uid, signing in anonymously on demand.
    /// Never falls back to a shared literal: an unauthenticated upload would pool
    /// every user's photos under `users/anonymous/`, with zero per-user isolation.
    private func resolveUID() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }
        return try await Auth.auth().signInAnonymously().user.uid
    }

    private func resolveFamilyID(for uid: String) async throws -> String {
        if let cached = await MainActor.run(body: { self.cachedFamilyID(for: uid) }) {
            return cached
        }

        let doc = try await Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument(source: .server)
        guard let familyId = doc.data()?["familyId"] as? String, !familyId.isEmpty else {
            throw PhotoStorageError.familyUnavailable
        }
        return familyId
    }

    @MainActor
    private func cachedFamilyID(for uid: String) -> String? {
        if let familyId = FamilyManager.shared.familyId, !familyId.isEmpty {
            return familyId
        }

        guard let cached = UserDefaults.standard.string(forKey: kFamilyIdDefaultsKey),
              !cached.isEmpty else {
            return nil
        }

        let ownerUID = UserDefaults.standard.string(forKey: kFamilyOwnerUidDefaultsKey)
        guard ownerUID == nil || ownerUID == uid else {
            return nil
        }
        return cached
    }

    func save(_ image: UIImage, forID id: UUID) async throws -> String {
        for try await event in saveWithProgress(image, forID: id) {
            if case .completed(let path) = event { return path }
        }
        throw PhotoStorageError.uploadFailed
    }

    func load(atPath path: String) async -> UIImage? {
        let key = path as NSString
        if let cached = cache.object(forKey: key) { return cached }

        let image: UIImage?
        if path.hasPrefix("/") {
            image = UIImage(contentsOfFile: path)
        } else {
            guard let data = try? await Storage.storage().reference().child(path).data(maxSize: 10 * 1024 * 1024) else { return nil }
            image = UIImage(data: data)
        }

        if let image { cache.setObject(image, forKey: key) }
        return image
    }

    func delete(atPath path: String) async throws {
        try await Storage.storage().reference().child(path).delete()
    }

    func deleteAll() async throws {
        // No signed-in user ⇒ this device owns no isolated bucket to clear. Never
        // reach into the shared `users/anonymous/` path — it isn't ours to delete.
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // Legacy cleanup only. New photos live under `families/{familyId}/photos`
        // because they are shared family assets and must remain available to co-parents.
        let folder = Storage.storage().reference().child("users/\(uid)/diary")
        let listing = try await folder.listAll()
        for item in listing.items {
            try await item.delete()
        }
        cache.removeAllObjects()
    }
}
