import SwiftUI

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

            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        skipButton
                        Spacer(minLength: 12)
                        heroSection
                        Spacer().frame(height: 24)
                        featureList
                        Spacer().frame(height: 18)
                        planSummary
                        Spacer(minLength: 16)
                        ctaSection
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: proxy.size.height)
                }
            }
        }
        .alert(isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Alert(
                title: Text(lm.purchaseErrorTitle),
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

            Text(subscriptionNameText)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

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
            featureRow(icon: "book.fill", text: lm.featureDiary)
        }
        .padding(.horizontal, 40)
    }

    private var planSummary: some View {
        VStack(spacing: 10) {
            planRow(title: lm.paywallSubscriptionNameLabel, value: subscriptionNameText)
            planRow(title: lm.paywallSubscriptionPeriodLabel, value: lm.paywallMonthlyPeriod)
            planRow(title: lm.paywallSubscriptionPriceLabel, value: subscriptionPriceText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.13))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 24)
    }

    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    do {
                        let purchaseSucceeded = try await subscriptionManager.purchase()
                        if purchaseSucceeded { onComplete() }
                    } catch {
                        errorMessage = localizedPurchaseError(error)
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
            .disabled(subscriptionManager.isLoading || !subscriptionManager.canPurchase)
            .padding(.horizontal, 24)

            Text(renewalDisclosureText)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            legalLinks

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

    private var renewalDisclosureText: String {
        guard !subscriptionManager.monthlyPrice.isEmpty else {
            return lm.paywallPriceLoadingDisclosure
        }
        return lm.paywallRenewalDisclosure(price: subscriptionManager.monthlyPrice)
    }

    private var subscriptionNameText: String {
        subscriptionManager.subscriptionName.isEmpty ? lm.paywallPlanFallbackName : subscriptionManager.subscriptionName
    }

    private var subscriptionPriceText: String {
        subscriptionManager.monthlyPrice.isEmpty ? lm.paywallPriceLoadingDisclosure : subscriptionManager.monthlyPrice
    }

    private var legalLinks: some View {
        HStack(spacing: 18) {
            if let termsOfUseURL = AppLegalLinks.termsOfUseURL {
                Link(destination: termsOfUseURL) {
                    Text(lm.termsOfUseEULA)
                        .underline()
                }
            }

            if let privacyPolicyURL = AppLegalLinks.privacyPolicyURL {
                Link(destination: privacyPolicyURL) {
                    Text(lm.privacyPolicy)
                        .underline()
                }
            }
        }
        .font(.caption.weight(.semibold))
        .foregroundColor(.white.opacity(0.8))
    }

    // MARK: — Helpers

    private func localizedPurchaseError(_ error: Error) -> String {
        switch error {
        case SubscriptionError.failedVerification: return lm.purchaseVerificationFailed
        case SubscriptionError.productUnavailable:  return lm.purchaseProductUnavailable
        default:                                    return lm.purchaseProductUnavailable
        }
    }

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

    private func planRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.72))

            Spacer(minLength: 12)

            Text(value)
                .font(.caption.weight(.bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
    }
}
