import Foundation

enum RecordLeapSkillError: Error {
    case emptySkill
}

final class RecordLeapSkillUseCase {
    private let addDiaryEntry: AddDiaryEntryUseCase
    private let syncRepo: any BabySyncRepositoryProtocol

    init(
        addDiaryEntry: AddDiaryEntryUseCase,
        syncRepo: any BabySyncRepositoryProtocol
    ) {
        self.addDiaryEntry = addDiaryEntry
        self.syncRepo = syncRepo
    }

    @discardableResult
    func execute(skill: String, date: Date = Date()) async throws -> StoredDiaryItem {
        let label = skill.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !label.isEmpty else { throw RecordLeapSkillError.emptySkill }

        let item = StoredDiaryItem(
            date: date,
            kind: .milestone,
            text: label,
            isMilestone: true,
            iconName: "star"
        )
        try await addDiaryEntry.execute(item)

        let log = DiaryLog(
            id: item.id.uuidString,
            date: item.date,
            kind: item.kind.rawValue,
            text: item.text,
            iconName: item.iconName,
            addedBy: "",
            addedByName: ""
        )
        try? await syncRepo.addDiaryLog(log)
        return item
    }
}
