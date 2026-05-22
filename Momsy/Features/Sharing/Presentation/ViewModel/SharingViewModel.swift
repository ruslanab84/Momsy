import SwiftUI
import Combine

@MainActor
final class SharingViewModel: ObservableObject {
    @Published var members: [FamilyMember] = []
    @Published var showInvite = false
    @Published var editingMember: FamilyMember? = nil
    @Published var saveError: String?

    private let repo: any FamilyRepository
    private let inviteService: any InviteServiceProtocol
    private let appState: AppState

    private var lm: LocalizationManager { .shared }

    var displayName: String {
        let name = appState.babyProfile?.name ?? ""
        return name.isEmpty ? lm.strings.baby : name
    }

    var inviteCode: String { inviteService.currentCode() }
    var inviteURL:  String { inviteService.inviteURL(for: inviteCode) }
    var inviteExpiry: Date { inviteService.expiry() }

    func regenerateInvite() {
        inviteService.regenerate()
        objectWillChange.send()
    }

    init(repo: any FamilyRepository, inviteService: any InviteServiceProtocol = LocalInviteService(), appState: AppState) {
        self.repo = repo
        self.inviteService = inviteService
        self.appState = appState
        Task { await loadMembers() }
    }

    func loadMembers() async {
        let stored = (try? await repo.getMembers()) ?? []
        members = stored.map { $0.toFamilyMember() }
    }

    func addMember(_ member: FamilyMember) {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
            members.append(member)
        }
        Task {
            do { try await repo.add(member.toStored()) }
            catch { saveError = error.localizedDescription }
        }
    }

    func changeRole(id: UUID, to newRole: FamilyRole) {
        guard let idx = members.firstIndex(where: { $0.id == id }) else { return }
        withAnimation { members[idx].role = newRole }
        let stored = members[idx].toStored()
        Task {
            do { try await repo.update(stored) }
            catch { saveError = error.localizedDescription }
        }
    }

    func removeMember(id: UUID) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            members.removeAll { $0.id == id }
        }
        Task {
            do { try await repo.remove(id: id) }
            catch { saveError = error.localizedDescription }
        }
    }
}

// MARK: - Mapping

private extension StoredFamilyMember {
    func toFamilyMember() -> FamilyMember {
        let role = FamilyRole(rawValue: roleRaw) ?? .mom
        return FamilyMember(
            id: id, name: name, role: role, isMe: isMe,
            isOnline: false, activity: "", blob: role.defaultBlob, tone: role.defaultTone
        )
    }
}

private extension FamilyMember {
    func toStored() -> StoredFamilyMember {
        StoredFamilyMember(id: id, name: name, roleRaw: role.rawValue, isMe: isMe)
    }
}
