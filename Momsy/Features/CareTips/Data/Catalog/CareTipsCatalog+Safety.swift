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
