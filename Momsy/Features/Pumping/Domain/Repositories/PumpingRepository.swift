import Foundation

protocol PumpingRepository {
    func start(side: PumpingSide) async throws -> PumpingEntry
    func stop(_ entry: PumpingEntry, volumeML: Int) async throws -> PumpingEntry
    func getEntries(from: Date, to: Date) async throws -> [PumpingEntry]
}
