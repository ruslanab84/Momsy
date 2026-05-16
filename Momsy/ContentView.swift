import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingDone") private var onboardingDone = false

    var body: some View {
        if !onboardingDone {
            OnboardingView(onDone: { onboardingDone = true })
        } else {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Сегодня", systemImage: "sun.max.fill") }

            LeapsView()
                .tabItem { Label("Скачки", systemImage: "star.fill") }

            DiaryView()
                .tabItem { Label("Дневник", systemImage: "heart.fill") }

            NavigationStack {
                DoctorMenuView()
            }
            .tabItem { Label("Доктор", systemImage: "drop.fill") }

            NavigationStack {
                MeView()
            }
            .tabItem { Label("Я", systemImage: "person.circle.fill") }
        }
        .tint(.bbCoralDeep)
    }
}

// MARK: - Doctor Menu

struct DoctorMenuView: View {
    var body: some View {
        List {
            NavigationLink(destination: SymptomView()) {
                Label("Симптомы", systemImage: "cross.fill")
                    .foregroundColor(.bbCoralDeep)
            }
            NavigationLink(destination: ReportView()) {
                Label("Отчёт для педиатра", systemImage: "doc.text.fill")
                    .foregroundColor(.bbSkyDeep)
            }
            NavigationLink(destination: TrackingView()) {
                Label("Рост и вес", systemImage: "chart.xyaxis.line")
                    .foregroundColor(.bbMintDeep)
            }
        }
        .navigationTitle("Доктор")
        .background(Color.bbCream.ignoresSafeArea())
    }
}

// MARK: - Me / Profile Menu

struct MeView: View {
    var body: some View {
        List {
            NavigationLink(destination: SharingView()) {
                Label("Семья и роли", systemImage: "person.3.fill")
                    .foregroundColor(.bbCoralDeep)
            }
            NavigationLink(destination: SoundsView()) {
                Label("Колыбельные и шум", systemImage: "music.note")
                    .foregroundColor(.bbLilacDeep)
            }
        }
        .navigationTitle("Профиль")
        .background(Color.bbCream.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
}
