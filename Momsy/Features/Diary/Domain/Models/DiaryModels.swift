import SwiftUI

enum DiaryItemType {
    case photo(tone: Color, handwriting: String, isMilestone: Bool)
    case note(text: String)
    case milestone(icon: BlobKind, label: String)
}

struct DiaryItem: Identifiable {
    let id: UUID
    let type: DiaryItemType

    init(id: UUID = UUID(), type: DiaryItemType) {
        self.id = id
        self.type = type
    }
}

struct DiaryDay: Identifiable {
    var id: String { dateLabel }
    let dateLabel: String
    let ageLabel: String
    var items: [DiaryItem]
}


