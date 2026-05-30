import SwiftUI

struct AddPumpingSheet: View {
    @ObservedObject var vm: PumpingViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager

    @State private var startTime = Date().addingTimeInterval(-1200)  // 20 min ago default
    @State private var endTime   = Date()
    @State private var side: PumpingSide = .left
    @State private var volumeML: Int = 100

    private var isValid: Bool { endTime > startTime }
    private var durationMinutes: Int { max(1, Int(endTime.timeIntervalSince(startTime)) / 60) }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    fieldSection(label: loc.strings.feedingStartedLabel) {
                        DatePicker(
                            "",
                            selection: $startTime,
                            in: ...Date(),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onChange(of: startTime) { _, newStart in
                            if endTime <= newStart {
                                endTime = newStart.addingTimeInterval(1200)
                            }
                        }
                    }

                    fieldSection(label: loc.strings.feedingEndedLabel) {
                        DatePicker(
                            "",
                            selection: $endTime,
                            in: startTime...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if isValid {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12, weight: .semibold))
                            Text("\(durationMinutes) \(loc.strings.unitMin)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.bbInkMute)
                        .padding(.horizontal, 4)
                    }

                    fieldSection(label: loc.strings.pumpingSideLabel) {
                        HStack(spacing: 0) {
                            ForEach(PumpingSide.allCases, id: \.self) { s in
                                let isSelected = side == s
                                Text(s.displayName(lang: loc.lang))
                                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                                    .foregroundColor(isSelected ? .bbRoseDeep : Color.bbInk.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(isSelected ? Color.bbRose.opacity(0.25) : Color.clear)
                                    .clipShape(Capsule())
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) { side = s }
                                    }
                            }
                        }
                        .padding(4)
                        .background(Color.bbCard)
                        .clipShape(Capsule())
                    }

                    fieldSection(label: loc.strings.pumpingVolume) {
                        HStack(spacing: 20) {
                            Button {
                                if volumeML >= 10 { volumeML -= 10 }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.bbRoseDeep)
                            }
                            .buttonStyle(.plain)

                            Text("\(volumeML) \(loc.strings.mlUnit)")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundColor(.bbInk)
                                .frame(minWidth: 80, alignment: .center)
                                .contentTransition(.numericText())
                                .animation(.spring(response: 0.25), value: volumeML)

                            Button {
                                if volumeML < 1000 { volumeML += 10 }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.bbRoseDeep)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .navigationTitle(loc.strings.addPumpingTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }
                        .foregroundColor(.bbRoseDeep)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.strings.save) {
                        vm.logManualEntry(
                            date: startTime,
                            durationMinutes: durationMinutes,
                            side: side,
                            volumeML: volumeML
                        )
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(isValid ? .bbRoseDeep : Color.bbInkMute)
                    .disabled(!isValid)
                }
            }
        }
    }

    @ViewBuilder
    private func fieldSection<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)
            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
