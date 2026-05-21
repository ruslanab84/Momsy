import Foundation

enum StoredDiaryItemKind: String, Codable {
    case photo, note, milestone
}

struct StoredDiaryItem: Identifiable, Codable {
    var id: UUID
    var date: Date
    var kind: StoredDiaryItemKind
    var text: String
    var toneHex: String
    var isMilestone: Bool
    var iconName: String
    var photoPath: String?

    init(id: UUID = UUID(), date: Date = Date(), kind: StoredDiaryItemKind,
         text: String = "", toneHex: String = "FFC0CB",
         isMilestone: Bool = false, iconName: String = "heart",
         photoPath: String? = nil) {
        self.id = id
        self.date = date
        self.kind = kind
        self.text = text
        self.toneHex = toneHex
        self.isMilestone = isMilestone
        self.iconName = iconName
        self.photoPath = photoPath
    }
}
