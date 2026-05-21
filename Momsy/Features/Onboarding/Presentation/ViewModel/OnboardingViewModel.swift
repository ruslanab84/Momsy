import SwiftUI
import Combine

enum OBStep: Int, CaseIterable {
    case age, profile, role, ready
}

final class OnboardingViewModel: ObservableObject {
    @Published var step: OBStep = .age
    @Published var forward = true
    @Published var selectedStage: BabyAgeStage = .baby
    @Published var babyName = ""
    @Published var birthDate: Date = {
        Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date()
    }()
    @Published var parentName = ""
    @Published var parentRole = "mom"

    private let saveBabyProfileUC: SaveBabyProfileUseCase
    private let analytics: any AnalyticsServiceProtocol
    private let pushNotifications: any PushNotificationServiceProtocol
    private let onDone: () -> Void

    init(saveBabyProfile: SaveBabyProfileUseCase,
         analytics: any AnalyticsServiceProtocol = LogAnalyticsService(),
         pushNotifications: any PushNotificationServiceProtocol = LocalPushNotificationService.shared,
         onDone: @escaping () -> Void) {
        self.saveBabyProfileUC = saveBabyProfile
        self.analytics = analytics
        self.pushNotifications = pushNotifications
        self.onDone = onDone
    }

    private var lang: String { UserDefaults.standard.string(forKey: "appLanguage") ?? "en" }

    var canContinue: Bool {
        step == .profile ? !babyName.trimmingCharacters(in: .whitespaces).isEmpty : true
    }

    var stepColor: Color {
        switch step {
        case .age:     return .bbCoral
        case .profile: return .bbMint
        case .role:    return .bbLilac
        case .ready:   return .bbButter
        }
    }

    func advance() {
        guard canContinue else { return }
        forward = true
        let all = OBStep.allCases
        if let idx = all.firstIndex(of: step), idx + 1 < all.count {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                step = all[idx + 1]
            }
        }
    }

    func goBack() {
        forward = false
        let all = OBStep.allCases
        if let idx = all.firstIndex(of: step), idx > 0 {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                step = all[idx - 1]
            }
        }
    }

    func finish() {
        let name = babyName.trimmingCharacters(in: .whitespaces)
        let parent = parentName.trimmingCharacters(in: .whitespaces)
        // Persist via repository
        Task {
            try? await saveBabyProfileUC.execute(
                BabyProfile(name: name, birthDate: birthDate, stage: selectedStage.rawValue)
            )
        }
        // Keep flat keys for @AppStorage readers in existing views
        UserDefaults.standard.set(name,                      forKey: "babyName")
        UserDefaults.standard.set(birthDate.timeIntervalSince1970, forKey: "babyBirthDate")
        UserDefaults.standard.set(selectedStage.rawValue,    forKey: "babyStage")
        UserDefaults.standard.set(parentRole,                forKey: "parentRole")
        UserDefaults.standard.set(parent,                    forKey: "parentName")
        analytics.track(.onboardingComplete)
        pushNotifications.scheduleMorningDiary(hour: 9, minute: 0)
        onDone()
    }
}
