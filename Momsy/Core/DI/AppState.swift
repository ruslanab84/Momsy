import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var babyProfile: BabyProfile?

    private let getBabyProfile: GetBabyProfileUseCase

    init(getBabyProfile: GetBabyProfileUseCase) {
        self.getBabyProfile = getBabyProfile
    }

    func load() async {
        babyProfile = try? await getBabyProfile.execute()
    }

    func update(_ profile: BabyProfile) {
        babyProfile = profile
    }
}
