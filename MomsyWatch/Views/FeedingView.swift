import SwiftUI

struct FeedingView: View {
    @EnvironmentObject var session: WatchSessionManager

    var body: some View {
        Group {
            switch session.state.feeding {
            case .idle:
                sidePicker
            case .running(let start, let side):
                runningView(start: start, side: side, paused: false)
            case .paused(let secs, let side):
                pausedView(elapsed: secs, side: side)
            }
        }
        .navigationTitle(WatchStrings.feeding)
    }

    private var sidePicker: some View {
        VStack(spacing: 8) {
            sideButton(token: "left",   icon: "l.circle.fill")
            sideButton(token: "right",  icon: "r.circle.fill")
            sideButton(token: "bottle", icon: "waterbottle.fill")
        }
        .padding(.horizontal, 4)
    }

    private func sideButton(token: String, icon: String) -> some View {
        Button {
            session.send(.startFeeding(side: token), haptic: .start)
        } label: {
            Label(WatchStrings.sideLabel(token: token), systemImage: icon)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }

    private func runningView(start: Date, side: String, paused: Bool) -> some View {
        VStack(spacing: 10) {
            Text(WatchStrings.sideLabel(token: side)).font(.caption).foregroundStyle(.secondary)
            Text(start, style: .timer)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .monospacedDigit()
            HStack(spacing: 8) {
                Button { session.send(.pauseFeeding, haptic: .click) } label: {
                    Image(systemName: "pause.fill").frame(maxWidth: .infinity)
                }
                Button { session.send(.stopFeeding, haptic: .success) } label: {
                    Image(systemName: "stop.fill").frame(maxWidth: .infinity)
                }
                .tint(.red)
            }
        }
        .padding(.horizontal, 4)
    }

    private func pausedView(elapsed: Int, side: String) -> some View {
        VStack(spacing: 10) {
            Text(WatchStrings.sideLabel(token: side)).font(.caption).foregroundStyle(.secondary)
            Text(timeString(elapsed))
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Button { session.send(.resumeFeeding, haptic: .start) } label: {
                    Image(systemName: "play.fill").frame(maxWidth: .infinity)
                }
                Button { session.send(.stopFeeding, haptic: .success) } label: {
                    Image(systemName: "stop.fill").frame(maxWidth: .infinity)
                }
                .tint(.red)
            }
        }
        .padding(.horizontal, 4)
    }

    private func timeString(_ secs: Int) -> String {
        String(format: "%02d:%02d", secs / 60, secs % 60)
    }
}
