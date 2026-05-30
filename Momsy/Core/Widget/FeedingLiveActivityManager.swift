import ActivityKit
import Foundation

@MainActor
final class FeedingLiveActivityManager {
    private var activity: Activity<FeedingActivityAttributes>?

    func startActivity(side: String, startDate: Date, babyName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        for existing in Activity<FeedingActivityAttributes>.activities {
            Task { await existing.end(nil, dismissalPolicy: .immediate) }
        }
        activity = nil
        let attributes = FeedingActivityAttributes(side: side, babyName: babyName)
        let state = FeedingActivityAttributes.ContentState(
            effectiveStartDate: startDate, isPaused: false, pausedSeconds: 0
        )
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil, relevanceScore: 75),
                pushType: nil
            )
        } catch {}
    }

    func pauseActivity(pausedSeconds: Int) {
        guard let activity else { return }
        let state = FeedingActivityAttributes.ContentState(
            effectiveStartDate: Date(), isPaused: true, pausedSeconds: pausedSeconds
        )
        Task { await activity.update(ActivityContent(state: state, staleDate: nil)) }
    }

    func resumeActivity(effectiveStartDate: Date) {
        guard let activity else { return }
        let state = FeedingActivityAttributes.ContentState(
            effectiveStartDate: effectiveStartDate, isPaused: false, pausedSeconds: 0
        )
        Task { await activity.update(ActivityContent(state: state, staleDate: nil)) }
    }

    func endActivity() {
        guard let activity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            self.activity = nil
        }
    }

    func reattachIfNeeded() {
        activity = Activity<FeedingActivityAttributes>.activities.first
    }
}
