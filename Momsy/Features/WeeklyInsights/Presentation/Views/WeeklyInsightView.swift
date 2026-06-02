import SwiftUI

struct WeeklyInsightView: View {
    @StateObject private var vm: WeeklyInsightViewModel
    @ObservedObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var lm: LocalizationManager
    @State private var showPaywall = false

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeWeeklyInsightViewModel())
        _subscriptionManager = ObservedObject(wrappedValue: container.subscriptionManager)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if !subscriptionManager.isPremium {
                    lockedCard
                } else if vm.state.isLoading && vm.reports.isEmpty {
                    ProgressView()
                        .padding(.top, 60)
                } else if vm.reports.isEmpty {
                    emptyCard
                } else {
                    ForEach(vm.reports) { report in
                        NavigationLink(destination: WeeklyInsightDetailView(insight: report)) {
                            reportRow(report)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.strings.weeklyInsightTitle)
        .task { await vm.load(isPremium: subscriptionManager.isPremium) }
        .sheet(isPresented: $showPaywall) {
            PaywallView(subscriptionManager: subscriptionManager, onComplete: {
                showPaywall = false
                Task { await vm.load(isPremium: subscriptionManager.isPremium) }
            })
        }
    }

    // MARK: - Rows

    private func reportRow(_ report: WeeklyInsight) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(weekRange(report))
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbLilacDeep)
                Spacer()
                if !report.isAIGenerated {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.bbInkSoft)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.bbInkSoft)
            }
            Text(report.ai.overallSummary.isEmpty ? report.ai.sleepSummary : report.ai.overallSummary)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.bbInk)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
    }

    private var emptyCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(.bbLilacDeep)
            Text(lm.strings.weeklyInsightEmpty)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.top, 40)
    }

    private var lockedCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.bbLilacDeep)
            Text(lm.strings.weeklyInsightLocked)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.bbInk)
                .multilineTextAlignment(.center)
            Button(action: { showPaywall = true }) {
                Text(lm.strings.unlockPremium)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Color.bbLilacDeep)
                    .clipShape(Capsule())
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.top, 40)
    }

    private func weekRange(_ report: WeeklyInsight) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: lm.current.rawValue)
        f.dateFormat = "d MMM"
        let end = Calendar.current.date(byAdding: .day, value: -1, to: report.weekEnd) ?? report.weekEnd
        return "\(f.string(from: report.weekStart)) – \(f.string(from: end))"
    }
}
