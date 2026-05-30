import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingDone") private var onboardingDone = false
    @AppStorage("paywallShown") private var paywallShown = false
    @Environment(\.appContainer) private var container
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            } else if !onboardingDone {
                OnboardingView(container: container, onDone: { onboardingDone = true })
                    .transition(.opacity)
            } else if !paywallShown {
                PaywallView(
                    subscriptionManager: container.subscriptionManager,
                    onComplete: { paywallShown = true }
                )
                .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showSplash)
        .animation(.easeInOut(duration: 0.35), value: onboardingDone)
        .animation(.easeInOut(duration: 0.35), value: paywallShown)
        .task {
            try? await Task.sleep(for: .seconds(2.2))
            showSplash = false
        }
    }
}

#Preview {
    ContentView()
}
