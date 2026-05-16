import SwiftUI

struct ReportView: View {
    @State private var selectedPeriod = 1

    private let periods = ["3 дня", "Неделя", "2 недели", "Месяц", "С пред. визита"]

    private let stats: [(String, String, String, Color)] = [
        ("Кормлений",    "47",      "6.7 / день",     .bbCoral),
        ("Сон",          "14ч 12м", "медиана / сутки", .bbLilac),
        ("Подгузники",   "38",      "мокрых · обычно", .bbSky),
        ("Температура",  "37.8°",   "пик · 1 раз",     .bbCoralDeep),
    ]

    private let sparklines: [(String, [Double], Color, String)] = [
        ("Кормления / сут",  [7, 8, 6, 7, 7, 7, 5],                           .bbCoralDeep, "5"),
        ("Сон / сут (ч)",    [14.5, 14, 13.5, 14, 14.5, 14, 13],              .bbLilacDeep, "13"),
        ("Температура °C",   [36.6, 36.7, 36.6, 36.8, 37.4, 37.8, 36.9],     .bbCoralDeep, "37.8"),
    ]

    private let toggles: [(String, Bool)] = [
        ("Кормления и срыгивания", true),
        ("Сон по дням", true),
        ("Подгузники и стул", true),
        ("Температура / симптомы", true),
        ("Вес и рост (график)", true),
        ("Лекарства и витамины", false),
        ("Фото и заметки", false),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                BBChipRow(chips: periods, selected: selectedPeriod)
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
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            BBSectionLabel(text: "Отчёт для педиатра")
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("Подготовить за")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text("неделю")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbCoralDeep)
            }
            Text("Сводка для визита: сон · еда · вес · температура · стул")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - PDF Preview

    private var pdfPreviewCard: some View {
        VStack(spacing: 0) {
            // header
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Лёва Соколов")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Spacer()
                    Text("4 мес 12 дн · 6.4 кг · 64 см")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
                Text("9–15 мая 2026 · отчёт от мамы")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }
            .padding(14)
            .background(Color.bbCard)

            Divider().overlay(Color.bbInkMute.opacity(0.2)).padding(.horizontal, 0)

            // stats grid
            let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(stats, id: \.0) { label, value, sub, tone in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(label.uppercased())
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInkSoft)
                        Text(value)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInk)
                        Text(sub)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.bbInkMute)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(tone.opacity(0.33))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(12)
            .background(Color.bbCard)

            // sparklines
            VStack(spacing: 10) {
                ForEach(sparklines, id: \.0) { label, vals, color, peak in
                    SparklineRow(label: label, values: vals, color: color, peak: peak)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
            .background(Color.bbCard)

            // notes
            VStack(alignment: .leading, spacing: 4) {
                Text("ЗАМЕТКИ МАМЫ")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .kerning(0.5)
                Text("13 мая поднималась t° до 37.8°, спал прерывисто. Появилась слюна, грызёт пальцы — думаем, зубы.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.bbCard)

            // doctor lines
            VStack(alignment: .leading, spacing: 10) {
                Text("ЗАМЕТКИ ВРАЧА")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .kerning(0.5)
                ForEach(0..<2) { _ in
                    Divider()
                        .overlay(Color.bbInkMute.opacity(0.4).frame(height: 1).padding(.top, 32))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.bbCreamSoft)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .bbShadow()
    }

    // MARK: - Include Toggles

    private var includeCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ВКЛЮЧИТЬ В ОТЧЁТ")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)
                .padding(.bottom, 8)

            ForEach(toggles, id: \.0) { label, isOn in
                BBToggleRow(label: label, isOn: isOn)
                if label != toggles.last?.0 {
                    Divider().opacity(0.4)
                }
            }
        }
        .bbCard(pad: 14)
    }

    // MARK: - Buttons

    private var actionButtons: some View {
        VStack(spacing: 8) {
            Button(action: {}) {
                Text("↗ Поделиться PDF")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.bbInk)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            Button(action: {}) {
                Text("Распечатать")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.bbInkMute.opacity(0.35), lineWidth: 1.5)
                    )
            }
        }
    }
}

// MARK: - Sparkline Row

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
            let points = values.enumerated().map { i, v -> CGPoint in
                let x = CGFloat(i) / CGFloat(values.count - 1) * w
                let y = h - CGFloat((v - minV) / range) * (h - 4) - 2
                return CGPoint(x: x, y: y)
            }
            ZStack {
                Path { p in
                    guard let first = points.first else { return }
                    p.move(to: first)
                    points.dropFirst().forEach { p.addLine(to: $0) }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))

                ForEach(points.indices, id: \.self) { i in
                    Circle()
                        .fill(color)
                        .frame(width: 3.2, height: 3.2)
                        .position(points[i])
                }
            }
        }
    }
}

#Preview {
    NavigationStack { ReportView() }
}
