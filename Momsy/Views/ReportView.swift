import SwiftUI
import UIKit

// MARK: - Supporting types

private struct ReportSection: Identifiable {
    let id = UUID()
    let label: String
    var isOn: Bool

    static let defaults: [ReportSection] = [
        ReportSection(label: "Кормления и срыгивания",   isOn: true),
        ReportSection(label: "Сон по дням",              isOn: true),
        ReportSection(label: "Подгузники и стул",        isOn: true),
        ReportSection(label: "Температура / симптомы",   isOn: true),
        ReportSection(label: "Вес и рост (график)",      isOn: true),
        ReportSection(label: "Лекарства и витамины",     isOn: false),
        ReportSection(label: "Фото и заметки",           isOn: false),
    ]
}

private struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}

// MARK: - ReportView

struct ReportView: View {
    @AppStorage("babyName") private var babyName = ""

    @State private var selectedPeriod = 1
    @State private var includes: [ReportSection] = ReportSection.defaults
    @State private var isGenerating = false
    @State private var shareURL: URL? = nil
    @State private var showShare = false

    private let periods = ["3 дня", "Неделя", "2 недели", "Месяц", "С визита"]

    private var displayName: String { babyName.isEmpty ? "Малыш" : babyName }

    private var periodLabel: String {
        ["3 дня", "неделю", "2 недели", "месяц", "последний визит"][selectedPeriod]
    }

    // Stats per period
    private var currentStats: [(label: String, value: String, sub: String, tone: Color)] {
        switch selectedPeriod {
        case 0: return [
            ("Кормлений",   "21",      "7 / день",         .bbCoral),
            ("Сон",         "14ч 5м",  "медиана / сутки",  .bbLilac),
            ("Подгузники",  "16",      "мокрых · норма",   .bbSky),
            ("Температура", "36.7°",   "норма · 3 дня",    .bbMintDeep),
        ]
        case 1: return [
            ("Кормлений",   "47",      "6.7 / день",        .bbCoral),
            ("Сон",         "14ч 12м", "медиана / сутки",   .bbLilac),
            ("Подгузники",  "38",      "мокрых · обычно",   .bbSky),
            ("Температура", "37.8°",   "пик · 1 раз",       .bbCoralDeep),
        ]
        case 2: return [
            ("Кормлений",   "94",      "6.7 / день",        .bbCoral),
            ("Сон",         "14ч 8м",  "медиана / сутки",   .bbLilac),
            ("Подгузники",  "76",      "мокрых · обычно",   .bbSky),
            ("Температура", "37.8°",   "пик · 1 раз",       .bbCoralDeep),
        ]
        default: return [
            ("Кормлений",   "~200",    "6.5 / день",        .bbCoral),
            ("Сон",         "13ч 50м", "медиана / сутки",   .bbLilac),
            ("Подгузники",  "~160",    "мокрых · норма",    .bbSky),
            ("Температура", "37.8°",   "пик · 2 раза",      .bbCoralDeep),
        ]
        }
    }

    // Sparklines per period
    private var currentSparklines: [(label: String, values: [Double], color: Color, peak: String)] {
        switch selectedPeriod {
        case 0: return [
            ("Кормления / сут", [7, 6, 7],                               .bbCoralDeep, "7"),
            ("Сон / сут (ч)",   [14.5, 14, 14.2],                        .bbLilacDeep, "14.5"),
            ("Температура °C",  [36.6, 36.7, 36.6],                      .bbCoralDeep, "36.7"),
        ]
        default: return [
            ("Кормления / сут", [7, 8, 6, 7, 7, 7, 5],                  .bbCoralDeep, "5"),
            ("Сон / сут (ч)",   [14.5, 14, 13.5, 14, 14.5, 14, 13],     .bbLilacDeep, "13"),
            ("Температура °C",  [36.6, 36.7, 36.6, 36.8, 37.4, 37.8, 36.9], .bbCoralDeep, "37.8"),
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
            BBSectionLabel(text: "Отчёт для педиатра")
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("Подготовить за")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(periodLabel)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbCoralDeep)
                    .contentTransition(.interpolate)
                    .animation(.spring(response: 0.3), value: periodLabel)
            }
            Text("Сводка для визита: сон · еда · вес · температура · стул")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Period chips (interactive)

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
                            .background(selectedPeriod == i ? Color.bbInk : Color.bbCard)
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
            sparklines: currentSparklines
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
            Text("ВКЛЮЧИТЬ В ОТЧЁТ")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)
                .padding(.bottom, 8)

            ForEach(includes.indices, id: \.self) { i in
                HStack {
                    Text(includes[i].label)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInk)
                    Spacer()
                    Toggle("", isOn: $includes[i].isOn)
                        .tint(.bbMintDeep)
                        .labelsHidden()
                }
                .padding(.vertical, 8)
                if i < includes.count - 1 {
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
                    Text(isGenerating ? "Готовим PDF…" : "Поделиться PDF")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(isGenerating ? Color.bbInk.opacity(0.6) : Color.bbInk)
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
                    Text("Распечатать")
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
        info.jobName = "Momsy — отчёт"
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
            sparklines: currentSparklines
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
// Extracted so it can be rendered both on-screen and via ImageRenderer.

struct ReportPreviewContent: View {
    let babyName: String
    let periodLabel: String
    let stats: [(label: String, value: String, sub: String, tone: Color)]
    let sparklines: [(label: String, values: [Double], color: Color, peak: String)]

    private var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM yyyy"
        return f.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            // Document header
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
                Text("Период: \(periodLabel)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }
            .padding(14)
            .background(Color.bbCard)

            Divider().overlay(Color.bbInkMute.opacity(0.2))

            // Stats grid
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

            // Sparkline charts
            VStack(spacing: 10) {
                ForEach(sparklines.indices, id: \.self) { i in
                    let row = sparklines[i]
                    SparklineRow(label: row.label, values: row.values, color: row.color, peak: row.peak)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
            .background(Color.bbCard)

            // Parent notes
            VStack(alignment: .leading, spacing: 4) {
                Text("ЗАМЕТКИ")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .kerning(0.5)
                Text("13 мая поднималась t° до 37.8°, спал прерывисто. Появилась слюна, грызёт пальцы — думаем, зубы.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.bbCard)

            // Doctor notes section (blank for printing)
            VStack(alignment: .leading, spacing: 0) {
                Text("ЗАМЕТКИ ВРАЧА")
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

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                Spacer()
                Text("пик: \(peak)")
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
