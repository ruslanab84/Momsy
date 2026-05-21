import Foundation

final class FeedingTimerService {
    private var task: Task<Void, Never>?

    func start(onTick: @escaping @Sendable (Int) -> Void) {
        stop()
        task = Task {
            var seconds = 0
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                seconds += 1
                onTick(seconds)
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }
}
