import ActivityKit
import Foundation
import os

@MainActor
final class BathLiveActivityManager: LiveActivityEnding {
    private var activity: Activity<BathActivityAttributes>?
    private let logger = Logger(subsystem: "RuslanAbd.Momsy", category: "LiveActivity")

    func startActivity(startDate: Date, babyName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.error("Bath: Live Activities disabled in Settings (areActivitiesEnabled=false)")
            return
        }
        for existing in Activity<BathActivityAttributes>.activities {
            Task { await existing.end(nil, dismissalPolicy: .immediate) }
        }
        activity = nil
        let attributes = BathActivityAttributes(babyName: babyName)
        let state = BathActivityAttributes.ContentState(effectiveStartDate: startDate)
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil, relevanceScore: 75),
                pushType: nil
            )
            logger.log("Bath: started activity \(self.activity?.id ?? "nil")")
        } catch {
            logger.error("Bath: Activity.request failed: \(error.localizedDescription)")
        }
    }

    func prepareEnd() -> LiveActivityTeardown {
        let activitiesToEnd = Activity<BathActivityAttributes>.endableActivities(including: activity)
        activity = nil
        return {
            for existing in activitiesToEnd {
                await existing.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    func reattachIfNeeded() {
        activity = Activity<BathActivityAttributes>.activities.first
    }
}
