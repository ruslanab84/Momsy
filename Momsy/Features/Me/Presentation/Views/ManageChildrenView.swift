import SwiftUI

/// Phase-1 multi-child management: list the roster, switch the active child, add up
/// to `ActiveBaby.maxChildren`, and delete. Intentionally minimal — the polished
/// top-bar switcher is Phase 2. Strings are inline (ru/en) pending full localization.
struct ManageChildrenView: View {
    @EnvironmentObject private var lm: LocalizationManager
    @EnvironmentObject private var appState: AppState
    @Environment(\.appContainer) private var container

    @State private var showAdd = false
    @State private var busy = false
    @State private var errorMessage: String?

    private var ru: Bool { lm.lang == "ru" }

    var body: some View {
        List {
            Section {
                ForEach(appState.babies) { baby in
                    row(for: baby)
                }
                .onDelete { offsets in
                    if appState.babies.count > 1 { delete(at: offsets) }
                }
            } footer: {
                Text(ru ? "До \(ActiveBaby.maxChildren) детей." : "Up to \(ActiveBaby.maxChildren) children.")
            }
        }
        .navigationTitle(ru ? "Дети" : "Children")
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
        .alert(ru ? "Не удалось" : "Couldn’t complete",
               isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private func row(for baby: BabyProfile) -> some View {
        Button {
            guard baby.id != appState.activeBabyId, !busy else { return }
            Task { busy = true; await container.switchActiveBaby(to: baby.id); busy = false }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(baby.name.isEmpty ? (ru ? "Малыш" : "Baby") : baby.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(baby.birthDate, style: .date)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                }
                Spacer()
                if baby.id == appState.activeBabyId {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.bbCoralDeep)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func delete(at offsets: IndexSet) {
        let targets = offsets.map { appState.babies[$0].id }
        Task {
            busy = true
            for id in targets {
                do { try await container.deleteChild(id: id) }
                catch { errorMessage = error.localizedDescription }
            }
            busy = false
        }
    }

    private func add(_ profile: BabyProfile) async {
        busy = true
        do { try await container.addChild(profile) }
        catch { errorMessage = error.localizedDescription }
        busy = false
    }
}
