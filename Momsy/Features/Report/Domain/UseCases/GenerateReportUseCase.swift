import SwiftUI

@MainActor
final class GenerateReportUseCase {
    private let pdfService: PDFReportService

    init(pdfService: PDFReportService? = nil) {
        self.pdfService = pdfService ?? PDFReportService()
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
}
