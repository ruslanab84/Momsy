import SwiftUI
import WidgetKit
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

private enum JoinAlert: Identifiable {
    case success
    case failure
    case confirm(String)
    case removedFromFamily
    case cloudSyncConsent
    case cloudSyncFailure(String)
    case weeklyInsightAIConsent

    var id: String {
        switch self {
        case .success: return "success"
        case .failure: return "failure"
        case .confirm(let code): return "confirm-\(code)"
        case .removedFromFamily: return "removedFromFamily"
        case .cloudSyncConsent: return "cloudSyncConsent"
        case .cloudSyncFailure(let message): return "cloudSyncFailure-\(message)"
        case .weeklyInsightAIConsent: return "weeklyInsightAIConsent"
        }
    }
}

private enum AppStartupState {
    case ready(AppRuntime)
    case failed(AppPersistenceError)
}

private struct AppRuntime {
    let container: AppContainer
    let phoneSession: PhoneSessionManager
}

@main
struct MomsyApp: App {
    @AppStorage("appTheme") private var appTheme = "system"
    @State private var startup: AppStartupState

    private var resolvedColorScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    init() {
        FirebaseBootstrapper.configureIfAvailable()
        _startup = State(initialValue: Self.bootstrap())
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch startup {
                case .ready(let runtime):
                    MomsyRootView(runtime: runtime)
                case .failed(let error):
                    PersistenceRecoveryView(error: error) {
                        startup = Self.bootstrap()
                    }
                }
            }
            .environmentObject(LocalizationManager.shared)
            .withLocalization(LocalizationManager.shared)
            .preferredColorScheme(resolvedColorScheme)
        }
    }

    @MainActor
    private static func bootstrap() -> AppStartupState {
        do {
            let container = try AppContainer.makeProduction()
            return .ready(AppRuntime(
                container: container,
                phoneSession: makePhoneSession(container: container)
            ))
        } catch let error as AppPersistenceError {
            return .failed(error)
        } catch {
            return .failed(.freshStoreCreationFailed(
                existingStoreError: error,
                freshStoreError: error
            ))
        }
    }

    @MainActor
    private static func makePhoneSession(container: AppContainer) -> PhoneSessionManager {
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
        return PhoneSessionManager(coordinator: coordinator, appState: container.appState)
    }
}

private struct MomsyRootView: View {
    @AppStorage("onboardingDone") private var onboardingDone = false
    @AppStorage(WeeklyInsightAIConsent.storageKey) private var weeklyInsightAIConsent = WeeklyInsightAIConsent.Status.notDetermined.rawValue
    @Environment(\.scenePhase) private var scenePhase
    @State private var joinAlert: JoinAlert?
    @State private var showJoinAuthSheet = false
    @State private var pendingAuthenticatedJoinCode: String?
    @State private var pendingAuthenticatedJoinForce = false
    @State private var widgetFeatureRoute: WidgetFeatureRoute?

    let runtime: AppRuntime

    private var container: AppContainer { runtime.container }
    private var phoneSession: PhoneSessionManager { runtime.phoneSession }
    private let localization = LocalizationManager.shared
    private let unitSystem = UnitSystemManager.shared
    private var appState: AppState { container.appState }

