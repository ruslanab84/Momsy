import Foundation

/// How to resolve an orphaned, still-open activity session discovered at launch —
/// a session whose `stop()` began (and cleared the widget state) but whose database
/// write was lost when the app was killed.
enum StaleSessionResolution: Equatable {
    /// Close the session at the recovered, real end time.
    case close(at: Date)
    /// Discard the session entirely because the recovered end is missing or
    /// implausible, so it can never inflate sleep / walk / bath totals.
    case discard
}

/// Decides how to close out an orphaned open session. Pure and side-effect free so
/// the (bounds-sensitive) logic can be unit-tested without I/O.
///
/// The previous behaviour stamped `Date()` as the end, which — if the app had been
/// closed for hours or days — recorded a single phantom session of that length and
/// inflated every downstream statistic (today totals, charts, weekly insights).
enum StaleSessionReconciler {

    /// - Parameters:
    ///   - start: the open session's start time.
    ///   - recoveredEnd: the true end time the widget store persisted at stop time,
    ///     if known. Sleep stores it directly; walk/bath derive it from the last
    ///     recorded duration.
    ///   - maxDuration: sessions longer than this are treated as untrustworthy.
    ///   - now: the current time (injected for deterministic testing).
    static func resolve(
        start: Date,
        recoveredEnd: Date?,
        maxDuration: TimeInterval,
        now: Date = Date()
    ) -> StaleSessionResolution {
        guard let end = recoveredEnd,
              end > start,
              end <= now,
              end.timeIntervalSince(start) <= maxDuration
        else { return .discard }
        return .close(at: end)
    }
}
