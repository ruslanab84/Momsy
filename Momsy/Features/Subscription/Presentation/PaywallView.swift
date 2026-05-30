import SwiftUI
import StoreKit

struct PaywallView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    let onComplete: () -> Void

    @EnvironmentObject private var loc: LocalizationManager
    @State private var errorMessage: String?

    private var lm: L10n { loc.strings }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.bbLilacDeep, Color.bbRoseDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                skipButton
                Spacer()
                heroSection
                Spacer().frame(height: 36)
                featureList
                Spacer()
                ctaSection
            }
        }
        .alert(isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Alert(
                title: Text(lm.done),
                message: Text(errorMessage ?? ""),
                dismissButton: .default(Text(lm.done))
            )
        }
    }

    // MARK: — Sections

    private var skipButton: some View {
        HStack {
            Spacer()
            Button(action: onComplete) {
                Text(lm.mayBeLater)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
            }
        }
        .padding(.top, 12)
    }

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(systemName: "star.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }

            Text("Momsy Premium")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)

            Text(lm.trialBadge)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.bbLilacDeep)
                .padding(.horizontal, 18)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.95))
                .clipShape(Capsule())
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 18) {
            featureRow(icon: "infinity", text: lm.featureAll)
            featureRow(icon: "person.2.fill", text: lm.featureSync)
            featureRow(icon: "sparkles", text: lm.featureAI)
            featureRow(icon: "book.fill", text: lm.featureDiary)
        }
        .padding(.horizontal, 40)
    }

    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    do {
                        try await subscriptionManager.purchase()
                        if subscriptionManager.isPremium { onComplete() }
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            } label: {
                ZStack {
                    if subscriptionManager.isLoading {
                        ProgressView().tint(.bbLilacDeep)
                    } else {
                        Text(lm.startTrial)
                            .font(.headline)
                            .foregroundColor(.bbLilacDeep)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(subscriptionManager.isLoading || subscriptionManager.product == nil)
            .padding(.horizontal, 24)

            Text(lm.paywallPriceNote)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await subscriptionManager.restore()
                    if subscriptionManager.isPremium { onComplete() }
                }
            } label: {
                Text(lm.restorePurchases)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
                    .underline()
            }
        }
        .padding(.bottom, 44)
    }

    // MARK: — Helpers

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}
