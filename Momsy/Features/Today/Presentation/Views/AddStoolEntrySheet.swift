import SwiftUI

struct AddStoolEntrySheet: View {
    let onSave: (Date) -> Void

    @State private var selectedDate = Date()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    dateCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color.bbCream.ignoresSafeArea())
            .navigationTitle(loc.strings.addStoolTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }
                        .foregroundColor(.bbInkSoft)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.strings.save) {
                        onSave(selectedDate)
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbMintDeep)
                }
            }
        }
    }

    private var dateCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.strings.stoolTimeLabel.uppercased())
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)

            DatePicker(
                "",
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .tint(.bbMintDeep)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.bbMint.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    AddStoolEntrySheet { _ in }
        .environmentObject(LocalizationManager.shared)
}
