import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    /// The active child. Kept as a stored mirror (not computed) so the ~20 existing
    /// consumers and the few setters keep working unchanged while multi-child lands.
    @Published var babyProfile: BabyProfile?
    /// Full roster, oldest first (child #1 first).
    @Published private(set) var babies: [BabyProfile] = []
    @Published private(set) var activeBabyId: UUID?

    private let getBabyProfile: GetBabyProfileUseCase
    private let getAllBabies: GetAllBabiesUseCase
    private var lm: LocalizationManager { .shared }
    private var mergeObserver: NSObjectProtocol?

    init(getBabyProfile: GetBabyProfileUseCase, getAllBabies: GetAllBabiesUseCase) {
        self.getBabyProfile = getBabyProfile
        self.getAllBabies = getAllBabies
        // The launch downloader adopts every child's profile during sync; reload the
        // roster when it signals a merge so the switcher reflects newly-pulled children.
        mergeObserver = NotificationCenter.default.addObserver(
            forName: .cloudSyncDidMerge, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in await self?.load() }
        }
    }

    deinit {
        if let mergeObserver { NotificationCenter.default.removeObserver(mergeObserver) }
    }

    func load() async {
        babies = (try? await getAllBabies.execute()) ?? []
        activeBabyId = ActiveBaby.currentId
        babyProfile = activeChild()
        if let p = babyProfile {
            WidgetDataStore.shared.setBabyInfo(name: p.name, birthDate: p.birthDate)
        }
    }

    private func activeChild() -> BabyProfile? {
        if let id = activeBabyId, let match = babies.first(where: { $0.id == id }) { return match }
        return babies.sorted { $0.birthDate < $1.birthDate }.first
    }

    /// Upsert a child into the roster and mirror it when it is the active one.
    /// Called on onboarding (first child) and profile edits.
    func update(_ profile: BabyProfile) {
        if let idx = babies.firstIndex(where: { $0.id == profile.id }) {
            babies[idx] = profile
        } else {
            babies.append(profile)
        }
        if activeBabyId == nil { activeBabyId = ActiveBaby.currentId ?? profile.id }
        // A persisted pointer to a child that isn't in the roster (e.g. left over from
        // a removed child or a prior account) must not strand this upsert without an
        // active mirror — adopt the upserted child as active in that case. This mirrors
        // activeChild()'s fallback used by load().
        if !babies.contains(where: { $0.id == activeBabyId }) { activeBabyId = profile.id }
        if activeBabyId == profile.id {
            babyProfile = profile
            WidgetDataStore.shared.setBabyInfo(name: profile.name, birthDate: profile.birthDate)
        }
    }

    /// Point the whole app at a different child. Persists the pointer and mirrors the
    /// profile; cloud re-sync for the new child is orchestrated by AppContainer.
    func setActive(_ id: UUID) {
        ActiveBaby.currentId = id
        activeBabyId = id
        babyProfile = activeChild()
        if let p = babyProfile {
            WidgetDataStore.shared.setBabyInfo(name: p.name, birthDate: p.birthDate)
        }
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
