import Foundation
import Testing
@testable import Momsy

@Suite("CSVReportService", .serialized)
struct CSVReportServiceTests {
    @Test func exportsUtf8AndEscapesFields() throws {
        let service = CSVReportService()
        defer { try? FileManager.default.removeItem(at: service.outputURL) }

        let url = try #require(service.export(
            babyName: "=SUM(1,1) Жанна \"А\"",
            periodLabel: "Last\nvisit",
            stats: [("Feedings", "2", "milk, \"left\"")],
            trends: [("Sleep", [1.5, 2], "2")]
        ))
        let data = try Data(contentsOf: url)
        let csv = String(decoding: data.dropFirst(3), as: UTF8.self)

        #expect(Array(data.prefix(3)) == [0xEF, 0xBB, 0xBF])
        #expect(csv.hasPrefix("\"Section\",\"Metric\",\"Point\",\"Value\",\"Details\"\r\n"))
        #expect(csv.contains("\"Report\",\"Baby\",\"\",\"'=SUM(1,1) Жанна \"\"А\"\"\",\"\""))
        #expect(csv.contains("\"Report\",\"Period\",\"\",\"Last\nvisit\",\"\""))
        #expect(csv.contains("\"Statistic\",\"Feedings\",\"\",\"2\",\"milk, \"\"left\"\"\""))
        #expect(csv.contains("\"Trend\",\"Sleep\",\"1\",\"1.5\",\"2\""))
        #expect(csv.contains("\"Trend\",\"Sleep\",\"2\",\"2.0\",\"2\""))
        #expect(csv.hasSuffix("\r\n"))
    }

    @Test func exportsLogItemsForSelectedPeriod() throws {
        let service = CSVReportService()
        defer { try? FileManager.default.removeItem(at: service.logOutputURL) }
        let start = Date(timeIntervalSince1970: 0)
        let timeZone = try #require(TimeZone(secondsFromGMT: 4 * 3_600))

        let url = try #require(service.exportLog(
            periodLabel: "Week 1",
            entries: [
                (
                    category: "Feeding",
                    label: "=formula, \"value\"",
                    start: start,
                    end: start.addingTimeInterval(90)
                ),
                (
                    category: "Sleep",
                    label: "Instant",
                    start: start.addingTimeInterval(120),
                    end: nil
                ),
            ],
            averageDayCount: 7,
            averageCategories: ["Feeding", "Sleep", "Diaper"],
            timeZone: timeZone
        ))
        let data = try Data(contentsOf: url)
        let csv = String(decoding: data.dropFirst(3), as: UTF8.self)

        #expect(url.pathExtension == "csv")
        #expect(Array(data.prefix(3)) == [0xEF, 0xBB, 0xBF])
        #expect(csv.hasPrefix("\"Period\",\"Label\",\"Start\",\"End\"\r\n"))
        #expect(csv.contains("\"Week 1\",\"'=formula, \"\"value\"\"\""))
        #expect(csv.contains("\"1970-01-01T04:00:00+04:00\",\"1970-01-01T04:01:30+04:00\""))
        #expect(csv.contains("\"Week 1\",\"Instant\",\"1970-01-01T04:02:00+04:00\",\"\""))
        #expect(!csv.contains("Duration Seconds"))
        #expect(csv.contains("\"Summary\",\"Category\",\"Average entries per day\",\"\""))
        #expect(csv.contains("\"Average\",\"Feeding\",\"0.1\",\"\""))
        #expect(csv.contains("\"Average\",\"Sleep\",\"0.1\",\"\""))
        #expect(csv.contains("\"Average\",\"Diaper\",\"0.0\",\"\""))
    }
}
