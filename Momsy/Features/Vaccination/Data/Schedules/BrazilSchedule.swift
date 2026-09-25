import Foundation

/// Calendário Nacional de Vacinação — Criança (Programa Nacional de Imunizações),
/// as published on the cited Ministério da Saúde page (no edition date on the page).
/// Source: `MedicalSourceID.brCalendarioNacional`, lastReviewed 2026-09-25.
/// Exceptional/risk-based entries (yellow fever at 6–8 months, PCV20 at 5 years for
/// Indigenous children) are marked optional.
enum BrazilSchedule {
    static let definition = VaccinationScheduleDefinition(
        key: .brNational, sourceID: .brCalendarioNacional, idRange: 800...899,
        lastReviewed: "2026-09-25", items: items
    )

    static let items: [VaccinationScheduleItem] = [
        // MARK: Birth
        .init(id: 800, en: "Hepatitis B — birth dose", ru: "Гепатит B — доза при рождении", de: "Hepatitis B — Geburtsdosis", es: "Hepatitis B — dosis al nacer", fr: "Hépatite B — dose à la naissance", pt: "Hepatite B — dose ao nascer", zh: "乙肝疫苗 — 出生剂次", timing: .atBirth),
        .init(id: 801, en: "BCG (tuberculosis)", ru: "БЦЖ (туберкулёз)", de: "BCG (Tuberkulose)", es: "BCG (tuberculosis)", fr: "BCG (tuberculose)", pt: "BCG (tuberculose)", zh: "卡介苗（结核病）", timing: .atBirth),

        // MARK: 2 months
        .init(id: 802, en: "Pentavalent (DTP-Hib-HepB) — dose 1", ru: "Пентавакцина (АКДС-Хиб-ГепB) — доза 1", de: "Fünffach (DTP-Hib-HepB) — Dosis 1", es: "Pentavalente (DTP-Hib-HB) — dosis 1", fr: "Pentavalent (DTC-Hib-HépB) — dose 1", pt: "Penta (DTP+Hib+HB) — 1ª dose", zh: "五联疫苗（百白破-Hib-乙肝）— 第 1 剂", timing: .months(2)),
        .init(id: 803, en: "Polio IPV — dose 1", ru: "Полиомиелит ИПВ — доза 1", de: "Polio IPV — Dosis 1", es: "Polio VPI — dosis 1", fr: "Polio VPI — dose 1", pt: "Poliomielite inativada VIP — 1ª dose", zh: "脊灰灭活疫苗 IPV — 第 1 剂", timing: .months(2)),
        .init(id: 804, en: "Rotavirus — dose 1", ru: "Ротавирус — доза 1", de: "Rotaviren — Dosis 1", es: "Rotavirus — dosis 1", fr: "Rotavirus — dose 1", pt: "Rotavírus humano — 1ª dose", zh: "轮状病毒疫苗 — 第 1 剂", timing: .months(2)),
        .init(id: 805, en: "Pneumococcal conjugate — dose 1", ru: "Пневмококковая конъюгированная — доза 1", de: "Pneumokokken-Konjugat — Dosis 1", es: "Neumocócica conjugada — dosis 1", fr: "Pneumocoque conjugué — dose 1", pt: "Pneumocócica conjugada — 1ª dose", zh: "肺炎球菌结合疫苗 — 第 1 剂", timing: .months(2)),

        // MARK: 3 months
        .init(id: 806, en: "Meningococcal C — dose 1", ru: "Менингококк C — доза 1", de: "Meningokokken C — Dosis 1", es: "Meningocócica C — dosis 1", fr: "Méningocoque C — dose 1", pt: "Meningocócica C — 1ª dose", zh: "C 群脑膜炎球菌疫苗 — 第 1 剂", timing: .months(3)),

        // MARK: 4 months
        .init(id: 807, en: "Pentavalent (DTP-Hib-HepB) — dose 2", ru: "Пентавакцина (АКДС-Хиб-ГепB) — доза 2", de: "Fünffach (DTP-Hib-HepB) — Dosis 2", es: "Pentavalente (DTP-Hib-HB) — dosis 2", fr: "Pentavalent (DTC-Hib-HépB) — dose 2", pt: "Penta (DTP+Hib+HB) — 2ª dose", zh: "五联疫苗（百白破-Hib-乙肝）— 第 2 剂", timing: .months(4)),
        .init(id: 808, en: "Polio IPV — dose 2", ru: "Полиомиелит ИПВ — доза 2", de: "Polio IPV — Dosis 2", es: "Polio VPI — dosis 2", fr: "Polio VPI — dose 2", pt: "Poliomielite inativada VIP — 2ª dose", zh: "脊灰灭活疫苗 IPV — 第 2 剂", timing: .months(4)),
        .init(id: 809, en: "Rotavirus — dose 2", ru: "Ротавирус — доза 2", de: "Rotaviren — Dosis 2", es: "Rotavirus — dosis 2", fr: "Rotavirus — dose 2", pt: "Rotavírus humano — 2ª dose", zh: "轮状病毒疫苗 — 第 2 剂", timing: .months(4)),
        .init(id: 810, en: "Pneumococcal conjugate — dose 2", ru: "Пневмококковая конъюгированная — доза 2", de: "Pneumokokken-Konjugat — Dosis 2", es: "Neumocócica conjugada — dosis 2", fr: "Pneumocoque conjugué — dose 2", pt: "Pneumocócica conjugada — 2ª dose", zh: "肺炎球菌结合疫苗 — 第 2 剂", timing: .months(4)),

        // MARK: 5 months
        .init(id: 811, en: "Meningococcal C — dose 2", ru: "Менингококк C — доза 2", de: "Meningokokken C — Dosis 2", es: "Meningocócica C — dosis 2", fr: "Méningocoque C — dose 2", pt: "Meningocócica C — 2ª dose", zh: "C 群脑膜炎球菌疫苗 — 第 2 剂", timing: .months(5)),

        // MARK: 6 months
        .init(id: 812, en: "Pentavalent (DTP-Hib-HepB) — dose 3", ru: "Пентавакцина (АКДС-Хиб-ГепB) — доза 3", de: "Fünffach (DTP-Hib-HepB) — Dosis 3", es: "Pentavalente (DTP-Hib-HB) — dosis 3", fr: "Pentavalent (DTC-Hib-HépB) — dose 3", pt: "Penta (DTP+Hib+HB) — 3ª dose", zh: "五联疫苗（百白破-Hib-乙肝）— 第 3 剂", timing: .months(6)),
        .init(id: 813, en: "Polio IPV — dose 3", ru: "Полиомиелит ИПВ — доза 3", de: "Polio IPV — Dosis 3", es: "Polio VPI — dosis 3", fr: "Polio VPI — dose 3", pt: "Poliomielite inativada VIP — 3ª dose", zh: "脊灰灭活疫苗 IPV — 第 3 剂", timing: .months(6)),
        .init(id: 814, en: "Influenza — yearly (6 months to under 6 years)", ru: "Грипп — ежегодно (от 6 месяцев до 6 лет)", de: "Influenza — jährlich (6 Monate bis unter 6 Jahre)", es: "Gripe — anual (de 6 meses a menores de 6 años)", fr: "Grippe — chaque année (de 6 mois à moins de 6 ans)", pt: "Influenza — anual (6 meses a menores de 6 anos)", zh: "流感疫苗 — 每年（6 个月至 6 岁以下）", timing: .months(6)),
        .init(id: 815, en: "COVID-19 — dose 1", ru: "COVID-19 — доза 1", de: "COVID-19 — Dosis 1", es: "COVID-19 — dosis 1", fr: "COVID-19 — dose 1", pt: "Covid-19 — 1ª dose", zh: "新冠疫苗 — 第 1 剂", timing: .months(6)),
        .init(id: 816, en: "Yellow fever — exceptional dose (risk areas)", ru: "Жёлтая лихорадка — исключительная доза (зоны риска)", de: "Gelbfieber — Ausnahmedosis (Risikogebiete)", es: "Fiebre amarilla — dosis excepcional (zonas de riesgo)", fr: "Fièvre jaune — dose exceptionnelle (zones à risque)", pt: "Febre amarela — dose em casos excepcionais", zh: "黄热病疫苗 — 特殊情况剂次（风险地区）", timing: .months(6), isOptional: true),

        // MARK: 7 months
        .init(id: 817, en: "COVID-19 — dose 2", ru: "COVID-19 — доза 2", de: "COVID-19 — Dosis 2", es: "COVID-19 — dosis 2", fr: "COVID-19 — dose 2", pt: "Covid-19 — 2ª dose", zh: "新冠疫苗 — 第 2 剂", timing: .months(7)),

        // MARK: 9 months
        .init(id: 818, en: "COVID-19 — dose 3", ru: "COVID-19 — доза 3", de: "COVID-19 — Dosis 3", es: "COVID-19 — dosis 3", fr: "COVID-19 — dose 3", pt: "Covid-19 — 3ª dose", zh: "新冠疫苗 — 第 3 剂", timing: .months(9)),
        .init(id: 819, en: "Yellow fever — dose 1", ru: "Жёлтая лихорадка — доза 1", de: "Gelbfieber — Dosis 1", es: "Fiebre amarilla — dosis 1", fr: "Fièvre jaune — dose 1", pt: "Febre amarela — 1ª dose", zh: "黄热病疫苗 — 第 1 剂", timing: .months(9)),

        // MARK: 12 months
        .init(id: 820, en: "Pneumococcal conjugate — booster", ru: "Пневмококковая конъюгированная — ревакцинация", de: "Pneumokokken-Konjugat — Auffrischung", es: "Neumocócica conjugada — refuerzo", fr: "Pneumocoque conjugué — rappel", pt: "Pneumocócica 20-valente — reforço", zh: "肺炎球菌结合疫苗 — 加强针", timing: .months(12)),
        .init(id: 821, en: "Meningococcal ACWY", ru: "Менингококк ACWY", de: "Meningokokken ACWY", es: "Meningocócica ACWY", fr: "Méningocoque ACWY", pt: "Meningocócica ACWY", zh: "ACWY 群脑膜炎球菌疫苗", timing: .months(12)),
        .init(id: 822, en: "MMR — dose 1", ru: "Корь-краснуха-паротит (КПК) — доза 1", de: "MMR — Dosis 1", es: "Triple vírica — dosis 1", fr: "ROR — dose 1", pt: "Tríplice viral (SCR) — 1ª dose", zh: "麻腮风疫苗（MMR）— 第 1 剂", timing: .months(12)),

        // MARK: 15 months
        .init(id: 823, en: "DTP — booster 1", ru: "АКДС — 1-я ревакцинация", de: "DTP — 1. Auffrischung", es: "DTP — 1.er refuerzo", fr: "DTC — 1er rappel", pt: "DTP — 1º reforço", zh: "百白破 — 第 1 次加强", timing: .months(15)),
        .init(id: 824, en: "Polio IPV — booster 1", ru: "Полиомиелит ИПВ — 1-я ревакцинация", de: "Polio IPV — 1. Auffrischung", es: "Polio VPI — 1.er refuerzo", fr: "Polio VPI — 1er rappel", pt: "Poliomielite inativada VIP — 1º reforço", zh: "脊灰灭活疫苗 IPV — 第 1 次加强", timing: .months(15)),
        .init(id: 825, en: "MMR — dose 2", ru: "Корь-краснуха-паротит (КПК) — доза 2", de: "MMR — Dosis 2", es: "Triple vírica — dosis 2", fr: "ROR — dose 2", pt: "Tríplice viral (SCR) — 2ª dose", zh: "麻腮风疫苗（MMR）— 第 2 剂", timing: .months(15)),
        .init(id: 826, en: "Varicella — dose 1", ru: "Ветряная оспа — доза 1", de: "Varizellen — Dosis 1", es: "Varicela — dosis 1", fr: "Varicelle — dose 1", pt: "Varicela — 1ª dose", zh: "水痘疫苗 — 第 1 剂", timing: .months(15)),
        .init(id: 827, en: "Hepatitis A", ru: "Гепатит A", de: "Hepatitis A", es: "Hepatitis A", fr: "Hépatite A", pt: "Hepatite A", zh: "甲肝疫苗", timing: .months(15)),

        // MARK: 4 years
        .init(id: 828, en: "DTP — booster 2", ru: "АКДС — 2-я ревакцинация", de: "DTP — 2. Auffrischung", es: "DTP — 2.º refuerzo", fr: "DTC — 2e rappel", pt: "DTP — 2º reforço", zh: "百白破 — 第 2 次加强", timing: .years(4)),
        .init(id: 829, en: "Polio IPV — booster 2", ru: "Полиомиелит ИПВ — 2-я ревакцинация", de: "Polio IPV — 2. Auffrischung", es: "Polio VPI — 2.º refuerzo", fr: "Polio VPI — 2e rappel", pt: "Poliomielite inativada VIP — 2º reforço", zh: "脊灰灭活疫苗 IPV — 第 2 次加强", timing: .years(4)),
        .init(id: 830, en: "Varicella — dose 2", ru: "Ветряная оспа — доза 2", de: "Varizellen — Dosis 2", es: "Varicela — dosis 2", fr: "Varicelle — dose 2", pt: "Varicela — 2ª dose", zh: "水痘疫苗 — 第 2 剂", timing: .years(4)),
        .init(id: 831, en: "Yellow fever — booster", ru: "Жёлтая лихорадка — ревакцинация", de: "Gelbfieber — Auffrischung", es: "Fiebre amarilla — refuerzo", fr: "Fièvre jaune — rappel", pt: "Febre amarela — reforço", zh: "黄热病疫苗 — 加强针", timing: .years(4)),

        // MARK: 5 years
        .init(id: 832, en: "Pneumococcal 20-valent (Indigenous children without prior PCV)", ru: "Пневмококковая 20-валентная (дети коренных народов без ПКВ)", de: "Pneumokokken 20-valent (indigene Kinder ohne PCV)", es: "Neumocócica 20-valente (niños indígenas sin VNC previa)", fr: "Pneumocoque 20-valent (enfants autochtones sans PCV antérieur)", pt: "Pneumocócica 20-valente (povos indígenas sem histórico vacinal)", zh: "20 价肺炎球菌疫苗（未接种过的原住民儿童）", timing: .years(5), isOptional: true),
    ]
}
