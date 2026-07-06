import Foundation

enum LeapCalendarScope: String, CaseIterable, Identifiable {
    case week
    case month

    var id: String { rawValue }
}

enum LeapCalendarDayPhase: String, Codable, Hashable {
    case calm
    case hard
    case peak
    case recovery
}

struct LeapCalendarDay: Identifiable, Equatable {
    let date: Date
    let dayNumber: Int
    let phase: LeapCalendarDayPhase
    let isToday: Bool
    let hasCheckIn: Bool

    var id: Date { date }
}

enum LeapCheckInSymptom: String, CaseIterable, Codable, Identifiable, Hashable {
    case sleepWorse
    case wantsHeld
    case fussiness
    case appetiteShift
    case newSkills

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .sleepWorse: return "moon.fill"
        case .wantsHeld: return "figure.2.arms.open"
        case .fussiness: return "cloud.rain.fill"
        case .appetiteShift: return "fork.knife"
        case .newSkills: return "sparkles"
        }
    }

    func title(for language: Language) -> String {
        switch self {
        case .sleepWorse:
            return localize("Sleep worse", "Сон хуже", "Schlaf schlechter", "Sueño peor", "Sommeil plus difficile", "Sono pior", "睡眠变差", language)
        case .wantsHeld:
            return localize("Wants arms", "Просится на руки", "Will auf den Arm", "Quiere brazos", "Réclame les bras", "Quer colo", "想被抱", language)
        case .fussiness:
            return localize("Fussy", "Капризность", "Quengelig", "Irritable", "Grognon", "Irritado", "烦躁", language)
        case .appetiteShift:
            return localize("Appetite shift", "Аппетит изменился", "Appetit anders", "Apetito distinto", "Appétit changé", "Apetite mudou", "食欲变化", language)
        case .newSkills:
            return localize("New skills", "Новые навыки", "Neue Fähigkeiten", "Nuevas habilidades", "Nouvelles compétences", "Novas competências", "新技能", language)
        }
    }

    private func localize(
        _ en: String,
        _ ru: String,
        _ de: String,
        _ es: String,
        _ fr: String,
        _ pt: String,
        _ zh: String,
        _ language: Language
    ) -> String {
        switch language {
        case .english: return en
        case .russian: return ru
        case .german: return de
        case .spanish: return es
        case .french: return fr
        case .portuguese: return pt
        case .chinese: return zh
        }
    }
}

struct LeapDailyCheckIn: Identifiable, Codable, Equatable {
    let leapID: Int
    let date: Date
    var symptoms: Set<LeapCheckInSymptom>

    var id: String {
        "\(leapID)-\(Int(date.timeIntervalSince1970))"
    }
}

struct LeapTodayAction: Identifiable, Equatable {
    let id: String
    let title: String
    let detail: String
    let systemImage: String
}

struct LeapBehaviorInsight: Identifiable, Equatable {
    let id: String
    let title: String
    let detail: String
    let systemImage: String
}

enum LeapHistoryDifficulty: String, Equatable {
    case light
    case moderate
    case hard
}

struct LeapHistorySummary: Identifiable, Equatable {
    let id: Int
    let leapID: Int
    let title: String
    let actualDays: Int
    let symptomDays: Int
    let difficulty: LeapHistoryDifficulty
    let dominantSymptoms: [LeapCheckInSymptom]
}
