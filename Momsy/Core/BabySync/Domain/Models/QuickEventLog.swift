import Foundation

struct QuickEventLog: Identifiable, Equatable {
    let id: String
    let kind: String
    let loggedAt: Date
    let label: String
    let addedBy: String
    let addedByName: String
}
