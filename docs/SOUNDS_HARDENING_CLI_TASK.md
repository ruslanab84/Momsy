# CLI Task: Sounds Feature — Correctness & Performance Hardening

**Severity:** P1 (main-thread DSP hitches, audio-session hijack) + P2 (Womb routing, timer drift, lock-screen toggle)
**Scope:** `Features/Sounds` only. SwiftUI/AVFoundation, async/await, existing DI. No API/Firebase changes.
**Approach:** Incremental. One new file (extract DSP), four focused edits. No behavior change to the public `SoundEngineProtocol`.

## Folder structure (delta)

```
Features/Sounds/
├── Data/
│   ├── SoundEngine.swift            (MODIFY — orchestration only, DSP removed)
│   ├── SoundSynthesizer.swift       (NEW — nonisolated DSP + filter state)
│   └── Services/
│       └── NowPlayingService.swift  (MODIFY — toggle respects play state)
├── Domain/
│   └── UseCases/
│       └── SleepTimerUseCase.swift  (MODIFY — deadline-based, drift-free)
```

---

## Problems

1. **P1 — DSP runs on `@MainActor`.** `SoundEngine` is `@MainActor`; `buildBuffer` synthesizes a 132,300-sample loop (`sin`/`exp` per sample) and its completion handler re-dispatches to `@MainActor` every 3s. Result: periodic main-thread hitches during playback (visible on scroll/animation).
2. **P1 — Audio session activated eagerly, never deactivated.** `setActive(true)` runs in the singleton `init()` (i.e. when the Sounds screen opens, before Play), interrupting other apps' audio. `stop()` never calls `setActive(false)`, so other apps' audio never auto-resumes.
3. **P2 — "Womb" plays plain white noise.** `SoundItem(nameEn: "Womb", categoryEn: "white noise")` routes to `whiteNoise()`; the dedicated `womb()` generator is dead code. Audio contradicts the Womb artwork.
4. **P2 — Sleep-timer drift.** Countdown decrements via a `Task.sleep(1s)` loop; accumulated scheduling overhead makes a 60-min timer stop noticeably late.
5. **P2 — Lock-screen toggle can't pause.** `togglePlayPauseCommand` always calls `onPlay`, so toggling while playing is a no-op.

---

### Task 1: Extract DSP into a nonisolated `SoundSynthesizer`

**Files:**
- Create: `Momsy/Features/Sounds/Data/SoundSynthesizer.swift`

- [ ] **Step 1: Create the file (verbatim)**

