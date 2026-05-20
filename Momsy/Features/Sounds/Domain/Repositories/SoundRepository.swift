import Foundation

protocol SoundRepository {
    func loadFavorites() -> Set<String>
    func saveFavorites(_ favorites: Set<String>)
}
