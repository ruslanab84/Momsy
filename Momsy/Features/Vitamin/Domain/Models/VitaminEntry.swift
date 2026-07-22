import Foundation

struct VitaminEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var label: String
}
