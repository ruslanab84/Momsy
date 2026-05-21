@testable import Momsy

final class MockSoundRepository: SoundRepository {
    private var stored: Set<String> = []
    func loadFavorites() -> Set<String> { stored }
    func saveFavorites(_ favorites: Set<String>) { stored = favorites }
}
