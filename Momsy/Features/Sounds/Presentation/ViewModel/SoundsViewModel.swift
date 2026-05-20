import SwiftUI
import Combine

@MainActor
final class SoundsViewModel: ObservableObject {
    @Published var sounds = sampleSounds
    @Published var selectedTimerIdx = 3
    @Published var timerSecondsLeft: Int = 0

    private let timerDurations = [15 * 60, 30 * 60, 60 * 60, 0]
    private var countdownTask: Task<Void, Never>? = nil

    private var lm: LocalizationManager { .shared }

    var anyPlaying: Bool { sounds.contains { $0.isPlaying } }
    var nowPlaying: SoundItem? { sounds.first { $0.isPlaying } }

    var timerLabels: [String] {
        ["15 \(lm.t("min", "мин"))", "30 \(lm.t("min", "мин"))", "1 \(lm.t("hr", "ч"))", "∞"]
    }

    var timerDisplay: String {
        if selectedTimerIdx == 3 { return lm.t("playing continuously", "играет непрерывно") }
        if timerSecondsLeft <= 0 { return "—" }
        let m = timerSecondsLeft / 60
        if m >= 60 {
            let h = m / 60; let rem = m % 60
            return rem == 0
                ? "\(h) \(lm.t("hr to stop", "ч до выкл."))"
                : "\(h) \(lm.t("hr", "ч")) \(rem) \(lm.t("min to stop", "мин до выкл."))"
        }
        return "\(m) \(lm.t("min", "мин")) \(String(format: "%02d", timerSecondsLeft % 60)) \(lm.t("sec to stop", "с до выкл."))"
    }

    func play(_ idx: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            if sounds[idx].isPlaying {
                sounds[idx].isPlaying = false
                SoundEngine.shared.stop()
                stopCountdown()
            } else {
                for j in sounds.indices { sounds[j].isPlaying = false }
                sounds[idx].isPlaying = true
                SoundEngine.shared.play(sounds[idx])
                startCountdown(for: selectedTimerIdx)
            }
        }
    }

    func stopAll() {
        withAnimation(.easeOut(duration: 0.35)) {
            for i in sounds.indices { sounds[i].isPlaying = false }
        }
        SoundEngine.shared.stop()
        stopCountdown()
    }

    func selectTimer(_ idx: Int) {
        withAnimation(.spring(response: 0.25)) { selectedTimerIdx = idx }
        if anyPlaying { startCountdown(for: idx) }
    }

    private func startCountdown(for idx: Int) {
        countdownTask?.cancel()
        let secs = timerDurations[idx]
        timerSecondsLeft = secs
        guard secs > 0 else { return }
        countdownTask = Task {
            while !Task.isCancelled, timerSecondsLeft > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                timerSecondsLeft = max(0, timerSecondsLeft - 1)
                if timerSecondsLeft == 0 { stopAll() }
            }
        }
    }

    func stopCountdown() {
        countdownTask?.cancel()
        countdownTask = nil
        timerSecondsLeft = 0
    }
}
