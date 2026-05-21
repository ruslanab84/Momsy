import SwiftUI
import Combine

@MainActor
final class SoundsViewModel: ObservableObject {
    @Published var sounds: [SoundItem] = []
    @Published var selectedTimerIdx = 3
    @Published var timerSecondsLeft: Int = 0

    private let soundRepository: any SoundRepository
    private let sleepTimerUC: SleepTimerUseCase
    private let nowPlaying: NowPlayingService
    private let soundEngine: any SoundEngineProtocol
    private var countdownTask: Task<Void, Never>? = nil
    private var favorites: Set<String> = []

    private let timerDurations = [15 * 60, 30 * 60, 60 * 60, 0]
    private var lm: LocalizationManager { .shared }
    private var lastPlayedIdx: Int?

    init(soundRepository: any SoundRepository,
         sleepTimerUC: SleepTimerUseCase,
         nowPlaying: NowPlayingService,
         soundEngine: any SoundEngineProtocol) {
        self.soundRepository = soundRepository
        self.sleepTimerUC = sleepTimerUC
        self.nowPlaying = nowPlaying
        self.soundEngine = soundEngine
        self.favorites = soundRepository.loadFavorites()
        self.sounds = sampleSounds.map { s in
            var copy = s
            copy.isFavorite = favorites.contains(s.nameEn)
            return copy
        }
        nowPlaying.configure(
            onPlay:  { [weak self] in self?.resumeIfStopped() },
            onPause: { [weak self] in self?.stopAll() }
        )
        soundEngine.onInterrupted = { [weak self] in self?.stopAll() }
        soundEngine.onResumed     = { [weak self] in self?.resumeIfStopped() }
    }

    var anyPlaying: Bool { sounds.contains { $0.isPlaying } }
    var nowPlayingItem: SoundItem? { sounds.first { $0.isPlaying } }

    var timerLabels: [String] {
        ["15 \(lm.strings.unitMin)", "30 \(lm.strings.unitMin)", "1 \(lm.strings.unitHr)", "∞"]
    }

    var timerDisplay: String {
        if selectedTimerIdx == 3 { return lm.strings.playingContinuously }
        if timerSecondsLeft <= 0 { return "—" }
        let m = timerSecondsLeft / 60
        if m >= 60 {
            let h = m / 60; let rem = m % 60
            return rem == 0
                ? "\(h) \(lm.strings.hrToStop)"
                : "\(h) \(lm.strings.unitHr) \(rem) \(lm.strings.minToStop)"
        }
        return "\(m) \(lm.strings.unitMin) \(String(format: "%02d", timerSecondsLeft % 60)) \(lm.strings.secToStop)"
    }

    func play(_ idx: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            if sounds[idx].isPlaying {
                sounds[idx].isPlaying = false
                lastPlayedIdx = nil
                soundEngine.stop()
                stopCountdown()
                nowPlaying.clear()
            } else {
                for j in sounds.indices { sounds[j].isPlaying = false }
                sounds[idx].isPlaying = true
                lastPlayedIdx = idx
                soundEngine.play(sounds[idx])
                startCountdown(for: selectedTimerIdx)
                nowPlaying.update(
                    soundName: sounds[idx].displayName(lang: lm.lang),
                    category: sounds[idx].displayCategory(lang: lm.lang),
                    isPlaying: true
                )
            }
        }
    }

    func stopAll() {
        withAnimation(.easeOut(duration: 0.35)) {
            for i in sounds.indices { sounds[i].isPlaying = false }
        }
        soundEngine.stop()
        stopCountdown()
        nowPlaying.clear()
        // lastPlayedIdx intentionally preserved — lock screen "play" and interruption resume need it
    }

    func selectTimer(_ idx: Int) {
        withAnimation(.spring(response: 0.25)) { selectedTimerIdx = idx }
        if anyPlaying { startCountdown(for: idx) }
    }

    func toggleFavorite(_ nameEn: String) {
        if favorites.contains(nameEn) {
            favorites.remove(nameEn)
        } else {
            favorites.insert(nameEn)
        }
        soundRepository.saveFavorites(favorites)
        for i in sounds.indices {
            sounds[i].isFavorite = favorites.contains(sounds[i].nameEn)
        }
    }

    func stopCountdown() {
        countdownTask?.cancel()
        countdownTask = nil
        timerSecondsLeft = 0
    }

    private func startCountdown(for idx: Int) {
        countdownTask?.cancel()
        let secs = timerDurations[idx]
        timerSecondsLeft = secs
        guard secs > 0 else { return }
        countdownTask = sleepTimerUC.start(
            seconds: secs,
            onTick: { [weak self] remaining in
                Task { @MainActor [weak self] in
                    self?.timerSecondsLeft = remaining
                }
            },
            onFinish: { [weak self] in
                Task { @MainActor [weak self] in
                    self?.stopAll()
                }
            }
        )
    }

    private func resumeIfStopped() {
        guard !anyPlaying, let idx = lastPlayedIdx else { return }
        play(idx)
    }
}
