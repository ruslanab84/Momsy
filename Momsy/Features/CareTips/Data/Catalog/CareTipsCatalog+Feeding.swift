import Foundation

extension CareTipsCatalog {
    static let feeding: [CareTip] = [

        CareTip(
            id: 1001, category: .feeding, icon: "arrow.up.circle.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Hold your baby upright after every feed",
                ru: "Держите ребёнка вертикально после каждого кормления",
                de: "Halten Sie Ihr Baby nach dem Füttern aufrecht",
                es: "Mantén al bebé incorporado después de cada toma",
                fr: "Gardez votre bébé bien droit après chaque tétée",
                pt: "Segure seu bebê em pé após cada mamada"
            ),
            summary: LocalizedText(
                en: "Ten to fifteen minutes vertical lets swallowed air come up before milk does",
                ru: "Десять-пятнадцать минут столбиком дают воздуху выйти раньше молока",
                de: "Zehn bis fünfzehn Minuten aufrecht lassen die Luft vor der Milch nach oben kommen",
                es: "Diez o quince minutos incorporado permiten que el aire salga antes que la leche",
                fr: "Dix à quinze minutes en position verticale permettent à l’air de sortir avant le lait",
                pt: "Dez a quinze minutos na vertical permitem que o ar engolido suba antes do leite."
            ),
            whatToDo: LocalizedList(
                en: [
                    "Lift your baby onto your shoulder so their chest rests against you and their chin clears your shoulder.",
                    "Support the head and neck with one hand; keep the spine straight rather than curled.",
                    "Stay upright for 10–15 minutes after a full feed, a little longer if your baby is prone to spitting up.",
                    "Pat or stroke the back gently and rhythmically — pressure is never needed.",
                    "Swap to a sitting-on-your-lap hold if your arm tires; the point is the vertical spine, not the exact position."
                ],
                ru: [
                    "Поднимите ребёнка к своему плечу так, чтобы его грудь прилегала к вам, а подбородок был выше вашего плеча.",
                    "Поддерживайте голову и шею одной рукой; спина должна быть прямой, а не скруглённой.",
                    "Держите вертикально 10–15 минут после полного кормления, чуть дольше — если ребёнок часто срыгивает.",
                    "Мягко и ритмично похлопывайте или поглаживайте спинку — давить никогда не нужно.",
                    "Если рука устала, пересадите ребёнка к себе на колени: важна вертикальная спина, а не конкретная поза."
                ],
                de: [
                    "Heben Sie Ihr Baby auf Ihre Schulter, sodass die Brust gegen Sie anliegt und das Kinn über Ihrer Schulter ist.",
                    "Stützen Sie Kopf und Nacken mit einer Hand; halten Sie die Wirbelsäule gerade und nicht gekrümmt.",
                    "Bleiben Sie 10–15 Minuten nach einer vollständigen Mahlzeit aufrecht, etwas länger, wenn Ihr Baby zum Spucken neigt.",
                    "Klopfen oder streicheln Sie den Rücken sanft und rhythmisch — Druck ist niemals erforderlich.",
                    "Wechseln Sie zu einem Halt auf Ihrem Schoß, wenn Ihr Arm müde wird; wichtig ist die aufrechte Wirbelsäule, nicht die exakte Position."
                ],
                es: [
                    "Levante a su bebé sobre su hombro para que su pecho descanse contra usted y su barbilla despeje su hombro.",
                    "Sostenga la cabeza y el cuello con una mano; Mantenga la columna recta en lugar de curvada.",
                    "Manténgase erguido durante 10 a 15 minutos después de una toma completa, un poco más si su bebé es propenso a regurgitar.",
                    "Dé palmaditas o acaricie la espalda suave y rítmicamente; nunca es necesaria presión.",
                    "Cambie a una posición sentada en su regazo si se le cansa el brazo; el punto es la columna vertical, no la posición exacta.",
                ],
                fr: [
                    "Soulevez votre bébé sur votre épaule pour que sa poitrine repose contre vous et que son menton dépasse votre épaule.",
                    "Soutenez la tête et le cou d’une seule main ; gardez la colonne vertébrale droite plutôt que courbée.",
                    "Restez debout pendant 10 à 15 minutes après une tétée complète, un peu plus longtemps si votre bébé a tendance à cracher.",
                    "Tapotez ou caressez le dos doucement et en rythme – la pression n’est jamais nécessaire.",
                    "Passez à une position assise sur vos genoux si votre bras se fatigue ; le point est la colonne verticale, pas la position exacte.",
                ],
                pt: [
                    "Levante o bebê sobre o ombro de forma que o peito dele repouse contra você e o queixo dele fique afastado do ombro.",
                    "Apoie a cabeça e o pescoço com uma mão; mantenha a coluna reta em vez de enrolada.",
                    "Fique em pé por 10 a 15 minutos após uma mamada completa, um pouco mais se o seu bebê tiver tendência a cuspir.",
                    "Dê tapinhas ou acaricie as costas suavemente e ritmicamente – nunca é necessária pressão.",
                    "Troque para sentar no colo se seu braço estiver cansado; o ponto é a coluna vertical, não a posição exata.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Newborns swallow air with almost every feed, and the valve between the stomach and the food pipe is still soft and easily opened. When your baby lies flat straight after a feed, that trapped air pushes milk back up with it. Staying upright lets the air rise above the milk and escape on its own, which usually means less spitting up, fewer squirming episodes and a calmer settle afterwards.",
                ru: "Новорождённые заглатывают воздух почти при каждом кормлении, а клапан между желудком и пищеводом ещё мягкий и легко открывается. Если сразу после еды положить ребёнка горизонтально, задержавшийся воздух выталкивает молоко вместе с собой. В вертикальном положении воздух поднимается над молоком и выходит сам — обычно это означает меньше срыгиваний, меньше беспокойных выгибаний и более спокойное засыпание.",
                de: "Neugeborene schlucken bei fast jedem Füttern Luft, und das Ventil zwischen Magen und Speiseröhre ist noch weich und leicht zu öffnen. Wenn Ihr Baby direkt nach dem Füttern flach liegt, drückt die eingeschlossene Luft die Milch mit nach oben. Wenn Sie aufrecht bleiben, kann die Luft über der Milch aufsteigen und von selbst entweichen, was normalerweise weniger Spucken, weniger Zappeln und eine ruhigere Beruhigung danach bedeutet.",
                es: "Los recién nacidos tragan aire con casi cada alimentación y la válvula entre el estómago y el esófago todavía está blanda y se abre fácilmente. Cuando su bebé se acuesta inmediatamente después de amamantar, el aire atrapado empuja la leche hacia arriba con él. Mantenerse erguido permite que el aire se eleve por encima de la leche y escape por sí solo, lo que generalmente significa menos regurgitaciones, menos episodios de retorcerse y un descanso más tranquilo después.",
                fr: "Les nouveau-nés avalent de l'air à presque chaque tétée, et la valve entre l'estomac et le tube alimentaire est toujours souple et s'ouvre facilement. Lorsque votre bébé est allongé à plat juste après une tétée, cet air emprisonné repousse le lait avec lui. Rester debout permet à l'air de s'élever au-dessus du lait et de s'échapper tout seul, ce qui signifie généralement moins de crachats, moins d'épisodes de tortillement et une installation plus calme par la suite.",
                pt: "Os recém-nascidos engolem ar em quase todas as mamadas, e a válvula entre o estômago e o tubo alimentar ainda está macia e pode ser aberta facilmente. Quando seu bebê fica deitado logo após a mamada, o ar preso empurra o leite de volta com ele. Ficar em pé permite que o ar suba acima do leite e escape por conta própria, o que geralmente significa menos regurgitações, menos episódios de contorção e uma postura mais calma depois."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Putting the baby straight down because they fell asleep at the breast or bottle.",
                    "Curling the body forward so the tummy is compressed — this makes reflux more likely, not less.",
                    "Firm patting in the belief that harder means faster.",
                    "Using a car seat or bouncer as the upright position — the slouched angle folds the tummy."
                ],
                ru: [
                    "Сразу класть ребёнка, потому что он уснул у груди или с бутылочкой.",
                    "Сгибать тело вперёд, сдавливая живот, — так рефлюкс становится вероятнее, а не наоборот.",
                    "Сильно похлопывать в расчёте, что «сильнее — значит быстрее».",
                    "Использовать автокресло или шезлонг как «вертикальное положение» — сутулый угол складывает живот."
                ],
                de: [
                    "Das Baby sofort hinlegen, weil es an der Brust oder Flasche eingeschlafen ist.",
                    "Den Körper nach vorne krümmen, sodass der Bauch gepresst wird — das macht Reflux wahrscheinlicher, nicht weniger.",
                    "Festes Klopfen in der Annahme, dass stärker schneller ist.",
                    "Einen Autositz oder eine Wippe als aufrechte Position verwenden — der gekrümmte Winkel faltet den Bauch."
                ],
                es: [
                    "Poner al bebé derecho hacia abajo porque se quedó dormido con el pecho o el biberón.",
                    "Curvar el cuerpo hacia adelante para comprimir el abdomen: esto hace que el reflujo sea más probable, no menos.",
                    "Palmaditas firmes en la creencia de que más duro significa más rápido.",
                    "Usar un asiento para el automóvil o una hamaca como posición vertical: el ángulo encorvado dobla la barriga.",
                ],
                fr: [
                    "Coucher le bébé directement parce qu'il s'est endormi au sein ou au biberon.",
                    "En courbant le corps vers l'avant pour que le ventre soit comprimé, cela rend le reflux plus probable, pas moins.",
                    "Tapotements fermes, convaincus que plus dur signifie plus vite.",
                    "En utilisant un siège d'auto ou un transat comme position verticale, l'angle affaissé plie le ventre.",
                ],
                pt: [
                    "Colocar o bebê direto no chão porque adormeceu no peito ou na mamadeira.",
                    "Enrolar o corpo para a frente para que a barriga fique comprimida – isso torna o refluxo mais provável, e não menor.",
                    "Tapinhas firmes na crença de que mais difícil significa mais rápido.",
                    "Usar uma cadeirinha de carro ou segurança como posição vertical - o ângulo desleixado dobra a barriga.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Spit-up is green, yellow, or contains blood.",
                    "Your baby arches, screams, or refuses feeds regularly after eating.",
                    "Weight gain slows or nappies become noticeably drier.",
                    "Milk comes back forcefully and repeatedly, not as a gentle dribble."
                ],
                ru: [
                    "Срыгиваемое содержимое зелёное, жёлтое или с кровью.",
                    "Ребёнок регулярно выгибается, кричит или отказывается от еды после кормления.",
                    "Прибавка в весе замедлилась или подгузники стали заметно суше.",
                    "Молоко выходит фонтаном и повторно, а не как небольшое подтекание."
                ],
                de: [
                    "Spucken ist grün, gelb oder enthält Blut.",
                    "Ihr Baby wölbt sich regelmäßig, schreit oder lehnt Mahlzeiten nach dem Essen ab.",
                    "Gewichtszunahme verlangsamt sich oder Windeln werden merklich trockener.",
                    "Milch kommt kräftig und wiederholt zurück, nicht als sanftes Rinnsal."
                ],
                es: [
                    "La regurgitación es verde, amarilla o contiene sangre.",
                    "Su bebé se arquea, grita o se niega a comer con regularidad después de comer.",
                    "El aumento de peso se ralentiza o los pañales se vuelven notablemente más secos.",
                    "La leche regresa con fuerza y repetidamente, no como un suave goteo.",
                ],
                fr: [
                    "Les crachats sont verts, jaunes ou contiennent du sang.",
                    "Votre bébé se cambre, crie ou refuse de se nourrir régulièrement après avoir mangé.",
                    "La prise de poids ralentit ou les couches deviennent sensiblement plus sèches.",
                    "Le lait revient avec force et à plusieurs reprises, et non comme un léger filet.",
                ],
                pt: [
                    "A cusparada é verde, amarela ou contém sangue.",
                    "Seu bebê se arqueia, grita ou recusa a alimentação regularmente depois de comer.",
                    "O ganho de peso diminui ou as fraldas ficam visivelmente mais secas.",
                    "O leite volta com força e repetidamente, não como um gotejamento suave.",
                ]
            )
        ),

