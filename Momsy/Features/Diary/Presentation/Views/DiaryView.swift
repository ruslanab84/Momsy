import SwiftUI
import PhotosUI

// MARK: - DiaryView

struct DiaryView: View {
    @StateObject private var vm: DiaryViewModel
    @EnvironmentObject var loc: LocalizationManager

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeDiaryViewModel())
    }

    private var filters: [String] {
        [loc.strings.all, "★ Milestones", loc.strings.filterPhoto, loc.strings.filterNotes]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                filterRow
                    .padding(.bottom, 12)

                if vm.filteredEntries.isEmpty {
                    emptyState
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 20) {
                        ForEach(vm.filteredEntries) { day in
                            DiaryDaySection(
                                day: day,
                                likedIDs: vm.likedIDs,
                                photosByID: vm.photosByID,
                                onLike: { id in vm.toggleLike(id) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .animation(.spring(response: 0.38, dampingFraction: 0.82), value: vm.selectedFilter)
                }

                Text(loc.strings.diaryQuote)
                    .font(.custom("Georgia", size: 18))
                    .italic()
                    .foregroundColor(.bbInkMute)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 28)
                    .padding(.bottom, 32)
            }
        }
        .background(Color.bbCream.ignoresSafeArea())
        .sheet(isPresented: $vm.showAdd) {
            AddEntrySheet(
                babyName: vm.displayName,
                babyBirthDateInterval: vm.babyBirthDateInterval,
                onAdd: { newDay, photos in vm.insertDay(newDay, photos: photos) }
            )
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                BBSectionLabel(text: loc.strings.feed)
                Text(loc.strings.diaryTitle(name: vm.displayName))
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
            }
            Spacer()
            Button { vm.showAdd = true } label: {
                Circle()
                    .fill(Color.bbCoralDeep)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .bbShadow()
            }
        }
    }

    // MARK: - Filters

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(filters.indices, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                            vm.selectedFilter = i
                        }
                    } label: {
                        Text(filters[i])
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(vm.selectedFilter == i ? .white : .bbInkSoft)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(vm.selectedFilter == i ? Color.bbSurface : Color.bbCard)
                            .clipShape(Capsule())
                            .bbShadowSoft()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 2)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            CuteBlobView(kind: .heart, size: 72, tone: .bbRose)
            Text(loc.strings.empty)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Text(loc.strings.diaryEmptyHint)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Day Section

