import SwiftData
import Foundation

@Model
final class LeapProgressRecord {
    var leapID: Int = 0
    var isDone: Bool = false
    var completedDate: Date?

    init(_ progress: LeapProgress) {
        leapID        = progress.id
        isDone        = progress.isDone
        completedDate = progress.completedDate
    }

    func toDomain() -> LeapProgress {
        LeapProgress(id: leapID, isDone: isDone, completedDate: completedDate)
    }
}
