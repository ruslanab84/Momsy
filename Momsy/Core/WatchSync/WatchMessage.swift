import Foundation

// Shared contract between the iPhone app and the Apple Watch companion.
//
// This file is intentionally free of any iOS-only types so it can be added to
// BOTH the `Momsy` target and the `MomsyWatch` watch target (via Target
// Membership in the file inspector). Sides and qualities cross the boundary as
// stable, non-localized tokens (`FeedingSide.token`, `SleepQuality.rawValue`).

/// Commands sent Watch → iPhone over `WCSession`.
enum WatchCommand: Codable, Equatable {
    case startFeeding(side: String)   // "left" | "right" | "bottle"
    case pauseFeeding
    case resumeFeeding
    case stopFeeding
    case startSleep
    case stopSleep(quality: String)   // SleepQuality.rawValue
    case logDiaper
}

/// Envelope carrying a command plus an idempotency id so re-delivered transfers
/// are processed at most once on the iPhone.
struct WatchCommandEnvelope: Codable, Equatable {
    let id: UUID
    let command: WatchCommand
    let sentAt: Date

    init(_ command: WatchCommand, id: UUID = UUID(), sentAt: Date = Date()) {
        self.id = id
        self.command = command
        self.sentAt = sentAt
    }
}

enum WatchFeedingState: Codable, Equatable {
    case idle(lastFeedingDate: Date?)
    case running(startDate: Date, side: String)
    case paused(elapsedSeconds: Int, side: String)
}

enum WatchSleepState: Codable, Equatable {
    case idle(lastDurationSeconds: Int?)
    case active(startDate: Date)
}

/// Authoritative state pushed iPhone → Watch via `updateApplicationContext`
/// (latest-wins). Drives the Watch UI and complications.
struct WatchState: Codable, Equatable {
    var babyName: String
    var feeding: WatchFeedingState
    var sleep: WatchSleepState
    var diaperCount: Int

    static let empty = WatchState(
        babyName: "",
        feeding: .idle(lastFeedingDate: nil),
        sleep: .idle(lastDurationSeconds: nil),
        diaperCount: 0
    )
}

/// Keys used in the `WCSession` payload dictionaries.
enum WatchConnectivityKeys {
    static let command = "cmd"
    static let state = "state"
}
