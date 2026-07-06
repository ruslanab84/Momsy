@testable import Momsy
import Foundation

final class MockPushNotificationService: PushNotificationServiceProtocol, @unchecked Sendable {
    var permissionRequested = false
    var scheduledDiaryHour: Int?
    var weeklyReportScheduled = false
    var weeklyReportCancelled = false
    var scheduledLeapSoonIDs: [Int] = []
    var scheduledLeapPeakIDs: [Int] = []
    var scheduledLeapSkillsIDs: [Int] = []

    func requestPermission() async { permissionRequested = true }
    func scheduleFeedingReminder(afterMinutes minutes: Int) {}
    func cancelFeedingReminder() {}
    func scheduleMorningDiary(hour: Int, minute: Int) { scheduledDiaryHour = hour }
    func scheduleLeapNotification(leapID: Int, name: String, startDate: Date) {}
    func scheduleLeapSoonNotification(leapID: Int, name: String, fireDate: Date) { scheduledLeapSoonIDs.append(leapID) }
    func scheduleLeapPeakNotification(leapID: Int, name: String, fireDate: Date) { scheduledLeapPeakIDs.append(leapID) }
    func scheduleLeapSkillsReminder(leapID: Int, name: String, fireDate: Date) { scheduledLeapSkillsIDs.append(leapID) }
    func cancelLeapNotification(leapID: Int) {}
    func scheduleVaccinationReminder(catalogId: Int, name: String, dueDate: Date) {}
    func cancelVaccinationReminder(catalogId: Int) {}
    func scheduleWeeklyReport(hour: Int, minute: Int) { weeklyReportScheduled = true }
    func cancelWeeklyReport() { weeklyReportCancelled = true }
}
