import Foundation

final class CSVReportService {
    private let fileName = "momsy_report.csv"
    private let logFileName = "momsy_log_report.csv"

    var outputURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }

    var logOutputURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(logFileName)
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

        return write(rows, to: outputURL)
    }

    func exportLog(
        periodLabel: String,
        entries: [(category: String, label: String, start: Date, end: Date?)],
        averageDayCount: Int? = nil,
        averageCategories: [String] = [],
        timeZone: TimeZone = .current
    ) -> URL? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
        var rows = [["Period", "Label", "Start", "End"]]

        for entry in entries {
            rows.append([
                periodLabel,
                entry.label,
                formatter.string(from: entry.start),
                entry.end.map { formatter.string(from: $0) } ?? "",
            ])
        }

        if let averageDayCount, averageDayCount > 0 {
            let counts = Dictionary(grouping: entries, by: { $0.category }).mapValues(\.count)
            rows.append(["Summary", "Category", "Average entries per day", ""])
            for category in averageCategories {
                let average = Double(counts[category, default: 0]) / Double(averageDayCount)
                rows.append([
                    "Average",
                    category,
                    String(format: "%.1f", locale: Locale(identifier: "en_US_POSIX"), average),
                    "",
                ])
            }
        }

        return write(rows, to: logOutputURL)
    }

    private func write(_ rows: [[String]], to url: URL) -> URL? {
        let csv = rows
            .map { $0.map(Self.escape).joined(separator: ",") }
            .joined(separator: "\r\n") + "\r\n"

        do {
            try Data(("\u{FEFF}" + csv).utf8).write(to: url, options: .atomic)
            return url
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
