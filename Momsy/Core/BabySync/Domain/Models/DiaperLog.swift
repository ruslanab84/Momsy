import Foundation

enum DiaperType: String, Codable {
    case wet    = "wet"
    case dirty  = "dirty"
    case both   = "both"
}

struct DiaperLog: Identifiable, Equatable {
    let id: String
    let loggedAt: Date
    let type: DiaperType
    let addedBy: String
    let addedByName: String
}
