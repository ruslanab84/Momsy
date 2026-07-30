import SwiftUI

// MARK: - Invite Sheet

struct InviteSheet: View {
    let inviteCode: String
    let inviteURL:  String
    let inviteExpiry: Date
    let initialRole: FamilyRole
    let isSyncing: Bool
    let onRegenerate: (FamilyRole) -> Void
    let onRoleChange: (FamilyRole) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedRole: FamilyRole
    @State private var showShare = false
    @State private var isCopied = false
    @State private var expiryLabel = ""
    @EnvironmentObject var loc: LocalizationManager

    init(
        inviteCode: String,
        inviteURL: String,
        inviteExpiry: Date,
        initialRole: FamilyRole,
        isSyncing: Bool,
        onRegenerate: @escaping (FamilyRole) -> Void,
        onRoleChange: @escaping (FamilyRole) -> Void
    ) {
        self.inviteCode = inviteCode
        self.inviteURL = inviteURL
        self.inviteExpiry = inviteExpiry
        self.initialRole = initialRole
        self.isSyncing = isSyncing
        self.onRegenerate = onRegenerate
        self.onRoleChange = onRoleChange
        _selectedRole = State(initialValue: initialRole)
    }

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
                            .disabled(isSyncing)

                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                onRegenerate(selectedRole)
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
                            .disabled(isSyncing)
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
                                    onRoleChange(role)
                                } label: {
                                    VStack(spacing: 6) {
                                        CuteBlobView(kind: role.defaultBlob, size: 36, tone: role.defaultTone)
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
                                .disabled(isSyncing)
                            }
                        }

                        Text(selectedRole.roleDescription(lang: loc.lang))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInkSoft)
                            .padding(.top, 2)
                    }

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
                    .disabled(isSyncing)
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
            .onChange(of: isSyncing) { _, syncing in
                if !syncing {
                    selectedRole = initialRole
                }
            }
            .task {
                while !Task.isCancelled {
                    expiryLabel = formatExpiry(inviteExpiry)
                    try? await Task.sleep(nanoseconds: 60_000_000_000)
                }
            }
        }
    }
}
