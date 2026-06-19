@testable import Momsy
import Foundation

enum TestError: Error {
    case mock
}

@MainActor
func makeAppState(profile: BabyProfile? = nil) -> AppState {
    let repo = MockBabyRepository(initialProfile: profile)
    let uc = GetBabyProfileUseCase(repository: repo)
    let all = GetAllBabiesUseCase(repository: repo)
    let state = AppState(getBabyProfile: uc, getAllBabies: all)
    state.babyProfile = profile
    return state
}
