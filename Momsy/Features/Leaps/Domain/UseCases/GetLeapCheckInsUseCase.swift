import Foundation

final class GetLeapCheckInsUseCase {
    private let repository: LeapCheckInRepository

    init(repository: LeapCheckInRepository) {
        self.repository = repository
    }

    func execute(leapID: Int) async throws -> [LeapDailyCheckIn] {
        try await repository.getCheckIns(leapID: leapID)
    }
}