private struct DiaryDaySection: View {
    let day: DiaryDay
    let likedIDs: Set<UUID>
    let photosByID: [UUID: UIImage]
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
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(alignment: .topLeading) {
            HStack(spacing: 6) {
                if image == nil {
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

// MARK: - Add Entry Sheet

struct AddEntrySheet: View {
    let babyName: String
    let babyBirthDateInterval: Double
    let onAdd: (DiaryDay, [UUID: UIImage]) -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager

    private enum EntryType: String, CaseIterable {
        case note = "note"
        case milestone = "milestone"
        case photo = "photo"

        func displayName(lang: String) -> String {
            switch self {
            case .note:      return lang == "en" ? "Note"      : "Заметка"
            case .milestone: return "Milestone"
            case .photo:     return lang == "en" ? "Photo"     : "Фото"
            }
        }
    }

    private var presetMilestones: [(BlobKind, String)] {
        loc.lang == "en" ? [
            (.star,   "First smile"),
            (.moon,   "Rolled over"),
            (.baby,   "Sat up alone"),
            (.bear,   "First tooth"),
            (.bottle, "Tried solids"),
            (.heart,  "First word"),
        ] : [
            (.star,   "Первая улыбка"),
            (.moon,   "Перевернулся"),
            (.baby,   "Сел сам"),
            (.bear,   "Первый зуб"),
            (.bottle, "Попробовал прикорм"),
            (.heart,  "Первое слово"),
        ]
    }

    private let photoTones: [Color] = [.bbCoral, .bbButter, .bbMint, .bbLilac, .bbSky, .bbRose]

    @State private var entryType: EntryType = .note
    @State private var noteText = ""
    @State private var milestoneLabel = ""
    @State private var selectedIcon: BlobKind = .star
    @State private var caption = ""
    @State private var selectedTone: Color = .bbCoral
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var photoImage: UIImage? = nil
    @State private var isLoadingPhoto = false

    private var isValid: Bool {
        switch entryType {
        case .note:      return !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .milestone: return !milestoneLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .photo:     return true
        }
    }

    private var ageLabel: String {
        guard babyBirthDateInterval > 0 else { return "" }
        let birth = Date(timeIntervalSince1970: babyBirthDateInterval)
        let comps = Calendar.current.dateComponents([.month, .day], from: birth, to: Date())
        let m = comps.month ?? 0, d = comps.day ?? 0
        if m == 0 { return "\(d) \(loc.strings.unitDay)" }
        if d == 0 { return "\(m) \(loc.strings.unitMonth)" }
        return "\(m) \(loc.strings.unitMonth) \(d) \(loc.strings.unitDay)"
    }

    private var todayLabel: String {
        let f = DateFormatter()
        if loc.lang == "en" {
            f.locale = Locale(identifier: "en_US")
            f.dateFormat = "EEE, d MMM"
            return "Today · " + f.string(from: Date())
        } else {
            f.locale = Locale(identifier: "ru_RU")
            f.dateFormat = "EEEE, d MMMM"
            return "Сегодня · " + String(f.string(from: Date()).prefix(2).lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Picker(loc.strings.entryType, selection: $entryType) {
                        ForEach(EntryType.allCases, id: \.self) {
                            Text($0.displayName(lang: loc.lang)).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 4)

                    Group {
                        switch entryType {
                        case .note:      noteContent
                        case .milestone: milestoneContent
                        case .photo:     photoContent
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: entryType)

                    Button(action: commit) {
                        Text(loc.strings.addToDiary)
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(isValid ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .disabled(!isValid)
                    .animation(.easeInOut(duration: 0.2), value: isValid)
                }
                .padding(20)
            }
            .background(Color.bbCream.ignoresSafeArea())
            .navigationTitle(loc.strings.newEntry)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }
                        .foregroundColor(.bbInkSoft)
                }
            }
        }
    }

    // MARK: - Note content

    private var noteContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.strings.whatToWrite)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)
            TextEditor(text: $noteText)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .frame(minHeight: 120)
                .padding(12)
                .background(Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.bbInkMute.opacity(0.2), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if noteText.isEmpty {
                        Text(loc.strings.noteExamplePlaceholder)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.bbInkMute.opacity(0.6))
                            .padding(16)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    // MARK: - Milestone content

    private var milestoneContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.strings.chooseIcon)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(presetMilestones, id: \.1) { kind, label in
                    Button {
                        selectedIcon = kind
                        milestoneLabel = label
                    } label: {
                        VStack(spacing: 6) {
                            CuteBlobView(kind: kind, size: 36, tone: .bbButter)
                            Text(label)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.bbInk)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(milestoneLabel == label ? Color.bbButter : Color.bbCard)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(milestoneLabel == label ? Color.bbButterDeep : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(loc.strings.orWriteYourOwn)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)

            TextField(loc.strings.milestoneExamplePlaceholder, text: $milestoneLabel)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .padding(14)
                .background(Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Photo content

    private var photoContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.strings.choosePhoto)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)

            PhotosPicker(selection: $photoItem, matching: .images) {
                ZStack {
                    if let img = photoImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .clipped()
                    } else {
                        selectedTone
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .overlay(
                                VStack(spacing: 8) {
                                    if isLoadingPhoto {
                                        ProgressView().tint(.white)
                                    } else {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 32, weight: .light))
                                            .foregroundColor(.white.opacity(0.8))
                                        Text(loc.strings.tapToChoose)
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .contentShape(Rectangle())
            }
            .onChange(of: photoItem) { _, new in
                guard let new else { return }
                isLoadingPhoto = true
                Task {
                    if let data = try? await new.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        photoImage = img
                    }
                    isLoadingPhoto = false
                }
            }

            if photoImage == nil {
                HStack(spacing: 10) {
                    Text(loc.strings.placeholderColor)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                    ForEach(photoTones, id: \.self) { c in
                        Button { selectedTone = c } label: {
                            Circle()
                                .fill(c)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle().strokeBorder(
                                        selectedTone == c ? Color.bbInk : Color.clear,
                                        lineWidth: 2
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Text(loc.strings.captionHandwriting)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)

            TextField(loc.strings.captionExamplePlaceholder, text: $caption)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .padding(14)
                .background(Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Commit

    private func commit() {
        var photos: [UUID: UIImage] = [:]
        let newItem: DiaryItem

        switch entryType {
        case .note:
            newItem = DiaryItem(type: .note(text: noteText.trimmingCharacters(in: .whitespacesAndNewlines)))

        case .milestone:
            newItem = DiaryItem(type: .milestone(icon: selectedIcon, label: milestoneLabel.trimmingCharacters(in: .whitespacesAndNewlines)))

        case .photo:
            newItem = DiaryItem(type: .photo(tone: selectedTone, handwriting: caption.isEmpty ? loc.strings.moment : caption, isMilestone: false))
            if let img = photoImage { photos[newItem.id] = img }
        }

        let newDay = DiaryDay(dateLabel: todayLabel, ageLabel: ageLabel, items: [newItem])
        onAdd(newDay, photos)
        dismiss()
    }
}

#Preview {
    DiaryView(container: AppContainer())
        .environmentObject(LocalizationManager.shared)
}
