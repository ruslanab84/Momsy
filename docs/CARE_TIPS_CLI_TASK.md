# CARE TIPS — новый раздел «Tips» во вкладке Doctor

**Приоритет:** P2 (новая фича, не блокер релиза)
**База:** `main`, коммит `c1a5d63` — *Fix account deletion GDPR compliance: outcomes, family scope, member cleanup*
**Целевая ветка:** `feature/care-tips`

---

## 1. Постановка задачи

Во вкладке **Doctor** добавить новый раздел **Tips (Care Guide)** — статическая справочная библиотека рекомендаций по уходу за малышом («после кормления подержать столбиком 10–15 минут», «ABC безопасного сна», «tummy time» и т. д.).

Требования:

- Контент на первом этапе **только на английском**; архитектура должна позволять добавить остальные 6 языков **чистым изменением данных**, без правок View/ViewModel.
- Весь текст проходит через l10n-слой (`LocalizedText` / `L10n`), никаких хардкод-строк в View.
- Дизайн нового экрана **не отличается** от остального приложения: те же токены (`bbCream`, `bbCard`, `bbInk`, `SemanticColor`), те же компоненты (`BBSectionLabel`, `bbCard()`, `bbShadow()`, `DoctorMenuRow`-стиль строк).
- Тексты **оригинальные**, написаны для Momsy. Не копировать формулировки конкурентов (Huckleberry и др.). Смысловая база — общедоступные рекомендации AAP/WHO/NHS, изложенные своими словами в спокойном поддерживающем тоне Momsy.
- Оффлайн-first: ноль сетевых запросов, ноль записей в Firestore, ноль стоимости.

### Что это НЕ

В `Features/Today/` уже есть `DailyTipAlgorithm` / `DailyTipRules` — **динамический** совет дня, генерируемый по контексту (когда кормили, сколько подгузников, фаза скачка). Новая фича — **статическая библиотека**, которую родитель открывает сам и листает. Эти две системы не пересекаются: не переиспользовать `DailyTip`, `TipCategory`, `DailyTipService`.

---

## 2. Архитектура

Паттерн взят из существующего `Features/Vaccination/Data/Schedules/WHOSchedule.swift`: статический каталог доменных моделей со словарём языков и фолбэком на английский.

### Новые файлы

```
Momsy/Core/Localization/
└── LocalizedText.swift                                    [NEW]

Momsy/Features/CareTips/
├── Domain/Models/
│   └── CareTipModels.swift                                [NEW]
├── Data/Catalog/
│   ├── CareTipsCatalog.swift                              [NEW]
│   ├── CareTipsCatalog+Feeding.swift                      [NEW]
│   ├── CareTipsCatalog+Sleep.swift                        [NEW]
│   ├── CareTipsCatalog+Hygiene.swift                      [NEW]
│   ├── CareTipsCatalog+Comfort.swift                      [NEW]
│   ├── CareTipsCatalog+Development.swift                  [NEW]
│   ├── CareTipsCatalog+Safety.swift                       [NEW]
│   └── CareTipsCatalog+Parent.swift                       [NEW]
└── Presentation/
    ├── ViewModel/
    │   └── CareTipsViewModel.swift                        [NEW]
    └── Views/
        ├── CareTipsView.swift                             [NEW]
        └── CareTipDetailView.swift                        [NEW]

MomsyTests/Features/CareTips/
└── CareTipsCatalogTests.swift                             [NEW]
```

### Изменяемые файлы

```
Momsy/Core/Localization/L10n.swift                         [EDIT] +секция в конец
Momsy/Core/DI/AppContainer.swift                           [EDIT] +фабрика
Momsy/Features/Doctor/Presentation/Views/DoctorMenuView.swift [EDIT] +строка меню
```

`PBXFileSystemSynchronizedRootGroup` включён — регистрация новых `.swift` в `project.pbxproj` **не требуется**. Новых SPM-продуктов и entitlements нет.

**Repository / UseCase слои не создаются**: данных для чтения-записи нет, каталог — это иммутабельная константа домена (тот же подход, что у `DevelopmentLeap.catalog` и `WHOSchedule.items`). Создавать пустой `CareTipsRepository` ради симметрии — оверинжиниринг.

---

## 3. ЗАДАЧА 1 — `LocalizedText` / `LocalizedList`

**Новый файл:** `Momsy/Core/Localization/LocalizedText.swift`

Переиспользуемые Core-типы. Благодаря `ExpressibleByStringLiteral` / `ExpressibleByArrayLiteral` авторинг каталога на английском выглядит как обычные строки и массивы, а добавление перевода — это замена литерала на `.init(en:ru:…)` в том же месте, без изменения сигнатур.

```swift
import Foundation

/// A single string that may exist in several languages.
/// Any language that is not authored yet falls back to English.
struct LocalizedText: Sendable, ExpressibleByStringLiteral {
    private let values: [Language: String]

    init(
        en: String,
        ru: String? = nil,
        de: String? = nil,
        es: String? = nil,
        fr: String? = nil,
        pt: String? = nil,
        zh: String? = nil
    ) {
        var map: [Language: String] = [.english: en]
        if let ru { map[.russian] = ru }
        if let de { map[.german] = de }
        if let es { map[.spanish] = es }
        if let fr { map[.french] = fr }
        if let pt { map[.portuguese] = pt }
        if let zh { map[.chinese] = zh }
        values = map
    }

    init(stringLiteral value: String) {
        self.init(en: value)
    }

    func callAsFunction(_ lang: Language) -> String {
        values[lang] ?? values[.english] ?? ""
    }

    func isTranslated(into lang: Language) -> Bool {
        values[lang] != nil
    }
}

/// A bullet list that may exist in several languages.
struct LocalizedList: Sendable, ExpressibleByArrayLiteral {
    private let values: [Language: [String]]

    init(
        en: [String],
        ru: [String]? = nil,
        de: [String]? = nil,
        es: [String]? = nil,
        fr: [String]? = nil,
        pt: [String]? = nil,
        zh: [String]? = nil
    ) {
        var map: [Language: [String]] = [.english: en]
        if let ru { map[.russian] = ru }
        if let de { map[.german] = de }
        if let es { map[.spanish] = es }
        if let fr { map[.french] = fr }
        if let pt { map[.portuguese] = pt }
        if let zh { map[.chinese] = zh }
        values = map
    }

    init(arrayLiteral elements: String...) {
        self.init(en: elements)
    }

    func callAsFunction(_ lang: Language) -> [String] {
        values[lang] ?? values[.english] ?? []
    }

    func isTranslated(into lang: Language) -> Bool {
        values[lang] != nil
    }
}
```

---

## 4. ЗАДАЧА 2 — доменная модель

**Новый файл:** `Momsy/Features/CareTips/Domain/Models/CareTipModels.swift`

```swift
import Foundation

enum CareTipCategory: String, CaseIterable, Identifiable, Sendable {
    case feeding
    case sleep
    case hygiene
    case comfort
    case development
    case safety
    case parent

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .feeding:     return "fork.knife"
        case .sleep:       return "moon.zzz.fill"
        case .hygiene:     return "drop.fill"
        case .comfort:     return "heart.fill"
        case .development: return "figure.child"
        case .safety:      return "shield.lefthalf.filled"
        case .parent:      return "person.2.fill"
        }
    }

    var semanticColor: SemanticColor {
        switch self {
        case .feeding:     return .coral
        case .sleep:       return .lilac
        case .hygiene:     return .sky
        case .comfort:     return .butter
        case .development: return .mint
        case .safety:      return .rose
        case .parent:      return .lilac
        }
    }

    func title(_ lang: Language) -> String {
        L10n(lang).careTipsCategoryTitle(self)
    }
}

struct CareTip: Identifiable, Sendable {
    let id: Int
    let category: CareTipCategory
    let icon: String
    /// Inclusive age window in months. `0...24` means "the whole first two years".
    let ageFromMonths: Int
    let ageToMonths: Int

    let title: LocalizedText
    let summary: LocalizedText
    let whatToDo: LocalizedList
    let whyItMatters: LocalizedText
    let commonMistakes: LocalizedList
    let whenToCallDoctor: LocalizedList

    init(
        id: Int,
        category: CareTipCategory,
        icon: String,
        ageFrom: Int,
        ageTo: Int,
        title: LocalizedText,
        summary: LocalizedText,
        whatToDo: LocalizedList,
        whyItMatters: LocalizedText,
        commonMistakes: LocalizedList,
        whenToCallDoctor: LocalizedList
    ) {
        self.id = id
        self.category = category
        self.icon = icon
        self.ageFromMonths = ageFrom
        self.ageToMonths = ageTo
        self.title = title
        self.summary = summary
        self.whatToDo = whatToDo
        self.whyItMatters = whyItMatters
        self.commonMistakes = commonMistakes
        self.whenToCallDoctor = whenToCallDoctor
    }

    func matches(ageMonths: Int) -> Bool {
        ageMonths >= ageFromMonths && ageMonths <= ageToMonths
    }

    func ageLabel(_ lang: Language) -> String {
        L10n(lang).careTipAgeRange(from: ageFromMonths, to: ageToMonths)
    }

    func matches(query: String, lang: Language) -> Bool {
        guard !query.isEmpty else { return true }
        let haystack = [title(lang), summary(lang)].joined(separator: " ")
        return haystack.range(
            of: query,
            options: [.caseInsensitive, .diacriticInsensitive]
        ) != nil
    }
}
```

---

## 5. ЗАДАЧА 3 — каталог

**Новый файл:** `Momsy/Features/CareTips/Data/Catalog/CareTipsCatalog.swift`

```swift
import Foundation

/// Static, offline care-guide content shown in Doctor → Tips.
///
/// ID ranges are namespaced per category so new entries never renumber existing ones:
/// feeding 1000+, sleep 1100+, hygiene 1200+, comfort 1300+,
/// development 1400+, safety 1500+, parent 1600+.
///
/// v1 is authored in English only. Adding a language is a pure data change:
/// replace a string literal with `.init(en: …, ru: …)` in place.
enum CareTipsCatalog {
    static let all: [CareTip] =
        feeding + sleep + hygiene + comfort + development + safety + parent

    static func tips(in category: CareTipCategory) -> [CareTip] {
        all.filter { $0.category == category }
    }

    static func tip(id: Int) -> CareTip? {
        all.first { $0.id == id }
    }
}
```

> **Тон контента.** Спокойный, поддерживающий, без давления и алармизма. Обращение — «your baby», не «the infant». Никаких дозировок препаратов, никаких диагнозов. Каждая карточка заканчивается блоком «When to call your doctor».

### 5.1 `CareTipsCatalog+Feeding.swift`

