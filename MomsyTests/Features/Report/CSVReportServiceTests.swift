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
}
