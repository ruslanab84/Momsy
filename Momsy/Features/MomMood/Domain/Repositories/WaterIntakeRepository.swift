import Foundation

protocol WaterIntakeRepository {
    func add(_ entry: WaterIntakeEntry) async throws
    func getEntries(from: Date, to: Date) async throws -> [WaterIntakeEntry]
}
