import Foundation

/// STIKO Impfkalender 2026, Tabelle 1A (Säuglinge und Kleinkinder) and the 5–6-year
/// column of Tabelle 1B — Epidemiologisches Bulletin 4/2026 (22 January 2026),
/// linked from the cited RKI Impfkalender page.
/// Source: `MedicalSourceID.stikoImpfkalender`, edition 2026, lastReviewed 2026-09-25.
/// The extra dose for preterm infants (footnote c) is not listed.
enum GermanySTIKOSchedule {
    static let definition = VaccinationScheduleDefinition(
        key: .deSTIKO, sourceID: .stikoImpfkalender, idRange: 400...499,
        lastReviewed: "2026-09-25", items: items
    )

    static let items: [VaccinationScheduleItem] = [
        // MARK: Birth
        .init(id: 400, en: "RSV antibody — single dose (by birth month)", ru: "Антитела к РСВ — однократно (по месяцу рождения)", de: "RSV-Antikörper — Einmaldosis (je nach Geburtsmonat)", es: "Anticuerpo frente al VRS — dosis única (según mes de nacimiento)", fr: "Anticorps anti-VRS — dose unique (selon le mois de naissance)", pt: "Anticorpo contra o VSR — dose única (conforme o mês de nascimento)", zh: "RSV 单克隆抗体 — 单剂（按出生月份）", timing: .atBirth),

        // MARK: 6 weeks
        .init(id: 401, en: "Rotavirus — dose 1", ru: "Ротавирус — доза 1", de: "Rotaviren — Dosis 1", es: "Rotavirus — dosis 1", fr: "Rotavirus — dose 1", pt: "Rotavírus — dose 1", zh: "轮状病毒疫苗 — 第 1 剂", timing: .weeks(6)),

        // MARK: 2 months
        .init(id: 402, en: "Hexavalent (DTaP-IPV-Hib-HepB) — dose 1", ru: "Шестивалентная (АКДС-ИПВ-Хиб-ГепB) — доза 1", de: "Sechsfach (DTaP-IPV-Hib-HepB) — Dosis 1", es: "Hexavalente (DTPa-VPI-Hib-HB) — dosis 1", fr: "Hexavalent (DTCa-VPI-Hib-HépB) — dose 1", pt: "Hexavalente (DTPa-VIP-Hib-HB) — dose 1", zh: "六联疫苗（百白破-脊灰-Hib-乙肝）— 第 1 剂", timing: .months(2)),
        .init(id: 403, en: "Pneumococcal PCV — dose 1", ru: "Пневмококк ПКВ — доза 1", de: "Pneumokokken PCV — Dosis 1", es: "Neumococo PCV — dosis 1", fr: "Pneumocoque PCV — dose 1", pt: "Pneumocócica PCV — dose 1", zh: "肺炎球菌疫苗 PCV — 第 1 剂", timing: .months(2)),
        .init(id: 404, en: "Meningococcal B — dose 1", ru: "Менингококк B — доза 1", de: "Meningokokken B — Dosis 1", es: "Meningococo B — dosis 1", fr: "Méningocoque B — dose 1", pt: "Meningocócica B — dose 1", zh: "B 群脑膜炎球菌疫苗 — 第 1 剂", timing: .months(2)),

        // MARK: 3 months
        .init(id: 405, en: "Rotavirus — dose 2", ru: "Ротавирус — доза 2", de: "Rotaviren — Dosis 2", es: "Rotavirus — dosis 2", fr: "Rotavirus — dose 2", pt: "Rotavírus — dose 2", zh: "轮状病毒疫苗 — 第 2 剂", timing: .months(3)),

        // MARK: 4 months
        .init(id: 406, en: "Rotavirus — dose 3 (depending on vaccine)", ru: "Ротавирус — доза 3 (в зависимости от вакцины)", de: "Rotaviren — Dosis 3 (je nach Impfstoff)", es: "Rotavirus — dosis 3 (según la vacuna)", fr: "Rotavirus — dose 3 (selon le vaccin)", pt: "Rotavírus — dose 3 (conforme a vacina)", zh: "轮状病毒疫苗 — 第 3 剂（视疫苗而定）", timing: .months(4), isOptional: true),
        .init(id: 407, en: "Hexavalent (DTaP-IPV-Hib-HepB) — dose 2", ru: "Шестивалентная (АКДС-ИПВ-Хиб-ГепB) — доза 2", de: "Sechsfach (DTaP-IPV-Hib-HepB) — Dosis 2", es: "Hexavalente (DTPa-VPI-Hib-HB) — dosis 2", fr: "Hexavalent (DTCa-VPI-Hib-HépB) — dose 2", pt: "Hexavalente (DTPa-VIP-Hib-HB) — dose 2", zh: "六联疫苗（百白破-脊灰-Hib-乙肝）— 第 2 剂", timing: .months(4)),
        .init(id: 408, en: "Pneumococcal PCV — dose 2", ru: "Пневмококк ПКВ — доза 2", de: "Pneumokokken PCV — Dosis 2", es: "Neumococo PCV — dosis 2", fr: "Pneumocoque PCV — dose 2", pt: "Pneumocócica PCV — dose 2", zh: "肺炎球菌疫苗 PCV — 第 2 剂", timing: .months(4)),
        .init(id: 409, en: "Meningococcal B — dose 2", ru: "Менингококк B — доза 2", de: "Meningokokken B — Dosis 2", es: "Meningococo B — dosis 2", fr: "Méningocoque B — dose 2", pt: "Meningocócica B — dose 2", zh: "B 群脑膜炎球菌疫苗 — 第 2 剂", timing: .months(4)),

        // MARK: 11 months
        .init(id: 410, en: "Hexavalent (DTaP-IPV-Hib-HepB) — dose 3", ru: "Шестивалентная (АКДС-ИПВ-Хиб-ГепB) — доза 3", de: "Sechsfach (DTaP-IPV-Hib-HepB) — Dosis 3", es: "Hexavalente (DTPa-VPI-Hib-HB) — dosis 3", fr: "Hexavalent (DTCa-VPI-Hib-HépB) — dose 3", pt: "Hexavalente (DTPa-VIP-Hib-HB) — dose 3", zh: "六联疫苗（百白破-脊灰-Hib-乙肝）— 第 3 剂", timing: .months(11)),
        .init(id: 411, en: "Pneumococcal PCV — dose 3", ru: "Пневмококк ПКВ — доза 3", de: "Pneumokokken PCV — Dosis 3", es: "Neumococo PCV — dosis 3", fr: "Pneumocoque PCV — dose 3", pt: "Pneumocócica PCV — dose 3", zh: "肺炎球菌疫苗 PCV — 第 3 剂", timing: .months(11)),
        .init(id: 412, en: "MMR — dose 1", ru: "Корь-краснуха-паротит (КПК) — доза 1", de: "Masern, Mumps, Röteln — Dosis 1", es: "Triple vírica (SRP) — dosis 1", fr: "ROR — dose 1", pt: "Tríplice viral (SCR) — dose 1", zh: "麻腮风疫苗（MMR）— 第 1 剂", timing: .months(11)),
        .init(id: 413, en: "Varicella — dose 1", ru: "Ветряная оспа — доза 1", de: "Varizellen — Dosis 1", es: "Varicela — dosis 1", fr: "Varicelle — dose 1", pt: "Varicela — dose 1", zh: "水痘疫苗 — 第 1 剂", timing: .months(11)),

        // MARK: 12 months
        .init(id: 414, en: "Meningococcal B — dose 3", ru: "Менингококк B — доза 3", de: "Meningokokken B — Dosis 3", es: "Meningococo B — dosis 3", fr: "Méningocoque B — dose 3", pt: "Meningocócica B — dose 3", zh: "B 群脑膜炎球菌疫苗 — 第 3 剂", timing: .months(12)),

        // MARK: 15 months
        .init(id: 415, en: "MMR — dose 2", ru: "Корь-краснуха-паротит (КПК) — доза 2", de: "Masern, Mumps, Röteln — Dosis 2", es: "Triple vírica (SRP) — dosis 2", fr: "ROR — dose 2", pt: "Tríplice viral (SCR) — dose 2", zh: "麻腮风疫苗（MMR）— 第 2 剂", timing: .months(15)),
        .init(id: 416, en: "Varicella — dose 2", ru: "Ветряная оспа — доза 2", de: "Varizellen — Dosis 2", es: "Varicela — dosis 2", fr: "Varicelle — dose 2", pt: "Varicela — dose 2", zh: "水痘疫苗 — 第 2 剂", timing: .months(15)),

        // MARK: 5 years
        .init(id: 417, en: "Tetanus, diphtheria, pertussis — booster", ru: "Столбняк, дифтерия, коклюш — ревакцинация", de: "Tetanus, Diphtherie, Pertussis — Auffrischung", es: "Tétanos, difteria, tosferina — refuerzo", fr: "Tétanos, diphtérie, coqueluche — rappel", pt: "Tétano, difteria, tosse convulsa — reforço", zh: "破伤风、白喉、百日咳 — 加强针", timing: .years(5)),
    ]
}