```swift
import Foundation

extension CareTipsCatalog {
    static let feeding: [CareTip] = [

        CareTip(
            id: 1001, category: .feeding, icon: "arrow.up.circle.fill", ageFrom: 0, ageTo: 6,
            title: "Hold your baby upright after every feed",
            summary: "Ten to fifteen minutes vertical lets swallowed air come up before milk does",
            whatToDo: [
                "Lift your baby onto your shoulder so their chest rests against you and their chin clears your shoulder.",
                "Support the head and neck with one hand; keep the spine straight rather than curled.",
                "Stay upright for 10–15 minutes after a full feed, a little longer if your baby is prone to spitting up.",
                "Pat or stroke the back gently and rhythmically — pressure is never needed.",
                "Swap to a sitting-on-your-lap hold if your arm tires; the point is the vertical spine, not the exact position."
            ],
            whyItMatters: "Newborns swallow air with almost every feed, and the valve between the stomach and the food pipe is still soft and easily opened. When your baby lies flat straight after a feed, that trapped air pushes milk back up with it. Staying upright lets the air rise above the milk and escape on its own, which usually means less spitting up, fewer squirming episodes and a calmer settle afterwards.",
            commonMistakes: [
                "Putting the baby straight down because they fell asleep at the breast or bottle.",
                "Curling the body forward so the tummy is compressed — this makes reflux more likely, not less.",
                "Firm patting in the belief that harder means faster.",
                "Using a car seat or bouncer as the upright position — the slouched angle folds the tummy."
            ],
            whenToCallDoctor: [
                "Spit-up is green, yellow, or contains blood.",
                "Your baby arches, screams, or refuses feeds regularly after eating.",
                "Weight gain slows or nappies become noticeably drier.",
                "Milk comes back forcefully and repeatedly, not as a gentle dribble."
            ]
        ),

        CareTip(
            id: 1002, category: .feeding, icon: "hands.sparkles.fill", ageFrom: 0, ageTo: 6,
            title: "Three burping positions and when each one works",
            summary: "If one hold does not work in five minutes, change position instead of patting longer",
            whatToDo: [
                "Over the shoulder: chest against you, chin above the shoulder — the classic first attempt.",
                "Sitting on your lap: support the chin and jaw with your palm (never the throat), lean the body slightly forward, pat between the shoulder blades.",
                "Face down across your lap: tummy on your thighs, head slightly higher than the body, one hand steadying the back.",
                "Give each position about five minutes, then switch rather than continuing with the same one.",
                "Burp mid-feed too — when you swap sides, or after roughly 60 ml from a bottle."
            ],
            whyItMatters: "Air sits wherever the stomach happens to be shaped at that moment, so a hold that releases a burp today may do nothing tomorrow. Changing the angle moves the bubble towards the top of the stomach where it can escape. Mid-feed burping helps more than a single attempt at the end, because a smaller stomach releases air more easily than a full one.",
            commonMistakes: [
                "Patting for twenty minutes in one position with no result.",
                "Supporting the throat instead of the jaw in the sitting hold.",
                "Assuming every feed must end with an audible burp — many do not, and that is fine.",
                "Waiting until the baby is already crying with discomfort before starting."
            ],
            whenToCallDoctor: [
                "Your baby seems to be in pain during or after most feeds despite burping.",
                "Feeds regularly end in inconsolable crying that lasts over an hour.",
                "You notice wheezing, coughing, or colour change during feeds."
            ]
        ),

        CareTip(
            id: 1003, category: .feeding, icon: "eye.fill", ageFrom: 0, ageTo: 4,
            title: "Catch hunger cues before the crying starts",
            summary: "Crying is a late signal — feeding at the early cues is calmer for everyone",
            whatToDo: [
                "Watch for early cues: stirring, mouth opening, turning the head side to side, hands moving to the face.",
                "Mid cues: stretching, increasing body movement, hands going into the mouth, small fussing sounds.",
                "Late cues: full crying, a red face, agitated jerky movements.",
                "Offer a feed at the early or mid stage — latching is easier and the feed is usually more efficient.",
                "If crying has already started, calm first: skin-to-skin, gentle rocking, a quiet voice, then offer."
            ],
            whyItMatters: "A crying baby has an arched tongue and a tense jaw, which makes a deep latch physically harder to achieve. Feeds that start from crying tend to be shorter, more frantic, and involve swallowing more air. Reading the early cues also builds your confidence in your own observations, which is worth as much as the smoother feed itself.",
            commonMistakes: [
                "Feeding strictly by the clock and ignoring what the baby is showing.",
                "Reading every mouth movement as hunger — babies also mouth their hands to self-soothe and explore.",
                "Using a dummy to postpone a clear feeding cue in the early weeks."
            ],
            whenToCallDoctor: [
                "Your baby is consistently too sleepy to show hunger cues and has to be woken for every feed.",
                "Fewer than six wet nappies a day after the first week.",
                "Feeding cues appear constantly and feeds never seem to satisfy."
            ]
        ),

        CareTip(
            id: 1004, category: .feeding, icon: "drop.fill", ageFrom: 0, ageTo: 6,
            title: "Paced bottle feeding: keep the bottle horizontal",
            summary: "Let your baby set the rhythm instead of letting gravity empty the bottle",
            whatToDo: [
                "Hold your baby semi-upright, head above the tummy — not lying flat.",
                "Keep the bottle roughly horizontal, filling only the tip of the teat with milk.",
                "Touch the teat to the lips and wait for the mouth to open rather than pushing it in.",
                "Pause every 20–30 seconds by tipping the bottle down slightly; let your baby breathe and decide to continue.",
                "Aim for the feed to last 10–20 minutes, and stop when your baby turns away — even with milk left."
            ],
            whyItMatters: "With a vertical bottle, milk flows whether or not the baby is actively sucking, so they must keep swallowing to avoid choking. That overrides the natural pause-and-breathe rhythm they use at the breast, and it bypasses the fullness signal, which is why fast bottle feeds often end with wind, spit-up and a distressed baby. Pacing gives the appetite feedback loop time to work.",
            commonMistakes: [
                "Propping the bottle on a cushion and leaving the baby to it — a choking risk, never safe.",
                "Encouraging the last few millilitres after the baby has clearly stopped.",
                "Moving up a teat size to shorten feeds.",
                "Feeding with the baby lying flat on their back."
            ],
            whenToCallDoctor: [
                "Milk regularly leaks from the corners of the mouth, or your baby gulps and splutters.",
                "Feeds take over 40 minutes and leave your baby exhausted.",
                "Coughing, gagging, or colour change during bottle feeds."
            ]
        ),

        CareTip(
            id: 1005, category: .feeding, icon: "timer", ageFrom: 0, ageTo: 12,
            title: "Preparing and storing formula safely",
            summary: "Fresh is safest: make each bottle when you need it and discard leftovers",
            whatToDo: [
                "Wash hands, then clean and sterilise bottles and teats for the whole first year.",
                "Boil fresh water and let it cool for no more than 30 minutes before mixing, so it is still hot enough to kill bacteria in the powder.",
                "Add water to the bottle first, then the exact number of level scoops stated on the tin.",
                "Cool quickly under a running cold tap, holding the lid on, and test on your inner wrist — it should feel lukewarm, not warm.",
                "Throw away anything left in the bottle within two hours of the feed starting."
            ],
            whyItMatters: "Formula powder is not a sterile product, and a warm made-up bottle is an excellent growth medium. Two things protect your baby: water hot enough to kill bacteria at the point of mixing, and a short window between making and drinking. Scoop accuracy matters just as much — over-concentrated formula strains immature kidneys, and over-diluted formula quietly holds back weight gain.",
            commonMistakes: [
                "Packing or heaping the scoop instead of levelling it off.",
                "Making up a batch of bottles for the day and leaving them at room temperature.",
                "Reheating a partly drunk bottle for later.",
                "Using a microwave, which creates hot spots that can scald the mouth."
            ],
            whenToCallDoctor: [
                "Vomiting, diarrhoea, or fever after a feed.",
                "Your baby refuses formula they normally accept, or develops a rash after feeds.",
                "Weight gain slows despite normal feed volumes."
            ]
        ),

        CareTip(
            id: 1006, category: .feeding, icon: "arrow.uturn.up", ageFrom: 0, ageTo: 6,
            title: "Spit-up or vomiting: how to tell them apart",
            summary: "A relaxed dribble is normal; forceful, distressed, or coloured is not",
            whatToDo: [
                "Look at the force: spit-up rolls out of the mouth, vomit is expelled with effort.",
                "Look at your baby: after spit-up they carry on as if nothing happened; after vomiting they are usually upset.",
                "Look at the colour: milky white or slightly curdled is expected; green, yellow, brown or blood-streaked is not.",
                "Note the volume — a tablespoon spreads widely on a muslin and often looks like far more than it is.",
                "Log episodes in Momsy so you can show a pattern rather than a memory at the next appointment."
            ],
            whyItMatters: "Around half of all babies spit up in the first months, simply because the ring of muscle at the top of the stomach is still maturing. That is a laundry problem, not a medical one, as long as your baby is comfortable and gaining weight. Vomiting is a different event with different causes, so separating the two in your own mind saves a lot of unnecessary worry — and makes the genuinely concerning episodes stand out.",
            commonMistakes: [
                "Cutting feed volumes because of frequent spit-up, which can affect weight gain.",
                "Switching formula repeatedly without medical advice.",
                "Judging severity by how large the stain looks.",
                "Adding thickeners or cereal to bottles without a doctor's guidance."
            ],
            whenToCallDoctor: [
                "Vomit is green or yellow, contains blood, or looks like coffee grounds.",
                "Vomiting is forceful and repeated after most feeds.",
                "Signs of dehydration: dry mouth, sunken fontanelle, far fewer wet nappies, unusual drowsiness.",
                "Vomiting together with fever, a swollen tummy, or refusal to feed."
            ]
        ),

        CareTip(
            id: 1007, category: .feeding, icon: "fork.knife", ageFrom: 5, ageTo: 8,
            title: "Starting solids: read your baby, not the calendar",
            summary: "Around six months, and only when all three readiness signs are there",
            whatToDo: [
                "Check the three signs together: sitting up with little support, steady head and neck control, and coordinated reaching for food and bringing it to the mouth.",
                "Start with a single food at a time, offered once a day at a calm moment when your baby is not overly hungry.",
                "Keep milk as the main source of nutrition — early solids are practice, not replacement calories.",
                "Expect most of the first meals to end up on the face, the bib and the floor. That is the process working.",
                "Log new foods and any reactions in Momsy's Food Diary."
            ],
            whyItMatters: "The readiness signs exist because swallowing solid food safely depends on trunk control and on the tongue-thrust reflex fading, not on a date. Starting before those are in place raises the risk of choking and rarely helps sleep, despite the folklore. Starting well after six months can make new textures harder to accept and leaves iron stores unsupported.",
            commonMistakes: [
                "Adding cereal to bottles in the hope of longer nights.",
                "Judging readiness by weight or by how interested the baby seems in watching you eat.",
                "Introducing several new foods on the same day, which hides the source of any reaction.",
                "Treating a screwed-up face as rejection — new tastes often need many exposures."
            ],
            whenToCallDoctor: [
                "Your baby cannot sit with support or hold their head steady at six months.",
                "Repeated gagging that turns into silent choking, or coughing that does not settle.",
                "Any rash, swelling, vomiting or breathing change after a new food.",
                "Consistent refusal of all solids by eight months."
            ]
        ),

        CareTip(
            id: 1008, category: .feeding, icon: "moon.stars.fill", ageFrom: 0, ageTo: 3,
            title: "Evening cluster feeding is normal, not a sign of low supply",
            summary: "Back-to-back feeds between late afternoon and bedtime are a phase, not a problem",
            whatToDo: [
                "Expect clusters most often in the late afternoon and evening, and around growth spurts.",
                "Set yourself up before it starts: water, snacks, a charged phone, a comfortable seat.",
                "Offer whenever your baby asks rather than trying to stretch intervals during the cluster.",
                "Hand the baby over between feeds if a co-parent is around — the feeding parent needs the breaks more than the cuddles.",
                "Check the reassuring signs: enough wet nappies, steady weight gain, and periods of alert calm during the day."
            ],
            whyItMatters: "Milk fat content and volume vary naturally through the day, and evening feeds tend to be shorter and less satisfying individually — so babies simply take more of them. Frequent evening stimulation also signals the breast to make more milk for the following day. Knowing the pattern is expected takes away the two things that make it hard: the fear that something is wrong, and the sense that it will never end.",
            commonMistakes: [
                "Reading the cluster as proof that milk has run out and topping up in panic.",
                "Timing feeds and enforcing intervals during the cluster window.",
                "Assuming a baby who cannot settle in the evening is simply hungry rather than overtired."
            ],
            whenToCallDoctor: [
                "Fewer than six wet nappies a day after the first week.",
                "No weight gain over two weeks, or weight loss.",
                "Your baby is hard to rouse, unusually floppy, or feeds weakly.",
                "Feeding is painful for you, or nipples are cracked and bleeding."
            ]
        )
    ]
}
```

### 5.2 `CareTipsCatalog+Sleep.swift`

