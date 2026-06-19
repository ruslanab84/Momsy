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

    private var ru: Bool { lm.lang == "ru" }
    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                TextField(ru ? "Имя" : "Name", text: $name)
                DatePicker(ru ? "Дата рождения" : "Birth date",
                           selection: $birthDate, in: ...Date(), displayedComponents: .date)
                Picker(ru ? "Пол" : "Gender", selection: $gender) {
                    Text(ru ? "Не указан" : "Unspecified").tag("")
                    Text(ru ? "Мальчик" : "Boy").tag("boy")
                    Text(ru ? "Девочка" : "Girl").tag("girl")
                }
            }
            .navigationTitle(ru ? "Новый ребёнок" : "New child")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(ru ? "Отмена" : "Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(ru ? "Готово" : "Done") {
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
