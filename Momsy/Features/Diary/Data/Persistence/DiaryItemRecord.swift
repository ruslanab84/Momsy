import SwiftData
import Foundation

@Model
final class DiaryItemRecord {
    var id: UUID = UUID()
    var date: Date = Date()
    var kindRaw: String = ""
    var text: String = ""
    var toneHex: String = ""
    var isMilestone: Bool = false
    var iconName: String = ""
    var photoPath: String?

    init(_ item: StoredDiaryItem) {
        id          = item.id
        date        = item.date
        kindRaw     = item.kind.rawValue
        text        = item.text
        toneHex     = item.toneHex
        isMilestone = item.isMilestone
        iconName    = item.iconName
        photoPath   = item.photoPath
    }

    func toDomain() -> StoredDiaryItem {
        StoredDiaryItem(
            id: id, date: date,
            kind: StoredDiaryItemKind(rawValue: kindRaw) ?? .note,
            text: text, toneHex: toneHex, isMilestone: isMilestone,
            iconName: iconName, photoPath: photoPath
        )
    }
}
