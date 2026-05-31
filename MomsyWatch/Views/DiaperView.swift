import SwiftUI

struct DiaperView: View {
    @EnvironmentObject var session: WatchSessionManager

    var body: some View {
        VStack(spacing: 12) {
            Text("\(session.state.diaperCount)")
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .monospacedDigit()
            Text(WatchStrings.diapersToday)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Button {
                session.send(.logDiaper, haptic: .click)
            } label: {
                Label(WatchStrings.add, systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 4)
        .navigationTitle(WatchStrings.diaper)
    }
}
