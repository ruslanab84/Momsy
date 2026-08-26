import SwiftUI

// MARK: - WHO Methodology Sheet

/// Discloses where the growth bands come from and how the percentile label is
/// derived. The label rounds age down to whole months and reports a range
/// between tabulated percentiles, so it reads more precise than it is unless
/// those approximations are spelled out.
struct WHOMethodologySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        NavigationStack {
            Form {
                Section(loc.strings.whoMethodologySourceTitle) {
                    paragraph(loc.strings.whoMethodologySource)
                    if let url = AppLegalLinks.whoGrowthStandardsURL {
                        Link(destination: url) {
                            HStack(spacing: 6) {
                                Text(loc.strings.whoMethodologyOpenSource)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.bbCoralDeep)
                        }
                    }
                }
                Section(loc.strings.whoAdaptationTitle) {
                    paragraph(loc.strings.whoGrowthAdaptationNote)
                }
                Section(loc.strings.whoMethodologyBandsTitle) {
                    paragraph(loc.strings.whoMethodologyBands)
                }
                Section(loc.strings.whoMethodologyCalcTitle) {
                    paragraph(loc.strings.whoMethodologyCalc)
                }
                Section(loc.strings.whoMethodologyMedicalTitle) {
                    paragraph(loc.strings.whoMethodologyMedical)
                }
            }
            .navigationTitle(loc.strings.whoMethodologyTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.strings.done) { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
    }

    private func paragraph(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, design: .rounded))
            .foregroundColor(.bbInkSoft)
            .fixedSize(horizontal: false, vertical: true)
    }
}
