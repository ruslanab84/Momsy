import SwiftUI
import PhotosUI

struct FoodDiaryView: View {
    @StateObject private var vm: FoodDiaryViewModel
    @EnvironmentObject private var lm: LocalizationManager

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeFoodDiaryViewModel())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if !vm.allergens.isEmpty {
                    AllergenCard(allergens: vm.allergens, lm: lm)
                }

                if vm.entries.isEmpty {
                    FoodDiaryEmptyState(lm: lm)
                } else {
                    ForEach(vm.grouped, id: \.date) { group in
                        FoodGroupSection(group: group, vm: vm, lm: lm)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.strings.foodDiary)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    vm.showAddEntry = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.bbCoralDeep)
                }
            }
        }
        .sheet(isPresented: $vm.showAddEntry) {
            AddFoodEntrySheet(vm: vm, lm: lm)
        }
        .task { await vm.load() }
    }
}

// MARK: - Allergen card

private struct AllergenCard: View {
    let allergens: [ComplementaryFoodEntry]
    let lm: LocalizationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(lm.strings.foodAllergens.uppercased())
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .kerning(0.5)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(allergens) { entry in
                        Text(entry.foodName)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(Color.bbCoralDeep)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.bbCoralDeep.opacity(0.35), radius: 10, y: 4)
    }
}

// MARK: - Group section

private struct FoodGroupSection: View {
    let group: (date: Date, items: [ComplementaryFoodEntry])
    let vm: FoodDiaryViewModel
    let lm: LocalizationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(group.date.formatted(.dateTime.day().month(.wide).year()))
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .kerning(0.3)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(Array(group.items.enumerated()), id: \.element.id) { idx, entry in
                    FoodEntryRow(entry: entry, photo: vm.photosByID[entry.id], lm: lm) {
                        Task { await vm.deleteEntry(entry) }
                    }
                    if idx < group.items.count - 1 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
        }
    }
}

// MARK: - Entry row

private struct FoodEntryRow: View {
    let entry: ComplementaryFoodEntry
    let photo: UIImage?
    let lm: LocalizationManager
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Photo or category icon
            if let img = photo {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(entry.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: entry.category.iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(entry.category.color)
                    )
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(entry.foodName)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInk)
                    if entry.isAllergen {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.bbCoralDeep)
                    }
                }
                HStack(spacing: 6) {
                    Text(entry.category.localizedName(lm: lm))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                    if entry.reaction != .none {
                        ReactionBadge(reaction: entry.reaction, lm: lm)
                    }
                }
            }

            Spacer()

            Text(entry.date.formatted(.dateTime.hour().minute()))
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkMute)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label(lm.strings.delete, systemImage: "trash")
            }
        }
    }
}

// MARK: - Reaction badge

private struct ReactionBadge: View {
    let reaction: FoodReaction
    let lm: LocalizationManager

    private var label: String {
        switch reaction {
        case .none:   return lm.strings.foodReactionNone
        case .mild:   return lm.strings.foodReactionMild
        case .severe: return lm.strings.foodReactionSevere
        }
    }

    private var color: Color {
        switch reaction {
        case .none:   return .bbInkMute
        case .mild:   return .bbButter
        case .severe: return .bbCoralDeep
        }
    }

    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(reaction == .mild ? .bbInk : .white)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(color)
            .clipShape(Capsule())
    }
}

// MARK: - Empty state

private struct FoodDiaryEmptyState: View {
    let lm: LocalizationManager

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 56, weight: .light))
                .foregroundColor(.bbCoralDeep.opacity(0.4))
            Text(lm.strings.foodStartHint)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, 40)
    }
}

// MARK: - Add Food Entry Sheet

private struct AddFoodEntrySheet: View {
    @ObservedObject var vm: FoodDiaryViewModel
    let lm: LocalizationManager

    @State private var photoItem: PhotosPickerItem? = nil
    @State private var isLoadingPhoto = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // Food name
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(lm.strings.foodName)
                        TextField(lm.strings.foodName, text: $vm.newFoodName)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .padding(14)
                            .background(Color.bbCard)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // Category picker
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(lm.strings.foodCategory)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(FoodCategory.allCases, id: \.self) { cat in
                                    Button {
                                        vm.newCategory = cat
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: cat.iconName)
                                                .font(.system(size: 13, weight: .semibold))
                                            Text(cat.localizedName(lm: lm))
                                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(vm.newCategory == cat ? .white : cat.color)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(vm.newCategory == cat ? cat.color : cat.color.opacity(0.12))
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }

