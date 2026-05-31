import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: WatchSessionManager

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    FeedingView()
                } label: {
                    QuickRow(icon: "drop.fill", title: WatchStrings.feeding, subtitle: feedingSubtitle)
                }
                NavigationLink {
                    SleepView()
                } label: {
                    QuickRow(icon: "moon.fill", title: WatchStrings.sleep, subtitle: sleepSubtitle)
                }
                NavigationLink {
                    DiaperView()
                } label: {
                    QuickRow(icon: "leaf.fill", title: WatchStrings.diaper,
                             subtitle: "\(session.state.diaperCount)")
                }
            }
            .navigationTitle(session.state.babyName.isEmpty ? "Momsy" : session.state.babyName)
        }
    }

    private var feedingSubtitle: String {
        switch session.state.feeding {
        case .running, .paused: return WatchStrings.stop.lowercased()
        case .idle(let date):
            guard let date else { return WatchStrings.tapToStart }
            return WatchStrings.lastFeeding + " " + relative(date)
        }
    }

    private var sleepSubtitle: String {
        if case .active = session.state.sleep { return WatchStrings.stop.lowercased() }
        return WatchStrings.tapToStart
    }

    private func relative(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }
}

struct QuickRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
