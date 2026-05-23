@testable import Momsy

enum TestError: Error {
    case mock
}

@MainActor
func makeAppState(profile: BabyProfile? = nil) -> AppState {
    let repo = MockBabyRepository(initialProfile: profile)
    let uc = GetBabyProfileUseCase(repository: repo)
    let state = AppState(getBabyProfile: uc)
    state.babyProfile = profile
    return state
}
