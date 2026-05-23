import SwiftUI

// MARK: - WHO Line Chart

struct WHOLineChart: View {
    let data: [WHOPoint]
    let babyPoints: [BabyGrowthPoint]
    let gridVals: [Int]
    let unit: String

    private let padL: CGFloat = 32, padR: CGFloat = 8, padT: CGFloat = 12, padB: CGFloat = 22
    private let maxMonth: Int = 24

    private func xPos(month: Int, width: CGFloat) -> CGFloat {
        padL + CGFloat(month) / CGFloat(maxMonth) * (width - padL - padR)
    }

    private func yPos(_ v: Double, height: CGFloat, minV: Double, maxV: Double) -> CGFloat {
        let range = max(maxV - minV, 0.01)
        return padT + CGFloat(1 - (v - minV) / range) * (height - padT - padB)
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let whoVals = data.flatMap { [$0.p3, $0.p97] }
            let babyVals = babyPoints.map { $0.value }
            let allVals = whoVals + babyVals
            let minV = (allVals.min() ?? 2.5) - 0.5
            let maxV = (allVals.max() ?? 15.0) + 0.5
            let sorted = babyPoints.sorted { $0.month < $1.month }

            ZStack(alignment: .topLeading) {

                // Outer band: P3–P97
                Path { p in
                    guard let first = data.first else { return }
                    p.move(to: CGPoint(x: xPos(month: first.month, width: w), y: yPos(first.p3, height: h, minV: minV, maxV: maxV)))
                    for pt in data { p.addLine(to: CGPoint(x: xPos(month: pt.month, width: w), y: yPos(pt.p3, height: h, minV: minV, maxV: maxV))) }
                    for pt in data.reversed() { p.addLine(to: CGPoint(x: xPos(month: pt.month, width: w), y: yPos(pt.p97, height: h, minV: minV, maxV: maxV))) }
                    p.closeSubpath()
                }
                .fill(Color.bbMint.opacity(0.10))

                // Inner band: P15–P85
                Path { p in
                    guard let first = data.first else { return }
                    p.move(to: CGPoint(x: xPos(month: first.month, width: w), y: yPos(first.p15, height: h, minV: minV, maxV: maxV)))
                    for pt in data { p.addLine(to: CGPoint(x: xPos(month: pt.month, width: w), y: yPos(pt.p15, height: h, minV: minV, maxV: maxV))) }
                    for pt in data.reversed() { p.addLine(to: CGPoint(x: xPos(month: pt.month, width: w), y: yPos(pt.p85, height: h, minV: minV, maxV: maxV))) }
                    p.closeSubpath()
                }
                .fill(Color.bbMint.opacity(0.30))

                // Median P50
                Path { p in
                    guard let first = data.first else { return }
                    p.move(to: CGPoint(x: xPos(month: first.month, width: w), y: yPos(first.p50, height: h, minV: minV, maxV: maxV)))
                    for pt in data.dropFirst() { p.addLine(to: CGPoint(x: xPos(month: pt.month, width: w), y: yPos(pt.p50, height: h, minV: minV, maxV: maxV))) }
                }
                .stroke(Color.bbMintDeep.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

                // Grid lines
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
                        .position(x: padL - 12, y: yg)
                }

                // Baby measurement line
                if !sorted.isEmpty {
                    Path { p in
                        guard let first = sorted.first else { return }
                        p.move(to: CGPoint(x: xPos(month: first.month, width: w), y: yPos(first.value, height: h, minV: minV, maxV: maxV)))
                        for pt in sorted.dropFirst() { p.addLine(to: CGPoint(x: xPos(month: pt.month, width: w), y: yPos(pt.value, height: h, minV: minV, maxV: maxV))) }
                    }
                    .stroke(Color.bbCoralDeep, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))

                    ForEach(sorted.indices, id: \.self) { i in
                        let pt = sorted[i]
                        let isLast = i == sorted.count - 1
                        Circle()
                            .fill(isLast ? Color.bbCoralDeep : Color.white)
                            .frame(width: isLast ? 9 : 5, height: isLast ? 9 : 5)
                            .overlay(Circle().strokeBorder(Color.bbCoralDeep, lineWidth: 2))
                            .position(x: xPos(month: pt.month, width: w),
                                      y: yPos(pt.value, height: h, minV: minV, maxV: maxV))
                    }

                    if let last = sorted.last {
                        Text(String(format: "%.1f \(unit)", last.value))
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(Color.bbCoralDeep)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .position(x: xPos(month: last.month, width: w) - 24,
                                      y: yPos(last.value, height: h, minV: minV, maxV: maxV) - 16)
                    }
                }

                // X-axis labels at 0, 6, 12, 18, 24
                ForEach([0, 6, 12, 18, 24], id: \.self) { m in
                    Text("\(m)m")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.bbInkMute)
                        .position(x: xPos(month: m, width: w), y: h - 4)
                }
            }
        }
    }
}
