import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var lm: LocalizationManager
    @Environment(\.appContainer) private var container
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(container: container)
                .tabItem { Label(lm.strings.today, systemImage: "sun.max.fill") }
                .tag(0)

            LeapsView(container: container)
                .tabItem { Label(lm.strings.tabLeaps, systemImage: "star.fill") }
                .tag(1)

            DiaryView(container: container)
                .tabItem { Label(lm.strings.diary, systemImage: "heart.fill") }
                .tag(2)

            NavigationStack {
                DoctorMenuView()
            }
            .tabItem { Label(lm.strings.tabDoctor, systemImage: "drop.fill") }
            .tag(3)

            NavigationStack {
                MeView()
            }
            .tabItem { Label(lm.strings.tabMe, systemImage: "person.circle.fill") }
            .tag(4)
        }
        .tint(.bbCoralDeep)
        .onOpenURL { url in
            switch url.host {
            case "feeding", "today": selectedTab = 0
            default: break
            }
        }
    }
}
