import SwiftUI

struct CareTipsView: View {
    @StateObject private var vm: CareTipsViewModel
    @EnvironmentObject private var lm: LocalizationManager

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeCareTipsViewModel())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12, pinnedViews: .sectionHeaders) {
                filterBar
                    .padding(.bottom, 2)

                if vm.isEmpty {
                    emptyState
                } else {
                    ForEach(vm.sections, id: \.category) { section in
                        Section {
                            VStack(spacing: 0) {
                                ForEach(Array(section.tips.enumerated()), id: \.element.id) { idx, tip in
                                    NavigationLink(destination: CareTipDetailView(tip: tip)) {
                                        CareTipRowView(tip: tip, lang: lm.current)
                                    }
                                    .buttonStyle(.plain)

                                    if idx < section.tips.count - 1 {
                                        Divider().padding(.leading, 60)
                                    }
                                }
                            }
                            .background(Color.bbCard)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
                        } header: {
                            Text(section.category.title(lm.current).uppercased())
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundColor(.bbInkSoft)
                                .kerning(0.5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 4)
                                .background(Color.bbCream)
                        }
                    }
                }

                disclaimerFooter
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.strings.careTipsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $vm.searchText, prompt: lm.strings.careTipsSearchPrompt)
    }

    // MARK: - Filters

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                if vm.canFilterByAge {
                    chip(
                        title: lm.strings.careTipsFilterMyBaby,
                        isSelected: vm.isAgeFilterOn
                    ) {
                        withAnimation(.spring(response: 0.3)) { vm.isAgeFilterOn.toggle() }
                    }
                }

                chip(
                    title: lm.strings.careTipsFilterAll,
                    isSelected: vm.selectedCategory == nil
                ) {
                    withAnimation(.spring(response: 0.3)) { vm.selectedCategory = nil }
                }

                ForEach(CareTipCategory.allCases) { category in
                    chip(
                        title: category.title(lm.current),
                        isSelected: vm.selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) { vm.toggleCategory(category) }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .white : .bbInkSoft)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.bbSurface : Color.bbCard)
                .clipShape(Capsule())
                .bbShadowSoft()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty & footer

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(.bbInkMute)
            Text(lm.strings.careTipsEmpty)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private var disclaimerFooter: some View {
        Text(lm.strings.careTipsDisclaimer)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.bbInkMute)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
    }
}

// MARK: - Row

private struct CareTipRowView: View {
    let tip: CareTip
    let lang: Language

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tip.category.semanticColor.color.opacity(0.28))
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: tip.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.bbInk)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(tip.title(lang))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInk)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(tip.summary(lang))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.bbInkMute)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
