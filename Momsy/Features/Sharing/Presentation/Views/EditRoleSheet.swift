import SwiftUI

// MARK: - Member Detail Sheet

struct MemberDetailSheet: View {
    let member: FamilyMember
    let onRoleChange: (FamilyRole) -> Void
    let onRemove: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedRole: FamilyRole
    @State private var showRemoveConfirm = false
    @EnvironmentObject var loc: LocalizationManager

    init(member: FamilyMember, onRoleChange: @escaping (FamilyRole) -> Void, onRemove: @escaping () -> Void) {
        self.member = member
        self.onRoleChange = onRoleChange
        self.onRemove = onRemove
        _selectedRole = State(initialValue: member.role)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    CuteBlobView(kind: member.blob, size: 80, tone: member.tone)
                    Text(member.name)
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(member.activity)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                }
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 10) {
                    Text(loc.strings.roleLabel)
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .kerning(0.5)

                    VStack(spacing: 1) {
                        ForEach(FamilyRole.allCases) { role in
                            Button {
                                withAnimation(.spring(response: 0.25)) { selectedRole = role }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: role.icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(selectedRole == role ? .bbCoralDeep : .bbInkSoft)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(role.displayName(lang: loc.lang))
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.bbInk)
                                        Text(role.roleDescription(lang: loc.lang))
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(.bbInkSoft)
                                    }
                                    Spacer()
                                    if selectedRole == role {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.bbCoralDeep)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(selectedRole == role ? Color.bbCoral.opacity(0.1) : Color.bbCard)
                            }
                            .buttonStyle(.plain)

                            if role != FamilyRole.allCases.last {
                                Divider().opacity(0.3)
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .bbShadowSoft()
                }
                .padding(.horizontal, 20)

                Spacer()

                VStack(spacing: 8) {
                    Button {
                        onRoleChange(selectedRole)
                        dismiss()
                    } label: {
                        Text(loc.strings.saveRole)
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedRole != member.role ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .disabled(selectedRole == member.role)
                    .animation(.easeInOut(duration: 0.2), value: selectedRole)

                    Button(role: .destructive) {
                        showRemoveConfirm = true
                    } label: {
                        Text(loc.strings.removeFromTeamAction)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.bbCoralDeep)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(Color.bbCream.ignoresSafeArea())
            .navigationTitle(loc.strings.editMember)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }.foregroundColor(.bbInkSoft)
                }
            }
            .confirmationDialog(
                loc.strings.removeConfirm(name: member.name),
                isPresented: $showRemoveConfirm,
                titleVisibility: .visible
            ) {
                Button(loc.strings.remove, role: .destructive) {
                    onRemove()
                    dismiss()
                }
                Button(loc.strings.cancel, role: .cancel) {}
            }
        }
    }
}
