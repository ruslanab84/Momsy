import Testing
@testable import Momsy
import Foundation
import AuthenticationServices

@Suite("VaccinationTiming")
struct VaccinationTimingTests {

    @Test("sortKeyDays orders birth < weeks < months < additional")
    func sortOrder() {
        #expect(VaccinationTiming.atBirth.sortKeyDays == 0)
        #expect(VaccinationTiming.weeks(6).sortKeyDays == 42)
        #expect(VaccinationTiming.months(9).sortKeyDays == 270)
        #expect(VaccinationTiming.additional.sortKeyDays == Int.max)
        #expect(VaccinationTiming.atBirth.sortKeyDays < VaccinationTiming.weeks(6).sortKeyDays)
        #expect(VaccinationTiming.weeks(14).sortKeyDays < VaccinationTiming.months(9).sortKeyDays)
    }

    @Test("dueDate adds the correct offset from birth")
    func dueDateOffsets() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let birth = cal.date(from: DateComponents(year: 2026, month: 1, day: 1))!

        #expect(VaccinationTiming.atBirth.dueDate(from: birth, cal) == birth)
        #expect(VaccinationTiming.weeks(6).dueDate(from: birth, cal)
                == cal.date(byAdding: .weekOfYear, value: 6, to: birth))
        #expect(VaccinationTiming.months(9).dueDate(from: birth, cal)
                == cal.date(byAdding: .month, value: 9, to: birth))
    }

    @Test("label localizes per language")
    func labels() {
        #expect(VaccinationTiming.atBirth.label(.english) == "Birth")
        #expect(VaccinationTiming.atBirth.label(.russian) == "Рождение")
        #expect(VaccinationTiming.weeks(6).label(.english) == "6 weeks")
        #expect(VaccinationTiming.weeks(1).label(.english) == "1 week")
        #expect(VaccinationTiming.months(1).label(.spanish) == "1 mes")
        #expect(VaccinationTiming.months(9).label(.spanish) == "9 meses")
        #expect(VaccinationTiming.additional.label(.german) == "Weitere")
        #expect(VaccinationTiming.months(9).label(.portuguese) == "9 meses")
        #expect(VaccinationTiming.months(1).label(.portuguese) == "1 mês")
        #expect(VaccinationTiming.atBirth.label(.portuguese) == "Nascimento")
    }

    @Test("Russian plural forms")
    func russianPlurals() {
        #expect(VaccinationTiming.months(1).label(.russian) == "1 месяц")
        #expect(VaccinationTiming.months(3).label(.russian) == "3 месяца")
        #expect(VaccinationTiming.months(9).label(.russian) == "9 месяцев")
    }
}

@Suite("VaccinationScheduleItem")
struct VaccinationScheduleItemTests {

    @Test("name(for:) returns the localized value, falling back to English")
    func nameLookup() {
        let item = VaccinationScheduleItem(
            id: 1, en: "BCG", ru: "БЦЖ", de: "BCG", es: "BCG", fr: "BCG", pt: "BCG (tuberculose)", zh: "卡介苗", timing: .atBirth
        )
        #expect(item.name(for: .russian) == "БЦЖ")
        #expect(item.name(for: .english) == "BCG")
        #expect(item.name(for: .french) == "BCG")
        #expect(item.name(for: .portuguese) == "BCG (tuberculose)")
        #expect(item.name(for: .chinese) == "卡介苗")
    }

    @Test("name(for:) of a custom synthetic item falls back to English for any language")
    func customNameFallback() {
        let item = VaccinationScheduleItem(
            id: -42, names: [.english: "Flu shot"], timing: .additional, isOptional: false
        )
        #expect(item.name(for: .german) == "Flu shot")
        #expect(item.name(for: .russian) == "Flu shot")
    }
}

@Suite("Vaccination schedule definitions")
struct VaccinationScheduleDefinitionTests {
    private var defs: [VaccinationScheduleDefinition] {
        Array(VaccinationScheduleResolver.definitions.values)
    }

    @Test("every definition cites a publishable source on its publisher's host")
    func sourcesArePublishable() throws {
        for def in defs {
            #expect(CitationPolicy.isPublishable([def.sourceID]), "\(def.key)")
            let source = try #require(MedicalSourceCatalog.source(def.sourceID))
            let url = try #require(source.url, "\(def.key)")
            #expect(url.host == source.publisher.allowedHost, "\(def.key)")
            if let prefix = source.publisher.allowedPathPrefix {
                #expect(url.path.hasPrefix(prefix), "\(def.key)")
            }
            #expect(def.key == VaccinationScheduleResolver.definitions.first { $0.value.key == def.key }?.key)
        }
    }

