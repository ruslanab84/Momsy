import SwiftUI

// MARK: - Join Family

struct JoinFamilyStep: View {
    @Binding var inviteCode: String
    let canContinue: Bool
    let onContinue: () -> Void
    let onCreateNewProfile: () -> Void

    @EnvironmentObject var loc: LocalizationManager
    @FocusState private var codeFocused: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    CuteBlobView(kind: .heart, size: 64, tone: .bbSky)
                        .padding(.top, 12)
                    Text(loc.strings.joinOnboardingTitle)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(loc.strings.joinOnboardingSubtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text(loc.strings.inviteCodeLabel)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .kerning(0.6)

                    TextField("MOMSY-XXXX", text: $inviteCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(.system(size: 17, weight: .semibold, design: .monospaced))
                        .foregroundColor(.bbInk)
                        .tint(.bbCoralDeep)
                        .focused($codeFocused)
                        .submitLabel(.continue)
                        .onSubmit {
                            if canContinue { onContinue() }
                        }
                        .onChange(of: inviteCode) { _, newValue in
                            // A pasted deeplink (vs. a manually-typed bare code) can be dismissed
                            // right away — otherwise the keyboard is still up when the user taps
                            // Continue, and that first tap gets swallowed by the paste
                            // menu/keyboard dismissal instead of reaching the button.
                            if newValue.contains("://") { codeFocused = false }
                        }
                        .padding(16)
                        .background(Color.bbCard)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(
                                    codeFocused ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.15),
                                    lineWidth: codeFocused ? 2 : 1.5
                                )
                        )
                        .bbShadowSoft()
                }
                .padding(.horizontal, 24)

                VStack(spacing: 10) {
                    OBContinueButton(
                        label: loc.strings.continueArrow,
                        enabled: canContinue,
                        action: onContinue
                    )

                    Button(action: onCreateNewProfile) {
                        Text(loc.strings.createNewBabyProfile)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInkMute)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear { codeFocused = inviteCode.isEmpty }
    }
}
