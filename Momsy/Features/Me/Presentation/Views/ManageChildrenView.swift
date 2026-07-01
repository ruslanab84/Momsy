import SwiftUI

struct ManageChildrenView: View {
    @EnvironmentObject private var lm: LocalizationManager
    @EnvironmentObject private var appState: AppState
    @Environment(\.appContainer) private var container

    @State private var showAdd = false
    @State private var busy = false
    @State private var errorMessage: String?
    @State private var pendingDeletion: BabyProfile?

    private var canDeleteChildren: Bool { appState.babies.count > 1 && !busy }

    var body: some View {
        List {
            Section {
                ForEach(appState.babies) { baby in
                    row(for: baby)
                }
            } footer: {
                Text(lm.strings.maxChildrenHint(ActiveBaby.maxChildren))
            }
        }
        .navigationTitle(lm.strings.children)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAdd = true } label: { Image(systemName: "plus") }
                    .disabled(appState.babies.count >= ActiveBaby.maxChildren || busy)
            }
        }
        .sheet(isPresented: $showAdd) {
            AddChildSheet { profile in
                Task { await add(profile) }
            }
            .environmentObject(lm)
        }
        .confirmationDialog(
            lm.strings.deleteChildTitle(displayName(for: pendingDeletion)),
            isPresented: Binding(
                get: { pendingDeletion != nil },
                set: { if !$0 { pendingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            if let pendingDeletion {
                Button(lm.strings.delete, role: .destructive) {
                    Task { await delete(pendingDeletion) }
                }
            }
            Button(lm.strings.cancel, role: .cancel) {
                pendingDeletion = nil
            }
        } message: {
            Text(lm.strings.deleteChildMessage(displayName(for: pendingDeletion)))
        }
        .alert(lm.strings.couldntComplete,
               isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private func row(for baby: BabyProfile) -> some View {
        HStack(spacing: 12) {
            Button {
                guard baby.id != appState.activeBabyId, !busy else { return }
                Task {
                    busy = true
                    await container.switchActiveBaby(to: baby.id)
                    busy = false
                }
            } label: {
                HStack {
                    childSummary(for: baby)
                    Spacer()
                    if baby.id == appState.activeBabyId {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.bbCoralDeep)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(busy)

            Button(role: .destructive) {
                requestDelete(baby)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(canDeleteChildren ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.55))
                    .frame(width: 36, height: 36)
                    .background(canDeleteChildren ? Color.bbCoral.opacity(0.14) : Color.bbInkMute.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(!canDeleteChildren)
            .accessibilityLabel(lm.strings.deleteChildTitle(displayName(for: baby)))
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                requestDelete(baby)
            } label: {
                Label(lm.strings.delete, systemImage: "trash")
            }
            .disabled(!canDeleteChildren)
        }
    }

    private func childSummary(for baby: BabyProfile) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(displayName(for: baby))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInk)
            Text(baby.birthDate, style: .date)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
    }

    private func displayName(for baby: BabyProfile?) -> String {
        guard let baby else { return lm.strings.baby }
        let name = baby.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? lm.strings.baby : name
    }

    private func requestDelete(_ baby: BabyProfile) {
        guard canDeleteChildren else {
            errorMessage = lm.strings.cannotDeleteLastChild
            return
        }
        pendingDeletion = baby
    }

    private func delete(_ baby: BabyProfile) async {
        pendingDeletion = nil
        busy = true
        defer { busy = false }
        do {
            try await container.deleteChild(id: baby.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func add(_ profile: BabyProfile) async {
        busy = true
        do { try await container.addChild(profile) }
        catch { errorMessage = error.localizedDescription }
        busy = false
    }
}
