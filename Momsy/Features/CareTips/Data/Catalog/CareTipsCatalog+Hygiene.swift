import Foundation

extension CareTipsCatalog {
    static let hygiene: [CareTip] = [

        CareTip(
            id: 1201, category: .hygiene, icon: "bandage.fill", ageFrom: 0, ageTo: 2,
            title: LocalizedText(
                en: "Umbilical cord care: clean, dry and uncovered",
                ru: "Уход за пупочной ранкой: чисто, сухо и открыто",
                de: "Nabelschnurpflege: sauber, trocken und offen",
                es: "Cuidado del cordón umbilical: limpio, seco y al aire",
                fr: "Entretien du cordon ombilical : propre, sec et découvert",
                pt: "Cuidados com o cordão umbilical: limpo, seco e descoberto"
            ),
            summary: LocalizedText(
                en: "Air is the main treatment — the stump falls off on its own in one to three weeks",
                ru: "Главное «лекарство» — воздух: остаток пуповины отпадает сам через одну-три недели",
                de: "Luft ist die Hauptbehandlung – der Stumpf fällt in ein bis drei Wochen von selbst ab",
                es: "El aire es el tratamiento principal: el muñón se cae solo en una a tres semanas",
                fr: "L'air est le traitement principal : le moignon tombe tout seul en une à trois semaines.",
                pt: "O ar é o principal tratamento – o coto cai sozinho em uma a três semanas"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Leave the stump exposed to air as much as possible.",
                    "Fold the nappy down below the stump so it never rubs or traps moisture.",
                    "Keep it dry: sponge baths until it has fallen off and the base has healed.",
                    "If it gets soiled, clean with plain water and let it air-dry completely.",
                    "Let it detach by itself — never pull, even if it is hanging by a thread."
                ],
                ru: [
                    "Как можно чаще оставляйте остаток пуповины открытым для воздуха.",
                    "Подворачивайте подгузник ниже пупка, чтобы он не натирал и не удерживал влагу.",
                    "Держите область сухой: до отпадения и заживления обходитесь обтираниями.",
                    "Если область загрязнилась, промойте чистой водой и дайте полностью высохнуть на воздухе.",
                    "Дайте остатку отпасть самому — не отрывайте, даже если он держится на волоске."
                ],
                de: [
                    "Lassen Sie den Stumpf so viel wie möglich der Luft ausgesetzt.",
                    "Falten Sie die Windel unter dem Stumpf nach unten, damit sie nie reibt oder Feuchtigkeit speichert.",
                    "Halten Sie es trocken: Schwammtäder, bis es abgefallen ist und die Basis verheilt ist.",
                    "Wenn es verschmutzt wird, mit klarem Wasser reinigen und vollständig an der Luft trocknen lassen.",
                    "Lassen Sie es von selbst abfallen – ziehen Sie nie daran, auch wenn es an einem Faden hängt."
                ],
                es: [
                    "Deja el muñón al aire todo lo posible.",
                    "Dobla el pañal por debajo del muñón para que nunca roce ni retenga humedad.",
                    "Mantenlo seco: baños con esponja hasta que se caiga y la base cicatrice.",
                    "Si se ensucia, límpialo con agua sola y deja que se seque del todo al aire.",
                    "Deja que se desprenda solo: nunca tires de él, aunque cuelgue de un hilo."
                ],
                fr: [
                    "Laissez la souche exposée à l'air autant que possible.",
                    "Pliez la couche sous le moignon afin qu'elle ne frotte jamais et ne retienne jamais l'humidité.",
                    "Gardez-le au sec : baignez-le à l'éponge jusqu'à ce qu'il tombe et que la base soit cicatrisée.",
                    "S'il est sale, nettoyez-le à l'eau claire et laissez-le sécher complètement à l'air libre.",
                    "Laissez-le se détacher tout seul – ne tirez jamais, même s’il ne tient qu’à un fil.",
                ],
                pt: [
                    "Deixe o coto exposto ao ar tanto quanto possível.",
                    "Dobre a fralda abaixo do coto para que nunca esfregue ou retenha umidade.",
                    "Mantenha-o seco: banhos de esponja até que caia e a base cicatrize.",
                    "Se ficar sujo, limpe com água pura e deixe secar completamente ao ar.",
                    "Deixe-o se soltar sozinho – nunca puxe, mesmo que esteja pendurado por um fio.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "The stump is dead tissue that dries and separates naturally, and the drier it stays the faster that happens. Old routines involving alcohol or antiseptic have largely been dropped because they slow separation without reducing infection in healthy babies. A little dried blood or a slightly unpleasant smell in the final days is expected as it separates.",
                ru: "Остаток пуповины — это отмершая ткань, которая подсыхает и отделяется сама, и чем суше она остаётся, тем быстрее это происходит. От прежних схем с обработкой спиртом или антисептиком в основном отказались: у здоровых детей они замедляют отделение, не снижая риск инфекции. Немного подсохшей крови или слегка неприятный запах в последние дни перед отпадением — ожидаемо.",
                de: "Der Stumpf ist totes Gewebe, das natürlich austrocknet und sich trennt – je trockener es bleibt, desto schneller geschieht dies. Alte Routinen mit Alkohol oder Antiseptikum wurden weitgehend aufgegeben, da sie die Trennung verlangsamen, ohne Infektionen bei gesunden Babys zu reduzieren. Ein wenig getrocknetes Blut oder ein leicht unangenehmer Geruch in den letzten Tagen ist beim Ablösen normal.",
                es: "El muñón es tejido muerto que se seca y se separa de forma natural, y cuanto más seco esté, antes ocurre. Las rutinas antiguas con alcohol o antiséptico se han abandonado en gran medida porque retrasan la separación sin reducir las infecciones en bebés sanos. Algo de sangre seca o un olor algo desagradable en los últimos días es esperable mientras se desprende.",
                fr: "Le moignon est un tissu mort qui sèche et se sépare naturellement, et plus il reste sec, plus cela se produit rapidement. Les anciennes routines impliquant de l'alcool ou des antiseptiques ont été largement abandonnées car elles ralentissent la séparation sans réduire l'infection chez les bébés en bonne santé. Un peu de sang séché ou une odeur légèrement désagréable dans les derniers jours est attendu lors de la séparation.",
                pt: "O coto é um tecido morto que seca e se separa naturalmente, e quanto mais seco fica, mais rápido isso acontece. As antigas rotinas que envolviam álcool ou anti-sépticos foram largamente abandonadas porque retardam a separação sem reduzir a infecção em bebés saudáveis. Espera-se um pouco de sangue seco ou um cheiro levemente desagradável nos últimos dias à medida que se separa."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Covering the stump with the nappy waistband.",
                    "Applying creams, powders, or antiseptic without being told to.",
                    "Full bath immersion before separation.",
                    "Helping it along when it seems ready to come off."
                ],
                ru: [
                    "Закрывать пупок резинкой подгузника.",
                    "Наносить кремы, присыпки или антисептик без назначения врача.",
                    "Полностью погружать ребёнка в ванночку до отпадения остатка.",
                    "«Помогать» остатку отпасть, когда он кажется готовым."
                ],
                de: [
                    "Den Stumpf mit dem Windelbund abdecken.",
                    "Cremes, Puder oder Antiseptikum anwenden, ohne dazu aufgefordert zu werden.",
                    "Vollständiges Bad vor der Trennung eintauchen.",
                    "Helfen, es zu entfernen, wenn es bereit scheint."
                ],
                es: [
                    "Tapar el muñón con la goma del pañal.",
                    "Aplicar cremas, polvos o antiséptico sin indicación médica.",
                    "Baños de inmersión completa antes de que se desprenda.",
                    "Ayudarlo a caer cuando parece que ya está listo."
                ],
                fr: [
                    "Couvrir le moignon avec la ceinture de la couche.",
                    "Appliquer des crèmes, des poudres ou des antiseptiques sans qu’on vous le demande.",
                    "Immersion complète en bain avant séparation.",
                    "L'aider quand il semble prêt à se détacher.",
                ],
                pt: [
                    "Cobrindo o coto com o cós da fralda.",
                    "Aplicar cremes, pós ou anti-sépticos sem ser solicitado.",
                    "Imersão completa no banho antes da separação.",
                    "Ajudando quando parece pronto para sair.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Redness spreading onto the skin around the base.",
                    "Pus, a foul discharge, or ongoing bleeding.",
                    "Your baby cries when the area is touched, or develops a fever.",
                    "The stump has not come away by three weeks."
                ],
                ru: [
                    "Покраснение распространяется на кожу вокруг основания.",
                    "Гной, дурно пахнущие выделения или непрекращающееся кровотечение.",
                    "Ребёнок плачет при прикосновении к этой области или у него поднялась температура.",
                    "Остаток пуповины не отпал к трём неделям."
                ],
                de: [
                    "Rötung breitet sich auf die Haut um die Basis aus.",
                    "Eiter, übler Ausfluss oder anhaltendes Bluten.",
                    "Ihr Baby weint, wenn die Stelle berührt wird, oder entwickelt Fieber.",
                    "Der Stumpf ist nicht in drei Wochen abgefallen."
                ],
                es: [
                    "Enrojecimiento que se extiende a la piel alrededor de la base.",
                    "Pus, secreción maloliente o sangrado que no cesa.",
                    "El bebé llora al tocar la zona, o le sube la fiebre.",
                    "El muñón no se ha desprendido a las tres semanas."
                ],
                fr: [
                    "Rougeur s'étendant sur la peau autour de la base.",
                    "Pus, écoulement nauséabond ou saignement continu.",
                    "Votre bébé pleure lorsque la zone est touchée ou développe de la fièvre.",
                    "Le moignon n'est pas parti depuis trois semaines.",
                ],
                pt: [
                    "Vermelhidão se espalhando pela pele ao redor da base.",
                    "Pus, secreção fétida ou sangramento contínuo.",
                    "Seu bebê chora quando a área é tocada ou fica com febre.",
                    "O coto ainda não saiu há três semanas.",
                ]
            )
        ),

