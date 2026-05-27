import SwiftUI

struct VitaminView: View {
    @ObservedObject var vm: VitaminViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    inputSection
                    listSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(Color.bbCream.ignoresSafeArea())
            .navigationTitle(loc.strings.vitamins)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.close) { dismiss() }
                        .foregroundColor(.bbMintDeep)
                }
            }
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(loc.strings.vitaminNameLabel)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)

            HStack(spacing: 10) {
                TextField(loc.strings.vitaminNamePlaceholder, text: $vm.vitaminName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInk)
                    .submitLabel(.done)
                    .onSubmit { vm.add() }

                Button(action: { vm.add() }) {
                    Text(loc.strings.add)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(vm.vitaminName.trimmingCharacters(in: .whitespaces).isEmpty ? .bbInkMute : .bbMintDeep)
                }
                .disabled(vm.vitaminName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(14)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Today's List

    @ViewBuilder
    private var listSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.strings.todaysVitamins)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)

            if vm.todayEntries.isEmpty {
                HStack {
                    Spacer()
                    Text(loc.strings.noVitaminsYet)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 20)
                    Spacer()
                }
                .background(Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(vm.todayEntries.enumerated()), id: \.element.id) { index, entry in
                        HStack(spacing: 12) {
                            Text(timeFormatter.string(from: entry.time))
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.bbInkMute)
                                .frame(width: 44, alignment: .leading)

                            CuteBlobView(kind: .vitamin, size: 32, tone: .bbButter)

                            Text(entry.label)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.bbInk)
                                .lineLimit(1)

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.bbCard)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))

                        if index < vm.todayEntries.count - 1 {
                            Divider()
                                .padding(.leading, 14 + 44 + 12 + 32 + 12)
                                .background(Color.bbCard)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: vm.todayEntries.count)
    }
}

#Preview {
    VitaminView(vm: VitaminViewModel(quickLogRepo: QuickLogRepository()))
        .environmentObject(LocalizationManager.shared)
}
