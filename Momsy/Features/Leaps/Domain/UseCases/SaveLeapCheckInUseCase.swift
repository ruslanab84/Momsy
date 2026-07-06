import Foundation

final class SaveLeapCheckInUseCase {
    private let repository: LeapCheckInRepository

    init(repository: LeapCheckInRepository) {
        self.repository = repository
    }

    func execute(_ checkIn: LeapDailyCheckIn) async throws {
        try await repository.saveCheckIn(checkIn)
    }
}
