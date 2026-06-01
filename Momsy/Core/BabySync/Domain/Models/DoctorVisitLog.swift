import Foundation

struct DoctorVisitLog: Identifiable, Equatable {
    let id: String
    let date: Date
    let addedBy: String
    let addedByName: String
}
