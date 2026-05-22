import SwiftUI
import Combine

// MARK: - Supporting Types

struct Symptom: Identifiable {
    let id: String
    let label: String
    let sub: String
    let tone: Color
    let icon: String
    var isOn: Bool
}

enum SymptomUrgency { case calm, watchful, urgent }

struct SymptomResult: Equatable {
    let title: String
    let detail: String
    let warning: String
    let urgency: SymptomUrgency

    static func == (lhs: SymptomResult, rhs: SymptomResult) -> Bool {
        lhs.title == rhs.title
    }

    var cardBg: Color {
        switch urgency {
        case .calm, .watchful: return Color.bbButter.opacity(0.8)
        case .urgent:          return Color.bbRose.opacity(0.7)
        }
    }
    var warningColor: Color {
        switch urgency {
        case .calm:            return Color.bbMintDeep
        case .watchful, .urgent: return Color.bbCoralDeep
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

// MARK: - ViewModel

final class SymptomViewModel: ObservableObject {
    @Published var isOnIDs: Set<String> = ["fever", "cry", "sleep"]
    @Published var diaryLogged = false

    private let appState: AppState
    private var lm: LocalizationManager { .shared }
    private func t(_ en: String, _ ru: String) -> String { lm.lang == "ru" ? ru : en }

    init(appState: AppState) {
        self.appState = appState
    }

    var displayName: String { appState.displayName }
    var activeCount: Int { isOnIDs.count }

    var symptoms: [Symptom] {
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

    func urgencyLabel(for urgency: SymptomUrgency) -> String {
        switch urgency {
        case .calm:     return t("Watching", "Наблюдаем")
        case .watchful: return t("Likely", "Скорее всего")
        case .urgent:   return t("See Doctor", "Нужен врач")
        }
    }

    var result: SymptomResult {
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

    func toggleSymptom(_ id: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            if isOnIDs.contains(id) { isOnIDs.remove(id) }
            else { isOnIDs.insert(id) }
        }
    }

    func reset() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isOnIDs = []
        }
    }

    func logToDiary() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { diaryLogged = true }
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run { withAnimation { diaryLogged = false } }
        }
    }
}
