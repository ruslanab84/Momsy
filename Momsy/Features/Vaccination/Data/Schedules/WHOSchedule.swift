import Foundation

/// WHO/EPI essential immunization schedule — the international default.
///
/// IDs are namespaced in the 100+ range so they never collide with custom entries
/// (negative ids) or with future national schedules (which use their own ranges).
enum WHOSchedule {
    static let items: [VaccinationScheduleItem] = [
        // MARK: Birth
        .init(id: 100, en: "BCG (tuberculosis)",            ru: "БЦЖ (туберкулёз)",                de: "BCG (Tuberkulose)",            es: "BCG (tuberculosis)",            fr: "BCG (tuberculose)",             pt: "BCG (tuberculose)", zh: "卡介苗（结核病）",             timing: .atBirth),
        .init(id: 101, en: "Hepatitis B — birth dose",      ru: "Гепатит B — доза при рождении",    de: "Hepatitis B — Geburtsdosis",   es: "Hepatitis B — dosis al nacer",  fr: "Hépatite B — dose à la naissance", pt: "Hepatite B — dose à nascença", zh: "乙肝疫苗 — 出生剂次",  timing: .atBirth),
        .init(id: 102, en: "Polio OPV — birth dose",        ru: "Полиомиелит ОПВ — при рождении",   de: "Polio OPV — Geburtsdosis",     es: "Polio OPV — dosis al nacer",    fr: "Polio VPO — dose à la naissance", pt: "Pólio VOP — dose à nascença", zh: "脊灰减毒活疫苗 OPV — 出生剂次",   timing: .atBirth),

        // MARK: 6 weeks
        .init(id: 103, en: "Pentavalent (DTP-HepB-Hib) — dose 1", ru: "Пентавакцина (АКДС-ГепB-Хиб) — доза 1", de: "Fünffach (DTP-HepB-Hib) — Dosis 1", es: "Pentavalente (DTP-HepB-Hib) — dosis 1", fr: "Pentavalent (DTC-HépB-Hib) — dose 1", pt: "Pentavalente (DTP-HepB-Hib) — dose 1", zh: "五联疫苗（百白破-乙肝-Hib）— 第 1 剂", timing: .weeks(6)),
        .init(id: 104, en: "Polio OPV — dose 1",            ru: "Полиомиелит ОПВ — доза 1",         de: "Polio OPV — Dosis 1",          es: "Polio OPV — dosis 1",           fr: "Polio VPO — dose 1",            pt: "Pólio VOP — dose 1", zh: "脊灰减毒活疫苗 OPV — 第 1 剂",            timing: .weeks(6)),
        .init(id: 105, en: "Pneumococcal PCV — dose 1",     ru: "Пневмококк ПКВ — доза 1",          de: "Pneumokokken PCV — Dosis 1",   es: "Neumococo PCV — dosis 1",       fr: "Pneumocoque PCV — dose 1",      pt: "Pneumocócica PCV — dose 1", zh: "肺炎球菌疫苗 PCV — 第 1 剂",     timing: .weeks(6)),
        .init(id: 106, en: "Rotavirus — dose 1",            ru: "Ротавирус — доза 1",               de: "Rotaviren — Dosis 1",          es: "Rotavirus — dosis 1",           fr: "Rotavirus — dose 1",            pt: "Rotavírus — dose 1", zh: "轮状病毒疫苗 — 第 1 剂",            timing: .weeks(6)),

        // MARK: 10 weeks
        .init(id: 107, en: "Pentavalent (DTP-HepB-Hib) — dose 2", ru: "Пентавакцина (АКДС-ГепB-Хиб) — доза 2", de: "Fünffach (DTP-HepB-Hib) — Dosis 2", es: "Pentavalente (DTP-HepB-Hib) — dosis 2", fr: "Pentavalent (DTC-HépB-Hib) — dose 2", pt: "Pentavalente (DTP-HepB-Hib) — dose 2", zh: "五联疫苗（百白破-乙肝-Hib）— 第 2 剂", timing: .weeks(10)),
        .init(id: 108, en: "Polio OPV — dose 2",            ru: "Полиомиелит ОПВ — доза 2",         de: "Polio OPV — Dosis 2",          es: "Polio OPV — dosis 2",           fr: "Polio VPO — dose 2",            pt: "Pólio VOP — dose 2", zh: "脊灰减毒活疫苗 OPV — 第 2 剂",            timing: .weeks(10)),
        .init(id: 109, en: "Pneumococcal PCV — dose 2",     ru: "Пневмококк ПКВ — доза 2",          de: "Pneumokokken PCV — Dosis 2",   es: "Neumococo PCV — dosis 2",       fr: "Pneumocoque PCV — dose 2",      pt: "Pneumocócica PCV — dose 2", zh: "肺炎球菌疫苗 PCV — 第 2 剂",     timing: .weeks(10)),
        .init(id: 110, en: "Rotavirus — dose 2",            ru: "Ротавирус — доза 2",               de: "Rotaviren — Dosis 2",          es: "Rotavirus — dosis 2",           fr: "Rotavirus — dose 2",            pt: "Rotavírus — dose 2", zh: "轮状病毒疫苗 — 第 2 剂",            timing: .weeks(10)),

        // MARK: 14 weeks
        .init(id: 111, en: "Pentavalent (DTP-HepB-Hib) — dose 3", ru: "Пентавакцина (АКДС-ГепB-Хиб) — доза 3", de: "Fünffach (DTP-HepB-Hib) — Dosis 3", es: "Pentavalente (DTP-HepB-Hib) — dosis 3", fr: "Pentavalent (DTC-HépB-Hib) — dose 3", pt: "Pentavalente (DTP-HepB-Hib) — dose 3", zh: "五联疫苗（百白破-乙肝-Hib）— 第 3 剂", timing: .weeks(14)),
        .init(id: 112, en: "Polio OPV — dose 3",            ru: "Полиомиелит ОПВ — доза 3",         de: "Polio OPV — Dosis 3",          es: "Polio OPV — dosis 3",           fr: "Polio VPO — dose 3",            pt: "Pólio VOP — dose 3", zh: "脊灰减毒活疫苗 OPV — 第 3 剂",            timing: .weeks(14)),
        .init(id: 113, en: "Polio IPV — dose 1",            ru: "Полиомиелит ИПВ — доза 1",         de: "Polio IPV — Dosis 1",          es: "Polio IPV — dosis 1",           fr: "Polio VPI — dose 1",            pt: "Pólio VIP — dose 1", zh: "脊灰灭活疫苗 IPV — 第 1 剂",            timing: .weeks(14)),
        .init(id: 114, en: "Pneumococcal PCV — dose 3",     ru: "Пневмококк ПКВ — доза 3",          de: "Pneumokokken PCV — Dosis 3",   es: "Neumococo PCV — dosis 3",       fr: "Pneumocoque PCV — dose 3",      pt: "Pneumocócica PCV — dose 3", zh: "肺炎球菌疫苗 PCV — 第 3 剂",     timing: .weeks(14)),

        // MARK: 9 months
        .init(id: 115, en: "Measles (MCV) — dose 1",        ru: "Корь (МКВ) — доза 1",              de: "Masern (MCV) — Dosis 1",       es: "Sarampión (MCV) — dosis 1",     fr: "Rougeole (VAR) — dose 1",       pt: "Sarampo (VAS) — dose 1", zh: "麻疹疫苗（MCV）— 第 1 剂",        timing: .months(9)),

        // MARK: 15–18 months
        .init(id: 116, en: "Measles (MCV) — dose 2",        ru: "Корь (МКВ) — доза 2",              de: "Masern (MCV) — Dosis 2",       es: "Sarampión (MCV) — dosis 2",     fr: "Rougeole (VAR) — dose 2",       pt: "Sarampo (VAS) — dose 2", zh: "麻疹疫苗（MCV）— 第 2 剂",        timing: .months(15)),
        .init(id: 117, en: "DTP — booster",                 ru: "АКДС — ревакцинация",              de: "DTP — Auffrischung",           es: "DTP — refuerzo",                fr: "DTC — rappel",                  pt: "DTP — reforço", zh: "百白破 — 加强针",                 timing: .months(18)),
    ]
}
