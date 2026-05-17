import SwiftUI
import PhotosUI

// MARK: - DiaryView

struct DiaryView: View {
    @AppStorage("babyName")      private var babyName = ""
    @AppStorage("babyBirthDate") private var babyBirthDateInterval: Double = 0
    @AppStorage("appLanguage")   private var lang = "en"

    @State private var selectedFilter = 0
    @State private var entries: [DiaryDay] = sampleDiary
    @State private var likedIDs: Set<UUID> = []
    @State private var photosByID: [UUID: UIImage] = [:]
    @State private var showAdd = false

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    private var filters: [String] {
        [t("All", "Всё"), "★ Milestones", t("📷 Photo", "📷 Фото"), t("✎ Notes", "✎ Заметки")]
    }

    private var displayName: String { babyName.isEmpty ? t("Baby", "Малыша") : babyName }

    private var filteredEntries: [DiaryDay] {
        switch selectedFilter {
        case 1:
            return compact { item in
                if case .milestone = item.type { return true }
                if case let .photo(_, _, isMilestone) = item.type { return isMilestone }
                return false
            }
        case 2:
            return compact { if case .photo = $0.type { return true }; return false }
        case 3:
            return compact { if case .note = $0.type { return true }; return false }
        default:
            return entries
        }
    }

    private func compact(_ predicate: (DiaryItem) -> Bool) -> [DiaryDay] {
        entries.compactMap { day in
            let filtered = day.items.filter(predicate)
            return filtered.isEmpty ? nil : DiaryDay(dateLabel: day.dateLabel, ageLabel: day.ageLabel, items: filtered)
        }
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

                if filteredEntries.isEmpty {
                    emptyState
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 20) {
                        ForEach(filteredEntries) { day in
                            DiaryDaySection(
                                day: day,
                                likedIDs: likedIDs,
                                photosByID: photosByID,
                                onLike: { id in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                                        if likedIDs.contains(id) { likedIDs.remove(id) }
                                        else { likedIDs.insert(id) }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .animation(.spring(response: 0.38, dampingFraction: 0.82), value: selectedFilter)
                }

                Text(t("A year from now you'll open this and smile ✿",
                       "через год вы откроете это и будете улыбаться ✿"))
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
        .sheet(isPresented: $showAdd) {
            AddEntrySheet(
                babyName: displayName,
                babyBirthDateInterval: babyBirthDateInterval,
                onAdd: { newDay, photos in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        insertDay(newDay)
                        photosByID.merge(photos) { _, new in new }
                    }
                }
            )
        }
    }

    // MARK: - Helpers

    private func insertDay(_ newDay: DiaryDay) {
        let todayPrefix = t("Today", "Сегодня")
        if let idx = entries.firstIndex(where: { $0.dateLabel.hasPrefix(todayPrefix) }) {
            entries[idx].items.insert(contentsOf: newDay.items, at: 0)
        } else {
            entries.insert(newDay, at: 0)
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                BBSectionLabel(text: t("Feed", "Лента"))
                Text(t("\(displayName)'s Diary", "Дневник \(displayName)"))
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
            }
            Spacer()
            Button { showAdd = true } label: {
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
                            selectedFilter = i
                        }
                    } label: {
                        Text(filters[i])
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(selectedFilter == i ? .white : .bbInkSoft)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedFilter == i ? Color.bbSurface : Color.bbCard)
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
            Text(t("Empty", "Пусто"))
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Text(t("Nothing in this category yet.\nAdd the first — tap +",
                   "В этой категории пока нет записей.\nДобавьте первую — нажмите +"))
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

    @AppStorage("appLanguage") private var lang = "en"
    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

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
                    Label(t("baby's photo", "фото малыша"), systemImage: "camera")
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
    @AppStorage("appLanguage") private var lang = "en"

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

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
        lang == "en" ? [
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
        if m == 0 { return "\(d) \(t("d", "дн"))" }
        if d == 0 { return "\(m) \(t("mo", "мес"))" }
        return "\(m) \(t("mo", "мес")) \(d) \(t("d", "дн"))"
    }

    private var todayLabel: String {
        let f = DateFormatter()
        if lang == "en" {
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
                    Picker(t("Type", "Тип"), selection: $entryType) {
                        ForEach(EntryType.allCases, id: \.self) {
                            Text($0.displayName(lang: lang)).tag($0)
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
                        Text(t("Add to Diary", "Добавить в дневник"))
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
            .navigationTitle(t("New Entry", "Новая запись"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(t("Cancel", "Отмена")) { dismiss() }
                        .foregroundColor(.bbInkSoft)
                }
            }
        }
    }

    // MARK: - Note content

    private var noteContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t("WHAT DO YOU WANT TO WRITE?", "ЧТО ХОТИТЕ ЗАПИСАТЬ?"))
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
                        Text(t("E.g. Laughed out loud for the first time!",
                               "Например: «Впервые засмеялся в голос!»"))
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
            Text(t("CHOOSE ICON", "ВЫБЕРИТЕ ИКОНКУ"))
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

            Text(t("OR WRITE YOUR OWN", "ИЛИ НАПИШИТЕ СВОЁ"))
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)

            TextField(t("E.g. First roll-over", "Например: «Первый переворот»"), text: $milestoneLabel)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .padding(14)
                .background(Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Photo content

    private var photoContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(t("CHOOSE PHOTO", "ВЫБЕРИТЕ ФОТО"))
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
                            .frame(height: 180)
                            .overlay(
                                VStack(spacing: 8) {
                                    if isLoadingPhoto {
                                        ProgressView().tint(.white)
                                    } else {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 32, weight: .light))
                                            .foregroundColor(.white.opacity(0.8))
                                        Text(t("Tap to choose", "Нажмите, чтобы выбрать"))
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                    Text(t("Placeholder color:", "Цвет плейсхолдера:"))
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

            Text(t("CAPTION (handwriting style)", "ПОДПИСЬ (рукописный стиль)"))
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)

            TextField(t("E.g. first laugh", "Например: «первый смех»"), text: $caption)
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
            newItem = DiaryItem(type: .photo(tone: selectedTone, handwriting: caption.isEmpty ? t("moment", "момент") : caption, isMilestone: false))
            if let img = photoImage { photos[newItem.id] = img }
        }

        let newDay = DiaryDay(dateLabel: todayLabel, ageLabel: ageLabel, items: [newItem])
        onAdd(newDay, photos)
        dismiss()
    }
}

#Preview {
    DiaryView()
}
