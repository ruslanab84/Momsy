import SwiftUI

struct SettingsView: View {
    @StateObject private var vm: SettingsViewModel
    @EnvironmentObject private var lm: LocalizationManager
    @EnvironmentObject private var units: UnitSystemManager
    @Environment(\.openURL) private var openURL

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeSettingsViewModel())
    }

    @State private var showDeleteConfirm = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                themeSection
                unitsSection
                languageSection
                vaccinationScheduleSection
                childrenSection
                aboutSection
                dangerSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.strings.settings)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            lm.strings.deleteAllDataConfirm,
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(lm.strings.deleteAllData, role: .destructive) {
                Task { await vm.deleteAllData() }
            }
            Button(lm.strings.cancel, role: .cancel) {}
        }
        .alert(lm.strings.deleteFailed, isPresented: Binding(
            get: { vm.deletionError != nil },
            set: { if !$0 { vm.deletionError = nil } }
        )) {
            Button("OK", role: .cancel) { vm.deletionError = nil }
        }
        .overlay {
            if vm.isDeleting {
                ZStack {
                    Color.black.opacity(0.35).ignoresSafeArea()
                    VStack(spacing: 14) {
                        ProgressView().tint(.white)
                        Text(lm.strings.deleting)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(28)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.isDeleting)
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
                Picker("", selection: $vm.appLanguage) {
                    ForEach(Language.allCases) { language in
                        Text("\(language.flag) \(language.displayName)").tag(language.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .tint(.bbCoralDeep)
                .frame(maxWidth: .infinity, alignment: .leading)
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

    // MARK: - Vaccination schedule

    private var vaccinationScheduleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: lm.strings.vaccinationSchedule)

            HStack(spacing: 14) {
                iconSquare(systemName: "syringe.fill", bg: .bbLilac)
                Picker("", selection: $vm.vaccinationScheduleKey) {
                    ForEach(vm.availableScheduleKeys) { key in
                        Text(key.displayName).tag(key.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .tint(.bbCoralDeep)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .bbShadow()

            Text(lm.strings.vaccinationScheduleHint)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkMute)
                .padding(.horizontal, 2)
        }
    }

    // MARK: - Children

    private var childrenSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: lm.strings.babyProfile)

            NavigationLink(destination: ManageChildrenView()) {
                chevronRow(
                    icon: "figure.2.and.child.holdinghands",
                    bg: .bbMint,
                    title: lm.strings.children
                )
            }
            .buttonStyle(.plain)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .bbShadow()

            Text(lm.strings.childrenSettingsHint)
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
                Button(action: openPrivacyPolicy) {
                    chevronRow(icon: "lock.shield.fill", bg: .bbMint,  title: lm.strings.privacy)
                }
                .buttonStyle(.plain)
                Divider().opacity(0.2).padding(.leading, 60)
                Button(action: openTermsOfUse) {
                    chevronRow(icon: "doc.plaintext.fill", bg: .bbSky, title: lm.strings.termsOfUse)
                }
                .buttonStyle(.plain)
                Divider().opacity(0.2).padding(.leading, 60)
                Button(action: openFeedback) {
                    chevronRow(icon: "envelope.fill",    bg: .bbLilac, title: lm.strings.feedback)
                }
                .buttonStyle(.plain)
            }
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .bbShadow()
        }
    }

    // MARK: - Data & Privacy

    private var dangerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: lm.strings.dangerZone)

            Button {
                showDeleteConfirm = true
            } label: {
                HStack(spacing: 14) {
                    iconSquare(systemName: "trash.fill", bg: .bbCoral)
                    Text(lm.strings.deleteAllData)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.bbCoralDeep)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.bbInkMute)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .disabled(vm.isDeleting)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .bbShadow()

            Text(lm.strings.deleteAllDataConfirm)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkMute)
                .padding(.horizontal, 2)
        }
    }

    private func openPrivacyPolicy() {
        guard let privacyPolicyURL = AppLegalLinks.privacyPolicyURL else { return }
        openURL(privacyPolicyURL)
    }

    private func openTermsOfUse() {
        guard let termsOfUseURL = AppLegalLinks.termsOfUseURL else { return }
        openURL(termsOfUseURL)
    }

    private func openFeedback() {
        guard let feedbackURL = AppLegalLinks.feedbackURL else { return }
        openURL(feedbackURL)
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
    NavigationStack { SettingsView(container: AppContainer()) }
        .environmentObject(LocalizationManager.shared)
        .environmentObject(UnitSystemManager.shared)
}
