import SwiftUI

// MARK: - View

struct SymptomView: View {
    @StateObject private var vm: SymptomViewModel
    @EnvironmentObject var loc: LocalizationManager

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeSymptomViewModel())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                symptomGrid
                severityPicker
                noteField
                actionButtons
                disclaimer
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbRose.opacity(0.25).ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.bbCoralDeep)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "cross.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.strings.symptomLogTitle)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(loc.strings.symptomLogSubtitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
            }
            Spacer()
            if vm.canSave {
                Button { vm.reset() } label: {
                    Text(loc.strings.reset)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
            }
        }
    }

    // MARK: - Symptom Grid

    private var symptomGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(vm.symptoms) { symptom in
                SymptomCard(symptom: symptom) {
                    vm.toggleSymptom(symptom.id)
                }
            }
        }
    }

    // MARK: - Severity

    private var severityPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.strings.symptomSeverityQuestion)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Picker(loc.strings.symptomSeverityQuestion, selection: $vm.severity) {
                Text(loc.strings.symptomSeverityMild).tag(SymptomSeverity.mild)
                Text(loc.strings.symptomSeverityModerate).tag(SymptomSeverity.moderate)
                Text(loc.strings.symptomSeverityHigh).tag(SymptomSeverity.high)
            }
            .pickerStyle(.segmented)
        }
        .bbCard(pad: 12)
    }

    // MARK: - Note

    private var noteField: some View {
        TextField(loc.strings.symptomNotePlaceholder, text: $vm.note, axis: .vertical)
            .lineLimit(3...6)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(.bbInk)
            .bbCard(pad: 12)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        Button { vm.logToDiary() } label: {
            HStack(spacing: 6) {
                Image(systemName: vm.diaryLogged ? "checkmark" : "book.closed")
                    .font(.system(size: 14, weight: .bold))
                Text(vm.diaryLogged ? loc.strings.saved : loc.strings.toDiary)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
            }
            .foregroundColor(vm.diaryLogged ? .bbMintDeep : .bbInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .bbShadowSoft()
        }
        .disabled(!vm.canSave)
        .opacity(vm.canSave || vm.diaryLogged ? 1 : 0.5)
    }

    // MARK: - Footer Disclaimer

    private var disclaimer: some View {
        Text(loc.strings.symptomLogFooter)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundColor(.bbInkMute)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Symptom Card

private struct SymptomCard: View {
    let symptom: Symptom
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(symptom.tone)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(symptom.icon)
                                .font(.system(size: 16))
                        )
                    Spacer()
                    if symptom.isOn {
                        Circle()
                            .fill(Color.bbCoralDeep)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundColor(.white)
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                Text(symptom.label)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
            }
            .bbCard(pad: 12)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(
                        symptom.isOn ? Color.bbCoralDeep : Color.clear,
                        lineWidth: 2.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { SymptomView(container: AppContainer()) }
}
