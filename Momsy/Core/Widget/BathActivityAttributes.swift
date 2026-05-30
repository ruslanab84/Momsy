import ActivityKit
import Foundation

struct BathActivityAttributes: ActivityAttributes {
    var babyName: String

    struct ContentState: Codable, Hashable, Sendable {
        var effectiveStartDate: Date
    }
}
