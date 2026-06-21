import Testing
import Foundation
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
@Suite("ActiveBabySyncOverride")
struct ActiveBabySyncOverrideTests {

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
