import SwiftUI

struct DiaryView: View {
    @State private var selectedFilter = 0
    private let filters = ["Всё", "★ Milestones", "📷 Фото", "Заметки", "По месяцам"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                filterRow
                    .padding(.bottom, 12)

                VStack(spacing: 18) {
                    ForEach(sampleDiary) { day in
                        DiaryDaySection(day: day)
                    }
                }
                .padding(.horizontal, 20)

                Text("через год вы откроете это и будете улыбаться ✿")
                    .font(.custom("Georgia", size: 20))
                    .italic()
                    .foregroundColor(.bbInkMute)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 16)
                    .padding(.bottom, 30)
            }
        }
        .background(Color.bbCream.ignoresSafeArea())
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                BBSectionLabel(text: "Лента")
                Text("Дневник Лёвы")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
            }
            Spacer()
            Circle()
                .fill(Color.bbCoralDeep)
                .frame(width: 44, height: 44)
                .overlay(
                    Text("+")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                )
                .bbShadow()
        }
    }

    // MARK: - Filters

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(filters.indices, id: \.self) { i in
                    Text(filters[i])
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(i == selectedFilter ? .white : .bbInkSoft)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(i == selectedFilter ? Color.bbInk : Color.bbCard)
                        .clipShape(Capsule())
                        .bbShadowSoft()
                        .onTapGesture { selectedFilter = i }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 2)
        }
    }
}

// MARK: - Day Section

private struct DiaryDaySection: View {
    let day: DiaryDay

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(day.dateLabel)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Spacer()
                Text(day.ageLabel)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }
            .padding(.horizontal, 4)

            ForEach(day.items) { item in
                DiaryItemView(item: item)
            }
        }
    }
}

// MARK: - Item Views

private struct DiaryItemView: View {
    let item: DiaryItem

    var body: some View {
        switch item.type {
        case let .photo(tone, handwriting, isMilestone):
            PhotoCard(tone: tone, handwriting: handwriting, isMilestone: isMilestone)
        case let .note(text):
            NoteCard(text: text)
        case let .milestone(icon, label):
            MilestoneCard(icon: icon, label: label)
        }
    }
}

private struct PhotoCard: View {
    let tone: Color
    let handwriting: String
    let isMilestone: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // striped placeholder
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tone)
                .frame(height: 220)
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.clear, Color.white.opacity(0.18)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                )

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("фото малыша")
                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                        .foregroundColor(.bbInk)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.93))
                        .clipShape(Capsule())

                    Spacer()

                    if isMilestone {
                        Text("★ milestone")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInk)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.bbButterDeep)
                            .clipShape(Capsule())
                    }
                }
                .padding(12)

                Spacer()

                Text(handwriting)
                    .font(.custom("Georgia", size: 26))
                    .italic()
                    .foregroundColor(.bbInk)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
            }
            .frame(height: 220)
        }
        .bbShadowSoft()
    }
}

private struct NoteCard: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(.bbInk)
            .fixedSize(horizontal: false, vertical: true)
            .bbCard(pad: 14)
    }
}

private struct MilestoneCard: View {
    let icon: BlobKind
    let label: String

    var body: some View {
        HStack(spacing: 12) {
            CuteBlobView(kind: icon, size: 42, tone: Color.bbButterDeep.opacity(0.35))
            VStack(alignment: .leading, spacing: 2) {
                Text("★ MILESTONE")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbButterDeep)
                    .kerning(0.4)
                Text(label)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
            }
        }
        .bbCard(pad: 14, bg: .bbButter)
    }
}

#Preview {
    DiaryView()
}
