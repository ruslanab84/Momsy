import ActivityKit
import Foundation

struct SleepActivityAttributes: ActivityAttributes {
    var babyName: String

    struct ContentState: Codable, Hashable, Sendable {
        var effectiveStartDate: Date
    }
}
