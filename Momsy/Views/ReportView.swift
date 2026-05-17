import SwiftUI
import UIKit

// MARK: - Supporting types

private struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}

// MARK: - ReportView

struct ReportView: View {
    @AppStorage("babyName")    private var babyName = ""
    @AppStorage("appLanguage") private var lang = "en"

    @State private var selectedPeriod = 1
    @State private var isOnStates: [Bool] = [true, true, true, true, true, false, false]
    @State private var isGenerating = false
    @State private var shareURL: URL? = nil
    @State private var showShare = false

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }
    private var displayName: String { babyName.isEmpty ? t("Baby", "Малыш") : babyName }

    private var periods: [String] {
        [t("3 days", "3 дня"), t("Week", "Неделя"), t("2 weeks", "2 недели"), t("Month", "Месяц"), t("Since visit", "С визита")]
    }

    private var periodLabel: String {
        [t("3 days", "3 дня"), t("a week", "неделю"), t("2 weeks", "2 недели"),
         t("a month", "месяц"), t("last visit", "последний визит")][selectedPeriod]
    }

    private var sectionLabels: [String] {
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

    private var currentStats: [(label: String, value: String, sub: String, tone: Color)] {
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

    private var currentSparklines: [(label: String, values: [Double], color: Color, peak: String)] {
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

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                periodChips
                pdfPreviewCard
                includeCard
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShare) {
            if let url = shareURL {
                ActivityView(items: [url])
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            BBSectionLabel(text: t("Paediatric Report", "Отчёт для педиатра"))
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(t("Prepare for", "Подготовить за"))
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(periodLabel)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbCoralDeep)
                    .contentTransition(.interpolate)
                    .animation(.spring(response: 0.3), value: periodLabel)
            }
            Text(t("Visit summary: sleep · food · weight · temp · stool",
                   "Сводка для визита: сон · еда · вес · температура · стул"))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Period chips

    private var periodChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(periods.indices, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedPeriod = i
                        }
                    } label: {
                        Text(periods[i])
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(selectedPeriod == i ? .white : .bbInk)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedPeriod == i ? Color.bbSurface : Color.bbCard)
                            .clipShape(Capsule())
                            .bbShadowSoft()
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.25), value: selectedPeriod)
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - PDF preview card

    private var pdfPreviewCard: some View {
        ReportPreviewContent(
            babyName: displayName,
            periodLabel: periods[selectedPeriod],
            stats: currentStats,
            sparklines: currentSparklines,
            lang: lang
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .bbShadow()
        .id(selectedPeriod)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedPeriod)
    }

    // MARK: - Include toggles

    private var includeCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(t("INCLUDE IN REPORT", "ВКЛЮЧИТЬ В ОТЧЁТ"))
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)
                .padding(.bottom, 8)

            ForEach(isOnStates.indices, id: \.self) { i in
                HStack {
                    Text(sectionLabels[i])
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInk)
                    Spacer()
                    Toggle("", isOn: $isOnStates[i])
                        .tint(.bbMintDeep)
                        .labelsHidden()
                }
                .padding(.vertical, 8)
                if i < isOnStates.count - 1 {
                    Divider().opacity(0.4)
                }
            }
        }
        .bbCard(pad: 14)
    }

    // MARK: - Action buttons

    private var actionButtons: some View {
        VStack(spacing: 8) {
            Button {
                Task { await generateAndShare() }
            } label: {
                HStack(spacing: 8) {
                    if isGenerating {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .bold))
                    }
                    Text(isGenerating ? t("Preparing PDF…", "Готовим PDF…") : t("Share PDF", "Поделиться PDF"))
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(isGenerating ? Color.bbSurface.opacity(0.6) : Color.bbSurface)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .animation(.easeInOut(duration: 0.2), value: isGenerating)
            }
            .disabled(isGenerating)

            Button {
                Task { await printReport() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "printer")
                        .font(.system(size: 14, weight: .semibold))
                    Text(t("Print", "Распечатать"))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(.bbInkSoft)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.bbInkMute.opacity(0.35), lineWidth: 1.5)
                )
            }
            .disabled(isGenerating)
        }
    }

    // MARK: - PDF generation

    @MainActor
    private func generateAndShare() async {
        guard !isGenerating, let url = renderPDF() else { return }
        shareURL = url
        showShare = true
    }

    @MainActor
    private func printReport() async {
        guard !isGenerating, let url = renderPDF() else { return }
        let info = UIPrintInfo.printInfo()
        info.outputType = .general
        info.jobName = t("Momsy — report", "Momsy — отчёт")
        let controller = UIPrintInteractionController.shared
        controller.printInfo = info
        controller.printingItem = url
        controller.present(animated: true)
    }

    @MainActor
    private func renderPDF() -> URL? {
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

// MARK: - Report Preview Content

struct ReportPreviewContent: View {
    let babyName: String
    let periodLabel: String
    let stats: [(label: String, value: String, sub: String, tone: Color)]
    let sparklines: [(label: String, values: [Double], color: Color, peak: String)]
    var lang: String = "en"

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    private var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: lang == "en" ? "en_US" : "ru_RU")
        f.dateFormat = "d MMMM yyyy"
        return f.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(babyName)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Spacer()
                    Text("Momsy · \(dateString)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
                Text(t("Period: \(periodLabel)", "Период: \(periodLabel)"))
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }
            .padding(14)
            .background(Color.bbCard)

            Divider().overlay(Color.bbInkMute.opacity(0.2))

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                spacing: 8
            ) {
                ForEach(stats.indices, id: \.self) { i in
                    let s = stats[i]
                    VStack(alignment: .leading, spacing: 2) {
                        Text(s.label.uppercased())
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInkSoft)
                        Text(s.value)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInk)
                        Text(s.sub)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.bbInkMute)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(s.tone.opacity(0.33))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(12)
            .background(Color.bbCard)

            VStack(spacing: 10) {
                ForEach(sparklines.indices, id: \.self) { i in
                    let row = sparklines[i]
                    SparklineRow(label: row.label, values: row.values, color: row.color, peak: row.peak, lang: lang)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
            .background(Color.bbCard)

            VStack(alignment: .leading, spacing: 4) {
                Text(t("NOTES", "ЗАМЕТКИ"))
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .kerning(0.5)
                Text(t("May 13 — temp rose to 37.8°, slept restlessly. Drooling, chewing fingers — probably teething.",
                       "13 мая поднималась t° до 37.8°, спал прерывисто. Появилась слюна, грызёт пальцы — думаем, зубы."))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.bbCard)

            VStack(alignment: .leading, spacing: 0) {
                Text(t("DOCTOR'S NOTES", "ЗАМЕТКИ ВРАЧА"))
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .kerning(0.5)
                    .padding(.bottom, 8)
                ForEach(0..<2, id: \.self) { _ in
                    Divider()
                        .overlay(Color.bbInkMute.opacity(0.4).frame(height: 1).padding(.top, 32))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.bbCreamSoft)
        }
    }
}

// MARK: - Sparkline components

private struct SparklineRow: View {
    let label: String
    let values: [Double]
    let color: Color
    let peak: String
    var lang: String = "en"

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                Spacer()
                Text(t("peak: \(peak)", "пик: \(peak)"))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
            SparklineChart(values: values, color: color)
                .frame(height: 32)
        }
    }
}

private struct SparklineChart: View {
    let values: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let minV = values.min() ?? 0
            let maxV = values.max() ?? 1
            let range = maxV - minV == 0 ? 1.0 : maxV - minV
            let pts = values.enumerated().map { i, v -> CGPoint in
                CGPoint(
                    x: CGFloat(i) / CGFloat(max(values.count - 1, 1)) * w,
                    y: h - CGFloat((v - minV) / range) * (h - 4) - 2
                )
            }
            ZStack {
                Path { p in
                    guard let first = pts.first else { return }
                    p.move(to: first)
                    pts.dropFirst().forEach { p.addLine(to: $0) }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))

                ForEach(pts.indices, id: \.self) { i in
                    Circle()
                        .fill(color)
                        .frame(width: 3.2, height: 3.2)
                        .position(pts[i])
                }
            }
        }
    }
}

#Preview {
    NavigationStack { ReportView() }
}
