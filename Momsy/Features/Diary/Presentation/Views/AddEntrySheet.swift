import SwiftUI
import PhotosUI

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
        case .photo:     return photoImage != nil && !isLoadingPhoto
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

        let newDay = DiaryDay(dateLabel: "", ageLabel: ageLabel, items: [newItem])
        onAdd(newDay, photos)
        dismiss()
    }
}
