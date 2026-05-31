import SwiftUI

struct SleepView: View {
    @EnvironmentObject var session: WatchSessionManager
    @State private var showQuality = false

    var body: some View {
        Group {
            switch session.state.sleep {
            case .idle:
                Button {
                    session.send(.startSleep, haptic: .start)
                } label: {
                    Label(WatchStrings.start, systemImage: "moon.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 4)
            case .active(let start):
                VStack(spacing: 10) {
                    Text(start, style: .timer)
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Button { showQuality = true } label: {
                        Label(WatchStrings.stop, systemImage: "stop.fill").frame(maxWidth: .infinity)
                    }
                    .tint(.red)
                }
                .padding(.horizontal, 4)
            }
        }
        .navigationTitle(WatchStrings.sleep)
        .sheet(isPresented: $showQuality) {
            QualitySheet { raw in
                session.send(.stopSleep(quality: raw), haptic: .success)
                showQuality = false
            }
        }
    }
}

private struct QualitySheet: View {
    let onPick: (String) -> Void

    var body: some View {
        List {
            Section(WatchStrings.quality) {
                row("good", WatchStrings.qualityGood, "hand.thumbsup.fill")
                row("normal", WatchStrings.qualityNormal, "equal.circle.fill")
                row("restless", WatchStrings.qualityRestless, "waveform.path.ecg")
            }
        }
    }

    private func row(_ raw: String, _ title: String, _ icon: String) -> some View {
        Button { onPick(raw) } label: {
            Label(title, systemImage: icon)
        }
    }
}
