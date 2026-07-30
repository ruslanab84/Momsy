import SwiftUI
import Combine

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
    @Published var showJoinConfirm = false
    @Published var isPreparingInvite = false
    @Published var showJoinAuthSheet = false
    @Published private(set) var inviteRole: FamilyRole

    private let repo: any FamilyRepository
    private let inviteService: any InviteServiceProtocol
    private let appState: AppState
    private let auth: any JoinAuthProviding
    // Preserves full StoredFamilyMember (including uid) across round-trips
    private var storedMembers: [StoredFamilyMember] = []
    private var pendingJoinAfterAuth = false
    private var pendingJoinForceAfterAuth = false

    private var lm: LocalizationManager { .shared }

    var displayName: String { appState.displayName }
    var canManageMembers: Bool {
        members.first(where: { $0.isMe })?.role.canManageFamilyMembers ?? false
    }

    var inviteCode: String { inviteService.currentCode() }
    var inviteURL:  String { inviteService.inviteURL(for: inviteCode) }
    var inviteExpiry: Date { inviteService.expiry() }

    func presentInvite() {
        guard canManageMembers else { return }
        guard !isPreparingInvite else { return }
        isPreparingInvite = true
        saveError = nil
        Task {
            do {
                _ = try await inviteService.prepareInvite(defaultRole: inviteRole)
                inviteRole = inviteService.currentRole()
                showInvite = true
            } catch {
                saveError = error.localizedDescription
                showInvite = false
            }
            isPreparingInvite = false
        }
    }

    func updateInviteRole(_ role: FamilyRole) {
        guard role != inviteRole else { return }
        regenerateInvite(role: role)
    }

    func regenerateInvite(role: FamilyRole) {
        guard canManageMembers else { return }
        guard !isPreparingInvite else { return }
        isPreparingInvite = true
        saveError = nil
        Task {
            do {
                _ = try await inviteService.issueInvite(role: role)
                inviteRole = role
                objectWillChange.send()
            } catch {
                saveError = error.localizedDescription
                showInvite = false
            }
            isPreparingInvite = false
        }
    }

    init(repo: any FamilyRepository, inviteService: any InviteServiceProtocol, appState: AppState, auth: any JoinAuthProviding) {
        self.repo = repo
        self.inviteService = inviteService
        self.appState = appState
        self.auth = auth
        self.inviteRole = inviteService.currentRole()
        Task { await loadMembers() }
    }

    func loadMembers() async {
        var stored = (try? await repo.getMembers()) ?? []
        if let currentMember = currentManagingMember(in: stored) {
            try? await repo.prepareForRosterManagement(currentMember: currentMember)
            stored = (try? await repo.getMembers()) ?? stored
        }
        stored = stored.filter { FamilyRole(storedRawValue: $0.roleRaw) != nil }
        storedMembers = stored
        members = stored.compactMap { $0.toFamilyMember() }
    }

    func changeRole(id: UUID, to newRole: FamilyRole) {
        guard canManageMembers else { return }
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
        guard canManageMembers else { return }
        guard
            let idx = members.firstIndex(where: { $0.id == id }),
            let storedIdx = storedMembers.firstIndex(where: { $0.id == id })
        else { return }
        let removedMember = members[idx]
        let removedStoredMember = storedMembers[storedIdx]
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            _ = members.remove(at: idx)
        }
        storedMembers.remove(at: storedIdx)
        Task {
            do {
                if let currentMember = currentManagingMember(in: storedMembers) {
                    try await repo.prepareForRosterManagement(currentMember: currentMember)
                }
                try await repo.remove(removedStoredMember)
            } catch {
                members.insert(removedMember, at: min(idx, members.count))
                storedMembers.insert(removedStoredMember, at: min(storedIdx, storedMembers.count))
                saveError = error.localizedDescription
            }
        }
    }

    func joinFamily(force: Bool = false) {
        guard !joinCode.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard !isJoining else { return }
        isJoining = true
        joinError = nil
        Task {
            FamilyManager.shared.beginJoinFlow()
            defer { FamilyManager.shared.endJoinFlow() }
            do {
                // Self-heal a missing session like the deep-link join path does,
                // instead of dead-ending the user at an auth wall.
                try await auth.requireAnonymousSignInIfNeeded()
            } catch AuthError.anonymousSignInRestricted {
                pendingJoinAfterAuth = true
                pendingJoinForceAfterAuth = force
                joinError = lm.strings.joinAuthSubtitle
                showJoinAuthSheet = true
                isJoining = false
                return
            } catch {
                joinError = lm.strings.joinAuthUnavailable
                isJoining = false
                return
            }
            guard let uid = auth.currentUID else {
                joinError = lm.strings.joinAuthUnavailable
                isJoining = false
                return
            }
            do {
                try await FamilyManager.shared.joinFamily(code: joinCode, uid: uid, force: force)
                joinCode = ""
                joinSuccess = true
                await loadMembers()
            } catch FamilyError.wouldAbandonExistingFamily {
                showJoinConfirm = true   // UI confirms, then calls confirmJoinReplacingFamily()
            } catch {
                joinError = error.localizedDescription
            }
            isJoining = false
            if joinSuccess {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                joinSuccess = false
            }
        }
    }

    func retryPendingJoinAfterAuthIfNeeded() {
        guard pendingJoinAfterAuth, auth.currentUID != nil else { return }
        let force = pendingJoinForceAfterAuth
        pendingJoinAfterAuth = false
        pendingJoinForceAfterAuth = false
        showJoinAuthSheet = false
        joinFamily(force: force)
    }

    func confirmJoinReplacingFamily() {
        showJoinConfirm = false
        joinFamily(force: true)
    }

    private func currentManagingMember(in stored: [StoredFamilyMember]) -> StoredFamilyMember? {
        stored.first {
            $0.isMe && (FamilyRole(storedRawValue: $0.roleRaw)?.canManageFamilyMembers ?? false)
        }
    }
}

// MARK: - Mapping

private extension StoredFamilyMember {
    func toFamilyMember() -> FamilyMember? {
        guard let role = FamilyRole(storedRawValue: roleRaw) else { return nil }
        return FamilyMember(
            id: id, name: name, role: role, isMe: isMe,
            isOnline: false, activity: ""
        )
    }
}
