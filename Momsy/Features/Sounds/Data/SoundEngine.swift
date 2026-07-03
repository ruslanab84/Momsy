import AVFoundation

/// Streams lullaby sounds via AVAudioEngine using DSP synthesis - no audio files.
/// Orchestration only: all synthesis runs on `audioQueue` via `SoundSynthesizer`,
/// never on the main actor.
@MainActor
final class SoundEngine: SoundEngineProtocol {
    static let shared = SoundEngine()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let synth: SoundSynthesizer

    private let audioQueue = DispatchQueue(label: "com.momsy.sound.synth", qos: .userInitiated)
    private var genID = 0

    var onInterrupted: (() -> Void)?
    var onResumed: (() -> Void)?

    private init() {
        guard let fmt = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2) else {
            preconditionFailure("Unable to create sound output format")
        }
        self.synth = SoundSynthesizer(format: fmt)
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: fmt)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        setupInterruption()
    }

    // MARK: - Public

    func play(_ sound: SoundItem) {
        stop()
        try? AVAudioSession.sharedInstance().setActive(true)
        try? engine.start()
        player.play()

        genID += 1
        let gid = genID
        let synth = self.synth
        audioQueue.async { synth.reset() }
        scheduleNext(sound: sound, id: gid)
        scheduleNext(sound: sound, id: gid)
    }

    func stop() {
        genID += 1
        if engine.isRunning {
            player.stop()
            engine.stop()
        }
        try? AVAudioSession.sharedInstance()
            .setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Scheduling

    private func scheduleNext(sound: SoundItem, id: Int) {
        guard id == genID else { return }
        let synth = self.synth
        audioQueue.async { [weak self] in
            guard let buffer = synth.makeBuffer(for: sound) else { return }
            Task { @MainActor [weak self] in
                guard let self, id == self.genID else { return }
                await self.player.scheduleBuffer(buffer)
                guard id == self.genID else { return }
                self.scheduleNext(sound: sound, id: id)
            }
        }
    }

    // MARK: - Interruptions

    private func setupInterruption() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            MainActor.assumeIsolated {
                self?.handleInterruption(note)
            }
        }
    }

    private func handleInterruption(_ note: Notification) {
        guard let info = note.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        switch type {
        case .began:
            onInterrupted?()
        case .ended:
            let opts = (info[AVAudioSessionInterruptionOptionKey] as? UInt).map {
                AVAudioSession.InterruptionOptions(rawValue: $0)
            }
            if opts?.contains(.shouldResume) == true {
                try? AVAudioSession.sharedInstance().setActive(true)
                onResumed?()
            }
        @unknown default: break
        }
    }
}
