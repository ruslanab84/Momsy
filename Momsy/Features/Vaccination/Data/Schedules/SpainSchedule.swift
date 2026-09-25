import Foundation

/// Calendario común de vacunación e inmunización a lo largo de toda la vida —
/// Calendario recomendado año 2026 (approved by the Consejo Interterritorial del SNS
/// on 12 December 2025), PDF linked from the cited Ministerio de Sanidad page.
/// Source: `MedicalSourceID.esCalendarioComun`, edition 2026, lastReviewed 2026-09-25.
/// Only "administración sistemática" entries up to 6 years; catch-up entries are not listed.
enum SpainSchedule {
    static let definition = VaccinationScheduleDefinition(
        key: .esNational, sourceID: .esCalendarioComun, idRange: 700...799,
        lastReviewed: "2026-09-25", items: items
    )

    static let items: [VaccinationScheduleItem] = [
        // MARK: Birth
        .init(id: 700, en: "Hepatitis B — birth dose (mother HBsAg-positive or unscreened)", ru: "Гепатит B — при рождении (мать HBsAg+ или без скрининга)", de: "Hepatitis B — Geburtsdosis (Mutter HBsAg-positiv oder ungescreent)", es: "Hepatitis B — dosis al nacer (madre AgHBs positivo o sin cribado)", fr: "Hépatite B — dose à la naissance (mère AgHBs positive ou non dépistée)", pt: "Hepatite B — dose à nascença (mãe AgHBs positivo ou sem rastreio)", zh: "乙肝疫苗 — 出生剂次（母亲 HBsAg 阳性或未筛查）", timing: .atBirth, isOptional: true),
        .init(id: 701, en: "RSV immunisation", ru: "Иммунизация против РСВ", de: "RSV-Immunisierung", es: "Inmunización frente al VRS", fr: "Immunisation contre le VRS", pt: "Imunização contra o VSR", zh: "RSV 免疫", timing: .atBirth),

        // MARK: 2 months
        .init(id: 702, en: "Hexavalent (DTaP-IPV-Hib-HepB) — dose 1", ru: "Шестивалентная (АКДС-ИПВ-Хиб-ГепB) — доза 1", de: "Sechsfach (DTaP-IPV-Hib-HepB) — Dosis 1", es: "Hexavalente (DTPa-VPI-Hib-HB) — dosis 1", fr: "Hexavalent (DTCa-VPI-Hib-HépB) — dose 1", pt: "Hexavalente (DTPa-VIP-Hib-HB) — dose 1", zh: "六联疫苗（百白破-脊灰-Hib-乙肝）— 第 1 剂", timing: .months(2)),
        .init(id: 703, en: "Pneumococcal PCV — dose 1", ru: "Пневмококк ПКВ — доза 1", de: "Pneumokokken PCV — Dosis 1", es: "Neumococo VNC — dosis 1", fr: "Pneumocoque PCV — dose 1", pt: "Pneumocócica PCV — dose 1", zh: "肺炎球菌疫苗 PCV — 第 1 剂", timing: .months(2)),
        .init(id: 704, en: "Meningococcal B — dose 1", ru: "Менингококк B — доза 1", de: "Meningokokken B — Dosis 1", es: "MenB — dosis 1", fr: "Méningocoque B — dose 1", pt: "Meningocócica B — dose 1", zh: "B 群脑膜炎球菌疫苗 — 第 1 剂", timing: .months(2)),
        .init(id: 705, en: "Rotavirus (schedule per vaccine used)", ru: "Ротавирус (схема по инструкции вакцины)", de: "Rotaviren (Schema je nach Impfstoff)", es: "Rotavirus (pauta según ficha técnica)", fr: "Rotavirus (schéma selon le vaccin)", pt: "Rotavírus (esquema conforme a vacina)", zh: "轮状病毒疫苗（按所用疫苗的程序）", timing: .months(2)),

        // MARK: 4 months
        .init(id: 706, en: "Hexavalent (DTaP-IPV-Hib-HepB) — dose 2", ru: "Шестивалентная (АКДС-ИПВ-Хиб-ГепB) — доза 2", de: "Sechsfach (DTaP-IPV-Hib-HepB) — Dosis 2", es: "Hexavalente (DTPa-VPI-Hib-HB) — dosis 2", fr: "Hexavalent (DTCa-VPI-Hib-HépB) — dose 2", pt: "Hexavalente (DTPa-VIP-Hib-HB) — dose 2", zh: "六联疫苗（百白破-脊灰-Hib-乙肝）— 第 2 剂", timing: .months(4)),
        .init(id: 707, en: "Pneumococcal PCV — dose 2", ru: "Пневмококк ПКВ — доза 2", de: "Pneumokokken PCV — Dosis 2", es: "Neumococo VNC — dosis 2", fr: "Pneumocoque PCV — dose 2", pt: "Pneumocócica PCV — dose 2", zh: "肺炎球菌疫苗 PCV — 第 2 剂", timing: .months(4)),
        .init(id: 708, en: "Meningococcal B — dose 2", ru: "Менингококк B — доза 2", de: "Meningokokken B — Dosis 2", es: "MenB — dosis 2", fr: "Méningocoque B — dose 2", pt: "Meningocócica B — dose 2", zh: "B 群脑膜炎球菌疫苗 — 第 2 剂", timing: .months(4)),
        .init(id: 709, en: "Meningococcal C — dose 1", ru: "Менингококк C — доза 1", de: "Meningokokken C — Dosis 1", es: "MenC — dosis 1", fr: "Méningocoque C — dose 1", pt: "Meningocócica C — dose 1", zh: "C 群脑膜炎球菌疫苗 — 第 1 剂", timing: .months(4)),

        // MARK: 6 months
        .init(id: 710, en: "Influenza — every season (6–59 months)", ru: "Грипп — каждый сезон (6–59 месяцев)", de: "Influenza — jede Saison (6–59 Monate)", es: "Gripe — cada temporada (6-59 meses)", fr: "Grippe — chaque saison (6–59 mois)", pt: "Gripe — cada época (6–59 meses)", zh: "流感疫苗 — 每个流行季（6–59 个月）", timing: .months(6)),

        // MARK: 11 months
        .init(id: 711, en: "Hexavalent (DTaP-IPV-Hib-HepB) — dose 3", ru: "Шестивалентная (АКДС-ИПВ-Хиб-ГепB) — доза 3", de: "Sechsfach (DTaP-IPV-Hib-HepB) — Dosis 3", es: "Hexavalente (DTPa-VPI-Hib-HB) — dosis 3", fr: "Hexavalent (DTCa-VPI-Hib-HépB) — dose 3", pt: "Hexavalente (DTPa-VIP-Hib-HB) — dose 3", zh: "六联疫苗（百白破-脊灰-Hib-乙肝）— 第 3 剂", timing: .months(11)),
        .init(id: 712, en: "Pneumococcal PCV — dose 3", ru: "Пневмококк ПКВ — доза 3", de: "Pneumokokken PCV — Dosis 3", es: "Neumococo VNC — dosis 3", fr: "Pneumocoque PCV — dose 3", pt: "Pneumocócica PCV — dose 3", zh: "肺炎球菌疫苗 PCV — 第 3 剂", timing: .months(11)),

        // MARK: 12 months
        .init(id: 713, en: "Meningococcal B — dose 3", ru: "Менингококк B — доза 3", de: "Meningokokken B — Dosis 3", es: "MenB — dosis 3", fr: "Méningocoque B — dose 3", pt: "Meningocócica B — dose 3", zh: "B 群脑膜炎球菌疫苗 — 第 3 剂", timing: .months(12)),
        .init(id: 714, en: "Meningococcal C — dose 2", ru: "Менингококк C — доза 2", de: "Meningokokken C — Dosis 2", es: "MenC — dosis 2", fr: "Méningocoque C — dose 2", pt: "Meningocócica C — dose 2", zh: "C 群脑膜炎球菌疫苗 — 第 2 剂", timing: .months(12)),
        .init(id: 715, en: "MMR — dose 1", ru: "Корь-краснуха-паротит (КПК) — доза 1", de: "MMR — Dosis 1", es: "Triple vírica (TV) — dosis 1", fr: "ROR — dose 1", pt: "Tríplice viral (SCR) — dose 1", zh: "麻腮风疫苗（MMR）— 第 1 剂", timing: .months(12)),

        // MARK: 15 months
        .init(id: 716, en: "Varicella — dose 1", ru: "Ветряная оспа — доза 1", de: "Varizellen — Dosis 1", es: "Varicela (VVZ) — dosis 1", fr: "Varicelle — dose 1", pt: "Varicela — dose 1", zh: "水痘疫苗 — 第 1 剂", timing: .months(15)),

        // MARK: 3–4 years
        .init(id: 717, en: "MMR — dose 2", ru: "Корь-краснуха-паротит (КПК) — доза 2", de: "MMR — Dosis 2", es: "Triple vírica (TV) — dosis 2", fr: "ROR — dose 2", pt: "Tríplice viral (SCR) — dose 2", zh: "麻腮风疫苗（MMR）— 第 2 剂", timing: .years(3)),
        .init(id: 718, en: "Varicella — dose 2", ru: "Ветряная оспа — доза 2", de: "Varizellen — Dosis 2", es: "Varicela (VVZ) — dosis 2", fr: "Varicelle — dose 2", pt: "Varicela — dose 2", zh: "水痘疫苗 — 第 2 剂", timing: .years(3)),

        // MARK: 6 years
        .init(id: 719, en: "DTaP-IPV — booster", ru: "АКДС-ИПВ — ревакцинация", de: "DTaP-IPV — Auffrischung", es: "DTPa/VPI — refuerzo", fr: "DTCa-VPI — rappel", pt: "DTPa-VIP — reforço", zh: "百白破-脊灰 — 加强针", timing: .years(6)),
    ]
}
