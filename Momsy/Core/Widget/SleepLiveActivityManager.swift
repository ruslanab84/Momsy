import ActivityKit
import Foundation
import os

@MainActor
final class SleepLiveActivityManager {
    private var activity: Activity<SleepActivityAttributes>?
    private let logger = Logger(subsystem: "RuslanAbd.Momsy", category: "LiveActivity")

    func startActivity(startDate: Date, babyName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.error("Sleep: Live Activities disabled in Settings (areActivitiesEnabled=false)")
            return
        }
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
            logger.log("Sleep: started activity \(self.activity?.id ?? "nil")")
        } catch {
            logger.error("Sleep: Activity.request failed: \(error.localizedDescription)")
        }
    }

    func endActivity() {
        activity = nil
        Task {
            for existing in Activity<SleepActivityAttributes>.activities {
                await existing.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    func reattachIfNeeded() {
        activity = Activity<SleepActivityAttributes>.activities.first
    }
}
