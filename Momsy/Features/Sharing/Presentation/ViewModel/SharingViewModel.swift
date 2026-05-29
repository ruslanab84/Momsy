import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class SharingViewModel: ObservableObject {
    @Published var members: [FamilyMember] = []
    @Published var showInvite = false
    @Published var editingMember: FamilyMember? = nil
    @Published var saveError: String?
    @Published var joinCode = ""
    @Published var isJoining = false
    @Published var joinError: String?
    @Published var joinSuccess = false

    private let repo: any FamilyRepository
    private let inviteService: any InviteServiceProtocol
    private let appState: AppState
    // Preserves full StoredFamilyMember (including uid) across round-trips
    private var storedMembers: [StoredFamilyMember] = []

    private var lm: LocalizationManager { .shared }

    var displayName: String { appState.displayName }

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
        storedMembers = stored
        members = stored.map { $0.toFamilyMember() }
        // Ensure any pending invite-code Firestore write completes before user can share
        await (inviteService as? FirestoreInviteService)?.awaitSync()
    }

    func addMember(_ member: FamilyMember) {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
            members.append(member)
        }
        let stored = member.toStored()
        storedMembers.append(stored)
        Task {
            do { try await repo.add(stored) }
            catch { saveError = error.localizedDescription }
        }
    }

    func changeRole(id: UUID, to newRole: FamilyRole) {
        guard
            let idx = members.firstIndex(where: { $0.id == id }),
            let storedIdx = storedMembers.firstIndex(where: { $0.id == id })
        else { return }
        withAnimation { members[idx].role = newRole }
        // Update the stored member in-place so uid and other fields are preserved
        var updated = storedMembers[storedIdx]
        updated.roleRaw = newRole.rawValue
        storedMembers[storedIdx] = updated
        Task {
            do { try await repo.update(updated) }
            catch { saveError = error.localizedDescription }
        }
    }

    func removeMember(id: UUID) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            members.removeAll { $0.id == id }
        }
        storedMembers.removeAll { $0.id == id }
        Task {
            do { try await repo.remove(id: id) }
            catch { saveError = error.localizedDescription }
        }
    }

    func joinFamily() {
        guard !joinCode.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            joinError = "Please sign in first."
            return
        }
        isJoining = true
        joinError = nil
        Task {
            do {
                try await FamilyManager.shared.joinFamily(code: joinCode, uid: uid)
                joinCode = ""
                joinSuccess = true
                await loadMembers()
            } catch {
                joinError = error.localizedDescription
            }
            isJoining = false
            // Auto-dismiss success banner after 3 seconds
            if joinSuccess {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                joinSuccess = false
            }
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