        CareTip(
            id: 1002, category: .feeding, icon: "hands.sparkles.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Three burping positions and when each one works",
                ru: "Три позы для отрыжки и когда какая работает",
                de: "Drei Positionen zum Aufstoßen und wann jede funktioniert",
                es: "Tres posturas para sacar los gases y cuándo funciona cada una",
                fr: "Trois positions pour faire roter bébé et savoir quand utiliser chacune",
                pt: "Três posições para arrotar e quando cada uma funciona"
            ),
            summary: LocalizedText(
                en: "If one hold does not work in five minutes, change position instead of patting longer",
                ru: "Если поза не сработала за пять минут, меняйте её, а не продолжайте похлопывать",
                de: "Wenn eine Position in fünf Minuten nicht funktioniert, wechseln Sie sie, anstatt länger zu klopfen",
                es: "Si una postura no funciona en cinco minutos, cámbiala en vez de dar palmaditas más tiempo",
                fr: "Si une position ne fonctionne pas en cinq minutes, changez-la au lieu de tapoter plus longtemps",
                pt: "Se uma espera não funcionar em cinco minutos, mude de posição em vez de dar tapinhas por mais tempo"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Over the shoulder: chest against you, chin above the shoulder — the classic first attempt.",
                    "Sitting on your lap: support the chin and jaw with your palm (never the throat), lean the body slightly forward, pat between the shoulder blades.",
                    "Face down across your lap: tummy on your thighs, head slightly higher than the body, one hand steadying the back.",
                    "Give each position about five minutes, then switch rather than continuing with the same one.",
                    "Burp mid-feed too — when you swap sides, or after roughly 60 ml from a bottle."
                ],
                ru: [
                    "Столбиком у плеча: грудь прижата к вам, подбородок выше плеча — классическая первая попытка.",
                    "Сидя у вас на коленях: поддерживайте подбородок и челюсть ладонью (никогда не горло), слегка наклоните корпус вперёд, похлопывайте между лопатками.",
                    "Лёжа животом поперёк ваших коленей: живот на бёдрах, голова чуть выше тела, одна рука придерживает спину.",
                    "Пробуйте каждую позу около пяти минут, затем меняйте, а не продолжайте ту же самую.",
                    "Делайте паузу на отрыжку и в середине кормления — при смене груди или примерно после 60 мл из бутылочки."
                ],
                de: [
                    "Über der Schulter: Brust gegen Sie, Kinn über der Schulter — der klassische erste Versuch.",
                    "Sitzend auf Ihrem Schoß: Kinn und Kiefer mit der Handfläche stützen (niemals die Kehle), den Körper leicht nach vorne neigen, zwischen den Schulterblättern klopfen.",
                    "Bauchlage über Ihrem Schoß: Bauch auf Ihren Oberschenkeln, Kopf leicht höher als der Körper, eine Hand stabilisiert den Rücken.",
                    "Geben Sie jeder Position etwa fünf Minuten, dann wechseln Sie, anstatt bei derselben zu bleiben.",
                    "Lassen Sie Ihr Baby auch während der Fütterung aufstoßen — beim Seitenwechsel oder nach etwa 60 ml aus der Flasche."
                ],
                es: [
                    "Por encima del hombro: el pecho contra ti, la barbilla por encima del hombro: el clásico primer intento.",
                    "Sentado en su regazo: sostenga la barbilla y la mandíbula con la palma de la mano (nunca la garganta), incline el cuerpo ligeramente hacia adelante, dé palmaditas entre los omóplatos.",
                    "Boca abajo sobre su regazo: boca abajo sobre los muslos, la cabeza ligeramente más alta que el cuerpo y una mano sosteniendo la espalda.",
                    "Dale a cada posición unos cinco minutos y luego cambia en lugar de continuar con la misma.",
                    "También haga eructar a mitad de la toma, cuando cambie de lado o después de aproximadamente 60 ml de un biberón.",
                ],
                fr: [
                    "Par-dessus l'épaule : poitrine contre vous, menton au-dessus de l'épaule — le premier essai classique.",
                    "Assis sur les genoux : soutenez le menton et la mâchoire avec la paume (jamais la gorge), penchez légèrement le corps vers l'avant, tapotez entre les omoplates.",
                    "Face contre terre sur vos genoux : ventre sur les cuisses, tête légèrement plus haute que le corps, une main stabilisant le dos.",
                    "Donnez environ cinq minutes à chaque position, puis changez plutôt que de continuer avec la même.",
                    "Faites également un rot à mi-tétée, lorsque vous changez de côté ou après environ 60 ml d'un biberon.",
                ],
                pt: [
                    "Por cima do ombro: peito contra você, queixo acima do ombro – a clássica primeira tentativa.",
                    "Sentado no colo: apoie o queixo e o maxilar com a palma da mão (nunca a garganta), incline o corpo ligeiramente para a frente, dê tapinhas entre as omoplatas.",
                    "De bruços no colo: barriga sobre as coxas, cabeça ligeiramente mais alta que o corpo, uma mão firmando as costas.",
                    "Dê a cada posição cerca de cinco minutos e depois mude em vez de continuar com a mesma posição.",
                    "Arrotar no meio da alimentação também – quando você troca de lado ou depois de cerca de 60 ml de uma mamadeira.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Air sits wherever the stomach happens to be shaped at that moment, so a hold that releases a burp today may do nothing tomorrow. Changing the angle moves the bubble towards the top of the stomach where it can escape. Mid-feed burping helps more than a single attempt at the end, because a smaller stomach releases air more easily than a full one.",
                ru: "Воздух располагается там, где в этот момент оказалась форма желудка, поэтому поза, сработавшая сегодня, завтра может не дать ничего. Смена угла перемещает пузырь к верхней части желудка, откуда он может выйти. Отрыжка в середине кормления помогает больше, чем одна попытка в конце: из менее наполненного желудка воздух выходит легче.",
                de: "Luft sitzt dort, wo der Magen in diesem Moment geformt ist, also kann eine Position, die heute zu einem Aufstoßen führt, morgen nichts bewirken. Eine Winkeländerung verschiebt die Blase in Richtung Magenöffnung, von wo aus sie entweichen kann. Aufstoßen während der Fütterung hilft mehr als ein einzelner Versuch am Ende, weil ein kleinerer Magen Luft leichter freisetzt als ein voller.",
                es: "El aire se asienta dondequiera que el estómago tenga forma en ese momento, por lo que una sujeción que libere un eructo hoy puede que no sirva de nada mañana. Cambiar el ángulo mueve la burbuja hacia la parte superior del estómago, donde puede escapar. Eructar a mitad de la comida ayuda más que un solo intento al final, porque un estómago más pequeño libera aire más fácilmente que uno lleno.",
                fr: "L'air se trouve là où se trouve la forme de l'estomac à ce moment-là, donc une prise qui libère un rot aujourd'hui peut ne rien faire demain. Changer l'angle déplace la bulle vers le haut de l'estomac où elle peut s'échapper. Le rot à mi-tétée aide plus qu'une seule tentative à la fin, car un estomac plus petit libère de l'air plus facilement qu'un estomac plein.",
                pt: "O ar fica onde quer que o estômago esteja moldado naquele momento, então uma pressão que libera um arroto hoje pode não fazer nada amanhã. Mudar o ângulo move a bolha em direção ao topo do estômago, de onde pode escapar. Arrotar no meio da alimentação ajuda mais do que uma única tentativa no final, porque um estômago menor libera ar com mais facilidade do que um estômago cheio."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Patting for twenty minutes in one position with no result.",
                    "Supporting the throat instead of the jaw in the sitting hold.",
                    "Assuming every feed must end with an audible burp — many do not, and that is fine.",
                    "Waiting until the baby is already crying with discomfort before starting."
                ],
                ru: [
                    "Похлопывать двадцать минут в одной позе без результата.",
                    "В позе сидя поддерживать горло вместо челюсти.",
                    "Считать, что каждое кормление должно заканчиваться слышимой отрыжкой, — часто её нет, и это нормально.",
                    "Ждать, пока ребёнок начнёт плакать от дискомфорта, и только потом начинать."
                ],
                de: [
                    "Zwanzig Minuten in einer Position klopfen ohne Ergebnis.",
                    "In der sitzenden Position die Kehle statt des Kiefers stützen.",
                    "Annehmen, dass jede Fütterung mit hörbarem Aufstoßen enden muss — viele tun das nicht, und das ist in Ordnung.",
                    "Warten, bis das Baby bereits vor Unbehagen weint, bevor Sie beginnen."
                ],
                es: [
                    "Dar palmaditas durante veinte minutos en una posición sin resultado.",
                    "Apoyar la garganta en lugar de la mandíbula al sentarse.",
                    "Suponiendo que cada comida debe terminar con un eructo audible, muchos no lo hacen, y eso está bien.",
                    "Esperar a que el bebé ya esté llorando de malestar antes de empezar.",
                ],
                fr: [
                    "Tapoter pendant vingt minutes dans une position sans résultat.",
                    "Soutenir la gorge au lieu de la mâchoire en position assise.",
                    "En supposant que chaque repas doit se terminer par un rot audible, beaucoup ne le font pas, et c'est très bien.",
                    "Attendre que bébé pleure déjà de gêne avant de commencer.",
                ],
                pt: [
                    "Dar tapinhas por vinte minutos em uma posição sem resultado.",
                    "Apoiando a garganta em vez da mandíbula na posição sentada.",
                    "Supondo que cada mamada termine com um arroto audível – muitos não o fazem, e tudo bem.",
                    "Esperar até que o bebê já esteja chorando de desconforto antes de começar.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby seems to be in pain during or after most feeds despite burping.",
                    "Feeds regularly end in inconsolable crying that lasts over an hour.",
                    "You notice wheezing, coughing, or colour change during feeds."
                ],
                ru: [
                    "Несмотря на отрыжку, ребёнок явно испытывает боль во время или после большинства кормлений.",
                    "Кормления регулярно заканчиваются безутешным плачем дольше часа.",
                    "Вы замечаете хрипы, кашель или изменение цвета кожи во время кормления."
                ],
                de: [
                    "Ihr Baby scheint trotz Aufstoßen während oder nach den meisten Mahlzeiten Schmerzen zu haben.",
                    "Fütterungen enden regelmäßig mit untröstlichem Weinen, das länger als eine Stunde dauert.",
                    "Sie bemerken Pfeifen, Husten oder Farbveränderungen während der Fütterung."
                ],
                es: [
                    "Su bebé parece sentir dolor durante o después de la mayoría de las tomas a pesar de eructar.",
                    "Las tomas terminan regularmente en un llanto inconsolable que dura más de una hora.",
                    "Nota sibilancias, tos o cambios de color durante las tomas.",
                ],
                fr: [
                    "Votre bébé semble souffrir pendant ou après la plupart des tétées malgré les rots.",
                    "Les tétées se terminent régulièrement par des pleurs inconsolables qui durent plus d'une heure.",
                    "Vous remarquez une respiration sifflante, de la toux ou un changement de couleur pendant les tétées.",
                ],
                pt: [
                    "Seu bebê parece sentir dor durante ou após a maioria das mamadas, apesar de arrotar.",
                    "As mamadas terminam regularmente em choro inconsolável que dura mais de uma hora.",
                    "Você percebe chiado no peito, tosse ou mudança de cor durante as mamadas.",
                ]
            )
        ),

        CareTip(
            id: 1003, category: .feeding, icon: "eye.fill", ageFrom: 0, ageTo: 4,
            title: LocalizedText(
                en: "Catch hunger cues before the crying starts",
                ru: "Замечайте признаки голода до начала плача",
                de: "Erkennen Sie Hungersignale, bevor das Weinen beginnt",
                es: "Reconoce las señales de hambre antes de que empiece el llanto",
                fr: "Repérez les signes de faim avant que les pleurs ne commencent",
                pt: "Capte sinais de fome antes que o choro comece"
            ),
            summary: LocalizedText(
                en: "Crying is a late signal — feeding at the early cues is calmer for everyone",
                ru: "Плач — поздний сигнал: кормление по ранним признакам спокойнее для всех",
                de: "Weinen ist ein spätes Signal — die Fütterung bei frühen Zeichen ist für alle ruhiger",
                es: "El llanto es una señal tardía: alimentar al bebé ante las primeras señales es más tranquilo para todos",
                fr: "Les pleurs sont un signe tardif : nourrir bébé dès les premiers signes est plus calme pour tout le monde",
                pt: "Chorar é um sinal tardio – alimentar-se nos primeiros sinais é mais calmo para todos"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Watch for early cues: stirring, mouth opening, turning the head side to side, hands moving to the face.",
                    "Mid cues: stretching, increasing body movement, hands going into the mouth, small fussing sounds.",
                    "Late cues: full crying, a red face, agitated jerky movements.",
                    "Offer a feed at the early or mid stage — latching is easier and the feed is usually more efficient.",
                    "If crying has already started, calm first: skin-to-skin, gentle rocking, a quiet voice, then offer."
                ],
                ru: [
                    "Следите за ранними признаками: ребёнок зашевелился, открывает рот, поворачивает голову из стороны в сторону, тянет руки к лицу.",
                    "Средние признаки: потягивания, усиление движений, руки во рту, короткие похныкивания.",
                    "Поздние признаки: полноценный плач, покрасневшее лицо, резкие возбуждённые движения.",
                    "Предлагайте грудь или бутылочку на ранней или средней стадии — захват легче, а кормление обычно эффективнее.",
                    "Если плач уже начался, сначала успокойте: контакт кожа к коже, мягкое покачивание, тихий голос, и только потом предлагайте еду."
                ],
                de: [
                    "Achten Sie auf frühe Zeichen: Bewegungen, Mundöffnen, Kopfdrehen von Seite zu Seite, Hände bewegen sich zum Gesicht.",
                    "Mittlere Zeichen: Stretching, zunehmende Körperbewegungen, Hände zum Mund, kleine Brabbel- oder Quengelgeräusche.",
                    "Späte Zeichen: vollständiges Weinen, rotes Gesicht, zuckende Bewegungen.",
                    "Bieten Sie die Fütterung in einem frühen oder mittleren Stadium an — das Anlegen ist einfacher und die Fütterung ist meist effizienter.",
                    "Wenn das Weinen bereits begonnen hat, beruhigen Sie zuerst: Haut-zu-Haut-Kontakt, sanftes Wiegen, ruhige Stimme, dann anbieten."
                ],
                es: [
                    "Esté atento a las señales tempranas: agitación, apertura de la boca, giro de la cabeza de lado a lado, movimiento de las manos hacia la cara.",
                    "Señales medias: estiramiento, aumento del movimiento corporal, manos metiéndose en la boca, pequeños sonidos de inquietud.",
                    "Señales tardías: llanto intenso, cara roja, movimientos agitados y espasmódicos.",
                    "Ofrezca una alimentación en la etapa inicial o intermedia: el agarre es más fácil y la alimentación suele ser más eficiente.",
                    "Si el llanto ya ha comenzado, primero cálmese: piel con piel, balanceo suave, voz tranquila y luego ofrézcase.",
                ],
                fr: [
                    "Surveillez les premiers signaux : remuer, ouvrir la bouche, tourner la tête d’un côté à l’autre, les mains se déplacer vers le visage.",
                    "Indices intermédiaires : étirements, mouvements corporels croissants, mains entrant dans la bouche, petits sons d'agitation.",
                    "Indices tardifs : pleurs abondants, visage rouge, mouvements saccadés et agités.",
                    "Offrez une alimentation au stade précoce ou intermédiaire – la prise du sein est plus facile et l’alimentation est généralement plus efficace.",
                    "Si les pleurs ont déjà commencé, calmez-vous d'abord : peau à peau, bercement doux, voix douce, puis proposez.",
                ],
                pt: [
                    "Fique atento aos primeiros sinais: mexer, abrir a boca, virar a cabeça de um lado para o outro, mover as mãos em direção ao rosto.",
                    "Sinais intermediários: alongamento, aumento do movimento do corpo, mãos na boca, pequenos sons de agitação.",
                    "Sinais tardios: choro intenso, rosto vermelho, movimentos bruscos e agitados.",
                    "Ofereça uma alimentação no estágio inicial ou intermediário – a pega é mais fácil e a alimentação geralmente é mais eficiente.",
                    "Se o choro já começou, acalme-se primeiro: pele a pele, balanço suave, voz baixa e depois ofereça.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "A crying baby has an arched tongue and a tense jaw, which makes a deep latch physically harder to achieve. Feeds that start from crying tend to be shorter, more frantic, and involve swallowing more air. Reading the early cues also builds your confidence in your own observations, which is worth as much as the smoother feed itself.",
                ru: "У плачущего ребёнка язык выгнут, а челюсть напряжена — глубокий захват физически даётся труднее. Кормления, начатые с плача, обычно короче, более суетливы и сопровождаются заглатыванием большего количества воздуха. Умение читать ранние признаки к тому же укрепляет доверие к собственным наблюдениям, а это ценно не меньше, чем более спокойное кормление.",
                de: "Ein weinendes Baby hat eine gewölbte Zunge und einen angespannten Kiefer, was einen tiefen Halt physisch schwieriger macht. Fütterungen, die aus Weinen beginnen, sind in der Regel kürzer, wilder und beinhalten mehr Luft schlucken. Das Lesen der frühen Zeichen stärkt auch Ihr Vertrauen in Ihre eigenen Beobachtungen, was genauso wertvoll ist wie die sanftere Fütterung selbst.",
                es: "Un bebé que llora tiene la lengua arqueada y la mandíbula tensa, lo que hace que sea físicamente más difícil lograr un agarre profundo. Las tomas que comienzan con el llanto tienden a ser más cortas, más frenéticas e implican tragar más aire. Leer las primeras señales también aumenta tu confianza en tus propias observaciones, lo que vale tanto como la transmisión más fluida en sí.",
                fr: "Un bébé qui pleure a une langue arquée et une mâchoire tendue, ce qui rend physiquement plus difficile une prise profonde du sein. Les tétées qui commencent par des pleurs ont tendance à être plus courtes, plus frénétiques et impliquent d’avaler plus d’air. La lecture des premiers signaux renforce également votre confiance dans vos propres observations, ce qui vaut autant que l'alimentation plus fluide elle-même.",
                pt: "Um bebê que chora tem a língua arqueada e a mandíbula tensa, o que torna fisicamente mais difícil conseguir uma pega profunda. As mamadas que começam com o choro tendem a ser mais curtas, mais frenéticas e envolvem engolir mais ar. Ler as primeiras dicas também aumenta sua confiança em suas próprias observações, o que vale tanto quanto a própria alimentação mais suave."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Feeding strictly by the clock and ignoring what the baby is showing.",
                    "Reading every mouth movement as hunger — babies also mouth their hands to self-soothe and explore.",
                    "Using a dummy to postpone a clear feeding cue in the early weeks."
                ],
                ru: [
                    "Кормить строго по часам, игнорируя то, что показывает ребёнок.",
                    "Принимать любое движение ртом за голод — дети также тянут руки в рот, чтобы успокоиться и исследовать мир.",
                    "Использовать пустышку, чтобы отложить явный сигнал голода в первые недели."
                ],
                de: [
                    "Streng nach der Uhr füttern und ignorieren, was das Baby zeigt.",
                    "Jede Mundbewegung als Hunger auslegen — Babys führen ihre Hände auch zum Mund, um sich selbst zu beruhigen und die Welt zu erkunden.",
                    "In den ersten Wochen einen Schnuller verwenden, um ein klares Hungersignal zu verschieben."
                ],
                es: [
                    "Alimentar estrictamente según el reloj e ignorar lo que muestra el bebé.",
                    "Interpretar cada movimiento de la boca como hambre: los bebés también se llevan las manos a la boca para calmarse y explorar.",
                    "Usar un chupete para posponer una señal clara de alimentación en las primeras semanas.",
                ],
                fr: [
                    "Nourrir strictement à l'heure et ignorer ce que montre le bébé.",
                    "Interprétant chaque mouvement de la bouche comme une faim, les bébés mettent également leurs mains dans leurs mains pour s'apaiser et explorer.",
                    "Utiliser un mannequin pour retarder un signal d'alimentation clair dans les premières semaines.",
                ],
                pt: [
                    "Alimentar estritamente de acordo com o relógio e ignorar o que o bebê está mostrando.",
                    "Interpretando cada movimento da boca como fome – os bebês também fazem a boca com as mãos para se acalmar e explorar.",
                    "Usar um manequim para adiar um sinal claro de alimentação nas primeiras semanas.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby is consistently too sleepy to show hunger cues and has to be woken for every feed.",
                    "Fewer than six wet nappies a day after the first week.",
                    "Feeding cues appear constantly and feeds never seem to satisfy."
                ],
                ru: [
                    "Ребёнок постоянно слишком сонный, чтобы подавать признаки голода, и его приходится будить на каждое кормление.",
                    "Меньше шести мокрых подгузников в сутки после первой недели.",
                    "Признаки голода появляются постоянно, и кормления как будто никогда не насыщают."
                ],
                de: [
                    "Ihr Baby ist durchgehend zu schläfrig, um Hungersignale zu zeigen, und muss bei jeder Fütterung geweckt werden.",
                    "Weniger als sechs nasse Windeln pro Tag nach der ersten Woche.",
                    "Hungersignale erscheinen ständig und Fütterungen scheinen nie zufriedenzustellen."
                ],
                es: [
                    "Su bebé siempre tiene demasiado sueño para mostrar señales de hambre y es necesario despertarlo para cada toma.",
                    "Menos de seis pañales mojados al día después de la primera semana.",
                    "Las señales de alimentación aparecen constantemente y las tomas nunca parecen satisfacer.",
                ],
                fr: [
                    "Votre bébé est constamment trop somnolent pour montrer des signaux de faim et doit être réveillé à chaque tétée.",
                    "Moins de six couches mouillées par jour après la première semaine.",
                    "Les signaux d'alimentation apparaissent constamment et les aliments ne semblent jamais satisfaisants.",
                ],
                pt: [
                    "Seu bebê está sempre com muito sono para mostrar sinais de fome e precisa ser acordado a cada mamada.",
                    "Menos de seis fraldas molhadas por dia após a primeira semana.",
                    "Os sinais de alimentação aparecem constantemente e a alimentação nunca parece satisfatória.",
                ]
            )
        ),

        CareTip(
            id: 1004, category: .feeding, icon: "drop.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Paced bottle feeding: keep the bottle horizontal",
                ru: "Кормление из бутылочки в темпе ребёнка: держите бутылочку горизонтально",
                de: "Tempogerechtiges Flaschenfahren: Halten Sie die Flasche horizontal",
                es: "Tomas pausadas con biberón: mantén el biberón horizontal",
                fr: "Donner le biberon au rythme de bébé : gardez le biberon à l’horizontale",
                pt: "Alimentação com mamadeira com ritmo: mantenha a mamadeira na horizontal"
            ),
            summary: LocalizedText(
                en: "Let your baby set the rhythm instead of letting gravity empty the bottle",
                ru: "Пусть ритм задаёт ребёнок, а не сила тяжести, опустошающая бутылочку",
                de: "Lassen Sie Ihr Baby den Rhythmus vorgeben, anstatt die Schwerkraft die Flasche zu leeren",
                es: "Deja que el bebé marque el ritmo en vez de que la gravedad vacíe el biberón",
                fr: "Laissez bébé donner le rythme au lieu de laisser la gravité vider le biberon",
                pt: "Deixe seu bebê definir o ritmo em vez de deixar a gravidade esvaziar a mamadeira"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Hold your baby semi-upright, head above the tummy — not lying flat.",
                    "Keep the bottle roughly horizontal, filling only the tip of the teat with milk.",
                    "Touch the teat to the lips and wait for the mouth to open rather than pushing it in.",
                    "Pause every 20–30 seconds by tipping the bottle down slightly; let your baby breathe and decide to continue.",
                    "Aim for the feed to last 10–20 minutes, and stop when your baby turns away — even with milk left."
                ],
                ru: [
                    "Держите ребёнка полувертикально, голова выше живота, а не горизонтально.",
                    "Держите бутылочку почти горизонтально, чтобы молоком был заполнен только кончик соски.",
                    "Коснитесь соской губ и подождите, пока рот откроется, а не вставляйте её силой.",
                    "Каждые 20–30 секунд делайте паузу, слегка опуская бутылочку: дайте ребёнку подышать и решить, продолжать ли.",
                    "Стремитесь, чтобы кормление длилось 10–20 минут, и заканчивайте, когда ребёнок отворачивается, — даже если молоко осталось."
                ],
                de: [
                    "Halten Sie Ihr Baby halbaufrecht, mit dem Kopf über dem Bauch — nicht flach liegend.",
                    "Halten Sie die Flasche grob horizontal, wobei nur die Spitze des Saugers mit Milch gefüllt ist.",
                    "Berühren Sie den Sauger an den Lippen und warten Sie, bis sich der Mund öffnet, anstatt ihn hineinzuschieben.",
                    "Machen Sie alle 20–30 Sekunden eine Pause, indem Sie die Flasche leicht neigen; lassen Sie Ihr Baby atmen und selbst entscheiden, ob es weitermachen möchte.",
                    "Zielen Sie darauf ab, dass die Fütterung 10–20 Minuten dauert, und stoppen Sie, wenn sich Ihr Baby abwendet — auch wenn noch Milch vorhanden ist."
                ],
                es: [
                    "Sostenga a su bebé semi-erguido, con la cabeza por encima del abdomen, no acostado.",
                    "Mantenga el biberón aproximadamente en posición horizontal, llenando solo la punta de la tetina con leche.",
                    "Toque los labios con la tetina y espere a que se abra la boca en lugar de empujarla hacia adentro.",
                    "Haga una pausa cada 20 a 30 segundos inclinando ligeramente la botella hacia abajo; deja que tu bebé respire y decide continuar.",
                    "Trate de que la toma dure de 10 a 20 minutos y deténgase cuando su bebé se dé la vuelta, incluso cuando quede leche.",
                ],
                fr: [
                    "Tenez votre bébé à moitié debout, la tête au-dessus du ventre, et non à plat.",
                    "Gardez le biberon à peu près horizontal, en remplissant uniquement le bout de la tétine avec du lait.",
                    "Mettez la tétine en contact avec les lèvres et attendez que la bouche s'ouvre plutôt que de l'enfoncer.",
                    "Faites une pause toutes les 20 à 30 secondes en inclinant légèrement la bouteille ; laissez votre bébé respirer et décidez de continuer.",
                    "Visez à ce que la tétée dure 10 à 20 minutes et arrêtez-vous lorsque votre bébé se détourne, même s'il reste du lait.",
                ],
                pt: [
                    "Segure seu bebê semi-ereto, com a cabeça acima da barriga - não deitado.",
                    "Mantenha a mamadeira aproximadamente na horizontal, enchendo apenas a ponta da tetina com leite.",
                    "Toque a tetina nos lábios e espere que a boca se abra em vez de empurrá-la para dentro.",
                    "Faça uma pausa a cada 20–30 segundos inclinando ligeiramente a garrafa para baixo; deixe seu bebê respirar e decida continuar.",
                    "Procure que a mamada dure de 10 a 20 minutos e pare quando o bebê se virar - mesmo que ainda tenha leite.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "With a vertical bottle, milk flows whether or not the baby is actively sucking, so they must keep swallowing to avoid choking. That overrides the natural pause-and-breathe rhythm they use at the breast, and it bypasses the fullness signal, which is why fast bottle feeds often end with wind, spit-up and a distressed baby. Pacing gives the appetite feedback loop time to work.",
                ru: "При вертикальной бутылочке молоко течёт независимо от того, сосёт ребёнок или нет, поэтому ему приходится всё время глотать, чтобы не поперхнуться. Это перебивает естественный ритм «пауза — вдох», который он использует у груди, и обходит сигнал насыщения — поэтому быстрые кормления из бутылочки часто заканчиваются газиками, срыгиванием и беспокойством. Кормление в темпе ребёнка даёт механизму насыщения время сработать.",
                de: "Bei einer vertikalen Flasche fließt die Milch, ob das Baby aktiv saugt oder nicht, also muss es ständig schlucken, um nicht zu ersticken. Dies setzt den natürlichen Pause-Atem-Rhythmus außer Kraft, den es an der Brust nutzt, und umgeht das Sättigungssignal – deshalb enden schnelle Flaschenmahlzeiten oft mit Blähungen, Spucken und einem gestressten Baby. Das Tempo gibt der Appetitfeedback-Schleife Zeit zu wirken.",
                es: "Con un biberón vertical, la leche fluye independientemente de que el bebé esté succionando activamente o no, por lo que debe seguir tragando para evitar ahogarse. Eso anula el ritmo natural de pausa y respiración que usan en el pecho y evita la señal de saciedad, razón por la cual la alimentación rápida con biberón a menudo termina con gases, regurgitaciones y un bebé angustiado. El ritmo le da tiempo al circuito de retroalimentación del apetito para funcionar.",
                fr: "Avec un biberon vertical, le lait coule, que le bébé tète activement ou non, il doit donc continuer à avaler pour éviter de s'étouffer. Cela annule le rythme naturel de pause et de respiration qu'ils utilisent au sein et contourne le signal de satiété, c'est pourquoi les tétées rapides au biberon se terminent souvent par du vent, des crachats et un bébé en détresse. La stimulation donne à la boucle de rétroaction de l’appétit le temps de fonctionner.",
                pt: "Com uma mamadeira vertical, o leite flui independentemente de o bebê estar sugando ativamente ou não, por isso ele deve continuar engolindo para evitar engasgos. Isso substitui o ritmo natural de pausa e respiração que eles usam no peito e ignora o sinal de plenitude, razão pela qual as mamadas rápidas geralmente terminam com gases, cusparadas e um bebê angustiado. O ritmo dá ao ciclo de feedback do apetite tempo para funcionar."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Propping the bottle on a cushion and leaving the baby to it — a choking risk, never safe.",
                    "Encouraging the last few millilitres after the baby has clearly stopped.",
                    "Moving up a teat size to shorten feeds.",
                    "Feeding with the baby lying flat on their back."
                ],
                ru: [
                    "Подпирать бутылочку подушкой и оставлять ребёнка одного — риск удушья, так делать нельзя.",
                    "Уговаривать доесть последние миллилитры, когда ребёнок явно закончил.",
                    "Переходить на соску с большим потоком, чтобы сократить кормление.",
                    "Кормить ребёнка, лежащего плашмя на спине."
                ],
                de: [
                    "Die Flasche auf einem Kissen abstützen und das Baby allein lassen — ein Erstickungsrisiko, niemals sicher.",
                    "Die letzten Milliliter zu ermutigen, nachdem das Baby eindeutig gestoppt hat.",
                    "Zu einer größeren Saugergröße wechseln, um Fütterungen zu verkürzen.",
                    "Das Baby füttern, während es flach auf dem Rücken liegt."
                ],
                es: [
                    "Apoyar el biberón sobre un cojín y dejar al bebé solo: un riesgo de asfixia, nunca seguro.",
                    "Fomentar los últimos mililitros después de que el bebé haya dejado claramente de hacerlo.",
                    "Aumentar el tamaño del pezón para acortar las tomas.",
                    "Alimentar con el bebé acostado boca arriba.",
                ],
                fr: [
                    "Poser le biberon sur un coussin et y laisser le bébé : un risque d'étouffement, jamais sûr.",
                    "Encourager les derniers millilitres après que le bébé se soit clairement arrêté.",
                    "Augmenter la taille des trayons pour raccourcir les tétées.",
                    "Nourrir le bébé allongé sur le dos.",
                ],
                pt: [
                    "Apoiar a mamadeira em uma almofada e deixar o bebê sozinho – um risco de asfixia, nunca seguro.",
                    "Encorajar os últimos mililitros depois que o bebê tiver parado claramente.",
                    "Aumentar o tamanho da tetina para encurtar a alimentação.",
                    "Alimentar com o bebê deitado de costas.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Milk regularly leaks from the corners of the mouth, or your baby gulps and splutters.",
                    "Feeds take over 40 minutes and leave your baby exhausted.",
                    "Coughing, gagging, or colour change during bottle feeds."
                ],
                ru: [
                    "Молоко регулярно вытекает из уголков рта или ребёнок захлёбывается и давится.",
                    "Кормление занимает больше 40 минут и полностью изматывает ребёнка.",
                    "Кашель, рвотные позывы или изменение цвета кожи во время кормления из бутылочки."
                ],
                de: [
                    "Milch tritt regelmäßig aus den Mundwinkeln aus, oder Ihr Baby schluckt und sprudelt.",
                    "Fütterungen dauern über 40 Minuten und erschöpfen Ihr Baby.",
                    "Husten, Würgen oder Farbveränderungen während der Flaschenmahlzeit."
                ],
                es: [
                    "La leche gotea regularmente por las comisuras de la boca o su bebé traga saliva y farfulla.",
                    "Las tomas duran más de 40 minutos y dejan al bebé exhausto.",
                    "Tos, náuseas o cambio de color durante la alimentación con biberón.",
                ],
                fr: [
                    "Le lait s'écoule régulièrement des coins de la bouche, ou votre bébé avale et bafouille.",
                    "Les tétées durent plus de 40 minutes et laissent votre bébé épuisé.",
                    "Toux, haut-le-cœur ou changement de couleur pendant l'allaitement au biberon.",
                ],
                pt: [
                    "O leite vaza regularmente pelos cantos da boca ou o bebê engole e balbucia.",
                    "As mamadas demoram mais de 40 minutos e deixam seu bebê exausto.",
                    "Tosse, engasgos ou mudança de cor durante a alimentação com mamadeira.",
                ]
            )
        ),

        CareTip(
            id: 1005, category: .feeding, icon: "timer", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Preparing and storing formula safely",
                ru: "Как безопасно готовить и хранить смесь",
                de: "Formel sicher zubereiten und lagern",
                es: "Preparar y conservar la leche de fórmula de forma segura",
                fr: "Préparer et conserver le lait infantile en toute sécurité",
                pt: "Preparar e armazenar a fórmula com segurança"
            ),
            summary: LocalizedText(
                en: "Fresh is safest: make each bottle when you need it and discard leftovers",
                ru: "Безопаснее всего свежая: готовьте каждую бутылочку перед кормлением и выливайте остатки",
                de: "Frisch ist am sichersten: Machen Sie jede Flasche, wenn Sie sie brauchen, und entsorgen Sie Reste",
                es: "Lo fresco es más seguro: prepara cada biberón cuando lo necesites y desecha las sobras",
                fr: "Le lait frais est le plus sûr : préparez chaque biberon au moment voulu et jetez les restes",
                pt: "Fresco é mais seguro: faça cada garrafa quando precisar e descarte as sobras"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Wash hands, then clean and sterilise bottles and teats for the whole first year.",
                    "Boil fresh water and let it cool for no more than 30 minutes before mixing, so it is still hot enough to kill bacteria in the powder.",
                    "Add water to the bottle first, then the exact number of level scoops stated on the tin.",
                    "Cool quickly under a running cold tap, holding the lid on, and test on your inner wrist — it should feel lukewarm, not warm.",
                    "Throw away anything left in the bottle within two hours of the feed starting."
                ],
                ru: [
                    "Вымойте руки, а бутылочки и соски мойте и стерилизуйте в течение всего первого года.",
                    "Вскипятите свежую воду и дайте ей остыть не более 30 минут перед разведением, чтобы она была ещё достаточно горячей и убила бактерии в порошке.",
                    "Сначала налейте в бутылочку воду, затем добавьте точное число мерных ложек без горки, указанное на банке.",
                    "Быстро охладите под струёй холодной воды, удерживая крышку, и проверьте на внутренней стороне запястья — должно быть чуть тёплым, не горячим.",
                    "Всё, что осталось в бутылочке, выливайте в течение двух часов с начала кормления."
                ],
                de: [
                    "Waschen Sie sich die Hände, reinigen und sterilisieren Sie dann Flaschen und Sauger das ganze erste Jahr.",
                    "Frisches Wasser kochen und vor dem Mischen nicht länger als 30 Minuten abkühlen lassen, damit es noch heiß genug ist, um Bakterien im Pulver abzutöten.",
                    "Wasser zuerst in die Flasche geben, dann die genaue Anzahl der auf der Dose angegebenen ebenen Messlöffel hinzufügen.",
                    "Schnell unter fließendem kaltem Wasser abkühlen, den Deckel halten und an der Innenseite des Handgelenks testen — es sollte sich lauwarm anfühlen, nicht warm.",
                    "Alles, was in der Flasche verbleibt, innerhalb von zwei Stunden nach Beginn der Fütterung entfernen."
                ],
                es: [
                    "Lávese las manos, luego limpie y esterilice biberones y tetinas durante todo el primer año.",
                    "Hierva agua fresca y déjela enfriar durante no más de 30 minutos antes de mezclar, para que todavía esté lo suficientemente caliente como para matar las bacterias en el polvo.",
                    "Primero agregue agua a la botella, luego la cantidad exacta de cucharadas rasas indicadas en la lata.",
                    "Enfríe rápidamente bajo un grifo de agua fría, mantenga la tapa puesta y pruébelo en la parte interna de la muñeca; debe sentirse tibio, no tibio.",
                    "Deseche todo lo que quede en el biberón dentro de las dos horas posteriores al inicio de la toma.",
                ],
                fr: [
                    "Lavez-vous les mains, puis nettoyez et stérilisez les biberons et les tétines pendant toute la première année.",
                    "Faites bouillir de l'eau fraîche et laissez-la refroidir pendant 30 minutes maximum avant de la mélanger, afin qu'elle soit encore suffisamment chaude pour tuer les bactéries présentes dans la poudre.",
                    "Ajoutez d'abord de l'eau dans la bouteille, puis le nombre exact de cuillères à niveau indiqué sur la boîte.",
                    "Refroidissez rapidement sous un robinet froid, en maintenant le couvercle et testez sur l'intérieur de votre poignet : il doit être tiède, pas chaud.",
                    "Jetez tout ce qui reste dans le biberon dans les deux heures suivant le début de la tétée.",
                ],
                pt: [
                    "Lave as mãos, depois limpe e esterilize mamadeiras e tetinas durante todo o primeiro ano.",
                    "Ferva água doce e deixe esfriar por no máximo 30 minutos antes de misturar, para que ainda esteja quente o suficiente para matar as bactérias do pó.",
                    "Adicione água à garrafa primeiro e depois o número exato de medidas indicadas na lata.",
                    "Deixe esfriar rapidamente sob uma torneira fria, segurando a tampa, e teste na parte interna do pulso - deve estar morno, não quente.",
                    "Jogue fora tudo o que sobrar na mamadeira dentro de duas horas após o início da alimentação.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Formula powder is not a sterile product, and a warm made-up bottle is an excellent growth medium. Two things protect your baby: water hot enough to kill bacteria at the point of mixing, and a short window between making and drinking. Scoop accuracy matters just as much — over-concentrated formula strains immature kidneys, and over-diluted formula quietly holds back weight gain.",
                ru: "Сухая смесь не является стерильным продуктом, а тёплая разведённая бутылочка — отличная среда для роста бактерий. Ребёнка защищают две вещи: вода, достаточно горячая в момент разведения, чтобы убить бактерии, и короткий промежуток между приготовлением и кормлением. Точность дозировки важна не меньше: слишком концентрированная смесь перегружает незрелые почки, а слишком разведённая незаметно тормозит прибавку в весе.",
                de: "Formelprder ist kein steriles Produkt, und eine warm zubereitete Flasche ist ein ausgezeichnetes Wachstumsmedium. Zwei Dinge schützen Ihr Baby: Wasser, das heiß genug ist, um Bakterien zum Zeitpunkt des Mischens abzutöten, und ein kurzes Fenster zwischen Herstellung und Konsum. Die Genauigkeit der Dosierung ist genauso wichtig — zu konzentrierte Formel belastet unreife Nieren, und zu verdünnte Formel bremst unauffällig das Gewichtswachstum.",
                es: "La fórmula en polvo no es un producto estéril y un biberón preparado tibio es un excelente medio de crecimiento. Dos cosas protegen a su bebé: agua lo suficientemente caliente como para matar las bacterias en el momento de mezclarse y un breve período entre preparar y beber. La precisión de la cucharada es igualmente importante: la fórmula demasiado concentrada ejerce presión sobre los riñones inmaduros y la fórmula demasiado diluida frena silenciosamente el aumento de peso.",
                fr: "La poudre de formule n’est pas un produit stérile et un biberon chaud et maquillé est un excellent milieu de croissance. Deux choses protègent votre bébé : de l’eau suffisamment chaude pour tuer les bactéries au moment du mélange et un court laps de temps entre la préparation et la consommation. La précision de la cuillère est tout aussi importante : une formule trop concentrée met à rude épreuve les reins immatures et une formule trop diluée retient discrètement la prise de poids.",
                pt: "A fórmula em pó não é um produto estéril e um frasco aquecido é um excelente meio de crescimento. Duas coisas protegem seu bebê: água quente o suficiente para matar as bactérias no momento da mistura e um curto intervalo entre fazer e beber. A precisão da colher é igualmente importante - a fórmula superconcentrada sobrecarrega os rins imaturos, e a fórmula superdiluída retém silenciosamente o ganho de peso."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Packing or heaping the scoop instead of levelling it off.",
                    "Making up a batch of bottles for the day and leaving them at room temperature.",
                    "Reheating a partly drunk bottle for later.",
                    "Using a microwave, which creates hot spots that can scald the mouth."
                ],
                ru: [
                    "Утрамбовывать порошок в мерной ложке или набирать с горкой вместо того, чтобы снимать излишек.",
                    "Готовить сразу несколько бутылочек на день и оставлять их при комнатной температуре.",
                    "Подогревать недопитую бутылочку, чтобы использовать позже.",
                    "Греть в микроволновой печи — она создаёт горячие точки, которыми можно обжечь рот."
                ],
                de: [
                    "Den Messlöffel stopfen oder häufen, anstatt ihn abzustreichen.",
                    "Mehrere Flaschen für den Tag zubereiten und bei Raumtemperatur stehen lassen.",
                    "Eine teilweise getrunkene Flasche später aufwärmen.",
                    "Eine Mikrowelle verwenden, die heiße Stellen erzeugt, die den Mund verbrennen können."
                ],
                es: [
                    "Empaquetar o amontonar la pala en lugar de nivelarla.",
                    "Preparar una tanda de biberones para el día y dejarlos a temperatura ambiente.",
                    "Recalentar una botella medio borracha para más tarde.",
                    "Usar un microondas, que crea puntos calientes que pueden quemar la boca.",
                ],
                fr: [
                    "Emballer ou empiler la cuillère au lieu de la niveler.",
                    "Constituer un lot de bouteilles pour la journée et les laisser à température ambiante.",
                    "Réchauffer une bouteille partiellement bue pour plus tard.",
                    "Utiliser un micro-ondes, ce qui crée des points chauds pouvant brûler la bouche.",
                ],
                pt: [
                    "Embalar ou empilhar a colher em vez de nivelá-la.",
                    "Preparar um lote de garrafas para o dia e deixá-las em temperatura ambiente.",
                    "Reaquecer uma garrafa parcialmente bêbada para mais tarde.",
                    "Usar um micro-ondas, que cria pontos quentes que podem queimar a boca.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Vomiting, diarrhoea, or fever after a feed.",
                    "Your baby refuses formula they normally accept, or develops a rash after feeds.",
                    "Weight gain slows despite normal feed volumes."
                ],
                ru: [
                    "Рвота, диарея или температура после кормления.",
                    "Ребёнок отказывается от смеси, которую обычно ест, или после кормлений появляется сыпь.",
                    "Прибавка в весе замедлилась при обычных объёмах кормления."
                ],
                de: [
                    "Erbrechen, Durchfall oder Fieber nach einer Mahlzeit.",
                    "Ihr Baby lehnt Formel ab, die es normalerweise akzeptiert, oder entwickelt nach den Mahlzeiten einen Ausschlag.",
                    "Die Gewichtszunahme verlangsamt sich trotz normaler Fütterungsmengen."
                ],
                es: [
                    "Vómitos, diarrea o fiebre después de una toma.",
                    "Su bebé rechaza la fórmula que normalmente acepta o desarrolla un sarpullido después de las tomas.",
                    "El aumento de peso se ralentiza a pesar de los volúmenes de alimento normales.",
                ],
                fr: [
                    "Vomissements, diarrhée ou fièvre après une tétée.",
                    "Votre bébé refuse les préparations qu'il accepte normalement ou développe une éruption cutanée après les tétées.",
                    "La prise de poids ralentit malgré des volumes de nourriture normaux.",
                ],
                pt: [
                    "Vômito, diarréia ou febre após a alimentação.",
                    "Seu bebê recusa a fórmula que normalmente aceita ou desenvolve erupção na pele após as mamadas.",
                    "O ganho de peso diminui apesar dos volumes normais de alimentação.",
                ]
            )
        ),

        CareTip(
            id: 1006, category: .feeding, icon: "arrow.uturn.up", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Spit-up or vomiting: how to tell them apart",
                ru: "Срыгивание или рвота: как отличить",
                de: "Spucken oder Erbrechen: wie man sie unterscheidet",
                es: "Regurgitación o vómito: cómo distinguirlos",
                fr: "Régurgitations ou vomissements : comment les distinguer",
                pt: "Cuspir ou vomitar: como diferenciá-los"
            ),
            summary: LocalizedText(
                en: "A relaxed dribble is normal; forceful, distressed, or coloured is not",
                ru: "Спокойное подтекание — норма; фонтаном, с беспокойством или цветное — нет",
                de: "Ein entspanntes Rinnsal ist normal; gewaltsam, angespannt oder gefärbt ist es nicht",
                es: "Un goteo tranquilo es normal; si es a presión, con malestar o tiene color, no lo es",
                fr: "Un petit écoulement sans effort est normal ; s’il est puissant, douloureux ou coloré, il ne l’est pas",
                pt: "Um drible relaxado é normal; forte, angustiado ou colorido não é"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Look at the force: spit-up rolls out of the mouth, vomit is expelled with effort.",
                    "Look at your baby: after spit-up they carry on as if nothing happened; after vomiting they are usually upset.",
                    "Look at the colour: milky white or slightly curdled is expected; green, yellow, brown or blood-streaked is not.",
                    "Note the volume — a tablespoon spreads widely on a muslin and often looks like far more than it is.",
                    "Log episodes in Momsy so you can show a pattern rather than a memory at the next appointment."
                ],
                ru: [
                    "Обратите внимание на силу: при срыгивании содержимое просто вытекает изо рта, рвота выбрасывается с усилием.",
                    "Посмотрите на ребёнка: после срыгивания он ведёт себя как ни в чём не бывало, после рвоты обычно расстроен.",
                    "Посмотрите на цвет: молочно-белое или слегка створоженное — ожидаемо; зелёное, жёлтое, коричневое или с прожилками крови — нет.",
                    "Оцените объём — столовая ложка широко расплывается по пелёнке и часто выглядит куда обильнее, чем есть.",
                    "Отмечайте эпизоды в Momsy, чтобы на приёме показать динамику, а не полагаться на память."
                ],
                de: [
                    "Achten Sie auf die Kraft: Spucken fließt aus dem Mund, Erbrechen wird mit Anstrengung ausgestoßen.",
                    "Schauen Sie Ihr Baby an: Nach dem Spucken machen sie weiter, als wäre nichts passiert; nach dem Erbrechen sind sie normalerweise verärgert.",
                    "Achten Sie auf die Farbe: Milchweiß oder leicht geronnen ist normal; grün, gelb, braun oder blutgestreift ist nicht normal.",
                    "Beachten Sie die Menge — ein Esslöffel breitet sich auf einem Tuch weit aus und sieht oft viel größer aus als es ist.",
                    "Notieren Sie Episoden in Momsy, damit Sie beim nächsten Termin ein Muster zeigen können, anstatt sich auf Ihre Erinnerung zu verlassen."
                ],
                es: [
                    "Fíjate en la fuerza: la regurgitación sale de la boca, el vómito se expulsa con esfuerzo.",
                    "Mira a tu bebé: después de regurgitar sigue como si nada; después de vomitar suelen estar molestos.",
                    "Fijaos en el color: se espera un blanco lechoso o ligeramente cuajado; verde, amarillo, marrón o con rayas de sangre no lo es.",
                    "Tenga en cuenta el volumen: una cucharada se esparce ampliamente sobre una muselina y, a menudo, parece mucho más de lo que es.",
                    "Registre episodios en Momsy para poder mostrar un patrón en lugar de un recuerdo en la próxima cita.",
                ],
                fr: [
                    "Regardez la force : les crachats sortent de la bouche, le vomi est expulsé avec effort.",
                    "Regardez votre bébé : après avoir craché, il continue comme si de rien n'était ; après avoir vomi, ils sont généralement bouleversés.",
                    "Regardez la couleur : on s'attend à un blanc laiteux ou légèrement caillé ; le vert, le jaune, le brun ou le sang ne le sont pas.",
                    "Notez le volume : une cuillère à soupe s'étale largement sur une mousseline et semble souvent bien plus grande qu'elle ne l'est en réalité.",
                    "Enregistrez les épisodes dans Momsy afin de pouvoir afficher un modèle plutôt qu'un souvenir lors du prochain rendez-vous.",
                ],
                pt: [
                    "Olha a força: o cuspe sai pela boca, o vômito é expelido com esforço.",
                    "Olhe para o seu bebê: depois de cuspir ele fica como se nada tivesse acontecido; depois de vomitar, geralmente ficam chateados.",
                    "Observe a cor: espera-se branco leitoso ou levemente coalhado; verde, amarelo, marrom ou com manchas de sangue não é.",
                    "Observe o volume – uma colher de sopa se espalha amplamente sobre uma musselina e muitas vezes parece muito mais do que realmente é.",
                    "Registre episódios no Momsy para que você possa mostrar um padrão em vez de uma memória no próximo compromisso.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Around half of all babies spit up in the first months, simply because the ring of muscle at the top of the stomach is still maturing. That is a laundry problem, not a medical one, as long as your baby is comfortable and gaining weight. Vomiting is a different event with different causes, so separating the two in your own mind saves a lot of unnecessary worry — and makes the genuinely concerning episodes stand out.",
                ru: "Примерно половина всех младенцев срыгивает в первые месяцы просто потому, что мышечное кольцо в верхней части желудка ещё дозревает. Это проблема стирки, а не медицины, пока ребёнку комфортно и он прибавляет в весе. Рвота — другое событие с другими причинами, поэтому умение различать их избавляет от множества лишних тревог и позволяет заметить действительно настораживающие эпизоды.",
                de: "Etwa die Hälfte aller Babys speien in den ersten Monaten, einfach weil der Muskelring oben am Magen noch ausreift. Das ist ein Wäscheproblem, kein medizinisches, solange Ihr Baby komfortabel ist und an Gewicht zunimmt. Erbrechen ist ein anderes Ereignis mit anderen Ursachen, also spart das Trennen der beiden in Ihrem Kopf viel unnötige Sorge — und macht die wirklich besorgniserregenden Episoden hervorgehoben.",
                es: "Aproximadamente la mitad de los bebés regurgitan durante los primeros meses, simplemente porque el anillo muscular en la parte superior del estómago todavía está madurando. Ése es un problema de lavandería, no médico, siempre y cuando su bebé esté cómodo y aumente de peso. El vómito es un evento diferente con causas diferentes, por lo que separar los dos en su mente le ahorra muchas preocupaciones innecesarias y hace que los episodios genuinamente preocupantes se destaquen.",
                fr: "Environ la moitié des bébés régurgitent au cours des premiers mois, simplement parce que l'anneau musculaire situé au sommet de l'estomac est encore en train de mûrir. Il s’agit d’un problème de lessive et non médical, tant que votre bébé se sent à l’aise et prend du poids. Les vomissements sont un événement différent avec des causes différentes, donc séparer les deux dans votre esprit vous évite bien des soucis inutiles et fait ressortir les épisodes véritablement préoccupants.",
                pt: "Cerca de metade dos bebês cuspe nos primeiros meses, simplesmente porque o anel muscular na parte superior do estômago ainda está amadurecendo. Esse é um problema de lavanderia, não médico, desde que seu bebê esteja confortável e ganhando peso. O vômito é um evento diferente com causas diferentes, portanto, separar os dois em sua mente evita muitas preocupações desnecessárias – e faz com que os episódios genuinamente preocupantes se destaquem."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Cutting feed volumes because of frequent spit-up, which can affect weight gain.",
                    "Switching formula repeatedly without medical advice.",
                    "Judging severity by how large the stain looks.",
                    "Adding thickeners or cereal to bottles without a doctor's guidance."
                ],
                ru: [
                    "Уменьшать объём кормления из-за частых срыгиваний — это может сказаться на прибавке в весе.",
                    "Постоянно менять смесь без совета врача.",
                    "Оценивать серьёзность по размеру пятна.",
                    "Добавлять в бутылочку загустители или кашу без назначения врача."
                ],
                de: [
                    "Fütterungsmengen aufgrund von häufigem Spucken reduzieren, was die Gewichtszunahme beeinträchtigen kann.",
                    "Formel wiederholt ohne ärztliche Anleitung wechseln.",
                    "Den Schweregrad anhand der Größe des Flecks beurteilen.",
                    "Verdickte oder Getreide in Flaschen ohne ärztliche Anleitung hinzufügen."
                ],
                es: [
                    "Reducir los volúmenes de alimento debido a regurgitaciones frecuentes, que pueden afectar el aumento de peso.",
                    "Cambiar de fórmula repetidamente sin consejo médico.",
                    "Juzgar la gravedad por el tamaño de la mancha.",
                    "Agregar espesantes o cereales a los biberones sin la orientación de un médico.",
                ],
                fr: [
                    "Réduire les volumes d’aliments en raison de régurgitations fréquentes, qui peuvent affecter la prise de poids.",
                    "Changer de formule à plusieurs reprises sans avis médical.",
                    "Juger de la gravité par la taille de la tache.",
                    "Ajouter des épaississants ou des céréales aux bouteilles sans l'avis d'un médecin.",
                ],
                pt: [
                    "Cortar o volume de ração devido a cusparadas frequentes, o que pode afetar o ganho de peso.",
                    "Trocar de fórmula repetidamente sem orientação médica.",
                    "Julgar a gravidade pelo tamanho da mancha.",
                    "Adicionar espessantes ou cereais às mamadeiras sem orientação médica.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Vomit is green or yellow, contains blood, or looks like coffee grounds.",
                    "Vomiting is forceful and repeated after most feeds.",
                    "Signs of dehydration: dry mouth, sunken fontanelle, far fewer wet nappies, unusual drowsiness.",
                    "Vomiting together with fever, a swollen tummy, or refusal to feed."
                ],
                ru: [
                    "Рвотные массы зелёные или жёлтые, с кровью либо цвета кофейной гущи.",
                    "Рвота фонтаном и повторяется после большинства кормлений.",
                    "Признаки обезвоживания: сухость во рту, запавший родничок, заметно меньше мокрых подгузников, необычная сонливость.",
                    "Рвота вместе с температурой, вздутым животом или отказом от еды."
                ],
                de: [
                    "Erbrechen ist grün oder gelb, enthält Blut oder sieht wie Kaffeesatz aus.",
                    "Erbrechen ist gewaltsam und wiederholt sich nach den meisten Mahlzeiten.",
                    "Anzeichen von Dehydrierung: trockener Mund, eingefallener Fontanelle, deutlich weniger nasse Windeln, ungewöhnliche Schläfrigkeit.",
                    "Erbrechen zusammen mit Fieber, aufgeblähtem Bauch oder Fütterungsverweigerung."
                ],
                es: [
                    "El vómito es verde o amarillo, contiene sangre o parece posos de café.",
                    "El vómito es fuerte y repetido después de la mayoría de las tomas.",
                    "Signos de deshidratación: boca seca, fontanela hundida, muchos menos pañales mojados, somnolencia inusual.",
                    "Vómitos junto con fiebre, barriga hinchada o negativa a alimentarse.",
                ],
                fr: [
                    "Le vomi est vert ou jaune, contient du sang ou ressemble à du marc de café.",
                    "Les vomissements sont violents et répétés après la plupart des tétées.",
                    "Signes de déshydratation : bouche sèche, fontanelle enfoncée, couches mouillées beaucoup moins nombreuses, somnolence inhabituelle.",
                    "Vomissements accompagnés de fièvre, d'un ventre gonflé ou d'un refus de se nourrir.",
                ],
                pt: [
                    "O vômito é verde ou amarelo, contém sangue ou parece borra de café.",
                    "O vômito é forte e repetido após a maioria das mamadas.",
                    "Sinais de desidratação: boca seca, fontanela afundada, muito menos fraldas molhadas, sonolência incomum.",
                    "Vômito acompanhado de febre, barriga inchada ou recusa em alimentar-se.",
                ]
            )
        ),

        CareTip(
            id: 1007, category: .feeding, icon: "fork.knife", ageFrom: 5, ageTo: 8,
            title: LocalizedText(
                en: "Starting solids: read your baby, not the calendar",
                ru: "Начало прикорма: смотрите на ребёнка, а не на календарь",
                de: "Feste Nahrung beginnen: Schauen Sie auf Ihr Baby, nicht auf den Kalender",
                es: "Empezar con sólidos: observa a tu bebé, no el calendario",
                fr: "Commencer les aliments solides : observez votre bébé, pas le calendrier",
                pt: "Começando com sólidos: leia seu bebê, não o calendário"
            ),
            summary: LocalizedText(
                en: "Around six months, and only when all three readiness signs are there",
                ru: "Примерно в шесть месяцев и только при наличии всех трёх признаков готовности",
                de: "Ungefähr sechs Monate alt und nur wenn alle drei Bereitschaftszeichen vorhanden sind",
                es: "Alrededor de los seis meses y solo cuando estén presentes las tres señales de preparación",
                fr: "Vers six mois, et seulement lorsque les trois signes de préparation sont présents",
                pt: "Cerca de seis meses, e somente quando todos os três sinais de prontidão estiverem presentes"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Check the three signs together: sitting up with little support, steady head and neck control, and coordinated reaching for food and bringing it to the mouth.",
                    "Start with a single food at a time, offered once a day at a calm moment when your baby is not overly hungry.",
                    "Keep milk as the main source of nutrition — early solids are practice, not replacement calories.",
                    "Expect most of the first meals to end up on the face, the bib and the floor. That is the process working.",
                    "Log new foods and any reactions in Momsy's Food Diary."
                ],
                ru: [
                    "Проверьте все три признака вместе: ребёнок сидит с минимальной поддержкой, уверенно держит голову и шею, скоординированно тянется к еде и подносит её ко рту.",
                    "Начинайте с одного продукта за раз, предлагая его один раз в день в спокойный момент, когда ребёнок не слишком голоден.",
                    "Молоко остаётся основным источником питания — ранний прикорм это тренировка, а не замена калорий.",
                    "Будьте готовы, что большая часть первых порций окажется на лице, слюнявчике и полу. Так и должно быть.",
                    "Записывайте новые продукты и любые реакции в «Дневник питания» в Momsy."
                ],
                de: [
                    "Überprüfen Sie alle drei Zeichen zusammen: Aufrecht sitzen mit minimaler Unterstützung, stabiler Kopf- und Nackenk ontrolle und koordiniertes Greifen nach Essen und Hinführen zum Mund.",
                    "Beginnen Sie mit einer Mahlzeit auf einmal, angeboten einmal täglich in einem ruhigen Moment, wenn Ihr Baby nicht zu hungrig ist.",
                    "Milch bleibt die Hauptenergiequelle — frühe Nahrung ist Übung, kein Ersatz für Kalorien.",
                    "Erwarten Sie, dass die meisten ersten Mahlzeiten auf dem Gesicht, der Lätzchen und dem Boden landen. Das ist der Prozess der richtig funktioniert.",
                    "Notieren Sie neue Lebensmittel und alle Reaktionen in Momsys Ernährungstagebuch."
                ],
                es: [
                    "Compruebe los tres signos juntos: sentarse con poco apoyo, control constante de la cabeza y el cuello, y alcanzar la comida de manera coordinada y llevársela a la boca.",
                    "Comience con un solo alimento a la vez, ofrézcalo una vez al día en un momento tranquilo cuando su bebé no tenga demasiada hambre.",
                    "Mantenga la leche como la principal fuente de nutrición; los primeros sólidos son una práctica, no calorías de reemplazo.",
                    "Espere que la mayoría de las primeras comidas acaben en la cara, el babero y el suelo. Ese es el proceso que funciona.",
                    "Registre nuevos alimentos y cualquier reacción en el Diario de alimentos de Momsy.",
                ],
                fr: [
                    "Vérifiez les trois signes ensemble : être assis avec peu de soutien, contrôler fermement la tête et le cou et atteindre de manière coordonnée la nourriture et la porter à la bouche.",
                    "Commencez avec un seul aliment à la fois, offert une fois par jour à un moment calme où votre bébé n'a pas trop faim.",
                    "Gardez le lait comme principale source de nutrition – les premiers aliments solides sont de la pratique et non des calories de remplacement.",
                    "Attendez-vous à ce que la plupart des premiers repas finissent sur le visage, le bavoir et le sol. C'est le processus qui fonctionne.",
                    "Enregistrez les nouveaux aliments et toutes les réactions dans le journal alimentaire de Momsy.",
                ],
                pt: [
                    "Verifique os três sinais juntos: sentar-se com pouco apoio, controle firme da cabeça e do pescoço e alcançar o alimento de forma coordenada e levá-lo à boca.",
                    "Comece com um único alimento de cada vez, oferecido uma vez ao dia em um momento calmo, quando o bebê não estiver com muita fome.",
                    "Mantenha o leite como a principal fonte de nutrição – os primeiros sólidos são uma prática, não uma reposição de calorias.",
                    "Espere que a maior parte das primeiras refeições acabe no rosto, no babador e no chão. Esse é o processo funcionando.",
                    "Registre novos alimentos e quaisquer reações no Diário Alimentar da Momsy.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "The readiness signs exist because swallowing solid food safely depends on trunk control and on the tongue-thrust reflex fading, not on a date. Starting before those are in place raises the risk of choking and rarely helps sleep, despite the folklore. Starting well after six months can make new textures harder to accept and leaves iron stores unsupported.",
                ru: "Признаки готовности существуют потому, что безопасное глотание твёрдой пищи зависит от контроля корпуса и угасания выталкивающего рефлекса языка, а не от даты в календаре. Начало прикорма до их появления повышает риск подавиться и, вопреки народному мнению, редко улучшает сон. Начало заметно позже шести месяцев затрудняет принятие новых текстур и оставляет без поддержки запасы железа.",
                de: "Die Bereitschaftszeichen existieren, weil das sichere Schlucken fester Nahrung von der Rumpfkontrolle und dem Verblassen des Zungenstoß-Reflexes abhängt, nicht von einem Datum. Wenn man vorher beginnt, erhöht sich das Erstickungsrisiko und hilft selten beim Schlaf, trotz folkloristischer Annahmen. Wenn man viel später als sechs Monate beginnt, kann es schwieriger werden, neue Texturen zu akzeptieren, und die Eisenvorräte erhalten keine Unterstützung.",
                es: "Los signos de preparación existen porque tragar alimentos sólidos de manera segura depende del control del tronco y de la desaparición del reflejo de empujar la lengua, no de una cita. Comenzar antes de que estén colocados aumenta el riesgo de asfixia y rara vez ayuda a dormir, a pesar de lo que se dice. Comenzar mucho después de seis meses puede hacer que las nuevas texturas sean más difíciles de aceptar y dejar las reservas de hierro sin soporte.",
                fr: "Les signes de préparation existent parce que l'ingestion sûre d'aliments solides dépend du contrôle du tronc et de la disparition du réflexe de poussée de langue, et non d'un rendez-vous. Commencer avant que ceux-ci ne soient en place augmente le risque d’étouffement et aide rarement à dormir, malgré le folklore. Bien commencer après six mois peut rendre les nouvelles textures plus difficiles à accepter et laisser les réserves de fer sans soutien.",
                pt: "Os sinais de prontidão existem porque a deglutição segura de alimentos sólidos depende do controle do tronco e do desaparecimento do reflexo de impulso da língua, e não de um encontro. Começar antes de eles estarem instalados aumenta o risco de asfixia e raramente ajuda a dormir, apesar do folclore. Começar bem depois de seis meses pode dificultar a aceitação de novas texturas e deixar os estoques de ferro sem suporte."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Adding cereal to bottles in the hope of longer nights.",
                    "Judging readiness by weight or by how interested the baby seems in watching you eat.",
                    "Introducing several new foods on the same day, which hides the source of any reaction.",
                    "Treating a screwed-up face as rejection — new tastes often need many exposures."
                ],
                ru: [
                    "Добавлять кашу в бутылочку в надежде на более длинные ночи.",
                    "Оценивать готовность по весу или по тому, с каким интересом ребёнок смотрит, как вы едите.",
                    "Вводить несколько новых продуктов в один день — так не понять, что вызвало реакцию.",
                    "Считать сморщенное лицо отказом — новым вкусам часто нужно много повторных знакомств."
                ],
                de: [
                    "Getreide in Flaschen hinzufügen, in der Hoffnung auf längere Nächte.",
                    "Bereitschaft nach Gewicht oder danach beurteilen, wie interessiert das Baby beim Zuschauen beim Essen wirkt.",
                    "An einem Tag mehrere neue Lebensmittel einführen, was die Quelle einer Reaktion verbirgt.",
                    "Ein verzogenes Gesicht als Ablehnung behandeln — neue Geschmäcker brauchen oft viele Wiederholungen."
                ],
                es: [
                    "Agregar cereal a los biberones con la esperanza de tener noches más largas.",
                    "Juzgar la disposición por el peso o por el interés del bebé en verle comer.",
                    "Introducir varios alimentos nuevos el mismo día, lo que oculta el origen de cualquier reacción.",
                    "Tratar una cara jodida como rechazo: los nuevos gustos a menudo necesitan muchas exposiciones.",
                ],
                fr: [
                    "Ajouter des céréales aux bouteilles dans l'espoir de nuits plus longues.",
                    "Jugez de l'état de préparation en fonction du poids ou de l'intérêt du bébé à vous regarder manger.",
                    "Introduire plusieurs nouveaux aliments le même jour, ce qui cache la source de toute réaction.",
                    "Traiter un visage foiré comme un rejet – les nouveaux goûts nécessitent souvent de nombreuses expositions.",
                ],
                pt: [
                    "Adicionar cereais às garrafas na esperança de noites mais longas.",
                    "Julgar a prontidão pelo peso ou pelo grau de interesse do bebê em observar você comer.",
                    "Apresentar vários alimentos novos no mesmo dia, o que esconde a origem de qualquer reação.",
                    "Tratar uma cara confusa como rejeição – novos gostos muitas vezes precisam de muitas exposições.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby cannot sit with support or hold their head steady at six months.",
                    "Repeated gagging that turns into silent choking, or coughing that does not settle.",
                    "Any rash, swelling, vomiting or breathing change after a new food.",
                    "Consistent refusal of all solids by eight months."
                ],
                ru: [
                    "В шесть месяцев ребёнок не может сидеть с поддержкой или уверенно держать голову.",
                    "Повторяющиеся рвотные позывы, переходящие в беззвучное удушье, или непроходящий кашель.",
                    "Любая сыпь, отёк, рвота или изменение дыхания после нового продукта.",
                    "Стойкий отказ от любого прикорма к восьми месяцам."
                ],
                de: [
                    "Ihr Baby kann sich mit Unterstützung nicht hinsetzen oder den Kopf mit sechs Monaten nicht stabil halten.",
                    "Wiederholtes Würgen, das zu stillem Ersticken führt, oder Husten, der sich nicht bessert.",
                    "Irgendwelche Ausschläge, Schwellungen, Erbrechen oder Atemveränderungen nach einer neuen Mahlzeit.",
                    "Anhaltende Weigerung aller festen Nahrung mit acht Monaten."
                ],
                es: [
                    "Su bebé no puede sentarse con apoyo ni mantener la cabeza firme a los seis meses.",
                    "Náuseas repetidas que se convierten en ahogos silenciosos o tos que no cesa.",
                    "Cualquier sarpullido, hinchazón, vómitos o cambios en la respiración después de un nuevo alimento.",
                    "Rechazo constante de todos los sólidos a los ocho meses.",
                ],
                fr: [
                    "Votre bébé ne peut pas s'asseoir avec un soutien ou maintenir sa tête stable à six mois.",
                    "Des haut-le-coeur répétés qui se transforment en un étouffement silencieux ou une toux qui ne s'installe pas.",
                    "Toute éruption cutanée, gonflement, vomissement ou modification de la respiration après un nouvel aliment.",
                    "Refus cohérent de tous les solides avant huit mois.",
                ],
                pt: [
                    "Seu bebê não consegue sentar-se com apoio ou manter a cabeça firme aos seis meses.",
                    "Engasgos repetidos que se transformam em engasgos silenciosos ou tosse que não cessa.",
                    "Qualquer erupção cutânea, inchaço, vômito ou alteração respiratória após um novo alimento.",
                    "Recusa consistente de todos os sólidos por oito meses.",
                ]
            )
        ),

        CareTip(
            id: 1008, category: .feeding, icon: "moon.stars.fill", ageFrom: 0, ageTo: 3,
            title: LocalizedText(
                en: "Evening cluster feeding is normal, not a sign of low supply",
                ru: "Вечерние частые прикладывания — норма, а не признак нехватки молока",
                de: "Abendliches Cluster-Füttern ist normal, kein Zeichen niedriger Versorgung",
                es: "Las tomas frecuentes por la tarde son normales, no una señal de poca leche",
                fr: "Les tétées groupées du soir sont normales, pas un signe de manque de lait",
                pt: "A alimentação noturna em grupo é normal, não é um sinal de baixa oferta"
            ),
            summary: LocalizedText(
                en: "Back-to-back feeds between late afternoon and bedtime are a phase, not a problem",
                ru: "Кормления одно за другим с вечера до отбоя — это этап, а не проблема",
                de: "Aufeinanderfolgende Fütterungen zwischen spätem Nachmittag und Schlafenszeit sind eine Phase, kein Problem",
                es: "Las tomas seguidas entre la tarde y la hora de dormir son una etapa, no un problema",
                fr: "Les tétées rapprochées entre la fin de l’après-midi et le coucher sont une phase, pas un problème",
                pt: "As mamadas consecutivas entre o final da tarde e a hora de dormir são uma fase, não um problema"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Expect clusters most often in the late afternoon and evening, and around growth spurts.",
                    "Set yourself up before it starts: water, snacks, a charged phone, a comfortable seat.",
                    "Offer whenever your baby asks rather than trying to stretch intervals during the cluster.",
                    "Hand the baby over between feeds if a co-parent is around — the feeding parent needs the breaks more than the cuddles.",
                    "Check the reassuring signs: enough wet nappies, steady weight gain, and periods of alert calm during the day."
                ],
                ru: [
                    "Чаще всего такие серии кормлений бывают ближе к вечеру и вечером, а также в периоды скачков роста.",
                    "Подготовьтесь заранее: вода, перекус, заряженный телефон, удобное место.",
                    "Предлагайте грудь по каждому запросу, не пытаясь растягивать интервалы в этот период.",
                    "Передавайте ребёнка между кормлениями, если рядом второй родитель, — кормящему родителю нужнее перерывы, чем объятия.",
                    "Проверьте обнадёживающие признаки: достаточно мокрых подгузников, стабильная прибавка в весе и периоды спокойного бодрствования днём."
                ],
                de: [
                    "Erwarten Sie Cluster am häufigsten am späten Nachmittag und Abend sowie um Wachstumsschübe.",
                    "Bereiten Sie sich vor: Wasser, Snacks, ein aufgeladenes Telefon, ein bequemer Sitz.",
                    "Bieten Sie immer dann an, wenn Ihr Baby fragt, anstatt zu versuchen, die Intervalle während des Clusters zu verlängern.",
                    "Geben Sie das Baby zwischen den Mahlzeiten ab, wenn ein Co-Elternteil in der Nähe ist — das fütternde Elternteil braucht eher Pausen als Umarmungen.",
                    "Überprüfen Sie die beruhigenden Zeichen: ausreichend nasse Windeln, konstante Gewichtszunahme und Phasen ruhigen Wachseins während des Tages."
                ],
                es: [
                    "Espere grupos con mayor frecuencia al final de la tarde y al anochecer, y alrededor de períodos de crecimiento acelerado.",
                    "Prepárate antes de que comience: agua, refrigerios, un teléfono cargado, un asiento cómodo.",
                    "Ofrécele cada vez que tu bebé te lo pida en lugar de intentar estirar los intervalos durante el grupo.",
                    "Entregue al bebé entre tomas si hay otro padre cerca; el padre que amamanta necesita más descansos que abrazos.",
                    "Compruebe los signos tranquilizadores: suficientes pañales mojados, aumento constante de peso y períodos de alerta y calma durante el día.",
                ],
                fr: [
                    "Attendez-vous à des grappes le plus souvent en fin d’après-midi et en soirée, ainsi qu’autour des poussées de croissance.",
                    "Préparez-vous avant le début : de l’eau, des collations, un téléphone chargé, un siège confortable.",
                    "Offrez-le chaque fois que votre bébé le demande plutôt que d'essayer d'allonger les intervalles pendant la grappe.",
                    "Remettez le bébé entre les tétées si un coparent est présent – le parent qui nourrit a plus besoin de pauses que de câlins.",
                    "Vérifiez les signes rassurants : suffisamment de couches mouillées, une prise de poids régulière et des périodes de calme alerte dans la journée.",
                ],
                pt: [
                    "Espere aglomerados com mais frequência no final da tarde e à noite, e perto de surtos de crescimento.",
                    "Prepare-se antes de começar: água, lanches, telefone carregado, assento confortável.",
                    "Ofereça sempre que seu bebê pedir, em vez de tentar esticar os intervalos durante o cluster.",
                    "Entregue o bebê entre as mamadas se um dos pais estiver por perto - o pai que amamenta precisa mais de pausas do que de abraços.",
                    "Verifique os sinais tranquilizadores: fraldas molhadas suficientes, ganho de peso constante e períodos de calma alerta durante o dia.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Milk fat content and volume vary naturally through the day, and evening feeds tend to be shorter and less satisfying individually — so babies simply take more of them. Frequent evening stimulation also signals the breast to make more milk for the following day. Knowing the pattern is expected takes away the two things that make it hard: the fear that something is wrong, and the sense that it will never end.",
                ru: "Жирность и объём молока естественным образом меняются в течение дня, а вечерние кормления обычно короче и по отдельности менее насыщающие — поэтому дети просто берут грудь чаще. Частая вечерняя стимуляция к тому же сигнализирует груди вырабатывать больше молока на следующий день. Понимание, что так и должно быть, убирает две главные трудности: страх, что что-то не так, и ощущение, что это никогда не закончится.",
                de: "Der Milchfettgehalt und das Volumen variieren natürlich im Laufe des Tages, und Abendmahlzeiten sind in der Regel kürzer und weniger befriedigend — also nehmen Babys einfach mehr von ihnen. Häufige abendliche Stimulation signalisiert der Brust auch, mehr Milch für den nächsten Tag zu produzieren. Zu wissen, dass dieses Muster zu erwarten ist, nimmt zwei Dinge, die es schwer machen, weg: die Angst, dass etwas nicht stimmt, und das Gefühl, dass es nie enden wird.",
                es: "El contenido y el volumen de grasa de la leche varían naturalmente a lo largo del día, y las tomas nocturnas tienden a ser más cortas y menos satisfactorias individualmente, por lo que los bebés simplemente toman más cantidad. La estimulación nocturna frecuente también indica al pecho que produzca más leche para el día siguiente. Saber que se espera un patrón elimina las dos cosas que lo hacen difícil: el miedo a que algo ande mal y la sensación de que nunca terminará.",
                fr: "La teneur en matières grasses et le volume du lait varient naturellement au cours de la journée, et les tétées du soir ont tendance à être plus courtes et moins satisfaisantes individuellement – de sorte que les bébés en prennent simplement plus. Une stimulation fréquente le soir signale également au sein de produire plus de lait pour le lendemain. Connaître le schéma attendu élimine les deux choses qui rendent les choses difficiles : la peur que quelque chose ne va pas et le sentiment que cela ne finira jamais.",
                pt: "O conteúdo e o volume de gordura do leite variam naturalmente ao longo do dia, e as mamadas noturnas tendem a ser mais curtas e menos satisfatórias individualmente – então os bebês simplesmente ingerem mais. A estimulação noturna frequente também sinaliza ao seio para produzir mais leite no dia seguinte. Saber o padrão esperado elimina as duas coisas que o tornam difícil: o medo de que algo esteja errado e a sensação de que nunca terá fim."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Reading the cluster as proof that milk has run out and topping up in panic.",
                    "Timing feeds and enforcing intervals during the cluster window.",
                    "Assuming a baby who cannot settle in the evening is simply hungry rather than overtired."
                ],
                ru: [
                    "Принимать серию частых кормлений за доказательство, что молоко закончилось, и в панике докармливать смесью.",
                    "Засекать время кормлений и выдерживать интервалы в этот вечерний период.",
                    "Считать, что ребёнок, который не может успокоиться вечером, просто голоден, а не переутомлён."
                ],
                de: [
                    "Das Cluster als Beweis lesen, dass die Milch aufgebraucht ist, und in Panik nachfüttern.",
                    "Fütterungen zeitlich planen und Intervalle während des Cluster-Fensters durchsetzen.",
                    "Angenommen, ein Baby, das sich abends nicht beruhigen kann, ist einfach hungrig und nicht überfordert."
                ],
                es: [
                    "Leer el racimo como prueba de que se ha acabado la leche y rellenar presa del pánico.",
                    "Cronometrar las transmisiones y aplicar intervalos durante la ventana del clúster.",
                    "Supongamos que un bebé que no puede calmarse por la noche simplemente tiene hambre y no está demasiado cansado.",
                ],
                fr: [
                    "Lire le cluster comme preuve que le lait est épuisé et faire l'appoint en panique.",
                    "Synchronisation des flux et application des intervalles pendant la fenêtre du cluster.",
                    "Supposons qu’un bébé qui n’arrive pas à s’installer le soir ait simplement faim plutôt que d’être fatigué.",
                ],
                pt: [
                    "Lendo o cluster como prova de que o leite acabou e completando em pânico.",
                    "Cronometrar feeds e impor intervalos durante a janela do cluster.",
                    "Suponha que um bebê que não consegue se acomodar à noite esteja simplesmente com fome, e não cansado.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Fewer than six wet nappies a day after the first week.",
                    "No weight gain over two weeks, or weight loss.",
                    "Your baby is hard to rouse, unusually floppy, or feeds weakly.",
                    "Feeding is painful for you, or nipples are cracked and bleeding."
                ],
                ru: [
                    "Меньше шести мокрых подгузников в сутки после первой недели.",
                    "Нет прибавки в весе в течение двух недель или вес снижается.",
                    "Ребёнка трудно разбудить, он необычно вялый или слабо сосёт.",
                    "Кормление болезненно для вас или соски потрескались и кровоточат."
                ],
                de: [
                    "Weniger als sechs nasse Windeln pro Tag nach der ersten Woche.",
                    "Keine Gewichtszunahme über zwei Wochen oder Gewichtsverlust.",
                    "Ihr Baby ist schwer zu wecken, ungewöhnlich schlaff oder saugt schwach.",
                    "Füttern ist für Sie schmerzhaft oder die Brustwarzen sind gerissen und bluten."
                ],
                es: [
                    "Menos de seis pañales mojados al día después de la primera semana.",
                    "No hay aumento de peso durante dos semanas ni pérdida de peso.",
                    "Es difícil despertar a su bebé, está inusualmente flácido o se alimenta débilmente.",
                    "La alimentación le resulta dolorosa o los pezones están agrietados y sangrando.",
                ],
                fr: [
                    "Moins de six couches mouillées par jour après la première semaine.",
                    "Pas de prise de poids sur deux semaines, ni de perte de poids.",
                    "Votre bébé est difficile à réveiller, est inhabituellement mou ou tète faiblement.",
                    "L'alimentation est douloureuse pour vous ou les mamelons sont fissurés et saignent.",
                ],
                pt: [
                    "Menos de seis fraldas molhadas por dia após a primeira semana.",
                    "Nenhum ganho de peso durante duas semanas ou perda de peso.",
                    "Seu bebê tem dificuldade para acordar, é incomumente mole ou se alimenta fracamente.",
                    "A alimentação é dolorosa para você ou os mamilos estão rachados e sangrando.",
                ]
            )
        )
    ]
}
