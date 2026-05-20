import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingDone") private var onboardingDone = false
    @Environment(\.appContainer) private var container

    var body: some View {
        if !onboardingDone {
            OnboardingView(container: container, onDone: { onboardingDone = true })
        } else {
            MainTabView()
        }
    }
}

#Preview {
    ContentView()
}
