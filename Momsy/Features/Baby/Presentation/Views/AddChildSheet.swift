import SwiftUI

/// Minimal add-child form shared by the Today header switcher and the
/// Manage-children screen. Returns a new `BabyProfile` to the caller on save.
struct AddChildSheet: View {
    @EnvironmentObject private var lm: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    let onSave: (BabyProfile) -> Void

    @State private var name = ""
    @State private var birthDate = Date()
    @State private var gender = ""

    private var strings: L10n { lm.strings }
    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                TextField(strings.name, text: $name)
                DatePicker(strings.birthDate,
                           selection: $birthDate, in: ...Date(), displayedComponents: .date)
                Picker(strings.gender, selection: $gender) {
                    Text(strings.genderUnspecified).tag("")
                    Text(strings.genderBoy).tag("boy")
                    Text(strings.genderGirl).tag("girl")
                }
            }
            .navigationTitle(strings.newChild)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(strings.done) {
                        onSave(BabyProfile(name: name.trimmingCharacters(in: .whitespaces),
                                           birthDate: birthDate, gender: gender))
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
