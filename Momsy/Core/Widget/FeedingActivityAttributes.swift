import ActivityKit
import Foundation

struct FeedingActivityAttributes: ActivityAttributes {
    var side: String      // "left" | "right" | "bottle"
    var babyName: String

    struct ContentState: Codable, Hashable, Sendable {
        var effectiveStartDate: Date
        var isPaused: Bool
        var pausedSeconds: Int
    }
}
