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
