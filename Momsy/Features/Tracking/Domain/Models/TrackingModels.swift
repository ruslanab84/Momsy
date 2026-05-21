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

// MARK: - WHO Child Growth Standards — boys, 0–24 months

let whoWeightData: [WHOPoint] = [
    WHOPoint(month:  0, p3:  2.5, p15:  2.9, p50:  3.3, p85:  3.9, p97:  4.3),
    WHOPoint(month:  1, p3:  3.4, p15:  3.9, p50:  4.5, p85:  5.1, p97:  5.7),
    WHOPoint(month:  2, p3:  4.4, p15:  4.9, p50:  5.6, p85:  6.3, p97:  7.0),
    WHOPoint(month:  3, p3:  5.1, p15:  5.7, p50:  6.4, p85:  7.2, p97:  8.0),
    WHOPoint(month:  4, p3:  5.6, p15:  6.2, p50:  7.0, p85:  7.9, p97:  8.7),
    WHOPoint(month:  5, p3:  6.1, p15:  6.7, p50:  7.5, p85:  8.4, p97:  9.3),
    WHOPoint(month:  6, p3:  6.4, p15:  7.1, p50:  7.9, p85:  8.8, p97:  9.7),
    WHOPoint(month:  7, p3:  6.7, p15:  7.4, p50:  8.3, p85:  9.2, p97: 10.2),
    WHOPoint(month:  8, p3:  6.9, p15:  7.7, p50:  8.6, p85:  9.6, p97: 10.5),
    WHOPoint(month:  9, p3:  7.1, p15:  7.9, p50:  8.9, p85:  9.9, p97: 10.9),
    WHOPoint(month: 10, p3:  7.4, p15:  8.2, p50:  9.2, p85: 10.2, p97: 11.2),
    WHOPoint(month: 11, p3:  7.6, p15:  8.4, p50:  9.4, p85: 10.5, p97: 11.5),
    WHOPoint(month: 12, p3:  7.7, p15:  8.6, p50:  9.6, p85: 10.7, p97: 11.8),
    WHOPoint(month: 15, p3:  8.3, p15:  9.2, p50: 10.3, p85: 11.4, p97: 12.6),
    WHOPoint(month: 18, p3:  8.8, p15:  9.8, p50: 10.9, p85: 12.1, p97: 13.4),
    WHOPoint(month: 21, p3:  9.2, p15: 10.2, p50: 11.4, p85: 12.6, p97: 13.9),
    WHOPoint(month: 24, p3:  9.7, p15: 10.8, p50: 12.0, p85: 13.3, p97: 14.6),
]

let whoHeightData: [WHOPoint] = [
    WHOPoint(month:  0, p3: 46.1, p15: 48.2, p50: 49.9, p85: 51.8, p97: 53.5),
    WHOPoint(month:  1, p3: 50.2, p15: 52.2, p50: 54.7, p85: 57.1, p97: 59.0),
    WHOPoint(month:  2, p3: 53.2, p15: 55.4, p50: 58.4, p85: 61.2, p97: 63.5),
    WHOPoint(month:  3, p3: 55.8, p15: 58.2, p50: 61.4, p85: 64.5, p97: 66.9),
    WHOPoint(month:  4, p3: 57.9, p15: 60.5, p50: 63.9, p85: 67.0, p97: 69.6),
    WHOPoint(month:  5, p3: 59.6, p15: 62.3, p50: 65.9, p85: 69.3, p97: 72.0),
    WHOPoint(month:  6, p3: 61.2, p15: 64.0, p50: 67.6, p85: 71.1, p97: 73.9),
    WHOPoint(month:  7, p3: 62.7, p15: 65.5, p50: 69.2, p85: 72.8, p97: 75.8),
    WHOPoint(month:  8, p3: 63.9, p15: 66.9, p50: 70.6, p85: 74.3, p97: 77.3),
    WHOPoint(month:  9, p3: 65.2, p15: 68.2, p50: 72.0, p85: 75.8, p97: 78.9),
    WHOPoint(month: 10, p3: 66.4, p15: 69.5, p50: 73.3, p85: 77.2, p97: 80.3),
    WHOPoint(month: 11, p3: 67.6, p15: 70.7, p50: 74.5, p85: 78.5, p97: 81.8),
    WHOPoint(month: 12, p3: 68.6, p15: 71.7, p50: 75.7, p85: 79.8, p97: 83.2),
    WHOPoint(month: 15, p3: 71.2, p15: 74.8, p50: 79.1, p85: 83.4, p97: 87.0),
    WHOPoint(month: 18, p3: 74.0, p15: 77.5, p50: 82.0, p85: 86.4, p97: 90.2),
    WHOPoint(month: 21, p3: 76.0, p15: 80.1, p50: 84.7, p85: 89.3, p97: 93.3),
    WHOPoint(month: 24, p3: 78.0, p15: 82.5, p50: 87.3, p85: 92.0, p97: 96.3),
]

let whoHeadData: [WHOPoint] = [
    WHOPoint(month:  0, p3: 32.1, p15: 33.2, p50: 34.5, p85: 35.9, p97: 37.0),
    WHOPoint(month:  1, p3: 34.2, p15: 35.3, p50: 36.9, p85: 38.3, p97: 39.6),
    WHOPoint(month:  2, p3: 36.0, p15: 37.1, p50: 38.6, p85: 40.1, p97: 41.3),
    WHOPoint(month:  3, p3: 37.3, p15: 38.4, p50: 39.9, p85: 41.4, p97: 42.6),
    WHOPoint(month:  4, p3: 38.4, p15: 39.5, p50: 41.0, p85: 42.5, p97: 43.7),
    WHOPoint(month:  5, p3: 39.2, p15: 40.3, p50: 41.8, p85: 43.3, p97: 44.5),
    WHOPoint(month:  6, p3: 40.0, p15: 41.1, p50: 42.6, p85: 44.1, p97: 45.3),
    WHOPoint(month:  7, p3: 40.6, p15: 41.8, p50: 43.3, p85: 44.8, p97: 46.0),
    WHOPoint(month:  8, p3: 41.1, p15: 42.3, p50: 43.8, p85: 45.3, p97: 46.6),
    WHOPoint(month:  9, p3: 41.6, p15: 42.8, p50: 44.3, p85: 45.8, p97: 47.1),
    WHOPoint(month: 10, p3: 42.0, p15: 43.2, p50: 44.7, p85: 46.2, p97: 47.5),
    WHOPoint(month: 11, p3: 42.3, p15: 43.5, p50: 45.0, p85: 46.5, p97: 47.8),
    WHOPoint(month: 12, p3: 42.6, p15: 43.8, p50: 45.2, p85: 46.8, p97: 48.1),
    WHOPoint(month: 15, p3: 43.3, p15: 44.5, p50: 46.0, p85: 47.5, p97: 48.9),
    WHOPoint(month: 18, p3: 44.0, p15: 45.1, p50: 46.6, p85: 48.1, p97: 49.5),
    WHOPoint(month: 21, p3: 44.5, p15: 45.7, p50: 47.1, p85: 48.7, p97: 50.1),
    WHOPoint(month: 24, p3: 45.0, p15: 46.1, p50: 47.6, p85: 49.2, p97: 50.5),
]

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
}

struct TemperatureEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var dateLabel: String
    var timeLabel: String
    var value: Double
    var note: String
}
