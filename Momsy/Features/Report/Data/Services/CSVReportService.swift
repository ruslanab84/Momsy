import Foundation

final class CSVReportService {
    private let fileName = "momsy_report.csv"

    var outputURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }

    func export(
        babyName: String,
        periodLabel: String,
        stats: [(label: String, value: String, details: String)],
        trends: [(label: String, values: [Double], peak: String)]
    ) -> URL? {
        var rows = [
            ["Section", "Metric", "Point", "Value", "Details"],
            ["Report", "Baby", "", babyName, ""],
            ["Report", "Period", "", periodLabel, ""],
        ]

        rows += stats.map { ["Statistic", $0.label, "", $0.value, $0.details] }
        for trend in trends {
            rows += trend.values.enumerated().map {
                ["Trend", trend.label, String($0.offset + 1), String($0.element), trend.peak]
            }
        }

        let csv = rows
            .map { $0.map(Self.escape).joined(separator: ",") }
            .joined(separator: "\r\n") + "\r\n"

        do {
            try Data(("\u{FEFF}" + csv).utf8).write(to: outputURL, options: .atomic)
            return outputURL
        } catch {
            return nil
        }
    }

    nonisolated private static func escape(_ value: String) -> String {
        let safeValue = value.drop(while: \.isWhitespace).first.map {
            "=+-@".contains($0) ? "'\(value)" : value
        } ?? value
        return "\"\(safeValue.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}
