import Foundation

final class FeedingTimerService {
    private var task: Task<Void, Never>?

    func start(from startDate: Date, onTick: @escaping @Sendable (Int) -> Void) {
        stop()
        task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 500_000_000)
                guard !Task.isCancelled else { return }
                let elapsed = Int(Date().timeIntervalSince(startDate))
                onTick(max(0, elapsed))
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }
}
