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
