import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {
    @StateObject private var vm: OnboardingViewModel
    @EnvironmentObject var loc: LocalizationManager

    init(container: AppContainer, onDone: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: container.makeOnboardingViewModel(onDone: onDone))
    }

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                navBar
                    .padding(.top, 56)
                    .padding(.horizontal, 24)

                stepContent
                    .transition(
                        vm.forward
                        ? .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity))
                        : .asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal:   .move(edge: .trailing).combined(with: .opacity))
                    )
                    .id(vm.step)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: vm.step)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.bbCream, vm.stepColor.opacity(0.18)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: vm.step)
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack(spacing: 12) {
            Button(action: vm.goBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.bbInkSoft)
                    .frame(width: 36, height: 36)
                    .background(Color.bbCard.opacity(0.7))
                    .clipShape(Circle())
            }
            .opacity(vm.step == .age ? 0 : 1)
            .disabled(vm.step == .age)

            HStack(spacing: 6) {
                ForEach(OBStep.allCases, id: \.self) { s in
                    Capsule()
                        .fill(s.rawValue <= vm.step.rawValue ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.2))
                        .frame(width: s == vm.step ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: vm.step)
                }
            }
            .frame(maxWidth: .infinity)

            Text("\(vm.step.rawValue + 1) / \(OBStep.allCases.count)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkMute)
                .frame(width: 36)
        }
        .padding(.bottom, 12)
    }

    // MARK: - Step Router

    @ViewBuilder
    private var stepContent: some View {
        switch vm.step {
        case .age:
            AgeStep(selected: $vm.selectedStage, lang: loc.lang, onContinue: vm.advance)
        case .profile:
            ProfileStep(babyName: $vm.babyName, birthDate: $vm.birthDate, gender: $vm.babyGender,
                        lang: loc.lang, canContinue: vm.canContinue, onContinue: vm.advance)
        case .role:
            RoleStep(parentName: $vm.parentName, selectedRole: $vm.parentRole, lang: loc.lang, onContinue: vm.advance)
        case .auth:
            AuthStep(
                isSigningIn: vm.isSigningIn,
                authError: vm.authError,
                prepareAppleRequest: vm.authManager.prepareAppleRequest,
                onAppleCompletion: vm.handleAppleCompletion,
                onGoogle: vm.signInWithGoogle,
                onSkip: vm.skipAuth
            )
        case .ready:
            ReadyStep(
                babyName: vm.babyName,
                birthDate: vm.birthDate,
                stage: vm.selectedStage,
                parentName: vm.parentName,
                role: vm.parentRole,
                lang: loc.lang,
                onStart: vm.finish
            )
        }
    }
}

#Preview {
    OnboardingView(container: AppContainer(), onDone: {})
        .environmentObject(LocalizationManager.shared)
}
