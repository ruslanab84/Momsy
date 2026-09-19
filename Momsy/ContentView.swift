import Combine
import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingDone") private var onboardingDone = false
    @Environment(\.appContainer) private var container
    @Environment(\.scenePhase) private var scenePhase
    @Binding private var widgetFeatureRoute: WidgetFeatureRoute?
    @State private var showSplash = true
    // Routed straight off the manager: a @State mirror fed by .onReceive stayed on the
    // paywall after the manager had already published requiresPurchase -> premium.
    @ObservedObject private var subscriptionManager: SubscriptionManager

    init(
        subscriptionManager: SubscriptionManager,
        widgetFeatureRoute: Binding<WidgetFeatureRoute?> = .constant(nil)
    ) {
        self.subscriptionManager = subscriptionManager
        _widgetFeatureRoute = widgetFeatureRoute
    }

    private var premiumAccessState: PremiumAccessState { subscriptionManager.accessState }

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
            } else if premiumAccessState == .requiresPurchase {
                PaywallView(
                    subscriptionManager: subscriptionManager,
                    pendingInviteStore: PendingFamilyInviteStore(),
                    joinFamily: { code in
                        try await container.joinFamilyFromOnboarding(code: code)
                    },
                    allowsSkip: false,
                    onComplete: {}
                )
                .transition(.opacity)
            } else {
                MainTabView(widgetFeatureRoute: $widgetFeatureRoute)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showSplash)
        .animation(.easeInOut(duration: 0.35), value: onboardingDone)
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task { await subscriptionManager.refreshAccess() }
        }
        .task {
            try? await Task.sleep(for: .seconds(2.2))
            showSplash = false
        }
    }
}

#Preview {
    let container = AppContainer()

    ContentView(subscriptionManager: container.subscriptionManager)
        .withContainer(container)
        .environmentObject(LocalizationManager.shared)
        .environmentObject(UnitSystemManager.shared)
        .environmentObject(container.appState)
        .withLocalization(LocalizationManager.shared)
}

enum PaywallPresentationState {
    private static let paywallShownKey = "paywallShown"

    static func resetForAuthenticationChange(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: paywallShownKey)
    }
}
