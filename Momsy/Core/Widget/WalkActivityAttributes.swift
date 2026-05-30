import ActivityKit
import Foundation

struct WalkActivityAttributes: ActivityAttributes {
    var babyName: String

    struct ContentState: Codable, Hashable, Sendable {
        var effectiveStartDate: Date
    }
}
