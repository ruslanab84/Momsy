import SwiftUI

@MainActor
final class GenerateReportUseCase {
    private let pdfService: PDFReportService
    private let csvService: CSVReportService

    init(
        pdfService: PDFReportService? = nil,
        csvService: CSVReportService? = nil
    ) {
        self.pdfService = pdfService ?? PDFReportService()
        self.csvService = csvService ?? CSVReportService()
    }

    func execute(
        babyName: String,
        periodLabel: String,
        stats: [(label: String, value: String, sub: String, tone: Color)],
        sparklines: [(label: String, values: [Double], color: Color, peak: String)],
        lang: String
    ) -> URL? {
        let content = ReportPreviewContent(
            babyName: babyName,
            periodLabel: periodLabel,
            stats: stats,
            sparklines: sparklines,
            lang: lang
        )
        return pdfService.render(content: content)
    }

    func executeCSV(
        babyName: String,
        periodLabel: String,
        stats: [(label: String, value: String, sub: String, tone: Color)],
        sparklines: [(label: String, values: [Double], color: Color, peak: String)]
    ) -> URL? {
        csvService.export(
            babyName: babyName,
            periodLabel: periodLabel,
            stats: stats.map { ($0.label, $0.value, $0.sub) },
            trends: sparklines.map { ($0.label, $0.values, $0.peak) }
        )
    }

    func executeCSV(
        periodLabel: String,
        items: [LogReportItem],
        averageDayCount: Int?
    ) -> URL? {
        csvService.exportLog(
            periodLabel: periodLabel,
            entries: items.map {
                (categoryLabel(for: $0.kind), $0.label, $0.start, $0.end)
            },
            averageDayCount: averageDayCount,
            averageCategories: averageCategories
        )
    }

    private var averageCategories: [String] {
        let strings = LocalizationManager.shared.strings
        return [
            strings.feeding,
            strings.sleep,
            strings.diaper,
            strings.stoolLabel,
            strings.walk,
            strings.bath,
            strings.pumping,
            strings.vitamins,
        ]
    }

    private func categoryLabel(for kind: BlobKind) -> String {
        let strings = LocalizationManager.shared.strings
        switch kind {
        case .bottle:  return strings.feeding
        case .sleep:   return strings.sleep
        case .drop:    return strings.diaper
        case .stool:   return strings.stoolLabel
        case .walk:    return strings.walk
        case .bath:    return strings.bath
        case .pump:    return strings.pumping
        case .vitamin: return strings.vitamins
        default:       return kind.rawValue.capitalized
        }
    }
}
