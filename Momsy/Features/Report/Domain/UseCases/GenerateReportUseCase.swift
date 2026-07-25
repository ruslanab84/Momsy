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

    func executeCSV(periodLabel: String, items: [LogReportItem]) -> URL? {
        csvService.exportLog(
            periodLabel: periodLabel,
            entries: items.map { ($0.label, $0.start, $0.end) }
        )
    }
}
