import SwiftUI

enum DiaryItemType {
    case photo(tone: Color, handwriting: String, isMilestone: Bool)
    case note(text: String)
    case milestone(icon: BlobKind, label: String)
}

struct DiaryItem: Identifiable {
    let id = UUID()
    let type: DiaryItemType
}

struct DiaryDay: Identifiable {
    var id: String { dateLabel }
    let dateLabel: String
    let ageLabel: String
    var items: [DiaryItem]
}

let sampleDiary: [DiaryDay] = [
    DiaryDay(dateLabel: "Today · Tue", ageLabel: "4 mo 12 d", items: [
        DiaryItem(type: .photo(tone: .bbCoral, handwriting: "First time\nrolled over!", isMilestone: true)),
        DiaryItem(type: .note(text: "Smiled a long time at grandpa on video call.")),
    ]),
    DiaryDay(dateLabel: "Yesterday · Mon", ageLabel: "4 mo 11 d", items: [
        DiaryItem(type: .milestone(icon: .star, label: "Holds head up for 30 sec")),
        DiaryItem(type: .photo(tone: .bbButter, handwriting: "morning\nin arms", isMilestone: false)),
    ]),
    DiaryDay(dateLabel: "Sat 13 May", ageLabel: "4 mo 9 d", items: [
        DiaryItem(type: .photo(tone: .bbMint, handwriting: "bath time", isMilestone: false)),
        DiaryItem(type: .note(text: "Temperature 37.8° by night. Drooling — teething?")),
        DiaryItem(type: .photo(tone: .bbLilac, handwriting: "falling asleep", isMilestone: false)),
    ]),
]
