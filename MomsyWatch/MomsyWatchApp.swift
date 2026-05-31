import SwiftUI

@main
struct MomsyWatchApp: App {
    @StateObject private var session = WatchSessionManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(session)
                .onAppear { session.activate() }
        }
    }
}
