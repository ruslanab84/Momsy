import SwiftUI
import Combine

@MainActor
final class FoodDiaryViewModel: ObservableObject {
    @Published private(set) var entries: [ComplementaryFoodEntry] = []
    @Published var isUploading = false
    @Published var saveError: String? = nil
    @Published var showAddEntry = false

    // Add-entry form state
    @Published var newFoodName = ""
    @Published var newCategory: FoodCategory = .vegetable
    @Published var newReaction: FoodReaction = .none
    @Published var newIsAllergen = false
    @Published var newNotes = ""

    private let add: AddFoodEntryUseCase
    private let get: GetFoodEntriesUseCase
    private let delete: DeleteFoodEntryUseCase
    private let syncRepo: any BabySyncRepositoryProtocol

    init(add: AddFoodEntryUseCase,
         get: GetFoodEntriesUseCase,
         delete: DeleteFoodEntryUseCase,
         syncRepo: any BabySyncRepositoryProtocol) {
        self.add = add
        self.get = get
        self.delete = delete
        self.syncRepo = syncRepo
    }

    var allergens: [ComplementaryFoodEntry] { entries.filter(\.isAllergen) }

    var grouped: [(date: Date, items: [ComplementaryFoodEntry])] {
        let dict = Dictionary(grouping: entries) {
            Calendar.current.startOfDay(for: $0.date)
        }
        return dict.sorted { $0.key > $1.key }.map { date, items in
            (date: date, items: items.sorted { $0.date > $1.date })
        }
    }

    func load() async {
        entries = (try? await get.execute()) ?? []
    }

    func saveEntry() async {
        let name = newFoodName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        isUploading = true
        defer { isUploading = false }
        do {
            let entry = try await add.execute(
                name: name, category: newCategory, reaction: newReaction,
                isAllergen: newIsAllergen, notes: newNotes
            )
            pushFoodEntryToFirestore(entry)
            resetForm()
            showAddEntry = false
            await load()
        } catch {
            saveError = error.localizedDescription
        }
    }

    func deleteEntry(_ entry: ComplementaryFoodEntry) async {
        await delete.execute(id: entry.id)
        BabySyncService().propagateDelete(id: entry.id, in: "foodDiaryLogs")
        await load()
    }

    private func pushFoodEntryToFirestore(_ entry: ComplementaryFoodEntry) {
        guard FamilyManager.shared.familyId != nil else { return }
        let log = FoodDiaryLog(
            id: entry.id.uuidString,
            date: entry.date,
            foodName: entry.foodName,
            category: entry.category.rawValue,
            reaction: entry.reaction.rawValue,
            isAllergen: entry.isAllergen,
            notes: entry.notes,
            addedBy: "",
            addedByName: ""
        )
        Task { try? await syncRepo.addFoodDiaryLog(log) }
    }

    private func resetForm() {
        newFoodName = ""
        newCategory = .vegetable
        newReaction = .none
        newIsAllergen = false
        newNotes = ""
    }
}
