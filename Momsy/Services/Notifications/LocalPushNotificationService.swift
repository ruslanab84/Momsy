import UserNotifications

final class LocalPushNotificationService: PushNotificationServiceProtocol, @unchecked Sendable {

    static let shared = LocalPushNotificationService()

    private let center = UNUserNotificationCenter.current()

    private enum ID {
        static let feeding = "momsy.feeding.reminder"
        static let diary   = "momsy.diary.morning"
        static let weeklyReport = "momsy.weeklyreport"
        static func leap(_ id: Int) -> String { "momsy.leap.\(id)" }
        static func vaccination(_ id: Int) -> String { "momsy.vaccination.\(id)" }
    }

    func requestPermission() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleFeedingReminder(afterMinutes minutes: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [ID.feeding])
        let str = LocalizationManager.shared.strings
        let hours = minutes / 60

        let content = UNMutableNotificationContent()
        content.title = str.notifFeedingTitle
        content.body  = str.notifFeedingBody(hours: hours)
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(minutes * 60), repeats: false
        )
        center.add(UNNotificationRequest(identifier: ID.feeding, content: content, trigger: trigger), withCompletionHandler: nil)
    }

    func cancelFeedingReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [ID.feeding])
    }

    func scheduleMorningDiary(hour: Int = 9, minute: Int = 0) {
        center.removePendingNotificationRequests(withIdentifiers: [ID.diary])
        let str = LocalizationManager.shared.strings

        let content = UNMutableNotificationContent()
        content.title = str.notifDiaryTitle
        content.body  = str.notifDiaryBody
        content.sound = .default

        var comps = DateComponents()
        comps.hour   = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        center.add(UNNotificationRequest(identifier: ID.diary, content: content, trigger: trigger), withCompletionHandler: nil)
    }

    func scheduleLeapNotification(leapID: Int, name: String, nameEn: String, startDate: Date) {
        guard startDate > Date() else { return }
        let str = LocalizationManager.shared.strings
        let leapName = LocalizationManager.shared.current == .english ? nameEn : name

        let content = UNMutableNotificationContent()
        content.title = str.notifLeapTitle
        content.body  = str.notifLeapBody(name: leapName)
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: ID.leap(leapID), content: content, trigger: trigger), withCompletionHandler: nil)
    }

    func cancelLeapNotification(leapID: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [ID.leap(leapID)])
    }

    func scheduleVaccinationReminder(catalogId: Int, name: String, dueDate: Date) {
        center.removePendingNotificationRequests(withIdentifiers: [ID.vaccination(catalogId)])
        guard let fireDate = Calendar.current.date(byAdding: .day, value: -7, to: dueDate),
              fireDate > Date() else { return }
        let str = LocalizationManager.shared.strings

        let content = UNMutableNotificationContent()
        content.title = str.notifVaccinationTitle
        content.body  = str.notifVaccinationBody(name: name)
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: ID.vaccination(catalogId), content: content, trigger: trigger), withCompletionHandler: nil)
    }

    func cancelVaccinationReminder(catalogId: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [ID.vaccination(catalogId)])
    }

    /// Recurring Sunday reminder that the weekly AI report is ready.
    func scheduleWeeklyReport(hour: Int = 7, minute: Int = 0) {
        center.removePendingNotificationRequests(withIdentifiers: [ID.weeklyReport])
        let strings = LocalizationManager.shared.strings

        let content = UNMutableNotificationContent()
        content.title = strings.weeklyReportNotificationTitle
        content.body  = strings.weeklyReportNotificationBody
        content.sound = .default

        var comps = DateComponents()
        comps.weekday = 1   // Sunday
        comps.hour    = hour
        comps.minute  = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        center.add(UNNotificationRequest(identifier: ID.weeklyReport, content: content, trigger: trigger), withCompletionHandler: nil)
    }

    func cancelWeeklyReport() {
        center.removePendingNotificationRequests(withIdentifiers: [ID.weeklyReport])
    }
}
