import SwiftUI
import Combine

@MainActor
final class FoodDiaryViewModel: ObservableObject {
    @Published private(set) var entries: [ComplementaryFoodEntry] = []
    @Published private(set) var photosByID: [UUID: UIImage] = [:]
    @Published var isUploading = false
    @Published var saveError: String? = nil
    @Published var showAddEntry = false

    // Add-entry form state
    @Published var newFoodName = ""
    @Published var newCategory: FoodCategory = .vegetable
    @Published var newReaction: FoodReaction = .none
    @Published var newIsAllergen = false
    @Published var newNotes = ""
    @Published var pendingPhoto: UIImage? = nil

    private let add: AddFoodEntryUseCase
    private let get: GetFoodEntriesUseCase
    private let delete: DeleteFoodEntryUseCase
    private let photoStorage: any PhotoStorageService

    init(add: AddFoodEntryUseCase,
         get: GetFoodEntriesUseCase,
         delete: DeleteFoodEntryUseCase,
         photoStorage: any PhotoStorageService) {
        self.add = add
        self.get = get
        self.delete = delete
        self.photoStorage = photoStorage
    }

    var allergens: [ComplementaryFoodEntry] { entries.filter(\.isAllergen) }

    var grouped: [(date: Date, items: [ComplementaryFoodEntry])] {
        let dict = Dictionary(grouping: entries) {
            Calendar.current.startOfDay(for: $0.date)
        }
        return dict.keys.sorted(by: >).map {
            (date: $0, items: dict[$0]!.sorted { $0.date > $1.date })
        }
    }

    func load() async {
        entries = (try? await get.execute()) ?? []
        await loadPhotos()
    }

    func saveEntry() async {
        let name = newFoodName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        isUploading = true
        defer { isUploading = false }
        var photoPath: String? = nil
        if let img = pendingPhoto {
            photoPath = try? await photoStorage.save(img, forID: UUID())
        }
        do {
            try await add.execute(
                name: name, category: newCategory, reaction: newReaction,
                isAllergen: newIsAllergen, notes: newNotes, photoPath: photoPath
            )
            resetForm()
            showAddEntry = false
            await load()
        } catch {
            saveError = error.localizedDescription
        }
    }

    func deleteEntry(_ entry: ComplementaryFoodEntry) async {
        if let path = entry.photoPath {
            try? await photoStorage.delete(atPath: path)
        }
        await delete.execute(id: entry.id)
        photosByID.removeValue(forKey: entry.id)
        await load()
    }

    private func loadPhotos() async {
        for entry in entries {
            guard let path = entry.photoPath, photosByID[entry.id] == nil else { continue }
            if let img = await photoStorage.load(atPath: path) {
                photosByID[entry.id] = img
            }
        }
    }

    private func resetForm() {
        newFoodName = ""
        newCategory = .vegetable
        newReaction = .none
        newIsAllergen = false
        newNotes = ""
        pendingPhoto = nil
    }
}
