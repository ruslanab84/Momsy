import SwiftUI

struct EditBabyProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appContainer) private var container
    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject var appState: AppState

    @State private var babyName: String
    @State private var birthDate: Date
    @State private var gender: String
    @State private var isSaving = false
    @State private var saveError: String?
    @FocusState private var nameFocused: Bool

    private let profile: BabyProfile

    init(profile: BabyProfile) {
        self.profile = profile
        _babyName  = State(initialValue: profile.name)
        _birthDate = State(initialValue: profile.birthDate)
        _gender    = State(initialValue: profile.gender)
    }

    private struct GenderOption: Identifiable {
        let id: String
        let icon: BabyGenderIconKind
        let label: (L10n) -> String
        let color: Color
    }

    private var genderOptions: [GenderOption] {
        [
            GenderOption(id: "boy",     icon: .boy,     label: { $0.genderBoy },     color: .bbSky),
            GenderOption(id: "girl",    icon: .girl,    label: { $0.genderGirl },    color: .bbCoral),
            GenderOption(id: "unknown", icon: .unknown, label: { $0.genderUnknown }, color: .bbButter),
        ]
    }

    private var ageDescription: String {
        let comps = Calendar.current.dateComponents([.month, .day], from: birthDate, to: Date())
        let months = comps.month ?? 0
        let days   = comps.day ?? 0
        if months == 0 { return "\(days) \(loc.strings.unitDay)" }
        return "\(months) \(loc.strings.unitMonth) \(days) \(loc.strings.unitDay)"
    }

    private var isValid: Bool {
        !babyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    nameSection
                    genderSection
                    dateSection
                    saveButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color.bbCream.ignoresSafeArea())
            .navigationTitle(loc.strings.babyProfile)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }
                        .foregroundColor(.bbInkSoft)
                }
            }
        }
        .errorToast($saveError)
    }

    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.strings.babyNameLabel)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.6)

            TextField(loc.strings.babyNamePlaceholder, text: $babyName)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
                .tint(.bbCoralDeep)
                .focused($nameFocused)
                .submitLabel(.done)
                .onSubmit { nameFocused = false }
                .padding(16)
                .background(Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            nameFocused ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.15),
                            lineWidth: nameFocused ? 2 : 1.5
                        )
                )
                .bbShadowSoft()
        }
    }

    // MARK: - Gender

    private var genderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.strings.genderLabel)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.6)

            HStack(spacing: 10) {
                ForEach(genderOptions) { option in
                    let isSelected = gender == option.id
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            gender = isSelected ? "" : option.id
                        }
                    } label: {
                        VStack(spacing: 6) {
                            BabyGenderIconView(kind: option.icon, size: 36, tone: option.color)
                            Text(option.label(loc.strings))
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundColor(.bbInk)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isSelected ? option.color.opacity(0.18) : Color.bbCard)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(isSelected ? option.color : Color.bbInkMute.opacity(0.12), lineWidth: isSelected ? 2 : 1.5)
                        )
                        .bbShadowSoft()
                        .scaleEffect(isSelected ? 1.03 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Date

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.strings.dateOfBirthLabel)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.6)

            VStack(spacing: 12) {
                DatePicker(
                    "",
                    selection: $birthDate,
                    in: Calendar.current.date(byAdding: .year, value: -3, to: Date())!...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(.bbCoralDeep)
                .padding(.horizontal, 8)

                HStack {
                    CuteBlobView(kind: .baby, size: 32, tone: .bbCoral)
                    Text(loc.strings.ageDescription(ageDescription))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInk)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .bbShadowSoft()
        }
    }

    // MARK: - Save

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Group {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text(loc.strings.saveChanges)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(isValid ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .disabled(!isValid || isSaving)
        .animation(.easeInOut(duration: 0.2), value: isValid)
    }

    private func save() {
        let trimmed = babyName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isSaving = true
        var updated = profile
        updated.name      = trimmed
        updated.birthDate = birthDate
        updated.gender    = gender
        Task {
            do {
                try await container.saveBabyProfile.execute(updated)
                appState.update(updated)
                try? await container.babySyncRepository.syncBabyProfile(updated)
                dismiss()
            } catch {
                saveError = error.localizedDescription
            }
            isSaving = false
        }
    }
}
