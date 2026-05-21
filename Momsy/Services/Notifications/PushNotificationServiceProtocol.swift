import Foundation

protocol PushNotificationServiceProtocol: Sendable {
    func requestPermission() async
    func scheduleFeedingReminder(afterMinutes minutes: Int)
    func cancelFeedingReminder()
    func scheduleMorningDiary(hour: Int, minute: Int)
    func scheduleLeapNotification(leapID: Int, name: String, nameEn: String, startDate: Date)
    func cancelLeapNotification(leapID: Int)
}
