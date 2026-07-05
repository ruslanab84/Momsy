import SwiftUI

struct PersistenceRecoveryView: View {
    @EnvironmentObject private var lm: LocalizationManager
    @State private var showDetails = false

    let error: AppPersistenceError
    let onRetry: () -> Void

    var body: some View {
        ZStack {
            BabyFoodBackgroundView()

            ScrollView {
                VStack(spacing: 18) {
                    Image(systemName: "externaldrive.badge.exclamationmark")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(Color.bbCoralDeep)
                        .frame(width: 78, height: 78)
                        .background(Color.bbCoral.opacity(0.16))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    VStack(spacing: 10) {
                        Text(lm.strings.persistenceRecoveryTitle)
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.bbInk)
                            .multilineTextAlignment(.center)

                        Text(lm.strings.persistenceRecoveryMessage)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.bbInkSoft)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text(lm.strings.persistenceRecoverySuggestion)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.bbInkSoft)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(12)
                        .background(Color.bbCreamSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Button(action: onRetry) {
                        Label(lm.strings.persistenceRecoveryRetry, systemImage: "arrow.clockwise")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.bbCoralDeep)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    DisclosureGroup(lm.strings.persistenceRecoveryDetails, isExpanded: $showDetails) {
                        Text(error.technicalDetails)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.bbInkSoft)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.bbInkSoft)
                }
                .padding(20)
                .background(Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .bbShadow()
                .padding(.horizontal, 22)
                .padding(.vertical, 40)
                .frame(maxWidth: 430)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    PersistenceRecoveryView(
        error: .freshStoreCreationFailed(
            existingStoreError: NSError(domain: "SwiftData", code: 1),
            freshStoreError: NSError(domain: "SwiftData", code: 2)
        ),
        onRetry: {}
    )
    .environmentObject(LocalizationManager.shared)
}
