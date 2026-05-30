import ActivityKit
import Foundation

struct PumpingActivityAttributes: ActivityAttributes {
    var side: String
    var babyName: String

    struct ContentState: Codable, Hashable, Sendable {
        var effectiveStartDate: Date
    }
}
