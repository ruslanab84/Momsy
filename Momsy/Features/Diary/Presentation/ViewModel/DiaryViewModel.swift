import SwiftUI
import Combine

@MainActor
final class DiaryViewModel: ObservableObject {
    @Published var selectedFilter = 0
    @Published var entries: [DiaryDay] = []
    @Published var likedIDs: Set<UUID> = []
    @Published var photosByID: [UUID: UIImage] = [:]
    @Published var showAdd = false

    private let repo: any DiaryRepository

    private var lm: LocalizationManager { .shared }

    var displayName: String {
        let name = UserDefaults.standard.string(forKey: "babyName") ?? ""
        return name.isEmpty ? lm.t("Baby", "Малыш") : name
    }

    var babyBirthDateInterval: Double {
        UserDefaults.standard.double(forKey: "babyBirthDate")
    }

    var filteredEntries: [DiaryDay] {
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

    init(repo: any DiaryRepository) {
        self.repo = repo
        Task { await loadEntries() }
    }

    func loadEntries() async {
        let yearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? .distantPast
        let stored = (try? await repo.getEntries(from: yearAgo, to: Date())) ?? []
        entries = group(stored.sorted { $0.date > $1.date })
    }

    // MARK: - Grouping & Mapping

    private func group(_ items: [StoredDiaryItem]) -> [DiaryDay] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let birth: Date? = {
            let interval = babyBirthDateInterval
            return interval > 0 ? Date(timeIntervalSince1970: interval) : nil
        }()

        var grouped: [Date: [StoredDiaryItem]] = [:]
        for item in items {
            let day = cal.startOfDay(for: item.date)
            grouped[day, default: []].append(item)
        }

        return grouped.keys.sorted { $0 > $1 }.map { day in
            DiaryDay(
                dateLabel: makeDateLabel(day, today: today),
                ageLabel: birth.map { makeAgeLabel(day, birth: $0) } ?? "",
                items: grouped[day]!.map { toDiaryItem($0) }
            )
        }
    }

    private func makeDateLabel(_ day: Date, today: Date) -> String {
        let cal = Calendar.current
        let df = DateFormatter()
        df.locale = Locale(identifier: lm.lang == "en" ? "en_US" : "ru_RU")
        if cal.isDate(day, inSameDayAs: today) {
            df.dateFormat = "EEE"
            return lm.t("Today · \(df.string(from: day))", "Сегодня · \(df.string(from: day))")
        }
        if let yesterday = cal.date(byAdding: .day, value: -1, to: today),
           cal.isDate(day, inSameDayAs: yesterday) {
            df.dateFormat = "EEE"
            return lm.t("Yesterday · \(df.string(from: day))", "Вчера · \(df.string(from: day))")
        }
        df.dateFormat = lm.lang == "en" ? "EEE d MMM" : "d MMM"
        return df.string(from: day)
    }

    private func makeAgeLabel(_ day: Date, birth: Date) -> String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.month, .day], from: birth, to: day)
        let months = max(0, comps.month ?? 0)
        let days = max(0, comps.day ?? 0)
        return lm.lang == "en" ? "\(months) mo \(days) d" : "\(months) мес \(days) дн"
    }

    private func toDiaryItem(_ stored: StoredDiaryItem) -> DiaryItem {
        switch stored.kind {
        case .note:
            return DiaryItem(id: stored.id, type: .note(text: stored.text))
        case .milestone:
            return DiaryItem(id: stored.id, type: .milestone(icon: blobKind(stored.iconName), label: stored.text))
        case .photo:
            return DiaryItem(id: stored.id, type: .photo(
                tone: Color(bbHex: stored.toneHex),
                handwriting: stored.text,
                isMilestone: stored.isMilestone
            ))
        }
    }

    private func toStored(_ item: DiaryItem, date: Date) -> StoredDiaryItem {
        switch item.type {
        case let .note(text):
            return StoredDiaryItem(id: item.id, date: date, kind: .note, text: text)
        case let .milestone(icon, label):
            return StoredDiaryItem(id: item.id, date: date, kind: .milestone, text: label, iconName: icon.iconName)
        case let .photo(tone, handwriting, isMilestone):
            return StoredDiaryItem(id: item.id, date: date, kind: .photo, text: handwriting,
                                   toneHex: tone.hexString, isMilestone: isMilestone)
        }
    }

    private func blobKind(_ name: String) -> BlobKind {
        switch name {
        case "baby":   return .baby
        case "sleep":  return .sleep
        case "bottle": return .bottle
        case "moon":   return .moon
        case "sun":    return .sun
        case "drop":   return .drop
        case "star":   return .star
        case "heart":  return .heart
        case "cloud":  return .cloud
        case "bear":   return .bear
        default:       return .heart
        }
    }

    // MARK: - Actions

    func compact(_ predicate: (DiaryItem) -> Bool) -> [DiaryDay] {
        entries.compactMap { day in
            let filtered = day.items.filter(predicate)
            return filtered.isEmpty ? nil : DiaryDay(dateLabel: day.dateLabel, ageLabel: day.ageLabel, items: filtered)
        }
    }

    func toggleLike(_ id: UUID) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
            if likedIDs.contains(id) { likedIDs.remove(id) } else { likedIDs.insert(id) }
        }
    }

    func insertDay(_ newDay: DiaryDay, photos: [UUID: UIImage]) {
        let date = Date()
        let todayPrefix = lm.t("Today", "Сегодня")
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let idx = entries.firstIndex(where: { $0.dateLabel.hasPrefix(todayPrefix) }) {
                entries[idx].items.insert(contentsOf: newDay.items, at: 0)
            } else {
                entries.insert(newDay, at: 0)
            }
            photosByID.merge(photos) { _, new in new }
        }
        Task {
            for item in newDay.items {
                try? await repo.add(toStored(item, date: date))
            }
        }
    }
}
