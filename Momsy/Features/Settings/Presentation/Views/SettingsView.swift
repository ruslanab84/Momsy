import SwiftUI

struct SettingsView: View {
    @StateObject private var vm: SettingsViewModel
    @EnvironmentObject private var lm: LocalizationManager
    @EnvironmentObject private var units: UnitSystemManager
    @Environment(\.openURL) private var openURL

    // TODO: replace with the public URL hosting PRIVACY.md before release.
    private let privacyPolicyURL = URL(string: "https://momsy.app/privacy")

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeSettingsViewModel())
    }

#if DEBUG
    @State private var iconShareItems: [Any] = []
    @State private var showIconShare = false
#endif

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                themeSection
                unitsSection
                languageSection
                aboutSection
#if DEBUG
                debugSection
#endif
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.strings.settings)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Theme

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: lm.strings.appTheme)

            HStack(spacing: 10) {
                themeCard(id: "light",  icon: "sun.max.fill",        label: lm.strings.themeLight, accent: .bbButter)
                themeCard(id: "system", icon: "circle.lefthalf.fill", label: lm.strings.themeAuto,  accent: .bbLilac)
                themeCard(id: "dark",   icon: "moon.fill",            label: lm.strings.themeDark,  accent: .bbSky)
            }

            Text(lm.strings.autoThemeHint)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkMute)
                .padding(.horizontal, 2)
        }
    }

    private func themeCard(id: String, icon: String, label: String, accent: Color) -> some View {
        let selected = vm.appTheme == id
        return Button {
            vm.setTheme(id)
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

    // MARK: - Units

    private var unitsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: lm.strings.unitSystem)

            HStack(spacing: 10) {
                unitCard(id: "metric",   icon: "scalemass",  label: lm.strings.unitMetric)
                unitCard(id: "imperial", icon: "ruler",       label: lm.strings.unitImperial)
            }

            Text(lm.strings.unitSystemHint)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkMute)
                .padding(.horizontal, 2)
        }
    }

    private func unitCard(id: String, icon: String, label: String) -> some View {
        let selected = vm.unitSystem == id
        return Button {
            vm.setUnitSystem(id)
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(selected ? Color.bbSky : Color.bbCream)
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
            BBSectionLabel(text: lm.strings.language)

            HStack(spacing: 14) {
                iconSquare(systemName: "globe", bg: .bbMint)
                Text(lm.strings.appLanguage)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInk)
                Spacer()
                Picker("", selection: $vm.appLanguage) {
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

            Text(lm.strings.languageComingSoon)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkMute)
                .padding(.horizontal, 2)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: lm.strings.about)

            VStack(spacing: 0) {
                infoRow(icon: "info.circle.fill",  bg: .bbSky,    title: lm.strings.version,       value: "1.0.0 (1)")
                Divider().opacity(0.2).padding(.leading, 60)
                infoRow(icon: "heart.fill",        bg: .bbRose,   title: lm.strings.madeWithLove,  value: lm.strings.forMoms)
                Divider().opacity(0.2).padding(.leading, 60)
                Button(action: openPrivacyPolicy) {
                    chevronRow(icon: "lock.shield.fill", bg: .bbMint,  title: lm.strings.privacy)
                }
                .buttonStyle(.plain)
                Divider().opacity(0.2).padding(.leading, 60)
                chevronRow(icon: "envelope.fill",    bg: .bbLilac, title: lm.strings.feedback)
            }
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .bbShadow()

            icloudSyncDisclosure
        }
    }

    private var icloudSyncDisclosure: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(lm.strings.icloudSyncTitle, systemImage: "icloud.fill")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.bbInk)
            Text(lm.strings.icloudSyncDisclosure)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkMute)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    private func openPrivacyPolicy() {
        guard let privacyPolicyURL else { return }
        openURL(privacyPolicyURL)
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

#if DEBUG
    // MARK: - Debug

    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: "Debug")

            Button {
                exportAppIcon()
            } label: {
                HStack(spacing: 14) {
                    iconSquare(systemName: "square.and.arrow.up", bg: .bbCoral)
                    Text("Export App Icon PNG")
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
            .buttonStyle(.plain)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .bbShadow()
            .sheet(isPresented: $showIconShare) {
                ActivityView(items: iconShareItems)
            }

            Text("Renders AppIconView at 1024×1024 — share to Mac and drop into AppIcon.appiconset.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkMute)
                .padding(.horizontal, 2)
        }
    }

    @MainActor
    private func exportAppIcon() {
        let renderer = ImageRenderer(content: AppIconView())
        renderer.scale = 1.0
        renderer.proposedSize = .init(width: 1024, height: 1024)
        guard let uiImage = renderer.uiImage else { return }
        iconShareItems = [uiImage]
        showIconShare = true
    }
#endif
}

#Preview {
    NavigationStack { SettingsView(container: AppContainer()) }
        .environmentObject(LocalizationManager.shared)
        .environmentObject(UnitSystemManager.shared)
}
