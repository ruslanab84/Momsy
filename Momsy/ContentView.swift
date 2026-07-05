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
                    onComplete: {
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
            migrateLegacyPaywallStateIfNeeded()
            try? await Task.sleep(for: .seconds(2.2))
            showSplash = false
        }
    }

    private func migrateLegacyPaywallStateIfNeeded() {
        if PaywallPresentationState.shouldSuppressInitialPaywallForExistingUser() {
            paywallShown = true
        }
    }
}

#Preview {
    let container = AppContainer()

    ContentView()
        .withContainer(container)
        .environmentObject(LocalizationManager.shared)
        .environmentObject(UnitSystemManager.shared)
        .environmentObject(container.appState)
        .withLocalization(LocalizationManager.shared)
}

private enum PaywallPresentationState {
    private static let onboardingDoneKey = "onboardingDone"
    private static let paywallShownKey = "paywallShown"
    private static let legacyMigrationKey = "paywallShownExistingUserMigrationDone"

    static func shouldSuppressInitialPaywallForExistingUser(defaults: UserDefaults = .standard) -> Bool {
        guard !defaults.bool(forKey: legacyMigrationKey) else { return false }
        defer { defaults.set(true, forKey: legacyMigrationKey) }

        let completedOnboarding = defaults.bool(forKey: onboardingDoneKey)
        let hasPaywallDecision = defaults.object(forKey: paywallShownKey) != nil
        return completedOnboarding && !hasPaywallDecision
    }
}
