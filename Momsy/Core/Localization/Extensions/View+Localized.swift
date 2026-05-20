import SwiftUI

private struct LocalizationManagerKey: EnvironmentKey {
    static let defaultValue = LocalizationManager.shared
}

extension EnvironmentValues {
    var loc: LocalizationManager {
        get { self[LocalizationManagerKey.self] }
        set { self[LocalizationManagerKey.self] = newValue }
    }
}

extension View {
    func withLocalization(_ manager: LocalizationManager = .shared) -> some View {
        environment(\.loc, manager)
    }
}
