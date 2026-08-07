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
