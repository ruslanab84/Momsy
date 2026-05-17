import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme")    private var appTheme    = "system"
    @AppStorage("appLanguage") private var appLanguage = "en"

    private func t(_ en: String, _ ru: String) -> String { appLanguage == "en" ? en : ru }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                themeSection
                languageSection
                aboutSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(t("Settings", "Настройки"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Theme

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: t("App Theme", "Тема приложения"))

            HStack(spacing: 10) {
                themeCard(id: "light",  icon: "sun.max.fill",        label: t("Light", "Светлая"), accent: .bbButter)
                themeCard(id: "system", icon: "circle.lefthalf.fill", label: t("Auto",  "Авто"),    accent: .bbLilac)
                themeCard(id: "dark",   icon: "moon.fill",            label: t("Dark",  "Тёмная"),  accent: .bbSky)
            }

            Text(t("Auto follows the system appearance.", "Авто — следует системной теме устройства."))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkMute)
                .padding(.horizontal, 2)
        }
    }

    private func themeCard(id: String, icon: String, label: String, accent: Color) -> some View {
        let selected = appTheme == id
        return Button {
            withAnimation(.spring(response: 0.3)) { appTheme = id }
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(selected ? accent : Color.bbCream)
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(selected ? .bbInk : .bbInkSoft)
                }
                Text(label)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(selected ? .bbCoralDeep : .bbInkSoft)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(selected ? Color.bbCoralDeep : Color.clear, lineWidth: 2.5)
            )
            .bbShadow()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Language

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: t("Language", "Язык"))

            HStack(spacing: 14) {
                iconSquare(systemName: "globe", bg: .bbMint)
                Text(t("App Language", "Язык приложения"))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInk)
                Spacer()
                Picker("", selection: $appLanguage) {
                    Text("🇬🇧 English").tag("en")
                    Text("🇷🇺 Русский").tag("ru")
                    Text("🇩🇪 Deutsch").tag("de")
                    Text("🇪🇸 Español").tag("es")
                }
                .pickerStyle(.menu)
                .tint(.bbCoralDeep)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .bbShadow()

            Text(t("Deutsch, Español — coming soon.", "English, Deutsch, Español — скоро."))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkMute)
                .padding(.horizontal, 2)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: t("About", "О приложении"))

            VStack(spacing: 0) {
                infoRow(icon: "info.circle.fill",  bg: .bbSky,    title: t("Version", "Версия"),               value: "1.0.0 (1)")
                Divider().opacity(0.2).padding(.leading, 60)
                infoRow(icon: "heart.fill",        bg: .bbRose,   title: t("Made with love", "Сделано с любовью"),    value: t("for moms", "для мам"))
                Divider().opacity(0.2).padding(.leading, 60)
                chevronRow(icon: "lock.shield.fill", bg: .bbMint,  title: t("Privacy", "Конфиденциальность"))
                Divider().opacity(0.2).padding(.leading, 60)
                chevronRow(icon: "envelope.fill",    bg: .bbLilac, title: t("Contact Us", "Написать нам"))
            }
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .bbShadow()
        }
    }

    private func infoRow(icon: String, bg: Color, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            iconSquare(systemName: icon, bg: bg)
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.bbInk)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkMute)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func chevronRow(icon: String, bg: Color, title: String) -> some View {
        HStack(spacing: 14) {
            iconSquare(systemName: icon, bg: bg)
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.bbInk)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.bbInkMute)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func iconSquare(systemName: String, bg: Color) -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(bg)
            .frame(width: 36, height: 36)
            .overlay(
                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            )
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
