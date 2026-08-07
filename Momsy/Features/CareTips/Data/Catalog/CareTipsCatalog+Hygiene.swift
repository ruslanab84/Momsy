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
