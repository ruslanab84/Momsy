import Foundation

final class LocalSoundRepository: SoundRepository {
    private let key = "sound_favorites"

    func loadFavorites() -> Set<String> {
        let arr = UserDefaults.standard.stringArray(forKey: key) ?? []
        return Set(arr)
    }

    func saveFavorites(_ favorites: Set<String>) {
        UserDefaults.standard.set(Array(favorites), forKey: key)
    }
}
