import SwiftUI

@MainActor
final class PDFReportService {
    private let fileName = "momsy_report.pdf"

    var outputURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }

    func render<V: View>(content: V, pageWidth: CGFloat = 360) -> URL? {
        let page = content
            .frame(width: pageWidth)
            .padding(20)
            .background(Color.bbCard)

        let renderer = ImageRenderer(content: page)
        renderer.scale = 3.0

        let url = outputURL
        renderer.render { size, draw in
            var box = CGRect(origin: .zero, size: size)
            guard let ctx = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            ctx.beginPDFPage(nil)
            draw(ctx)
            ctx.endPDFPage()
            ctx.closePDF()
        }
        return url
    }
}
