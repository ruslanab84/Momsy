import SwiftUI

// MARK: - SharingView

struct SharingView: View {
    @StateObject private var vm: SharingViewModel
    @EnvironmentObject var loc: LocalizationManager

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeSharingViewModel())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                header
                memberList
                inviteCard
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
                onRegenerate: { vm.regenerateInvite() },
                onInvite: { member in vm.addMember(member) }
            )
        }
        .sheet(item: $vm.editingMember) { member in
            MemberDetailSheet(
                member: member,
                onRoleChange: { newRole in vm.changeRole(id: member.id, to: newRole) },
                onRemove: { vm.removeMember(id: member.id) }
            )
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
                MemberCard(member: member) {
                    vm.editingMember = member
                }
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.8), value: vm.members.count)
    }

    // MARK: - Invite card

    private var inviteCard: some View {
        Button { vm.showInvite = true } label: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.bbCoralDeep.opacity(0.12))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.bbCoralDeep)
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
    }

    // MARK: - Role matrix

    private var matrixHeaders: [String] {
        ["", loc.strings.roleMom, loc.strings.roleDad, loc.strings.roleNanny, loc.strings.roleGrandma]
    }

    private var matrixRows: [(String, [Bool])] {
        [
            (loc.strings.matrixFeedingSleep,  [true,  true,  true,  false]),
            (loc.strings.diapers,             [true,  true,  true,  false]),
            (loc.strings.matrixTempMedicine,  [true,  true,  false, false]),
            (loc.strings.symptoms,             [true,  true,  false, false]),
            (loc.strings.matrixPhotosDiary,   [true,  true,  true,  true ]),
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

// MARK: - Member Card

private struct MemberCard: View {
    let member: FamilyMember
    let onEdit: () -> Void
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                CuteBlobView(kind: member.blob, size: 50, tone: member.tone)
                if member.isOnline {
                    Circle()
                        .fill(Color.bbMintDeep)
                        .frame(width: 13, height: 13)
                        .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(member.name)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text("· \(member.role.displayName(lang: loc.lang))")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
                Text(member.role.roleDescription(lang: loc.lang))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                Text(member.activity.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(member.isOnline ? .bbMintDeep : .bbInkMute)
                    .kerning(0.4)
            }

            Spacer()

            if member.isMe {
                Text(loc.strings.you)
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.bbCoral)
                    .clipShape(Capsule())
            } else {
                Button(action: onEdit) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.bbInkSoft)
                        .frame(width: 32, height: 32)
                        .background(Color.bbCreamSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .bbCard(pad: 12)
    }
}

// MARK: - Member Detail Sheet

private struct MemberDetailSheet: View {
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

// MARK: - Invite Sheet

private struct InviteSheet: View {
    let inviteCode: String
    let inviteURL:  String
    let inviteExpiry: Date
    let onRegenerate: () -> Void
    let onInvite: (FamilyMember) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedRole: FamilyRole = .dad
    @State private var nameText = ""
    @State private var showShare = false
    @State private var isCopied = false
    @State private var expiryLabel = ""
    @EnvironmentObject var loc: LocalizationManager

    private let blobsByRole: [FamilyRole: (BlobKind, Color)] = [
        .mom:     (.baby,  .bbCoral),
        .dad:     (.bear,  .bbSky),
        .nanny:   (.sun,   .bbMint),
        .grandma: (.heart, .bbLilac),
    ]

    private var qrImage: Image? {
        guard let data = inviteURL.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        guard let ciImage = filter.outputImage else { return nil }
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
        let ctx = CIContext()
        guard let cgImage = ctx.createCGImage(scaled, from: scaled.extent) else { return nil }
        return Image(uiImage: UIImage(cgImage: cgImage))
    }

    private func formatExpiry(_ date: Date) -> String {
        let remaining = date.timeIntervalSinceNow
        if remaining <= 0 { return loc.strings.expired }
        let hrs = Int(remaining / 3600)
        let mins = Int((remaining.truncatingRemainder(dividingBy: 3600)) / 60)
        if hrs > 0 { return loc.strings.expiryHoursLeft(hrs: hrs, mins: mins) }
        return loc.strings.expiryMinsLeft(mins)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // QR + link card
                    VStack(spacing: 12) {
                        if let qr = qrImage {
                            qr
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 160)
                                .padding(16)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }

                        Text(inviteCode)
                            .font(.system(size: 16, weight: .heavy, design: .monospaced))
                            .foregroundColor(.bbInk)
                            .kerning(1)

                        Text(inviteURL)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.bbInkMute)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        HStack(spacing: 8) {
                            // Copy link button
                            Button {
                                UIPasteboard.general.string = inviteURL
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation { isCopied = true }
                                Task {
                                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                                    withAnimation { isCopied = false }
                                }
                            } label: {
                                Label(isCopied ? loc.strings.copied : loc.strings.copyLink,
                                      systemImage: isCopied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(isCopied ? .bbMintDeep : .bbInk)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(isCopied ? Color.bbMint : Color.bbCreamSoft)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .animation(.spring(response: 0.3), value: isCopied)

                            // Regenerate button
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                onRegenerate()
                            } label: {
                                Label(loc.strings.newCode, systemImage: "arrow.clockwise")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.bbInkSoft)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.bbCreamSoft)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                            Text(expiryLabel)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.bbInkMute)
                    }
                    .frame(maxWidth: .infinity)
                    .bbCard(pad: 20)

                    // Role picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text(loc.strings.roleInTeam)
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInkMute)
                            .kerning(0.5)

                        HStack(spacing: 8) {
                            ForEach(FamilyRole.allCases) { role in
                                Button {
                                    withAnimation(.spring(response: 0.25)) { selectedRole = role }
                                } label: {
                                    VStack(spacing: 6) {
                                        let (blob, tone) = blobsByRole[role] ?? (.star, .bbButter)
                                        CuteBlobView(kind: blob, size: 36, tone: tone)
                                        Text(role.displayName(lang: loc.lang))
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundColor(selectedRole == role ? .bbCoralDeep : .bbInk)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedRole == role ? Color.bbCoral.opacity(0.15) : Color.bbCard)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(selectedRole == role ? Color.bbCoralDeep : Color.clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Text(selectedRole.roleDescription(lang: loc.lang))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInkSoft)
                            .padding(.top, 2)
                    }

                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text(loc.strings.nameOptional)
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInkMute)
                            .kerning(0.5)
                        TextField(loc.strings.memberNamePlaceholder, text: $nameText)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .padding(14)
                            .background(Color.bbCard)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // Action buttons
                    VStack(spacing: 8) {
                        Button { showShare = true } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15, weight: .bold))
                                Text(loc.strings.shareLink)
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.bbSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }

                        Button {
                            let (blob, tone) = blobsByRole[selectedRole] ?? (.star, .bbButter)
                            let name = nameText.trimmingCharacters(in: .whitespaces).isEmpty
                                ? selectedRole.displayName(lang: loc.lang)
                                : nameText.trimmingCharacters(in: .whitespaces)
                            onInvite(FamilyMember(
                                name: name, role: selectedRole, isMe: false, isOnline: false,
                                activity: loc.strings.invitationSent,
                                blob: blob, tone: tone
                            ))
                            dismiss()
                        } label: {
                            Text(loc.strings.addToTeam)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.bbCoralDeep)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(Color.bbCoralDeep.opacity(0.4), lineWidth: 1.5)
                                )
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.bbCream.ignoresSafeArea())
            .navigationTitle(loc.strings.invite)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }.foregroundColor(.bbInkSoft)
                }
            }
            .sheet(isPresented: $showShare) {
                ActivityView(items: [inviteURL])
            }
            .onAppear { expiryLabel = formatExpiry(inviteExpiry) }
            .task {
                while !Task.isCancelled {
                    expiryLabel = formatExpiry(inviteExpiry)
                    try? await Task.sleep(nanoseconds: 60_000_000_000)
                }
            }
        }
    }
}


#Preview {
    NavigationStack { SharingView(container: AppContainer()) }
        .environmentObject(LocalizationManager.shared)
}
