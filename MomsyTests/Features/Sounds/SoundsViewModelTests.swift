import Testing
@testable import Momsy
import Foundation

@Suite("SoundsViewModel", .serialized)
@MainActor
struct SoundsViewModelTests {

    func makeVM() -> (SoundsViewModel, MockSoundEngine) {
        let engine = MockSoundEngine()
        let vm = SoundsViewModel(
            soundRepository: MockSoundRepository(),
            sleepTimerUC: SleepTimerUseCase(),
            nowPlaying: NowPlayingService.shared,
            soundEngine: engine
        )
        return (vm, engine)
    }

    // MARK: - Playback

    @Test("play(idx) starts engine with correct sound")
    func playStartsEngine() {
        let (vm, engine) = makeVM()
        vm.play(0)
        #expect(engine.playedSounds.count == 1)
        #expect(engine.lastPlayed?.nameEn == vm.sounds[0].nameEn)
        #expect(vm.sounds[0].isPlaying)
        #expect(vm.anyPlaying)
    }

    @Test("play(idx) on playing sound stops it")
    func playTogglesSameIndex() {
        let (vm, engine) = makeVM()
        vm.play(0)
        vm.play(0)
        #expect(engine.stopCallCount == 1)
        #expect(!vm.anyPlaying)
        #expect(!vm.sounds[0].isPlaying)
    }

    @Test("play(idx) switches sound — previous stops, new starts")
    func playSwitch() {
        let (vm, engine) = makeVM()
        vm.play(0)
        vm.play(1)
        #expect(engine.playedSounds.count == 2)
        #expect(!vm.sounds[0].isPlaying)
        #expect(vm.sounds[1].isPlaying)
    }

    @Test("only one sound plays at a time")
    func onlyOnePlayingAtOnce() {
        let (vm, _) = makeVM()
        vm.play(0)
        vm.play(1)
        let playing = vm.sounds.filter { $0.isPlaying }
        #expect(playing.count == 1)
    }

    // MARK: - stopAll

    @Test("stopAll stops engine and clears playing state")
    func stopAllClearsState() {
        let (vm, engine) = makeVM()
        vm.play(0)
        vm.stopAll()
        #expect(engine.stopCallCount == 1)
        #expect(!vm.anyPlaying)
        #expect(vm.sounds.allSatisfy { !$0.isPlaying })
    }

    @Test("stopAll preserves lastPlayedIdx for resume")
    func stopAllPreservesLastPlayed() {
        let (vm, engine) = makeVM()
        vm.play(2)
        vm.stopAll()
        engine.simulateResume()
        #expect(vm.sounds[2].isPlaying)
    }

    // MARK: - Interruption

    @Test("interruption stops playback")
    func interruptionStopsPlayback() {
        let (vm, engine) = makeVM()
        vm.play(0)
        engine.simulateInterruption()
        #expect(!vm.anyPlaying)
        #expect(engine.stopCallCount == 1)
    }

    @Test("resume after interruption replays last sound")
    func resumeAfterInterruptionReplaysLastSound() {
        let (vm, engine) = makeVM()
        vm.play(0)
        engine.simulateInterruption()
        engine.simulateResume()
        #expect(vm.sounds[0].isPlaying)
        #expect(engine.playedSounds.count == 2)
    }

    @Test("resume without prior play does nothing")
    func resumeWithoutPriorPlayDoesNothing() {
        let (vm, engine) = makeVM()
        engine.simulateResume()
        #expect(!vm.anyPlaying)
        #expect(engine.playedSounds.isEmpty)
    }

    // MARK: - Favorites

    @Test("toggleFavorite marks then unmarks")
    func toggleFavoriteRoundTrips() {
        let (vm, _) = makeVM()
        let name = vm.sounds[0].nameEn
        #expect(!vm.sounds[0].isFavorite)
        vm.toggleFavorite(name)
        #expect(vm.sounds[0].isFavorite)
        vm.toggleFavorite(name)
        #expect(!vm.sounds[0].isFavorite)
    }

    @Test("toggleFavorite persists across view model instances")
    func toggleFavoritePersists() {
        let repo = MockSoundRepository()
        let engine = MockSoundEngine()
        let vm1 = SoundsViewModel(soundRepository: repo,
                                   sleepTimerUC: SleepTimerUseCase(),
                                   nowPlaying: NowPlayingService.shared,
                                   soundEngine: engine)
        vm1.toggleFavorite(vm1.sounds[0].nameEn)

        let vm2 = SoundsViewModel(soundRepository: repo,
                                   sleepTimerUC: SleepTimerUseCase(),
                                   nowPlaying: NowPlayingService.shared,
                                   soundEngine: MockSoundEngine())
        #expect(vm2.sounds[0].isFavorite)
    }

    // MARK: - Timer display

    @Test("timerDisplay shows continuous for ∞ selection")
    func timerDisplayInfinite() {
        let (vm, _) = makeVM()
        vm.selectedTimerIdx = 3
        #expect(vm.timerDisplay.contains("непрерывно") || vm.timerDisplay.contains("continuously"))
    }
}
