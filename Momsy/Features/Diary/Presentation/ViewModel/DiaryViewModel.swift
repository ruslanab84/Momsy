import SwiftUI
import Combine

@MainActor
final class DiaryViewModel: ObservableObject {
    @Published var selectedFilter = 0
    @Published var entries: [DiaryDay] = []
    @Published var likedIDs: Set<UUID> = []
    @Published var saveError: String?

    private let repo: any DiaryRepository
    private let analytics: any AnalyticsServiceProtocol
    private let appState: AppState
    private var mergeObserver: NSObjectProtocol?

    private var lm: LocalizationManager { .shared }

    var displayName: String { appState.displayName }

    var babyBirthDate: Date? { appState.babyProfile?.birthDate }

    var babyBirthDateInterval: Double {
        appState.babyProfile?.birthDate.timeIntervalSince1970 ?? 0
    }

    var filteredEntries: [DiaryDay] {
        switch selectedFilter {
        case 1:
            return compact { item in
                if case .milestone = item.type { return true }
                return false
            }
        case 2:
            return compact { if case .note = $0.type { return true }; return false }
        default:
            return entries
        }
    }

    init(repo: any DiaryRepository,
         analytics: any AnalyticsServiceProtocol = LogAnalyticsService(),
         appState: AppState) {
        self.repo = repo
        self.analytics = analytics
        self.appState = appState
        Task { await loadEntries() }
        mergeObserver = NotificationCenter.default.addObserver(
            forName: .cloudSyncDidMerge, object: nil, queue: .main
        ) { [weak self] _ in
            Task { await self?.loadEntries() }
        }
    }

    deinit {
        if let mergeObserver { NotificationCenter.default.removeObserver(mergeObserver) }
    }

    func loadEntries() async {
        let yearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? .distantPast
        let stored = (try? await repo.getEntries(from: yearAgo, to: Date())) ?? []
        entries = group(stored.filter { $0.kind != .photo }.sorted { $0.date > $1.date })
    }

    // MARK: - Grouping & Mapping

    private func group(_ items: [StoredDiaryItem]) -> [DiaryDay] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let birth: Date? = babyBirthDate

        var grouped: [Date: [StoredDiaryItem]] = [:]
        for item in items {
            let day = cal.startOfDay(for: item.date)
            grouped[day, default: []].append(item)
        }

        return grouped.sorted { $0.key > $1.key }.map { day, dayItems in
            DiaryDay(
                dateLabel: makeDateLabel(day, today: today),
                ageLabel: birth.map { makeAgeLabel(day, birth: $0) } ?? "",
                items: dayItems.map { toDiaryItem($0) }
            )
        }
    }

    private func makeDateLabel(_ day: Date, today: Date) -> String {
        let cal = Calendar.current
        let df = DateFormatter()
        df.locale = Locale(identifier: lm.lang == "en" ? "en_US" : "ru_RU")
        if cal.isDate(day, inSameDayAs: today) {
            df.dateFormat = "EEE"
            return lm.strings.todayEntry(df.string(from: day))
        }
        if let yesterday = cal.date(byAdding: .day, value: -1, to: today),
           cal.isDate(day, inSameDayAs: yesterday) {
            df.dateFormat = "EEE"
            return lm.strings.yesterdayEntry(df.string(from: day))
        }
        df.dateFormat = lm.lang == "en" ? "EEE d MMM" : "d MMM"
        return df.string(from: day)
    }

    private func makeAgeLabel(_ day: Date, birth: Date) -> String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.month, .day], from: birth, to: day)
        let months = max(0, comps.month ?? 0)
        let days = max(0, comps.day ?? 0)
        return "\(months) \(lm.strings.ageMonthShort) \(days) \(lm.strings.ageDayShort)"
    }

    private func toDiaryItem(_ stored: StoredDiaryItem) -> DiaryItem {
        switch stored.kind {
        case .note:
            return DiaryItem(id: stored.id, type: .note(text: stored.text))
        case .milestone:
            return DiaryItem(id: stored.id, type: .milestone(icon: blobKind(stored.iconName), label: stored.text))
        case .photo:
            // Photo entries no longer supported; filtered out before reaching here
            return DiaryItem(id: stored.id, type: .note(text: stored.text))
        }
    }

    private func toStored(_ item: DiaryItem, date: Date) -> StoredDiaryItem {
        switch item.type {
        case let .note(text):
            return StoredDiaryItem(id: item.id, date: date, kind: .note, text: text)
        case let .milestone(icon, label):
            return StoredDiaryItem(id: item.id, date: date, kind: .milestone, text: label, iconName: icon.iconName)
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

    func insertDay(_ newDay: DiaryDay) {
        let entryTypes = newDay.items.map { item -> String in
            switch item.type {
            case .note: return "note"
            case .milestone: return "milestone"
            }
        }
        entryTypes.forEach { analytics.track(.diaryEntryAdded(type: $0)) }
        let date = Date()
        let todayStart = Calendar.current.startOfDay(for: date)
        let todayPrefix = lm.strings.today
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let idx = entries.firstIndex(where: { $0.dateLabel.hasPrefix(todayPrefix) }) {
                entries[idx].items.insert(contentsOf: newDay.items, at: 0)
            } else {
                let label = makeDateLabel(todayStart, today: todayStart)
                let age = babyBirthDate.map { makeAgeLabel(todayStart, birth: $0) } ?? ""
                entries.insert(DiaryDay(dateLabel: label, ageLabel: age, items: newDay.items), at: 0)
            }
        }
        Task {
            for item in newDay.items {
                let stored = toStored(item, date: date)
                do {
                    try await repo.add(stored)
                    pushDiaryToFirestore(stored)
                } catch {
                    rollbackItem(item)
                    saveError = error.localizedDescription
                }
            }
        }
    }

    private func pushDiaryToFirestore(_ item: StoredDiaryItem) {
        guard FamilyManager.shared.familyId != nil else { return }
        let uid  = UserDefaults.standard.string(forKey: "uid") ?? ""
        let name = UserDefaults.standard.string(forKey: "displayName") ?? ""
        let log = DiaryLog(
            id: item.id.uuidString, date: item.date,
            kind: item.kind.rawValue, text: item.text,
            iconName: item.iconName, addedBy: uid, addedByName: name
        )
        Task { try? await BabySyncService().setLog(DiaryLogDTO(from: log), id: log.id, to: "diaryLogs") }
    }

    private func rollbackItem(_ item: DiaryItem) {
        withAnimation {
            for i in entries.indices { entries[i].items.removeAll { $0.id == item.id } }
            entries.removeAll { $0.items.isEmpty }
        }
    }
}
