import Foundation

final class ScheduleLeapNotificationsUseCase {
    private let pushNotifications: any PushNotificationServiceProtocol
    private let calendar: Calendar

    init(
        pushNotifications: any PushNotificationServiceProtocol,
        calendar: Calendar = .current
    ) {
        self.pushNotifications = pushNotifications
        self.calendar = calendar
    }

    func execute(
        leaps: [DevelopmentLeap],
        birthDate: Date,
        language: Language,
        now: Date = Date()
    ) {
        for leap in leaps {
            guard !leap.isDone else {
                pushNotifications.cancelLeapNotification(leapID: leap.id)
                continue
            }

            let startDate = reminderDate(
                on: BabyAgeContext.leapStartDate(for: leap, birthDate: birthDate, calendar: calendar),
                hour: 9
            )
            let peakDate = reminderDate(
                on: calendar.date(
                    byAdding: .day,
                    value: BabyAgeContext.peakDay(totalHardDays: leap.hardDays) - 1,
                    to: startDate
                ) ?? startDate,
                hour: 9
            )
            let skillsDate = reminderDate(
                on: calendar.date(byAdding: .day, value: leap.hardDays, to: startDate) ?? startDate,
                hour: 10
            )
            let soonDate = reminderDate(
                on: calendar.date(byAdding: .day, value: -3, to: startDate) ?? startDate,
                hour: 9
            )
            let name = leap.name(for: language)

            if soonDate > now {
                pushNotifications.scheduleLeapSoonNotification(
                    leapID: leap.id,
                    name: name,
                    fireDate: soonDate
                )
            }
            if startDate > now {
                pushNotifications.scheduleLeapNotification(
                    leapID: leap.id,
                    name: name,
                    startDate: startDate
                )
            }
            if peakDate > now {
                pushNotifications.scheduleLeapPeakNotification(
                    leapID: leap.id,
                    name: name,
                    fireDate: peakDate
                )
            }
            if skillsDate > now {
                pushNotifications.scheduleLeapSkillsReminder(
                    leapID: leap.id,
                    name: name,
                    fireDate: skillsDate
                )
            }
        }
    }

    private func reminderDate(on date: Date, hour: Int) -> Date {
        let day = calendar.startOfDay(for: date)
        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day) ?? day
    }
}
