import Foundation

final class ScheduleLeapNotificationsUseCase {
    private let pushNotifications: any PushNotificationServiceProtocol
    private let calendar: Calendar
    private let maxScheduledLeaps: Int

    init(
        pushNotifications: any PushNotificationServiceProtocol,
        calendar: Calendar = .current,
        maxScheduledLeaps: Int = 3
    ) {
        self.pushNotifications = pushNotifications
        self.calendar = calendar
        self.maxScheduledLeaps = maxScheduledLeaps
    }

    func execute(
        leaps: [DevelopmentLeap],
        birthDate: Date,
        language: Language,
        now: Date = Date()
    ) {
        let upcomingIDs = Set(
            leaps.filter { !$0.isDone }
                .sorted { $0.week < $1.week }
                .prefix(maxScheduledLeaps)
                .map(\.id)
        )

        for leap in leaps {
            guard upcomingIDs.contains(leap.id) else {
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
