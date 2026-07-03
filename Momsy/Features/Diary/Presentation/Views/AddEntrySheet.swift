import SwiftUI

// MARK: - Add Entry Sheet

struct AddEntrySheet: View {
    let babyName: String
    let babyBirthDateInterval: Double
    let onAdd: (DiaryDay) -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager

    private enum EntryType: String, CaseIterable {
        case note = "note"
        case milestone = "milestone"

        func displayName(_ strings: L10n) -> String {
            switch self {
            case .note:      return strings.noteSectionLabel
            case .milestone: return strings.milestone
            }
        }
    }

    private var presetMilestones: [(BlobKind, String)] {
        [
            (.star,   loc.strings.milestoneFirstSmile),
            (.moon,   loc.strings.milestoneRolledOver),
            (.baby,   loc.strings.milestoneSatUpAlone),
            (.bear,   loc.strings.milestoneFirstTooth),
            (.bottle, loc.strings.milestoneTriedSolids),
            (.heart,  loc.strings.milestoneFirstWord),
        ]
    }

    @State private var entryType: EntryType = .note
    @State private var noteText = ""
    @State private var milestoneLabel = ""
    @State private var selectedIcon: BlobKind = .star

    private var isValid: Bool {
        switch entryType {
        case .note:      return !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .milestone: return !milestoneLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                            Text($0.displayName(loc.strings)).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 4)

                    Group {
                        switch entryType {
                        case .note:      noteContent
                        case .milestone: milestoneContent
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

    // MARK: - Commit

    private func commit() {
        let newItem: DiaryItem
        switch entryType {
        case .note:
            newItem = DiaryItem(type: .note(text: noteText.trimmingCharacters(in: .whitespacesAndNewlines)))
        case .milestone:
            newItem = DiaryItem(type: .milestone(icon: selectedIcon, label: milestoneLabel.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        let newDay = DiaryDay(dateLabel: "", ageLabel: ageLabel, items: [newItem])
        onAdd(newDay)
        dismiss()
    }
}
