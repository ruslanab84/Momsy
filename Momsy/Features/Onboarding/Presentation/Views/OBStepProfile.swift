import SwiftUI

// MARK: - Step 2: Baby Profile

struct ProfileStep: View {
    @Binding var babyName: String
    @Binding var birthDate: Date
    @Binding var gender: String
    let lang: String
    let canContinue: Bool
    let onContinue: () -> Void
    @EnvironmentObject var loc: LocalizationManager

    @FocusState private var nameFocused: Bool

    private struct GenderOption: Identifiable {
        let id: String
        let emoji: String
        let label: (L10n) -> String
        let color: Color
    }

    private var genderOptions: [GenderOption] {
        [
            GenderOption(id: "boy",     emoji: "👦", label: { $0.genderBoy },     color: .bbSky),
            GenderOption(id: "girl",    emoji: "👧", label: { $0.genderGirl },    color: .bbCoral),
            GenderOption(id: "unknown", emoji: "🌟", label: { $0.genderUnknown }, color: .bbButter),
        ]
    }

    var ageDescription: String {
        let comps = Calendar.current.dateComponents([.month, .day], from: birthDate, to: Date())
        let months = comps.month ?? 0
        let days   = comps.day ?? 0
        if months == 0 { return "\(days) \(loc.strings.unitDay)" }
        return "\(months) \(loc.strings.unitMonth) \(days) \(loc.strings.unitDay)"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                VStack(spacing: 8) {
                    CuteBlobView(kind: .star, size: 64, tone: .bbMint)
                        .padding(.top, 12)
                    Text(loc.strings.whatsYourBabyName)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(loc.strings.nameBirthHelp)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                        .multilineTextAlignment(.center)
                }

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
                        .submitLabel(.next)
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
                .padding(.horizontal, 24)

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
                                    Text(option.emoji)
                                        .font(.system(size: 28))
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
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text(loc.strings.dateOfBirthLabel)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .kerning(0.6)
                        .padding(.horizontal, 24)

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
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .bbShadow()
                    .padding(.horizontal, 24)
                }

                OBContinueButton(
                    label: loc.strings.continueArrow,
                    enabled: canContinue,
                    action: onContinue
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear { nameFocused = true }
    }
}
