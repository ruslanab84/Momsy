import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var babyProfile: BabyProfile?

    private let getBabyProfile: GetBabyProfileUseCase
    private var lm: LocalizationManager { .shared }

    init(getBabyProfile: GetBabyProfileUseCase) {
        self.getBabyProfile = getBabyProfile
    }

    func load() async {
        babyProfile = try? await getBabyProfile.execute()
    }

    func update(_ profile: BabyProfile) {
        babyProfile = profile
    }

    var displayName: String {
        let name = babyProfile?.name ?? ""
        return name.isEmpty ? lm.strings.baby : name
    }

    func babyAgeString(lang: String) -> String {
        guard let birth = babyProfile?.birthDate else { return "" }
        let comps = Calendar.current.dateComponents([.month, .day], from: birth, to: Date())
        let m = comps.month ?? 0, d = comps.day ?? 0
        if lang == "en" {
            if m == 0 { return "\(d)d" }
            if d == 0 { return "\(m)mo" }
            return "\(m)mo \(d)d"
        } else {
            if m == 0 { return "\(d) дн" }
            if d == 0 { return "\(m) мес" }
            return "\(m) мес \(d) дн"
        }
    }
}
