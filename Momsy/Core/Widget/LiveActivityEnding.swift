import ActivityKit
import Foundation

/// The asynchronous remainder of a Live Activity teardown, handed back by
/// `prepareEnd()` once the manager has already dropped its local bookkeeping.
/// Main-actor isolated because `Activity` handles are only touched there.
typealias LiveActivityTeardown = @MainActor () async -> Void

/// Shared ending contract for the Live Activity managers (sleep, feeding, walk,
/// bath, pumping).
///
/// `endActivity()` stays fire-and-forget for UI callers, which keep running
/// after the call and give the spawned task a chance to finish. Callers that can
/// be suspended the moment they return — remote push handlers above all — must
/// use `endActivityAwaitingCompletion()`, otherwise the system can freeze the
/// process before ActivityKit dismissed the activity and it stays on the Lock
/// Screen until the user opens the app.
@MainActor
protocol LiveActivityEnding: AnyObject {
    /// Cancels observers and drops the cached activity synchronously, then
    /// returns the ActivityKit teardown that can only run asynchronously.
    ///
    /// Splitting it this way keeps the local state reset immediate on both
    /// paths: a `startActivity` right after an `endActivity` never sees stale
    /// bookkeeping, whether or not the caller awaited the teardown.
    func prepareEnd() -> LiveActivityTeardown

    /// Ends the activity without blocking the caller.
    func endActivity()

    /// Ends the activity and returns only after ActivityKit is done with it.
    func endActivityAwaitingCompletion() async
}

extension LiveActivityEnding {
    func endActivity() {
        let teardown = prepareEnd()
        Task { @MainActor in await teardown() }
    }

    func endActivityAwaitingCompletion() async {
        let teardown = prepareEnd()
        await teardown()
    }
}

extension Activity {
    /// Every running activity of this kind, plus `cached` when ActivityKit does
    /// not list it (yet), so a just-requested activity is never left behind.
    @MainActor
    static func endableActivities(
        including cached: Activity<Attributes>?
    ) -> [Activity<Attributes>] {
        var activities = Activity<Attributes>.activities
        if let cached, !activities.contains(where: { $0.id == cached.id }) {
            activities.append(cached)
        }
        return activities
    }
}