```swift
import Foundation

extension CareTipsCatalog {
    static let sleep: [CareTip] = [

        CareTip(
            id: 1101, category: .sleep, icon: "bed.double.fill", ageFrom: 0, ageTo: 12,
            title: "The ABC of safe sleep: Alone, on the Back, in a Cot",
            summary: "The single most protective habit of the first year, for every sleep",
            whatToDo: [
                "Alone: your baby sleeps on their own surface, with nobody and nothing else on it.",
                "Back: on the back for every nap and every night, until they roll both ways by themselves.",
                "Cot: a cot, crib or moses basket that meets current safety standards.",
                "Apply it to every sleep, including short daytime naps and sleeps away from home.",
                "Make sure everyone who ever settles your baby — partner, grandparents, nanny — follows the same three rules."
            ],
            whyItMatters: "Back sleeping is the change most strongly associated with the fall in sudden infant death rates worldwide. On the back, the airway stays open and the swallowing reflex is better positioned to protect it, which is also why healthy babies do not choke when they sleep this way. The value of the rule comes from consistency: occasional exceptions, including at other people's homes, are where the risk concentrates.",
            commonMistakes: [
                "Side sleeping as a compromise — it is unstable and the baby can roll to the front.",
                "Front sleeping for naps because the baby settles better that way.",
                "Different rules for daytime naps than for the night.",
                "Assuming a baby who has rolled once is ready to sleep on their front."
            ],
            whenToCallDoctor: [
                "Your baby is very unsettled on their back and has been diagnosed with reflux — ask before changing anything.",
                "Any breathing pause, colour change, or floppiness during sleep — seek help immediately.",
                "A health professional has advised a different position for a medical reason; follow their instruction, not this card."
            ]
        ),

        CareTip(
            id: 1102, category: .sleep, icon: "checkmark.shield.fill", ageFrom: 0, ageTo: 12,
            title: "A firm, flat, empty sleep surface",
            summary: "Nothing in the cot but a fitted sheet and your baby",
            whatToDo: [
                "Use a firm, flat mattress that fits the cot frame with no gaps at the edges.",
                "Cover it with one well-fitted sheet and nothing else.",
                "Remove pillows, duvets, loose blankets, cot bumpers, positioners, wedges and soft toys.",
                "Use a sleeping bag or a light tucked blanket that reaches no higher than the chest, with feet at the foot of the cot.",
                "Keep the cot away from cords, blind pulls, and anything hanging within reach."
            ],
            whyItMatters: "A soft or cluttered surface can mould around the face or let a baby rebreathe their own exhaled air, and young babies cannot reliably move their head away from an obstruction. Cot bumpers and sleep positioners were designed to solve problems that a correctly sized cot does not have, and both have caused harm. The safest cot looks almost empty, which feels wrong to most parents and is exactly right.",
            commonMistakes: [
                "Adding a comforter or muslin 'just for naps'.",
                "A mattress topper or extra padding for comfort.",
                "A duvet or pillow in the first year.",
                "Letting the baby sleep on a sofa, armchair or beanbag with an adult."
            ],
            whenToCallDoctor: [
                "Your baby cannot settle at all on a firm flat surface after the newborn weeks.",
                "Reflux is severe enough that you are considering a wedge or an incline — ask first.",
                "You find your baby with bedding over the face, even once."
            ]
        ),

        CareTip(
            id: 1103, category: .sleep, icon: "house.fill", ageFrom: 0, ageTo: 6,
            title: "Share a room, not a bed, for the first six months",
            summary: "Same room, separate surface — close enough to hear, safe enough to sleep",
            whatToDo: [
                "Place the cot, crib or bedside sleeper within arm's reach of your bed.",
                "Keep this arrangement for at least the first six months, including naps if you are in the room.",
                "Feed in bed if you need to, but move your baby back to their own surface before you sleep.",
                "If you might fall asleep while feeding, clear the bed of pillows and duvets first as a precaution.",
                "Never sleep with your baby on a sofa or armchair — this carries a much higher risk than a bed."
            ],
            whyItMatters: "Room-sharing is associated with a lower risk of sudden infant death, and it makes night feeds far less exhausting because nobody has to cross the house. Bed-sharing is a different thing: adult bedding, mattress softness and the presence of another body change the picture. Separating the two ideas lets you keep the benefit of closeness without the associated risk.",
            commonMistakes: [
                "Moving the baby to their own room early because they seem noisy sleepers.",
                "Falling asleep on the sofa during night feeds.",
                "Bed-sharing after alcohol, sedating medication, or extreme exhaustion.",
                "A bedside sleeper that is not securely fixed, leaving a gap against the adult mattress."
            ],
            whenToCallDoctor: [
                "Your baby was premature or had a low birth weight — ask about additional precautions.",
                "You find yourself repeatedly falling asleep while feeding — say so; there are safer arrangements.",
                "Snoring, pauses in breathing, or noisy laboured breathing during sleep."
            ]
        ),

        CareTip(
            id: 1104, category: .sleep, icon: "thermometer.medium", ageFrom: 0, ageTo: 12,
            title: "Room temperature and how to dress for sleep",
            summary: "Aim for 18–21 °C and check the chest, not the hands",
            whatToDo: [
                "Keep the sleep room between about 18 and 21 °C where you can.",
                "Dress your baby in one more layer than you are comfortable in, counting the sleeping bag as a layer.",
                "Check temperature by slipping two fingers onto the chest or the back of the neck.",
                "Use a lighter sleeping bag in summer and a warmer one in winter rather than adding loose blankets.",
                "Remove hats and hoods indoors — babies release heat through the head."
            ],
            whyItMatters: "Overheating is a recognised risk factor for sudden infant death, and babies cannot take off a layer or push away a blanket the way an adult can. Cool hands and feet are normal for months and are a poor guide, because circulation to the extremities is still developing. The chest tells you the truth: it should feel warm and dry, never hot or clammy.",
            commonMistakes: [
                "Adding layers because the hands feel cold.",
                "Leaving a hat on for indoor sleep.",
                "A hot water bottle or electric blanket in the cot.",
                "Placing the cot next to a radiator or in direct sunlight."
            ],
            whenToCallDoctor: [
                "Your baby is sweating, flushed, or breathing rapidly during sleep.",
                "The chest feels hot and clammy even after removing a layer.",
                "A fever appears alongside unusual drowsiness or refusal to feed."
            ]
        ),

        CareTip(
            id: 1105, category: .sleep, icon: "moon.fill", ageFrom: 0, ageTo: 4,
            title: "Swaddling — and stopping at the first sign of rolling",
            summary: "Snug at the arms, loose at the hips, and finished before rolling starts",
            whatToDo: [
                "Use a thin breathable fabric or a purpose-made swaddle, never a heavy blanket.",
                "Keep it firm across the chest but loose enough to slide two fingers under the top edge.",
                "Leave plenty of room at the hips so the legs can bend up and out.",
                "Always place a swaddled baby on their back, never on the side or front.",
                "Stop swaddling completely at the first sign of rolling — usually somewhere between two and four months. Move to a sleeping bag with arms free."
            ],
            whyItMatters: "Swaddling dampens the startle reflex that wakes newborns from light sleep, which is why it often buys everyone a longer stretch. The danger point is rolling: a swaddled baby who turns onto their front cannot use their arms to lift or turn their head. Hip room matters too, because tightly straightened legs can interfere with normal hip development in the early months.",
            commonMistakes: [
                "Wrapping the legs straight and tight.",
                "Continuing to swaddle after the first roll because it still helps sleep.",
                "Swaddling on top of thick clothing, which risks overheating.",
                "Covering the neck or chin with the top edge of the fabric."
            ],
            whenToCallDoctor: [
                "You hear a click from the hips, or the legs seem to move unevenly.",
                "Your baby overheats when swaddled even in light layers.",
                "Your baby rolls while swaddled — stop immediately and mention it at the next check-up."
            ]
        ),

        CareTip(
            id: 1106, category: .sleep, icon: "clock.fill", ageFrom: 0, ageTo: 12,
            title: "Wake windows and the overtired trap",
            summary: "Watch the clock and the baby — a short awake stretch prevents a long fight",
            whatToDo: [
                "Use rough guides: about 45–60 minutes awake for a newborn, 1.5–2 hours around 3–4 months, 2–3 hours by 6 months, 3–4 hours near a year.",
                "Start winding down at the first tired cues — a fixed stare, red eyebrows, ear pulling, sudden clumsiness in movement.",
                "Treat the ranges as a starting point and adjust to your own baby over a week of observation.",
                "Track sleep in Momsy for a few days to see the real pattern rather than the remembered one.",
                "Shorten the wake window rather than lengthening it when settling has been difficult."
            ],
            whyItMatters: "When a baby stays awake past their limit, the body releases stress hormones to keep going, and those same hormones then make falling asleep harder and staying asleep shorter. That is the counter-intuitive part of infant sleep: an overtired baby fights sleep more, not less. Catching the window early is usually the difference between a five-minute settle and forty-five minutes of crying.",
            commonMistakes: [
                "Keeping the baby up longer in the hope of a better night.",
                "Following a chart from the internet instead of your own baby's signals.",
                "Missing the earliest cues and waiting for eye rubbing or crying.",
                "Expecting the same window every time of day — the first one of the morning is usually shortest."
            ],
            whenToCallDoctor: [
                "Your baby sleeps far more or far less than the guides over several weeks and seems unwell with it.",
                "Sleep is constantly broken by pain, coughing, or laboured breathing.",
                "You are worried about development alongside unusual sleep patterns."
            ]
        ),

        CareTip(
            id: 1107, category: .sleep, icon: "sparkles", ageFrom: 2, ageTo: 12,
            title: "Build a twenty-minute bedtime routine",
            summary: "The same short sequence every night becomes a signal your baby can read",
            whatToDo: [
                "Choose three or four steps and keep the order fixed: for example bath, sleeping bag, feed, one short song.",
                "Keep the whole thing to about twenty minutes — long routines drift past the tired window.",
                "Dim the lights and lower your voice from the first step onwards.",
                "Finish in the room where your baby will sleep.",
                "Use the same shortened version away from home so the signal still works when everything else is unfamiliar."
            ],
            whyItMatters: "Babies cannot tell time, but they are excellent at recognising sequences. A repeated pattern of dimming light, a familiar smell and a predictable order tells the body what is coming, and melatonin release follows the cue. The routine is doing something real; it is not a superstition. Consistency matters far more than the specific contents, which is why simple routines usually outperform elaborate ones.",
            commonMistakes: [
                "Changing the order depending on who is putting the baby down.",
                "Screens or bright overhead light during the wind-down.",
                "Starting the routine only after the baby is already overtired.",
                "Abandoning the routine on holiday or when visiting family."
            ],
            whenToCallDoctor: [
                "Bedtime is consistently distressing for months despite a stable routine.",
                "Your baby wakes screaming and cannot be comforted, night after night.",
                "You are running out of resources to cope with the nights — say this out loud to your doctor or health visitor."
            ]
        )
    ]
}
```

### 5.3 `CareTipsCatalog+Hygiene.swift`

