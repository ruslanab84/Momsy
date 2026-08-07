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
