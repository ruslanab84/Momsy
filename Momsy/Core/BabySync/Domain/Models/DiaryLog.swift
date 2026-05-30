import Foundation

struct DiaryLog: Identifiable, Equatable {
    let id: String
    let date: Date
    let kind: String
    let text: String
    let iconName: String
    let addedBy: String
    let addedByName: String
}
