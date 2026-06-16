import Foundation

/// When a vaccination is due, relative to the baby's birth date.
/// Replaces the old `ageMonths: Int` field and its magic numbers (0 = birth, 999 = additional)
/// so that week-based primary series (used by the WHO/EPI schedule) can be represented accurately.
enum VaccinationTiming: Hashable {
    case atBirth
    case weeks(Int)
    case months(Int)
    case additional   // user-added vaccines that don't belong to a scheduled milestone

    /// Canonical, sortable key in days from birth (used for grouping/ordering).
    var sortKeyDays: Int {
        switch self {
        case .atBirth:       return 0
        case .weeks(let w):  return w * 7
        case .months(let m): return m * 30
        case .additional:    return Int.max
        }
    }

    func dueDate(from birth: Date, _ cal: Calendar = .current) -> Date {
        switch self {
        case .atBirth:       return birth
        case .weeks(let w):  return cal.date(byAdding: .weekOfYear, value: w, to: birth) ?? birth
        case .months(let m): return cal.date(byAdding: .month, value: m, to: birth) ?? birth
        case .additional:    return birth
        }
    }

    func label(_ lang: Language) -> String {
        switch self {
        case .atBirth:
            switch lang {
            case .russian: return "Рождение"
            case .german:  return "Geburt"
            case .spanish: return "Nacimiento"
            case .french:  return "Naissance"
            case .portuguese: return "Nascimento"
            default:       return "Birth"
            }
        case .weeks(let w):
            switch lang {
            case .russian: return "\(w) \(Self.ruWeeks(w))"
            case .german:  return w == 1 ? "1 Woche"  : "\(w) Wochen"
            case .spanish: return w == 1 ? "1 semana" : "\(w) semanas"
            case .french:  return w == 1 ? "1 semaine": "\(w) semaines"
            case .portuguese: return w == 1 ? "1 semana" : "\(w) semanas"
            default:       return w == 1 ? "1 week"   : "\(w) weeks"
            }
        case .months(let m):
            switch lang {
            case .russian: return "\(m) \(Self.ruMonths(m))"
            case .german:  return m == 1 ? "1 Monat" : "\(m) Monate"
            case .spanish: return m == 1 ? "1 mes"   : "\(m) meses"
            case .french:  return m == 1 ? "1 mois"  : "\(m) mois"
            case .portuguese: return m == 1 ? "1 mês" : "\(m) meses"
            default:       return m == 1 ? "1 month" : "\(m) months"
            }
        case .additional:
            switch lang {
            case .russian: return "Дополнительные"
            case .german:  return "Weitere"
            case .spanish: return "Adicionales"
            case .french:  return "Supplémentaires"
            case .portuguese: return "Adicionais"
            default:       return "Additional"
            }
        }
    }

    private static func ruMonths(_ n: Int) -> String {
        if n % 10 == 1 && n % 100 != 11 { return "месяц" }
        if (2...4).contains(n % 10) && !(12...14).contains(n % 100) { return "месяца" }
        return "месяцев"
    }

    private static func ruWeeks(_ n: Int) -> String {
        if n % 10 == 1 && n % 100 != 11 { return "неделя" }
        if (2...4).contains(n % 10) && !(12...14).contains(n % 100) { return "недели" }
        return "недель"
    }
}

struct VaccinationScheduleItem: Identifiable {
    let id: Int
    let names: [Language: String]
    let timing: VaccinationTiming
    let isOptional: Bool

    func name(for lang: Language) -> String {
        names[lang] ?? names[.english] ?? names.first?.value ?? ""
    }
}

extension VaccinationScheduleItem {
    /// Convenience initializer for authoring schedule data files compactly.
    init(id: Int, en: String, ru: String, de: String, es: String, fr: String, pt: String,
         timing: VaccinationTiming, isOptional: Bool = false) {
        self.init(
            id: id,
            names: [.english: en, .russian: ru, .german: de, .spanish: es, .french: fr, .portuguese: pt],
            timing: timing,
            isOptional: isOptional
        )
    }
}

struct VaccinationEntry: Identifiable {
    var id: UUID
    var catalogId: Int
    var doneDate: Date
    var notes: String
    var customName: String?
    var updatedAt: Date? = Date()

    var isCustom: Bool { customName != nil }
}

struct VaccinationStatus: Identifiable {
    let item: VaccinationScheduleItem
    let entry: VaccinationEntry?
    let dueDate: Date

    var id: Int { item.id }
    var isDone: Bool { entry != nil }
    var isOverdue: Bool { !isDone && dueDate < Date() }
}
