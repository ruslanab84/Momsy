import Foundation

struct VaccinationLog: Identifiable, Equatable {
    let id: String
    let catalogId: Int
    let doneDate: Date
    let vaccineName: String
    let notes: String
    let addedBy: String
    let addedByName: String
}
