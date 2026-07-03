import Foundation

final class SleepTimerUseCase {
    func start(
        seconds: Int,
        onTick: @escaping @Sendable (Int) -> Void,
        onFinish: @escaping @Sendable () -> Void
    ) -> Task<Void, Never> {
        Task {
            let deadline = Date().addingTimeInterval(TimeInterval(seconds))
            while !Task.isCancelled {
                let remaining = Int(deadline.timeIntervalSinceNow.rounded())
                guard remaining > 0 else { break }
                onTick(remaining)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            if !Task.isCancelled { onFinish() }
        }
    }
}
