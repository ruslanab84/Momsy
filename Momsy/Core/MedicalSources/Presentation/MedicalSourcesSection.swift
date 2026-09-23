import SwiftUI

/// Reusable "Sources" block for every medical surface. Rows with a URL open the
/// publisher page in Safari; print-only citations (EPDS) render as static text.
struct MedicalSourcesSection: View {
    let ids: [MedicalSourceID]
    @EnvironmentObject var loc: LocalizationManager

    private var sources: [MedicalSource] { ids.compactMap(MedicalSourceCatalog.source) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.strings.medicalSourcesTitle)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .textCase(.uppercase)
            ForEach(sources) { source in
                if let url = source.url {
                    Link(destination: url) { row(source, isLink: true) }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(source.title), \(source.publisher.badge), \(loc.strings.medicalSourcesOpensInSafari)")
                        .accessibilityAddTraits(.isLink)
                } else {
                    row(source, isLink: false)
                        .accessibilityElement(children: .combine)
                }
            }
        }
    }

    private func row(_ source: MedicalSource, isLink: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(source.publisher.badge)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.bbCoralDeep))
            VStack(alignment: .leading, spacing: 2) {
                Text(source.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInk)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                if let citation = source.citation, !isLink {
                    Text(citation)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(source.year)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                }
            }
            Spacer(minLength: 0)
            if isLink {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.bbCoralDeep)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.bbCard))
    }
}

#Preview {
    ScrollView {
        MedicalSourcesSection(ids: [.whoGrowthStandards, .nhsColic, .aapSafeSleep, .epdsCox1987])
            .padding()
    }
    .background(Color.bbCream)
    .environmentObject(LocalizationManager.shared)
}
