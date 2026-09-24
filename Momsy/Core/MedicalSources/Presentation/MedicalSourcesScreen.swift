import SwiftUI

/// Global "Medical sources & disclaimer" screen: every catalog source, grouped by publisher.
struct MedicalSourcesScreen: View {
    @EnvironmentObject var loc: LocalizationManager

    /// Catalog grouped by publisher, WHO first (publisher priority order).
    static var groups: [[MedicalSourceID]] {
        MedicalPublisher.allCases
            .sorted { $0.priority < $1.priority }
            .map { publisher in MedicalSourceCatalog.all.filter { $0.publisher == publisher }.map(\.id) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Label(loc.strings.medicalDisclaimerTitle, systemImage: "stethoscope")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(loc.strings.medicalDisclaimerBody)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.bbCard))
                .accessibilityElement(children: .combine)

                ForEach(Self.groups, id: \.self) { ids in
                    MedicalSourcesSection(ids: ids)
                }
            }
            .padding()
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(loc.strings.medicalSourcesScreenTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { MedicalSourcesScreen() }
        .environmentObject(LocalizationManager.shared)
}
