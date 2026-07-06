import Foundation

struct DevelopmentLeapDefinition: Identifiable, Equatable {
    let id: Int
    let week: Int
    let hardDays: Int
}

enum DevelopmentLeapSchedule {
    static let lookaheadWeeks = 1

    static let definitions: [DevelopmentLeapDefinition] = [
        .init(id: 1, week: 5, hardDays: 7),
        .init(id: 2, week: 8, hardDays: 7),
        .init(id: 3, week: 12, hardDays: 7),
        .init(id: 4, week: 17, hardDays: 28),
        .init(id: 5, week: 26, hardDays: 28),
        .init(id: 6, week: 36, hardDays: 35),
        .init(id: 7, week: 46, hardDays: 28),
        .init(id: 8, week: 55, hardDays: 35),
        .init(id: 9, week: 64, hardDays: 35),
        .init(id: 10, week: 75, hardDays: 35)
    ]

    static var weeks: [Int] {
        definitions.map(\.week)
    }

    static func definition(id: Int) -> DevelopmentLeapDefinition {
        guard let definition = definitions.first(where: { $0.id == id }) else {
            preconditionFailure("Missing development leap definition for id \(id)")
        }
        return definition
    }
}
