import SwiftUI

private struct Symptom: Identifiable {
    let id: String
    let label: String
    let sub: String
    let tone: Color
    let icon: String
    var isOn: Bool
}

struct SymptomView: View {
    @State private var symptoms: [Symptom] = [
        Symptom(id: "fever",  label: "Температура",  sub: "37.8°C · 40 мин",  tone: .bbCoral,  icon: "🌡", isOn: true),
        Symptom(id: "rash",   label: "Сыпь",          sub: "выберите место",   tone: .bbRose,   icon: "◌", isOn: false),
        Symptom(id: "vomit",  label: "Рвота",          sub: "нет",              tone: .bbButter, icon: "↑", isOn: false),
        Symptom(id: "cry",    label: "Долгий плач",    sub: "> 1 ч",            tone: .bbLilac,  icon: "♪", isOn: true),
        Symptom(id: "stool",  label: "Стул",           sub: "обычный",          tone: .bbMint,   icon: "⬭", isOn: false),
        Symptom(id: "eat",    label: "Отказ от еды",   sub: "выбрать",          tone: .bbSky,    icon: "✕", isOn: false),
        Symptom(id: "sleep",  label: "Сон",            sub: "короткие фазы",    tone: .bbLilac,  icon: "☾", isOn: true),
        Symptom(id: "other",  label: "Другое",         sub: "описать",          tone: .bbCreamSoft, icon: "+", isOn: false),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                disclaimerCard
                symptomGrid
                resultCard
                actionButtons
                disclaimer
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbRose.opacity(0.25).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
                Text("Что-то не так?")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text("Отметьте — мы подскажем, что делать")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
            }
            Spacer()
        }
    }

    // MARK: - Disclaimer Banner

    private var disclaimerCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("⚑ ЭТО НЕ ДИАГНОЗ")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbButter)
                .kerning(0.6)
            Text("Помогаем сориентироваться. Решение принимаете вы и врач.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .bbCard(pad: 12, bg: .bbInk)
    }

    // MARK: - Symptom Grid

    private var symptomGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(symptoms.indices, id: \.self) { i in
                SymptomCard(symptom: symptoms[i]) {
                    symptoms[i].isOn.toggle()
                }
            }
        }
    }

    // MARK: - Result Card

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                CuteBlobView(kind: .heart, size: 36, tone: .bbCoral)
                VStack(alignment: .leading, spacing: 2) {
                    Text("СКОРЕЕ ВСЕГО")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbButterDeep)
                        .kerning(0.6)
                    Text("Прорезывание зубов")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                }
            }

            Text("Температура до 38°, плач, проблемы со сном — частые спутники. Попробуйте холодный прорезыватель, носите на руках.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 4) {
                Text("⚠ Срочно к врачу, если:")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbCoralDeep)
                Text("температура > 38.5° дольше суток · отказ от воды · вялость · сыпь")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .bbCard(pad: 16, bg: Color.bbButter.opacity(0.8))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button(action: {}) {
                Text("Записать в дневник")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.bbCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .bbShadowSoft()
            }
            Button(action: {}) {
                Text("Позвонить врачу")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
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
        Text("Подсказки на основе симптомов — это навигация, не диагноз.\nПри сомнениях — всегда к педиатру.")
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
                            Text("✓")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundColor(.white)
                        )
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
                .strokeBorder(symptom.isOn ? Color.bbCoralDeep : Color.clear, lineWidth: 2.5)
        )
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    NavigationStack { SymptomView() }
}
