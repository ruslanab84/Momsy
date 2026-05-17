import SwiftUI

// MARK: - Models

private struct Symptom: Identifiable {
    let id: String
    let label: String
    let sub: String
    let tone: Color
    let icon: String
    var isOn: Bool
}

private enum SymptomUrgency { case calm, watchful, urgent }

private struct SymptomResult: Equatable {
    let title: String
    let detail: String
    let warning: String
    let urgency: SymptomUrgency

    static func == (lhs: SymptomResult, rhs: SymptomResult) -> Bool {
        lhs.title == rhs.title
    }

    var cardBg: Color {
        switch urgency {
        case .calm:     return Color.bbButter.opacity(0.8)
        case .watchful: return Color.bbButter.opacity(0.8)
        case .urgent:   return Color.bbRose.opacity(0.7)
        }
    }
    var warningColor: Color {
        switch urgency {
        case .calm:     return Color.bbMintDeep
        case .watchful: return Color.bbCoralDeep
        case .urgent:   return Color.bbCoralDeep
        }
    }
    var urgencyIcon: String {
        switch urgency {
        case .calm:     return "checkmark.circle.fill"
        case .watchful: return "questionmark.circle.fill"
        case .urgent:   return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - View

struct SymptomView: View {
    @AppStorage("babyName")    private var babyName = ""
    @AppStorage("appLanguage") private var lang = "en"

    @State private var isOnIDs: Set<String> = ["fever", "cry", "sleep"]
    @State private var diaryLogged = false

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }
    private var displayName: String { babyName.isEmpty ? t("Baby", "Малыш") : babyName }
    private var activeCount: Int { isOnIDs.count }

    private var symptoms: [Symptom] {
        [
            Symptom(id: "fever",  label: t("Temperature",   "Температура"),
                    sub: "37.8°C · 40 \(t("min", "мин"))",      tone: .bbCoral,     icon: "🌡", isOn: isOnIDs.contains("fever")),
            Symptom(id: "rash",   label: t("Rash",          "Сыпь"),
                    sub: t("choose area",   "выберите место"),    tone: .bbRose,      icon: "◌",  isOn: isOnIDs.contains("rash")),
            Symptom(id: "vomit",  label: t("Vomiting",      "Рвота"),
                    sub: t("none",          "нет"),               tone: .bbButter,    icon: "↑",  isOn: isOnIDs.contains("vomit")),
            Symptom(id: "cry",    label: t("Long crying",   "Долгий плач"),
                    sub: "> 1 \(t("hr",    "ч"))",               tone: .bbLilac,     icon: "♪",  isOn: isOnIDs.contains("cry")),
            Symptom(id: "stool",  label: t("Stool",         "Стул"),
                    sub: t("normal",        "обычный"),           tone: .bbMint,      icon: "⬭",  isOn: isOnIDs.contains("stool")),
            Symptom(id: "eat",    label: t("Refusing food", "Отказ от еды"),
                    sub: t("select",        "выбрать"),           tone: .bbSky,       icon: "✕",  isOn: isOnIDs.contains("eat")),
            Symptom(id: "sleep",  label: t("Sleep issues",  "Нарушение сна"),
                    sub: t("short phases",  "короткие фазы"),     tone: .bbLilac,     icon: "☾",  isOn: isOnIDs.contains("sleep")),
            Symptom(id: "other",  label: t("Other",         "Другое"),
                    sub: t("describe",      "описать"),           tone: .bbCreamSoft, icon: "+",  isOn: isOnIDs.contains("other")),
        ]
    }

    private func urgencyLabel(for urgency: SymptomUrgency) -> String {
        switch urgency {
        case .calm:     return t("Watching", "Наблюдаем")
        case .watchful: return t("Likely", "Скорее всего")
        case .urgent:   return t("See Doctor", "Нужен врач")
        }
    }

    private var result: SymptomResult {
        let on = isOnIDs

        if on.isEmpty {
            return SymptomResult(
                title: t("Nothing marked", "Ничего не отмечено"),
                detail: t("Mark symptoms above — we'll suggest what might be happening.",
                          "Отметьте симптомы выше — мы подскажем, что может происходить."),
                warning: "", urgency: .calm
            )
        }

        let hasFever = on.contains("fever")
        let hasRash   = on.contains("rash")
        let hasVomit  = on.contains("vomit")
        let hasCry    = on.contains("cry")
        let hasSleep  = on.contains("sleep")
        let hasEat    = on.contains("eat")

        if hasFever && hasRash {
            return SymptomResult(
                title: t("Needs Examination", "Требует осмотра"),
                detail: t("Fever combined with a rash needs a paediatrician's attention. Don't delay — call your doctor today.",
                          "Сочетание температуры и сыпи требует внимания педиатра. Не откладывайте — позвоните врачу сегодня."),
                warning: t("rash + fever · face or throat swelling · difficulty breathing",
                           "сыпь + температура · отёк лица или горла · затруднённое дыхание"),
                urgency: .urgent
            )
        }
        if hasVomit && hasFever {
            return SymptomResult(
                title: t("Gastroenteritis", "Гастроэнтерит"),
                detail: t("Vomiting with fever may indicate a gut infection. Keep fluids up: offer breast and water more often.",
                          "Рвота с температурой — возможна кишечная инфекция. Следите за водным балансом: грудь и вода чаще обычного."),
                warning: t("refusing fluids 6+ hrs · sunken fontanelle · dry mouth · bloody vomit",
                           "отказ от воды дольше 6 ч · запавший родничок · сухой рот · рвота с кровью"),
                urgency: .urgent
            )
        }
        if hasVomit {
            return SymptomResult(
                title: t("Digestive Upset", "Расстройство ЖКТ"),
                detail: t("Possible overfeeding, gas, or food reaction. Hold baby upright 20 min after feeding.",
                          "Возможен перекорм, газы или реакция на питание. Держите малыша вертикально 20 мин после еды."),
                warning: t("projectile vomiting · vomiting 3+ times in 2 hrs · blood in vomit",
                           "рвота фонтаном · рвота более 3 раз за 2 ч · кровь в рвоте"),
                urgency: .watchful
            )
        }
        if hasFever && hasCry && hasSleep {
            return SymptomResult(
                title: t("Teething", "Прорезывание зубов"),
                detail: t("Temp up to 38°, crying, disturbed sleep — classic signs. Try a cold teether, carry more.",
                          "Температура до 38°, плач, нарушение сна — частые спутники. Попробуйте холодный прорезыватель, носите на руках."),
                warning: t("t° > 38.5° for more than a day · refusing fluids · lethargy · unusual rash",
                           "t° > 38.5° дольше суток · отказ от воды · вялость · необычная сыпь"),
                urgency: .watchful
            )
        }
        if hasFever && hasEat {
            return SymptomResult(
                title: t("ARVI / Sore Throat", "ОРВИ / воспаление горла"),
                detail: t("Refusing food with fever is a common sign of a viral infection. Offer fluids and breast more often.",
                          "Отказ от еды при температуре — частый признак вирусной инфекции. Предлагайте воду и грудь чаще обычного."),
                warning: t("t° > 39° · difficulty breathing · lethargy · refusing all fluids",
                           "t° > 39° · затруднённое дыхание · вялость · отказ от воды"),
                urgency: .watchful
            )
        }
        if hasFever {
            return SymptomResult(
                title: t("Viral Infection", "Вирусная инфекция"),
                detail: t("Monitor closely. Use fever reducer at t° > 38.5°. Ensure adequate fluids.",
                          "Следите за динамикой. Жаропонижающее при t° > 38.5°. Обеспечьте достаточное питьё."),
                warning: t("t° > 38° in babies under 3 mo · t° > 39° in older babies · seizures · lethargy",
                           "t° > 38° у детей до 3 мес · t° > 39° у старших · судороги · вялость"),
                urgency: .watchful
            )
        }
        if hasCry && hasSleep {
            return SymptomResult(
                title: t("Leap or Colic", "Скачок или колики"),
                detail: t("Crying and disturbed sleep without fever are usually a developmental leap or colic. Try tummy massage and the 'tiger position'.",
                          "Плач и нарушение сна без температуры чаще всего — скачок развития или колики. Попробуйте массаж животика и «позицию тигра»."),
                warning: t("crying 3+ hrs non-stop · hard bloated belly",
                           "плач дольше 3 часов без перерыва · живот твёрдый и вздутый"),
                urgency: .calm
            )
        }
        if hasCry {
            return SymptomResult(
                title: t("Prolonged Crying", "Долгий плач"),
                detail: t("Check the basics: hunger, diaper, room temperature, tiredness. Peak colic age is 6 weeks.",
                          "Проверьте основные причины: голод, подгузник, температура в комнате, усталость. Пик колик — 6 недель."),
                warning: t("unusual tone of cry · arching back · no urination 8+ hrs",
                           "плач необычного тона · выгибание спины · нет мочеиспускания 8+ ч"),
                urgency: .calm
            )
        }
        return SymptomResult(
            title: t("Watching", "Наблюдаем"),
            detail: t("The marked symptoms aren't alarming. Keep observing and log any changes.",
                      "Отмеченные симптомы не вызывают тревоги. Продолжайте наблюдать и записывайте любые изменения."),
            warning: t("any worsening · new symptoms · your gut — you know your baby best",
                       "любое ухудшение · новые симптомы · ваша интуиция — вы лучше знаете малыша"),
            urgency: .calm
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                disclaimerCard
                symptomGrid
                resultCard
                    .animation(.spring(response: 0.38, dampingFraction: 0.78), value: result)
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
            if activeCount > 0 {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isOnIDs = []
                    }
                } label: {
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
            ForEach(symptoms) { symptom in
                SymptomCard(symptom: symptom) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        if isOnIDs.contains(symptom.id) {
                            isOnIDs.remove(symptom.id)
                        } else {
                            isOnIDs.insert(symptom.id)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Result Card

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: result.urgencyIcon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(result.warningColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(urgencyLabel(for: result.urgency).uppercased())
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbButterDeep)
                        .kerning(0.6)
                    Text(result.title)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                }
            }

            if !result.detail.isEmpty {
                Text(result.detail)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !result.warning.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(result.warningColor)
                        Text(t("See doctor urgently if:", "Срочно к врачу, если:"))
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(result.warningColor)
                    }
                    Text(result.warning)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .bbCard(pad: 16, bg: result.cardBg)
        .id(result.title)
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    diaryLogged = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { diaryLogged = false }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: diaryLogged ? "checkmark" : "book.closed")
                        .font(.system(size: 14, weight: .bold))
                    Text(diaryLogged ? t("Saved", "Записано") : t("To diary", "В дневник"))
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                }
                .foregroundColor(diaryLogged ? .bbMintDeep : .bbInk)
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
