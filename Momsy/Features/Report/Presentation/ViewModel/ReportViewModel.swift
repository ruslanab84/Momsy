import SwiftUI
import UIKit

@MainActor
final class ReportViewModel: ObservableObject {
    @Published var selectedPeriod = 1
    @Published var isOnStates: [Bool] = [true, true, true, true, true, false, false]
    @Published var isGenerating = false
    @Published var shareURL: URL? = nil
    @Published var showShare = false

    private var lang: String { UserDefaults.standard.string(forKey: "appLanguage") ?? "en" }
    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    var displayName: String {
        let name = UserDefaults.standard.string(forKey: "babyName") ?? ""
        return name.isEmpty ? t("Baby", "Малыш") : name
    }

    var periods: [String] {
        [t("3 days", "3 дня"), t("Week", "Неделя"), t("2 weeks", "2 недели"), t("Month", "Месяц"), t("Since visit", "С визита")]
    }

    var periodLabel: String {
        [t("3 days", "3 дня"), t("a week", "неделю"), t("2 weeks", "2 недели"),
         t("a month", "месяц"), t("last visit", "последний визит")][selectedPeriod]
    }

    var sectionLabels: [String] {
        [
            t("Feedings & spit-ups",   "Кормления и срыгивания"),
            t("Sleep by day",          "Сон по дням"),
            t("Diapers & stool",       "Подгузники и стул"),
            t("Temp / symptoms",       "Температура / симптомы"),
            t("Weight & height",       "Вес и рост (график)"),
            t("Medicine & vitamins",   "Лекарства и витамины"),
            t("Photos & notes",        "Фото и заметки"),
        ]
    }

    var currentStats: [(label: String, value: String, sub: String, tone: Color)] {
        switch selectedPeriod {
        case 0: return [
            (t("Feedings",     "Кормлений"),   "21",      t("7 / day",            "7 / день"),          .bbCoral),
            (t("Sleep",        "Сон"),         "14h 5m",  t("median / day",       "медиана / сутки"),   .bbLilac),
            (t("Diapers",      "Подгузники"),  "16",      t("wet · normal",       "мокрых · норма"),    .bbSky),
            (t("Temperature",  "Температура"), "36.7°",   t("normal · 3 days",    "норма · 3 дня"),     .bbMintDeep),
        ]
        case 1: return [
            (t("Feedings",     "Кормлений"),   "47",      t("6.7 / day",          "6.7 / день"),        .bbCoral),
            (t("Sleep",        "Сон"),         "14h 12m", t("median / day",       "медиана / сутки"),   .bbLilac),
            (t("Diapers",      "Подгузники"),  "38",      t("wet · usual",        "мокрых · обычно"),   .bbSky),
            (t("Temperature",  "Температура"), "37.8°",   t("peak · 1 time",      "пик · 1 раз"),       .bbCoralDeep),
        ]
        case 2: return [
            (t("Feedings",     "Кормлений"),   "94",      t("6.7 / day",          "6.7 / день"),        .bbCoral),
            (t("Sleep",        "Сон"),         "14h 8m",  t("median / day",       "медиана / сутки"),   .bbLilac),
            (t("Diapers",      "Подгузники"),  "76",      t("wet · usual",        "мокрых · обычно"),   .bbSky),
            (t("Temperature",  "Температура"), "37.8°",   t("peak · 1 time",      "пик · 1 раз"),       .bbCoralDeep),
        ]
        default: return [
            (t("Feedings",     "Кормлений"),   "~200",    t("6.5 / day",          "6.5 / день"),        .bbCoral),
            (t("Sleep",        "Сон"),         "13h 50m", t("median / day",       "медиана / сутки"),   .bbLilac),
            (t("Diapers",      "Подгузники"),  "~160",    t("wet · normal",       "мокрых · норма"),    .bbSky),
            (t("Temperature",  "Температура"), "37.8°",   t("peak · 2 times",     "пик · 2 раза"),      .bbCoralDeep),
        ]
        }
    }

    var currentSparklines: [(label: String, values: [Double], color: Color, peak: String)] {
        switch selectedPeriod {
        case 0: return [
            (t("Feedings / day", "Кормления / сут"), [7, 6, 7],              .bbCoralDeep, "7"),
            (t("Sleep / day (h)", "Сон / сут (ч)"),  [14.5, 14, 14.2],       .bbLilacDeep, "14.5"),
            (t("Temperature °C", "Температура °C"),  [36.6, 36.7, 36.6],     .bbCoralDeep, "36.7"),
        ]
        default: return [
            (t("Feedings / day", "Кормления / сут"), [7, 8, 6, 7, 7, 7, 5],                   .bbCoralDeep, "5"),
            (t("Sleep / day (h)", "Сон / сут (ч)"),  [14.5, 14, 13.5, 14, 14.5, 14, 13],      .bbLilacDeep, "13"),
            (t("Temperature °C", "Температура °C"),  [36.6, 36.7, 36.6, 36.8, 37.4, 37.8, 36.9], .bbCoralDeep, "37.8"),
        ]
        }
    }

    func generateAndShare() async {
        guard !isGenerating, let url = renderPDF() else { return }
        shareURL = url
        showShare = true
    }

    func printReport() async {
        guard !isGenerating, let url = renderPDF() else { return }
        let info = UIPrintInfo.printInfo()
        info.outputType = .general
        info.jobName = t("Momsy — report", "Momsy — отчёт")
        let controller = UIPrintInteractionController.shared
        controller.printInfo = info
        controller.printingItem = url
        controller.present(animated: true)
    }

    func renderPDF() -> URL? {
        isGenerating = true
        defer { isGenerating = false }

        let content = ReportPreviewContent(
            babyName: displayName,
            periodLabel: periods[selectedPeriod],
            stats: currentStats,
            sparklines: currentSparklines,
            lang: lang
        )
        .frame(width: 360)
        .padding(20)
        .background(Color.bbCard)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 3.0

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("momsy_report.pdf")

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
