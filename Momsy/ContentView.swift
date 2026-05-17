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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                // Prominent panic button
                NavigationLink(destination: SymptomView()) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 52, height: 52)
                                .overlay(
                                    Image(systemName: "cross.fill")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ТРЕВОЖНАЯ КНОПКА")
                                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white.opacity(0.75))
                                    .kerning(0.5)
                                Text("Что-то не так?")
                                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Text("Отметьте симптомы — получите подсказку. Не диагноз, а навигация.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(18)
                    .background(Color.bbCoralDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Color.bbCoralDeep.opacity(0.35), radius: 12, y: 6)
                }
                .buttonStyle(.plain)

                // Secondary items
                VStack(spacing: 1) {
                    DoctorMenuRow(
                        destination: ReportView(),
                        icon: "doc.text.fill",
                        iconColor: .bbSkyDeep,
                        iconBg: Color.bbSky.opacity(0.3),
                        title: "Отчёт для педиатра",
                        sub: "PDF за неделю — сон, кормление, вес"
                    )
                    Divider().padding(.leading, 60)
                    DoctorMenuRow(
                        destination: TrackingView(),
                        icon: "chart.xyaxis.line",
                        iconColor: .bbMintDeep,
                        iconBg: Color.bbMint.opacity(0.3),
                        title: "Рост и вес",
                        sub: "График по перцентилям ВОЗ"
                    )
                }
                .background(Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle("Доктор")
    }
}

private struct DoctorMenuRow<D: View>: View {
    let destination: D
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let title: String
    let sub: String

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconBg)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(iconColor)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(sub)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
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