```swift
import Foundation

extension CareTipsCatalog {
    static let hygiene: [CareTip] = [

        CareTip(
            id: 1201, category: .hygiene, icon: "bandage.fill", ageFrom: 0, ageTo: 2,
            title: "Umbilical cord care: clean, dry and uncovered",
            summary: "Air is the main treatment — the stump falls off on its own in one to three weeks",
            whatToDo: [
                "Leave the stump exposed to air as much as possible.",
                "Fold the nappy down below the stump so it never rubs or traps moisture.",
                "Keep it dry: sponge baths until it has fallen off and the base has healed.",
                "If it gets soiled, clean with plain water and let it air-dry completely.",
                "Let it detach by itself — never pull, even if it is hanging by a thread."
            ],
            whyItMatters: "The stump is dead tissue that dries and separates naturally, and the drier it stays the faster that happens. Old routines involving alcohol or antiseptic have largely been dropped because they slow separation without reducing infection in healthy babies. A little dried blood or a slightly unpleasant smell in the final days is expected as it separates.",
            commonMistakes: [
                "Covering the stump with the nappy waistband.",
                "Applying creams, powders, or antiseptic without being told to.",
                "Full bath immersion before separation.",
                "Helping it along when it seems ready to come off."
            ],
            whenToCallDoctor: [
                "Redness spreading onto the skin around the base.",
                "Pus, a foul discharge, or ongoing bleeding.",
                "Your baby cries when the area is touched, or develops a fever.",
                "The stump has not come away by three weeks."
            ]
        ),

        CareTip(
            id: 1202, category: .hygiene, icon: "drop.fill", ageFrom: 0, ageTo: 3,
            title: "Bathing a newborn: short, warm and not every day",
            summary: "Two or three baths a week at around 37 °C is plenty for new skin",
            whatToDo: [
                "Check the water with your elbow or a thermometer — around 37 °C, comfortably warm rather than hot.",
                "Keep baths to five or ten minutes and fill the water to about 10–13 cm.",
                "Gather everything first: towel, clean nappy, clothes, water. Never step away, not for a second.",
                "Support the head and neck with one forearm and hold the outer arm or shoulder with that hand.",
                "Use plain water in the early weeks, or a small amount of unperfumed baby wash. Top-and-tail on the days between baths."
            ],
            whyItMatters: "Newborn skin is thinner than adult skin and is still building its protective barrier, so frequent washing and fragranced products strip more than they clean. Two or three baths a week keeps the skin comfortable while the nappy area and face — the parts that actually get dirty — are cleaned daily. Short baths also avoid the rapid heat loss that leaves babies chilled and unsettled afterwards.",
            commonMistakes: [
                "Testing the water with a hand, which is far less sensitive than an elbow.",
                "Daily baths with soap in the first weeks.",
                "Bath seats or rings used as a reason to look away.",
                "Bathing straight after a feed, which often ends in spit-up."
            ],
            whenToCallDoctor: [
                "Persistent dry, cracked or weeping patches that do not improve.",
                "A rash that spreads after bathing.",
                "Your baby becomes cold and mottled during or after baths."
            ]
        ),

        CareTip(
            id: 1203, category: .hygiene, icon: "wind", ageFrom: 0, ageTo: 24,
            title: "Preventing nappy rash: air time and a barrier",
            summary: "Change often, dry thoroughly, and let the skin breathe once a day",
            whatToDo: [
                "Change as soon as you notice a wet or dirty nappy, and at least every two to three hours in the early months.",
                "Clean with water and cotton wool or fragrance-free wipes, front to back.",
                "Pat completely dry — moisture left in the creases is what starts most rashes.",
                "Apply a thin layer of barrier cream on clean dry skin if the area looks pink.",
                "Give ten minutes of nappy-free time on a towel each day."
            ],
            whyItMatters: "Nappy rash is mostly a moisture problem: wet skin softens, friction breaks the surface, and the ammonia from urine irritates what is left. Air time and thorough drying address the cause directly, which is why they work better than any cream. A barrier ointment then keeps the next wet nappy off skin that is already sore.",
            commonMistakes: [
                "Scrubbing sore skin instead of patting it.",
                "A thick layer of cream over damp skin, which seals the moisture in.",
                "Fragranced or alcohol-based wipes on broken skin.",
                "Talcum powder — it can be inhaled and does not help."
            ],
            whenToCallDoctor: [
                "The rash has bright red patches with small spots spreading beyond the edges — this can be thrush.",
                "Blisters, open sores, or areas of raw weeping skin.",
                "No improvement after three days of good care.",
                "Rash plus fever or an unsettled, unwell baby."
            ]
        ),

        CareTip(
            id: 1204, category: .hygiene, icon: "scissors", ageFrom: 0, ageTo: 24,
            title: "Trimming tiny nails without the drama",
            summary: "Cut during sleep, follow the natural shape, and file the corners",
            whatToDo: [
                "Choose a time when your baby is deeply asleep or relaxed after a bath.",
                "Press the fingertip pad gently away from the nail before you cut.",
                "Cut fingernails straight across following the curve, and toenails straight across with no rounding at the corners.",
                "Smooth the edges with a soft emery board — that is what stops the scratching.",
                "Expect to trim fingernails roughly weekly and toenails every few weeks."
            ],
            whyItMatters: "Newborn nails are soft and grow surprisingly fast, and sharp edges leave scratches on the face within hours. The reason to file rather than cut short is that the nail bed sits very close to the free edge in babies, so cutting deep is both painful and an infection risk. Rounded toenail corners are the main cause of ingrown nails later.",
            commonMistakes: [
                "Biting the nails off — the adult mouth carries bacteria into any small tear.",
                "Cutting too short in the hope of going longer between trims.",
                "Rounding toenail corners.",
                "Scratch mittens used permanently, which limits the hand exploration babies need."
            ],
            whenToCallDoctor: [
                "Redness, swelling or pus around a nail fold.",
                "An ingrown toenail that does not settle.",
                "A cut that keeps bleeding after a few minutes of gentle pressure."
            ]
        ),

        CareTip(
            id: 1205, category: .hygiene, icon: "nose.fill", ageFrom: 0, ageTo: 24,
            title: "Nose and ear care: clean the outside only",
            summary: "Saline and a soft cloth — nothing goes inside the nostril or ear canal",
            whatToDo: [
                "Wipe the outer ear and the folds behind it with a damp cloth, then dry.",
                "For a blocked nose, put one or two saline drops in each nostril and wait a minute.",
                "Clear softened mucus with a bulb syringe or nasal aspirator, or let your baby sneeze it out.",
                "Try saline about ten minutes before a feed, so your baby can breathe while sucking.",
                "Leave earwax alone — it moves out of the canal by itself."
            ],
            whyItMatters: "Babies breathe mainly through the nose for the first months, so even a modest blockage disrupts feeding and sleep more than it would in an adult. Saline thins mucus so it can move; it does not medicate anything, which is why it is safe to repeat. Cotton buds push wax deeper and can damage a very short, delicate ear canal, so the rule is simple: nothing smaller than your fingertip goes in.",
            commonMistakes: [
                "Cotton buds inside the nostril or ear canal.",
                "Ear candles, which are ineffective and carry a burn risk.",
                "Aggressive suction that irritates the nasal lining and increases swelling.",
                "Decongestant drops for infants without medical advice."
            ],
            whenToCallDoctor: [
                "Your baby pulls at one ear alongside fever or unusual crying.",
                "Discharge or blood from the ear.",
                "A blocked nose that stops your baby feeding, or breathing that looks laboured.",
                "Any suspicion an object has been pushed into the nose or ear."
            ]
        )
    ]
}
```

### 5.4 `CareTipsCatalog+Comfort.swift`

```swift
import Foundation

extension CareTipsCatalog {
    static let comfort: [CareTip] = [

        CareTip(
            id: 1301, category: .comfort, icon: "waveform", ageFrom: 0, ageTo: 4,
            title: "Soothing a colicky evening",
            summary: "Layer several calming inputs at once and give each combination a few minutes",
            whatToDo: [
                "Try the calming set together: a snug wrap, holding on the side or over your forearm, a steady shushing sound, gentle rhythmic movement, and something to suck.",
                "Keep the rhythm constant — babies settle to repetition, not variety.",
                "Reduce input elsewhere: dim the lights, turn off the television, move to a quieter room.",
                "Change holder every twenty minutes if there are two of you.",
                "If nothing works and you feel your patience going, put your baby down safely in the cot and step away for a few minutes."
            ],
            whyItMatters: "Colic in the sense of long unexplained evening crying peaks around six weeks and settles for most babies by three or four months. These techniques imitate the constant motion, pressure and sound of the womb, which is why several at once tends to work better than any one alone. Knowing there is an end point matters as much as the techniques themselves — this phase is finite even when it does not feel that way.",
            commonMistakes: [
                "Switching technique every thirty seconds before any of them can work.",
                "Colic drops, herbal remedies or gripe water without medical advice.",
                "Assuming crying always means hunger and feeding continuously.",
                "Blaming yourself — colic is not caused by anything you did or did not do."
            ],
            whenToCallDoctor: [
                "Crying starts suddenly after a calm period, or the cry sounds high-pitched and unusual.",
                "Crying with fever, vomiting, blood in the stool, or refusal to feed.",
                "Poor weight gain alongside the crying.",
                "You feel unable to cope — this is a reason to ask for help, not a failure."
            ]
        ),

        CareTip(
            id: 1302, category: .comfort, icon: "arrow.triangle.2.circlepath", ageFrom: 0, ageTo: 6,
            title: "Releasing trapped wind",
            summary: "Bicycle legs, a warm tummy and a few minutes of patience",
            whatToDo: [
                "Lay your baby on their back and cycle the legs slowly, one at a time.",
                "Bring both knees gently up towards the tummy, hold for a few seconds, release. Repeat several times.",
                "Massage the tummy in slow clockwise circles with warm hands, following the direction of the gut.",
                "Try a few minutes of tummy time across your lap while your baby is awake and supervised.",
                "Do all of this before a feed or well after one, not immediately afterwards."
            ],
            whyItMatters: "An immature digestive system moves gas slowly, and a baby who cannot yet change position has no way to help it along. Leg movement and clockwise massage follow the path of the large intestine and physically encourage gas towards the exit. Warmth relaxes the abdominal wall, which is why the same movements work better with warm hands than cold ones.",
            commonMistakes: [
                "Massaging straight after a feed, which usually brings milk back up.",
                "Pressing firmly on a full tummy.",
                "Anticlockwise circles, working against the natural direction.",
                "Simethicone drops or herbal teas without asking your doctor first."
            ],
            whenToCallDoctor: [
                "The tummy is hard, swollen, or tender to touch.",
                "No stool for an unusually long stretch alongside distress and vomiting.",
                "Blood or mucus in the stool.",
                "Drawing the legs up with screaming that comes in sharp waves."
            ]
        ),

        CareTip(
            id: 1303, category: .comfort, icon: "thermometer.high", ageFrom: 0, ageTo: 24,
            title: "Measuring a fever and knowing the thresholds",
            summary: "Under three months, any fever is an immediate call — no exceptions",
            whatToDo: [
                "Measure with a digital thermometer under the arm for young babies, or use the device your doctor recommends.",
                "Record the number and the time in Momsy so you can show the curve, not a single point.",
                "Watch behaviour as well as the number: feeding, alertness, wet nappies, breathing, skin colour.",
                "Keep fluids going — more frequent breast or formula feeds, and water too once solids have started.",
                "Do not overwrap. One light layer helps heat escape."
            ],
            whyItMatters: "In babies under three months the immune system cannot contain infection reliably, so a temperature of 38 °C or above is treated as urgent regardless of how well the baby seems. From three months onwards, behaviour carries more information than the number itself: a baby with 39 °C who drinks and responds to you is usually less concerning than one at 38 °C who is limp and will not feed.",
            commonMistakes: [
                "Judging temperature by touch alone.",
                "Wrapping a hot baby in blankets.",
                "Any medication without confirming the dose for your baby's age and weight with a professional.",
                "Cold baths or alcohol rubs to bring the temperature down."
            ],
            whenToCallDoctor: [
                "Any fever of 38 °C or more in a baby under three months — seek care immediately.",
                "Fever with a rash that does not fade under pressure, a stiff neck, or a bulging fontanelle — emergency.",
                "Difficult or rapid breathing, unusual drowsiness, or a weak cry.",
                "Fever lasting more than 48 hours, or a baby who will not drink."
            ]
        ),

        CareTip(
            id: 1304, category: .comfort, icon: "mouth.fill", ageFrom: 4, ageTo: 24,
            title: "Teething relief that is actually safe",
            summary: "Cool pressure works; necklaces and numbing gels do not belong here",
            whatToDo: [
                "Offer a firm rubber or silicone teether, chilled in the fridge rather than the freezer.",
                "Rub the gum with a clean finger or a cool damp flannel using steady pressure.",
                "Let your baby chew on a cold clean cloth under supervision.",
                "Wipe drool from the chin and neck often and apply a barrier cream to prevent a drool rash.",
                "Keep routines calm and expect a few unsettled nights around each tooth."
            ],
            whyItMatters: "Pressure on the gum interrupts the pain signal from the tooth pushing through, and cold reduces local swelling — which is why a chilled teether outperforms almost everything sold for the purpose. Amber necklaces are a strangulation and choking risk with no proven benefit, and some numbing gels contain ingredients not considered safe for infants. Teething also does not cause high fever or diarrhoea; if those appear, look for another explanation.",
            commonMistakes: [
                "Amber or wooden bead necklaces.",
                "Teethers frozen solid, which are too hard for delicate gums.",
                "Numbing gels containing benzocaine or lidocaine.",
                "Blaming a high fever or a persistent illness on teething."
            ],
            whenToCallDoctor: [
                "Fever above 38 °C, which is not caused by teething.",
                "Diarrhoea, vomiting, or a rash across the body.",
                "Refusal to feed for more than a day.",
                "Swollen, bleeding gums, or no teeth at all by around 15 months."
            ]
        ),

        CareTip(
            id: 1305, category: .comfort, icon: "comb.fill", ageFrom: 0, ageTo: 6,
            title: "Cradle cap: harmless and self-resolving",
            summary: "Soften, comb gently, wash out — and accept that time does most of the work",
            whatToDo: [
                "Massage a little baby oil or an unfragranced emollient into the scalp and leave it for an hour or overnight.",
                "Loosen the softened scales with a soft brush or a fine comb, always gently.",
                "Wash out with a mild baby shampoo, then brush the hair through.",
                "Repeat every few days rather than daily.",
                "If it does not shift, leave it — it clears on its own within months."
            ],
            whyItMatters: "Cradle cap comes from overactive oil glands stimulated by hormones still circulating from pregnancy, so it is neither an infection nor a sign of poor hygiene, and it does not itch or bother your baby. Softening first is the whole trick: dry scales are attached to skin, oiled scales are not. Picking at dry patches breaks the skin underneath and opens the door to genuine infection.",
            commonMistakes: [
                "Picking or scratching off dry flakes with a fingernail.",
                "Adult anti-dandruff shampoo.",
                "Daily washing, which strips the scalp and can make it worse.",
                "Assuming it means your baby is uncomfortable — it almost never is."
            ],
            whenToCallDoctor: [
                "The patches spread to the face, neck or body.",
                "Redness, weeping, swelling, or a smell — signs of infection.",
                "Your baby scratches at the scalp or seems itchy.",
                "It has not improved by around a year."
            ]
        )
    ]
}
```

