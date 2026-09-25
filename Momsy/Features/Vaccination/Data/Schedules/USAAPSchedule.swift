import Foundation

/// American Academy of Pediatrics 2026 Recommended Immunization Schedule —
/// Children: Birth Through 6 Years Old (PDF linked from the cited healthychildren.org page).
/// Source: `MedicalSourceID.aapImmunizationSchedule`, edition 2026, lastReviewed 2026-09-25.
/// Where the source gives an age range, the item uses the first age of that range.
enum USAAPSchedule {
    static let definition = VaccinationScheduleDefinition(
        key: .usAAP, sourceID: .aapImmunizationSchedule, idRange: 200...299,
        lastReviewed: "2026-09-25", items: items
    )

    static let items: [VaccinationScheduleItem] = [
        // MARK: Birth
        .init(id: 200, en: "Hepatitis B — dose 1", ru: "Гепатит B — доза 1", de: "Hepatitis B — Dosis 1", es: "Hepatitis B — dosis 1", fr: "Hépatite B — dose 1", pt: "Hepatite B — dose 1", zh: "乙肝疫苗 — 第 1 剂", timing: .atBirth),
        .init(id: 201, en: "RSV — 1 dose during RSV season", ru: "РСВ — 1 доза в сезон РСВ", de: "RSV — 1 Dosis in der RSV-Saison", es: "VRS — 1 dosis en temporada de VRS", fr: "VRS — 1 dose pendant la saison du VRS", pt: "VSR — 1 dose na época do VSR", zh: "RSV — RSV 流行季 1 剂", timing: .atBirth),

        // MARK: 1 month
        .init(id: 202, en: "Hepatitis B — dose 2", ru: "Гепатит B — доза 2", de: "Hepatitis B — Dosis 2", es: "Hepatitis B — dosis 2", fr: "Hépatite B — dose 2", pt: "Hepatite B — dose 2", zh: "乙肝疫苗 — 第 2 剂", timing: .months(1)),

        // MARK: 2 months
        .init(id: 203, en: "Rotavirus (RV) — dose 1", ru: "Ротавирус — доза 1", de: "Rotaviren — Dosis 1", es: "Rotavirus — dosis 1", fr: "Rotavirus — dose 1", pt: "Rotavírus — dose 1", zh: "轮状病毒疫苗 — 第 1 剂", timing: .months(2)),
        .init(id: 204, en: "DTaP — dose 1", ru: "АКДС (DTaP) — доза 1", de: "DTaP — Dosis 1", es: "DTaP — dosis 1", fr: "DTCa — dose 1", pt: "DTPa — dose 1", zh: "百白破（DTaP）— 第 1 剂", timing: .months(2)),
        .init(id: 205, en: "Hib — dose 1", ru: "Хиб — доза 1", de: "Hib — Dosis 1", es: "Hib — dosis 1", fr: "Hib — dose 1", pt: "Hib — dose 1", zh: "Hib 疫苗 — 第 1 剂", timing: .months(2)),
        .init(id: 206, en: "Pneumococcal PCV — dose 1", ru: "Пневмококк ПКВ — доза 1", de: "Pneumokokken PCV — Dosis 1", es: "Neumococo PCV — dosis 1", fr: "Pneumocoque PCV — dose 1", pt: "Pneumocócica PCV — dose 1", zh: "肺炎球菌疫苗 PCV — 第 1 剂", timing: .months(2)),
        .init(id: 207, en: "Polio IPV — dose 1", ru: "Полиомиелит ИПВ — доза 1", de: "Polio IPV — Dosis 1", es: "Polio IPV — dosis 1", fr: "Polio VPI — dose 1", pt: "Pólio VIP — dose 1", zh: "脊灰灭活疫苗 IPV — 第 1 剂", timing: .months(2)),

        // MARK: 4 months
        .init(id: 208, en: "Rotavirus (RV) — dose 2", ru: "Ротавирус — доза 2", de: "Rotaviren — Dosis 2", es: "Rotavirus — dosis 2", fr: "Rotavirus — dose 2", pt: "Rotavírus — dose 2", zh: "轮状病毒疫苗 — 第 2 剂", timing: .months(4)),
        .init(id: 209, en: "DTaP — dose 2", ru: "АКДС (DTaP) — доза 2", de: "DTaP — Dosis 2", es: "DTaP — dosis 2", fr: "DTCa — dose 2", pt: "DTPa — dose 2", zh: "百白破（DTaP）— 第 2 剂", timing: .months(4)),
        .init(id: 210, en: "Hib — dose 2", ru: "Хиб — доза 2", de: "Hib — Dosis 2", es: "Hib — dosis 2", fr: "Hib — dose 2", pt: "Hib — dose 2", zh: "Hib 疫苗 — 第 2 剂", timing: .months(4)),
        .init(id: 211, en: "Pneumococcal PCV — dose 2", ru: "Пневмококк ПКВ — доза 2", de: "Pneumokokken PCV — Dosis 2", es: "Neumococo PCV — dosis 2", fr: "Pneumocoque PCV — dose 2", pt: "Pneumocócica PCV — dose 2", zh: "肺炎球菌疫苗 PCV — 第 2 剂", timing: .months(4)),
        .init(id: 212, en: "Polio IPV — dose 2", ru: "Полиомиелит ИПВ — доза 2", de: "Polio IPV — Dosis 2", es: "Polio IPV — dosis 2", fr: "Polio VPI — dose 2", pt: "Pólio VIP — dose 2", zh: "脊灰灭活疫苗 IPV — 第 2 剂", timing: .months(4)),

        // MARK: 6 months
        .init(id: 213, en: "Hepatitis B — dose 3", ru: "Гепатит B — доза 3", de: "Hepatitis B — Dosis 3", es: "Hepatitis B — dosis 3", fr: "Hépatite B — dose 3", pt: "Hepatite B — dose 3", zh: "乙肝疫苗 — 第 3 剂", timing: .months(6)),
        .init(id: 214, en: "Rotavirus (RV) — dose 3", ru: "Ротавирус — доза 3", de: "Rotaviren — Dosis 3", es: "Rotavirus — dosis 3", fr: "Rotavirus — dose 3", pt: "Rotavírus — dose 3", zh: "轮状病毒疫苗 — 第 3 剂", timing: .months(6)),
        .init(id: 215, en: "DTaP — dose 3", ru: "АКДС (DTaP) — доза 3", de: "DTaP — Dosis 3", es: "DTaP — dosis 3", fr: "DTCa — dose 3", pt: "DTPa — dose 3", zh: "百白破（DTaP）— 第 3 剂", timing: .months(6)),
        .init(id: 216, en: "Hib — dose 3", ru: "Хиб — доза 3", de: "Hib — Dosis 3", es: "Hib — dosis 3", fr: "Hib — dose 3", pt: "Hib — dose 3", zh: "Hib 疫苗 — 第 3 剂", timing: .months(6)),
        .init(id: 217, en: "Pneumococcal PCV — dose 3", ru: "Пневмококк ПКВ — доза 3", de: "Pneumokokken PCV — Dosis 3", es: "Neumococo PCV — dosis 3", fr: "Pneumocoque PCV — dose 3", pt: "Pneumocócica PCV — dose 3", zh: "肺炎球菌疫苗 PCV — 第 3 剂", timing: .months(6)),
        .init(id: 218, en: "Polio IPV — dose 3", ru: "Полиомиелит ИПВ — доза 3", de: "Polio IPV — Dosis 3", es: "Polio IPV — dosis 3", fr: "Polio VPI — dose 3", pt: "Pólio VIP — dose 3", zh: "脊灰灭活疫苗 IPV — 第 3 剂", timing: .months(6)),
        .init(id: 219, en: "COVID-19", ru: "COVID-19", de: "COVID-19", es: "COVID-19", fr: "COVID-19", pt: "COVID-19", zh: "新冠疫苗（COVID-19）", timing: .months(6)),
        .init(id: 220, en: "Influenza — yearly", ru: "Грипп — ежегодно", de: "Influenza — jährlich", es: "Gripe — anual", fr: "Grippe — chaque année", pt: "Gripe — anual", zh: "流感疫苗 — 每年", timing: .months(6)),

        // MARK: 8 months
        .init(id: 221, en: "RSV — 1 dose in 2nd season (high risk)", ru: "РСВ — 1 доза во 2-й сезон (группа риска)", de: "RSV — 1 Dosis in der 2. Saison (Risikogruppe)", es: "VRS — 1 dosis en la 2.ª temporada (alto riesgo)", fr: "VRS — 1 dose lors de la 2e saison (à risque)", pt: "VSR — 1 dose na 2.ª época (alto risco)", zh: "RSV — 第 2 个流行季 1 剂（高风险）", timing: .months(8), isOptional: true),

        // MARK: 12 months
        .init(id: 222, en: "Hib — booster", ru: "Хиб — ревакцинация", de: "Hib — Auffrischung", es: "Hib — refuerzo", fr: "Hib — rappel", pt: "Hib — reforço", zh: "Hib 疫苗 — 加强针", timing: .months(12)),
        .init(id: 223, en: "Pneumococcal PCV — dose 4", ru: "Пневмококк ПКВ — доза 4", de: "Pneumokokken PCV — Dosis 4", es: "Neumococo PCV — dosis 4", fr: "Pneumocoque PCV — dose 4", pt: "Pneumocócica PCV — dose 4", zh: "肺炎球菌疫苗 PCV — 第 4 剂", timing: .months(12)),
        .init(id: 224, en: "MMR — dose 1", ru: "Корь-краснуха-паротит (КПК) — доза 1", de: "MMR — Dosis 1", es: "Triple vírica (SRP) — dosis 1", fr: "ROR — dose 1", pt: "Tríplice viral (SCR) — dose 1", zh: "麻腮风疫苗（MMR）— 第 1 剂", timing: .months(12)),
        .init(id: 225, en: "Varicella — dose 1", ru: "Ветряная оспа — доза 1", de: "Varizellen — Dosis 1", es: "Varicela — dosis 1", fr: "Varicelle — dose 1", pt: "Varicela — dose 1", zh: "水痘疫苗 — 第 1 剂", timing: .months(12)),
        .init(id: 226, en: "Hepatitis A — dose 1", ru: "Гепатит A — доза 1", de: "Hepatitis A — Dosis 1", es: "Hepatitis A — dosis 1", fr: "Hépatite A — dose 1", pt: "Hepatite A — dose 1", zh: "甲肝疫苗 — 第 1 剂", timing: .months(12)),

        // MARK: 15 months
        .init(id: 227, en: "DTaP — dose 4", ru: "АКДС (DTaP) — доза 4", de: "DTaP — Dosis 4", es: "DTaP — dosis 4", fr: "DTCa — dose 4", pt: "DTPa — dose 4", zh: "百白破（DTaP）— 第 4 剂", timing: .months(15)),

        // MARK: 18 months
        .init(id: 228, en: "Hepatitis A — dose 2 (6 months after dose 1)", ru: "Гепатит A — доза 2 (через 6 месяцев после 1-й)", de: "Hepatitis A — Dosis 2 (6 Monate nach Dosis 1)", es: "Hepatitis A — dosis 2 (6 meses tras la 1.ª)", fr: "Hépatite A — dose 2 (6 mois après la 1re)", pt: "Hepatite A — dose 2 (6 meses após a 1.ª)", zh: "甲肝疫苗 — 第 2 剂（第 1 剂后 6 个月）", timing: .months(18)),

        // MARK: 4–6 years
        .init(id: 229, en: "DTaP — dose 5", ru: "АКДС (DTaP) — доза 5", de: "DTaP — Dosis 5", es: "DTaP — dosis 5", fr: "DTCa — dose 5", pt: "DTPa — dose 5", zh: "百白破（DTaP）— 第 5 剂", timing: .years(4)),
        .init(id: 230, en: "Polio IPV — dose 4", ru: "Полиомиелит ИПВ — доза 4", de: "Polio IPV — Dosis 4", es: "Polio IPV — dosis 4", fr: "Polio VPI — dose 4", pt: "Pólio VIP — dose 4", zh: "脊灰灭活疫苗 IPV — 第 4 剂", timing: .years(4)),
        .init(id: 231, en: "MMR — dose 2", ru: "Корь-краснуха-паротит (КПК) — доза 2", de: "MMR — Dosis 2", es: "Triple vírica (SRP) — dosis 2", fr: "ROR — dose 2", pt: "Tríplice viral (SCR) — dose 2", zh: "麻腮风疫苗（MMR）— 第 2 剂", timing: .years(4)),
        .init(id: 232, en: "Varicella — dose 2", ru: "Ветряная оспа — доза 2", de: "Varizellen — Dosis 2", es: "Varicela — dosis 2", fr: "Varicelle — dose 2", pt: "Varicela — dose 2", zh: "水痘疫苗 — 第 2 剂", timing: .years(4)),
    ]
}
