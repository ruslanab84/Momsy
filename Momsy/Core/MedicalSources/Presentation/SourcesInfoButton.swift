import SwiftUI

/// Toolbar ⓘ button that presents the sources behind a medical screen.
struct SourcesInfoButton: View {
    let ids: [MedicalSourceID]
    @EnvironmentObject var loc: LocalizationManager
    @State private var isPresented = false

    var body: some View {
        Button { isPresented = true } label: {
            Image(systemName: "info.circle")
        }
        .accessibilityLabel(loc.strings.medicalSourcesButtonA11y)
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                ScrollView {
                    MedicalSourcesSection(ids: ids)
                        .padding()
                }
                .background(Color.bbCream)
                .navigationTitle(loc.strings.medicalSourcesTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(loc.strings.done) { isPresented = false }
                            .fontWeight(.bold)
                    }
                }
            }
            .environmentObject(loc)
        }
    }
}

#Preview {
    NavigationStack {
        Text("Screen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SourcesInfoButton(ids: [.whoPhysicalActivitySleepUnder5, .nhsHelpingBabySleep])
                }
            }
    }
    .environmentObject(LocalizationManager.shared)
}
