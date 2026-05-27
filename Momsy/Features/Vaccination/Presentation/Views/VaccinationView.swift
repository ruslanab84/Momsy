import SwiftUI

struct VaccinationView: View {
    @StateObject private var vm: VaccinationViewModel
    @EnvironmentObject private var lm: LocalizationManager

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeVaccinationViewModel())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12, pinnedViews: .sectionHeaders) {
                ForEach(vm.grouped, id: \.ageMonths) { group in
                    Section {
                        VStack(spacing: 0) {
                            ForEach(Array(group.items.enumerated()), id: \.element.id) { idx, status in
                                VaccinationRowView(status: status, lm: lm) {
                                    vm.doneDate = status.entry?.doneDate ?? Date()
                                    vm.showMarkDone = status
                                } onUnmark: {
                                    Task { await vm.undone(status) }
                                }
                                if idx < group.items.count - 1 {
                                    Divider().padding(.leading, 52)
                                }
                            }
                        }
                        .background(Color.bbCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
                    } header: {
                        Text(group.label.uppercased())
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
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.strings.vaccinations)
        .task { await vm.load() }
        .sheet(item: $vm.showMarkDone) { status in
            MarkDoneSheet(vm: vm, status: status, lm: lm)
        }
    }
}

private struct VaccinationRowView: View {
    let status: VaccinationStatus
    let lm: LocalizationManager
    let onTap: () -> Void
    let onUnmark: () -> Void

    private var statusColor: Color {
        if status.isDone    { return .bbMintDeep }
        if status.isOverdue { return .bbCoralDeep }
        return .bbSkyDeep
    }

    private var statusIcon: String {
        if status.isDone    { return "checkmark.circle.fill" }
        if status.isOverdue { return "exclamationmark.circle.fill" }
        return "clock.fill"
    }

    private var name: String {
        switch lm.current {
        case .english: return status.item.nameEN
        case .german:  return status.item.nameDE
        case .russian: return status.item.nameRU
        }
    }

    var body: some View {
        Button(action: { if !status.isDone { onTap() } }) {
            HStack(spacing: 12) {
                Image(systemName: statusIcon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(statusColor)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInk)
                    if status.isDone, let doneDate = status.entry?.doneDate {
                        Text(doneDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.bbMintDeep)
                    } else {
                        Text(status.dueDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(status.isOverdue ? .bbCoralDeep : .bbInkSoft)
                    }
                }
                Spacer()
                if !status.isDone {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.bbInkMute)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if status.isDone {
                Button(role: .destructive, action: onUnmark) {
                    Label(lm.strings.vaccinationUndo, systemImage: "arrow.uturn.backward")
                }
                .tint(.bbCoralDeep)
            }
        }
    }
}

private struct MarkDoneSheet: View {
    @ObservedObject var vm: VaccinationViewModel
    let status: VaccinationStatus
    let lm: LocalizationManager

    private var name: String {
        switch lm.current {
        case .english: return status.item.nameEN
        case .german:  return status.item.nameDE
        case .russian: return status.item.nameRU
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "syringe")
                        .font(.system(size: 44))
                        .foregroundColor(.bbLilacDeep)
                    Text(name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInk)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 24)

                DatePicker(
                    lm.strings.vaccinationMarkDone,
                    selection: $vm.doneDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .accentColor(.bbLilacDeep)
                .padding(.horizontal, 16)

                Button {
                    Task { await vm.confirmDone(status) }
                } label: {
                    Text(lm.strings.vaccinationMarkDone)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.bbLilacDeep)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .navigationTitle(lm.strings.vaccinationCalendar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lm.strings.cancel) { vm.showMarkDone = nil }
                }
            }
        }
    }
}
