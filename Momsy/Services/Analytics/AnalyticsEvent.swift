import Foundation

enum AnalyticsEvent {
    case onboardingComplete
    case feedingStarted(side: String)
    case feedingStopped(durationMinutes: Int, side: String)
    case diaryEntryAdded(type: String)
    case reportGenerated(period: String)
    case leapViewed(leapID: Int)
}

extension AnalyticsEvent {
    var name: String {
        switch self {
        case .onboardingComplete:  return "onboarding_complete"
        case .feedingStarted:      return "feeding_started"
        case .feedingStopped:      return "feeding_stopped"
        case .diaryEntryAdded:     return "diary_entry_added"
        case .reportGenerated:     return "report_generated"
        case .leapViewed:          return "leap_viewed"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .onboardingComplete:
            return [:]
        case .feedingStarted(let side):
            return ["side": side]
        case .feedingStopped(let minutes, let side):
            return ["duration_minutes": minutes, "side": side]
        case .diaryEntryAdded(let type):
            return ["entry_type": type]
        case .reportGenerated(let period):
            return ["period": period]
        case .leapViewed(let id):
            return ["leap_id": id]
        }
    }
}
