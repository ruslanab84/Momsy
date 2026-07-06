import Foundation

protocol LeapCheckInRepository {
    func getCheckIns(leapID: Int) async throws -> [LeapDailyCheckIn]
    func saveCheckIn(_ checkIn: LeapDailyCheckIn) async throws
}
