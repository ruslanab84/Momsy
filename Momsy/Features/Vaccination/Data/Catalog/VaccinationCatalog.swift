import Foundation

enum VaccinationCatalog {
    static let items: [VaccinationScheduleItem] = [
        .init(id: 1,  nameEN: "Hepatitis B — dose 1",          nameRU: "Гепатит B — доза 1",           nameDE: "Hepatitis B — Dosis 1",          ageMonths: 0,  isOptional: false),
        .init(id: 2,  nameEN: "BCG (tuberculosis)",             nameRU: "БЦЖ (туберкулёз)",             nameDE: "BCG (Tuberkulose)",               ageMonths: 0,  isOptional: false),
        .init(id: 3,  nameEN: "Hepatitis B — dose 2",          nameRU: "Гепатит B — доза 2",           nameDE: "Hepatitis B — Dosis 2",          ageMonths: 1,  isOptional: false),
        .init(id: 4,  nameEN: "DTP — dose 1",                  nameRU: "АКДС — доза 1",                nameDE: "DTP — Dosis 1",                  ageMonths: 2,  isOptional: false),
        .init(id: 5,  nameEN: "Polio IPV — dose 1",            nameRU: "Полиомиелит ИПВ — доза 1",     nameDE: "Polio IPV — Dosis 1",            ageMonths: 2,  isOptional: false),
        .init(id: 6,  nameEN: "Pneumococcal PCV — dose 1",     nameRU: "ПКВ (пневмококк) — доза 1",   nameDE: "Pneumokokken PCV — Dosis 1",     ageMonths: 2,  isOptional: false),
        .init(id: 7,  nameEN: "DTP — dose 2",                  nameRU: "АКДС — доза 2",                nameDE: "DTP — Dosis 2",                  ageMonths: 3,  isOptional: false),
        .init(id: 8,  nameEN: "Polio IPV — dose 2",            nameRU: "Полиомиелит ИПВ — доза 2",     nameDE: "Polio IPV — Dosis 2",            ageMonths: 3,  isOptional: false),
        .init(id: 9,  nameEN: "Hib — dose 1",                  nameRU: "Хиб — доза 1",                 nameDE: "Hib — Dosis 1",                  ageMonths: 3,  isOptional: false),
        .init(id: 10, nameEN: "DTP — dose 3",                  nameRU: "АКДС — доза 3",                nameDE: "DTP — Dosis 3",                  ageMonths: 5,  isOptional: false),
        .init(id: 11, nameEN: "Polio IPV — dose 3",            nameRU: "Полиомиелит ИПВ — доза 3",     nameDE: "Polio IPV — Dosis 3",            ageMonths: 5,  isOptional: false),
        .init(id: 12, nameEN: "Hib — dose 2",                  nameRU: "Хиб — доза 2",                 nameDE: "Hib — Dosis 2",                  ageMonths: 5,  isOptional: false),
        .init(id: 13, nameEN: "Pneumococcal PCV — dose 2",     nameRU: "ПКВ (пневмококк) — доза 2",   nameDE: "Pneumokokken PCV — Dosis 2",     ageMonths: 5,  isOptional: false),
        .init(id: 14, nameEN: "Hepatitis B — dose 3",          nameRU: "Гепатит B — доза 3",           nameDE: "Hepatitis B — Dosis 3",          ageMonths: 6,  isOptional: false),
        .init(id: 15, nameEN: "MMR (measles/mumps/rubella)",   nameRU: "КПК (корь/паротит/краснуха)", nameDE: "MMR (Masern/Mumps/Röteln)",       ageMonths: 12, isOptional: false),
        .init(id: 16, nameEN: "Pneumococcal PCV — booster",    nameRU: "ПКВ (пневмококк) — ревакцинация", nameDE: "Pneumokokken PCV — Auffrischung", ageMonths: 15, isOptional: false),
        .init(id: 17, nameEN: "DTP — booster",                 nameRU: "АКДС — ревакцинация",          nameDE: "DTP — Auffrischung",             ageMonths: 18, isOptional: false),
        .init(id: 18, nameEN: "Polio OPV — booster 1",         nameRU: "Полиомиелит ОПВ — ревакц. 1",  nameDE: "Polio OPV — Auffrischung 1",     ageMonths: 18, isOptional: false),
        .init(id: 19, nameEN: "Hib — booster",                 nameRU: "Хиб — ревакцинация",           nameDE: "Hib — Auffrischung",             ageMonths: 18, isOptional: false),
        .init(id: 20, nameEN: "Polio OPV — booster 2",         nameRU: "Полиомиелит ОПВ — ревакц. 2",  nameDE: "Polio OPV — Auffrischung 2",     ageMonths: 20, isOptional: false),
    ]
}
