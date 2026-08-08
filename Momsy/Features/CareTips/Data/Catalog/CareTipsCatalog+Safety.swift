import Foundation

extension CareTipsCatalog {
    static let safety: [CareTip] = [

        CareTip(
            id: 1501, category: .safety, icon: "car.fill", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Car seat basics: rear-facing, snug harness, no coats",
                ru: "Автокресло: спиной вперёд, плотные ремни, без верхней одежды",
                de: "Grundlagen des Autositzes: rückwärts gewandt, fester Gurt, keine Mäntel",
                es: "Lo básico de la silla del coche: a contramarcha, arnés ceñido, sin abrigos",
                fr: "Bases du siège auto : dos à la route, harnais bien ajusté, pas de manteau",
                pt: "Noções básicas de assento de carro: voltado para trás, arnês confortável, sem casacos"
            ),
            summary: LocalizedText(
                en: "Rear-facing as long as the seat allows, and the harness flat against the body",
                ru: "Спиной вперёд столько, сколько позволяет кресло, ремни — плотно к телу",
                de: "Rückwärts gewandt, solange der Sitz es zulässt, und der Gurt flach am Körper",
                es: "A contramarcha todo el tiempo que permita la silla, y el arnés plano contra el cuerpo",
                fr: "Dos à la route tant que le siège le permet et le harnais à plat contre le corps",
                pt: "Voltado para trás enquanto o assento permitir e o arnês encostado ao corpo"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Keep the seat rear-facing for as long as your seat's height and weight limits permit.",
                    "Set the harness slots at or just below the shoulders in a rear-facing seat.",
                    "Tighten until you cannot pinch a horizontal fold of webbing at the shoulder.",
                    "Position the chest clip at armpit level.",
                    "Remove bulky coats and snowsuits; strap your baby in first, then lay the coat or a blanket over the harness."
                ],
                ru: [
                    "Устанавливайте кресло спиной вперёд так долго, как позволяют ограничения по росту и весу для вашей модели.",
                    "В кресле, установленном спиной вперёд, ремни должны выходить на уровне плеч или чуть ниже.",
                    "Затягивайте так, чтобы у плеча нельзя было защипнуть горизонтальную складку ремня.",
                    "Нагрудный зажим располагайте на уровне подмышек.",
                    "Снимайте объёмные куртки и комбинезоны: сначала пристегните ребёнка, затем накройте его курткой или пледом поверх ремней."
                ],
                de: [
                    "Halten Sie den Sitz so lange rückwärts gewandt, wie die Höhen- und Gewichtsbeschränkungen Ihres Sitzes es zulassen.",
                    "Stellen Sie die Gurtschlitze auf Schulterhöhe oder knapp darunter in einem rückwärts gewandten Sitz ein.",
                    "Ziehen Sie an, bis Sie keine horizontale Falte des Gurtes an der Schulter einklemmen können.",
                    "Positionieren Sie den Brustclip auf Achselhöhe.",
                    "Entfernen Sie sperrige Mäntel und Schneeanzüge; schnallen Sie Ihr Baby zuerst an, dann legen Sie den Mantel oder eine Decke über den Gurt."
                ],
                es: [
                    "Mantén la silla a contramarcha tanto tiempo como permitan sus límites de altura y peso.",
                    "Coloca las ranuras del arnés a la altura de los hombros o justo por debajo cuando va a contramarcha.",
                    "Tensa hasta que no puedas pellizcar un pliegue horizontal de la cinta a la altura del hombro.",
                    "Sitúa el broche del pecho a la altura de las axilas.",
                    "Quita abrigos gruesos y buzos de nieve: ata primero al bebé y luego pon el abrigo o una manta por encima del arnés."
                ],
                fr: [
                    "Gardez le siège orienté vers l'arrière aussi longtemps que les limites de hauteur et de poids de votre siège le permettent.",
                    "Réglez les fentes du harnais au niveau ou juste en dessous des épaules dans un siège dos à la route.",
                    "Serrez jusqu'à ce que vous ne puissiez pas pincer un pli horizontal de la sangle au niveau de l'épaule.",
                    "Positionnez le clip pectoral au niveau des aisselles.",
                    "Retirez les manteaux et les habits de neige volumineux ; Attachez d'abord votre bébé, puis posez le manteau ou une couverture sur le harnais.",
                ],
                pt: [
                    "Mantenha o assento voltado para trás enquanto os limites de altura e peso do assento permitirem.",
                    "Coloque as ranhuras do arnês nos ombros ou logo abaixo deles em um assento voltado para trás.",
                    "Aperte até que você não consiga prender uma dobra horizontal da correia no ombro.",
                    "Posicione o clipe torácico na altura das axilas.",
                    "Remova casacos volumosos e roupas de neve; amarre primeiro o bebê e depois coloque o casaco ou cobertor sobre o arnês.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "In a frontal collision a rear-facing seat spreads the force across the whole back and supports the head and neck, which is exactly what a baby's proportionally heavy head and soft neck need. A padded coat compresses to almost nothing under crash forces, leaving several centimetres of slack in a harness that felt tight in the driveway — which is how a correctly fastened child ends up loose in a crash.",
                ru: "При лобовом столкновении кресло, установленное спиной вперёд, распределяет нагрузку по всей спине и поддерживает голову и шею — именно то, что нужно ребёнку с непропорционально тяжёлой головой и слабой шеей. Утеплённая куртка при ударе сжимается почти до нуля, оставляя несколько сантиметров слабины в ремнях, которые казались тугими во дворе, — так правильно пристёгнутый ребёнок оказывается свободным в момент аварии.",
                de: "Bei einem Frontalaufprall verteilt ein rückwärts gewandter Sitz die Kraft über den ganzen Rücken und stützt Kopf und Nacken – genau das, was ein Baby mit verhältnismäßig schwerem Kopf und weichem Nacken braucht. Ein gepolsterter Mantel wird unter Aufprallkräften zu fast nichts komprimiert und hinterlässt mehrere Zentimeter Spielraum in einem Gurt, der in der Einfahrt eng wirkte – so endet ein richtig angeschnalltes Kind in einem Aufprall lose.",
                es: "En una colisión frontal, una silla a contramarcha reparte la fuerza por toda la espalda y sujeta la cabeza y el cuello, que es justo lo que necesita un bebé con una cabeza proporcionalmente pesada y un cuello blando. Un abrigo acolchado se comprime hasta casi nada con las fuerzas del impacto y deja varios centímetros de holgura en un arnés que parecía tenso en el portal: así es como un niño bien atado acaba suelto en un choque.",
                fr: "En cas de collision frontale, un siège orienté vers l'arrière répartit la force sur tout le dos et soutient la tête et le cou, ce dont a exactement besoin la tête proportionnellement lourde et le cou mou d'un bébé. Un manteau rembourré ne se comprime presque plus sous les forces d'un accident, laissant plusieurs centimètres de mou dans un harnais qui semblait serré dans l'allée - c'est ainsi qu'un enfant correctement attaché se retrouve lâche lors d'un accident.",
                pt: "Numa colisão frontal, um assento virado para trás distribui a força por todas as costas e apoia a cabeça e o pescoço, que é exactamente o que a cabeça proporcionalmente pesada e o pescoço macio de um bebé precisam. Um casaco acolchoado se comprime até quase nada sob as forças do impacto, deixando vários centímetros de folga em um arnês que parecia apertado na entrada da garagem – e é assim que uma criança corretamente amarrada acaba solta em um acidente."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Turning forward-facing on a birthday rather than at the seat's limit.",
                    "A loose harness or a chest clip sitting on the tummy.",
                    "Winter coats, snowsuits or aftermarket padding under the straps.",
                    "Second-hand seats of unknown history, or any seat involved in a crash."
                ],
                ru: [
                    "Разворачивать кресло лицом вперёд «по дню рождения», а не по достижении ограничений кресла.",
                    "Слабо затянутые ремни или нагрудный зажим, съехавший на живот.",
                    "Зимние куртки, комбинезоны или сторонние подкладки под ремнями.",
                    "Бывшие в употреблении кресла с неизвестной историей или любое кресло, побывавшее в аварии."
                ],
                de: [
                    "Zum Geburtstag umdrehen statt bis zur Grenze des Sitzes.",
                    "Ein loser Gurt oder ein Brustclip, der auf dem Bauch sitzt.",
                    "Wintermäntel, Schneeanzüge oder Nachkauf-Polsterung unter den Gurten.",
                    "Gebrauchte Sitze mit unbekannter Vorgeschichte oder jeder Sitz, der in einen Unfall verwickelt war."
                ],
                es: [
                    "Girar la silla al sentido de la marcha por un cumpleaños y no al llegar al límite de la silla.",
                    "Un arnés flojo o el broche del pecho colocado sobre la barriga.",
                    "Abrigos de invierno, buzos de nieve o acolchados no homologados bajo las cintas.",
                    "Sillas de segunda mano de historial desconocido, o cualquier silla que haya sufrido un accidente."
                ],
                fr: [
                    "Se tourner vers l'avant le jour d'un anniversaire plutôt qu'à la limite du siège.",
                    "Un harnais lâche ou une pince pectorale posée sur le ventre.",
                    "Manteaux d'hiver, combinaisons de neige ou rembourrage de rechange sous les bretelles.",
                    "Sièges d'occasion d'histoire inconnue, ou tout siège impliqué dans un accident.",
                ],
                pt: [
                    "Virar voltado para a frente no aniversário e não no limite do assento.",
                    "Um arnês solto ou um clipe no peito colocado na barriga.",
                    "Casacos de inverno, roupas de neve ou estofamento de reposição sob as alças.",
                    "Assentos usados de história desconhecida ou qualquer assento envolvido em um acidente.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby's head slumps forward or breathing sounds laboured in the seat — check the recline angle urgently.",
                    "Premature or low birth weight babies may need a car seat tolerance check before discharge.",
                    "After any collision, have your baby assessed even if they seem completely fine."
                ],
                ru: [
                    "Голова ребёнка заваливается вперёд или дыхание в кресле кажется затруднённым — срочно проверьте угол наклона.",
                    "Недоношенным детям и детям с низким весом при рождении перед выпиской может потребоваться проверка переносимости автокресла.",
                    "После любого столкновения покажите ребёнка врачу, даже если он выглядит совершенно здоровым."
                ],
                de: [
                    "Der Kopf Ihres Babys sackt nach vorne oder die Atmung im Sitz klingt mühsam – überprüfen Sie den Neigungswinkel dringend.",
                    "Frühgeborene oder untergewichtige Babys benötigen möglicherweise vor der Entlassung einen Autositz-Toleranztest.",
                    "Nach einem Aufprall sollte Ihr Baby untersucht werden, auch wenn es völlig in Ordnung zu sein scheint."
                ],
                es: [
                    "La cabeza del bebé se le va hacia delante o su respiración suena costosa en la silla: revisa el ángulo de reclinado con urgencia.",
                    "Los bebés prematuros o de bajo peso al nacer pueden necesitar una prueba de tolerancia a la silla antes del alta.",
                    "Tras cualquier colisión, haz que valoren al bebé aunque parezca estar perfectamente."
                ],
                fr: [
                    "La tête de votre bébé s'affaisse vers l'avant ou les bruits de respiration sont pénibles dans le siège : vérifiez de toute urgence l'angle d'inclinaison.",
                    "Les bébés prématurés ou de faible poids à la naissance peuvent avoir besoin d’un contrôle de tolérance du siège d’auto avant leur sortie.",
                    "Après toute collision, faites évaluer votre bébé même s’il semble tout à fait bien.",
                ],
                pt: [
                    "A cabeça do seu bebê cai para a frente ou há sons respiratórios difíceis no assento - verifique o ângulo de reclinação com urgência.",
                    "Bebês prematuros ou com baixo peso ao nascer podem precisar de uma verificação de tolerância à cadeirinha antes da alta.",
                    "Após qualquer colisão, avalie seu bebê, mesmo que ele pareça completamente bem.",
                ]
            )
        ),

        CareTip(
            id: 1502, category: .safety, icon: "exclamationmark.triangle.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Never step away from the changing table",
                ru: "Никогда не отходите от пеленального столика",
                es: "Nunca te apartes del cambiador",
                fr: "Ne vous éloignez jamais de la table à langer",
                pt: "Nunca se afaste do trocador"
            ),
            summary: LocalizedText(
                en: "One hand stays on your baby, always — rolling arrives without warning",
                ru: "Одна рука всегда на ребёнке — первый переворот случается без предупреждения",
                es: "Una mano siempre sobre el bebé: el primer volteo llega sin avisar",
                fr: "Une main reste toujours sur votre bébé – le roulement arrive sans avertissement",
                pt: "Uma mão permanece em seu bebê, sempre – o rolar chega sem avisar"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Keep everything you need within arm's reach before you start.",
                    "Keep one hand on your baby's tummy or chest throughout, including while reaching for wipes.",
                    "If you must leave for any reason, take your baby with you or put them on the floor.",
                    "Consider changing on a mat on the floor from the newborn stage.",
                    "Use the strap if your changing table has one, but never as a substitute for your hand."
                ],
                ru: [
                    "Заранее положите всё необходимое на расстоянии вытянутой руки.",
                    "Всё время держите одну руку на животе или груди ребёнка, в том числе когда тянетесь за салфетками.",
                    "Если нужно отойти по любой причине, возьмите ребёнка с собой или положите его на пол.",
                    "Рассмотрите вариант переодевать ребёнка на коврике на полу уже с периода новорождённости.",
                    "Используйте ремень, если он есть на столике, но никогда не как замену своей руке."
                ],
                es: [
                    "Ten todo lo que necesitas al alcance de la mano antes de empezar.",
                    "Mantén una mano sobre la barriga o el pecho del bebé todo el rato, incluso al estirarte a por las toallitas.",
                    "Si tienes que salir por lo que sea, llévate al bebé contigo o déjalo en el suelo.",
                    "Plantéate cambiarlo sobre una colchoneta en el suelo desde recién nacido.",
                    "Usa la correa si el cambiador la tiene, pero nunca como sustituto de tu mano."
                ],
                fr: [
                    "Gardez tout ce dont vous avez besoin à portée de main avant de commencer.",
                    "Gardez une main sur le ventre ou la poitrine de votre bébé, y compris lorsque vous attrapez des lingettes.",
                    "Si vous devez partir pour quelque raison que ce soit, emmenez votre bébé avec vous ou posez-le par terre.",
                    "Pensez à vous changer sur un tapis au sol dès le stade nouveau-né.",
                    "Utilisez la sangle si votre table à langer en est équipée, mais jamais pour remplacer votre main.",
                ],
                pt: [
                    "Mantenha tudo o que você precisa ao alcance do braço antes de começar.",
                    "Mantenha uma mão na barriga ou no peito do bebê o tempo todo, inclusive enquanto pega os lenços umedecidos.",
                    "Se por algum motivo você precisar sair, leve seu bebê com você ou coloque-o no chão.",
                    "Considere colocar um tapete no chão desde o recém-nascido.",
                    "Use a alça se o seu trocador tiver, mas nunca como substituto da mão.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "The first roll is unpredictable and often happens weeks before parents expect it — many falls involve a baby who had never rolled before. Falls from changing height are among the most common injuries in the first year, and the head takes most of the impact. The single-hand rule works because it does not depend on you correctly predicting when your baby will develop a new skill.",
                ru: "Первый переворот непредсказуем и часто случается на несколько недель раньше, чем ожидают родители: во многих падениях участвует ребёнок, который до этого ни разу не переворачивался. Падения с высоты пеленального столика — одна из самых частых травм на первом году, и основной удар приходится на голову. Правило «одна рука на ребёнке» работает потому, что не зависит от вашей способности угадать, когда появится новый навык.",
                es: "El primer volteo es impredecible y suele ocurrir semanas antes de lo que los padres esperan: en muchas caídas el bebé nunca se había dado la vuelta. Las caídas desde la altura del cambiador están entre las lesiones más frecuentes del primer año, y la cabeza recibe la mayor parte del impacto. La regla de la mano encima funciona porque no depende de que aciertes cuándo tu bebé desarrollará una nueva habilidad.",
                fr: "Le premier roulement est imprévisible et se produit souvent des semaines avant que les parents ne s'y attendent : de nombreuses chutes impliquent un bébé qui n'avait jamais roulé auparavant. Les chutes de hauteur variable font partie des blessures les plus courantes au cours de la première année, et la tête subit la majeure partie de l'impact. La règle d’une seule main fonctionne car elle ne dépend pas de votre capacité à prédire correctement le moment où votre bébé développera une nouvelle compétence.",
                pt: "A primeira rolagem é imprevisível e muitas vezes acontece semanas antes do esperado pelos pais – muitas quedas envolvem um bebê que nunca havia rolado antes. As quedas devido à mudança de altura estão entre as lesões mais comuns no primeiro ano, e a cabeça sofre a maior parte do impacto. A regra da mão única funciona porque não depende de você prever corretamente quando seu bebê desenvolverá uma nova habilidade."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Turning to grab a nappy from a shelf just out of reach.",
                    "Trusting a strap or raised sides to hold a determined baby.",
                    "Answering the door or the phone mid-change.",
                    "Assuming a baby who has not rolled yet cannot roll today."
                ],
                ru: [
                    "Отвернуться, чтобы взять подгузник с полки чуть дальше вытянутой руки.",
                    "Полагаться на ремень или бортики, что они удержат настойчивого ребёнка.",
                    "Открывать дверь или отвечать на звонок посреди переодевания.",
                    "Считать, что ребёнок, который ещё не переворачивался, не перевернётся сегодня."
                ],
                es: [
                    "Girarte a coger un pañal de una estantería que queda justo fuera de tu alcance.",
                    "Confiar en que una correa o unos bordes elevados sujeten a un bebé decidido.",
                    "Abrir la puerta o contestar al teléfono a mitad del cambio.",
                    "Suponer que un bebé que aún no se ha dado la vuelta no puede hacerlo hoy."
                ],
                fr: [
                    "Se retourner pour attraper une couche sur une étagère juste hors de portée.",
                    "Faire confiance à une sangle ou à des côtés surélevés pour retenir un bébé déterminé.",
                    "Répondre à la porte ou au téléphone en cours de changement.",
                    "En supposant qu'un bébé qui n'a pas encore roulé ne puisse pas rouler aujourd'hui.",
                ],
                pt: [
                    "Virando-se para pegar uma fralda em uma prateleira fora de alcance.",
                    "Confiar em uma alça ou nas laterais elevadas para segurar um bebê determinado.",
                    "Atender a porta ou o telefone no meio da mudança.",
                    "Supondo que um bebê que ainda não rolou não possa rolar hoje.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Any fall from height in a baby under a year — seek advice even without visible injury.",
                    "Loss of consciousness, vomiting, unusual drowsiness, or a bulging soft spot after a fall — emergency.",
                    "A swelling on the head, or any change in behaviour, feeding or responsiveness."
                ],
                ru: [
                    "Любое падение с высоты у ребёнка до года — обратитесь к врачу даже без видимых повреждений.",
                    "Потеря сознания, рвота, необычная сонливость или выбухающий родничок после падения — экстренная ситуация.",
                    "Припухлость на голове или любые изменения в поведении, кормлении и реакциях."
                ],
                es: [
                    "Cualquier caída desde altura en un bebé menor de un año: consulta aunque no haya lesión visible.",
                    "Pérdida de conciencia, vómitos, somnolencia inusual o fontanela abombada tras la caída: urgencia.",
                    "Un bulto en la cabeza, o cualquier cambio en el comportamiento, la alimentación o la reactividad."
                ],
                fr: [
                    "Toute chute de hauteur chez un bébé de moins d'un an : demandez conseil même sans blessure visible.",
                    "Perte de conscience, vomissements, somnolence inhabituelle ou point mou bombé après une chute – urgence.",
                    "Un gonflement de la tête ou tout changement de comportement, d'alimentation ou de réactivité.",
                ],
                pt: [
                    "Qualquer queda de altura em um bebê com menos de um ano – procure orientação mesmo sem ferimentos visíveis.",
                    "Perda de consciência, vômito, sonolência incomum ou ponto fraco e protuberante após uma queda – emergência.",
                    "Um inchaço na cabeça ou qualquer alteração no comportamento, alimentação ou capacidade de resposta.",
                ]
            )
        ),

        CareTip(
            id: 1503, category: .safety, icon: "shield.lefthalf.filled", ageFrom: 5, ageTo: 24,
            title: LocalizedText(
                en: "Baby-proof before your baby moves",
                ru: "Обезопасьте дом до того, как ребёнок поедет",
                es: "Adapta la casa antes de que el bebé se mueva",
                fr: "À l'épreuve des bébés avant que votre bébé ne bouge",
                pt: "À prova de bebês antes que ele se mexa"
            ),
            summary: LocalizedText(
                en: "Do it at five months, not on the day they first crawl",
                ru: "Делайте это в пять месяцев, а не в день первого ползания",
                es: "Hazlo a los cinco meses, no el día en que gatee por primera vez",
                fr: "Faites-le à cinq mois, pas le jour où ils rampent pour la première fois",
                pt: "Faça isso aos cinco meses, não no dia em que rastejarem pela primeira vez"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Get down on the floor and look at the room from your baby's eye level.",
                    "Anchor bookcases, chests of drawers and televisions to the wall.",
                    "Fit stair gates at the top and bottom, and lock away cleaning products, medicines and small batteries.",
                    "Move cords and blind pulls out of reach and tie them up high.",
                    "Check for anything that fits through a toilet-roll tube — that is roughly the choking size limit."
                ],
                ru: [
                    "Опуститесь на пол и посмотрите на комнату с высоты глаз ребёнка.",
                    "Закрепите к стене книжные шкафы, комоды и телевизоры.",
                    "Поставьте ворота безопасности вверху и внизу лестницы, уберите под замок бытовую химию, лекарства и мелкие батарейки.",
                    "Уберите провода и шнуры жалюзи из зоны досягаемости и подвяжите их повыше.",
                    "Проверьте, что нет предметов, проходящих во втулку от туалетной бумаги, — это примерный предел размера, опасного удушьем."
                ],
                es: [
                    "Ponte en el suelo y mira la habitación a la altura de los ojos del bebé.",
                    "Ancla a la pared estanterías, cómodas y televisores.",
                    "Coloca barreras arriba y abajo de la escalera, y guarda bajo llave productos de limpieza, medicamentos y pilas pequeñas.",
                    "Aparta cables y cordones de persianas de su alcance y átalos en alto.",
                    "Comprueba si algo cabe por el tubo de un rollo de papel higiénico: ese es más o menos el límite de tamaño para atragantamiento."
                ],
                fr: [
                    "Allongez-vous sur le sol et regardez la pièce à la hauteur des yeux de votre bébé.",
                    "Ancrez les bibliothèques, les commodes et les téléviseurs au mur.",
                    "Installez des barrières d'escalier en haut et en bas et verrouillez les produits de nettoyage, les médicaments et les petites piles.",
                    "Déplacez les cordons et les stores hors de portée et attachez-les en hauteur.",
                    "Vérifiez tout ce qui passe dans un tube de papier toilette – c'est à peu près la limite de taille d'étouffement.",
                ],
                pt: [
                    "Deite-se no chão e olhe para o quarto do nível dos olhos do bebê.",
                    "Fixe estantes, cômodas e televisões na parede.",
                    "Coloque portões de escada na parte superior e inferior e guarde produtos de limpeza, medicamentos e pilhas pequenas.",
                    "Mova os cabos e as persianas para fora do alcance e amarre-os bem alto.",
                    "Verifique se há alguma coisa que passe por um tubo de papel higiênico – esse é aproximadamente o limite de tamanho de asfixia.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Mobility arrives suddenly: a baby who has never moved forward can cross a room within a day of working out how. Preparing early means you are not improvising while also watching a newly mobile child. Furniture tip-overs and button batteries deserve particular attention because both cause severe harm quickly and both are easy to overlook.",
                ru: "Подвижность появляется внезапно: ребёнок, который никогда не двигался вперёд, может пересечь комнату уже на следующий день после того, как понял, как это делается. Подготовка заранее избавляет от необходимости импровизировать, одновременно присматривая за только что «поехавшим» ребёнком. Опрокидывание мебели и дисковые батарейки заслуживают особого внимания: и то и другое быстро приводит к тяжёлым последствиям и легко упускается из виду.",
                es: "La movilidad llega de golpe: un bebé que nunca ha avanzado puede cruzar una habitación al día siguiente de descubrir cómo hacerlo. Prepararlo pronto significa no tener que improvisar mientras vigilas a un niño recién móvil. Los vuelcos de muebles y las pilas de botón merecen atención especial porque ambos causan daños graves rápidamente y ambos se pasan por alto con facilidad.",
                fr: "La mobilité arrive soudainement : un bébé qui n’a jamais avancé peut traverser une pièce en une journée après avoir compris comment. Se préparer tôt signifie ne pas improviser tout en surveillant un enfant nouvellement mobile. Les renversements de meubles et les piles boutons méritent une attention particulière, car tous deux provoquent rapidement de graves dommages et sont faciles à négliger.",
                pt: "A mobilidade chega de repente: um bebê que nunca avançou pode atravessar uma sala um dia depois de descobrir como. Preparar-se cedo significa que você não está improvisando enquanto observa uma criança recém-móvel. Os tombos de móveis e as baterias tipo botão merecem atenção especial porque ambos causam danos graves rapidamente e são fáceis de ignorar."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Waiting for the first crawl before starting.",
                    "Forgetting rooms your baby is 'never' in — bathroom, kitchen, grandparents' house.",
                    "Pressure-fitted gates at the top of stairs, where screw-fitted ones are needed.",
                    "Handbags left on the floor with medication or coins inside."
                ],
                ru: [
                    "Ждать первого ползания, прежде чем начать.",
                    "Забывать про комнаты, где ребёнок «никогда» не бывает, — ванную, кухню, квартиру бабушки и дедушки.",
                    "Ставить распорные ворота наверху лестницы, где нужны прикрученные к стене.",
                    "Оставлять на полу сумки с лекарствами или монетами внутри."
                ],
                es: [
                    "Esperar al primer gateo para empezar.",
                    "Olvidar las habitaciones donde el bebé «nunca» está: baño, cocina, casa de los abuelos.",
                    "Barreras a presión en lo alto de la escalera, donde hacen falta atornilladas.",
                    "Bolsos dejados en el suelo con medicamentos o monedas dentro."
                ],
                fr: [
                    "Attendre la première exploration avant de commencer.",
                    "Oublier les pièces dans lesquelles votre bébé n'est « jamais » : salle de bain, cuisine, maison des grands-parents.",
                    "Portails à pression en haut des escaliers, là où des portails à vis sont nécessaires.",
                    "Sacs à main laissés par terre contenant des médicaments ou des pièces de monnaie à l’intérieur.",
                ],
                pt: [
                    "Aguardando o primeiro rastreamento antes de começar.",
                    "Esquecer os quartos onde seu bebê 'nunca' está - banheiro, cozinha, casa dos avós.",
                    "Portões pressurizados no topo das escadas, onde são necessários portões aparafusados.",
                    "Bolsas deixadas no chão com medicamentos ou moedas dentro.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Any suspicion your baby has swallowed a button battery or a magnet — go to emergency immediately, do not wait for symptoms.",
                    "Suspected poisoning — call emergency services and keep the packaging with you.",
                    "Choking that clears but is followed by ongoing coughing or noisy breathing."
                ],
                ru: [
                    "Любое подозрение, что ребёнок проглотил дисковую батарейку или магнит, — немедленно в скорую помощь, не ждите симптомов.",
                    "Подозрение на отравление — вызывайте экстренные службы и держите упаковку при себе.",
                    "Эпизод удушья, который прошёл, но после него сохраняется кашель или шумное дыхание."
                ],
                es: [
                    "Cualquier sospecha de que el bebé se ha tragado una pila de botón o un imán: acude a urgencias de inmediato, no esperes a que haya síntomas.",
                    "Sospecha de intoxicación: llama a los servicios de emergencia y lleva contigo el envase.",
                    "Un atragantamiento que se resuelve pero deja tos persistente o respiración ruidosa."
                ],
                fr: [
                    "Si vous soupçonnez que votre bébé a avalé une pile bouton ou un aimant, rendez-vous immédiatement aux urgences, n'attendez pas les symptômes.",
                    "Empoisonnement suspecté : appelez les services d'urgence et conservez l'emballage avec vous.",
                    "Un étouffement qui disparaît mais est suivi d'une toux continue ou d'une respiration bruyante.",
                ],
                pt: [
                    "Qualquer suspeita de que seu bebê tenha engolido uma bateria tipo botão ou um ímã – vá para a emergência imediatamente, não espere pelos sintomas.",
                    "Suspeita de envenenamento – ligue para os serviços de emergência e guarde a embalagem com você.",
                    "Asfixia que desaparece, mas é seguida por tosse contínua ou respiração ruidosa.",
                ]
            )
        ),

        CareTip(
            id: 1504, category: .safety, icon: "drop.triangle.fill", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Water safety: never out of arm's reach",
                ru: "Безопасность на воде: всегда на расстоянии вытянутой руки",
                es: "Seguridad en el agua: nunca fuera del alcance del brazo",
                fr: "La sécurité aquatique : jamais hors de portée",
                pt: "Segurança na água: nunca fora do alcance do braço"
            ),
            summary: LocalizedText(
                en: "A few centimetres of water is enough, and drowning is silent",
                ru: "Достаточно нескольких сантиметров воды, и утопление происходит беззвучно",
                es: "Bastan unos centímetros de agua, y el ahogamiento es silencioso",
                fr: "Quelques centimètres d’eau suffisent et la noyade est silencieuse",
                pt: "Bastam alguns centímetros de água e o afogamento é silencioso"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Keep a hand on your baby for the entire bath, every time.",
                    "Empty the bath immediately afterwards.",
                    "Keep toilet lids down and bathroom doors closed; buckets and basins emptied after use.",
                    "Set the household hot water thermostat to a safe limit and always run cold water into the bath first.",
                    "Treat bath seats and rings as toys, not as safety devices."
                ],
                ru: [
                    "Держите руку на ребёнке всё время купания, каждый раз.",
                    "Сразу после купания сливайте воду.",
                    "Держите крышку унитаза опущенной, дверь в ванную закрытой, а вёдра и тазы — пустыми после использования.",
                    "Выставьте на водонагревателе безопасный предел температуры и всегда наливайте в ванночку сначала холодную воду.",
                    "Относитесь к стульчикам и кругам для купания как к игрушкам, а не средствам безопасности."
                ],
                es: [
                    "Mantén una mano sobre el bebé durante todo el baño, siempre.",
                    "Vacía la bañera inmediatamente después.",
                    "Deja bajada la tapa del inodoro y cerrada la puerta del baño; vacía cubos y barreños tras usarlos.",
                    "Ajusta el termostato del agua caliente a un límite seguro y echa siempre primero el agua fría en la bañera.",
                    "Trata los asientos y aros de baño como juguetes, no como dispositivos de seguridad."
                ],
                fr: [
                    "Gardez une main sur votre bébé pendant tout le bain, à chaque fois.",
                    "Videz la baignoire immédiatement après.",
                    "Gardez les couvercles des toilettes baissés et les portes des salles de bains fermées ; seaux et bassines vidés après utilisation.",
                    "Réglez le thermostat d'eau chaude domestique à une limite sûre et faites toujours couler de l'eau froide dans le bain en premier.",
                    "Considérez les sièges et les anneaux de bain comme des jouets et non comme des dispositifs de sécurité.",
                ],
                pt: [
                    "Mantenha a mão em seu bebê durante todo o banho, sempre.",
                    "Esvazie a banheira imediatamente a seguir.",
                    "Mantenha as tampas dos vasos sanitários abaixadas e as portas dos banheiros fechadas; baldes e bacias esvaziados após o uso.",
                    "Defina o termostato de água quente doméstica para um limite seguro e sempre coloque água fria na banheira primeiro.",
                    "Trate os assentos e anéis de banho como brinquedos, não como dispositivos de segurança.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Infant drowning happens in seconds, in very little water, and almost silently — there is no splashing or shouting to alert you. A baby who slips under cannot right themselves, and the reflex response makes it worse rather than better. Scalds are the other bathroom risk: a baby's skin burns at lower temperatures and in less time than an adult's.",
                ru: "Утопление младенца происходит за секунды, в совсем небольшом количестве воды и почти беззвучно — не будет ни плеска, ни крика, которые вас предупредят. Ребёнок, соскользнувший под воду, не может подняться сам, а рефлекторная реакция только ухудшает положение. Второй риск в ванной — ожоги: кожа ребёнка обжигается при более низкой температуре и за меньшее время, чем кожа взрослого.",
                es: "El ahogamiento infantil ocurre en segundos, con muy poca agua y casi en silencio: no hay chapoteos ni gritos que te avisen. Un bebé que se desliza bajo el agua no puede incorporarse solo, y la respuesta refleja empeora las cosas en lugar de mejorarlas. Las quemaduras son el otro riesgo del baño: la piel de un bebé se quema a menos temperatura y en menos tiempo que la de un adulto.",
                fr: "La noyade d'un nourrisson se produit en quelques secondes, dans très peu d'eau et presque silencieusement : il n'y a pas d'éclaboussures ni de cris pour vous alerter. Un bébé qui glisse ne peut pas se redresser, et la réponse réflexe aggrave la situation plutôt que de l'améliorer. Les brûlures sont l'autre risque dans la salle de bain : la peau d'un bébé brûle à des températures plus basses et en moins de temps que celle d'un adulte.",
                pt: "O afogamento infantil acontece em segundos, em muito pouca água e quase silenciosamente – não há respingos ou gritos para alertá-lo. Um bebê que escorrega não consegue se endireitar e a resposta reflexa piora a situação em vez de melhorar. As queimaduras são outro risco no banheiro: a pele de um bebê queima em temperaturas mais baixas e em menos tempo do que a de um adulto."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Leaving the room for a towel or a phone.",
                    "Asking an older sibling to supervise.",
                    "Running hot water into the bath while the baby is already in it.",
                    "Buckets or paddling pools left with water in them."
                ],
                ru: [
                    "Выйти из комнаты за полотенцем или телефоном.",
                    "Просить старшего ребёнка присмотреть.",
                    "Доливать горячую воду, когда ребёнок уже в ванночке.",
                    "Оставлять вёдра или надувные бассейны с водой."
                ],
                es: [
                    "Salir de la habitación a por una toalla o el móvil.",
                    "Pedirle a un hermano mayor que vigile.",
                    "Añadir agua caliente a la bañera con el bebé ya dentro.",
                    "Dejar cubos o piscinas hinchables con agua dentro."
                ],
                fr: [
                    "Quitter la pièce pour une serviette ou un téléphone.",
                    "Demander à un frère ou une sœur aîné de superviser.",
                    "Faire couler de l’eau chaude dans le bain alors que bébé y est déjà.",
                    "Seaux ou pataugeoires laissés avec de l'eau dedans.",
                ],
                pt: [
                    "Sair do quarto para pegar uma toalha ou um telefone.",
                    "Pedir a um irmão mais velho para supervisionar.",
                    "Colocar água quente na banheira enquanto o bebê já está nela.",
                    "Baldes ou piscinas infantis deixadas com água.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Any submersion, even brief, followed by coughing, breathing changes or drowsiness — seek care immediately.",
                    "A scald that blisters, covers a large area, or affects the face, hands or nappy area.",
                    "Vomiting or unusual sleepiness in the hours after any water incident."
                ],
                ru: [
                    "Любое погружение под воду, даже кратковременное, после которого появились кашель, изменения дыхания или сонливость, — немедленно к врачу.",
                    "Ожог с пузырями, обширный ожог или ожог лица, кистей рук либо области подгузника.",
                    "Рвота или необычная сонливость в течение нескольких часов после любого происшествия с водой."
                ],
                es: [
                    "Cualquier inmersión, aunque sea breve, seguida de tos, cambios en la respiración o somnolencia: busca atención de inmediato.",
                    "Una quemadura que forma ampollas, cubre una zona amplia o afecta a la cara, las manos o la zona del pañal.",
                    "Vómitos o somnolencia inusual en las horas siguientes a cualquier incidente con agua."
                ],
                fr: [
                    "Toute immersion, même brève, suivie de toux, de changements respiratoires ou de somnolence – demandez immédiatement des soins.",
                    "Une brûlure qui forme des cloques, couvre une grande surface ou affecte le visage, les mains ou les couches.",
                    "Vomissements ou somnolence inhabituelle dans les heures qui suivent tout incident d'eau.",
                ],
                pt: [
                    "Qualquer submersão, mesmo que breve, seguida de tosse, alterações respiratórias ou sonolência – procure atendimento imediatamente.",
                    "Uma escaldadura que forma bolhas, cobre uma grande área ou afeta o rosto, as mãos ou a área da fralda.",
                    "Vômito ou sonolência incomum nas horas seguintes a qualquer incidente com água.",
                ]
            )
        ),

        CareTip(
            id: 1505, category: .safety, icon: "cross.case.fill", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Be ready for an emergency before you need to be",
                ru: "Подготовьтесь к экстренной ситуации заранее",
                es: "Prepárate para una emergencia antes de necesitarlo",
                fr: "Soyez prêt à faire face à une urgence avant de devoir l'être",
                pt: "Esteja pronto para uma emergência antes de precisar"
            ),
            summary: LocalizedText(
                en: "Save the numbers, take an infant first-aid course, and know your own address",
                ru: "Сохраните номера, пройдите курс первой помощи младенцам и знайте свой адрес наизусть",
                es: "Guarda los números, haz un curso de primeros auxilios para lactantes y sábete tu dirección",
                fr: "Enregistrez les numéros, suivez un cours de premiers secours pour nourrissons et connaissez votre propre adresse",
                pt: "Salve os números, faça um curso de primeiros socorros infantis e saiba seu próprio endereço"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Save your local emergency number and your paediatrician's number in your phone now.",
                    "Write your full address, including the entry code and floor, somewhere visible — people forget it under stress.",
                    "Take an infant first-aid and CPR course; infant technique differs from the adult version and cannot be learned from a video alone.",
                    "Refresh the training every couple of years, and make sure anyone who cares for your baby has done it too.",
                    "Keep a small first-aid kit and your baby's health record where anyone can find them."
                ],
                ru: [
                    "Прямо сейчас сохраните в телефоне номер экстренных служб и номер вашего педиатра.",
                    "Напишите на видном месте полный адрес, включая код домофона и этаж, — в стрессе его забывают.",
                    "Пройдите курс первой помощи и сердечно-лёгочной реанимации для младенцев: техника для детей отличается от взрослой, и по одному видео её не освоить.",
                    "Обновляйте навыки раз в пару лет и убедитесь, что курс прошли все, кто остаётся с ребёнком.",
                    "Держите небольшую аптечку и медицинскую карту ребёнка там, где их сможет найти любой."
                ],
                es: [
                    "Guarda ya en el móvil el número de emergencias de tu zona y el de tu pediatra.",
                    "Escribe tu dirección completa, con código de portal y piso, en un sitio visible: bajo estrés se olvida.",
                    "Haz un curso de primeros auxilios y RCP para lactantes; la técnica infantil no es la del adulto y no se aprende solo con un vídeo.",
                    "Recicla la formación cada par de años y asegúrate de que quien cuide al bebé también la tenga.",
                    "Ten un botiquín pequeño y la cartilla de salud del bebé donde cualquiera pueda encontrarlos."
                ],
                fr: [
                    "Enregistrez dès maintenant votre numéro d'urgence local et le numéro de votre pédiatre sur votre téléphone.",
                    "Écrivez votre adresse complète, y compris le code d'entrée et l'étage, dans un endroit visible – les gens l'oublient sous le stress.",
                    "Suivez un cours de premiers soins pour nourrissons et de RCR ; la technique pour nourrissons diffère de la version adulte et ne peut pas être apprise uniquement à partir d’une vidéo.",
                    "Actualisez la formation tous les deux ans et assurez-vous que toutes les personnes qui s'occupent de votre bébé l'ont également fait.",
                    "Conservez une petite trousse de premiers soins et le carnet de santé de votre bébé à un endroit où tout le monde peut les trouver.",
                ],
                pt: [
                    "Salve agora o seu número de emergência local e o número do seu pediatra no seu telefone.",
                    "Escreva seu endereço completo, incluindo o código de entrada e o andar, em algum lugar visível – as pessoas esquecem dele quando estão estressadas.",
                    "Faça um curso de primeiros socorros e RCP infantil; a técnica infantil difere da versão adulta e não pode ser aprendida apenas com um vídeo.",
                    "Atualize o treinamento a cada dois anos e certifique-se de que todos que cuidam do seu bebê também o façam.",
                    "Mantenha um pequeno kit de primeiros socorros e o registro de saúde do seu bebê onde qualquer pessoa possa encontrá-los.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "In an emergency you will not read instructions or research technique — you will do whatever you have already practised. Infant CPR uses two fingers rather than two hands and a different rate and depth, so adult training does not transfer. Preparing in advance is not pessimism; it is the same reason you check where the exits are on a plane you fully expect to land normally.",
                ru: "В экстренной ситуации вы не будете читать инструкции и искать технику — вы сделаете то, что уже отрабатывали. При реанимации младенца используют два пальца, а не две руки, а также другую частоту и глубину нажатий, поэтому взрослые навыки сюда не переносятся. Готовиться заранее — это не пессимизм: по той же причине вы смотрите, где выходы в самолёте, который наверняка сядет нормально.",
                es: "En una emergencia no vas a leer instrucciones ni a buscar la técnica: harás lo que ya hayas practicado. La RCP en lactantes usa dos dedos en lugar de dos manos, con otro ritmo y otra profundidad, así que la formación de adultos no sirve. Prepararse por adelantado no es pesimismo: es la misma razón por la que miras dónde están las salidas de un avión que esperas que aterrice con normalidad.",
                fr: "En cas d’urgence, vous ne lirez pas d’instructions ou de techniques de recherche – vous ferez ce que vous avez déjà pratiqué. La RCR pour nourrissons utilise deux doigts plutôt que deux mains et une fréquence et une profondeur différentes, de sorte que la formation des adultes n'est pas transférée. Se préparer à l’avance n’est pas du pessimisme ; c'est la même raison pour laquelle vous vérifiez où se trouvent les sorties dans un avion dont vous pensez vraiment qu'il atterrira normalement.",
                pt: "Numa emergência você não lerá instruções ou técnicas de pesquisa – você fará tudo o que já praticou. A RCP infantil usa dois dedos em vez de duas mãos e uma frequência e profundidade diferentes, portanto o treinamento de adultos não é transferido. Preparar-se com antecedência não é pessimismo; é o mesmo motivo pelo qual você verifica onde estão as saídas de um avião que você espera pousar normalmente."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Assuming adult first aid is close enough.",
                    "Relying on a video watched once.",
                    "Leaving carers without emergency contacts or medical details.",
                    "Skipping refresher training after the first year."
                ],
                ru: [
                    "Считать, что взрослой первой помощи «достаточно близко».",
                    "Полагаться на один просмотренный ролик.",
                    "Оставлять тех, кто сидит с ребёнком, без экстренных контактов и медицинских сведений.",
                    "Пропускать повторные курсы после первого года."
                ],
                es: [
                    "Dar por hecho que los primeros auxilios de adultos son suficientemente parecidos.",
                    "Confiar en un vídeo visto una sola vez.",
                    "Dejar a los cuidadores sin contactos de emergencia ni datos médicos.",
                    "Saltarse el reciclaje de la formación después del primer año."
                ],
                fr: [
                    "En supposant que les premiers secours pour adultes soient suffisamment proches.",
                    "S'appuyer sur une vidéo regardée une fois.",
                    "Laisser les soignants sans contacts d’urgence ni détails médicaux.",
                    "Sauter une formation de remise à niveau après la première année.",
                ],
                pt: [
                    "Supondo que os primeiros socorros para adultos estejam próximos o suficiente.",
                    "Baseando-se em um vídeo assistido uma vez.",
                    "Deixar os cuidadores sem contatos de emergência ou detalhes médicos.",
                    "Ignorar o treinamento de atualização após o primeiro ano.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Difficulty breathing, blue or grey lips or skin, or unresponsiveness — call emergency services immediately.",
                    "A seizure, or a rash that does not fade under pressure.",
                    "Any choking episode that needed intervention should be assessed afterwards."
                ],
                ru: [
                    "Затруднённое дыхание, синие или серые губы либо кожа, отсутствие реакции — немедленно вызывайте экстренные службы.",
                    "Судороги или сыпь, которая не бледнеет при надавливании.",
                    "Любой эпизод удушья, потребовавший вмешательства, нужно показать врачу после."
                ],
                es: [
                    "Dificultad para respirar, labios o piel azulados o grisáceos, o falta de respuesta: llama de inmediato a emergencias.",
                    "Una convulsión, o un sarpullido que no palidece al presionar.",
                    "Todo episodio de atragantamiento que haya requerido intervención debe valorarse después."
                ],
                fr: [
                    "Difficulté à respirer, lèvres ou peau bleues ou grises, ou insensibilité : appelez immédiatement les services d'urgence.",
                    "Une convulsion ou une éruption cutanée qui ne s’estompe pas sous la pression.",
                    "Tout épisode d’étouffement nécessitant une intervention doit être évalué par la suite.",
                ],
                pt: [
                    "Dificuldade em respirar, lábios ou pele azulados ou acinzentados ou falta de resposta – ligue para os serviços de emergência imediatamente.",
                    "Uma convulsão ou erupção na pele que não desaparece sob pressão.",
                    "Qualquer episódio de engasgo que necessite de intervenção deve ser avaliado posteriormente.",
                ]
            )
        )
    ]
}
