import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingDone") private var onboardingDone = false
    @State private var paywallShown = UserDefaults.standard.bool(forKey: "paywallShown")
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
                    onComplete: {
                        UserDefaults.standard.set(true, forKey: "paywallShown")
                        withAnimation(.easeInOut(duration: 0.35)) { paywallShown = true }
                    }
                )
                .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showSplash)
        .animation(.easeInOut(duration: 0.35), value: onboardingDone)
        .task {
            try? await Task.sleep(for: .seconds(2.2))
            showSplash = false
        }
    }
}

#Preview {
    ContentView()
}
