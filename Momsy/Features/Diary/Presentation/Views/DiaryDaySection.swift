import SwiftUI

// MARK: - Day Section

struct DiaryDaySection: View {
    let day: DiaryDay
    let likedIDs: Set<UUID>
    let onLike: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
                DiaryItemView(
                    item: item,
                    isLiked: likedIDs.contains(item.id),
                    onLike: { onLike(item.id) }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
    }
}

// MARK: - Item router

private struct DiaryItemView: View {
    let item: DiaryItem
    let isLiked: Bool
    let onLike: () -> Void

    var body: some View {
        switch item.type {
        case let .note(text):
            NoteCard(text: text, isLiked: isLiked, onLike: onLike)
        case let .milestone(icon, label):
            MilestoneCard(icon: icon, label: label, isLiked: isLiked, onLike: onLike)
        }
    }
}

// MARK: - Note Card

private struct NoteCard: View {
    let text: String
    let isLiked: Bool
    let onLike: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.bbInk)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onLike) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 18))
                    .foregroundColor(isLiked ? .bbRose : .bbInkMute)
                    .scaleEffect(isLiked ? 1.15 : 1.0)
            }
            .padding(.leading, 12)
        }
        .bbCard(pad: 14)
    }
}

// MARK: - Milestone Card

private struct MilestoneCard: View {
    let icon: BlobKind
    let label: String
    let isLiked: Bool
    let onLike: () -> Void

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
            Spacer()
            Button(action: onLike) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 18))
                    .foregroundColor(isLiked ? .bbRose : .bbInkMute)
                    .scaleEffect(isLiked ? 1.15 : 1.0)
            }
        }
        .bbCard(pad: 14, bg: .bbButter)
    }
}