```swift
import AVFoundation

/// Pure DSP synthesis + filter state for the sound engine.
/// Not main-actor isolated: every access is serialized by SoundEngine's audio queue,
/// keeping the per-sample loop off the main thread.
final class SoundSynthesizer: @unchecked Sendable {
    private let format: AVAudioFormat
    private var frameOffset = 0

    private var pinkB    = [Double](repeating: 0, count: 7)
    private var rainLP   = 0.0
    private var oceanLP  = 0.0
    private var forestLP = 0.0
    private var brookLP  = 0.0
    private var wombLP   = 0.0
    private var nextChirpT = 1.5

    init(format: AVAudioFormat) { self.format = format }

    func reset() {
        frameOffset = 0
        pinkB       = [Double](repeating: 0, count: 7)
        rainLP = 0; oceanLP = 0; forestLP = 0; brookLP = 0; wombLP = 0
        nextChirpT  = Double.random(in: 1...3)
    }

    func makeBuffer(for sound: SoundItem) -> AVAudioPCMBuffer? {
        let sr      = format.sampleRate
        let nFrames = AVAudioFrameCount(sr * 3)
        guard let buf  = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: nFrames),
              let data = buf.floatChannelData else { return nil }
        buf.frameLength = nFrames

        let nCh   = Int(format.channelCount)
        let start = frameOffset
        for i in 0..<Int(nFrames) {
            let s = nextSample(sound: sound, absFrame: start + i, sr: sr)
            for ch in 0..<nCh { data[ch][i] = s }
        }
        frameOffset += Int(nFrames)
        return buf
    }

    private func nextSample(sound: SoundItem, absFrame: Int, sr: Double) -> Float {
        let t = Double(absFrame) / sr
        // Route by name first so "Womb" gets its dedicated generator regardless of
        // its display category.
        if sound.nameEn.lowercased() == "womb" { return womb(t: t) }

        switch sound.categoryEn {
        case "white noise":
            return whiteNoise()
        case "pink noise":
            return pinkNoise()
        case "melody":
            return melody(t: t)
        case "for newborns":
            return sound.nameEn.lowercased() == "heartbeat" ? heartbeat(t: t) : womb(t: t)
        case "nature":
            switch sound.nameEn.lowercased() {
            case "rain":            return rain(t: t)
            case "ocean":           return ocean(t: t)
            case "forest":          return forest(t: t)
            case "brook", "stream": return brook(t: t)
            default:                return pinkNoise()
            }
        default:
            return whiteNoise()
        }
    }

    // MARK: - Generators

    private func whiteNoise() -> Float { .random(in: -0.35...0.35) }

    private func pinkNoise() -> Float {
        let w = Double(Float.random(in: -1...1))
        pinkB[0] = 0.99886 * pinkB[0] + w * 0.0555179
        pinkB[1] = 0.99332 * pinkB[1] + w * 0.0750759
        pinkB[2] = 0.96900 * pinkB[2] + w * 0.1538520
        pinkB[3] = 0.86650 * pinkB[3] + w * 0.3104856
        pinkB[4] = 0.55000 * pinkB[4] + w * 0.5329522
        pinkB[5] = -0.7616 * pinkB[5] - w * 0.0168980
        let p = pinkB[0]+pinkB[1]+pinkB[2]+pinkB[3]+pinkB[4]+pinkB[5]+pinkB[6] + w * 0.5362
        pinkB[6] = w * 0.115926
        return Float(p * 0.11)
    }

    private func heartbeat(t: Double) -> Float {
        let tp = t.truncatingRemainder(dividingBy: 1.0)
        var s  = 0.0
        if tp < 0.12 {
            s += sin(.pi * tp / 0.12) * exp(-tp * 20) * sin(2 * .pi * 55 * tp) * 0.9
        }
        let t2 = tp - 0.25
        if t2 >= 0 && t2 < 0.10 {
            s += sin(.pi * t2 / 0.10) * exp(-t2 * 25) * sin(2 * .pi * 50 * t2) * 0.65
        }
        return Float(s)
    }

    private func womb(t: Double) -> Float {
        let w = Double(Float.random(in: -1...1))
        wombLP = 0.015 * w + 0.985 * wombLP
        let mod = 0.85 + 0.15 * sin(2 * .pi * 1.0 * t)
        return Float(wombLP * mod * 0.9)
    }

    private func rain(t: Double) -> Float {
        let w = Double(Float.random(in: -1...1))
        rainLP = 0.04 * w + 0.96 * rainLP
        let mod = 0.65 + 0.35 * sin(2 * .pi * 0.23 * t) * sin(2 * .pi * 0.11 * t)
        return Float(rainLP * mod * 0.7)
    }

    private func ocean(t: Double) -> Float {
        let w = Double(Float.random(in: -1...1))
        oceanLP = 0.02 * w + 0.98 * oceanLP
        let swell = 0.4 + 0.6 * (0.5 + 0.5 * sin(2 * .pi * 0.07 * t + 0.5 * sin(2 * .pi * 0.03 * t)))
        return Float(oceanLP * swell * 0.8)
    }

    private func forest(t: Double) -> Float {
        let w = Double(Float.random(in: -1...1))
        forestLP = 0.06 * w + 0.94 * forestLP
        var chirp = 0.0
        if t >= nextChirpT && t < nextChirpT + 0.18 {
            let lt = t - nextChirpT
            chirp = sin(.pi * lt / 0.18) * sin(2 * .pi * 3_400 * lt) * 0.25
        } else if t > nextChirpT + 0.18 {
            nextChirpT = t + Double.random(in: 2...7)
        }
        return Float(forestLP * 0.18 + chirp)
    }

    private func brook(t: Double) -> Float {
        let w = Double(Float.random(in: -1...1))
        brookLP = 0.07 * w + 0.93 * brookLP
        let gurgle = 0.55 + 0.45 * sin(2 * .pi * 0.9 * t) * sin(2 * .pi * 1.4 * t) * sin(2 * .pi * 0.4 * t)
        return Float(brookLP * gurgle * 0.7)
    }

    private func melody(t: Double) -> Float {
        let freqs: [Double] = [523.25, 440.00, 392.00, 329.63, 293.66, 261.63, 329.63, 392.00]
        let noteDur  = 0.75
        let totalDur = noteDur * Double(freqs.count)
        let tp       = t.truncatingRemainder(dividingBy: totalDur)
        let noteIdx  = Int(tp / noteDur) % freqs.count
        let nt       = tp.truncatingRemainder(dividingBy: noteDur)
        let freq     = freqs[noteIdx]

        let att = 0.05, rel = 0.2
        let env: Double
        if      nt < att           { env = nt / att }
        else if nt > noteDur - rel { env = (noteDur - nt) / rel }
        else                       { env = 1.0 }

        let wave = sin(2 * .pi * freq * t)
                 + sin(2 * .pi * freq * 2 * t) * 0.25
                 + sin(2 * .pi * freq * 0.5 * t) * 0.08
        return Float(env * wave * 0.22)
    }
}
```

---

### Task 2: Slim `SoundEngine` to orchestration; move synthesis off-main + fix session lifecycle

**Files:**
- Modify: `Momsy/Features/Sounds/Data/SoundEngine.swift` (full replacement — DSP now lives in `SoundSynthesizer`)

- [ ] **Step 1: Replace the file (verbatim)**

