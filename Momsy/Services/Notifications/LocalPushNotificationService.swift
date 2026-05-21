import UserNotifications

final class LocalPushNotificationService: PushNotificationServiceProtocol, @unchecked Sendable {

    static let shared = LocalPushNotificationService()

    private let center = UNUserNotificationCenter.current()

    private enum ID {
        static let feeding = "momsy.feeding.reminder"
        static let diary   = "momsy.diary.morning"
        static func leap(_ id: Int) -> String { "momsy.leap.\(id)" }
    }

    func requestPermission() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleFeedingReminder(afterMinutes minutes: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [ID.feeding])
        let isEn = (UserDefaults.standard.string(forKey: "appLanguage") ?? "en") == "en"
        let hours = minutes / 60

        let content = UNMutableNotificationContent()
        content.title = isEn ? "Feeding reminder" : "Напоминание о кормлении"
        content.body  = isEn
            ? "Baby hasn't eaten in \(hours)+ hours. Time to feed?"
            : "Малыш не ел уже \(hours)+ ч. Пора покормить?"
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
        let isEn = (UserDefaults.standard.string(forKey: "appLanguage") ?? "en") == "en"

        let content = UNMutableNotificationContent()
        content.title = isEn ? "Daily diary" : "Дневник малыша"
        content.body  = isEn
            ? "Write down today's special moments"
            : "Запишите сегодняшние моменты в дневник малыша"
        content.sound = .default

        var comps = DateComponents()
        comps.hour   = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        center.add(UNNotificationRequest(identifier: ID.diary, content: content, trigger: trigger), withCompletionHandler: nil)
    }

    func scheduleLeapNotification(leapID: Int, name: String, nameEn: String, startDate: Date) {
        guard startDate > Date() else { return }
        let isEn = (UserDefaults.standard.string(forKey: "appLanguage") ?? "en") == "en"

        let content = UNMutableNotificationContent()
        content.title = isEn ? "Development leap" : "Скачок развития"
        content.body  = isEn
            ? "«\(nameEn)» leap begins — your baby is reaching a new stage"
            : "Начинается «\(name)» — малыш переходит на новый этап"
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: ID.leap(leapID), content: content, trigger: trigger), withCompletionHandler: nil)
    }

    func cancelLeapNotification(leapID: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [ID.leap(leapID)])
    }
}