### 5.5 `CareTipsCatalog+Development.swift`

```swift
import Foundation

extension CareTipsCatalog {
    static let development: [CareTip] = [

        CareTip(
            id: 1401, category: .development, icon: "figure.child", ageFrom: 0, ageTo: 6,
            title: "Tummy time from the first week",
            summary: "Start with three to five minutes a few times a day and build from there",
            whatToDo: [
                "Begin on day one or two: chest-to-chest on your reclined body counts as tummy time.",
                "Move to a firm flat surface for short sessions, two or three times a day.",
                "Choose the moment well — after a nappy change, before a feed, never straight after eating.",
                "Get down to eye level, talk, and use a mirror or a high-contrast card to give them a reason to lift.",
                "Build towards roughly an hour spread across the day by three months. Always awake and supervised."
            ],
            whyItMatters: "Everything from head control to rolling, sitting and eventually crawling depends on the neck, shoulder and back strength that only develops against gravity. Since babies now spend nights and naps on their backs — correctly so — the awake hours are where that work has to happen. It also takes pressure off the back of the skull, which protects head shape at the same time.",
            commonMistakes: [
                "Skipping it because the baby protests — short frequent sessions beat one long unhappy one.",
                "Tummy time straight after a feed.",
                "Only on a soft mattress or sofa, where there is nothing firm to push against.",
                "Leaving the baby unattended, or letting them fall asleep on their front."
            ],
            whenToCallDoctor: [
                "No head lift at all by three months.",
                "Your baby consistently turns the head to only one side.",
                "One side of the body feels stiffer or is clearly used less.",
                "Head control seems to go backwards after it had been improving."
            ]
        ),

        CareTip(
            id: 1402, category: .development, icon: "circle.righthalf.filled", ageFrom: 0, ageTo: 6,
            title: "Keeping head shape round",
            summary: "Vary the pressure point: alternate head position, cot orientation and carrying arm",
            whatToDo: [
                "Alternate which end of the cot the head goes to each night, so your baby turns towards the room from both sides.",
                "Move the mobile or the interesting side of the room from time to time.",
                "Switch the arm you carry and feed on, even if bottle feeding.",
                "Increase awake time off the back of the head — tummy time, side-lying play, upright carrying.",
                "Limit time in car seats, bouncers and swings to what travel actually requires."
            ],
            whyItMatters: "An infant skull is soft and reshapes under sustained pressure, so a baby who always rests on the same spot develops a flat area there. The fix is variety rather than any device, and the earlier it starts the more effectively the skull rounds out on its own. Persistent one-sided turning sometimes means a tight neck muscle, which responds well to early physiotherapy and less well to waiting.",
            commonMistakes: [
                "Head-shaping pillows or positioners in the cot — unsafe for sleep and not effective.",
                "Long daily stretches in a car seat or bouncer.",
                "Always feeding and carrying on the same side.",
                "Changing sleep position to the front to relieve pressure."
            ],
            whenToCallDoctor: [
                "A visible flat area that is not improving with position changes by around four months.",
                "Your baby cannot or will not turn the head one way.",
                "The face or ears look asymmetric.",
                "Any concern about head size or shape at a routine check."
            ]
        ),

        CareTip(
            id: 1403, category: .development, icon: "bubble.left.and.bubble.right.fill", ageFrom: 0, ageTo: 24,
            title: "Serve and return: answer every babble",
            summary: "Your reply to a sound is what builds language, long before words appear",
            whatToDo: [
                "When your baby makes a sound, look at them, respond, and pause as if waiting for a reply.",
                "Name what they are looking at rather than what you want them to look at.",
                "Narrate ordinary routines out loud — nappy changes, cooking, getting dressed.",
                "Use warm exaggerated intonation; the sing-song voice is genuinely easier for a baby to process.",
                "Keep it two-way — leave gaps rather than filling every silence."
            ],
            whyItMatters: "Language develops through back-and-forth exchanges, not through volume of speech directed at a child. Each time your baby vocalises and you respond, they learn that sounds cause responses — the foundation of conversation. Research consistently finds that the number of these turn-taking exchanges predicts later language ability better than the total number of words a child hears.",
            commonMistakes: [
                "Background television or radio treated as language exposure — it does not respond.",
                "Filling every gap so there is no space for the baby to take a turn.",
                "Waiting for real words before starting conversations.",
                "Correcting babble instead of answering it."
            ],
            whenToCallDoctor: [
                "No cooing or vocal sounds by around four months.",
                "No babbling with consonants by nine months.",
                "No response to their name or to loud sounds.",
                "A loss of sounds, gestures or eye contact that were previously there — mention this promptly."
            ]
        ),

        CareTip(
            id: 1404, category: .development, icon: "heart.fill", ageFrom: 0, ageTo: 3,
            title: "Skin-to-skin — and why fathers should do it too",
            summary: "Bare chest, bare back covered, and twenty unhurried minutes",
            whatToDo: [
                "Undress your baby to the nappy and place them chest-down on your bare chest.",
                "Cover their back with a light blanket, leaving the face clear and visible at all times.",
                "Stay upright and awake — if you feel sleepy, move your baby to the cot first.",
                "Aim for at least twenty minutes so both of you can settle into it.",
                "Share it: fathers, partners and adoptive parents get the same benefits."
            ],
            whyItMatters: "Direct skin contact stabilises a baby's heart rate, breathing and temperature, and it lowers stress hormones in both the baby and the adult holding them. For the parent it triggers oxytocin release, which supports bonding and, for the feeding parent, milk supply. It is one of the few things that is simultaneously good for the baby, good for the adult, and free.",
            commonMistakes: [
                "Treating it as something only the birth mother can do.",
                "Stopping after the first week — it stays valuable for months.",
                "Falling asleep with the baby on your chest on a sofa or armchair.",
                "Rushing it into five-minute slots between other tasks."
            ],
            whenToCallDoctor: [
                "Your baby becomes cold, mottled or floppy during skin-to-skin.",
                "Noisy or laboured breathing while lying on your chest.",
                "You feel no connection at all after weeks of trying — this is worth saying to a professional, and it is common."
            ]
        ),

        CareTip(
            id: 1405, category: .development, icon: "book.fill", ageFrom: 0, ageTo: 24,
            title: "Read aloud daily, starting now",
            summary: "The voice matters more than the story, and no age is too early",
            whatToDo: [
                "Read for a few minutes a day from the newborn stage — any book, including your own.",
                "Choose high-contrast and simple images for the first months, then cloth and board books to grab and chew.",
                "Let your baby set the pace: skip pages, repeat favourites, stop when interest goes.",
                "Point at pictures and name them rather than reading the text word for word.",
                "Fit it into a routine you already have, such as before the last feed."
            ],
            whyItMatters: "Books put unusual words into a warm familiar voice, and the combination of rhythm, repetition and closeness is what makes them stick. Long before a baby understands a story, they learn that pages turn, that pictures mean something, and that this is a shared and pleasant activity. Building the habit in the first year is far easier than introducing it to a mobile toddler.",
            commonMistakes: [
                "Waiting until the child can sit still and listen.",
                "Insisting on finishing the book.",
                "Swapping books for an app or a screen at this age.",
                "Choosing only long text-heavy stories."
            ],
            whenToCallDoctor: [
                "No visual tracking of pictures or faces by three months.",
                "No interest in looking at books or faces at all by around a year.",
                "Any concern about hearing or vision — get it checked rather than watched."
            ]
        )
    ]
}
```

### 5.6 `CareTipsCatalog+Safety.swift`

