import Foundation

/// Returns a tip from a local static list, rotating daily.
/// Replaces GeminiDailyTipService — no network call required.
/// Future: swap fetch() body to query a local SwiftData/JSON tip database.
final class StaticDailyTipService: DailyTipService {

    func fetch(context: DailyContext) async throws -> String {
        let tips = Self.tips(for: context.language)
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return tips[(dayIndex - 1) % tips.count]
    }

    // MARK: - Tip Banks

    private static func tips(for language: Language) -> [String] {
        switch language {
        case .russian:  return russianTips
        case .english, .spanish:  return englishTips
        case .german:   return germanTips
        case .french:   return frenchTips
        case .portuguese: return portugueseTips
        }
    }

    private static let russianTips: [String] = [
        "Попробуйте делать лёгкий массаж ножек перед сном — это помогает малышу расслабиться и быстрее уснуть.",
        "Регулярные прогулки на свежем воздухе улучшают сон и укрепляют иммунитет — даже 20 минут имеют значение.",
        "Разговаривайте с малышом во время смены подгузника: ваш голос — лучший стимул для развития речи.",
        "Держите малыша вертикально 10–15 минут после кормления — это снизит дискомфорт от газиков.",
        "Тихая музыка или белый шум помогают создать привычный ритуал засыпания уже с первых недель.",
        "Доверяйте своей интуиции — вы лучший эксперт по своему ребёнку.",
        "Сейчас самое время для тактильных игр: поглаживания, кожа к коже укрепляют вашу связь.",
        "Не забывайте о себе: короткий отдых мамы делает её более внимательной и спокойной.",
        "Следите за сигналами усталости у малыша — зевота и потирание глаз означают, что пора укладывать.",
        "Яркие контрастные предметы на расстоянии 20–30 см отлично стимулируют зрение в первые месяцы.",
    ]

    private static let englishTips: [String] = [
        "A gentle leg massage before bedtime helps your baby relax and fall asleep more easily.",
        "Even a 20-minute walk outdoors improves sleep quality and boosts your baby's immune system.",
        "Talk to your baby during diaper changes — your voice is the best stimulus for language development.",
        "Hold your baby upright for 10–15 minutes after feeding to ease gas discomfort.",
        "Soft music or white noise helps build a consistent sleep routine from the very first weeks.",
        "Trust your instincts — you are the best expert on your own baby.",
        "Now is a great time for touch-based play: gentle strokes and skin-to-skin contact strengthen your bond.",
        "Remember to rest when you can — a rested parent is a calmer, more attentive parent.",
        "Watch for tiredness cues: yawning and eye-rubbing mean it's time to start the sleep routine.",
        "High-contrast objects at 20–30 cm distance are excellent for stimulating vision in the first months.",
    ]

    private static let germanTips: [String] = [
        "Eine sanfte Beinmassage vor dem Schlafengehen hilft Ihrem Baby, sich zu entspannen und leichter einzuschlafen.",
        "Schon ein 20-minütiger Spaziergang verbessert den Schlaf und stärkt das Immunsystem Ihres Babys.",
        "Sprechen Sie beim Wickeln mit Ihrem Baby — Ihre Stimme ist der beste Sprachentwicklungsreiz.",
        "Halten Sie das Baby 10–15 Minuten nach dem Füttern aufrecht, um Blähungen zu lindern.",
        "Sanfte Musik oder weißes Rauschen helfen, von Anfang an eine gleichmäßige Schlafroutine aufzubauen.",
        "Vertrauen Sie Ihrem Instinkt — Sie sind der beste Experte für Ihr eigenes Kind.",
        "Jetzt ist eine gute Zeit für Berührungsspiele: sanftes Streicheln und Haut-zu-Haut-Kontakt stärken Ihre Bindung.",
        "Vergessen Sie nicht, sich auszuruhen — ein ausgeruhter Elternteil ist ein ruhigerer und aufmerksamerer Elternteil.",
        "Achten Sie auf Müdigkeitssignale: Gähnen und Augenreiben bedeuten, dass es Zeit für die Schlafroutine ist.",
        "Kontrastreiche Gegenstände in 20–30 cm Entfernung regen in den ersten Monaten das Sehvermögen hervorragend an.",
    ]

    private static let frenchTips: [String] = [
        "Un doux massage des jambes avant le coucher aide votre bébé à se détendre et à s’endormir plus facilement.",
        "Même une promenade de 20 minutes en plein air améliore le sommeil et renforce le système immunitaire de votre bébé.",
        "Parlez à votre bébé pendant le change — votre voix est le meilleur stimulant pour le développement du langage.",
        "Tenez votre bébé droit pendant 10 à 15 minutes après la tétée pour soulager l’inconfort lié aux gaz.",
        "Une musique douce ou un bruit blanc aide à instaurer un rituel d’endormissement régulier dès les premières semaines.",
        "Faites confiance à votre instinct — vous êtes la meilleure experte de votre propre bébé.",
        "C’est le moment idéal pour les jeux de contact : les câlins et le peau à peau renforcent votre lien.",
        "Pensez à vous reposer quand vous le pouvez — un parent reposé est plus calme et plus attentif.",
        "Repérez les signes de fatigue : bâillements et frottement des yeux signifient qu’il est temps de commencer le rituel du coucher.",
        "Les objets très contrastés à 20–30 cm de distance stimulent excellemment la vision durant les premiers mois.",
    ]

    private static let portugueseTips: [String] = [
        "Uma massagem suave nas perninhas antes de dormir ajuda o seu bebé a relaxar e a adormecer mais facilmente.",
        "Mesmo um passeio de 20 minutos ao ar livre melhora a qualidade do sono e reforça o sistema imunitário do seu bebé.",
        "Fale com o seu bebé durante a muda da fralda — a sua voz é o melhor estímulo para o desenvolvimento da linguagem.",
        "Mantenha o seu bebé na vertical durante 10–15 minutos após a mamada para aliviar o desconforto dos gases.",
        "Música suave ou ruído branco ajudam a criar um ritual de sono constante desde as primeiras semanas.",
        "Confie no seu instinto — é a melhor especialista no seu próprio bebé.",
        "Agora é uma ótima altura para brincadeiras de toque: festinhas e o contacto pele com pele fortalecem a vossa ligação.",
        "Não se esqueça de descansar quando puder — uma mãe descansada é mais calma e mais atenta.",
        "Esteja atenta aos sinais de cansaço: bocejos e esfregar dos olhos indicam que é hora de começar o ritual do sono.",
        "Objetos de alto contraste a 20–30 cm de distância são excelentes para estimular a visão nos primeiros meses.",
    ]
}
