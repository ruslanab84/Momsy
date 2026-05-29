import SwiftUI
import AuthenticationServices

// MARK: - Step 4: Sign-In (optional)

struct AuthStep: View {
    let isSigningIn: Bool
    let authError: Error?
    let prepareAppleRequest: (ASAuthorizationAppleIDRequest) -> Void
    let onAppleCompletion: (Result<ASAuthorization, Error>) -> Void
    let onGoogle: () -> Void
    let onSkip: () -> Void

    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                header
                    .padding(.horizontal, 24)

                if isSigningIn {
                    ProgressView()
                        .tint(.bbCoralDeep)
                        .scaleEffect(1.4)
                        .frame(height: 80)
                } else {
                    authButtons
                        .padding(.horizontal, 24)
                }

                if let error = authError {
                    Text(error.localizedDescription)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.red.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Button(action: onSkip) {
                    Text(loc.strings.mayBeLater)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 20)
                }
                .disabled(isSigningIn)
                .padding(.bottom, 40)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 8) {
            CuteBlobView(kind: .cloud, size: 64, tone: .bbSky)
                .padding(.top, 12)
            Text(loc.strings.authStepTitle)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Text(loc.strings.authStepSubtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }

    private var authButtons: some View {
        VStack(spacing: 12) {
            SignInWithAppleButton(.signIn) { request in
                prepareAppleRequest(request)
            } onCompletion: { result in
                onAppleCompletion(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            googleButton
        }
    }

    private var googleButton: some View {
        Button(action: onGoogle) {
            HStack(spacing: 10) {
                Image(systemName: "g.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 0.86, green: 0.22, blue: 0.17))
                Text(loc.strings.signInWithGoogle)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInk)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.bbInkMute.opacity(0.2), lineWidth: 1.5)
            )
            .bbShadow()
        }
    }
}