                    // Reaction picker
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(lm.strings.foodReaction)
                        HStack(spacing: 8) {
                            ForEach(FoodReaction.allCases, id: \.self) { r in
                                Button {
                                    vm.newReaction = r
                                } label: {
                                    Text(r.localizedName(lm: lm))
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(vm.newReaction == r ? .white : r.color)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(vm.newReaction == r ? r.color : r.color.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Allergen toggle
                    Toggle(isOn: $vm.newIsAllergen) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.bbCoralDeep)
                            Text(lm.strings.foodAllergen)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.bbInk)
                        }
                    }
                    .padding(14)
                    .background(Color.bbCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .tint(.bbCoralDeep)

                    // Notes (optional)
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("\(lm.strings.notes) (\(lm.strings.optional))")
                        TextField(lm.strings.notes, text: $vm.newNotes)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .padding(14)
                            .background(Color.bbCard)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // Photo picker
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("\(lm.strings.photo) (\(lm.strings.optional))")
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            ZStack {
                                if let img = vm.pendingPhoto {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 140)
                                        .clipped()
                                } else {
                                    Color.bbCoral.opacity(0.12)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 140)
                                        .overlay(
                                            VStack(spacing: 8) {
                                                if isLoadingPhoto {
                                                    ProgressView().tint(.bbCoralDeep)
                                                } else {
                                                    Image(systemName: "camera.fill")
                                                        .font(.system(size: 28, weight: .light))
                                                        .foregroundColor(.bbCoralDeep.opacity(0.7))
                                                    Text(lm.strings.tapToChoose)
                                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                        .foregroundColor(.bbCoralDeep.opacity(0.7))
                                                }
                                            }
                                        )
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .onChange(of: photoItem) { _, new in
                            guard let new else { return }
                            isLoadingPhoto = true
                            Task {
                                if let data = try? await new.loadTransferable(type: Data.self),
                                   let img = UIImage(data: data) {
                                    vm.pendingPhoto = img
                                }
                                isLoadingPhoto = false
                            }
                        }
                    }

                    // Save button
                    Button {
                        Task { await vm.saveEntry() }
                    } label: {
                        ZStack {
                            if vm.isUploading {
                                ProgressView().tint(.white)
                            } else {
                                Text(lm.strings.save)
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(vm.newFoodName.trimmingCharacters(in: .whitespaces).isEmpty || vm.isUploading
                                    ? Color.bbInkMute.opacity(0.4)
                                    : Color.bbCoralDeep)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .disabled(vm.newFoodName.trimmingCharacters(in: .whitespaces).isEmpty || vm.isUploading)
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .background(Color.bbCream.ignoresSafeArea())
            .navigationTitle(lm.strings.addFood)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lm.strings.cancel) { vm.showAddEntry = false }
                        .foregroundColor(.bbInkSoft)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .foregroundColor(.bbInkMute)
            .kerning(0.5)
    }
}

// MARK: - FoodCategory helpers

extension FoodCategory {
    var iconName: String {
        switch self {
        case .vegetable: return "leaf.fill"
        case .fruit:     return "circle.fill"
        case .cereal:    return "square.fill"
        case .meat:      return "flame.fill"
        case .dairy:     return "drop.fill"
        case .fish:      return "waveform"
        case .egg:       return "oval.fill"
        case .other:     return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .vegetable: return .bbMintDeep
        case .fruit:     return .bbCoral
        case .cereal:    return .bbButter
        case .meat:      return .bbCoralDeep
        case .dairy:     return .bbSkyDeep
        case .fish:      return .bbSky
        case .egg:       return .bbButterDeep
        case .other:     return .bbInkSoft
        }
    }

    func localizedName(lm: LocalizationManager) -> String {
        switch self {
        case .vegetable: return lm.strings.foodCatVegetable
        case .fruit:     return lm.strings.foodCatFruit
        case .cereal:    return lm.strings.foodCatCereal
        case .meat:      return lm.strings.foodCatMeat
        case .dairy:     return lm.strings.foodCatDairy
        case .fish:      return lm.strings.foodCatFish
        case .egg:       return lm.strings.foodCatEgg
        case .other:     return lm.strings.foodCatOther
        }
    }
}

// MARK: - FoodReaction helpers

extension FoodReaction {
    var color: Color {
        switch self {
        case .none:   return .bbInkSoft
        case .mild:   return .bbButter
        case .severe: return .bbCoralDeep
        }
    }

    func localizedName(lm: LocalizationManager) -> String {
        switch self {
        case .none:   return lm.strings.foodReactionNone
        case .mild:   return lm.strings.foodReactionMild
        case .severe: return lm.strings.foodReactionSevere
        }
    }
}
