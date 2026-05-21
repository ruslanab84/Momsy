import UIKit

protocol PhotoStorageService: Sendable {
    func save(_ image: UIImage, forID id: UUID) async throws -> String
    func load(atPath path: String) async -> UIImage?
    func delete(atPath path: String) async throws
}

enum PhotoStorageError: Error {
    case encodingFailed
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
}
