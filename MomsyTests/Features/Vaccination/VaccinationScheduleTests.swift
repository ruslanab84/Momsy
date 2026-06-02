import Testing
@testable import Momsy
import Foundation

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
        // Portuguese falls back to English.
        #expect(VaccinationTiming.months(9).label(.portuguese) == "9 months")
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
            id: 1, en: "BCG", ru: "БЦЖ", de: "BCG", es: "BCG", timing: .atBirth
        )
        #expect(item.name(for: .russian) == "БЦЖ")
        #expect(item.name(for: .english) == "BCG")
        // Portuguese isn't in the dictionary → English fallback.
        #expect(item.name(for: .portuguese) == "BCG")
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

@Suite("VaccinationScheduleProvider")
struct VaccinationScheduleProviderTests {

    @Test("WHO is populated and autoDetect always resolves to a populated schedule")
    func autoDetectClamped() {
        #expect(VaccinationScheduleProvider.populated.contains(.who))
        #expect(VaccinationScheduleProvider.populated.contains(VaccinationScheduleProvider.autoDetect()))
    }

    @Test("WHO schedule ids are namespaced in the 100+ range and unique")
    func whoIdsNamespaced() {
        let ids = WHOSchedule.items.map(\.id)
        #expect(ids.allSatisfy { $0 >= 100 })
        #expect(Set(ids).count == ids.count)
        #expect(!WHOSchedule.items.isEmpty)
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
