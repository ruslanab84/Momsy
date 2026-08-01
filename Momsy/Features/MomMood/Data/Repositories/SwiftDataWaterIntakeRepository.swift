import SwiftData
import Foundation

@MainActor
final class SwiftDataWaterIntakeRepository: WaterIntakeRepository {
    private static let pendingOwnerUID = "__momsy_local_pending_owner__"
    private let context: ModelContext
    private let currentUID: () -> String?

    init(context: ModelContext, currentUID: @escaping () -> String? = { nil }) {
        self.context = context
        self.currentUID = currentUID
    }

    func add(_ entry: WaterIntakeEntry) async throws {
        context.insert(WaterIntakeRecord(entry, ownerUID: try resolvedOwnerUID()))
        try context.save()
    }

    func upsert(_ entries: [WaterIntakeEntry]) async throws {
        guard !entries.isEmpty else { return }
        let incomingIds = entries.map(\.id)
        let byId = Dictionary(
            try context.fetch(
                FetchDescriptor<WaterIntakeRecord>(predicate: #Predicate { incomingIds.contains($0.id) })
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
                context.insert(WaterIntakeRecord(entry, ownerUID: currentUID() ?? Self.pendingOwnerUID))
                changed = true
            case .update: record?.merge(entry); changed = true
            case .skip:
                if let record, record.ownerUID.isEmpty, !entry.ownerUID.isEmpty {
                    record.ownerUID = entry.ownerUID
                    record.ownerName = entry.ownerName
                    changed = true
                }
            }
        }
        if changed { try context.save() }
    }

    func getEntries(from: Date, to: Date) async throws -> [WaterIntakeEntry] {
        let scope = ActiveBaby.scope
        let ownerUID = try resolvedOwnerUID()
        var descriptor = FetchDescriptor<WaterIntakeRecord>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to
                    && $0.babyId == scope && $0.ownerUID == ownerUID
            }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    private func resolvedOwnerUID() throws -> String {
        guard let ownerUID = currentUID(), !ownerUID.isEmpty else {
            return Self.pendingOwnerUID
        }
        let pendingOwnerUID = Self.pendingOwnerUID
        let records = try context.fetch(
            FetchDescriptor<WaterIntakeRecord>(
                predicate: #Predicate { $0.ownerUID == pendingOwnerUID }
            )
        )
        guard !records.isEmpty else { return ownerUID }
        records.forEach { $0.ownerUID = ownerUID }
        try context.save()
        return ownerUID
    }
}
