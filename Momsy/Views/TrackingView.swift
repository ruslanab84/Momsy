import SwiftUI

struct TrackingView: View {
    @State private var selectedTab = 0
    private let tabs = ["Вес", "Рост", "Окруж. головы", "Темп."]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                tabPicker
                chartCard
                measurementsList
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
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                BBSectionLabel(text: "Здоровье")
                Text("Рост и вес")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text("6.4 кг · 64 см · сегодня")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
            }
            Spacer()
            BBPill(text: "в норме", color: .bbMint, fg: .bbMintDeep)
        }
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tabs.indices, id: \.self) { i in
                    Text(tabs[i])
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(i == selectedTab ? .white : .bbInkSoft)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(i == selectedTab ? Color.bbInk : Color.bbCard)
                        .clipShape(Capsule())
                        .bbShadowSoft()
                        .onTapGesture { selectedTab = i }
                }
            }
        }
    }

    // MARK: - Chart Card

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Вес, кг")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Spacer()
                Text("0–5 мес · перцентили ВОЗ")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }

            WHOWeightChart(data: sampleWeightData)
                .frame(height: 160)

            HStack(spacing: 12) {
                legendItem(color: .bbCoralDeep, isDashed: false, label: "Лёва")
                legendItem(color: .bbMint,      isDashed: false, label: "Норма 15–85%")
                legendItem(color: .bbMintDeep,  isDashed: true,  label: "Медиана")
            }
            .padding(.top, 4)
        }
        .bbCard(pad: 14)
    }

    private func legendItem(color: Color, isDashed: Bool, label: String) -> some View {
        HStack(spacing: 4) {
            if isDashed {
                HStack(spacing: 1) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle().fill(color).frame(width: 2.5, height: 1.5)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(color).frame(width: 12, height: 3)
            }
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
    }

    // MARK: - Measurements List

    private var measurementsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: "Последние замеры")
            VStack(spacing: 0) {
                ForEach(sampleMeasurements.indices, id: \.self) { i in
                    let m = sampleMeasurements[i]
                    HStack(spacing: 12) {
                        Text(m.dateLabel)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.bbInkMute)
                            .frame(width: 50, alignment: .leading)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("\(m.weight) · \(m.height)")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundColor(.bbInk)
                            Text(m.delta)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.bbInkSoft)
                        }
                        Spacer()
                        if let visit = m.visitLabel {
                            BBPill(text: "★ \(visit)", color: .bbSky, fg: .bbSkyDeep, size: 10)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    if i < sampleMeasurements.count - 1 {
                        Divider().opacity(0.2).padding(.horizontal, 14)
                    }
                }
            }
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .bbShadow()
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button(action: {}) {
                Text("+ Вес / рост")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.bbCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .bbShadowSoft()
            }
            Button(action: {}) {
                Text("+ Температура")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.bbCoralDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}

// MARK: - WHO Weight Chart

private struct WHOWeightChart: View {
    let data: [WeightPoint]

    private let padL: CGFloat = 30, padR: CGFloat = 8, padT: CGFloat = 12, padB: CGFloat = 22
    private let gridVals = [3, 5, 7, 9]

    private func xPos(_ i: Int, width: CGFloat) -> CGFloat {
        padL + CGFloat(i) / CGFloat(data.count - 1) * (width - padL - padR)
    }

    private func yPos(_ v: Double, height: CGFloat, minV: Double, maxV: Double) -> CGFloat {
        padT + CGFloat(1 - (v - minV) / (maxV - minV)) * (height - padT - padB)
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let allVals = data.flatMap { [$0.babyKg, $0.p15, $0.p85] }
            let minV = (allVals.min() ?? 2.5) - 0.2
            let maxV = (allVals.max() ?? 9.0) + 0.2

            ZStack(alignment: .topLeading) {
                // Percentile band
                Path { p in
                    p.move(to: CGPoint(x: xPos(0, width: w), y: yPos(data[0].p15, height: h, minV: minV, maxV: maxV)))
                    for i in data.indices.dropFirst() {
                        p.addLine(to: CGPoint(x: xPos(i, width: w), y: yPos(data[i].p15, height: h, minV: minV, maxV: maxV)))
                    }
                    for i in data.indices.reversed() {
                        p.addLine(to: CGPoint(x: xPos(i, width: w), y: yPos(data[i].p85, height: h, minV: minV, maxV: maxV)))
                    }
                    p.closeSubpath()
                }
                .fill(Color.bbMint.opacity(0.35))

                // P50 dashed
                Path { p in
                    p.move(to: CGPoint(x: xPos(0, width: w), y: yPos(data[0].p50, height: h, minV: minV, maxV: maxV)))
                    for i in data.indices.dropFirst() {
                        p.addLine(to: CGPoint(x: xPos(i, width: w), y: yPos(data[i].p50, height: h, minV: minV, maxV: maxV)))
                    }
                }
                .stroke(Color.bbMintDeep.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

                // Grid lines + y-labels
                ForEach(gridVals, id: \.self) { v in
                    let yg = yPos(Double(v), height: h, minV: minV, maxV: maxV)
                    Path { p in
                        p.move(to: CGPoint(x: padL, y: yg))
                        p.addLine(to: CGPoint(x: w - padR, y: yg))
                    }
                    .stroke(Color.bbInkMute.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [2, 4]))
                    Text("\(v)")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.bbInkMute)
                        .position(x: padL - 10, y: yg)
                }

                // Baby curve
                Path { p in
                    p.move(to: CGPoint(x: xPos(0, width: w), y: yPos(data[0].babyKg, height: h, minV: minV, maxV: maxV)))
                    for i in data.indices.dropFirst() {
                        p.addLine(to: CGPoint(x: xPos(i, width: w), y: yPos(data[i].babyKg, height: h, minV: minV, maxV: maxV)))
                    }
                }
                .stroke(Color.bbCoralDeep, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))

                // Dots
                ForEach(data.indices, id: \.self) { i in
                    let pt = CGPoint(x: xPos(i, width: w), y: yPos(data[i].babyKg, height: h, minV: minV, maxV: maxV))
                    let isLast = i == data.count - 1
                    Circle()
                        .fill(isLast ? Color.bbCoralDeep : Color.white)
                        .frame(width: isLast ? 9 : 5, height: isLast ? 9 : 5)
                        .overlay(Circle().strokeBorder(Color.bbCoralDeep, lineWidth: 2))
                        .position(pt)
                }

                // Current label
                let lastIdx = data.count - 1
                let lastPt = CGPoint(
                    x: xPos(lastIdx, width: w) - 18,
                    y: yPos(data[lastIdx].babyKg, height: h, minV: minV, maxV: maxV) - 16
                )
                Text(String(format: "%.1f кг", data[lastIdx].babyKg))
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.bbCoralDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .position(lastPt)

                // X labels
                ForEach(data.indices, id: \.self) { i in
                    Text("\(i) мес")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.bbInkMute)
                        .position(x: xPos(i, width: w), y: h - 4)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { TrackingView() }
}
