import Foundation

protocol LeapsRepository {
    func getAllProgress() async throws -> [LeapProgress]
    func saveProgress(_ progress: LeapProgress) async throws
    func resetProgress(id: Int) async throws
}
