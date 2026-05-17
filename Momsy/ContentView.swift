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
    @AppStorage("appLanguage") private var lang = "en"
    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label(t("Today", "Сегодня"), systemImage: "sun.max.fill") }

            LeapsView()
                .tabItem { Label(t("Leaps", "Скачки"), systemImage: "star.fill") }

            DiaryView()
                .tabItem { Label(t("Diary", "Дневник"), systemImage: "heart.fill") }

            NavigationStack {
                DoctorMenuView()
            }
            .tabItem { Label(t("Doctor", "Доктор"), systemImage: "drop.fill") }

            NavigationStack {
                MeView()
            }
            .tabItem { Label(t("Me", "Я"), systemImage: "person.circle.fill") }
        }
        .tint(.bbCoralDeep)
    }
}

// MARK: - Doctor Menu

struct DoctorMenuView: View {
    @AppStorage("appLanguage") private var lang = "en"
    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
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
                                Text(t("PANIC BUTTON", "ТРЕВОЖНАЯ КНОПКА"))
                                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white.opacity(0.75))
                                    .kerning(0.5)
                                Text(t("Something wrong?", "Что-то не так?"))
                                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Text(t("Note symptoms — get guidance. Not a diagnosis, just navigation.",
                               "Отметьте симптомы — получите подсказку. Не диагноз, а навигация."))
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

                VStack(spacing: 1) {
                    DoctorMenuRow(
                        destination: ReportView(),
                        icon: "doc.text.fill",
                        iconColor: .bbSkyDeep,
                        iconBg: Color.bbSky.opacity(0.3),
                        title: t("Pediatrician Report", "Отчёт для педиатра"),
                        sub: t("PDF for the week — sleep, feeding, weight", "PDF за неделю — сон, кормление, вес")
                    )
                    Divider().padding(.leading, 60)
                    DoctorMenuRow(
                        destination: TrackingView(),
                        icon: "chart.xyaxis.line",
                        iconColor: .bbMintDeep,
                        iconBg: Color.bbMint.opacity(0.3),
                        title: t("Height & Weight", "Рост и вес"),
                        sub: t("WHO percentile chart", "График по перцентилям ВОЗ")
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
        .navigationTitle(t("Doctor", "Доктор"))
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
    @AppStorage("appLanguage") private var lang = "en"
    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                meSection(rows: [
                    MeRow(destination: SharingView(),
                          icon: "person.3.fill", bg: .bbCoral,
                          title: t("Family & Roles", "Семья и роли"),
                          sub: t("Mom, dad, nanny, grandma", "Мама, папа, няня, бабушка")),
                    MeRow(destination: SoundsView(),
                          icon: "music.note", bg: .bbLilac,
                          title: t("Lullabies & Sounds", "Колыбельные и шум"),
                          sub: t("White noise, melodies, timer", "Белый шум, мелодии, таймер")),
                ])
                meSection(rows: [
                    MeRow(destination: SettingsView(),
                          icon: "gearshape.fill", bg: .bbSky,
                          title: t("Settings", "Настройки"),
                          sub: t("Theme, language", "Тема, язык")),
                ])
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(t("Profile", "Профиль"))
    }

    private func meSection(rows: [MeRow]) -> some View {
        VStack(spacing: 0) {
            ForEach(rows.indices, id: \.self) { i in
                rows[i]
                if i < rows.count - 1 {
                    Divider().opacity(0.2).padding(.leading, 60)
                }
            }
        }
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .bbShadow()
    }
}

private struct MeRow: View {
    let destination: AnyView
    let icon: String
    let bg: Color
    let title: String
    let sub: String

    init<D: View>(destination: D, icon: String, bg: Color, title: String, sub: String) {
        self.destination = AnyView(destination)
        self.icon = icon
        self.bg = bg
        self.title = title
        self.sub = sub
    }

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(bg)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
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

#Preview {
    ContentView()
}
