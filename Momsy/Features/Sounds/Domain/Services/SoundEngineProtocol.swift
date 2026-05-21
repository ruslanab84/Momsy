import Foundation

@MainActor
protocol SoundEngineProtocol: AnyObject {
    var onInterrupted: (() -> Void)? { get set }
    var onResumed: (() -> Void)? { get set }
    func play(_ sound: SoundItem)
    func stop()
}
