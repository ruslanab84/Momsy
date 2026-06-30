import Foundation

struct QuickEventLog: Identifiable, Equatable {
    let id: String
    let kind: String
    let loggedAt: Date
    let label: String
    let startDate: Date?
    let endDate: Date?
    let addedBy: String
    let addedByName: String

    init(
        id: String,
        kind: String,
        loggedAt: Date,
        label: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        addedBy: String,
        addedByName: String
    ) {
        self.id = id
        self.kind = kind
        self.loggedAt = loggedAt
        self.label = label
        self.startDate = startDate
        self.endDate = endDate
        self.addedBy = addedBy
        self.addedByName = addedByName
    }
}
