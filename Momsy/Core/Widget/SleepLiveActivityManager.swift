import ActivityKit
import Foundation
import os

@MainActor
final class SleepLiveActivityManager {
    private var activity: Activity<SleepActivityAttributes>?
    private var pushTokenTask: Task<Void, Never>?
    private var activityStateTask: Task<Void, Never>?
    private let logger = Logger(subsystem: "RuslanAbd.Momsy", category: "LiveActivity")

    func startActivity(
        startDate: Date,
        babyName: String,
        babyGender: String?,
        babyId: UUID?,
        sleepLogId: UUID
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.error("Sleep: Live Activities disabled in Settings (areActivitiesEnabled=false)")
            return
        }
        let previousFamilyId = FamilyManager.shared.familyId
        for existing in Activity<SleepActivityAttributes>.activities {
            Task {
                await existing.end(nil, dismissalPolicy: .immediate)
                RemotePushTokenService.shared.revokeLiveActivity(
                    activityId: existing.id,
                    familyId: previousFamilyId
                )
            }
        }
        pushTokenTask?.cancel()
        activityStateTask?.cancel()
        activity = nil
        let attributes = SleepActivityAttributes(babyName: babyName, babyGender: babyGender)
        let state = SleepActivityAttributes.ContentState(effectiveStartDate: startDate)
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil, relevanceScore: 75),
                pushType: .token
            )
            logger.log("Sleep: started activity \(self.activity?.id ?? "nil")")
            if let activity, let babyId, let familyId = FamilyManager.shared.familyId {
                observeRemoteLifecycle(
                    activity,
                    familyId: familyId,
                    babyId: babyId,
                    sleepLogId: sleepLogId,
                    effectiveStartDate: startDate
                )
            }
        } catch {
            logger.error("Sleep: Activity.request failed: \(error.localizedDescription)")
        }
    }

    func endActivity() {
        // Snapshot before the Task can yield so a later sleep activity cannot be ended by this stop.
        let context = snapshotEndContext()
        Task {
            await endActivities(in: context)
        }
    }

    /// Awaits the actual `ActivityKit` `end()` calls before returning. Required by callers
    /// (e.g. the remote push background handler) that must not return control to the system
    /// before the Live Activity has actually ended, or iOS may suspend the process first.
    func endActivityAwaitingCompletion() async {
        await endActivities(in: snapshotEndContext())
    }

    private func snapshotEndContext() -> (
        activities: [Activity<SleepActivityAttributes>],
        endDate: Date,
        familyId: String?
    ) {
        pushTokenTask?.cancel()
        activityStateTask?.cancel()
        pushTokenTask = nil
        activityStateTask = nil
        var activities = Activity<SleepActivityAttributes>.activities
        if let activity, !activities.contains(where: { $0.id == activity.id }) {
            activities.append(activity)
        }
        activity = nil
        return (activities, Date(), FamilyManager.shared.familyId)
    }

    private func endActivities(
        in context: (
            activities: [Activity<SleepActivityAttributes>],
            endDate: Date,
            familyId: String?
        )
    ) async {
        for existing in context.activities {
            var state = existing.content.state
            state.endDate = context.endDate
            await existing.end(
                ActivityContent(state: state, staleDate: nil, relevanceScore: 0),
                dismissalPolicy: .immediate
            )
            RemotePushTokenService.shared.revokeLiveActivity(
                activityId: existing.id,
                familyId: context.familyId
            )
        }
    }

    func reattachIfNeeded() {
        activity = Activity<SleepActivityAttributes>.activities.first
    }

    private func observeRemoteLifecycle(
        _ activity: Activity<SleepActivityAttributes>,
        familyId: String,
        babyId: UUID,
        sleepLogId: UUID,
        effectiveStartDate: Date
    ) {
        pushTokenTask = Task {
            for await token in activity.pushTokenUpdates {
                guard !Task.isCancelled else { return }
                RemotePushTokenService.shared.publishLiveActivity(
                    token: token,
                    activityId: activity.id,
                    familyId: familyId,
                    babyId: babyId,
                    sleepLogId: sleepLogId,
                    effectiveStartDate: effectiveStartDate
                )
            }
        }
        activityStateTask = Task {
            for await state in activity.activityStateUpdates {
                guard !Task.isCancelled else { return }
                if state == .ended || state == .dismissed {
                    RemotePushTokenService.shared.revokeLiveActivity(
                        activityId: activity.id,
                        familyId: familyId
                    )
                    return
                }
            }
        }
    }
}
