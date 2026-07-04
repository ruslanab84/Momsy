import SwiftUI
import AuthenticationServices

enum AccountAuthSheetMode {
    case account
    case joinFamily
}

struct AccountAuthSheet: View {
    @StateObject private var vm: AccountAuthViewModel
    @EnvironmentObject private var loc: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    private let mode: AccountAuthSheetMode

    init(container: AppContainer, mode: AccountAuthSheetMode = .account) {
        self.mode = mode
        _vm = StateObject(wrappedValue: container.makeAccountAuthViewModel())
    }

    var body: some View {
        NavigationStack {
            AuthStep(
                title: title,
                subtitle: subtitle,
                isSigningIn: vm.isSigningIn,
                authError: vm.authError,
                allowsSkip: false,
                prepareAppleRequest: vm.prepareApple,
                onAppleCompletion: vm.completeApple,
                onGoogle: vm.signInWithGoogle,
                onSkip: {}
            )
            .background(Color.bbCream.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.bbInkMute)
                    }
                }
            }
        }
        .onChange(of: vm.didSignIn) { _, signedIn in
            if signedIn { dismiss() }
        }
    }

    private var title: String {
        switch mode {
        case .account:
            return loc.strings.settingsAuthSheetTitle
        case .joinFamily:
            return loc.strings.joinAuthTitle
        }
    }

    private var subtitle: String {
        switch mode {
        case .account:
            return loc.strings.settingsAuthSheetSubtitle
        case .joinFamily:
            return loc.strings.joinAuthSubtitle
        }
    }
}
