import SwiftUI
import UIKit

// MARK: - Family Invite

struct FamilyInviteStep: View {
    let selectedRole: FamilyRole
    let inviteCode: String
    let inviteURL: String
    let inviteExpiry: Date
    let isPreparing: Bool
    let error: Error?
    let onRoleChange: (FamilyRole) -> Void
    let onGenerate: () -> Void
    let onRegenerate: () -> Void
    let onContinue: () -> Void
    let onSkip: () -> Void

    @EnvironmentObject var loc: LocalizationManager
    @State private var showShare = false
    @State private var isCopied = false

    private var hasInvite: Bool {
        !inviteCode.isEmpty && !inviteURL.isEmpty
    }

    private var expiryText: String {
        let remaining = inviteExpiry.timeIntervalSinceNow
        guard remaining > 0 else { return loc.strings.expired }
        let hours = Int(remaining / 3600)
        let minutes = Int((remaining.truncatingRemainder(dividingBy: 3600)) / 60)
        return hours > 0
            ? loc.strings.expiryHoursLeft(hrs: hours, mins: minutes)
            : loc.strings.expiryMinsLeft(minutes)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                header
                    .padding(.horizontal, 24)

                rolePicker
                    .padding(.horizontal, 24)

                inviteCard
                    .padding(.horizontal, 24)

                if let error {
                    Text((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.red.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 10) {
                    OBContinueButton(
                        label: loc.strings.continueArrow,
                        action: onContinue
                    )

                    Button(action: onSkip) {
                        Text(loc.strings.skipInviteForNow)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInkMute)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 20)
                    }
                    .disabled(isPreparing)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showShare) {
            ActivityView(items: [inviteURL])
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            CuteBlobView(kind: .heart, size: 64, tone: .bbRose)
                .padding(.top, 12)
            Text(loc.strings.inviteOnboardingTitle)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Text(loc.strings.inviteOnboardingSubtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }

    private var rolePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.strings.roleInTeam)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)

            HStack(spacing: 8) {
                ForEach(FamilyRole.allCases) { role in
                    roleButton(role)
                }
            }
        }
    }

    private func roleButton(_ role: FamilyRole) -> some View {
        let isSelected = selectedRole == role
        return Button {
            withAnimation(.spring(response: 0.25)) {
                onRoleChange(role)
            }
        } label: {
            VStack(spacing: 6) {
                CuteBlobView(kind: role.defaultBlob, size: 36, tone: role.defaultTone)
                Text(role.displayName(lang: loc.lang))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .bbCoralDeep : .bbInk)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.bbCoral.opacity(0.15) : Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? Color.bbCoralDeep : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(isPreparing)
    }

    private var inviteCard: some View {
        VStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.bbCreamSoft)
                .frame(height: 92)
                .overlay {
                    if isPreparing {
                        ProgressView()
                            .tint(.bbCoralDeep)
                    } else if hasInvite {
                        VStack(spacing: 6) {
                            Text(inviteCode)
                                .font(.system(size: 16, weight: .heavy, design: .monospaced))
                                .foregroundColor(.bbInk)
                                .kerning(1)
                            Text(inviteURL)
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.bbInkMute)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .padding(.horizontal, 12)
                        }
                    } else {
                        Text(loc.strings.inviteLinkNotGenerated)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInkSoft)
                    }
                }

            if hasInvite {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text(expiryText)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.bbInkMute)
            }

            HStack(spacing: 8) {
                Button(action: hasInvite ? onRegenerate : onGenerate) {
                    Label(hasInvite ? loc.strings.newCode : loc.strings.generateInviteLink,
                          systemImage: hasInvite ? "arrow.clockwise" : "link.badge.plus")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.bbCreamSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(isPreparing)

                Button(action: copyInvite) {
                    Label(isCopied ? loc.strings.copied : loc.strings.copyLink,
                          systemImage: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(isCopied ? .bbMintDeep : .bbInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isCopied ? Color.bbMint.opacity(0.35) : Color.bbCreamSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!hasInvite || isPreparing)
            }

            Button {
                showShare = true
            } label: {
                Label(loc.strings.shareLink, systemImage: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(hasInvite ? Color.bbSurface : Color.bbInkMute.opacity(0.45))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .disabled(!hasInvite || isPreparing)
        }
        .bbCard(pad: 16)
    }

    private func copyInvite() {
        guard hasInvite else { return }
        UIPasteboard.general.string = inviteURL
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation { isCopied = true }
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation { isCopied = false }
        }
    }
}
