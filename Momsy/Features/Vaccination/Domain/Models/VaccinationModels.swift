import Foundation

struct VaccinationScheduleItem: Identifiable {
    let id: Int
    let nameEN: String
    let nameRU: String
    let nameDE: String
    let ageMonths: Int
    let isOptional: Bool
}

struct VaccinationEntry: Identifiable {
    var id: UUID
    var catalogId: Int
    var doneDate: Date
    var notes: String
    var customName: String?

    var isCustom: Bool { customName != nil }
}

struct VaccinationStatus: Identifiable {
    let item: VaccinationScheduleItem
    let entry: VaccinationEntry?
    let dueDate: Date

    var id: Int { item.id }
    var isDone: Bool { entry != nil }
    var isOverdue: Bool { !isDone && dueDate < Date() }
}
