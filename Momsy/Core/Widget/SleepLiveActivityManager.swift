import ActivityKit
import Foundation

@MainActor
final class SleepLiveActivityManager {
    private var activity: Activity<SleepActivityAttributes>?

    func startActivity(startDate: Date, babyName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        for existing in Activity<SleepActivityAttributes>.activities {
            Task { await existing.end(nil, dismissalPolicy: .immediate) }
        }
        activity = nil
        let attributes = SleepActivityAttributes(babyName: babyName)
        let state = SleepActivityAttributes.ContentState(effectiveStartDate: startDate)
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
        activity = Activity<SleepActivityAttributes>.activities.first
    }
}