    var body: some View {
        ContentView(widgetFeatureRoute: $widgetFeatureRoute)
            .withContainer(container)
            .environmentObject(localization)
            .environmentObject(unitSystem)
            .environmentObject(appState)
            .withLocalization(localization)
            .task {
                let deletionStillPending = await container.recoverPendingAccountDeletion()
                container.runMigrationIfNeeded()
                await appState.load()
                phoneSession.activate()
                if onboardingDone {
                    await setupNotificationsOnLaunch(appState: appState)
                }
                guard !deletionStillPending else { return }
                switch CloudSyncConsent.status() {
                case .granted:
                    await startCloudServices()
                case .notDetermined where onboardingDone:
                    joinAlert = .cloudSyncConsent
                case .notDetermined, .denied:
                    await maybeGenerateWeeklyReport()
                }
            }
            .onOpenURL { url in
#if canImport(GoogleSignIn)
                GIDSignIn.sharedInstance.handle(url)
#endif
                if let route = WidgetFeatureRoute(url: url) {
                    widgetFeatureRoute = route
                    return
                }
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
                case .removedFromFamily:
                    return Alert(title: Text(localization.strings.removedFromFamilyTitle),
                                 message: Text(localization.strings.removedFromFamilyMessage),
                                 dismissButton: .default(Text(localization.strings.done)))
                case .cloudSyncConsent:
                    return Alert(
                        title: Text(localization.strings.cloudSyncConsentTitle),
                        message: Text(localization.strings.cloudSyncConsentMessage),
                        primaryButton: .default(Text(localization.strings.cloudSyncAllow)) {
                            CloudSyncConsent.set(.granted)
                            Task { await startCloudServices() }
                        },
                        secondaryButton: .cancel(Text(localization.strings.cloudSyncKeepLocal)) {
                            CloudSyncConsent.set(.denied)
                            container.subscriptionManager.cloudSyncConsentDidChange(enabled: false)
                            Task { await maybeGenerateWeeklyReport() }
                        }
                    )
                case .cloudSyncFailure(let message):
                    return Alert(
                        title: Text(localization.strings.cloudSync),
                        message: Text(message),
                        dismissButton: .default(Text(localization.strings.done))
                    )
                case .weeklyInsightAIConsent:
                    return Alert(
                        title: Text(localization.strings.weeklyInsightAIConsentTitle),
                        message: Text(localization.strings.weeklyInsightAIConsentMessage),
                        primaryButton: .default(Text(localization.strings.weeklyInsightAIConsentAllow)) {
                            weeklyInsightAIConsent = WeeklyInsightAIConsent.Status.granted.rawValue
                            Task { await maybeGenerateWeeklyReport() }
                        },
                        secondaryButton: .cancel(Text(localization.strings.weeklyInsightAIConsentDeny)) {
                            weeklyInsightAIConsent = WeeklyInsightAIConsent.Status.denied.rawValue
                        }
                    )
                }
            }
            .sheet(isPresented: $showJoinAuthSheet, onDismiss: {
                Task { @MainActor in
                    await retryPendingAuthenticatedJoinIfPossible()
                }
            }) {
                AccountAuthSheet(container: container, mode: .joinFamily)
            }
            .onChange(of: onboardingDone) { _, isDone in
                guard isDone else { return }
                Task { await setupNotificationsOnLaunch(appState: appState) }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    WidgetCenter.shared.reloadAllTimelines()
                    if CloudSyncConsent.isGranted() {
                        Task { await container.cloudSyncDownloader.resyncAll() }
                        container.sleepLiveSync.start()
                    } else {
                        container.sleepLiveSync.stop()
                    }
                    Task { await maybeGenerateWeeklyReport() }
                } else {
                    container.sleepLiveSync.stop()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .familyMembershipRevoked)) { _ in
                joinAlert = .removedFromFamily
            }
    }

    /// Generates the weekly AI report for the last completed week (Premium only).
    /// No-ops if a report already exists for that week.
    @MainActor
    private func startCloudServices() async {
        do {
            try await container.authManager.signInAnonymouslyIfNeeded()
            container.subscriptionManager.cloudSyncConsentDidChange(enabled: true)
            await container.cloudSyncDownloader.downloadAndMergeWhenReady()
            container.sleepLiveSync.start()
        } catch {
            await maybeGenerateWeeklyReport()
            joinAlert = .cloudSyncFailure(error.localizedDescription)
            return
        }
        await maybeGenerateWeeklyReport()
    }

    @MainActor
    private func maybeGenerateWeeklyReport() async {
        /* Weekly Report and its Gemini consent/generation flow are temporarily disabled
        for the App Store release.
        guard onboardingDone, container.subscriptionManager.isPremium else { return }
        switch WeeklyInsightAIConsent.status() {
        case .notDetermined:
            joinAlert = .weeklyInsightAIConsent
        case .granted:
            _ = await container.generateWeeklyInsight.generateIfNeeded()
        case .denied:
            break
        }
        */
    }

    @MainActor
    private func joinFamilyFromLink(code: String, force: Bool = false) async {
        FamilyManager.shared.beginJoinFlow()
        defer { FamilyManager.shared.endJoinFlow() }
        do {
            try await container.authManager.requireAnonymousSignInIfNeeded()
            guard let uid = container.authManager.currentUID else {
                joinAlert = .failure
                return
            }
            try await FamilyManager.shared.joinFamily(code: code, uid: uid, force: force)
            pendingAuthenticatedJoinCode = nil
            pendingAuthenticatedJoinForce = false
            joinAlert = .success
        } catch AuthError.anonymousSignInRestricted {
            pendingAuthenticatedJoinCode = code
            pendingAuthenticatedJoinForce = force
            joinAlert = nil
            showJoinAuthSheet = true
        } catch FamilyError.wouldAbandonExistingFamily where !force {
            joinAlert = .confirm(code)
        } catch {
            joinAlert = .failure
        }
    }

    @MainActor
    private func retryPendingAuthenticatedJoinIfPossible() async {
        guard let code = pendingAuthenticatedJoinCode else { return }
        guard container.authManager.currentUID != nil else { return }
        let force = pendingAuthenticatedJoinForce
        pendingAuthenticatedJoinCode = nil
        pendingAuthenticatedJoinForce = false
        await joinFamilyFromLink(code: code, force: force)
    }
}

private func setupNotificationsOnLaunch(appState: AppState) async {
    let push = LocalPushNotificationService.shared
    // push.scheduleWeeklyReport(hour: 7, minute: 0) // Weekly Report is temporarily disabled.
    push.cancelWeeklyReport()

    guard let birth = appState.babyProfile?.birthDate else { return }
    for leap in DevelopmentLeap.catalog {
        let start = BabyAgeContext.leapStartDate(for: leap, birthDate: birth)
        push.scheduleLeapNotification(leapID: leap.id, name: leap.name(for: LocalizationManager.shared.current), startDate: start)
    }
}
