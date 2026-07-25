import SwiftUI

struct LogReportDayList: View {
    let items: [LogReportItem]
    let emptyText: String
    @EnvironmentObject private var units: UnitSystemManager

    var body: some View {
        VStack(spacing: 10) {
            if items.isEmpty {
                Text(emptyText)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .bbCard(pad: 14)
            } else {
                ForEach(items) { item in
                    row(item)
                }
            }
        }
    }

    private func row(_ item: LogReportItem) -> some View {
        HStack(spacing: 12) {
            Text(item.start, format: units.current.timeFormatStyle())
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.bbInkMute)
                .frame(width: units.isImperial ? 68 : 44, alignment: .leading)
            CuteBlobView(kind: item.kind, size: 32, tone: item.kind.defaultTone)
            Text(item.label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInk)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .bbShadowSoft()
    }
}
