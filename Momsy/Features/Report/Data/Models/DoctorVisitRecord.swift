import SwiftData
import Foundation

@Model
final class DoctorVisitRecord {
    var id: UUID
    var date: Date

    init(id: UUID, date: Date) {
        self.id = id
        self.date = date
    }

    func toDomain() -> DoctorVisit {
        DoctorVisit(id: id, date: date)
    }
}
