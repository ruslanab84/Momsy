import Foundation

/// Ошибка ограниченного ожидания записи Firestore.
enum FirestoreAckError: LocalizedError {
    /// Запись поставлена в очередь, но бэкенд не подтвердил её за отведённое время.
    case notConfirmed

    var errorDescription: String? {
        LocalizationManager.shared.strings.inviteNotConfirmedMessage
    }
}

/// Однократная защёлка: доставляет исход ровно один раз, кто бы ни пришёл первым —
/// completion-хендлер записи или таймер. Вынесена отдельно от `FirestoreAck`, чтобы
/// её можно было протестировать без Firestore.
nonisolated final class AckLatch: @unchecked Sendable {
    private let lock = NSLock()
    private var finished = false
    private let onFinish: (Result<Void, Error>) -> Void

    var hasFinished: Bool {
        lock.lock(); defer { lock.unlock() }
        return finished
    }

    init(onFinish: @escaping (Result<Void, Error>) -> Void) {
        self.onFinish = onFinish
    }

    func finish(_ error: Error?) {
        lock.lock()
        guard !finished else { lock.unlock(); return }
        finished = true
        lock.unlock()
        onFinish(error.map { .failure($0) } ?? .success(()))
    }
}

enum FirestoreAck {
    /// Ждёт подтверждения completion-based записи Firestore не дольше `timeout`.
    ///
    /// Сама запись при этом остаётся поставленной в очередь — Firestore сохранит её в
    /// персистентном кэше и повторит, когда сеть вернётся. Ограничивается только
    /// *ожидание*: `try await ref.setData(...)` офлайн не возвращает управление никогда,
    /// потому что completion срабатывает только после ack бэкенда.
    ///
    /// Бросает `FirestoreAckError.notConfirmed`, если ack не пришёл вовремя. Вызывающий
    /// обязан трактовать это как «документа в облаке может ещё не быть» и не показывать
    /// пользователю данные, зависящие от его существования.
    static func confirm(
        timeout: TimeInterval,
        _ write: (@escaping @Sendable (Error?) -> Void) -> Void
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let latch = AckLatch { continuation.resume(with: $0) }
            let timer = Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                guard !Task.isCancelled else { return }
                latch.finish(FirestoreAckError.notConfirmed)
            }
            write { error in
                timer.cancel()
                latch.finish(error)
            }
        }
    }
}
