import SwiftUI

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
                                uploadProgress: vm.uploadProgress,
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
        .errorToast($vm.saveError)
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

#Preview {
    DiaryView(container: AppContainer())
        .environmentObject(LocalizationManager.shared)
}