```swift
import Foundation

extension CareTipsCatalog {
    static let safety: [CareTip] = [

        CareTip(
            id: 1501, category: .safety, icon: "car.fill", ageFrom: 0, ageTo: 24,
            title: "Car seat basics: rear-facing, snug harness, no coats",
            summary: "Rear-facing as long as the seat allows, and the harness flat against the body",
            whatToDo: [
                "Keep the seat rear-facing for as long as your seat's height and weight limits permit.",
                "Set the harness slots at or just below the shoulders in a rear-facing seat.",
                "Tighten until you cannot pinch a horizontal fold of webbing at the shoulder.",
                "Position the chest clip at armpit level.",
                "Remove bulky coats and snowsuits; strap your baby in first, then lay the coat or a blanket over the harness."
            ],
            whyItMatters: "In a frontal collision a rear-facing seat spreads the force across the whole back and supports the head and neck, which is exactly what a baby's proportionally heavy head and soft neck need. A padded coat compresses to almost nothing under crash forces, leaving several centimetres of slack in a harness that felt tight in the driveway — which is how a correctly fastened child ends up loose in a crash.",
            commonMistakes: [
                "Turning forward-facing on a birthday rather than at the seat's limit.",
                "A loose harness or a chest clip sitting on the tummy.",
                "Winter coats, snowsuits or aftermarket padding under the straps.",
                "Second-hand seats of unknown history, or any seat involved in a crash."
            ],
            whenToCallDoctor: [
                "Your baby's head slumps forward or breathing sounds laboured in the seat — check the recline angle urgently.",
                "Premature or low birth weight babies may need a car seat tolerance check before discharge.",
                "After any collision, have your baby assessed even if they seem completely fine."
            ]
        ),

        CareTip(
            id: 1502, category: .safety, icon: "exclamationmark.triangle.fill", ageFrom: 0, ageTo: 12,
            title: "Never step away from the changing table",
            summary: "One hand stays on your baby, always — rolling arrives without warning",
            whatToDo: [
                "Keep everything you need within arm's reach before you start.",
                "Keep one hand on your baby's tummy or chest throughout, including while reaching for wipes.",
                "If you must leave for any reason, take your baby with you or put them on the floor.",
                "Consider changing on a mat on the floor from the newborn stage.",
                "Use the strap if your changing table has one, but never as a substitute for your hand."
            ],
            whyItMatters: "The first roll is unpredictable and often happens weeks before parents expect it — many falls involve a baby who had never rolled before. Falls from changing height are among the most common injuries in the first year, and the head takes most of the impact. The single-hand rule works because it does not depend on you correctly predicting when your baby will develop a new skill.",
            commonMistakes: [
                "Turning to grab a nappy from a shelf just out of reach.",
                "Trusting a strap or raised sides to hold a determined baby.",
                "Answering the door or the phone mid-change.",
                "Assuming a baby who has not rolled yet cannot roll today."
            ],
            whenToCallDoctor: [
                "Any fall from height in a baby under a year — seek advice even without visible injury.",
                "Loss of consciousness, vomiting, unusual drowsiness, or a bulging soft spot after a fall — emergency.",
                "A swelling on the head, or any change in behaviour, feeding or responsiveness."
            ]
        ),

        CareTip(
            id: 1503, category: .safety, icon: "shield.lefthalf.filled", ageFrom: 5, ageTo: 24,
            title: "Baby-proof before your baby moves",
            summary: "Do it at five months, not on the day they first crawl",
            whatToDo: [
                "Get down on the floor and look at the room from your baby's eye level.",
                "Anchor bookcases, chests of drawers and televisions to the wall.",
                "Fit stair gates at the top and bottom, and lock away cleaning products, medicines and small batteries.",
                "Move cords and blind pulls out of reach and tie them up high.",
                "Check for anything that fits through a toilet-roll tube — that is roughly the choking size limit."
            ],
            whyItMatters: "Mobility arrives suddenly: a baby who has never moved forward can cross a room within a day of working out how. Preparing early means you are not improvising while also watching a newly mobile child. Furniture tip-overs and button batteries deserve particular attention because both cause severe harm quickly and both are easy to overlook.",
            commonMistakes: [
                "Waiting for the first crawl before starting.",
                "Forgetting rooms your baby is 'never' in — bathroom, kitchen, grandparents' house.",
                "Pressure-fitted gates at the top of stairs, where screw-fitted ones are needed.",
                "Handbags left on the floor with medication or coins inside."
            ],
            whenToCallDoctor: [
                "Any suspicion your baby has swallowed a button battery or a magnet — go to emergency immediately, do not wait for symptoms.",
                "Suspected poisoning — call emergency services and keep the packaging with you.",
                "Choking that clears but is followed by ongoing coughing or noisy breathing."
            ]
        ),

        CareTip(
            id: 1504, category: .safety, icon: "drop.triangle.fill", ageFrom: 0, ageTo: 24,
            title: "Water safety: never out of arm's reach",
            summary: "A few centimetres of water is enough, and drowning is silent",
            whatToDo: [
                "Keep a hand on your baby for the entire bath, every time.",
                "Empty the bath immediately afterwards.",
                "Keep toilet lids down and bathroom doors closed; buckets and basins emptied after use.",
                "Set the household hot water thermostat to a safe limit and always run cold water into the bath first.",
                "Treat bath seats and rings as toys, not as safety devices."
            ],
            whyItMatters: "Infant drowning happens in seconds, in very little water, and almost silently — there is no splashing or shouting to alert you. A baby who slips under cannot right themselves, and the reflex response makes it worse rather than better. Scalds are the other bathroom risk: a baby's skin burns at lower temperatures and in less time than an adult's.",
            commonMistakes: [
                "Leaving the room for a towel or a phone.",
                "Asking an older sibling to supervise.",
                "Running hot water into the bath while the baby is already in it.",
                "Buckets or paddling pools left with water in them."
            ],
            whenToCallDoctor: [
                "Any submersion, even brief, followed by coughing, breathing changes or drowsiness — seek care immediately.",
                "A scald that blisters, covers a large area, or affects the face, hands or nappy area.",
                "Vomiting or unusual sleepiness in the hours after any water incident."
            ]
        ),

        CareTip(
            id: 1505, category: .safety, icon: "cross.case.fill", ageFrom: 0, ageTo: 24,
            title: "Be ready for an emergency before you need to be",
            summary: "Save the numbers, take an infant first-aid course, and know your own address",
            whatToDo: [
                "Save your local emergency number and your paediatrician's number in your phone now.",
                "Write your full address, including the entry code and floor, somewhere visible — people forget it under stress.",
                "Take an infant first-aid and CPR course; infant technique differs from the adult version and cannot be learned from a video alone.",
                "Refresh the training every couple of years, and make sure anyone who cares for your baby has done it too.",
                "Keep a small first-aid kit and your baby's health record where anyone can find them."
            ],
            whyItMatters: "In an emergency you will not read instructions or research technique — you will do whatever you have already practised. Infant CPR uses two fingers rather than two hands and a different rate and depth, so adult training does not transfer. Preparing in advance is not pessimism; it is the same reason you check where the exits are on a plane you fully expect to land normally.",
            commonMistakes: [
                "Assuming adult first aid is close enough.",
                "Relying on a video watched once.",
                "Leaving carers without emergency contacts or medical details.",
                "Skipping refresher training after the first year."
            ],
            whenToCallDoctor: [
                "Difficulty breathing, blue or grey lips or skin, or unresponsiveness — call emergency services immediately.",
                "A seizure, or a rash that does not fade under pressure.",
                "Any choking episode that needed intervention should be assessed afterwards."
            ]
        )
    ]
}
```

### 5.7 `CareTipsCatalog+Parent.swift`

```swift
import Foundation

extension CareTipsCatalog {
    static let parent: [CareTip] = [

        CareTip(
            id: 1601, category: .parent, icon: "person.2.fill", ageFrom: 0, ageTo: 12,
            title: "Split the night into shifts",
            summary: "One protected four-hour block each beats two people half-awake all night",
            whatToDo: [
                "Divide the night into two blocks — for example one parent covers until 2am, the other from 2am.",
                "The off-duty parent sleeps elsewhere if possible, with earplugs and no monitor.",
                "If breastfeeding, the non-feeding parent still does the nappy change, the resettle and the return to the cot.",
                "Agree the split in advance rather than negotiating at 3am.",
                "Rotate which parent gets the earlier block so the harder half is shared."
            ],
            whyItMatters: "Sleep restores in cycles of roughly ninety minutes, and a full uninterrupted block does far more for functioning than the same total hours broken into fragments. Two adults each half-awake all night end up with two impaired parents; a shift system produces one rested parent every night. Agreeing it in advance also removes the nightly negotiation, which is where most of the resentment tends to accumulate.",
            commonMistakes: [
                "Both parents waking for every feed out of solidarity.",
                "The non-feeding parent assuming there is nothing useful to do.",
                "Deciding who gets up in the moment, every time.",
                "Filling the off-duty block with chores instead of sleep."
            ],
            whenToCallDoctor: [
                "You cannot sleep even when your baby is asleep and someone else is on duty.",
                "Exhaustion is affecting your driving, your safety, or your ability to care for your baby.",
                "Persistent low mood or anxiety alongside the tiredness."
            ]
        ),

        CareTip(
            id: 1602, category: .parent, icon: "heart.text.square.fill", ageFrom: 0, ageTo: 12,
            title: "Baby blues or something more",
            summary: "Tearfulness in the first two weeks is common; low mood that persists deserves support",
            whatToDo: [
                "Expect the baby blues: weepiness, mood swings and sensitivity peaking around days three to five and easing within two weeks.",
                "Track how you feel over time — Momsy's Wellbeing screen includes the EPDS questionnaire.",
                "Tell one person how you are actually doing, not the version you give at the door.",
                "Protect the basics where you can: food, water, daylight, one block of sleep.",
                "If low mood, anxiety or numbness lasts beyond two weeks, book an appointment. Bring your partner if that helps."
            ],
            whyItMatters: "Baby blues are driven by an abrupt hormonal shift after birth and resolve on their own. Postnatal depression and anxiety are different: they persist, they deepen, and they respond well to treatment — but only when someone knows about them. They are common, they affect fathers and partners too, and they are not a verdict on how much you love your baby.",
            commonMistakes: [
                "Waiting for it to pass because everyone says the first months are hard.",
                "Assuming it cannot be depression because you love your baby.",
                "Hiding it from your partner or your doctor.",
                "Believing partners and fathers are not affected."
            ],
            whenToCallDoctor: [
                "Low mood, anxiety or emptiness lasting more than two weeks.",
                "Difficulty bonding, or persistent guilt and worthlessness.",
                "Panic attacks, intrusive frightening thoughts, or being unable to sleep even when your baby sleeps.",
                "Any thought of harming yourself or your baby — contact emergency services or your doctor straight away. This is urgent and treatable, and asking for help is the right move."
            ]
        ),

        CareTip(
            id: 1603, category: .parent, icon: "hand.raised.fill", ageFrom: 0, ageTo: 12,
            title: "Never shake a baby: have a walk-away plan",
            summary: "Decide now what you will do when you have nothing left, so you do not decide in the moment",
            whatToDo: [
                "Agree the plan in advance: when you reach your limit, put your baby down on their back in the cot.",
                "Leave the room, close the door, and set a timer for five or ten minutes.",
                "Breathe slowly, drink water, step outside, or call someone.",
                "Go back when you are calmer. A crying baby in a safe cot is fine for a few minutes; a shaken baby is not.",
                "Make sure everyone who ever cares for your baby — partner, relatives, babysitters — knows this plan and knows it is allowed."
            ],
            whyItMatters: "Shaking causes catastrophic and permanent brain injury in seconds, and it almost always happens to loving parents at the end of a long stretch of inconsolable crying. Crying peaks around six to eight weeks, exactly when parents are most exhausted, which is why the plan has to exist before the moment arrives. Choosing to walk away is not neglect — it is the responsible thing to do.",
            commonMistakes: [
                "Believing this only happens to other kinds of parents.",
                "Continuing to hold a baby while feeling anger rise.",
                "Not telling other carers that walking away is expected and allowed.",
                "Feeling ashamed of reaching a limit — every parent has one."
            ],
            whenToCallDoctor: [
                "If your baby has been shaken or dropped, seek emergency care immediately, whatever the circumstances.",
                "Vomiting, unusual drowsiness, irritability, a bulging fontanelle, seizures or breathing changes after any head impact.",
                "If you frequently feel close to losing control, tell your doctor or health visitor. Support exists and asking for it protects everyone."
            ]
        )
    ]
}
```

> **Итого v1: 38 рекомендаций.** Оставшиеся из проведённого анализа (choking hazards, allergens, open cup, milk storage, drowsy-but-awake, sleep regressions, oral care, dressing rule, constipation, dehydration, screen-free, milestones, second-hand smoke, hand hygiene, fair night duties и др.) добавляются позже как чистое data-изменение — свободные id в тех же диапазонах.

---

## 6. ЗАДАЧА 4 — ViewModel

**Новый файл:** `Momsy/Features/CareTips/Presentation/ViewModel/CareTipsViewModel.swift`

```swift
import SwiftUI
import Combine

@MainActor
final class CareTipsViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedCategory: CareTipCategory? = nil
    @Published var isAgeFilterOn: Bool = true

    private let appState: AppState
    private let catalog: [CareTip]
    private var lm: LocalizationManager { .shared }

    init(appState: AppState, catalog: [CareTip] = CareTipsCatalog.all) {
        self.appState = appState
        self.catalog = catalog
        self.isAgeFilterOn = appState.babyProfile?.birthDate != nil
    }

    var babyAgeMonths: Int? {
        guard let birth = appState.babyProfile?.birthDate else { return nil }
        return BabyAgeContext.ageMonths(birthDate: birth)
    }

    var canFilterByAge: Bool { babyAgeMonths != nil }

    var sections: [(category: CareTipCategory, tips: [CareTip])] {
        let lang = lm.current
        let age = isAgeFilterOn ? babyAgeMonths : nil
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        let filtered = catalog.filter { tip in
            if let selectedCategory, tip.category != selectedCategory { return false }
            if let age, !tip.matches(ageMonths: age) { return false }
            return tip.matches(query: query, lang: lang)
        }

        return CareTipCategory.allCases.compactMap { category in
            let tips = filtered.filter { $0.category == category }
            return tips.isEmpty ? nil : (category: category, tips: tips)
        }
    }

    var isEmpty: Bool { sections.isEmpty }

    func toggleCategory(_ category: CareTipCategory) {
        selectedCategory = (selectedCategory == category) ? nil : category
    }
}
```

