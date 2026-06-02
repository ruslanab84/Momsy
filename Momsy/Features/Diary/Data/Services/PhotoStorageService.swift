import UIKit

enum PhotoUploadEvent: Sendable {
    case progress(Double)
    case completed(String)
}

enum PhotoStorageError: Error {
    case encodingFailed
    case uploadFailed
}

protocol PhotoStorageService: Sendable {
    func save(_ image: UIImage, forID id: UUID) async throws -> String
    func saveWithProgress(_ image: UIImage, forID id: UUID) -> AsyncThrowingStream<PhotoUploadEvent, Error>
    func load(atPath path: String) async -> UIImage?
    func delete(atPath path: String) async throws
    /// Removes every photo this user has stored. Used for GDPR account erasure.
    func deleteAll() async throws
}

extension PhotoStorageService {
    func saveWithProgress(_ image: UIImage, forID id: UUID) -> AsyncThrowingStream<PhotoUploadEvent, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let path = try await save(image, forID: id)
                    continuation.yield(.completed(path))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

actor LocalPhotoStorageService: PhotoStorageService {
    private let directory: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("DiaryPhotos", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.directory = dir
    }

    func save(_ image: UIImage, forID id: UUID) async throws -> String {
        let url = directory.appendingPathComponent("\(id.uuidString).jpg")
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw PhotoStorageError.encodingFailed
        }
        try data.write(to: url, options: .atomic)
        return url.path
    }

    func load(atPath path: String) async -> UIImage? {
        UIImage(contentsOfFile: path)
    }

    func delete(atPath path: String) async throws {
        try FileManager.default.removeItem(atPath: path)
    }

    func deleteAll() async throws {
        try? FileManager.default.removeItem(at: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
}
