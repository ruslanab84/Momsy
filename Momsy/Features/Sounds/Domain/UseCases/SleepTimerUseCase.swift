import Foundation

final class SleepTimerUseCase {
    func start(
        seconds: Int,
        onTick: @escaping @Sendable (Int) -> Void,
        onFinish: @escaping @Sendable () -> Void
    ) -> Task<Void, Never> {
        Task {
            var remaining = seconds
            while !Task.isCancelled, remaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                remaining -= 1
                onTick(remaining)
            }
            if !Task.isCancelled { onFinish() }
        }
    }
}
