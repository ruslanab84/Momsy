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

    /// Снимает Live Activity и возвращает задачу, которая завершится, когда ActivityKit
    /// реально закроет все активности.
    ///
    /// Синхронная часть (отмена наблюдателей, снимок списка активностей, обнуление
    /// `activity`) выполняется до возврата, поэтому немедленный `startActivity` не
    /// подхватит уже снятую активность. Само `end(...)` асинхронно, и вызывающий из
    /// фонового контекста ОБЯЗАН его дождаться — см. `endActivityAndWait()`.
    @discardableResult
    func endActivity() -> Task<Void, Never> {
        pushTokenTask?.cancel()
        activityStateTask?.cancel()
        pushTokenTask = nil
        activityStateTask = nil
        var activities = Activity<SleepActivityAttributes>.activities
        if let activity, !activities.contains(where: { $0.id == activity.id }) {
            activities.append(activity)
        }
        let activitiesToEnd = activities
        let endDate = Date()
        let familyId = FamilyManager.shared.familyId
        activity = nil
        return Task {
            for existing in activitiesToEnd {
                var state = existing.content.state
                state.endDate = endDate
                await existing.end(
                    ActivityContent(state: state, staleDate: nil, relevanceScore: 0),
                    dismissalPolicy: .immediate
                )
                // Отзыв токена намеренно НЕ ожидается: completion Firestore приходит только
                // после ack бэкенда, поэтому офлайн ожидание не вернулось бы никогда и
                // повесило бы фоновый хендлер до убийства системой. Firestore сохранит
                // удаление в персистентном кэше и повторит его сам.
                RemotePushTokenService.shared.revokeLiveActivity(
                    activityId: existing.id,
                    familyId: familyId
                )
            }
        }
    }

    /// Снимает Live Activity и ждёт, пока ActivityKit закроет её.
    ///
    /// Нужен фоновым вызывающим (обработчику silent push от второго родителя): вернув
    /// управление раньше, чем `end(...)` отработал, хендлер отчитается системе о
    /// завершении, приложение уснёт, и Live Activity останется висеть на локскрине.
    func endActivityAndWait() async {
        await endActivity().value
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
