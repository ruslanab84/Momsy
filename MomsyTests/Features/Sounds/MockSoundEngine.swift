@testable import Momsy
import Foundation

@MainActor
final class MockSoundEngine: SoundEngineProtocol {
    var onInterrupted: (() -> Void)?
    var onResumed: (() -> Void)?

    private(set) var playedSounds: [SoundItem] = []
    private(set) var stopCallCount = 0

    var lastPlayed: SoundItem? { playedSounds.last }

    func play(_ sound: SoundItem) {
        playedSounds.append(sound)
    }

    func stop() {
        stopCallCount += 1
    }

    func simulateInterruption() { onInterrupted?() }
    func simulateResume()       { onResumed?() }
}
