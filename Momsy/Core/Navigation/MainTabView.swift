import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var lm: LocalizationManager
    @Environment(\.appContainer) private var container

    var body: some View {
        TabView {
            TodayView(container: container)
                .tabItem { Label(lm.t("Today", "Сегодня"), systemImage: "sun.max.fill") }

            LeapsView()
                .tabItem { Label(lm.t("Leaps", "Скачки"), systemImage: "star.fill") }

            DiaryView(container: container)
                .tabItem { Label(lm.t("Diary", "Дневник"), systemImage: "heart.fill") }

            NavigationStack {
                DoctorMenuView()
            }
            .tabItem { Label(lm.t("Doctor", "Доктор"), systemImage: "drop.fill") }

            NavigationStack {
                MeView()
            }
            .tabItem { Label(lm.t("Me", "Я"), systemImage: "person.circle.fill") }
        }
        .tint(.bbCoralDeep)
    }
}
