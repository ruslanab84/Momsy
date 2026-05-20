import Foundation

struct SoundItem: Identifiable {
    let id = UUID()
    let name: String
    let nameEn: String
    let category: String
    let categoryEn: String
    var isPlaying: Bool = false

    func displayName(lang: String) -> String     { lang == "en" ? nameEn     : name }
    func displayCategory(lang: String) -> String { lang == "en" ? categoryEn : category }
}

let sampleSounds: [SoundItem] = [
    SoundItem(name: "Утроба",       nameEn: "Womb",        category: "белый шум",         categoryEn: "white noise"),
    SoundItem(name: "Дождь",        nameEn: "Rain",        category: "природа",           categoryEn: "nature"),
    SoundItem(name: "Фен",          nameEn: "Hair dryer",  category: "розовый шум",       categoryEn: "pink noise"),
    SoundItem(name: "Колыбельная",  nameEn: "Lullaby",     category: "мелодия",           categoryEn: "melody"),
    SoundItem(name: "Сердцебиение", nameEn: "Heartbeat",   category: "для новорождённых", categoryEn: "for newborns"),
    SoundItem(name: "Океан",        nameEn: "Ocean",       category: "природа",           categoryEn: "nature"),
    SoundItem(name: "Лес",          nameEn: "Forest",      category: "природа",           categoryEn: "nature"),
    SoundItem(name: "Ручей",        nameEn: "Brook",       category: "природа",           categoryEn: "nature"),
]
