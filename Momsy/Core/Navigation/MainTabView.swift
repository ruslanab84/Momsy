import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var lm: LocalizationManager
    @Environment(\.appContainer) private var container

    var body: some View {
        TabView {
            TodayView(container: container)
                .tabItem { Label(lm.strings.today, systemImage: "sun.max.fill") }

            LeapsView(container: container)
                .tabItem { Label(lm.strings.tabLeaps, systemImage: "star.fill") }

            DiaryView(container: container)
                .tabItem { Label(lm.strings.diary, systemImage: "heart.fill") }

            NavigationStack {
                DoctorMenuView()
            }
            .tabItem { Label(lm.strings.tabDoctor, systemImage: "drop.fill") }

            NavigationStack {
                MeView()
            }
            .tabItem { Label(lm.strings.tabMe, systemImage: "person.circle.fill") }
        }
        .tint(.bbCoralDeep)
    }
}
