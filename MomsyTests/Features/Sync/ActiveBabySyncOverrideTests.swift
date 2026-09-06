import Testing
import Foundation
import SwiftData
@testable import Momsy

/// The roster download retargets the sync path per child via a task-local override
/// (`ActiveBaby.syncTargetOverride`). The override is scoped to the sync's own task tree:
/// reads inside it follow the target, while a concurrent user write — running in a
/// separate task tree — never inherits it, so a new log can't be misattributed to
/// whichever child the loop is mid-processing.
///
/// These assert the task-local behaviour directly rather than the persisted selection,
/// so they stay deterministic under Swift Testing's parallel execution (a `@TaskLocal`
/// is per-task-tree, never the shared `UserDefaults.standard` other suites mutate).
@Suite("ActiveBabySyncOverride", .serialized)
struct ActiveBabySyncOverrideTests {

    @Test @MainActor
    func fetchedRecordsKeepTheirBabyAfterSelectionChanges() async throws {
        let previousBaby = ActiveBaby.currentId
        let suite = "ActiveBabySyncOverrideTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer {
            ActiveBaby.currentId = previousBaby
            defaults.removePersistentDomain(forName: suite)
        }
        let container = AppContainer()
        let watermarks = SyncWatermarkStore(defaults: defaults)
        let downloader = CloudSyncDownloader(
            service: BabySyncService(),
            feedingRepo: container.feedingRepository,
            sleepRepo: container.sleepRepository,
            diaperRepo: container.diaperRepository,
            stoolRepo: container.stoolRepository,
            diaryRepo: container.diaryRepository,
            walkRepo: container.walkRepository,
            bathRepo: container.bathRepository,
            pumpingRepo: container.pumpingRepository,
            vitaminRepo: container.vitaminRepository,
            measurementRepo: container.measurementRepository,
            vaccinationRepo: container.vaccinationRepository,
            foodDiaryRepo: container.complementaryFeedingRepository,
            quickLogRepo: container.quickLogRepository,
            babyRepo: container.babyRepository,
            temperatureRepo: container.temperatureRepository,
            momSleepRepo: container.momSleepRepository,
            waterIntakeRepo: container.waterIntakeRepository,
            leapsRepo: container.leapsRepository,
            doctorVisitRepo: container.doctorVisitRepository,
            watermarks: watermarks
        )
        let babyA = UUID(), babyB = UUID()
        let entry = FeedingEntry(durationSeconds: 60, updatedAt: Date(timeIntervalSince1970: 2_000))
        let fetched = CloudSyncDownloader.PendingFetch(
            dtos: [entry], familyId: "family", babyId: babyA.uuidString,
            collection: "feedingLogs", commitTo: entry.updatedAt
        )
        ActiveBaby.currentId = babyB
        await downloader.merge(fetched, map: { $0 }) { entries in
            await Task.yield()
            try await container.feedingRepository.upsert(entries)
        }

        let records = try container.modelContainer.mainContext.fetch(FetchDescriptor<FeedingRecord>())
        #expect(records.count == 1)
        #expect(records.first?.babyId == babyA)
        #expect(ActiveBaby.currentId == babyB)
        #expect(watermarks.watermark(family: "family", baby: babyA.uuidString,
                                     collection: "feedingLogs") == entry.updatedAt)
        #expect(watermarks.watermark(family: "family", baby: babyB.uuidString,
                                     collection: "feedingLogs") == nil)
    }

    @Test func overrideRetargetsCurrentIdAndScopeWithinTheBinding() async {
        let syncTarget = UUID()
        await ActiveBaby.$syncTargetOverride.withValue(syncTarget) {
            #expect(ActiveBaby.currentId == syncTarget)
            #expect(ActiveBaby.scope == syncTarget)
        }
        // Binding is popped once the child's sync span ends; the override no longer applies.
        #expect(ActiveBaby.syncTargetOverride == nil)
    }

    @Test func concurrentTaskTreeDoesNotInheritTheOverride() async {
        let syncTarget = UUID()
        await ActiveBaby.$syncTargetOverride.withValue(syncTarget) {
            // A detached task models a user-initiated write running while the roster sync
            // holds the override. It must NOT inherit the binding, so its path/scope reads
            // fall through to the user's real selection rather than the sync target.
            let inheritedOverride = await Task.detached { ActiveBaby.syncTargetOverride }.value
            #expect(inheritedOverride == nil)
        }
    }
}
