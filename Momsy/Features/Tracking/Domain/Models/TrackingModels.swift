import Foundation

// MARK: - WHO Reference

struct WHOPoint: Identifiable {
    let id = UUID()
    let month: Int
    let p3:  Double
    let p15: Double
    let p50: Double
    let p85: Double
    let p97: Double
}

struct BabyGrowthPoint {
    let month: Int
    let value: Double
}

// MARK: - Measurement entries

struct MeasurementEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var dateLabel: String
    var weight: String
    var height: String
    var headCirc: String
    var delta: String
    var visitLabel: String?
    var updatedAt: Date? = Date()
}

struct TemperatureEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var dateLabel: String
    var timeLabel: String
    var value: Double
    var note: String
    var updatedAt: Date? = Date()
}
