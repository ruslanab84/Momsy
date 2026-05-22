import SwiftUI

struct MeView: View {
    @EnvironmentObject private var lm: LocalizationManager
    @EnvironmentObject private var appState: AppState
    @Environment(\.appContainer) private var container
    @State private var showEditProfile = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                babyProfileCard
                meSection(rows: [
                    MeRow(destination: SharingView(container: container),
                          icon: "person.3.fill", bg: .bbCoral,
                          title: lm.strings.family,
                          sub: lm.strings.familyMembersHint),
                    MeRow(destination: SoundsView(container: container),
                          icon: "music.note", bg: .bbLilac,
                          title: lm.strings.lullabiesSounds,
                          sub: lm.strings.lullabiesHint),
                ])
                meSection(rows: [
                    MeRow(destination: SettingsView(),
                          icon: "gearshape.fill", bg: .bbSky,
                          title: lm.strings.settings,
                          sub: lm.strings.settingsHint),
                ])
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.strings.profile)
        .sheet(isPresented: $showEditProfile) {
            if let profile = appState.babyProfile {
                EditBabyProfileView(profile: profile)
                    .environmentObject(lm)
                    .environmentObject(appState)
                    .environment(\.appContainer, container)
            }
        }
    }

    // MARK: - Baby Profile Card

    private var babyProfileCard: some View {
        HStack(spacing: 14) {
            CuteBlobView(kind: .baby, size: 56, tone: .bbCoral)
            VStack(alignment: .leading, spacing: 2) {
                Text(appState.displayName)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                if !appState.babyAgeString(lang: lm.lang).isEmpty {
                    Text(appState.babyAgeString(lang: lm.lang))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                }
            }
            Spacer()
            Button {
                showEditProfile = true
            } label: {
                Text(lm.strings.editProfile)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.bbCoralDeep)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.bbCoral.opacity(0.15))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(appState.babyProfile == nil)
        }
        .bbCard(pad: 16)
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
