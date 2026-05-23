@testable import Momsy
import Foundation

final class MockPushNotificationService: PushNotificationServiceProtocol, @unchecked Sendable {
    var permissionRequested = false
    var scheduledDiaryHour: Int?

    func requestPermission() async { permissionRequested = true }
    func scheduleFeedingReminder(afterMinutes minutes: Int) {}
    func cancelFeedingReminder() {}
    func scheduleMorningDiary(hour: Int, minute: Int) { scheduledDiaryHour = hour }
    func scheduleLeapNotification(leapID: Int, name: String, nameEn: String, startDate: Date) {}
    func cancelLeapNotification(leapID: Int) {}
}
