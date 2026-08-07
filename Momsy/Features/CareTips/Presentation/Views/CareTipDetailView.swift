import SwiftUI

struct CareTipDetailView: View {
    let tip: CareTip
    @EnvironmentObject private var lm: LocalizationManager

    private var lang: Language { lm.current }
    private var tint: Color { tip.category.semanticColor.color }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                header
                numberedBlock(title: lm.strings.careTipWhatToDo, items: tip.whatToDo(lang))
                paragraphBlock(title: lm.strings.careTipWhyItMatters, text: tip.whyItMatters(lang))
                bulletBlock(
                    title: lm.strings.careTipCommonMistakes,
                    items: tip.commonMistakes(lang),
                    symbol: "xmark.circle.fill",
                    symbolColor: .bbInkMute
                )
                redFlagBlock
                disclaimer
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(tip.category.title(lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint.opacity(0.3))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: tip.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.bbInk)
                    )
                BBPill(text: tip.ageLabel(lang), color: tint.opacity(0.3))
                Spacer()
            }

            Text(tip.title(lang))
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
                .fixedSize(horizontal: false, vertical: true)

            Text(tip.summary(lang))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard()
    }

    // MARK: - Blocks

    private func numberedBlock(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: title)
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(idx + 1)")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(tint.opacity(0.35)))
                    Text(item)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard()
    }

    private func paragraphBlock(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: title)
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.bbInk)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard()
    }

    private func bulletBlock(
        title: String,
        items: [String],
        symbol: String,
        symbolColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: title)
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: symbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(symbolColor)
                        .frame(width: 22)
                    Text(item)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard()
    }

    private var redFlagBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lm.strings.careTipWhenToCallDoctor.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.75))
                .kerning(0.6)

            ForEach(Array(tip.whenToCallDoctor(lang).enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: 22)
                    Text(item)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard(bg: .bbSurface)
    }

    private var disclaimer: some View {
        Text(lm.strings.careTipsDisclaimer)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.bbInkMute)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.top, 4)
    }
}
