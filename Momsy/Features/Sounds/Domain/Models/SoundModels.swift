import Foundation

enum SoundNameKey {
    case womb, rain, hairDryer, lullaby, heartbeat, ocean, forest, brook

    func localized(_ strings: L10n) -> String {
        switch self {
        case .womb:      return strings.soundWomb
        case .rain:      return strings.soundRain
        case .hairDryer: return strings.soundHairDryer
        case .lullaby:   return strings.soundLullaby
        case .heartbeat: return strings.soundHeartbeat
        case .ocean:     return strings.soundOcean
        case .forest:    return strings.soundForest
        case .brook:     return strings.soundBrook
        }
    }
}

enum SoundCategoryKey {
    case whiteNoise, nature, pinkNoise, melody, newborns

    func localized(_ strings: L10n) -> String {
        switch self {
        case .whiteNoise: return strings.soundCategoryWhiteNoise
        case .nature:     return strings.soundCategoryNature
        case .pinkNoise:  return strings.soundCategoryPinkNoise
        case .melody:     return strings.soundCategoryMelody
        case .newborns:   return strings.soundCategoryNewborns
        }
    }
}

struct SoundItem: Identifiable {
    let id = UUID()
    let name: String
    let nameEn: String
    let category: String
    let categoryEn: String
    let nameKey: SoundNameKey
    let categoryKey: SoundCategoryKey
    var isPlaying: Bool = false
    var isFavorite: Bool = false

    func displayName(_ strings: L10n) -> String { nameKey.localized(strings) }
    func displayCategory(_ strings: L10n) -> String { categoryKey.localized(strings) }
    func displayName(lang: String) -> String { displayName(L10n(Language.from(lang))) }
    func displayCategory(lang: String) -> String { displayCategory(L10n(Language.from(lang))) }
}

let sampleSounds: [SoundItem] = [
    SoundItem(name: "Утроба",       nameEn: "Womb",        category: "белый шум",         categoryEn: "white noise", nameKey: .womb, categoryKey: .whiteNoise),
    SoundItem(name: "Дождь",        nameEn: "Rain",        category: "природа",           categoryEn: "nature", nameKey: .rain, categoryKey: .nature),
    SoundItem(name: "Фен",          nameEn: "Hair dryer",  category: "розовый шум",       categoryEn: "pink noise", nameKey: .hairDryer, categoryKey: .pinkNoise),
    SoundItem(name: "Колыбельная",  nameEn: "Lullaby",     category: "мелодия",           categoryEn: "melody", nameKey: .lullaby, categoryKey: .melody),
    SoundItem(name: "Сердцебиение", nameEn: "Heartbeat",   category: "для новорождённых", categoryEn: "for newborns", nameKey: .heartbeat, categoryKey: .newborns),
    SoundItem(name: "Океан",        nameEn: "Ocean",       category: "природа",           categoryEn: "nature", nameKey: .ocean, categoryKey: .nature),
    SoundItem(name: "Лес",          nameEn: "Forest",      category: "природа",           categoryEn: "nature", nameKey: .forest, categoryKey: .nature),
    SoundItem(name: "Ручей",        nameEn: "Brook",       category: "природа",           categoryEn: "nature", nameKey: .brook, categoryKey: .nature),
]
