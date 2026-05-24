import SwiftUI

struct MoodCheckinSheet: View {
    @ObservedObject var vm: MomMoodViewModel
    @EnvironmentObject private var lm: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    @State private var mood = 3
    @State private var energy = 3
    @State private var note = ""

    private let faces = ["😔", "😕", "😐", "🙂", "😊"]
    private let energyIcons = ["🪫", "😴", "⚡️", "💪", "🚀"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    pickerSection(
                        label: lm.strings.tabDiary,
                        emojis: faces,
                        selected: $mood
                    )
                    pickerSection(
                        label: lm.strings.momMoodEnergyLabel,
                        emojis: energyIcons,
                        selected: $energy
                    )
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lm.strings.momMoodNoteSub.uppercased())
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInkMute)
                            .kerning(0.5)
                        TextField(lm.strings.noteExamplePlaceholder, text: $note)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .padding(14)
                            .background(Color.bbCard)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    Button {
                        Task {
                            await vm.saveCheckin(mood: mood, energy: energy, note: note)
                            dismiss()
                        }
                    } label: {
                        Text(lm.strings.save)
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.bbRoseDeep)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
                .padding(20)
            }
            .background(Color.bbCream.ignoresSafeArea())
            .navigationTitle(lm.strings.momMoodCheckin)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lm.strings.cancel) { dismiss() }
                        .foregroundColor(.bbInkSoft)
                }
            }
        }
    }

    private func pickerSection(label: String, emojis: [String], selected: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { val in
                    Button { selected.wrappedValue = val } label: {
                        VStack(spacing: 4) {
                            Text(emojis[val - 1])
                                .font(.system(size: 28))
                            Circle()
                                .fill(selected.wrappedValue == val ? Color.bbRoseDeep : Color.clear)
                                .frame(width: 6, height: 6)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selected.wrappedValue == val
                            ? Color.bbRose.opacity(0.4)
                            : Color.bbCard)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.25, dampingFraction: 0.8), value: selected.wrappedValue)
                }
            }
        }
    }
}
