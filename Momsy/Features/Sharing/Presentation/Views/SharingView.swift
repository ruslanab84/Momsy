import SwiftUI

// MARK: - SharingView

struct SharingView: View {
    @StateObject private var vm: SharingViewModel
    @ObservedObject private var authManager: AuthManager
    @EnvironmentObject var loc: LocalizationManager

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        _vm = StateObject(wrappedValue: container.makeSharingViewModel())
        _authManager = ObservedObject(wrappedValue: container.authManager)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                header
                memberList
                if vm.canManageMembers {
                    inviteCard
                }
                joinCard
                roleMatrix
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $vm.showInvite) {
            InviteSheet(
                inviteCode: vm.inviteCode,
                inviteURL:  vm.inviteURL,
                inviteExpiry: vm.inviteExpiry,
                initialRole: vm.inviteRole,
                isSyncing: vm.isPreparingInvite,
                onRegenerate: { role in vm.regenerateInvite(role: role) },
                onRoleChange: { role in vm.updateInviteRole(role) }
            )
        }
        .sheet(item: $vm.editingMember) { member in
            MemberDetailSheet(
                member: member,
                onRoleChange: { newRole in vm.changeRole(id: member.id, to: newRole) },
                onRemove: { vm.removeMember(id: member.id) }
            )
        }
        .sheet(isPresented: $vm.showJoinAuthSheet, onDismiss: {
            vm.retryPendingJoinAfterAuthIfNeeded()
        }) {
            AccountAuthSheet(container: container, mode: .joinFamily)
        }
        .onChange(of: authManager.isSignedIn) { _, _ in
            vm.retryPendingJoinAfterAuthIfNeeded()
        }
        .errorToast($vm.saveError)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            BBSectionLabel(text: loc.strings.family)
            Text(loc.strings.teamTitle(name: vm.displayName))
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Text(loc.strings.familyRoleHint)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Member list

    private var memberList: some View {
        VStack(spacing: 10) {
            ForEach(vm.members) { member in
                MemberCard(member: member, canEdit: vm.canManageMembers) {
                    vm.editingMember = member
                }
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.8), value: vm.members.count)
    }

    // MARK: - Invite card

    private var inviteCard: some View {
        Button { vm.presentInvite() } label: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.bbCoralDeep.opacity(0.12))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Group {
                            if vm.isPreparingInvite {
                                ProgressView()
                            } else {
                                Image(systemName: "person.badge.plus.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.bbCoralDeep)
                            }
                        }
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(loc.strings.inviteFamilyMember)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(loc.strings.inviteQrHint)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.bbInkMute)
            }
            .padding(16)
            .background(Color.bbCreamSoft)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.bbInkMute.opacity(0.25), style: StrokeStyle(lineWidth: 2, dash: [6]))
            )
        }
        .buttonStyle(.plain)
        .disabled(vm.isPreparingInvite)
    }

    // MARK: - Join with code

    private var joinCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: loc.strings.joinFamilyTitle)
            HStack(spacing: 10) {
                TextField(InviteCodeFormat.placeholder, text: $vm.joinCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.bbCreamSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                Button {
                    vm.joinFamily()
                } label: {
                    if vm.isJoining {
                        ProgressView()
                            .frame(width: 56, height: 44)
                    } else {
                        Text(loc.strings.joinAction)
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 44)
                            .background(Color.bbCoralDeep)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .disabled(vm.isJoining || vm.joinCode.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            if let err = vm.joinError {
                Text(err)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.red)
            }
            if vm.joinSuccess {
                Text(loc.strings.joinSuccessMessage)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbMintDeep)
            }
        }
        .padding(16)
        .background(Color.bbCreamSoft)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .alert(loc.strings.joinReplaceTitle, isPresented: $vm.showJoinConfirm) {
            Button(loc.strings.joinReplaceConfirm, role: .destructive) { vm.confirmJoinReplacingFamily() }
            Button(loc.strings.cancel, role: .cancel) { }
        } message: {
            Text(loc.strings.joinReplaceMessage)
        }
    }

    // MARK: - Role matrix

    private var matrixHeaders: [String] {
        ["", loc.strings.roleMom, loc.strings.roleDad, loc.strings.roleNanny, loc.strings.roleGrandma]
    }

    private var matrixRows: [(String, [Bool])] {
        [
            (loc.strings.matrixFeedingSleep,  [true,  true,  true,  true ]),
            (loc.strings.diapers,             [true,  true,  true,  true ]),
            (loc.strings.matrixTempMedicine,  [true,  true,  false, false]),
            (loc.strings.symptoms,             [true,  true,  false, false]),
            (loc.strings.matrixPhotosDiary,   [true,  true,  false, false]),
            (loc.strings.matrixPaedsReport,   [true,  true,  false, false]),
        ]
    }

    private func hasRole(_ role: FamilyRole) -> Bool {
        vm.members.contains { $0.role == role }
    }

    private var roleMatrix: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: loc.strings.whatEachRoleSees)

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(matrixHeaders.indices, id: \.self) { i in
                        let isActive = i > 0 && hasRole(FamilyRole.allCases[i - 1])
                        Text(matrixHeaders[i].uppercased())
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(isActive ? .bbCoralDeep : .bbInkSoft)
                            .frame(maxWidth: .infinity, alignment: i == 0 ? .leading : .center)
                            .padding(.vertical, 10)
                            .padding(.horizontal, i == 0 ? 12 : 0)
                            .background(isActive && i > 0 ? Color.bbCoral.opacity(0.12) : Color.bbCreamSoft)
                    }
                }

                Divider().opacity(0.3)

                ForEach(matrixRows.indices, id: \.self) { ri in
                    HStack(spacing: 0) {
                        Text(matrixRows[ri].0)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInk)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)

                        ForEach(matrixRows[ri].1.indices, id: \.self) { ci in
                            let granted = matrixRows[ri].1[ci]
                            let rolePresent = hasRole(FamilyRole.allCases[ci])
                            Image(systemName: granted ? "checkmark.circle.fill" : "minus")
                                .font(.system(size: granted ? 14 : 11, weight: .bold))
                                .foregroundColor(granted
                                    ? (rolePresent ? .bbMintDeep : .bbMintDeep.opacity(0.4))
                                    : Color.bbInkMute.opacity(0.3)
                                )
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 10)
                                .background(rolePresent && granted ? Color.bbMint.opacity(0.08) : Color.clear)
                        }
                    }
                    if ri < matrixRows.count - 1 {
                        Divider().opacity(0.15)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .bbShadow()
        }
    }
}

#Preview {
    NavigationStack { SharingView(container: AppContainer()) }
        .environmentObject(LocalizationManager.shared)
}