```swift
import AVFoundation

/// Streams lullaby sounds via AVAudioEngine using DSP synthesis — no audio files.
/// Orchestration only: all synthesis runs on `audioQueue` via `SoundSynthesizer`,
/// never on the main actor.
@MainActor
final class SoundEngine: SoundEngineProtocol {
    static let shared = SoundEngine()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let format: AVAudioFormat
    private let synth: SoundSynthesizer

    // Serial queue owning every buffer build. Keeps the per-sample loop off main.
    private let audioQueue = DispatchQueue(label: "com.momsy.sound.synth", qos: .userInitiated)
    private var genID = 0  // main-actor confined; bumped on every play/stop

    var onInterrupted: (() -> Void)?
    var onResumed: (() -> Void)?

    private init() {
        let fmt = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        self.format = fmt
        self.synth  = SoundSynthesizer(format: fmt)
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: fmt)
        // Category only — activating here would interrupt other apps before Play.
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
        audioQueue.async { synth.reset() }   // serial → runs before the builds below
        scheduleNext(sound: sound, id: gid)  // buffer A
        scheduleNext(sound: sound, id: gid)  // buffer B — pre-fill to avoid a gap
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

    /// MainActor entry: builds the next buffer off-main, then hops back to schedule it.
    private func scheduleNext(sound: SoundItem, id: Int) {
        guard id == genID else { return }
        let synth = self.synth
        audioQueue.async { [weak self] in
            guard let buffer = synth.makeBuffer(for: sound) else { return }
            Task { @MainActor [weak self] in
                guard let self, id == self.genID else { return }
                self.player.scheduleBuffer(buffer) { [weak self] in
                    Task { @MainActor [weak self] in
                        self?.scheduleNext(sound: sound, id: id)
                    }
                }
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
            self?.handleInterruption(note)
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
```

- [ ] **Step 2: Build**

Run: ⌘B. Expected: builds clean; no strict-concurrency warnings (synth is `@unchecked Sendable`, main-actor state stays on main).

---

### Task 3: Deadline-based sleep timer (no drift)

**Files:**
- Modify: `Momsy/Features/Sounds/Domain/UseCases/SleepTimerUseCase.swift`

- [ ] **Step 1: Replace the `start` body**

```swift
import Foundation

final class SleepTimerUseCase {
    func start(
        seconds: Int,
        onTick: @escaping @Sendable (Int) -> Void,
        onFinish: @escaping @Sendable () -> Void
    ) -> Task<Void, Never> {
        Task {
            let deadline = Date().addingTimeInterval(TimeInterval(seconds))
            while !Task.isCancelled {
                let remaining = Int(deadline.timeIntervalSinceNow.rounded())
                guard remaining > 0 else { break }
                onTick(remaining)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            if !Task.isCancelled { onFinish() }
        }
    }
}
```

Remaining is derived from a fixed wall-clock deadline, so per-iteration `Task.sleep` overhead no longer accumulates. `SoundsViewModel` already seeds `timerSecondsLeft = secs` before the first tick, so the display stays correct.

---

### Task 4: Lock-screen toggle respects play state

**Files:**
- Modify: `Momsy/Features/Sounds/Data/Services/NowPlayingService.swift`

- [ ] **Step 1: Track play state**

After `private var onPause: (() -> Void)?`, add:

```swift
    private var isPlaying = false
```

- [ ] **Step 2: Fix the toggle target**

Replace:

```swift
        rc.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.onPlay?()
            return .success
        }
```

with:

```swift
        rc.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            if self.isPlaying { self.onPause?() } else { self.onPlay?() }
            return .success
        }
```

- [ ] **Step 3: Keep `isPlaying` in sync**

In `update(soundName:category:isPlaying:)`, add as the first line of the method body:

```swift
        self.isPlaying = isPlaying
```

In `clear()`, add as the first line:

```swift
        isPlaying = false
```

---

## Definition of Done

- [ ] `SoundEngine.swift` contains no per-sample loop; all generators live in `SoundSynthesizer.swift`.
- [ ] No synthesis runs on the main actor (buffer builds dispatched to `audioQueue`).
- [ ] Audio session activates only in `play()` and deactivates in `stop()` with `.notifyOthersOnDeactivation`.
- [ ] "Womb" routes to the `womb()` generator.
- [ ] Sleep timer derives remaining from a wall-clock deadline.
- [ ] Lock-screen toggle pauses when playing, resumes when stopped.
- [ ] `SoundEngineProtocol` unchanged; `SoundsViewModel` untouched.

## Manual QA

1. **No hitch:** Start a sound, scroll the sound list / trigger animations for ~30s → smooth, no periodic stutter every 3s.
2. **Continuity:** Play each sound ≥10s → seamless loop, no gap/click at 3s boundaries.
3. **Womb:** Play "Womb" → warm filtered rumble (not flat hiss); matches artwork.
4. **Session courtesy:** Play music in another app → open Sounds screen (don't press Play) → music keeps playing. Press Play → music stops. Press Stop → other app's audio resumes.
5. **Timer accuracy:** Set 15 min, note wall-clock start → audio stops within a few seconds of 15:00 (not a minute late).
6. **Lock-screen:** Play → lock → tap the toggle → pauses; tap again → resumes.

## Out of Scope (separate follow-up)

- **Sound-name localization:** `SoundItem.displayName(lang:)` returns Russian for de/es/fr/pt/zh (only RU/EN exist). A data-only translation pass for the 8 names + categories — track separately to keep this change focused.
