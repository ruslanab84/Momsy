import SwiftUI

// MARK: - SharingView

struct SharingView: View {
    @AppStorage("babyName") private var babyName = ""

    @State private var members: [FamilyMember] = sampleFamily
    @State private var showInvite = false
    @State private var editingMember: FamilyMember? = nil
    @State private var removeTarget: FamilyMember? = nil

    private var displayName: String { babyName.isEmpty ? "малыша" : babyName }

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
        .sheet(isPresented: $showInvite) {
            InviteSheet { newMember in
                withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
                    members.append(newMember)
                }
            }
        }
        .sheet(item: $editingMember) { member in
            MemberDetailSheet(
                member: member,
                onRoleChange: { newRole in
                    if let idx = members.firstIndex(where: { $0.id == member.id }) {
                        withAnimation { members[idx].role = newRole }
                    }
                },
                onRemove: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        members.removeAll { $0.id == member.id }
                    }
                }
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            BBSectionLabel(text: "Семья")
            Text("Команда \(displayName)")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Text("У всех своя роль — у каждой свой уровень доступа.")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Member list

    private var memberList: some View {
        VStack(spacing: 10) {
            ForEach(members) { member in
                MemberCard(member: member) {
                    editingMember = member
                }
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.8), value: members.count)
    }

    // MARK: - Invite card

    private var inviteCard: some View {
        Button { showInvite = true } label: {
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
                    Text("Пригласить члена семьи")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text("QR-код или ссылка · выбор роли")
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

    private let matrixHeaders = ["", "Мама", "Папа", "Няня", "Бабушка"]
    private let matrixRows: [(String, [Bool])] = [
        ("Кормления и сон",         [true,  true,  true,  false]),
        ("Подгузники",              [true,  true,  true,  false]),
        ("Температура / лекарства", [true,  true,  false, false]),
        ("Симптомы",                [true,  true,  false, false]),
        ("Фото и дневник",          [true,  true,  true,  true ]),
        ("Отчёт педиатру",          [true,  true,  false, false]),
    ]

    private func hasRole(_ role: FamilyRole) -> Bool {
        members.contains { $0.role == role }
    }

    private var roleMatrix: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: "Что видит каждая роль")

            VStack(spacing: 0) {
                // Column headers
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
                    Text("· \(member.role.rawValue)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
                Text(member.role.description)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                Text(member.activity.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(member.isOnline ? .bbMintDeep : .bbInkMute)
                    .kerning(0.4)
            }

            Spacer()

            if member.isMe {
                Text("вы")
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

    init(member: FamilyMember, onRoleChange: @escaping (FamilyRole) -> Void, onRemove: @escaping () -> Void) {
        self.member = member
        self.onRoleChange = onRoleChange
        self.onRemove = onRemove
        _selectedRole = State(initialValue: member.role)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Avatar + name
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

                // Role picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("РОЛЬ")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .kerning(0.5)

                    VStack(spacing: 1) {
                        ForEach(FamilyRole.allCases) { role in
                            Button {
                                withAnimation(.spring(response: 0.25)) {
                                    selectedRole = role
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: role.icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(selectedRole == role ? .bbCoralDeep : .bbInkSoft)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(role.rawValue)
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.bbInk)
                                        Text(role.description)
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

                // Actions
                VStack(spacing: 8) {
                    Button {
                        onRoleChange(selectedRole)
                        dismiss()
                    } label: {
                        Text("Сохранить роль")
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
                        Text("Удалить из команды")
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
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }.foregroundColor(.bbInkSoft)
                }
            }
            .confirmationDialog(
                "Удалить \(member.name) из команды?",
                isPresented: $showRemoveConfirm,
                titleVisibility: .visible
            ) {
                Button("Удалить", role: .destructive) {
                    onRemove()
                    dismiss()
                }
                Button("Отмена", role: .cancel) {}
            }
        }
    }
}

// MARK: - Invite Sheet

private struct InviteSheet: View {
    let onInvite: (FamilyMember) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedRole: FamilyRole = .dad
    @State private var nameText = ""
    @State private var showShare = false

    private let blobsByRole: [FamilyRole: (BlobKind, Color)] = [
        .mom:     (.baby,  .bbCoral),
        .dad:     (.bear,  .bbSky),
        .nanny:   (.sun,   .bbMint),
        .grandma: (.heart, .bbLilac),
    ]

    private var inviteCode: String { "MOMSY-\(Int.random(in: 1000...9999))" }
    private var inviteURL: String { "https://momsy.app/join/\(inviteCode)" }

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

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // QR Card
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
                        Text(inviteURL)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.bbInkMute)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                            Text("Ссылка действует 24 часа")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.bbInkMute)
                    }
                    .frame(maxWidth: .infinity)
                    .bbCard(pad: 20)

                    // Role picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("РОЛЬ В КОМАНДЕ")
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
                                        Text(role.rawValue)
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

                        Text(selectedRole.description)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInkSoft)
                            .padding(.top, 2)
                    }

                    // Optional name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ИМЯ (необязательно)")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInkMute)
                            .kerning(0.5)
                        TextField("Например: Миша, Бабушка Оля…", text: $nameText)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .padding(14)
                            .background(Color.bbCard)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // Share + Add buttons
                    VStack(spacing: 8) {
                        Button {
                            showShare = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15, weight: .bold))
                                Text("Поделиться ссылкой")
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.bbInk)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }

                        Button {
                            let (blob, tone) = blobsByRole[selectedRole] ?? (.star, .bbButter)
                            let name = nameText.trimmingCharacters(in: .whitespaces).isEmpty
                                ? selectedRole.rawValue
                                : nameText.trimmingCharacters(in: .whitespaces)
                            onInvite(FamilyMember(
                                name: name,
                                role: selectedRole,
                                isMe: false,
                                isOnline: false,
                                activity: "приглашение отправлено",
                                blob: blob,
                                tone: tone
                            ))
                            dismiss()
                        } label: {
                            Text("Добавить в команду")
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
            .navigationTitle("Пригласить")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }.foregroundColor(.bbInkSoft)
                }
            }
            .sheet(isPresented: $showShare) {
                ShareSheet(items: [inviteURL])
            }
        }
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack { SharingView() }
}