    @Test("item ids stay inside their range, are globally unique, ranges don't overlap")
    func idsNamespaced() {
        var all: [Int] = []
        for def in defs {
            #expect(!def.items.isEmpty, "\(def.key)")
            for item in def.items { #expect(def.idRange.contains(item.id), "\(def.key) \(item.id)") }
            all += def.items.map(\.id)
        }
        #expect(Set(all).count == all.count)
        let ranges = defs.map(\.idRange)
        for (i, r) in ranges.enumerated() {
            for other in ranges[(i + 1)...] { #expect(!r.overlaps(other)) }
        }
    }

    @Test("every item is named in all 7 languages")
    func allLanguages() {
        for def in defs {
            for item in def.items {
                for lang in [Language.english, .russian, .german, .spanish, .french, .portuguese, .chinese] {
                    #expect(!(item.names[lang] ?? "").isEmpty, "\(def.key) \(item.id) \(lang)")
                }
            }
        }
    }

    @Test("definitions are keyed by their own key, WHO range unchanged")
    func keysConsistent() {
        for (key, def) in VaccinationScheduleResolver.definitions { #expect(key == def.key) }
        #expect(WHOSchedule.definition.idRange == 100...199)
        let ids = WHOSchedule.items.map(\.id)
        #expect(ids.allSatisfy { $0 >= 100 })
        #expect(Set(ids).count == ids.count)
    }
}

@Suite("VaccinationScheduleResolver")
struct VaccinationScheduleResolverTests {
    private func resolver(region: String?) -> VaccinationScheduleResolver {
        var r = VaccinationScheduleResolver()
        r.regionProvider = { region }
        return r
    }

    @Test("nil key auto-detects DE to STIKO when registered, else WHO")
    func autoDetectDE() {
        let key = resolver(region: "DE").definition(for: BabyProfile()).key
        let expected: VaccinationScheduleKey = VaccinationScheduleResolver.definitions[.deSTIKO] != nil ? .deSTIKO : .who
        #expect(key == expected)
    }

    @Test("CN, JP and unregistered regions fall back to WHO")
    func unsupportedRegions() {
        #expect(resolver(region: "CN").definition(for: nil).key == .who)
        #expect(resolver(region: "JP").definition(for: nil).key == .who)
        #expect(resolver(region: "GB").definition(for: nil).key == .who)
        #expect(resolver(region: nil).definition(for: nil).key == .who)
    }

    @Test("stored key wins over region; unknown rawValue falls back to auto without crashing")
    func storedKey() {
        let r = resolver(region: "DE")
        #expect(r.definition(for: BabyProfile(vaccinationScheduleKey: "who")).key == .who)
        #expect(r.definition(for: BabyProfile(vaccinationScheduleKey: "xxFuture")).key
                == r.definition(for: BabyProfile()).key)
    }

    @Test("availableKeys lists only registered schedules and item(forCatalogId:) finds the owner")
    func lookup() {
        let r = VaccinationScheduleResolver()
        #expect(Set(r.availableKeys) == Set(VaccinationScheduleResolver.definitions.keys))
        #expect(r.item(forCatalogId: 100)?.key == .who)
        #expect(r.item(forCatalogId: 999) == nil)
        #expect(r.item(forCatalogId: -5) == nil)
    }
}

@Suite("BabyProfile schedule key persistence")
struct BabyProfileScheduleKeyTests {
    @Test("P0: legacy JSON without vaccinationScheduleKey still decodes")
    func legacyPayloadDecodes() throws {
        let json = """
        [{"id":"6F9619FF-8B86-D011-B42D-00C04FC964FF","name":"Mia","birthDate":0,"stage":"newborn","gender":"girl"}]
        """
        let babies = try JSONDecoder().decode([BabyProfile].self, from: Data(json.utf8))
        #expect(babies.count == 1)
        #expect(babies[0].name == "Mia")
        #expect(babies[0].vaccinationScheduleKey == nil)
    }

    @Test("round-trip keeps the stored key")
    func roundTrip() throws {
        let baby = BabyProfile(name: "Leo", vaccinationScheduleKey: "deSTIKO")
        let decoded = try JSONDecoder().decode(BabyProfile.self, from: JSONEncoder().encode(baby))
        #expect(decoded == baby)
        #expect(decoded.vaccinationScheduleKey == "deSTIKO")
    }

    @Test("DTO maps the key both ways, nil stays nil")
    func dto() {
        #expect(BabyProfileDTO(from: BabyProfile()).domain.vaccinationScheduleKey == nil)
        let dto = BabyProfileDTO(from: BabyProfile(vaccinationScheduleKey: "deSTIKO"))
        #expect(dto.vaccinationScheduleKey == "deSTIKO")
        #expect(dto.domain.vaccinationScheduleKey == "deSTIKO")
    }
}

private final class InMemoryVaccinationRepository: VaccinationRepository {
    var entries: [VaccinationEntry]
    init(_ entries: [VaccinationEntry]) { self.entries = entries }
    func getAll() async throws -> [VaccinationEntry] { entries }
    func save(_ entry: VaccinationEntry) async throws { entries.append(entry) }
    func upsert(_ entries: [VaccinationEntry]) async throws { self.entries += entries }
    func delete(id: UUID) async throws { entries.removeAll { $0.id == id } }
    func applyDeletions(_ ids: Set<UUID>) async throws { entries.removeAll { ids.contains($0.id) } }
}

/// Fixed active schedule; other catalog ids resolve through the real registry.
private struct MockVaccinationScheduleResolver: VaccinationScheduleResolving {
    var active: VaccinationScheduleDefinition
    var availableKeys: [VaccinationScheduleKey] { VaccinationScheduleResolver().availableKeys }
    func definition(for baby: BabyProfile?) -> VaccinationScheduleDefinition { active }
    func item(forCatalogId id: Int) -> (item: VaccinationScheduleItem, key: VaccinationScheduleKey)? {
        VaccinationScheduleResolver().item(forCatalogId: id)
    }
}

@Suite("Done-marks from another schedule")
struct ForeignVaccinationStatusTests {
    private var otherSchedule: VaccinationScheduleDefinition {
        VaccinationScheduleResolver.definitions.values.first { $0.key != .who }!
    }

    @Test("WHO mark stays visible under Additional with origin caption on another schedule")
    func foreignMarkVisible() async {
        let whoEntry = VaccinationEntry(id: UUID(), catalogId: 100, doneDate: Date(), notes: "")
        let custom = VaccinationEntry(id: UUID(), catalogId: -1, doneDate: Date(), notes: "", customName: "Flu")
        let activeId = otherSchedule.items[0].id
        let activeEntry = VaccinationEntry(id: UUID(), catalogId: activeId, doneDate: Date(), notes: "")
        let useCase = GetVaccinationStatusUseCase(
            repository: InMemoryVaccinationRepository([whoEntry, custom, activeEntry]),
            resolver: MockVaccinationScheduleResolver(active: otherSchedule)
        )
        let statuses = await useCase.execute(baby: BabyProfile())

        let foreign = statuses.first { $0.entry?.id == whoEntry.id }
        #expect(foreign != nil)
        #expect(foreign?.item.timing == .additional)
        #expect(foreign?.isDone == true)
        #expect(foreign?.originKey == .who)
        #expect(statuses.first { $0.entry?.id == custom.id }?.originKey == nil)
        #expect(statuses.first { $0.entry?.id == activeEntry.id }?.originKey == nil)
    }

    @Test("unresolvable ids are skipped, not crashed on")
    func unresolvable() async {
        let orphan = VaccinationEntry(id: UUID(), catalogId: 950, doneDate: Date(), notes: "")
        let useCase = GetVaccinationStatusUseCase(
            repository: InMemoryVaccinationRepository([orphan]),
            resolver: MockVaccinationScheduleResolver(active: WHOSchedule.definition)
        )
        let statuses = await useCase.execute(baby: nil)
        #expect(statuses.count == WHOSchedule.items.count)
    }
}

private struct UnusedEraser: CloudAccountEraser {
    struct Unused: Error {}
    func deleteCloudData(uid: String, familyIdHint: String?) async throws -> AccountErasureOutcome { throw Unused() }
    func isCloudDataPresent(uid: String) async throws -> Bool { throw Unused() }
}

private final class UnusedAuth: AccountAuthProtocol {
    var currentUID: String? { nil }
    func deleteAccount(expectedUID: String) async throws {}
}

@MainActor
private final class NoDeletionAuthenticator: AccountDeletionAuthenticating {
    var accountDeletionProvider: AccountDeletionProvider? { nil }
    func prepareAppleDeletionRequest(_ request: ASAuthorizationAppleIDRequest) {}
    func reauthenticateForDeletionWithApple(_ result: Result<ASAuthorization, Error>) async throws {}
    func reauthenticateForDeletionWithGoogle() async throws {}
}

private struct FixedPreferences: UserPreferencesRepository {
    func load() -> UserPreferences { UserPreferences(appTheme: "system", appLanguage: "en", unitSystem: "metric") }
    func save(_ prefs: UserPreferences) {}
}

@Suite("Settings schedule selection")
@MainActor
struct SettingsScheduleSelectionTests {
    private final class Calls {
        var updated: [BabyProfile] = []
        var cancelled: [Int] = []
        var failUpdate = false
    }
    private struct SaveFailed: Error {}

    private func makeVM(access: PremiumAccessState, canEdit: Bool = true,
                        calls: Calls) -> SettingsViewModel {
        let defaults = UserDefaults(suiteName: "SettingsScheduleSelectionTests.\(UUID().uuidString)")!
        let baby = BabyProfile(name: "Leo", vaccinationScheduleKey: "who")
        return SettingsViewModel(
            repo: FixedPreferences(),
            deleteAccount: DeleteAccountUseCase(
                cloudEraser: UnusedEraser(), auth: UnusedAuth(),
                pendingStore: UserDefaultsPendingAccountDeletionStore(defaults: defaults),
                pendingAuthStore: UserDefaultsPendingAuthAccountDeletionStore(defaults: defaults),
                suppressedRestoreStore: UserDefaultsSuppressedFamilyRestoreStore(defaults: defaults),
                eraseLocal: {}
            ),
            accountAuth: NoDeletionAuthenticator(),
            cloudSyncEnabled: false,
            updateCloudSync: { _ in },
            activeBaby: { baby },
            updateBaby: { profile in
                if calls.failUpdate { throw SaveFailed() }
                calls.updated.append(profile)
            },
            canEditBaby: { canEdit },
            accessState: { access },
            cancelVaccinationReminders: { calls.cancelled += $0 },
            scheduleResolver: VaccinationScheduleResolver()
        )
    }

    private var otherKey: VaccinationScheduleKey {
        VaccinationScheduleResolver().availableKeys.first { $0 != .who }!
    }

    @Test("requiresPurchase never writes the child")
    func paywalled() async {
        let calls = Calls()
        let vm = makeVM(access: .requiresPurchase, calls: calls)
        await vm.selectSchedule(otherKey)
        #expect(calls.updated.isEmpty)
        #expect(vm.scheduleKey == .who)
    }

    @Test("non-parent role never writes the child")
    func readOnlyRole() async {
        let calls = Calls()
        let vm = makeVM(access: .premium, canEdit: false, calls: calls)
        await vm.selectSchedule(otherKey)
        #expect(calls.updated.isEmpty)
        #expect(!vm.canEditSchedule)
    }

    @Test("premium parent saves once with the new key and cancels old reminders")
    func premiumParent() async {
        let calls = Calls()
        let vm = makeVM(access: .premium, calls: calls)
        await vm.selectSchedule(otherKey)
        #expect(calls.updated.count == 1)
        #expect(calls.updated.first?.vaccinationScheduleKey == otherKey.rawValue)
        #expect(vm.scheduleKey == otherKey)
        #expect(vm.scheduleSourceID == VaccinationScheduleResolver.definitions[otherKey]?.sourceID)
        #expect(Set(calls.cancelled) == Set(WHOSchedule.items.map(\.id)))
    }

    @Test("failed save rolls the key back and surfaces the error")
    func rollback() async {
        let calls = Calls()
        calls.failUpdate = true
        let vm = makeVM(access: .premium, calls: calls)
        await vm.selectSchedule(otherKey)
        #expect(vm.scheduleKey == .who)
        #expect(vm.scheduleError != nil)
        #expect(calls.cancelled.isEmpty)
    }
}

@Suite("Legacy RU → WHO migration map")
struct VaccinationMigrationMapTests {

    @Test("every legacy RU id (1...20) maps to a WHO id")
    func coversAllLegacyIds() {
        for ru in 1...20 {
            #expect(UserDefaultsMigration.legacyRUToWHO[ru] != nil)
        }
    }

    @Test("all mapped targets are real WHO schedule ids")
    func targetsAreValidWHOIds() {
        let whoIds = Set(WHOSchedule.items.map(\.id))
        for target in UserDefaultsMigration.legacyRUToWHO.values {
            #expect(whoIds.contains(target))
        }
    }
}
