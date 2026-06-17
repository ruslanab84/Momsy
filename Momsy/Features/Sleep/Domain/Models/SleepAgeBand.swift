import Foundation

/// Дробный возрастной бэнд ТОЛЬКО для прогноза сна.
/// BabyAgeStage намеренно не используется: внутри его "newborn 0–3 мес"
/// wake window меняется в 3 раза.
enum SleepAgeBand: CaseIterable {
    case weeks0to6, weeks6to12, months3to4, months4to6
    case months6to9, months9to12, months12to18, months18to24, months24plus

    /// Включительная верхняя граница в днях; nil = без верхней границы.
    var upperBoundDays: Int? {
        switch self {
        case .weeks0to6:    return 42
        case .weeks6to12:   return 84
        case .months3to4:   return 120
        case .months4to6:   return 180
        case .months6to9:   return 270
        case .months9to12:  return 365
        case .months12to18: return 545
        case .months18to24: return 730
        case .months24plus: return nil
        }
    }
}
