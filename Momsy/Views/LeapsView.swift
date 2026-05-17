import SwiftUI

struct LeapsView: View {
    @AppStorage("babyName") private var babyName = ""
    @State private var expandedLeapID: Int? = nil

    private var displayName: String { babyName.isEmpty ? "Малыш" : babyName }
    private var currentLeap: DevelopmentLeap { sampleLeaps.first(where: { $0.isCurrent }) ?? sampleLeaps[3] }

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
            Text("Сейчас — скачок №\(currentLeap.id)")
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
                BBPill(text: "\(currentLeap.week)-я неделя", color: .bbInk, fg: .white)
            }

            Text("«\(currentLeap.name)»")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)

            Text("\(displayName) \(currentLeap.description)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color.bbInk.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                LeapInfoBlock(
                    title: "ЧТО ЗАМЕТНО",
                    items: currentLeap.signs,
                    accent: .bbCoralDeep
                )
                LeapInfoBlock(
                    title: "СКОРО НАУЧИТСЯ",
                    items: currentLeap.skills,
                    accent: .bbMintDeep
                )
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

    // MARK: - Timeline

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: "Календарь скачков")
            VStack(spacing: 0) {
                ForEach(sampleLeaps) { leap in
                    LeapTimelineRow(
                        leap: leap,
                        isExpanded: expandedLeapID == leap.id,
                        isLast: leap.id == sampleLeaps.count
                    ) {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                            expandedLeapID = expandedLeapID == leap.id ? nil : leap.id
                        }
                    }
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
            Text("Для скачка «\(currentLeap.name)»")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.bbInk)
            Text(currentLeap.tip)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .bbCard(pad: 14, bg: Color.bbMint.opacity(0.3))
    }
}

// MARK: - Leap Info Block

private struct LeapInfoBlock: View {
    let title: String
    let items: [String]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundColor(accent)
                .kerning(0.4)
            ForEach(items, id: \.self) { item in
                Text("· \(item)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInk)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Timeline Row

private struct LeapTimelineRow: View {
    let leap: DevelopmentLeap
    let isExpanded: Bool
    let isLast: Bool
    let onTap: () -> Void

    private var dotFill: Color {
        if leap.isDone    { return .bbMint }
        if leap.isCurrent { return leap.tone }
        return .bbCreamSoft
    }
    private var dotBorder: Color {
        if leap.isCurrent { return .bbCoralDeep }
        if leap.isDone    { return .bbMintDeep }
        return Color.bbInkMute.opacity(0.2)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Dot + connector line
                VStack(spacing: 0) {
                    Circle()
                        .fill(dotFill)
                        .overlay(Circle().strokeBorder(dotBorder, lineWidth: leap.isCurrent ? 3 : 2))
                        .frame(width: 38, height: 38)
                        .overlay(
                            Group {
                                if leap.isDone {
                                    Text("✓")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundColor(.bbMintDeep)
                                } else {
                                    Text("\(leap.id)")
                                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                                        .foregroundColor(leap.isCurrent ? .bbInk : .bbInkMute)
                                }
                            }
                        )
                    if !isLast {
                        Rectangle()
                            .fill(Color.bbCreamSoft)
                            .frame(width: 2)
                            .frame(minHeight: isExpanded ? 28 : 14)
                    }
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center) {
                        Text(leap.name)
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(leap.isCurrent ? .bbCoralDeep : .bbInk)
                        Spacer()
                        HStack(spacing: 4) {
                            Text("\(leap.week) нед")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.bbInkMute)
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.bbInkMute)
                        }
                    }

                    Group {
                        if leap.isCurrent {
                            Text("идёт сейчас")
                                .foregroundColor(.bbCoralDeep)
                        } else if leap.isDone {
                            Text("завершён")
                                .foregroundColor(.bbMintDeep)
                        } else {
                            Text("впереди · \(leap.week)-я неделя")
                                .foregroundColor(.bbInkMute)
                        }
                    }
                    .font(.system(size: 11, weight: .bold, design: .rounded))

                    if isExpanded {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(leap.description.prefix(1).uppercased() + leap.description.dropFirst())
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.bbInkSoft)
                                .fixedSize(horizontal: false, vertical: true)

                            if !leap.signs.isEmpty {
                                HStack(alignment: .top, spacing: 10) {
                                    MiniList(label: "замечают", items: leap.signs, accent: .bbCoral)
                                    MiniList(label: "научится", items: leap.skills, accent: .bbMintDeep)
                                }
                            }

                            if !leap.tip.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.bbButterDeep)
                                    Text(leap.tip)
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundColor(.bbInkSoft)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(8)
                                .background(Color.bbButter.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, isLast ? 0 : 8)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Mini List

private struct MiniList: View {
    let label: String
    let items: [String]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundColor(accent)
                .kerning(0.3)
            ForEach(items.prefix(3), id: \.self) { item in
                Text("· \(item)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInk)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    LeapsView()
}
