import SwiftUI

struct MeView: View {
    @EnvironmentObject private var lm: LocalizationManager
    @Environment(\.appContainer) private var container

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                meSection(rows: [
                    MeRow(destination: SharingView(container: container),
                          icon: "person.3.fill", bg: .bbCoral,
                          title: lm.t("Family", "Семья"),
                          sub: lm.t("Mom, dad, nanny, grandma", "Мама, папа, няня, бабушка")),
                    MeRow(destination: SoundsView(),
                          icon: "music.note", bg: .bbLilac,
                          title: lm.t("Lullabies & Sounds", "Колыбельные и шум"),
                          sub: lm.t("White noise, melodies, timer", "Белый шум, мелодии, таймер")),
                ])
                meSection(rows: [
                    MeRow(destination: SettingsView(),
                          icon: "gearshape.fill", bg: .bbSky,
                          title: lm.t("Settings", "Настройки"),
                          sub: lm.t("Theme, language", "Тема, язык")),
                ])
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.t("Profile", "Профиль"))
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

struct MeRow: View {
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
