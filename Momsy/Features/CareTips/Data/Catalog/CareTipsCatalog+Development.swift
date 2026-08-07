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
