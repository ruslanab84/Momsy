import SwiftUI

// MARK: - Step 1: Age

struct AgeStep: View {
    @Binding var selected: BabyAgeStage
    let lang: String
    let onContinue: () -> Void
    let onJoinWithInvite: () -> Void
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(Color.bbButter).frame(width: 130, height: 130)
                    Circle().fill(Color.bbCoral).frame(width: 100, height: 100)
                    CuteBlobView(kind: .baby, size: 64, tone: .clear)
                }
                .padding(.top, 12)
                .padding(.bottom, 20)

                Text(loc.strings.helloMama)
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)

                Text(loc.strings.howOldIsYourBaby)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 12)

                VStack(spacing: 10) {
                    ForEach(BabyAgeStage.allCases) { stage in
                        OBAgeCard(stage: stage, isSelected: selected == stage, lang: loc.lang)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) { selected = stage }
                            }
                    }
                }
                .padding(.horizontal, 24)

                tipBanner
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                OBContinueButton(label: loc.strings.continueArrow, action: onContinue)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                Button(action: onJoinWithInvite) {
                    Text(loc.strings.haveInviteLink)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 6)
                    .padding(.bottom, 40)
            }
        }
    }

    private var tipBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.bbMintDeep)
                .frame(width: 24, height: 24)
                .overlay(Text("✓").font(.system(size: 12, weight: .heavy)).foregroundColor(.white))
            Text(loc.strings.ageChangeNote)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.bbMint.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Age Card

private struct OBAgeCard: View {
    let stage: BabyAgeStage
    let isSelected: Bool
    let lang: String

    var body: some View {
        HStack(spacing: 14) {
            CuteBlobView(kind: stage.blobKind, size: 56, tone: stage.tone)
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text(lang == "en" ? stage.labelEn : stage.label)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text((lang == "en" ? stage.subtitleEn : stage.subtitle).uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .kerning(0.4)
                }
                Text(lang == "en" ? stage.focusEn : stage.focus)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
            }
            Spacer()
            Circle()
                .strokeBorder(isSelected ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.25), lineWidth: 2)
                .background(Circle().fill(isSelected ? Color.bbCoralDeep : Color.clear))
                .frame(width: 24, height: 24)
                .overlay(Circle().fill(.white).frame(width: 8, height: 8).opacity(isSelected ? 1 : 0))
        }
        .padding(14)
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(isSelected ? Color.bbCoralDeep : Color.clear, lineWidth: 2.5)
        )
        .bbShadow()
        .scaleEffect(isSelected ? 1.01 : 1.0)
        .animation(.spring(response: 0.25), value: isSelected)
    }
}

// MARK: - Continue Button (shared by all steps)

struct OBContinueButton: View {
    let label: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(enabled ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(enabled ? 0.08 : 0), radius: 0, y: 4)
        }
        .disabled(!enabled)
        .animation(.easeInOut(duration: 0.2), value: enabled)
    }
}
