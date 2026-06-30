import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import WidgetKit
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

private enum JoinAlert: Identifiable {
    case success
    case failure
    case confirm(String)

    var id: String {
        switch self {
        case .success: return "success"
        case .failure: return "failure"
        case .confirm(let code): return "confirm-\(code)"
        }
    }
}

@main
struct MomsyApp: App {
    @AppStorage("appTheme") private var appTheme = "system"
    @AppStorage("onboardingDone") private var onboardingDone = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var joinAlert: JoinAlert?

    private let container = AppContainer()
    private let localization = LocalizationManager.shared
    private let unitSystem   = UnitSystemManager.shared
    private let phoneSession: PhoneSessionManager
    private var appState: AppState { container.appState }

    private var resolvedColorScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    init() {
        FirebaseApp.configure()
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings

        let coordinator = QuickLogCoordinator(
            logFeeding:        container.logFeeding,
            startSleep:        container.startSleep,
            stopSleep:         container.stopSleep,
            getSleep:          container.getSleepEntries,
            diaperRepo:        container.diaperRepository,
            appState:          container.appState,
            analytics:         container.analytics,
            pushNotifications: container.pushNotifications
        )
        phoneSession = PhoneSessionManager(coordinator: coordinator, appState: container.appState)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .withContainer(container)
                .environmentObject(localization)
                .environmentObject(unitSystem)
                .environmentObject(appState)
                .withLocalization(localization)
                .preferredColorScheme(resolvedColorScheme)
                .task {
                    let deletionStillPending = await container.recoverPendingAccountDeletion()
                    container.runMigrationIfNeeded()
                    await appState.load()
                    phoneSession.activate()
                    guard !deletionStillPending else {
                        await setupNotificationsOnLaunch(appState: appState)
                        return
                    }
                    await container.authManager.signInAnonymouslyIfNeeded()
                    await container.cloudSyncDownloader.downloadAndMergeWhenReady()
                    await setupNotificationsOnLaunch(appState: appState)
                    await maybeGenerateWeeklyReport()
                }
                .onOpenURL { url in
#if canImport(GoogleSignIn)
                    GIDSignIn.sharedInstance.handle(url)
#endif
                    guard let code = JoinDeeplink.code(from: url) else { return }
                    guard onboardingDone else {
                        PendingFamilyInviteStore().save(code)
                        return
                    }
                    Task { @MainActor in
                        await joinFamilyFromLink(code: code)
                    }
                }
                .alert(item: $joinAlert) { alert in
                    switch alert {
                    case .success:
                        return Alert(title: Text(localization.strings.joinSuccessTitle),
                                     message: Text(localization.strings.joinSuccessMessage),
                                     dismissButton: .default(Text(localization.strings.done)))
                    case .failure:
                        return Alert(title: Text(localization.strings.joinFailedTitle),
                                     message: Text(localization.strings.joinFailedMessage),
                                     dismissButton: .default(Text(localization.strings.done)))
                    case .confirm(let code):
                        return Alert(
                            title: Text(localization.strings.joinReplaceTitle),
                            message: Text(localization.strings.joinReplaceMessage),
                            primaryButton: .destructive(Text(localization.strings.joinReplaceConfirm)) {
                                Task { @MainActor in
                                    await joinFamilyFromLink(code: code, force: true)
                                }
                            },
                            secondaryButton: .cancel(Text(localization.strings.cancel))
                        )
                    }
                }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                WidgetCenter.shared.reloadAllTimelines()
                Task { await container.cloudSyncDownloader.resyncAll() }
                Task { await maybeGenerateWeeklyReport() }
            }
        }
    }

    /// Generates the weekly AI report for the last completed week (Premium only).
    /// No-ops if a report already exists for that week.
    @MainActor
    private func maybeGenerateWeeklyReport() async {
        guard container.subscriptionManager.isPremium else { return }
        _ = await container.generateWeeklyInsight.generateIfNeeded()
    }

    @MainActor
    private func joinFamilyFromLink(code: String, force: Bool = false) async {
        await container.authManager.signInAnonymouslyIfNeeded()
        guard let uid = container.authManager.firebaseUser?.uid else {
            joinAlert = .failure
            return
        }
        do {
            try await FamilyManager.shared.joinFamily(code: code, uid: uid, force: force)
            joinAlert = .success
        } catch FamilyError.wouldAbandonExistingFamily where !force {
            joinAlert = .confirm(code)
        } catch {
            joinAlert = .failure
        }
    }
}

private func setupNotificationsOnLaunch(appState: AppState) async {
    let push = LocalPushNotificationService.shared
    await push.requestPermission()
    push.scheduleWeeklyReport(hour: 7, minute: 0)

    guard let birth = appState.babyProfile?.birthDate else { return }
    for leap in DevelopmentLeap.catalog {
        guard let start = Calendar.current.date(byAdding: .weekOfYear, value: leap.week, to: birth) else { continue }
        push.scheduleLeapNotification(leapID: leap.id, name: leap.name(for: LocalizationManager.shared.current), startDate: start)
    }
}