---

## 7. ЗАДАЧА 5 — Views

**Новый файл:** `Momsy/Features/CareTips/Presentation/Views/CareTipsView.swift`

```swift
import SwiftUI

struct CareTipsView: View {
    @StateObject private var vm: CareTipsViewModel
    @EnvironmentObject private var lm: LocalizationManager

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeCareTipsViewModel())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12, pinnedViews: .sectionHeaders) {
                filterBar
                    .padding(.bottom, 2)

                if vm.isEmpty {
                    emptyState
                } else {
                    ForEach(vm.sections, id: \.category) { section in
                        Section {
                            VStack(spacing: 0) {
                                ForEach(Array(section.tips.enumerated()), id: \.element.id) { idx, tip in
                                    NavigationLink(destination: CareTipDetailView(tip: tip)) {
                                        CareTipRowView(tip: tip, lang: lm.current)
                                    }
                                    .buttonStyle(.plain)

                                    if idx < section.tips.count - 1 {
                                        Divider().padding(.leading, 60)
                                    }
                                }
                            }
                            .background(Color.bbCard)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
                        } header: {
                            Text(section.category.title(lm.current).uppercased())
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundColor(.bbInkSoft)
                                .kerning(0.5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 4)
                                .background(Color.bbCream)
                        }
                    }
                }

                disclaimerFooter
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.strings.careTipsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $vm.searchText, prompt: lm.strings.careTipsSearchPrompt)
    }

    // MARK: - Filters

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                if vm.canFilterByAge {
                    chip(
                        title: lm.strings.careTipsFilterMyBaby,
                        isSelected: vm.isAgeFilterOn
                    ) {
                        withAnimation(.spring(response: 0.3)) { vm.isAgeFilterOn.toggle() }
                    }
                }

                chip(
                    title: lm.strings.careTipsFilterAll,
                    isSelected: vm.selectedCategory == nil
                ) {
                    withAnimation(.spring(response: 0.3)) { vm.selectedCategory = nil }
                }

                ForEach(CareTipCategory.allCases) { category in
                    chip(
                        title: category.title(lm.current),
                        isSelected: vm.selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) { vm.toggleCategory(category) }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .white : .bbInkSoft)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.bbSurface : Color.bbCard)
                .clipShape(Capsule())
                .bbShadowSoft()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty & footer

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(.bbInkMute)
            Text(lm.strings.careTipsEmpty)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private var disclaimerFooter: some View {
        Text(lm.strings.careTipsDisclaimer)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.bbInkMute)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
    }
}

// MARK: - Row

private struct CareTipRowView: View {
    let tip: CareTip
    let lang: Language

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tip.category.semanticColor.color.opacity(0.28))
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: tip.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.bbInk)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(tip.title(lang))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInk)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(tip.summary(lang))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.bbInkMute)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
```

**Новый файл:** `Momsy/Features/CareTips/Presentation/Views/CareTipDetailView.swift`

```swift
import SwiftUI

struct CareTipDetailView: View {
    let tip: CareTip
    @EnvironmentObject private var lm: LocalizationManager

    private var lang: Language { lm.current }
    private var tint: Color { tip.category.semanticColor.color }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                header
                numberedBlock(title: lm.strings.careTipWhatToDo, items: tip.whatToDo(lang))
                paragraphBlock(title: lm.strings.careTipWhyItMatters, text: tip.whyItMatters(lang))
                bulletBlock(
                    title: lm.strings.careTipCommonMistakes,
                    items: tip.commonMistakes(lang),
                    symbol: "xmark.circle.fill",
                    symbolColor: .bbInkMute
                )
                redFlagBlock
                disclaimer
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(tip.category.title(lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint.opacity(0.3))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: tip.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.bbInk)
                    )
                BBPill(text: tip.ageLabel(lang), color: tint.opacity(0.3))
                Spacer()
            }

            Text(tip.title(lang))
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
                .fixedSize(horizontal: false, vertical: true)

            Text(tip.summary(lang))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard()
    }

    // MARK: - Blocks

    private func numberedBlock(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: title)
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(idx + 1)")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(tint.opacity(0.35)))
                    Text(item)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard()
    }

    private func paragraphBlock(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: title)
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.bbInk)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard()
    }

    private func bulletBlock(
        title: String,
        items: [String],
        symbol: String,
        symbolColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            BBSectionLabel(text: title)
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: symbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(symbolColor)
                        .frame(width: 22)
                    Text(item)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard()
    }

    private var redFlagBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lm.strings.careTipWhenToCallDoctor.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.75))
                .kerning(0.6)

            ForEach(Array(tip.whenToCallDoctor(lang).enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: 22)
                    Text(item)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard(bg: .bbSurface)
    }

    private var disclaimer: some View {
        Text(lm.strings.careTipsDisclaimer)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.bbInkMute)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.top, 4)
    }
}
```

---

## 8. ЗАДАЧА 6 — L10n

**Файл:** `Momsy/Core/Localization/L10n.swift`

Все UI-строки раздела локализованы сразу на 7 языков (они короткие). Контент рекомендаций локализуется отдельно, через `LocalizedText` в каталоге.

**BEFORE** (строки 1756–1761, конец файла):

```swift
    // MARK: — Log Report (Doctor)
    var logReportTitle: String { s("Report", "Отчёт", "Bericht", "Informe", "Rapport", "Relatório", "报告") }
    var logReportSub: String   { s("All entries — day, week, month", "Все записи — день, неделя, месяц", "Alle Einträge — Tag, Woche, Monat", "Todos los registros — día, semana, mes", "Toutes les entrées — jour, semaine, mois", "Todos os registos — dia, semana, mês", "全部记录——日、周、月") }
    var logReportDay: String   { s("Day", "День", "Tag", "Día", "Jour", "Dia", "日") }
    var logReportEmpty: String { s("No entries for this period", "Нет записей за этот период", "Keine Einträge für diesen Zeitraum", "No hay registros en este período", "Aucune entrée pour cette période", "Sem registos neste período", "此时段暂无记录") }
}
```

**AFTER:**

```swift
    // MARK: — Log Report (Doctor)
    var logReportTitle: String { s("Report", "Отчёт", "Bericht", "Informe", "Rapport", "Relatório", "报告") }
    var logReportSub: String   { s("All entries — day, week, month", "Все записи — день, неделя, месяц", "Alle Einträge — Tag, Woche, Monat", "Todos los registros — día, semana, mes", "Toutes les entrées — jour, semaine, mois", "Todos os registos — dia, semana, mês", "全部记录——日、周、月") }
    var logReportDay: String   { s("Day", "День", "Tag", "Día", "Jour", "Dia", "日") }
    var logReportEmpty: String { s("No entries for this period", "Нет записей за этот период", "Keine Einträge für diesen Zeitraum", "No hay registros en este período", "Aucune entrée pour cette période", "Sem registos neste período", "此时段暂无记录") }

    // MARK: — Care Tips (Doctor)
    var careTipsTitle: String { s("Care Tips", "Советы по уходу", "Pflegetipps", "Consejos de cuidado", "Conseils de soins", "Dicas de cuidados", "护理建议") }
    var careTipsSub: String   { s("Everyday guidance by age", "Рекомендации по возрасту", "Alltagstipps nach Alter", "Guía diaria por edad", "Conseils du quotidien par âge", "Orientação diária por idade", "按月龄的日常指导") }
    var careTipsSearchPrompt: String { s("Search tips", "Поиск советов", "Tipps suchen", "Buscar consejos", "Rechercher des conseils", "Pesquisar dicas", "搜索建议") }
    var careTipsEmpty: String { s("Nothing found. Try another filter or search.", "Ничего не найдено. Измените фильтр или запрос.", "Nichts gefunden. Anderer Filter oder Suchbegriff?", "No se encontró nada. Prueba otro filtro o búsqueda.", "Aucun résultat. Essayez un autre filtre ou une autre recherche.", "Nada encontrado. Tente outro filtro ou pesquisa.", "未找到内容。请更换筛选或搜索词。") }
    var careTipsFilterAll: String { s("All", "Все", "Alle", "Todos", "Tous", "Todos", "全部") }
    var careTipsFilterMyBaby: String { s("For my baby", "Для моего малыша", "Für mein Baby", "Para mi bebé", "Pour mon bébé", "Para o meu bebé", "适合我的宝宝") }

    var careTipWhatToDo: String { s("What to do", "Что делать", "Was zu tun ist", "Qué hacer", "Que faire", "O que fazer", "怎么做") }
    var careTipWhyItMatters: String { s("Why it matters", "Почему это важно", "Warum es wichtig ist", "Por qué importa", "Pourquoi c’est important", "Porque é importante", "为什么重要") }
    var careTipCommonMistakes: String { s("Common mistakes", "Частые ошибки", "Häufige Fehler", "Errores frecuentes", "Erreurs fréquentes", "Erros comuns", "常见误区") }
    var careTipWhenToCallDoctor: String { s("When to call your doctor", "Когда звонить врачу", "Wann zum Arzt", "Cuándo llamar al médico", "Quand appeler le médecin", "Quando contactar o médico", "何时联系医生") }

    var careTipsDisclaimer: String {
        s("General guidance for everyday care, not medical advice or a diagnosis. When in doubt — always see your paediatrician.",
          "Общие рекомендации по повседневному уходу, а не медицинский совет или диагноз. При любых сомнениях — всегда к педиатру.",
          "Allgemeine Hinweise zur täglichen Pflege, keine medizinische Beratung und keine Diagnose. Im Zweifel — immer zum Kinderarzt.",
          "Orientación general para el cuidado diario, no es consejo médico ni un diagnóstico. Ante la duda — acude siempre a tu pediatra.",
          "Conseils généraux pour les soins du quotidien, pas un avis médical ni un diagnostic. En cas de doute — consultez toujours votre pédiatre.",
          "Orientação geral para os cuidados diários, não é aconselhamento médico nem um diagnóstico. Em caso de dúvida — consulte sempre o seu pediatra.",
          "这是日常护理的一般性建议，不构成医疗建议或诊断。如有疑问——请务必就诊儿科医生。")
    }

    var careTipsAllAges: String { s("All ages", "Любой возраст", "Jedes Alter", "Todas las edades", "Tous les âges", "Todas as idades", "全月龄") }

    func careTipsCategoryTitle(_ category: CareTipCategory) -> String {
        switch category {
        case .feeding:     return s("Feeding", "Кормление", "Ernährung", "Alimentación", "Alimentation", "Alimentação", "喂养")
        case .sleep:       return s("Sleep", "Сон", "Schlaf", "Sueño", "Sommeil", "Sono", "睡眠")
        case .hygiene:     return s("Daily care", "Ежедневный уход", "Tägliche Pflege", "Cuidado diario", "Soins quotidiens", "Cuidados diários", "日常护理")
        case .comfort:     return s("Comfort", "Комфорт", "Wohlbefinden", "Bienestar", "Confort", "Conforto", "舒缓")
        case .development: return s("Development", "Развитие", "Entwicklung", "Desarrollo", "Développement", "Desenvolvimento", "发育")
        case .safety:      return s("Safety", "Безопасность", "Sicherheit", "Seguridad", "Sécurité", "Segurança", "安全")
        case .parent:      return s("For parents", "Для родителей", "Für Eltern", "Para los padres", "Pour les parents", "Para os pais", "给父母")
        }
    }

    func careTipAgeRange(from: Int, to: Int) -> String {
        if from == 0 && to >= 24 { return careTipsAllAges }
        let unit = s("mo", "мес", "Mon.", "meses", "mois", "meses", "个月")
        return "\(from)–\(to) \(unit)"
    }
}
```

