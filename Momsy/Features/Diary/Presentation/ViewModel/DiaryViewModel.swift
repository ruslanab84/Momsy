import SwiftUI
import Combine

@MainActor
final class DiaryViewModel: ObservableObject {
    @Published var selectedFilter = 0
    @Published var entries: [DiaryDay] = []
    @Published var likedIDs: Set<UUID> = []
    @Published var photosByID: [UUID: UIImage] = [:]
    @Published var uploadProgress: [UUID: Double] = [:]
    @Published var showAdd = false
    @Published var saveError: String?

    private let repo: any DiaryRepository
    private let photoStorage: any PhotoStorageService
    private let analytics: any AnalyticsServiceProtocol
    private let appState: AppState

    private var lm: LocalizationManager { .shared }

    var displayName: String {
        let name = appState.babyProfile?.name ?? ""
        return name.isEmpty ? lm.strings.baby : name
    }

    var babyBirthDate: Date? { appState.babyProfile?.birthDate }

    var babyBirthDateInterval: Double {
        appState.babyProfile?.birthDate.timeIntervalSince1970 ?? 0
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

    init(repo: any DiaryRepository,
         photoStorage: any PhotoStorageService,
         analytics: any AnalyticsServiceProtocol = LogAnalyticsService(),
         appState: AppState) {
        self.repo = repo
        self.photoStorage = photoStorage
        self.analytics = analytics
        self.appState = appState
        Task {
            await loadEntries()
            await migrateLocalPhotosToFirebase()
        }
    }

    func loadEntries() async {
        let yearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? .distantPast
        let stored = (try? await repo.getEntries(from: yearAgo, to: Date())) ?? []

        var loaded: [UUID: UIImage] = [:]
        for item in stored where item.kind == .photo {
            if let path = item.photoPath, let img = await photoStorage.load(atPath: path) {
                loaded[item.id] = img
            }
        }

        entries = group(stored.sorted { $0.date > $1.date })
        photosByID.merge(loaded) { _, new in new }
    }

    // MARK: - Migration

    private func migrateLocalPhotosToFirebase() async {
        let yearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? .distantPast
        let stored = (try? await repo.getEntries(from: yearAgo, to: Date())) ?? []
        let localItems = stored.filter { $0.kind == .photo && ($0.photoPath?.hasPrefix("/") == true) }
        guard !localItems.isEmpty else { return }

        for item in localItems {
            guard let localPath = item.photoPath,
                  let image = UIImage(contentsOfFile: localPath) else { continue }
            do {
                let firebasePath = try await photoStorage.save(image, forID: item.id)
                var updated = item
                updated.photoPath = firebasePath
                try await repo.update(updated)
                try? FileManager.default.removeItem(atPath: localPath)
            } catch {
                // Leave local file intact if upload fails; will retry next launch
            }
        }

        await loadEntries()
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
        let entryTypes = newDay.items.map { item -> String in
            switch item.type {
            case .note: return "note"
            case .milestone: return "milestone"
            case .photo: return "photo"
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
            photosByID.merge(photos) { _, new in new }
        }
        Task {
            for item in newDay.items {
                var stored = toStored(item, date: date)
                if stored.kind == .photo, let img = photos[item.id] {
                    do {
                        for try await event in photoStorage.saveWithProgress(img, forID: item.id) {
                            switch event {
                            case .progress(let fraction):
                                uploadProgress[item.id] = fraction
                            case .completed(let path):
                                stored.photoPath = path
                                uploadProgress.removeValue(forKey: item.id)
                            }
                        }
                    } catch {
                        uploadProgress.removeValue(forKey: item.id)
                        saveError = error.localizedDescription
                    }
                }
                do { try await repo.add(stored) }
                catch { saveError = error.localizedDescription }
            }
            await loadEntries()
        }
    }
}
