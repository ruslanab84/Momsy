import SwiftUI

struct WeeklyInsightDetailView: View {
    let insight: WeeklyInsight
    @EnvironmentObject private var lm: LocalizationManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                section(
                    icon: "moon.zzz.fill",
                    color: .bbLilacDeep,
                    header: lm.strings.weeklyInsightSleepHeader,
                    summary: insight.ai.sleepSummary,
                    recommendation: insight.ai.sleepRecommendation
                )
                section(
                    icon: "fork.knife",
                    color: .bbCoralDeep,
                    header: lm.strings.weeklyInsightFeedingHeader,
                    summary: insight.ai.feedingSummary,
                    recommendation: insight.ai.feedingRecommendation
                )
                if !insight.ai.overallSummary.isEmpty {
                    overallCard
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.strings.weeklyInsightTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(icon: String, color: Color, header: String, summary: String, recommendation: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
                Text(header)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
            }
            if !summary.isEmpty {
                Text(summary)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if !recommendation.isEmpty {
                Text(recommendation)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(color)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
    }

    private var overallCard: some View {
        Text(insight.ai.overallSummary)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(.bbInk)
            .fixedSize(horizontal: false, vertical: true)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.bbLilac.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
