import SwiftUI

// MARK: - Step 3: Parent Role

struct RoleStep: View {
    @Binding var parentName: String
    @Binding var selectedRole: String
    let lang: String
    let onContinue: () -> Void
    @EnvironmentObject var loc: LocalizationManager

    @FocusState private var nameFocused: Bool

    private var roles: [(String, String, BlobKind, Color)] {
        [
            ("mom",   loc.strings.roleMom,    .mom,   .bbCoral),
            ("dad",   loc.strings.roleDad,    .dad,   .bbSky),
            ("nanny", loc.strings.roleNanny,  .nanny, .bbMint),
            ("other", loc.strings.roleOther,  .other, .bbButter),
        ]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    CuteBlobView(kind: .heart, size: 64, tone: .bbLilac)
                        .padding(.top, 12)
                    Text(loc.strings.whoAreYou)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(loc.strings.roleHelp)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                        .multilineTextAlignment(.center)
                }

                let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(roles, id: \.0) { id, label, blob, tone in
                        let isSelected = selectedRole == id
                        VStack(spacing: 10) {
                            CuteBlobView(kind: blob, size: 52, tone: tone)
                            Text(label)
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundColor(.bbInk)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.bbCard)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(isSelected ? Color.bbCoralDeep : Color.clear, lineWidth: 2.5)
                        )
                        .bbShadow()
                        .scaleEffect(isSelected ? 1.02 : 1.0)
                        .animation(.spring(response: 0.3), value: selectedRole)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) { selectedRole = id }
                        }
                    }
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text(loc.strings.yourNameOptional)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .kerning(0.6)

                    TextField(loc.strings.yourNamePlaceholder, text: $parentName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInk)
                        .tint(.bbCoralDeep)
                        .focused($nameFocused)
                        .padding(14)
                        .background(Color.bbCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(
                                    nameFocused ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.15),
                                    lineWidth: nameFocused ? 2 : 1.5
                                )
                        )
                        .bbShadowSoft()
                }
                .padding(.horizontal, 24)

                OBContinueButton(label: loc.strings.continueArrow, action: onContinue)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}
