import SwiftUI

// MARK: - View

struct SymptomView: View {
    @StateObject private var vm = SymptomViewModel()
    @AppStorage("appLanguage") private var lang = "en"

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                disclaimerCard
                symptomGrid
                resultCard
                    .animation(.spring(response: 0.38, dampingFraction: 0.78), value: vm.result)
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
                Text(t("Something wrong?", "Что-то не так?"))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(t("Mark it — we'll guide you on what to do", "Отметьте — мы подскажем, что делать"))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
            }
            Spacer()
            if vm.activeCount > 0 {
                Button { vm.reset() } label: {
                    Text(t("reset", "сбросить"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
            }
        }
    }

    // MARK: - Disclaimer Banner

    private var disclaimerCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(.bbButter)
            VStack(alignment: .leading, spacing: 2) {
                Text(t("NOT A DIAGNOSIS", "Это не диагноз"))
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbButter)
                    .kerning(0.6)
                Text(t("We help you navigate. The decision is yours and your doctor's.",
                       "Помогаем сориентироваться. Решение принимаете вы и врач."))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .bbCard(pad: 12, bg: .bbSurface)
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

    // MARK: - Result Card

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: vm.result.urgencyIcon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(vm.result.warningColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.urgencyLabel(for: vm.result.urgency).uppercased())
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbButterDeep)
                        .kerning(0.6)
                    Text(vm.result.title)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                }
            }

            if !vm.result.detail.isEmpty {
                Text(vm.result.detail)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !vm.result.warning.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(vm.result.warningColor)
                        Text(t("See doctor urgently if:", "Срочно к врачу, если:"))
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(vm.result.warningColor)
                    }
                    Text(vm.result.warning)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .bbCard(pad: 16, bg: vm.result.cardBg)
        .id(vm.result.title)
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button { vm.logToDiary() } label: {
                HStack(spacing: 6) {
                    Image(systemName: vm.diaryLogged ? "checkmark" : "book.closed")
                        .font(.system(size: 14, weight: .bold))
                    Text(vm.diaryLogged ? t("Saved", "Записано") : t("To diary", "В дневник"))
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                }
                .foregroundColor(vm.diaryLogged ? .bbMintDeep : .bbInk)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .bbShadowSoft()
            }

            Button {
                if let url = URL(string: "tel://103") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text(t("Call", "Позвонить"))
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.bbCoralDeep)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    // MARK: - Footer Disclaimer

    private var disclaimer: some View {
        Text(t("Symptom hints are navigation, not a diagnosis.\nWhen in doubt — always see your paediatrician.",
               "Подсказки на основе симптомов — это навигация, не диагноз.\nПри любых сомнениях — всегда к педиатру."))
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
                VStack(alignment: .leading, spacing: 1) {
                    Text(symptom.label)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(symptom.sub)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
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
    NavigationStack { SymptomView() }
}
