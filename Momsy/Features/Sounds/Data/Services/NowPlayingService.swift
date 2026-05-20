import MediaPlayer

@MainActor
final class NowPlayingService {
    static let shared = NowPlayingService()

    private var onPlay: (() -> Void)?
    private var onPause: (() -> Void)?

    private init() {
        let rc = MPRemoteCommandCenter.shared()
        rc.playCommand.addTarget { [weak self] _ in
            self?.onPlay?()
            return .success
        }
        rc.pauseCommand.addTarget { [weak self] _ in
            self?.onPause?()
            return .success
        }
        rc.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.onPlay?()
            return .success
        }
        rc.stopCommand.addTarget { [weak self] _ in
            self?.onPause?()
            return .success
        }
    }

    func configure(onPlay: @escaping () -> Void, onPause: @escaping () -> Void) {
        self.onPlay = onPlay
        self.onPause = onPause
    }

    func update(soundName: String, category: String, isPlaying: Bool) {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: soundName,
            MPMediaItemPropertyAlbumTitle: category,
            MPMediaItemPropertyArtist: "Momsy",
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyIsLiveStream: true,
        ]
        if let art = makeArtwork() {
            info[MPMediaItemPropertyArtwork] = art
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func clear() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func makeArtwork() -> MPMediaItemArtwork? {
        guard let image = UIImage(systemName: "moon.fill") else { return nil }
        return MPMediaItemArtwork(boundsSize: CGSize(width: 100, height: 100)) { _ in image }
    }
}
