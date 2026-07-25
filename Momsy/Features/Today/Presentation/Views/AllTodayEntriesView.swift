import SwiftUI

struct AllTodayEntriesView: View {
    let entries: [LogEntry]

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject private var units: UnitSystemManager

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    if entries.isEmpty {
                        emptyState
                    } else {
                        ForEach(entries) { entry in
                            entryRow(entry)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.bbCream.ignoresSafeArea())
            .navigationTitle(loc.strings.todaySoFar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.close) { dismiss() }
                        .foregroundColor(.bbInkSoft)
                }
            }
        }
    }

    // MARK: - Entry Row

    private func entryRow(_ entry: LogEntry) -> some View {
        HStack(spacing: 12) {
            Text(entry.time, format: units.current.timeFormatStyle())
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.bbInkMute)
                .frame(width: units.isImperial ? 68 : 44, alignment: .leading)
            CuteBlobView(kind: entry.kind, size: 32, tone: entry.kind.defaultTone)
            Text(entry.label)
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

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            CuteBlobView(kind: .baby, size: 64, tone: .bbCoral)
            Text(loc.strings.noEntriesYet)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

#Preview {
    AllTodayEntriesView(entries: [
        LogEntry(time: Date(), kind: .bottle, label: "Left · 18 min"),
        LogEntry(time: Date().addingTimeInterval(-3600), kind: .sleep, label: "Sleep · 1 h 20 min"),
        LogEntry(time: Date().addingTimeInterval(-7200), kind: .drop, label: "Diaper #3"),
    ])
    .environmentObject(LocalizationManager.shared)
    .environmentObject(UnitSystemManager.shared)
}
