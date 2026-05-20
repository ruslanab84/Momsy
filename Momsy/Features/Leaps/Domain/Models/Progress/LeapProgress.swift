import Foundation

struct LeapProgress: Identifiable, Codable {
    var id: Int  // matches DevelopmentLeap.id
    var isDone: Bool
    var completedDate: Date?

    init(id: Int, isDone: Bool = false, completedDate: Date? = nil) {
        self.id = id
        self.isDone = isDone
        self.completedDate = completedDate
    }
}
