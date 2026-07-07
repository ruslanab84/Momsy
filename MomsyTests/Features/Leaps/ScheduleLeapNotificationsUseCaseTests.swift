import Testing
@testable import Momsy
import Foundation

@Suite("ScheduleLeapNotificationsUseCase")
struct ScheduleLeapNotificationsUseCaseTests {

    @Test("schedules only the next N pending leaps and cancels the rest")
    func capsPendingLeaps() {
        let mock = MockPushNotificationService()
        let sut = ScheduleLeapNotificationsUseCase(pushNotifications: mock, maxScheduledLeaps: 3)
        let birthDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let leaps = DevelopmentLeap.catalog.map { leap -> DevelopmentLeap in
            var copy = leap
            copy.isDone = leap.id == 1
            copy.isCurrent = false
            return copy
        }

        sut.execute(leaps: leaps, birthDate: birthDate, language: .english)

        #expect(Set(mock.scheduledLeapStartIDs) == Set([2, 3, 4]))
        #expect(mock.cancelledLeapIDs.contains(1))
        #expect(mock.cancelledLeapIDs.contains(5))
        #expect(!mock.scheduledLeapStartIDs.contains(5))
    }
}
