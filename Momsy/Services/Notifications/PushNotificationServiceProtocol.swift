import Foundation

protocol PushNotificationServiceProtocol: Sendable {
    func requestPermission() async
    func scheduleFeedingReminder(afterMinutes minutes: Int)
    func cancelFeedingReminder()
    func scheduleMorningDiary(hour: Int, minute: Int)
    func scheduleLeapNotification(leapID: Int, name: String, startDate: Date)
    func scheduleLeapSoonNotification(leapID: Int, name: String, fireDate: Date)
    func scheduleLeapPeakNotification(leapID: Int, name: String, fireDate: Date)
    func scheduleLeapSkillsReminder(leapID: Int, name: String, fireDate: Date)
    func cancelLeapNotification(leapID: Int)
    func scheduleVaccinationReminder(catalogId: Int, name: String, dueDate: Date)
    func cancelVaccinationReminder(catalogId: Int)
    func scheduleWeeklyReport(hour: Int, minute: Int)
    func cancelWeeklyReport()
}
