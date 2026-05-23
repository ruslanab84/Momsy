import SwiftUI

// MARK: - Day Section

struct DiaryDaySection: View {
    let day: DiaryDay
    let likedIDs: Set<UUID>
    let photosByID: [UUID: UIImage]
    let uploadProgress: [UUID: Double]
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
                    image: photosByID[item.id],
                    uploadProgress: uploadProgress[item.id],
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
    let image: UIImage?
    let uploadProgress: Double?
    let isLiked: Bool
    let onLike: () -> Void

    var body: some View {
        switch item.type {
        case let .photo(tone, handwriting, isMilestone):
            PhotoCard(
                tone: tone,
                handwriting: handwriting,
                isMilestone: isMilestone,
                image: image,
                uploadProgress: uploadProgress,
                isLiked: isLiked,
                onLike: onLike
            )
        case let .note(text):
            NoteCard(text: text, isLiked: isLiked, onLike: onLike)
        case let .milestone(icon, label):
            MilestoneCard(icon: icon, label: label, isLiked: isLiked, onLike: onLike)
        }
    }
}

// MARK: - Photo Card

private struct PhotoCard: View {
    let tone: Color
    let handwriting: String
    let isMilestone: Bool
    let image: UIImage?
    let uploadProgress: Double?
    let isLiked: Bool
    let onLike: () -> Void
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        ZStack(alignment: .bottom) {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .clipped()
            } else {
                tone
                    .frame(height: 240)
                    .overlay(
                        LinearGradient(
                            colors: [.white.opacity(0.18), .clear, .white.opacity(0.12)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.35)],
                startPoint: .center, endPoint: .bottom
            )

            HStack(alignment: .bottom) {
                Text(handwriting)
                    .font(.custom("Georgia", size: 24))
                    .italic()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                    .padding(.leading, 16)
                    .padding(.bottom, 14)

                Spacer()

                Button(action: onLike) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isLiked ? Color.bbRose : .white)
                        .shadow(color: .black.opacity(0.2), radius: 3)
                        .padding(.trailing, 16)
                        .padding(.bottom, 14)
                        .scaleEffect(isLiked ? 1.15 : 1.0)
                }
            }

            if let progress = uploadProgress {
                UploadProgressOverlay(progress: progress)
            }
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(alignment: .topLeading) {
            HStack(spacing: 6) {
                if image == nil && uploadProgress == nil {
                    Label(loc.strings.babyPhotoLabel, systemImage: "camera")
                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                        .foregroundColor(.bbInk)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.93))
                        .clipShape(Capsule())
                }
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
        }
        .bbShadowSoft()
    }
}

private struct UploadProgressOverlay: View {
    let progress: Double

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 44, height: 44)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.2), value: progress)
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
