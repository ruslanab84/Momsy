@testable import Momsy
import Foundation

final class MockLeapsRepository: LeapsRepository {
    var progress: [LeapProgress] = []
    var shouldThrow = false

    func getAllProgress() async throws -> [LeapProgress] {
        if shouldThrow { throw TestError.mock }
        return progress
    }

    func saveProgress(_ p: LeapProgress) async throws {
        if shouldThrow { throw TestError.mock }
        if let idx = progress.firstIndex(where: { $0.id == p.id }) {
            progress[idx] = p
        } else {
            progress.append(p)
        }
    }

    func upsert(_ entries: [LeapProgress]) async throws {
        if shouldThrow { throw TestError.mock }
        for p in entries {
            if let idx = progress.firstIndex(where: { $0.id == p.id }) {
                progress[idx] = p
            } else {
                progress.append(p)
            }
        }
    }

    func resetProgress(id: Int) async throws {
        progress.removeAll { $0.id == id }
    }
}