        CareTip(
            id: 1202, category: .hygiene, icon: "drop.fill", ageFrom: 0, ageTo: 3,
            title: LocalizedText(
                en: "Bathing a newborn: short, warm and not every day",
                ru: "Купание новорождённого: коротко, тепло и не каждый день",
                de: "Baden eines Neugeborenen: kurz, warm und nicht jeden Tag",
                es: "Bañar a un recién nacido: corto, templado y no a diario",
                fr: "Baigner un nouveau-né : court, chaud et pas tous les jours",
                pt: "Dar banho em um recém-nascido: curto, quente e não todos os dias"
            ),
            summary: LocalizedText(
                en: "Two or three baths a week at around 37 °C is plenty for new skin",
                ru: "Двух-трёх купаний в неделю при температуре около 37 °C достаточно для новой кожи",
                de: "Zwei- oder dreimal pro Woche Baden bei etwa 37 °C ist ausreichend für neue Haut",
                es: "Dos o tres baños por semana a unos 37 °C bastan para una piel nueva",
                fr: "Deux ou trois bains par semaine à environ 37 °C suffisent amplement pour une peau neuve",
                pt: "Dois ou três banhos por semana a cerca de 37 °C são suficientes para uma pele nova"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Check the water with your elbow or a thermometer — around 37 °C, comfortably warm rather than hot.",
                    "Keep baths to five or ten minutes and fill the water to about 10–13 cm.",
                    "Gather everything first: towel, clean nappy, clothes, water. Never step away, not for a second.",
                    "Support the head and neck with one forearm and hold the outer arm or shoulder with that hand.",
                    "Use plain water in the early weeks, or a small amount of unperfumed baby wash. Top-and-tail on the days between baths."
                ],
                ru: [
                    "Проверяйте воду локтем или термометром — около 37 °C, приятно тёплая, а не горячая.",
                    "Купайте пять-десять минут, наливая воду примерно на 10–13 см.",
                    "Сначала приготовьте всё: полотенце, чистый подгузник, одежду, воду. Никогда не отходите, даже на секунду.",
                    "Поддерживайте голову и шею одним предплечьем, а этой же кистью держите дальнее плечо или ручку.",
                    "В первые недели используйте только воду или небольшое количество детского средства без ароматизаторов. В остальные дни просто подмывайте и умывайте."
                ],
                de: [
                    "Überprüfen Sie das Wasser mit Ihrem Ellbogen oder einem Thermometer – etwa 37 °C, angenehm warm statt heiß.",
                    "Halten Sie Bäder auf fünf bis zehn Minuten und füllen Sie das Wasser auf etwa 10–13 cm.",
                    "Bereiten Sie alles vor: Handtuch, saubere Windel, Kleidung, Wasser. Gehen Sie nie weg, nicht für eine Sekunde.",
                    "Stützen Sie Kopf und Nacken mit einem Unterarm und halten Sie den äußeren Arm oder die Schulter mit dieser Hand.",
                    "Verwenden Sie in den ersten Wochen reines Wasser oder eine kleine Menge unparfümiertes Babywaschmittel. An anderen Tagen einfach Intimpflege machen."
                ],
                es: [
                    "Comprueba el agua con el codo o con un termómetro: unos 37 °C, agradablemente templada y no caliente.",
                    "Que el baño dure cinco o diez minutos, con unos 10–13 cm de agua.",
                    "Prepara todo antes: toalla, pañal limpio, ropa, agua. No te alejes nunca, ni un segundo.",
                    "Sujeta la cabeza y el cuello con un antebrazo y agarra con esa misma mano el brazo o el hombro más alejado.",
                    "Usa solo agua las primeras semanas, o un poco de jabón infantil sin perfume. Los días sin baño, limpia cara y zona del pañal."
                ],
                fr: [
                    "Vérifiez l’eau avec votre coude ou un thermomètre – environ 37 °C, confortablement tiède plutôt que chaude.",
                    "Limitez les bains à cinq ou dix minutes et remplissez l'eau jusqu'à environ 10 à 13 cm.",
                    "Rassemblez d’abord tout : une serviette, une couche propre, des vêtements, de l’eau. Ne vous éloignez jamais, pas une seconde.",
                    "Soutenez la tête et le cou avec un avant-bras et tenez l’extérieur du bras ou de l’épaule avec cette main.",
                    "Utilisez de l’eau claire au cours des premières semaines ou une petite quantité de nettoyant pour bébé non parfumé. Haut et queue les jours entre les bains.",
                ],
                pt: [
                    "Verifique a água com o cotovelo ou um termômetro – em torno de 37 °C, confortavelmente quente, em vez de quente.",
                    "Mantenha os banhos por cinco ou dez minutos e encha a água até cerca de 10–13 cm.",
                    "Reúna tudo primeiro: toalha, fralda limpa, roupa, água. Nunca se afaste, nem por um segundo.",
                    "Apoie a cabeça e o pescoço com um antebraço e segure a parte externa do braço ou ombro com essa mão.",
                    "Use água pura nas primeiras semanas ou uma pequena quantidade de sabonete líquido para bebês sem perfume. Top-and-tail nos dias entre os banhos.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Newborn skin is thinner than adult skin and is still building its protective barrier, so frequent washing and fragranced products strip more than they clean. Two or three baths a week keeps the skin comfortable while the nappy area and face — the parts that actually get dirty — are cleaned daily. Short baths also avoid the rapid heat loss that leaves babies chilled and unsettled afterwards.",
                ru: "Кожа новорождённого тоньше кожи взрослого и ещё формирует защитный барьер, поэтому частое мытьё и средства с ароматизаторами смывают больше, чем очищают. Два-три купания в неделю сохраняют кожу в порядке, тогда как область подгузника и лицо — то, что действительно загрязняется, — очищаются ежедневно. Короткие купания также избавляют от быстрой потери тепла, из-за которой ребёнок мёрзнет и потом беспокоится.",
                de: "Neugeborene Haut ist dünner als Erwachsenenhaut und bildet noch ihre Schutzbarriere, daher entfernt häufiges Waschen und duftende Produkte mehr, als sie reinigen. Zwei- oder dreimal pro Woche Baden hält die Haut komfortabel, während der Windelbereich und das Gesicht – die Teile, die wirklich schmutzig werden – täglich gereinigt werden. Kurze Bäder vermeiden auch den schnellen Wärmeverlust, der Babys abkühlt und danach unruhig macht.",
                es: "La piel del recién nacido es más fina que la del adulto y todavía está construyendo su barrera protectora, así que lavar a menudo y usar productos perfumados retira más de lo que limpia. Dos o tres baños por semana mantienen la piel cómoda, mientras que la zona del pañal y la cara —lo que de verdad se ensucia— se limpian a diario. Los baños cortos también evitan la pérdida rápida de calor que deja al bebé frío e inquieto después.",
                fr: "La peau des nouveau-nés est plus fine que celle des adultes et continue de construire sa barrière protectrice. C'est pourquoi des lavages fréquents et des produits parfumés décapent plus qu'ils ne nettoient. Deux ou trois bains par semaine maintiennent la peau confortable tandis que la zone des couches et le visage – les parties qui se salissent – ​​sont nettoyés quotidiennement. Les bains courts évitent également la perte de chaleur rapide qui laisse les bébés glacés et instables par la suite.",
                pt: "A pele do recém-nascido é mais fina do que a pele do adulto e ainda está a construir a sua barreira protetora, por isso a lavagem frequente e os produtos perfumados retiram mais do que limpam. Dois ou três banhos por semana mantêm a pele confortável enquanto a área da fralda e o rosto – as partes que realmente ficam sujas – são limpos diariamente. Banhos curtos também evitam a rápida perda de calor que depois deixa os bebês gelados e inquietos."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Testing the water with a hand, which is far less sensitive than an elbow.",
                    "Daily baths with soap in the first weeks.",
                    "Bath seats or rings used as a reason to look away.",
                    "Bathing straight after a feed, which often ends in spit-up."
                ],
                ru: [
                    "Проверять воду рукой — она гораздо менее чувствительна, чем локоть.",
                    "Ежедневные купания с мылом в первые недели.",
                    "Считать, что стульчик или круг для купания позволяют отвести взгляд.",
                    "Купать сразу после кормления — это часто заканчивается срыгиванием."
                ],
                de: [
                    "Wasser mit der Hand testen, die viel weniger empfindlich ist als ein Ellbogen.",
                    "Tägliche Bäder mit Seife in den ersten Wochen.",
                    "Badewannen oder Ringe als Grund zu verwenden, um abzusehen.",
                    "Direkt nach der Fütterung baden, was oft mit Aufstoßen endet."
                ],
                es: [
                    "Probar el agua con la mano, mucho menos sensible que el codo.",
                    "Baños diarios con jabón en las primeras semanas.",
                    "Usar asientos o aros de baño como excusa para apartar la vista.",
                    "Bañar justo después de una toma, lo que suele acabar en regurgitación."
                ],
                fr: [
                    "Tester l'eau avec une main, qui est beaucoup moins sensible qu'un coude.",
                    "Bains quotidiens avec du savon les premières semaines.",
                    "Sièges ou anneaux de bain utilisés comme raison pour détourner le regard.",
                    "Se baigner juste après une tétée, qui se termine souvent par des régurgitations.",
                ],
                pt: [
                    "Testar a água com a mão, que é muito menos sensível que o cotovelo.",
                    "Banhos diários com sabonete nas primeiras semanas.",
                    "Assentos de banho ou anéis usados como motivo para desviar o olhar.",
                    "Tomar banho logo após a mamada, que muitas vezes termina em cuspe.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Persistent dry, cracked or weeping patches that do not improve.",
                    "A rash that spreads after bathing.",
                    "Your baby becomes cold and mottled during or after baths."
                ],
                ru: [
                    "Стойкие сухие, потрескавшиеся или мокнущие участки кожи, которые не проходят.",
                    "Сыпь, которая распространяется после купания.",
                    "Ребёнок замерзает, кожа становится мраморной во время или после купания."
                ],
                de: [
                    "Anhaltend trockene, rissige oder nässende Stellen, die sich nicht bessern.",
                    "Ein Ausschlag, der nach dem Baden auftritt.",
                    "Ihr Baby wird während oder nach Bädern kalt und fleckig."
                ],
                es: [
                    "Zonas secas, agrietadas o que supuran de forma persistente y no mejoran.",
                    "Un sarpullido que se extiende después del baño.",
                    "El bebé se queda frío y con la piel moteada durante o después del baño."
                ],
                fr: [
                    "Plaques persistantes sèches, craquelées ou suintantes qui ne s'améliorent pas.",
                    "Une éruption cutanée qui se propage après le bain.",
                    "Votre bébé devient froid et marbré pendant ou après le bain.",
                ],
                pt: [
                    "Manchas persistentes secas, rachadas ou lacrimejantes que não melhoram.",
                    "Uma erupção cutânea que se espalha após o banho.",
                    "Seu bebê fica com frio e manchas durante ou após o banho.",
                ]
            )
        ),

        CareTip(
            id: 1203, category: .hygiene, icon: "wind", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Preventing nappy rash: air time and a barrier",
                ru: "Профилактика пелёночного дерматита: воздушные ванны и защитный крем",
                de: "Windelausschlag verhindern: Luftzeit und eine Schutzbarriere",
                es: "Prevenir la dermatitis del pañal: aire y una barrera",
                fr: "Prévenir l'érythème fessier : du temps d'air et une barrière",
                pt: "Prevenir assaduras: tempo de ar e uma barreira"
            ),
            summary: LocalizedText(
                en: "Change often, dry thoroughly, and let the skin breathe once a day",
                ru: "Меняйте подгузник часто, тщательно просушивайте кожу и раз в день давайте ей подышать",
                de: "Wechseln Sie häufig, trocknen Sie gründlich ab und lassen Sie die Haut einmal täglich atmen",
                es: "Cambia a menudo, seca a fondo y deja que la piel respire una vez al día",
                fr: "Changez-le souvent, séchez-le soigneusement et laissez la peau respirer une fois par jour",
                pt: "Troque frequentemente, seque bem e deixe a pele respirar uma vez por dia"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Change as soon as you notice a wet or dirty nappy, and at least every two to three hours in the early months.",
                    "Clean with water and cotton wool or fragrance-free wipes, front to back.",
                    "Pat completely dry — moisture left in the creases is what starts most rashes.",
                    "Apply a thin layer of barrier cream on clean dry skin if the area looks pink.",
                    "Give ten minutes of nappy-free time on a towel each day."
                ],
                ru: [
                    "Меняйте подгузник сразу, как заметили, что он мокрый или грязный, и не реже чем каждые два-три часа в первые месяцы.",
                    "Очищайте водой с ватой или салфетками без ароматизаторов, движениями спереди назад.",
                    "Просушивайте промакивающими движениями досуха — именно влага в складках чаще всего запускает раздражение.",
                    "Если кожа порозовела, нанесите тонкий слой защитного крема на чистую сухую кожу.",
                    "Каждый день давайте ребёнку десять минут полежать без подгузника на полотенце."
                ],
                de: [
                    "Wechseln Sie die Windel sofort, wenn Sie eine nasse oder schmutzige Windel bemerken, und mindestens alle zwei bis drei Stunden in den frühen Monaten.",
                    "Reinigen Sie mit Wasser und Wattestäbchen oder parfümfreien Tüchern von vorne nach hinten.",
                    "Vollständig trockentupfen – Feuchtigkeit in den Falten ist das, was die meisten Ausschläge verursacht.",
                    "Tragen Sie eine dünne Schicht Schutzcrème auf saubere trockene Haut auf, wenn die Stelle rosa aussieht.",
                    "Geben Sie jedem Tag zehn Minuten windelfrei auf einem Handtuch."
                ],
                es: [
                    "Cambia el pañal en cuanto lo notes mojado o sucio, y al menos cada dos o tres horas en los primeros meses.",
                    "Limpia con agua y algodón o toallitas sin perfume, de delante hacia atrás.",
                    "Seca a toquecitos por completo: la humedad que queda en los pliegues es lo que inicia la mayoría de las irritaciones.",
                    "Aplica una capa fina de crema barrera sobre piel limpia y seca si la zona se ve rosada.",
                    "Dale diez minutos al día sin pañal sobre una toalla."
                ],
                fr: [
                    "Changez-la dès que vous remarquez une couche mouillée ou sale, et au moins toutes les deux à trois heures les premiers mois.",
                    "Nettoyer avec de l'eau et du coton ou des lingettes sans parfum, de l'avant vers l'arrière.",
                    "Séchez complètement en tapotant – l’humidité laissée dans les plis est à l’origine de la plupart des éruptions cutanées.",
                    "Appliquez une fine couche de crème barrière sur une peau propre et sèche si la zone paraît rose.",
                    "Donnez dix minutes de temps sans couches sur une serviette chaque jour.",
                ],
                pt: [
                    "Troque assim que notar uma fralda molhada ou suja e pelo menos a cada duas ou três horas nos primeiros meses.",
                    "Limpe com água e algodão ou lenços sem perfume, da frente para trás.",
                    "Seque completamente – a umidade deixada nas dobras é o que causa a maioria das erupções cutâneas.",
                    "Aplique uma fina camada de creme barreira na pele limpa e seca se a área parecer rosada.",
                    "Dê dez minutos de tempo livre de fraldas em uma toalha todos os dias.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Nappy rash is mostly a moisture problem: wet skin softens, friction breaks the surface, and the ammonia from urine irritates what is left. Air time and thorough drying address the cause directly, which is why they work better than any cream. A barrier ointment then keeps the next wet nappy off skin that is already sore.",
                ru: "Пелёночный дерматит — прежде всего проблема влаги: намокшая кожа размягчается, трение повреждает её поверхность, а аммиак из мочи раздражает всё остальное. Воздушные ванны и тщательное просушивание работают с самой причиной — поэтому они эффективнее любого крема. А защитная мазь потом не даёт следующему мокрому подгузнику контактировать с уже раздражённой кожей.",
                de: "Windelausschlag ist hauptsächlich ein Feuchtigkeitsproblem: nasse Haut wird weich, Reibung zerstört die Oberfläche, und Ammoniak aus dem Urin reizt den Rest. Luftzeit und gründliches Trocknen adressieren direkt die Ursache – deshalb wirken sie besser als jede Creme. Eine Schutzunguentum hält die nächste nasse Windel dann von bereits entzündeter Haut fern.",
                es: "La dermatitis del pañal es sobre todo un problema de humedad: la piel mojada se reblandece, la fricción rompe la superficie y el amoniaco de la orina irrita lo que queda. El tiempo al aire y un secado a fondo atacan la causa directamente, por eso funcionan mejor que cualquier crema. La pomada barrera luego mantiene el siguiente pañal mojado lejos de una piel ya dolorida.",
                fr: "L'érythème fessier est principalement un problème d'humidité : la peau mouillée se ramollit, la friction brise la surface et l'ammoniac de l'urine irrite ce qui reste. Le temps d’aération et un séchage complet s’attaquent directement à la cause, c’est pourquoi ils fonctionnent mieux que n’importe quelle crème. Une pommade barrière éloigne ensuite la prochaine couche mouillée de la peau déjà douloureuse.",
                pt: "As assaduras são principalmente um problema de umidade: a pele molhada amolece, a fricção rompe a superfície e a amônia da urina irrita o que resta. O tempo de ventilação e a secagem completa abordam a causa diretamente, e é por isso que funcionam melhor do que qualquer creme. Uma pomada de barreira mantém a próxima fralda molhada longe da pele que já está dolorida."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Scrubbing sore skin instead of patting it.",
                    "A thick layer of cream over damp skin, which seals the moisture in.",
                    "Fragranced or alcohol-based wipes on broken skin.",
                    "Talcum powder — it can be inhaled and does not help."
                ],
                ru: [
                    "Растирать раздражённую кожу вместо промакивания.",
                    "Наносить толстый слой крема на влажную кожу — это запирает влагу внутри.",
                    "Использовать салфетки с ароматизаторами или спиртом на повреждённой коже.",
                    "Тальк — его можно вдохнуть, и он не помогает."
                ],
                de: [
                    "Wunde Haut reiben statt tupfen.",
                    "Eine dicke Crèmeschicht auf feuchter Haut auftragen, die Feuchtigkeit einschließt.",
                    "Parfümierte oder alkoholbasierte Tücher auf beschädigter Haut verwenden.",
                    "Talkumpuder – es kann eingeatmet werden und hilft nicht."
                ],
                es: [
                    "Frotar la piel irritada en lugar de secarla a toquecitos.",
                    "Una capa gruesa de crema sobre piel húmeda, que sella la humedad dentro.",
                    "Toallitas perfumadas o con alcohol sobre piel dañada.",
                    "Polvos de talco: se pueden inhalar y no ayudan."
                ],
                fr: [
                    "Frotter la peau douloureuse au lieu de la tapoter.",
                    "Une épaisse couche de crème sur la peau humide, qui scelle l'humidité.",
                    "Lingettes parfumées ou à base d'alcool sur peau éraflée.",
                    "Talc — il peut être inhalé et n’aide pas.",
                ],
                pt: [
                    "Esfregar a pele dolorida em vez de dar tapinhas.",
                    "Uma espessa camada de creme sobre a pele úmida, que retém a umidade.",
                    "Toalhetes perfumados ou à base de álcool na pele ferida.",
                    "Pó de talco – pode ser inalado e não ajuda.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "The rash has bright red patches with small spots spreading beyond the edges — this can be thrush.",
                    "Blisters, open sores, or areas of raw weeping skin.",
                    "No improvement after three days of good care.",
                    "Rash plus fever or an unsettled, unwell baby."
                ],
                ru: [
                    "Сыпь с яркими красными участками и мелкими элементами за их границами — это может быть кандидоз.",
                    "Пузыри, открытые ранки или участки мокнущей повреждённой кожи.",
                    "Нет улучшения после трёх дней правильного ухода.",
                    "Сыпь вместе с температурой или ребёнок беспокоен и выглядит нездоровым."
                ],
                de: [
                    "Der Ausschlag hat leuchtend rote Flecken mit kleinen Flecken, die über die Kanten hinausgehen – das kann Soor sein.",
                    "Blasen, offene Wunden oder Bereiche von roher nässender Haut.",
                    "Keine Verbesserung nach drei Tagen guter Pflege.",
                    "Ausschlag plus Fieber oder ein verängstigtes, unwohles Baby."
                ],
                es: [
                    "El sarpullido tiene placas rojo intenso con pequeños puntos que se extienden más allá de los bordes: puede ser candidiasis.",
                    "Ampollas, llagas abiertas o zonas de piel en carne viva que supuran.",
                    "No mejora tras tres días de buenos cuidados.",
                    "Sarpullido con fiebre, o un bebé inquieto y con mal estado general."
                ],
                fr: [
                    "L’éruption présente des taches rouge vif avec de petites taches s’étendant au-delà des bords – il peut s’agir d’un muguet.",
                    "Ampoules, plaies ouvertes ou zones de peau crue et suintante.",
                    "Aucune amélioration après trois jours de bons soins.",
                    "Éruption cutanée et fièvre ou bébé instable et malade.",
                ],
                pt: [
                    "A erupção apresenta manchas vermelhas brilhantes com pequenas manchas espalhadas além das bordas – pode ser candidíase.",
                    "Bolhas, feridas abertas ou áreas de pele em carne viva.",
                    "Nenhuma melhora após três dias de bons cuidados.",
                    "Erupção cutânea com febre ou um bebê instável e indisposto.",
                ]
            )
        ),

        CareTip(
            id: 1204, category: .hygiene, icon: "scissors", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Trimming tiny nails without the drama",
                ru: "Как стричь крошечные ногти без слёз",
                de: "Winzige Nägel schneiden ohne Drama",
                es: "Cortar uñas diminutas sin dramas",
                fr: "Couper les petits ongles sans drame",
                pt: "Aparar unhas minúsculas sem drama"
            ),
            summary: LocalizedText(
                en: "Cut during sleep, follow the natural shape, and file the corners",
                ru: "Стригите во сне, повторяйте естественную форму и подпиливайте уголки",
                de: "Schneiden Sie im Schlaf, folgen Sie der natürlichen Form und feilen Sie die Ecken",
                es: "Corta mientras duerme, sigue la forma natural y lima las esquinas",
                fr: "Coupez pendant le sommeil, suivez la forme naturelle et limez les coins",
                pt: "Corte durante o sono, siga o formato natural e lixe os cantos"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Choose a time when your baby is deeply asleep or relaxed after a bath.",
                    "Press the fingertip pad gently away from the nail before you cut.",
                    "Cut fingernails straight across following the curve, and toenails straight across with no rounding at the corners.",
                    "Smooth the edges with a soft emery board — that is what stops the scratching.",
                    "Expect to trim fingernails roughly weekly and toenails every few weeks."
                ],
                ru: [
                    "Выбирайте время, когда ребёнок крепко спит или расслаблен после купания.",
                    "Перед стрижкой мягко отведите подушечку пальца от ногтя.",
                    "Ногти на руках стригите прямо, следуя изгибу, а на ногах — строго прямо, не закругляя уголки.",
                    "Сгладьте края мягкой пилочкой — именно это избавляет от царапин.",
                    "Ногти на руках обычно нужно стричь примерно раз в неделю, на ногах — раз в несколько недель."
                ],
                de: [
                    "Wählen Sie einen Zeitpunkt, wenn Ihr Baby tief schläft oder sich nach einem Bad entspannt.",
                    "Schieben Sie das Fingerkissen vor dem Schneiden sanft vom Nagel weg.",
                    "Schneiden Sie Fingernägel gerade, der Kurve folgend, und Zehennägel gerade mit abgerundeten Ecken.",
                    "Glätten Sie die Kanten mit einer weichen Nagelfeile – das stoppt das Kratzen.",
                    "Erwarten Sie, Fingernägel etwa wöchentlich zu schneiden und Zehennägel alle paar Wochen."
                ],
                es: [
                    "Elige un momento en el que el bebé duerma profundamente o esté relajado tras el baño.",
                    "Aparta con suavidad la yema del dedo de la uña antes de cortar.",
                    "Corta las uñas de las manos rectas siguiendo la curva, y las de los pies rectas sin redondear las esquinas.",
                    "Suaviza los bordes con una lima blanda: eso es lo que evita los arañazos.",
                    "Cuenta con cortar las uñas de las manos cada semana y las de los pies cada pocas semanas."
                ],
                fr: [
                    "Choisissez un moment où votre bébé est profondément endormi ou détendu après un bain.",
                    "Appuyez doucement sur le bout du doigt pour l'éloigner de l'ongle avant de couper.",
                    "Coupez les ongles directement en suivant la courbe et les ongles des pieds en ligne droite sans arrondir les coins.",
                    "Lissez les bords avec une planche d’émeri souple – c’est ce qui empêche les rayures.",
                    "Attendez-vous à couper les ongles environ une fois par semaine et les ongles des pieds toutes les quelques semaines.",
                ],
                pt: [
                    "Escolha um horário em que seu bebê esteja dormindo profundamente ou relaxado após o banho.",
                    "Pressione a ponta do dedo suavemente para longe da unha antes de cortar.",
                    "Corte as unhas em linha reta seguindo a curva e as unhas dos pés em linha reta, sem arredondamento nos cantos.",
                    "Alise as bordas com uma lixa macia – é isso que evita arranhões.",
                    "Espere aparar as unhas aproximadamente semanalmente e as dos pés a cada poucas semanas.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Newborn nails are soft and grow surprisingly fast, and sharp edges leave scratches on the face within hours. The reason to file rather than cut short is that the nail bed sits very close to the free edge in babies, so cutting deep is both painful and an infection risk. Rounded toenail corners are the main cause of ingrown nails later.",
                ru: "Ногти новорождённого мягкие и растут удивительно быстро, а острые края оставляют царапины на лице уже через несколько часов. Подпиливать лучше, чем стричь коротко, потому что у младенцев ногтевое ложе расположено очень близко к свободному краю: срезать глубоко и больно, и рискованно из-за инфекции. Закруглённые уголки ногтей на ногах — главная причина их врастания в будущем.",
                de: "Neugeborene Nägel sind weich und wachsen überraschend schnell, und scharfe Kanten hinterlassen Kratzer im Gesicht innerhalb von Stunden. Der Grund zum Feilen statt kurz schneiden ist, dass das Nagelbett bei Babys sehr nah am freien Rand sitzt, daher ist tiefes Schneiden sowohl schmerzhaft als auch ein Infektionsrisiko. Abgerundete Zehennägelecken sind die Hauptursache für eingewachsene Nägel später.",
                es: "Las uñas del recién nacido son blandas y crecen sorprendentemente rápido, y los bordes afilados dejan arañazos en la cara en cuestión de horas. Conviene limar en lugar de cortar muy corto porque en los bebés el lecho ungueal queda muy cerca del borde libre, así que cortar profundo duele y es un riesgo de infección. Redondear las esquinas de las uñas de los pies es la causa principal de uñas encarnadas más adelante.",
                fr: "Les ongles des nouveau-nés sont doux et poussent étonnamment vite, et les bords tranchants laissent des rayures sur le visage en quelques heures. La raison pour laquelle il faut limer plutôt que couper court est que le lit de l'ongle se trouve très près du bord libre chez les bébés, donc couper profondément est à la fois douloureux et présente un risque d'infection. Les coins arrondis des ongles des pieds sont la principale cause des ongles incarnés plus tard.",
                pt: "As unhas dos recém-nascidos são macias e crescem surpreendentemente rápido, e as pontas afiadas deixam arranhões no rosto em poucas horas. A razão para lixar em vez de cortar é que o leito ungueal fica muito próximo da borda livre dos bebês, portanto, cortar profundamente é doloroso e representa um risco de infecção. Os cantos arredondados das unhas são a principal causa de unhas encravadas posteriormente."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Biting the nails off — the adult mouth carries bacteria into any small tear.",
                    "Cutting too short in the hope of going longer between trims.",
                    "Rounding toenail corners.",
                    "Scratch mittens used permanently, which limits the hand exploration babies need."
                ],
                ru: [
                    "Обкусывать ногти — из рта взрослого бактерии попадают в любую микротрещину.",
                    "Стричь слишком коротко в надежде реже возвращаться к этой процедуре.",
                    "Закруглять уголки ногтей на ногах.",
                    "Постоянно держать ребёнка в антицарапках — это ограничивает нужное ему исследование мира руками."
                ],
                de: [
                    "Die Nägel abbeißen – der Erwachsenenmund trägt Bakterien in jeden kleinen Riss.",
                    "Zu kurz schneiden in der Hoffnung, länger zwischen den Schnitten zu gehen.",
                    "Zehennägelecken abrunden.",
                    "Kratzmittel permanent verwenden, was die Handexporation begrenzt, die Babys brauchen."
                ],
                es: [
                    "Morder las uñas para quitarlas: la boca adulta lleva bacterias a cualquier pequeña rotura.",
                    "Cortar demasiado corto con la esperanza de espaciar los cortes.",
                    "Redondear las esquinas de las uñas de los pies.",
                    "Usar manoplas antiarañazos de forma permanente, lo que limita la exploración con las manos que el bebé necesita."
                ],
                fr: [
                    "Se ronger les ongles – la bouche d’un adulte transporte des bactéries dans n’importe quelle petite déchirure.",
                    "Coupe trop courte dans l'espoir d'aller plus longtemps entre les coupes.",
                    "Coins arrondis des ongles.",
                    "Mitaines à gratter utilisées en permanence, ce qui limite l'exploration des mains dont les bébés ont besoin.",
                ],
                pt: [
                    "Roer as unhas – a boca do adulto transporta bactérias para qualquer pequena lágrima.",
                    "Cortar muito curto na esperança de prolongar o tempo entre os cortes.",
                    "Arredondando os cantos das unhas.",
                    "Luvas anti-riscos usadas permanentemente, o que limita a exploração das mãos que os bebês precisam.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Redness, swelling or pus around a nail fold.",
                    "An ingrown toenail that does not settle.",
                    "A cut that keeps bleeding after a few minutes of gentle pressure."
                ],
                ru: [
                    "Покраснение, отёк или гной вокруг ногтевого валика.",
                    "Вросший ноготь на ноге, который не проходит.",
                    "Порез продолжает кровить после нескольких минут мягкого прижатия."
                ],
                de: [
                    "Rötung, Schwellung oder Eiter um eine Nagelfalte.",
                    "Ein eingewachsener Zehennagel, der sich nicht beruhigt.",
                    "Ein Schnitt, der nach ein paar Minuten sanftem Druck weiterblütet."
                ],
                es: [
                    "Enrojecimiento, hinchazón o pus alrededor del pliegue de una uña.",
                    "Una uña encarnada en el pie que no se resuelve.",
                    "Un corte que sigue sangrando tras unos minutos de presión suave."
                ],
                fr: [
                    "Rougeur, gonflement ou pus autour d'un pli de l'ongle.",
                    "Un ongle incarné qui ne s'installe pas.",
                    "Une coupure qui continue de saigner après quelques minutes de légère pression.",
                ],
                pt: [
                    "Vermelhidão, inchaço ou pus ao redor da prega ungueal.",
                    "Uma unha encravada que não resolve.",
                    "Um corte que continua sangrando após alguns minutos de pressão suave.",
                ]
            )
        ),

        CareTip(
            id: 1205, category: .hygiene, icon: "nose.fill", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Nose and ear care: clean the outside only",
                ru: "Уход за носом и ушами: чистим только снаружи",
                de: "Nase- und Ohrenpflege: nur die Außenseite reinigen",
                es: "Cuidado de nariz y oídos: limpia solo por fuera",
                fr: "Soins du nez et des oreilles : nettoyer l’extérieur uniquement",
                pt: "Cuidados com nariz e ouvidos: limpe apenas a parte externa"
            ),
            summary: LocalizedText(
                en: "Saline and a soft cloth — nothing goes inside the nostril or ear canal",
                ru: "Солевой раствор и мягкая салфетка — ничего не вводим в нос и слуховой проход",
                de: "Salzwasser und ein weiches Tuch – nichts geht in Nasenlöcher oder Gehörgang",
                es: "Suero fisiológico y un paño suave: nada entra en la nariz ni en el conducto auditivo",
                fr: "Une solution saline et un chiffon doux : rien ne pénètre dans la narine ou le conduit auditif",
                pt: "Solução salina e um pano macio – nada entra na narina ou no canal auditivo"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Wipe the outer ear and the folds behind it with a damp cloth, then dry.",
                    "For a blocked nose, put one or two saline drops in each nostril and wait a minute.",
                    "Clear softened mucus with a bulb syringe or nasal aspirator, or let your baby sneeze it out.",
                    "Try saline about ten minutes before a feed, so your baby can breathe while sucking.",
                    "Leave earwax alone — it moves out of the canal by itself."
                ],
                ru: [
                    "Протрите наружное ухо и складки за ним влажной салфеткой, затем просушите.",
                    "При заложенности носа закапайте одну-две капли солевого раствора в каждую ноздрю и подождите минуту.",
                    "Уберите размягчённую слизь аспиратором или грушей либо дайте ребёнку вычихнуть её.",
                    "Закапывайте солевой раствор примерно за десять минут до кормления, чтобы ребёнок мог дышать во время сосания.",
                    "Ушную серу не трогайте — она выходит из слухового прохода сама."
                ],
                de: [
                    "Wischen Sie das äußere Ohr und die Falten dahinter mit einem feuchten Tuch ab, dann trocknen.",
                    "Bei verstopfter Nase geben Sie ein oder zwei Tropfen Kochsalzlösung in jedes Nasenloch und warten eine Minute.",
                    "Entfernen Sie verdünnte Flüssigkeit mit einer Ballonspritze oder einem Nasensauger, oder lassen Sie Ihr Baby niesen.",
                    "Versuchen Sie Salzwasser etwa zehn Minuten vor einer Fütterung, damit Ihr Baby während des Saugens atmen kann.",
                    "Lassen Sie Ohrenschmalz allein – es verlässt den Gehörgang von selbst."
                ],
                es: [
                    "Limpia la oreja por fuera y los pliegues de detrás con un paño húmedo, y después seca.",
                    "Si tiene la nariz taponada, pon una o dos gotas de suero fisiológico en cada fosa y espera un minuto.",
                    "Retira el moco ya ablandado con una pera de succión o un aspirador nasal, o deja que lo expulse estornudando.",
                    "Prueba el suero unos diez minutos antes de una toma, para que pueda respirar mientras succiona.",
                    "No toques la cera: sale sola del conducto auditivo."
                ],
                fr: [
                    "Essuyez l'oreille externe et les plis derrière avec un chiffon humide, puis séchez.",
                    "Pour un nez bouché, mettez une ou deux gouttes de solution saline dans chaque narine et attendez une minute.",
                    "Éliminez le mucus ramolli avec une seringue à poire ou un aspirateur nasal, ou laissez votre bébé l'éternuer.",
                    "Essayez une solution saline environ dix minutes avant une tétée, afin que votre bébé puisse respirer pendant qu'il tète.",
                    "Laissez le cérumen tranquille : il sort tout seul du canal.",
                ],
                pt: [
                    "Limpe a parte externa da orelha e as dobras atrás dela com um pano úmido e depois seque.",
                    "Para nariz entupido, coloque uma ou duas gotas de soro fisiológico em cada narina e espere um minuto.",
                    "Limpe o muco amolecido com uma seringa ou aspirador nasal, ou deixe seu bebê espirrar.",
                    "Experimente solução salina cerca de dez minutos antes da mamada, para que seu bebê possa respirar enquanto chupa.",
                    "Deixe a cera em paz – ela sai sozinha do canal.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Babies breathe mainly through the nose for the first months, so even a modest blockage disrupts feeding and sleep more than it would in an adult. Saline thins mucus so it can move; it does not medicate anything, which is why it is safe to repeat. Cotton buds push wax deeper and can damage a very short, delicate ear canal, so the rule is simple: nothing smaller than your fingertip goes in.",
                ru: "Первые месяцы дети дышат в основном носом, поэтому даже небольшая заложенность нарушает кормление и сон сильнее, чем у взрослого. Солевой раствор разжижает слизь, чтобы она могла выйти; он не является лекарством — поэтому его безопасно применять повторно. Ватные палочки продвигают серу глубже и могут повредить очень короткий и нежный слуховой проход, так что правило простое: ничего тоньше вашего пальца внутрь не вводится.",
                de: "Babys atmen in den ersten Monaten hauptsächlich durch die Nase, daher stört selbst eine bescheidene Blockierung die Fütterung und den Schlaf mehr als bei einem Erwachsenen. Salzwasser verdünnt Schleim, damit er sich bewegen kann; es ist kein Medikament, daher ist es sicher wiederzuholten. Wattestäbchen schieben Wachs tiefer hinein und können einen sehr kurzen, empfindlichen Gehörgang beschädigen, also lautet die Regel: nichts Kleineres als Ihr Fingertipp geht hinein.",
                es: "Los bebés respiran sobre todo por la nariz durante los primeros meses, así que incluso una obstrucción moderada altera la alimentación y el sueño más que en un adulto. El suero fluidifica el moco para que pueda salir; no medica nada, y por eso es seguro repetirlo. Los bastoncillos empujan la cera más adentro y pueden dañar un conducto auditivo muy corto y delicado, así que la regla es simple: nada más fino que la punta de tu dedo entra ahí.",
                fr: "Les bébés respirent principalement par le nez pendant les premiers mois, de sorte que même un léger blocage perturbe l'alimentation et le sommeil plus que chez un adulte. La solution saline fluidifie le mucus pour qu’il puisse bouger ; cela ne médicamente rien, c’est pourquoi il est prudent de le répéter. Les cotons-tiges poussent le cérumen plus profondément et peuvent endommager un conduit auditif très court et délicat, la règle est donc simple : rien de plus petit que le bout de votre doigt n'y entre.",
                pt: "Os bebés respiram principalmente pelo nariz durante os primeiros meses, por isso mesmo um bloqueio modesto perturba a alimentação e o sono mais do que num adulto. A solução salina afina o muco para que ele possa se mover; não medica nada, por isso é seguro repetir. Os cotonetes empurram a cera mais profundamente e podem danificar um canal auditivo muito curto e delicado, então a regra é simples: nada menor do que a ponta do seu dedo entra."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Cotton buds inside the nostril or ear canal.",
                    "Ear candles, which are ineffective and carry a burn risk.",
                    "Aggressive suction that irritates the nasal lining and increases swelling.",
                    "Decongestant drops for infants without medical advice."
                ],
                ru: [
                    "Ватные палочки внутри носа или слухового прохода.",
                    "Ушные свечи — они неэффективны и опасны ожогом.",
                    "Слишком активное отсасывание, которое раздражает слизистую носа и усиливает отёк.",
                    "Сосудосуживающие капли младенцу без назначения врача."
                ],
                de: [
                    "Wattestäbchen im Nasenloch oder Gehörgang.",
                    "Ohrenkerzen, die unwirksam sind und ein Brandrisiko tragen.",
                    "Aggressive Absaugung, die die Nasenschleimhaut reizt und Schwellungen verstärkt.",
                    "Abschwellende Tropfen für Säuglinge ohne ärztliche Beratung."
                ],
                es: [
                    "Bastoncillos dentro de la nariz o del conducto auditivo.",
                    "Velas óticas: no funcionan y conllevan riesgo de quemadura.",
                    "Succión agresiva, que irrita la mucosa nasal y aumenta la inflamación.",
                    "Gotas descongestionantes para lactantes sin indicación médica."
                ],
                fr: [
                    "Des cotons-tiges à l’intérieur de la narine ou du conduit auditif.",
                    "Les bougies auriculaires, inefficaces et présentant un risque de brûlure.",
                    "Aspiration agressive qui irrite la muqueuse nasale et augmente le gonflement.",
                    "Gouttes décongestionnantes pour nourrissons sans avis médical.",
                ],
                pt: [
                    "Cotonetes dentro da narina ou canal auditivo.",
                    "Velas auriculares, que são ineficazes e apresentam risco de queimadura.",
                    "Sucção agressiva que irrita o revestimento nasal e aumenta o inchaço.",
                    "Gotas descongestionantes para bebês sem orientação médica.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby pulls at one ear alongside fever or unusual crying.",
                    "Discharge or blood from the ear.",
                    "A blocked nose that stops your baby feeding, or breathing that looks laboured.",
                    "Any suspicion an object has been pushed into the nose or ear."
                ],
                ru: [
                    "Ребёнок тянет себя за одно ухо на фоне температуры или необычного плача.",
                    "Выделения или кровь из уха.",
                    "Заложенность носа, из-за которой ребёнок не может есть, или затруднённое дыхание.",
                    "Любое подозрение, что в нос или ухо попал посторонний предмет."
                ],
                de: [
                    "Ihr Baby zieht an einem Ohr mit Fieber oder ungewöhnlichem Weinen.",
                    "Ausfluss oder Blut aus dem Ohr.",
                    "Eine verstopfte Nase, die Ihr Baby füttert, oder anstrengend aussehende Atmung.",
                    "Jeder Verdacht, dass ein Gegenstand in Nase oder Ohr gedrückt wurde."
                ],
                es: [
                    "El bebé se tira de una oreja junto con fiebre o llanto inusual.",
                    "Supuración o sangre saliendo del oído.",
                    "Nariz taponada que impide comer, o respiración que parece costosa.",
                    "Cualquier sospecha de que se ha introducido un objeto en la nariz o el oído."
                ],
                fr: [
                    "Votre bébé tire une oreille en même temps que de la fièvre ou des pleurs inhabituels.",
                    "Écoulement ou sang de l’oreille.",
                    "Un nez bouché qui empêche votre bébé de s'alimenter ou une respiration qui semble difficile.",
                    "Tout soupçon qu'un objet a été poussé dans le nez ou l'oreille.",
                ],
                pt: [
                    "Seu bebê puxa uma orelha junto com febre ou choro incomum.",
                    "Descarga ou sangue do ouvido.",
                    "Um nariz entupido que impede o bebê de mamar ou uma respiração que parece difícil.",
                    "Qualquer suspeita de que um objeto foi enfiado no nariz ou na orelha.",
                ]
            )
        )
    ]
}
