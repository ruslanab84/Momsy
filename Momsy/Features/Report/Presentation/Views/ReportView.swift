import SwiftUI
import UIKit

// MARK: - ReportView

struct ReportView: View {
    @StateObject private var vm: ReportViewModel
    @EnvironmentObject var loc: LocalizationManager

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeReportViewModel())
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
        .task { await vm.loadData() }
        .onChange(of: vm.selectedPeriod) { _ in Task { await vm.loadData() } }
        .sheet(isPresented: $vm.showShare) {
            if let url = vm.shareURL {
                ActivityView(items: [url])
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            BBSectionLabel(text: loc.strings.paediatricReport)
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(loc.strings.prepareFor)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(vm.periodLabel)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbCoralDeep)
                    .contentTransition(.interpolate)
                    .animation(.spring(response: 0.3), value: vm.periodLabel)
            }
            Text(loc.strings.visitSummaryHint)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Period chips

    private var periodChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.periods.indices, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            vm.selectedPeriod = i
                        }
                    } label: {
                        Text(vm.periods[i])
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(vm.selectedPeriod == i ? .white : .bbInk)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(vm.selectedPeriod == i ? Color.bbSurface : Color.bbCard)
                            .clipShape(Capsule())
                            .bbShadowSoft()
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.25), value: vm.selectedPeriod)
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - PDF preview card

    private var pdfPreviewCard: some View {
        ReportPreviewContent(
            babyName: vm.displayName,
            periodLabel: vm.periods[vm.selectedPeriod],
            stats: vm.currentStats,
            sparklines: vm.currentSparklines,
            lang: loc.lang
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .bbShadow()
        .id(vm.selectedPeriod)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: vm.selectedPeriod)
    }

    // MARK: - Include toggles

    private var includeCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(loc.strings.includeInReport)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)
                .padding(.bottom, 8)

            ForEach(vm.isOnStates.indices, id: \.self) { i in
                HStack {
                    Text(vm.sectionLabels[i])
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInk)
                    Spacer()
                    Toggle("", isOn: $vm.isOnStates[i])
                        .tint(.bbMintDeep)
                        .labelsHidden()
                }
                .padding(.vertical, 8)
                if i < vm.isOnStates.count - 1 {
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
                Task { await vm.generateAndShare() }
            } label: {
                HStack(spacing: 8) {
                    if vm.isGenerating {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .bold))
                    }
                    Text(vm.isGenerating ? loc.strings.preparingPdf : loc.strings.sharePdf)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(vm.isGenerating ? Color.bbSurface.opacity(0.6) : Color.bbSurface)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .animation(.easeInOut(duration: 0.2), value: vm.isGenerating)
            }
            .disabled(vm.isGenerating)

            Button {
                Task { await vm.printReport() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "printer")
                        .font(.system(size: 14, weight: .semibold))
                    Text(loc.strings.printAction)
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
            .disabled(vm.isGenerating)
        }
    }
}

// MARK: - Report Preview Content

struct ReportPreviewContent: View {
    let babyName: String
    let periodLabel: String
    let stats: [(label: String, value: String, sub: String, tone: Color)]
    let sparklines: [(label: String, values: [Double], color: Color, peak: String)]
    var lang: String = "en"

    private var lm: LocalizationManager { .shared }

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
                Text(lm.strings.reportPreviewPeriod(label: periodLabel))
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
                Text(lm.strings.reportPreviewNotes)
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
                Text(lm.strings.reportPreviewDoctorNotes)
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

    private var lm: LocalizationManager { .shared }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                Spacer()
                Text(lm.strings.reportSparkPeak(value: peak))
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
    NavigationStack { ReportView(container: AppContainer()) }
}
