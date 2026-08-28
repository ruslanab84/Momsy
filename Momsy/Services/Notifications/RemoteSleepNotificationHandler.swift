import UIKit

final class MomsyAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            RemotePushTokenService.shared.receiveApplicationToken(deviceToken)
        }
    }

    nonisolated func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]
    ) async -> UIBackgroundFetchResult {
        await RemoteSleepNotificationHandler.handle(RemoteSleepEndPayload(userInfo))
    }
}

private struct RemoteSleepEndPayload: Sendable {
    let action: String?
    let familyId: String?
    let babyId: String?
    let sleepLogId: String?
    let endedAt: Double?

    nonisolated init(_ userInfo: [AnyHashable: Any]) {
        action = userInfo["action"] as? String
        familyId = userInfo["familyId"] as? String
        babyId = userInfo["babyId"] as? String
        sleepLogId = userInfo["sleepLogId"] as? String
        endedAt = (userInfo["endedAt"] as? NSNumber)?.doubleValue
    }
}

enum RemoteSleepNotificationHandler {
    @MainActor
    fileprivate static func handle(_ payload: RemoteSleepEndPayload) async -> UIBackgroundFetchResult {
        guard payload.action == "end-sleep",
              let familyId = payload.familyId,
              familyId == UserDefaults.standard.string(forKey: kFamilyIdDefaultsKey),
              let babyIdString = payload.babyId,
              let babyId = UUID(uuidString: babyIdString),
              let sleepLogIdString = payload.sleepLogId,
              let sleepLogId = UUID(uuidString: sleepLogIdString),
              let endedAt = payload.endedAt,
              endedAt.isFinite,
              endedAt > 0 else { return .noData }

        let changed = WidgetDataStore.shared.endSleepIfMatches(
            sleepLogId: sleepLogId,
            babyId: babyId,
            endedAt: Date(timeIntervalSince1970: endedAt)
        )
        if changed {
            // The system can suspend the app as soon as this handler returns,
            // so the dismissal has to be awaited — a fire-and-forget task would
            // leave the activity on the Lock Screen.
            await SleepLiveActivityManager().endActivityAwaitingCompletion()
        }
        return changed ? .newData : .noData
    }
}
