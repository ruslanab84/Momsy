import SwiftData
import Foundation

@Model
final class LeapProgressRecord {
    var leapID: Int = 0
    var babyId: UUID = ActiveBaby.unassigned
    var isDone: Bool = false
    var completedDate: Date?

    init(_ progress: LeapProgress) {
        leapID        = progress.id
        babyId        = ActiveBaby.scope
        isDone        = progress.isDone
        completedDate = progress.completedDate
    }

    func toDomain() -> LeapProgress {
        LeapProgress(id: leapID, isDone: isDone, completedDate: completedDate)
    }
}
