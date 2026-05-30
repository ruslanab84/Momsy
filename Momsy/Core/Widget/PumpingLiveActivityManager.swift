import ActivityKit
import Foundation

@MainActor
final class PumpingLiveActivityManager {
    private var activity: Activity<PumpingActivityAttributes>?

    func startActivity(side: String, startDate: Date, babyName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        for existing in Activity<PumpingActivityAttributes>.activities {
            Task { await existing.end(nil, dismissalPolicy: .immediate) }
        }
        activity = nil
        let attributes = PumpingActivityAttributes(side: side, babyName: babyName)
        let state = PumpingActivityAttributes.ContentState(effectiveStartDate: startDate)
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil, relevanceScore: 75),
                pushType: nil
            )
        } catch {}
    }

    func endActivity() {
        guard let activity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            self.activity = nil
        }
    }

    func reattachIfNeeded() {
        activity = Activity<PumpingActivityAttributes>.activities.first
    }
}
