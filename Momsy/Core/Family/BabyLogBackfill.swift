import SwiftData
import Foundation

/// One-time migration that attributes legacy (pre-multi-child) log records to the
/// first child, plus the cascade-delete used when a child is removed. Both walk the
/// same set of `BabyScoped` SwiftData models, parameterised by what to do with a match.
enum BabyLogBackfill {
    private static let flagKey = "babyLogBackfill_v1_done"

    /// Stamp every `unassigned` log record with child #1's id. No-op (and not marked
    /// done) until a baby exists, so a fresh install doesn't lock in the flag before
    /// onboarding creates the first child.
    @MainActor
    static func run(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: flagKey) else { return }

        let targetId: UUID
        if let active = ActiveBaby.currentId {
            targetId = active
        } else {
            var descriptor = FetchDescriptor<BabyRecord>(sortBy: [SortDescriptor(\.birthDate)])
            descriptor.fetchLimit = 1
            guard let first = try? context.fetch(descriptor).first else { return }
            targetId = first.id
            ActiveBaby.currentId = targetId
        }

        applyAll(match: ActiveBaby.unassigned, reassignTo: targetId, context: context)
        try? context.save()
        UserDefaults.standard.set(true, forKey: flagKey)
    }

    /// Remove every log belonging to a deleted child. Caller saves the context.
    @MainActor
    static func deleteLogs(forBaby id: UUID, context: ModelContext) {
        applyAll(match: id, reassignTo: nil, context: context)
    }

    @MainActor
    private static func applyAll(match: UUID, reassignTo newId: UUID?, context: ModelContext) {
        apply(SleepRecord.self,             match: match, reassignTo: newId, context: context)
        apply(FeedingRecord.self,           match: match, reassignTo: newId, context: context)
        apply(DiaperRecord.self,            match: match, reassignTo: newId, context: context)
        apply(StoolRecord.self,             match: match, reassignTo: newId, context: context)
        apply(DiaryItemRecord.self,         match: match, reassignTo: newId, context: context)
        apply(PumpingRecord.self,           match: match, reassignTo: newId, context: context)
        apply(WalkRecord.self,              match: match, reassignTo: newId, context: context)
        apply(BathRecord.self,              match: match, reassignTo: newId, context: context)
        apply(VaccinationRecord.self,       match: match, reassignTo: newId, context: context)
        apply(MeasurementRecord.self,       match: match, reassignTo: newId, context: context)
        apply(TemperatureRecord.self,       match: match, reassignTo: newId, context: context)
        apply(DoctorVisitRecord.self,       match: match, reassignTo: newId, context: context)
        apply(ComplementaryFoodRecord.self, match: match, reassignTo: newId, context: context)
        apply(MomSleepRecord.self,          match: match, reassignTo: newId, context: context)
        apply(MomMoodRecord.self,           match: match, reassignTo: newId, context: context)
        apply(WaterIntakeRecord.self,       match: match, reassignTo: newId, context: context)
        apply(LeapProgressRecord.self,      match: match, reassignTo: newId, context: context)
    }

    /// Fetches all rows of `T` and reassigns or deletes those matching `match`.
    /// In-memory filtering (rather than a `#Predicate`) keeps this generic over the
    /// `BabyScoped` protocol property, which the predicate macro cannot express.
    @MainActor
    private static func apply<T: PersistentModel & BabyScoped>(
        _ type: T.Type, match: UUID, reassignTo newId: UUID?, context: ModelContext
    ) {
        let records = (try? context.fetch(FetchDescriptor<T>())) ?? []
        for record in records where record.babyId == match {
            if let newId { record.babyId = newId } else { context.delete(record) }
        }
    }
}
