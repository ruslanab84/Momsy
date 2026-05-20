import Foundation

struct WeightPoint: Identifiable {
    let id = UUID()
    let month: Int
    let babyKg: Double
    let p15: Double
    let p50: Double
    let p85: Double
}

let whoWeightData: [WeightPoint] = [
    WeightPoint(month: 0, babyKg: 3.2, p15: 2.8, p50: 3.3, p85: 3.9),
    WeightPoint(month: 1, babyKg: 4.1, p15: 3.9, p50: 4.5, p85: 5.1),
    WeightPoint(month: 2, babyKg: 5.0, p15: 4.7, p50: 5.6, p85: 6.5),
    WeightPoint(month: 3, babyKg: 5.7, p15: 5.3, p50: 6.4, p85: 7.4),
    WeightPoint(month: 4, babyKg: 6.1, p15: 5.8, p50: 7.0, p85: 8.1),
    WeightPoint(month: 5, babyKg: 6.4, p15: 6.2, p50: 7.5, p85: 8.7),
]

let whoHeightData: [WeightPoint] = [
    WeightPoint(month: 0, babyKg: 50.0, p15: 46.1, p50: 49.1, p85: 52.0),
    WeightPoint(month: 1, babyKg: 53.0, p15: 50.2, p50: 53.7, p85: 57.2),
    WeightPoint(month: 2, babyKg: 57.0, p15: 53.2, p50: 57.1, p85: 60.9),
    WeightPoint(month: 3, babyKg: 60.0, p15: 55.8, p50: 59.8, p85: 63.8),
    WeightPoint(month: 4, babyKg: 62.0, p15: 57.8, p50: 62.1, p85: 66.4),
    WeightPoint(month: 5, babyKg: 64.0, p15: 59.6, p50: 64.0, p85: 68.5),
]

let whoHeadData: [WeightPoint] = [
    WeightPoint(month: 0, babyKg: 34.0, p15: 32.5, p50: 34.5, p85: 36.5),
    WeightPoint(month: 1, babyKg: 36.5, p15: 34.5, p50: 36.5, p85: 38.5),
    WeightPoint(month: 2, babyKg: 38.0, p15: 36.0, p50: 38.0, p85: 40.0),
    WeightPoint(month: 3, babyKg: 40.0, p15: 37.5, p50: 39.5, p85: 41.5),
    WeightPoint(month: 4, babyKg: 41.5, p15: 38.5, p50: 40.5, p85: 42.5),
    WeightPoint(month: 5, babyKg: 42.0, p15: 39.5, p50: 41.5, p85: 43.5),
]

struct MeasurementEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var dateLabel: String
    var weight: String
    var height: String
    var headCirc: String
    var delta: String
    var visitLabel: String?
}

struct TemperatureEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var dateLabel: String
    var timeLabel: String
    var value: Double
    var note: String
}


