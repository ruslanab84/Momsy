import AVFoundation

/// Pure DSP synthesis + filter state for the sound engine.
/// Not main-actor isolated: every access is serialized by SoundEngine's audio queue,
/// keeping the per-sample loop off the main thread.
final class SoundSynthesizer: @unchecked Sendable {
    private let format: AVAudioFormat
    private var frameOffset = 0

    private var pinkB = [Double](repeating: 0, count: 7)
    private var rainLP = 0.0
    private var oceanLP = 0.0
    private var forestLP = 0.0
    private var brookLP = 0.0
    private var wombLP = 0.0
    private var nextChirpT = 1.5

    init(format: AVAudioFormat) { self.format = format }

    func reset() {
        frameOffset = 0
        pinkB = [Double](repeating: 0, count: 7)
        rainLP = 0; oceanLP = 0; forestLP = 0; brookLP = 0; wombLP = 0
        nextChirpT = Double.random(in: 1...3)
    }

    func makeBuffer(for sound: SoundItem) -> AVAudioPCMBuffer? {
        let sr = format.sampleRate
        let nFrames = AVAudioFrameCount(sr * 3)
        guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: nFrames),
              let data = buf.floatChannelData else { return nil }
        buf.frameLength = nFrames

        let nCh = Int(format.channelCount)
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
            case "rain": return rain(t: t)
            case "ocean": return ocean(t: t)
            case "forest": return forest(t: t)
            case "brook", "stream": return brook(t: t)
            default: return pinkNoise()
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
        let p = pinkB[0] + pinkB[1] + pinkB[2] + pinkB[3] + pinkB[4] + pinkB[5] + pinkB[6] + w * 0.5362
        pinkB[6] = w * 0.115926
        return Float(p * 0.11)
    }

    private func heartbeat(t: Double) -> Float {
        let tp = t.truncatingRemainder(dividingBy: 1.0)
        var s = 0.0
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
        let noteDur = 0.75
        let totalDur = noteDur * Double(freqs.count)
        let tp = t.truncatingRemainder(dividingBy: totalDur)
        let noteIdx = Int(tp / noteDur) % freqs.count
        let nt = tp.truncatingRemainder(dividingBy: noteDur)
        let freq = freqs[noteIdx]

        let att = 0.05, rel = 0.2
        let env: Double
        if nt < att {
            env = nt / att
        } else if nt > noteDur - rel {
            env = (noteDur - nt) / rel
        } else {
            env = 1.0
        }

        let wave = sin(2 * .pi * freq * t)
            + sin(2 * .pi * freq * 2 * t) * 0.25
            + sin(2 * .pi * freq * 0.5 * t) * 0.08
        return Float(env * wave * 0.22)
    }
}
