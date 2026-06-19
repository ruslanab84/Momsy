import SwiftData
import Foundation

@Model
final class DiaryItemRecord {
    var id: UUID = UUID()
    var babyId: UUID = ActiveBaby.unassigned
    var date: Date = Date()
    var kindRaw: String = ""
    var text: String = ""
    var toneHex: String = ""
    var isMilestone: Bool = false
    var iconName: String = ""
    var photoPath: String?
    var updatedAt: Date?

    init(_ item: StoredDiaryItem) {
        id = item.id
        babyId = ActiveBaby.scope
        apply(item)
    }

    func apply(_ item: StoredDiaryItem) {
        date        = item.date
        kindRaw     = item.kind.rawValue
        text        = item.text
        toneHex     = item.toneHex
        isMilestone = item.isMilestone
        iconName    = item.iconName
        photoPath   = item.photoPath
        updatedAt   = item.updatedAt
    }

    /// Cloud-merge update: overwrites only the fields the synced DTO carries.
    /// `toneHex` and `photoPath` are local-only, so they are preserved.
    func merge(_ item: StoredDiaryItem) {
        date        = item.date
        kindRaw     = item.kind.rawValue
        text        = item.text
        isMilestone = item.isMilestone
        iconName    = item.iconName
        updatedAt   = item.updatedAt
    }

    func toDomain() -> StoredDiaryItem {
        StoredDiaryItem(
            id: id, date: date,
            kind: StoredDiaryItemKind(rawValue: kindRaw) ?? .note,
            text: text, toneHex: toneHex, isMilestone: isMilestone,
            iconName: iconName, photoPath: photoPath, updatedAt: updatedAt
        )
    }
}
