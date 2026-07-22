import ActivityKit
import Foundation

struct SleepActivityAttributes: ActivityAttributes {
    var babyName: String

    struct ContentState: Codable, Hashable, Sendable {
        var effectiveStartDate: Date
        var endDate: Date? = nil

        var timerInterval: ClosedRange<Date> {
            effectiveStartDate...max(endDate ?? .distantFuture, effectiveStartDate)
        }
    }
}
