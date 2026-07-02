import SwiftUI

// MARK: - Member Card

struct MemberCard: View {
    let member: FamilyMember
    let canEdit: Bool
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
            } else if canEdit {
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