---

## 9. ЗАДАЧА 7 — DI

**Файл:** `Momsy/Core/DI/AppContainer.swift`

**BEFORE** (строки 716–719):

```swift
    func makeWeeklyInsightViewModel() -> WeeklyInsightViewModel {
        WeeklyInsightViewModel(generate: generateWeeklyInsight, get: getWeeklyInsights)
    }
}
```

**AFTER:**

```swift
    func makeWeeklyInsightViewModel() -> WeeklyInsightViewModel {
        WeeklyInsightViewModel(generate: generateWeeklyInsight, get: getWeeklyInsights)
    }

    func makeCareTipsViewModel() -> CareTipsViewModel {
        CareTipsViewModel(appState: appState)
    }
}
```

---

## 10. ЗАДАЧА 8 — строка меню в Doctor

**Файл:** `Momsy/Features/Doctor/Presentation/Views/DoctorMenuView.swift`

Новая строка ставится **второй** — сразу после Weekly Insight, перед Log Report.

**BEFORE** (строки 55–61):

```swift
                            iconBg: Color.bbLilac.opacity(0.3),
                            title: lm.strings.weeklyInsightTitle,
                            sub: lm.strings.weeklyInsightSub
                        )
                        Divider().padding(.leading, 60)
                        DoctorMenuRow(
                            destination: LogReportView(container: container),
```

**AFTER:**

```swift
                            iconBg: Color.bbLilac.opacity(0.3),
                            title: lm.strings.weeklyInsightTitle,
                            sub: lm.strings.weeklyInsightSub
                        )
                        Divider().padding(.leading, 60)
                        DoctorMenuRow(
                            destination: CareTipsView(container: container),
                            icon: "lightbulb.fill",
                            iconColor: .bbButterDeep,
                            iconBg: Color.bbButter.opacity(0.3),
                            title: lm.strings.careTipsTitle,
                            sub: lm.strings.careTipsSub
                        )
                        Divider().padding(.leading, 60)
                        DoctorMenuRow(
                            destination: LogReportView(container: container),
```

Других правок в файле нет.

---

## 11. ЗАДАЧА 9 — тесты

**Новый файл:** `MomsyTests/Features/CareTips/CareTipsCatalogTests.swift`

Swift Testing (не XCTest), в стиле существующего `MomsyTests/Features/Vaccination/VaccinationScheduleTests.swift`.

```swift
import Testing
@testable import Momsy
import Foundation

@Suite("CareTipsCatalog")
struct CareTipsCatalogTests {

    @Test("catalog is not empty and every category is represented")
    func categoriesPopulated() {
        #expect(!CareTipsCatalog.all.isEmpty)
        for category in CareTipCategory.allCases {
            #expect(!CareTipsCatalog.tips(in: category).isEmpty, "\(category.rawValue) has no tips")
        }
    }

    @Test("ids are unique and inside the category namespace")
    func idsAreUniqueAndNamespaced() {
        let ids = CareTipsCatalog.all.map(\.id)
        #expect(Set(ids).count == ids.count)

        let ranges: [CareTipCategory: Range<Int>] = [
            .feeding: 1000..<1100,
            .sleep: 1100..<1200,
            .hygiene: 1200..<1300,
            .comfort: 1300..<1400,
            .development: 1400..<1500,
            .safety: 1500..<1600,
            .parent: 1600..<1700
        ]
        for tip in CareTipsCatalog.all {
            #expect(ranges[tip.category]?.contains(tip.id) == true, "id \(tip.id) outside its namespace")
        }
    }

    @Test("every tip has complete content in English")
    func contentIsComplete() {
        for tip in CareTipsCatalog.all {
            #expect(!tip.title(.english).isEmpty)
            #expect(!tip.summary(.english).isEmpty)
            #expect(!tip.whyItMatters(.english).isEmpty)
            #expect(tip.whatToDo(.english).count >= 3, "tip \(tip.id) has too few steps")
            #expect(!tip.commonMistakes(.english).isEmpty)
            #expect(!tip.whenToCallDoctor(.english).isEmpty, "tip \(tip.id) has no red flags")
            #expect(!tip.icon.isEmpty)
        }
    }

    @Test("age windows are valid")
    func ageWindowsValid() {
        for tip in CareTipsCatalog.all {
            #expect(tip.ageFromMonths >= 0)
            #expect(tip.ageToMonths >= tip.ageFromMonths)
            #expect(tip.ageToMonths <= 24)
        }
    }

    @Test("untranslated languages fall back to English")
    func fallsBackToEnglish() {
        guard let tip = CareTipsCatalog.all.first else { return }
        for lang in Language.allCases {
            #expect(!tip.title(lang).isEmpty, "\(lang.rawValue) resolved to an empty title")
            #expect(!tip.whatToDo(lang).isEmpty)
        }
    }

    @Test("age filter selects only tips covering that age")
    func ageFilter() {
        let newbornTips = CareTipsCatalog.all.filter { $0.matches(ageMonths: 0) }
        #expect(!newbornTips.isEmpty)
        #expect(newbornTips.allSatisfy { $0.ageFromMonths == 0 })

        let solidsTip = CareTipsCatalog.tip(id: 1007)
        #expect(solidsTip?.matches(ageMonths: 0) == false)
        #expect(solidsTip?.matches(ageMonths: 6) == true)
    }

    @Test("search matches title and summary case-insensitively")
    func search() {
        let tip = CareTipsCatalog.tip(id: 1001)
        #expect(tip?.matches(query: "UPRIGHT", lang: .english) == true)
        #expect(tip?.matches(query: "", lang: .english) == true)
        #expect(tip?.matches(query: "zzzzz", lang: .english) == false)
    }
}
```

Дополнительный файл `MomsyTests/Core/LocalizedTextTests.swift`:

```swift
import Testing
@testable import Momsy

@Suite("LocalizedText")
struct LocalizedTextTests {

    @Test("string literal authoring resolves to English for every language")
    func literalFallback() {
        let text: LocalizedText = "Hold your baby upright"
        for lang in Language.allCases {
            #expect(text(lang) == "Hold your baby upright")
        }
        #expect(text.isTranslated(into: .english))
        #expect(!text.isTranslated(into: .russian))
    }

    @Test("authored translation wins over the English fallback")
    func translationWins() {
        let text = LocalizedText(en: "Sleep", ru: "Сон")
        #expect(text(.russian) == "Сон")
        #expect(text(.german) == "Sleep")
        #expect(text.isTranslated(into: .russian))
    }

    @Test("array literal authoring resolves to English")
    func listFallback() {
        let list: LocalizedList = ["one", "two"]
        #expect(list(.french) == ["one", "two"])
        #expect(LocalizedList(en: ["one"], ru: ["один"])(.russian) == ["один"])
    }
}
```

---

## 12. Что НЕ делаем

- Не создаём `CareTipsRepository` / UseCase — данных для чтения-записи нет.
- Не пишем ничего в SwiftData и Firestore. Схема данных не меняется, миграция не нужна.
- Не трогаем `DailyTipAlgorithm`, `DailyTipRules`, `DailyTipService` и всё в `Features/Today/`.
- Не добавляем избранное / «прочитано» — состояние потребует персистентности и синхронизации между со-родителями; это отдельная задача после релиза.
- Не ставим paywall: раздел бесплатный.
- Не редактируем `project.pbxproj`.
- Не добавляем переводы контента — только английский, остальные языки резолвятся фолбэком.

---

## 13. Definition of Done

- [ ] Создан `Momsy/Core/Localization/LocalizedText.swift` с `LocalizedText` и `LocalizedList`, оба `Sendable`.
- [ ] Создан `CareTipModels.swift`: `CareTipCategory` (7 кейсов), `CareTip`, методы `matches(ageMonths:)`, `matches(query:lang:)`, `ageLabel(_:)`.
- [ ] Созданы 8 файлов каталога, суммарно **38 рекомендаций**, id внутри своих неймспейсов.
- [ ] Каждая рекомендация содержит title, summary, ≥3 пункта `whatToDo`, `whyItMatters`, `commonMistakes`, `whenToCallDoctor`.
- [ ] Создан `CareTipsViewModel` с фильтрами по категории, возрасту и поиску.
- [ ] Созданы `CareTipsView` и `CareTipDetailView`, использующие только существующие токены дизайн-системы (`bbCream`, `bbCard`, `bbInk`, `bbInkSoft`, `bbInkMute`, `bbSurface`, `SemanticColor`) и компоненты (`BBSectionLabel`, `BBPill`, `bbCard()`, `bbShadowSoft()`).
- [ ] В `L10n.swift` добавлена секция `// MARK: — Care Tips (Doctor)` со всеми ключами на 7 языках.
- [ ] В `AppContainer` добавлена `makeCareTipsViewModel()`.
- [ ] В `DoctorMenuView` добавлена строка Care Tips второй по счёту с иконкой `lightbulb.fill` и разделителями.
- [ ] Созданы `CareTipsCatalogTests.swift` и `LocalizedTextTests.swift`, все тесты зелёные.
- [ ] Проект собирается без предупреждений Swift 6 strict concurrency.
- [ ] Хардкод-строк в новых View нет — всё через `lm.strings` или `LocalizedText`.
- [ ] Ни один файл вне списка из раздела 2 не изменён.

---

## 14. Manual QA

1. **Вход.** Doctor → в карточке меню вторая строка «Care Tips / Everyday guidance by age» с жёлтой иконкой лампочки. Стиль строки идентичен соседним.
2. **Список.** Открывается экран с чипсами фильтров и секциями по категориям. Заголовки секций закреплены при скролле (как в Vaccinations). Фон `bbCream`.
3. **Фильтр по возрасту.** Профиль с датой рождения → чип «For my baby» активен по умолчанию, показаны только релевантные возрасту советы. Выключить чип → появляются все 38.
4. **Профиль без даты рождения.** Чип «For my baby» отсутствует, список полный, крашей нет.
5. **Категории.** Тап по «Sleep» → только 7 карточек сна. Повторный тап по тому же чипу снимает фильтр. Тап по «All» сбрасывает.
6. **Поиск.** Ввод `upright` → находит совет 1001. Ввод `zzzz` → empty state с иконкой лупы, без пустых секций.
7. **Деталь.** Тап по любой строке: шапка с иконкой, пилюлей возраста, заголовком и summary; далее «What to do» нумерованным списком, «Why it matters» абзацем, «Common mistakes» с крестиками, тёмная карточка `bbSurface` «When to call your doctor», внизу дисклеймер.
8. **Языки.** Настройки → сменить язык на Русский → заголовок экрана «Советы по уходу», названия категорий и блоков на русском, **контент рекомендаций остаётся английским** (ожидаемо на этом этапе). Повторить для 中文 — проверить, что длинные английские тексты не ломают вёрстку.
9. **Тёмная тема.** Переключить в iOS → все карточки, тёмный блок red-flags и текст читаемы.
10. **Динамический шрифт.** Увеличить размер текста до максимума → заголовки и пункты переносятся, ничего не обрезается (`fixedSize(horizontal: false, vertical: true)` стоит везде).
11. **Оффлайн.** Включить авиарежим → раздел полностью работает.
12. **Firestore.** Открыть консоль → после прохода по разделу новых документов и чтений нет.
13. **Навигация.** Back из детали возвращает в список с сохранёнными фильтрами и поисковым запросом.

---

## 15. Следующие шаги (вне этой задачи)

1. Перевод контента на ru/de/es/fr/pt/zh — правка литералов на `.init(en:…, ru:…)` в файлах каталога, без изменений кода.
2. Добавление оставшихся ~19 рекомендаций из исходного анализа в свободные id.
3. Избранное и отметка «прочитано» с синхронизацией между со-родителями.
4. Диплинк из Today: карточка совета дня → релевантная статья Care Guide.
