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
        .onReceive(NotificationCenter.default.publisher(for: .pendingFamilyInviteDidChange)) { _ in
            vm.loadPendingInviteIfNeeded()
        }
        .alert(loc.strings.joinReplaceTitle, isPresented: $vm.showJoinConfirm) {
            Button(loc.strings.joinReplaceConfirm, role: .destructive) {
                vm.confirmJoinReplacingFamily()
            }
            Button(loc.strings.cancel, role: .cancel) { }
        } message: {
            Text(loc.strings.joinReplaceMessage)
        }
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
                ForEach(vm.steps, id: \.self) { s in
                    Capsule()
                        .fill(stepIsCompleteOrCurrent(s) ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.2))
                        .frame(width: s == vm.step ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: vm.step)
                }
            }
            .frame(maxWidth: .infinity)

            Text("\(vm.currentStepNumber) / \(vm.steps.count)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkMute)
                .frame(width: 36)
        }
        .padding(.bottom, 12)
    }

    private func stepIsCompleteOrCurrent(_ step: OBStep) -> Bool {
        guard
            let stepIndex = vm.steps.firstIndex(of: step),
            let currentIndex = vm.steps.firstIndex(of: vm.step)
        else { return false }
        return stepIndex <= currentIndex
    }

    // MARK: - Step Router

    @ViewBuilder
    private var stepContent: some View {
        switch vm.step {
        case .join:
            JoinFamilyStep(
                inviteCode: $vm.pendingInviteCode,
                canContinue: vm.canContinue,
                onContinue: vm.advance,
                onCreateNewProfile: vm.startCreateFlow
            )
        case .age:
            AgeStep(
                selected: $vm.selectedStage,
                lang: loc.lang,
                onContinue: vm.advance,
                onJoinWithInvite: { vm.startJoinFlow() }
            )
        case .profile:
            ProfileStep(babyName: $vm.babyName, birthDate: $vm.birthDate, gender: $vm.babyGender,
                        lang: loc.lang, canContinue: vm.canContinue, onContinue: vm.advance)
        case .role:
            RoleStep(parentName: $vm.parentName, selectedRole: $vm.parentRole, lang: loc.lang, onContinue: vm.advance)
        case .privacy:
            CloudSyncConsentStep(
                isJoinFlow: vm.isJoinFlow,
                onAllow: { vm.chooseCloudSync(true) },
                onKeepLocal: { vm.chooseCloudSync(false) }
            )
        case .invite:
            FamilyInviteStep(
                selectedRole: vm.selectedInviteRole,
                inviteCode: vm.inviteCode,
                inviteURL: vm.inviteURL,
                inviteExpiry: vm.inviteExpiry,
                isPreparing: vm.isPreparingInvite,
                error: vm.inviteError,
                onRoleChange: vm.updateInviteRole,
                onGenerate: { Task { await vm.prepareInvite() } },
                onRegenerate: { Task { await vm.regenerateInvite() } },
                onContinue: vm.advance,
                onSkip: vm.skipInvite
            )
        case .auth:
            AuthStep(
                title: vm.isJoinFlow ? loc.strings.joinAuthTitle : loc.strings.authStepTitle,
                subtitle: vm.isJoinFlow ? loc.strings.joinAuthSubtitle : loc.strings.authStepSubtitle,
                isSigningIn: vm.isSigningIn,
                authError: vm.authError,
                allowsSkip: !vm.isJoinFlow,
                prepareAppleRequest: vm.authManager.prepareAppleRequest,
                onAppleCompletion: vm.handleAppleCompletion,
                onGoogle: vm.signInWithGoogle,
                onSkip: vm.skipAuth
            )
        case .ready:
            ReadyStep(
                babyName: vm.readyBabyName,
                birthDate: vm.readyBirthDate,
                stage: vm.readyStage,
                parentName: vm.parentName,
                role: vm.parentRole,
                lang: loc.lang,
                isJoinFlow: vm.isJoinFlow,
                cloudSyncEnabled: vm.cloudSyncEnabled,
                onStart: vm.finish
            )
        }
    }
}

private struct CloudSyncConsentStep: View {
    let isJoinFlow: Bool
    let onAllow: () -> Void
    let onKeepLocal: () -> Void

    @EnvironmentObject private var loc: LocalizationManager
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                CuteBlobView(kind: .cloud, size: 72, tone: .bbMint)
                    .padding(.top, 12)

                VStack(spacing: 8) {
                    Text(loc.strings.cloudSyncConsentTitle)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(isJoinFlow
                         ? loc.strings.cloudSyncConsentJoinMessage
                         : loc.strings.cloudSyncConsentMessage)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }

                VStack(alignment: .leading, spacing: 14) {
                    consentRow(icon: "person.crop.circle.badge.checkmark",
                               text: loc.strings.cloudSyncAnonymousAccountDisclosure)
                    consentRow(icon: "arrow.triangle.2.circlepath",
                               text: loc.strings.cloudSyncFirestoreDisclosure)
                    consentRow(icon: "hand.raised.fill",
                               text: loc.strings.cloudSyncOptionalDisclosure)
                }
                .bbCard(pad: 18)

                Button(action: onAllow) {
                    Text(loc.strings.cloudSyncAllow)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(Color.bbCoralDeep)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

                Button(action: onKeepLocal) {
                    Text(isJoinFlow ? loc.strings.cloudSyncUseLocally : loc.strings.cloudSyncKeepLocal)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .padding(.vertical, 6)
                }

                Button {
                    if let url = AppLegalLinks.privacyPolicyURL { openURL(url) }
                } label: {
                    Text(loc.strings.readPrivacyPolicy)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbCoralDeep)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
        }
    }

    private func consentRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.bbCoralDeep)
                .frame(width: 22)
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    OnboardingView(container: AppContainer(), onDone: {})
        .environmentObject(LocalizationManager.shared)
}
