import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingDone") private var onboardingDone = false
    @AppStorage("paywallShown") private var paywallShown = false
    @Environment(\.appContainer) private var container
    @Environment(\.scenePhase) private var scenePhase
    @Binding private var widgetFeatureRoute: WidgetFeatureRoute?
    @State private var showSplash = true
    @State private var premiumAccessState: PremiumAccessState = .resolving

    init(widgetFeatureRoute: Binding<WidgetFeatureRoute?> = .constant(nil)) {
        _widgetFeatureRoute = widgetFeatureRoute
    }

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            } else if !onboardingDone {
                OnboardingView(container: container, onDone: { onboardingDone = true })
                    .transition(.opacity)
            } else if premiumAccessState == .resolving {
                SplashView()
                    .transition(.opacity)
            } else if premiumAccessState == .requiresPurchase && !paywallShown {
                PaywallView(
                    subscriptionManager: container.subscriptionManager,
                    onComplete: {
                        withAnimation(.easeInOut(duration: 0.35)) { paywallShown = true }
                    }
                )
                .transition(.opacity)
            } else {
                MainTabView(widgetFeatureRoute: $widgetFeatureRoute)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showSplash)
        .animation(.easeInOut(duration: 0.35), value: onboardingDone)
        .onReceive(container.subscriptionManager.$accessState) { premiumAccessState = $0 }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task { await container.subscriptionManager.refreshAccess() }
        }
        .task {
            migrateLegacyPaywallStateIfNeeded()
            premiumAccessState = container.subscriptionManager.accessState
            await container.subscriptionManager.refreshAccess()
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
