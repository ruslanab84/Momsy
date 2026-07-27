import Testing
import Foundation
@testable import Momsy

@Suite("AckLatch")
struct AckLatchTests {

    private struct Boom: Error {}

    @Test("the first completion wins and is delivered once")
    func firstWins() {
        var results: [Result<Void, Error>] = []
        let latch = AckLatch { results.append($0) }

        latch.finish(nil)
        latch.finish(Boom())
        latch.finish(nil)

        #expect(results.count == 1)
        #expect(latch.hasFinished)
        if case .failure = results[0] { Issue.record("expected success") }
    }

    @Test("an error delivered first is the reported outcome")
    func errorWins() {
        var results: [Result<Void, Error>] = []
        let latch = AckLatch { results.append($0) }

        latch.finish(Boom())
        latch.finish(nil)

        #expect(results.count == 1)
        guard case .failure(let error) = results[0] else {
            Issue.record("expected failure")
            return
        }
        #expect(error is Boom)
    }

    @Test("concurrent finishes still deliver exactly one outcome")
    func concurrentFinishes() async {
        let counter = Counter()
        let latch = AckLatch { _ in counter.increment() }

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<64 {
                group.addTask { latch.finish(nil) }
            }
        }

        #expect(counter.value == 1)
    }

    private final class Counter: @unchecked Sendable {
        private let lock = NSLock()
        private var count = 0
        var value: Int { lock.lock(); defer { lock.unlock() }; return count }
        func increment() { lock.lock(); count += 1; lock.unlock() }
    }
}
