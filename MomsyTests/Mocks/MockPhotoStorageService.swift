@testable import Momsy
import UIKit

final class MockPhotoStorageService: PhotoStorageService, @unchecked Sendable {
    var shouldThrow = false
    var savedPaths: [UUID: String] = [:]

    func save(_ image: UIImage, forID id: UUID) async throws -> String {
        if shouldThrow { throw PhotoStorageError.uploadFailed }
        let path = "mock/\(id.uuidString).jpg"
        savedPaths[id] = path
        return path
    }

    func load(atPath path: String) async -> UIImage? { nil }

    func delete(atPath path: String) async throws {}
}
