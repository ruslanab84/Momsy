import SwiftData
import Foundation

@MainActor
final class SwiftDataMomSleepRepository: MomSleepRepository {
    private static let pendingOwnerUID = "__momsy_local_pending_owner__"
    private let context: ModelContext
    private let currentUID: () -> String?

    init(context: ModelContext, currentUID: @escaping () -> String? = { nil }) {
        self.context = context
        self.currentUID = currentUID
    }

    func getEntries(from: Date, to: Date) async throws -> [SleepEntry] {
        let scope = ActiveBaby.scope
        let ownerUID = try resolvedOwnerUID()
        var descriptor = FetchDescriptor<MomSleepRecord>(
            predicate: #Predicate {
                $0.startDate >= from && $0.startDate <= to
                    && $0.babyId == scope && $0.ownerUID == ownerUID
            }
        )
        descriptor.sortBy = [SortDescriptor(\.startDate)]
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func add(_ entry: SleepEntry) async throws {
        context.insert(MomSleepRecord(entry, ownerUID: try resolvedOwnerUID()))
        try context.save()
    }

    func update(_ entry: SleepEntry) async throws {
        let id = entry.id
        let ownerUID = try resolvedOwnerUID()
        var descriptor = FetchDescriptor<MomSleepRecord>(
            predicate: #Predicate { $0.id == id && $0.ownerUID == ownerUID }
        )
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            record.apply(entry)
            try context.save()
        }
    }

    func upsert(_ entries: [SleepEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let byId = Dictionary(
            try context.fetch(
                FetchDescriptor<MomSleepRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
            ).map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        var changed = false
        for entry in entries {
            let record = byId[entry.id]
            switch SyncMerge.decide(localExists: record != nil,
                                    localUpdatedAt: record?.updatedAt,
                                    incomingUpdatedAt: entry.updatedAt) {
            case .insert:
                context.insert(MomSleepRecord(entry, ownerUID: currentUID() ?? Self.pendingOwnerUID))
                changed = true
            case .update: record?.merge(entry); changed = true
            case .skip:
                if let record, record.ownerUID.isEmpty, let ownerUID = entry.startedBy {
                    record.ownerUID = ownerUID
                    record.ownerName = entry.startedByName ?? ""
                    changed = true
                }
            }
        }
        if changed { try context.save() }
    }

    func delete(id: UUID) async throws {
        let ownerUID = try resolvedOwnerUID()
        var descriptor = FetchDescriptor<MomSleepRecord>(
            predicate: #Predicate { $0.id == id && $0.ownerUID == ownerUID }
        )
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            context.delete(record)
            try context.save()
        }
    }

    private func resolvedOwnerUID() throws -> String {
        guard let ownerUID = currentUID(), !ownerUID.isEmpty else {
            return Self.pendingOwnerUID
        }
        let pendingOwnerUID = Self.pendingOwnerUID
        let records = try context.fetch(
            FetchDescriptor<MomSleepRecord>(
                predicate: #Predicate { $0.ownerUID == pendingOwnerUID }
            )
        )
        guard !records.isEmpty else { return ownerUID }
        records.forEach { $0.ownerUID = ownerUID }
        try context.save()
        return ownerUID
    }
}
