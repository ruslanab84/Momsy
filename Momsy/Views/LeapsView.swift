import SwiftUI

struct LeapsView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                currentLeapCard
                timelineSection
                tipCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            BBSectionLabel(text: "Скачки развития")
            Text("Сейчас — скачок №4")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            HStack(spacing: 4) {
                Text("День 3 из ~5 трудных.")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                Text("держитесь, мама ✿")
                    .font(.custom("Georgia", size: 17))
                    .italic()
                    .foregroundColor(.bbCoralDeep)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Current Leap Card

    private var currentLeapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CuteBlobView(kind: .star, size: 56, tone: Color.white.opacity(0.4))
                Spacer()
                BBPill(text: "17-я неделя", color: .bbInk, fg: .white)
            }

            Text("«Мир событий»")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)

            Text("Лёва начинает понимать, что одно действие приводит к другому. Это огромная работа для мозга — отсюда плач и плохой сон.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color.bbInk.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                signsBlock
                skillsBlock
            }

            Text("✿ Это пройдёт. Обычно длится ~1 неделю. Чаще берите на руки — это не балует.")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(10)
                .background(Color.bbInk)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .bbCard(pad: 18, bg: .bbCoral)
    }

    private var signsBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ЧТО ЗАМЕТНО")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundColor(.bbCoralDeep)
                .kerning(0.4)
            ForEach(["хуже спит", "требует рук", "капризничает", "отказ от еды"], id: \.self) { s in
                Text("· \(s)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInk)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var skillsBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("СКОРО НАУЧИТСЯ")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundColor(.bbMintDeep)
                .kerning(0.4)
            ForEach(["следит глазами", "хватает предметы", "узнаёт игрушку", "гулит на смех"], id: \.self) { s in
                Text("· \(s)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInk)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Timeline

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: "Календарь скачков")

            VStack(spacing: 0) {
                ForEach(sampleLeaps) { leap in
                    LeapTimelineRow(leap: leap)
                }
            }
            .bbCard(pad: 14)
        }
    }

    // MARK: - Tip Card

    private var tipCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("СОВЕТ НА СЕГОДНЯ")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(.bbMintDeep)
                .kerning(0.5)
            Text("Покажите Лёве чёрно-белую книжку.")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.bbInk)
            Text("В этот скачок особенно интересны контрасты и причинно-следственные игры (нажал — пискнуло).")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .bbCard(pad: 14, bg: Color.bbMint.opacity(0.3))
    }
}

// MARK: - Timeline Row

private struct LeapTimelineRow: View {
    let leap: DevelopmentLeap

    var dotColor: Color {
        if leap.isDone    { return .bbMint }
        if leap.isCurrent { return leap.tone }
        return .bbCreamSoft
    }
    var dotBorderColor: Color {
        if leap.isCurrent { return .bbCoralDeep }
        if leap.isDone    { return .bbMintDeep }
        return Color.bbInkMute.opacity(0.2)
    }
    var labelColor: Color {
        leap.isCurrent ? .bbCoralDeep : .bbInk
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // dot + line
            VStack(spacing: 0) {
                Circle()
                    .fill(dotColor)
                    .overlay(Circle().strokeBorder(dotBorderColor, lineWidth: leap.isCurrent ? 3 : 2))
                    .frame(width: 38, height: 38)
                    .overlay(
                        Group {
                            if leap.isDone {
                                Text("✓").font(.system(size: 14, weight: .heavy)).foregroundColor(.bbMintDeep)
                            } else {
                                Text("\(leap.id)").font(.system(size: 14, weight: .heavy, design: .rounded))
                                    .foregroundColor(leap.isCurrent ? .bbInk : .bbInkMute)
                            }
                        }
                    )
                if leap.id < sampleLeaps.count {
                    Rectangle()
                        .fill(Color.bbCreamSoft)
                        .frame(width: 2, height: 14)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(leap.name)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(labelColor)
                    Spacer()
                    Text("\(leap.week) нед")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
                if leap.isCurrent {
                    Text("идёт сейчас")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.bbCoralDeep)
                } else if leap.isDone {
                    Text("прошли · 2 фото")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.bbMintDeep)
                }
            }
            .padding(.top, 8)
        }
        .padding(.bottom, leap.id < sampleLeaps.count ? 0 : 0)
    }
}

#Preview {
    LeapsView()
}
