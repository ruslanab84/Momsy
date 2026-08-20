import SwiftUI
import StoreKit

struct PaywallView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    let onComplete: () -> Void

    @EnvironmentObject private var loc: LocalizationManager
    @State private var purchaseAlert: PurchaseAlert?

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
                        planSelector
                        Spacer(minLength: 16)
                        ctaSection
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: proxy.size.height)
                }
            }
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

            if subscriptionManager.trialEligible {
                Text(lm.trialBadge)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.bbLilacDeep)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.95))
                    .clipShape(Capsule())
            }
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

    private var planSelector: some View {
        VStack(spacing: 10) {
            if let annual = subscriptionManager.annualProduct {
                planCard(
                    product: annual,
                    title: lm.paywallPlanAnnual,
                    period: lm.paywallAnnualPeriod,
                    badge: subscriptionManager.savingsPercent.map(lm.paywallSavePercent)
                )
            }
            if let monthly = subscriptionManager.monthlyProduct {
                planCard(
                    product: monthly,
                    title: lm.paywallPlanMonthly,
                    period: lm.paywallMonthlyPeriod,
                    badge: nil
                )
            }
        }
        .padding(.horizontal, 24)
    }

    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button {
                purchaseAlert = nil
                Task {
                    do {
                        let purchaseSucceeded = try await subscriptionManager.purchase()
                        if purchaseSucceeded { onComplete() }
                    } catch {
                        purchaseAlert = localizedPurchaseAlert(error)
                    }
                }
            } label: {
                ZStack {
                    if subscriptionManager.isLoading {
                        ProgressView().tint(.bbLilacDeep)
                    } else {
                        Text(subscriptionManager.trialEligible ? lm.startTrial : lm.subscribeCTA)
                            .font(.headline)
                            .foregroundColor(.bbLilacDeep)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(subscriptionManager.isLoading)
            .padding(.horizontal, 24)

            if let purchaseAlert {
                Text("\(purchaseAlert.title): \(purchaseAlert.message)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

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
        guard let product = subscriptionManager.selectedProduct else {
            return lm.paywallPriceLoadingDisclosure
        }
        let price = product.displayPrice
        let isAnnual = product.id == ProductID.annual
        if subscriptionManager.trialEligible {
            return isAnnual
                ? lm.paywallRenewalDisclosureAnnual(price: price)
                : lm.paywallRenewalDisclosure(price: price)
        }
        return isAnnual
            ? lm.paywallRenewalDisclosureAnnualNoTrial(price: price)
            : lm.paywallRenewalDisclosureMonthlyNoTrial(price: price)
    }

    private var subscriptionNameText: String {
        let name = subscriptionManager.selectedProduct?.displayName ?? ""
        return name.isEmpty ? lm.paywallPlanFallbackName : name
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

    private func planCard(product: Product, title: String, period: String, badge: String?) -> some View {
        let isSelected = subscriptionManager.selectedProductID == product.id
        return Button {
            subscriptionManager.selectedProductID = product.id
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.white)
                        if let badge {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.bbLilacDeep)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.95))
                                .clipShape(Capsule())
                        }
                    }
                    Text(period)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer(minLength: 12)

                Text(product.displayPrice)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(isSelected ? 0.22 : 0.10))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(isSelected ? 0.9 : 0.22), lineWidth: isSelected ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func localizedPurchaseAlert(_ error: Error) -> PurchaseAlert {
        switch error {
        case SubscriptionError.pendingApproval:
            return PurchaseAlert(title: lm.purchasePendingTitle, message: lm.purchasePendingMessage)
        case SubscriptionError.failedVerification:
            return PurchaseAlert(title: lm.purchaseErrorTitle, message: lm.purchaseVerificationFailed)
        default:
            return PurchaseAlert(title: lm.purchaseErrorTitle, message: lm.purchaseProductUnavailable)
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
}

private struct PurchaseAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
