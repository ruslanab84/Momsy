import Foundation

final class LogPumpingUseCase {
    private let repository: any PumpingRepository

    init(repository: any PumpingRepository) {
        self.repository = repository
    }

    func start(side: PumpingSide) async throws -> PumpingEntry {
        try await repository.start(side: side)
    }

    func stop(_ entry: PumpingEntry, volumeML: Int) async throws -> PumpingEntry {
        try await repository.stop(entry, volumeML: volumeML)
    }
}
