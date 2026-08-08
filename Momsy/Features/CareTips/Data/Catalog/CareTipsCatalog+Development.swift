import Foundation

extension CareTipsCatalog {
    static let development: [CareTip] = [

        CareTip(
            id: 1401, category: .development, icon: "figure.child", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Tummy time from the first week",
                ru: "Выкладывание на живот с первой недели",
                de: "Bauchzeit ab der ersten Woche",
                es: "Tiempo boca abajo desde la primera semana",
                fr: "Temps sur le ventre dès la première semaine",
                pt: "Tempo de barriga desde a primeira semana",
                zh: "从第一周开始的俯卧时间"
            ),
            summary: LocalizedText(
                en: "Start with three to five minutes a few times a day and build from there",
                ru: "Начните с трёх-пяти минут несколько раз в день и постепенно увеличивайте",
                de: "Beginnen Sie mit drei bis fünf Minuten mehrmals am Tag und bauen Sie auf",
                es: "Empieza con tres a cinco minutos varias veces al día y ve aumentando",
                fr: "Commencez par trois à cinq minutes plusieurs fois par jour et développez à partir de là",
                pt: "Comece com três a cinco minutos algumas vezes ao dia e desenvolva a partir daí",
                zh: "从每天几次三到五分钟开始，然后从那里开始构建"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Begin on day one or two: chest-to-chest on your reclined body counts as tummy time.",
                    "Move to a firm flat surface for short sessions, two or three times a day.",
                    "Choose the moment well — after a nappy change, before a feed, never straight after eating.",
                    "Get down to eye level, talk, and use a mirror or a high-contrast card to give them a reason to lift.",
                    "Build towards roughly an hour spread across the day by three months. Always awake and supervised."
                ],
                ru: [
                    "Начинайте с первого-второго дня: положение грудь к груди на вашем полулежащем теле тоже считается выкладыванием на живот.",
                    "Переходите к твёрдой ровной поверхности для коротких занятий два-три раза в день.",
                    "Выбирайте подходящий момент — после смены подгузника, перед кормлением, но никогда сразу после еды.",
                    "Опуститесь на уровень глаз ребёнка, разговаривайте, покажите зеркало или контрастную картинку, чтобы у него был повод поднять голову.",
                    "К трём месяцам стремитесь примерно к часу в сутки суммарно. Всегда только в бодрствовании и под присмотром."
                ],
                de: [
                    "Beginnen Sie am ersten oder zweiten Tag: Brust an Brust auf Ihrem halbaufgerichteten Körper zählt auch als Bauchzeit.",
                    "Gehen Sie zu einer festen, ebenen Fläche für kurze Einheiten, zwei- oder dreimal täglich über.",
                    "Wählen Sie den richtigen Moment – nach dem Windelwechsel, vor der Fütterung, nie direkt nach dem Essen.",
                    "Gehen Sie auf Augenhöhe, sprechen Sie und nutzen Sie einen Spiegel oder eine hochkontrastive Karte, um dem Baby einen Grund zu geben, den Kopf zu heben.",
                    "Arbeiten Sie bis drei Monaten auf insgesamt etwa eine Stunde pro Tag hin, verteilt über den Tag. Immer wach und überwacht."
                ],
                es: [
                    "Empieza el primer o segundo día: pecho con pecho sobre tu cuerpo reclinado ya cuenta como tiempo boca abajo.",
                    "Pasa a una superficie firme y plana en sesiones cortas, dos o tres veces al día.",
                    "Elige bien el momento: después de un cambio de pañal, antes de una toma, nunca justo después de comer.",
                    "Ponte a su altura, háblale y usa un espejo o una lámina de alto contraste para darle un motivo para levantar la cabeza.",
                    "Ve acercándote a una hora repartida a lo largo del día hacia los tres meses. Siempre despierto y vigilado."
                ],
                fr: [
                    "Commencez le premier ou le deuxième jour : le mouvement poitrine contre poitrine sur votre corps incliné compte pour du temps sur le ventre.",
                    "Déplacez-vous sur une surface plane et ferme pour de courtes séances, deux ou trois fois par jour.",
                    "Choisissez bien le moment : après le changement de couche, avant la tétée, jamais juste après avoir mangé.",
                    "Mettez-vous à hauteur des yeux, parlez et utilisez un miroir ou une carte à contraste élevé pour leur donner une raison de soulever.",
                    "Construisez environ une heure répartie sur la journée sur trois mois. Toujours éveillé et surveillé.",
                ],
                pt: [
                    "Comece no primeiro ou segundo dia: peito a peito com o corpo reclinado conta como tempo de barriga para baixo.",
                    "Vá para uma superfície plana e firme para sessões curtas, duas ou três vezes ao dia.",
                    "Escolha bem o momento – depois de trocar a fralda, antes da mamada, nunca logo após comer.",
                    "Abaixe-se ao nível dos olhos, converse e use um espelho ou um cartão de alto contraste para dar-lhes um motivo para levantar.",
                    "Construa para aproximadamente uma hora, distribuída ao longo do dia por três meses. Sempre acordado e supervisionado.",
                ],
                zh: [
                    "从第一天或第二天开始：斜躺的身体上胸部接触胸部的时间算作俯卧时间。",
                    "转移到坚硬平坦的表面进行短期训练，每天两次或三次。",
                    "选择好时机——换尿布后、喂奶前，切勿在刚吃完饭后。",
                    "俯身与视线齐平，交谈，并使用镜子或高对比度卡片给他们举起的理由。",
                    "三个月内逐渐争取每天大约一个小时。始终保持清醒并受到监督。",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Everything from head control to rolling, sitting and eventually crawling depends on the neck, shoulder and back strength that only develops against gravity. Since babies now spend nights and naps on their backs — correctly so — the awake hours are where that work has to happen. It also takes pressure off the back of the skull, which protects head shape at the same time.",
                ru: "Всё — от удержания головы до переворотов, сидения и в итоге ползания — зависит от силы мышц шеи, плечевого пояса и спины, которая развивается только в работе против силы тяжести. Поскольку ночью и в дневной сон дети теперь спят на спине (и это правильно), эта работа приходится на время бодрствования. Заодно снимается давление с затылка, что помогает сохранить форму головы.",
                de: "Alles – von der Kopfkontrolle über das Rollen und Sitzen bis hin zum Krabbeln – hängt von der Nacken-, Schulter- und Rückenstärke ab, die sich nur gegen die Schwerkraft entwickelt. Da Babys nun Nächte und Nickerchen auf dem Rücken verbringen – zu Recht – geschieht diese Entwicklung während der wachen Stunden. Dies entlastet auch die Rückseite des Schädels, was gleichzeitig die Kopfform schützt.",
                es: "Todo, desde el control de la cabeza hasta girarse, sentarse y finalmente gatear, depende de la fuerza de cuello, hombros y espalda que solo se desarrolla contra la gravedad. Como los bebés pasan las noches y las siestas boca arriba —y así debe ser—, ese trabajo tiene que hacerse en las horas de vigilia. Además quita presión de la parte posterior del cráneo, lo que protege la forma de la cabeza al mismo tiempo.",
                fr: "Tout, depuis le contrôle de la tête jusqu'à rouler, s'asseoir et éventuellement ramper, dépend de la force du cou, des épaules et du dos qui ne se développe que contre la gravité. Puisque les bébés passent désormais leurs nuits et leurs siestes sur le dos – à juste titre – c’est pendant les heures d’éveil que ce travail doit être effectué. Il soulage également la pression exercée sur l'arrière du crâne, ce qui protège en même temps la forme de la tête.",
                pt: "Tudo, desde o controle da cabeça até rolar, sentar e eventualmente engatinhar, depende da força do pescoço, ombros e costas que só se desenvolve contra a gravidade. Como os bebês agora passam as noites e cochilam de costas - com razão - é nas horas de vigília que esse trabalho deve acontecer. Ele também tira a pressão da parte de trás do crânio, o que ao mesmo tempo protege o formato da cabeça.",
                zh: "从头部控制到翻身、坐立和最终爬行，一切都取决于颈部、肩部和背部的力量，而这些力量只能在对抗重力的情况下发展。由于婴儿现在晚上和小睡都是仰卧的——这是正确的——醒着的时间就是这项工作必须进行的时间。它还可以减轻头骨后部的压力，同时保护头部形状。"
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Skipping it because the baby protests — short frequent sessions beat one long unhappy one.",
                    "Tummy time straight after a feed.",
                    "Only on a soft mattress or sofa, where there is nothing firm to push against.",
                    "Leaving the baby unattended, or letting them fall asleep on their front."
                ],
                ru: [
                    "Отказываться из-за протестов ребёнка — короткие частые подходы лучше одного долгого и мучительного.",
                    "Выкладывать на живот сразу после кормления.",
                    "Делать это только на мягком матрасе или диване, где не от чего оттолкнуться.",
                    "Оставлять ребёнка без присмотра или позволять ему уснуть на животе."
                ],
                de: [
                    "Es auslassen, weil das Baby protestiert – kurze häufige Einheiten sind besser als eine lange unglückliche.",
                    "Bauchzeit direkt nach der Fütterung.",
                    "Nur auf einer weichen Matratze oder einem Sofa, wo es nichts zum Abstoßen gibt.",
                    "Das Baby ohne Aufsicht lassen oder es auf dem Bauch einschlafen lassen."
                ],
                es: [
                    "Saltárselo porque el bebé protesta: sesiones cortas y frecuentes superan a una larga y llorosa.",
                    "Ponerlo boca abajo justo después de una toma.",
                    "Hacerlo solo sobre un colchón blando o el sofá, donde no hay nada firme contra lo que empujar.",
                    "Dejar al bebé sin vigilancia, o permitir que se duerma boca abajo."
                ],
                fr: [
                    "Sautez-le parce que le bébé proteste – de courtes séances fréquentes battent une longue et malheureuse.",
                    "Temps sur le ventre juste après une tétée.",
                    "Uniquement sur un matelas moelleux ou un canapé, où il n'y a rien de ferme contre quoi pousser.",
                    "Laisser le bébé sans surveillance ou le laisser s'endormir sur le ventre.",
                ],
                pt: [
                    "Ignorar porque o bebê protesta - sessões curtas e frequentes superam uma sessão longa e infeliz.",
                    "Hora de ficar de bruços logo após a mamada.",
                    "Somente em colchão ou sofá macio, onde não haja nada firme para empurrar.",
                    "Deixar o bebê sozinho ou deixá-lo dormir de bruços.",
                ],
                zh: [
                    "跳过它是因为婴儿抗议——短而频繁的治疗胜过长时间不愉快的治疗。",
                    "喂奶后立即趴着的时间。",
                    "只能在柔软的床垫或沙发上，没有任何坚硬的东西可以推挤。",
                    "让婴儿无人看管，或者让他们趴着睡。",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "No head lift at all by three months.",
                    "Your baby consistently turns the head to only one side.",
                    "One side of the body feels stiffer or is clearly used less.",
                    "Head control seems to go backwards after it had been improving."
                ],
                ru: [
                    "К трём месяцам ребёнок совсем не поднимает голову.",
                    "Ребёнок постоянно поворачивает голову только в одну сторону.",
                    "Одна сторона тела кажется более напряжённой или явно меньше используется.",
                    "Контроль головы ухудшился после того, как уже улучшался."
                ],
                de: [
                    "Mit drei Monaten hebt das Baby den Kopf gar nicht.",
                    "Ihr Baby dreht den Kopf konsistent nur nach einer Seite.",
                    "Eine Seite des Körpers fühlt sich steifer an oder wird deutlich weniger benutzt.",
                    "Die Kopfkontrolle scheint sich zu verschlechtern, nachdem sie sich verbessert hatte."
                ],
                es: [
                    "No levanta nada la cabeza a los tres meses.",
                    "El bebé gira la cabeza siempre hacia el mismo lado.",
                    "Un lado del cuerpo se nota más rígido o claramente se usa menos.",
                    "El control de la cabeza parece retroceder después de haber ido mejorando."
                ],
                fr: [
                    "Aucun lifting du tout d’ici trois mois.",
                    "Votre bébé tourne constamment la tête d’un seul côté.",
                    "Un côté du corps semble plus rigide ou est clairement moins utilisé.",
                    "Le contrôle de la tête semble reculer après s'être amélioré.",
                ],
                pt: [
                    "Nenhuma elevação de cabeça por três meses.",
                    "Seu bebê vira consistentemente a cabeça apenas para um lado.",
                    "Um lado do corpo parece mais rígido ou é claramente menos usado.",
                    "O controle da cabeça parece retroceder depois de ter melhorado.",
                ],
                zh: [
                    "三个月了头完全没有抬起来。",
                    "您的宝宝始终只将头转向一侧。",
                    "身体的一侧感觉更僵硬或明显使用较少。",
                    "头部控制能力在改善后似乎出现了倒退。",
                ]
            )
        ),

        CareTip(
            id: 1402, category: .development, icon: "circle.righthalf.filled", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Keeping head shape round",
                ru: "Как сохранить круглую форму головы",
                de: "Kopfform rund halten",
                es: "Mantener redonda la forma de la cabeza",
                fr: "Garder la forme de la tête ronde",
                pt: "Mantendo o formato da cabeça redondo",
                zh: "保持头部形状呈圆形"
            ),
            summary: LocalizedText(
                en: "Vary the pressure point: alternate head position, cot orientation and carrying arm",
                ru: "Меняйте точку давления: положение головы, ориентацию в кроватке и руку, на которой носите",
                de: "Variieren Sie den Druckpunkt: wechseln Sie Kopfposition, Bettenausrichtung und Tragearm",
                es: "Varía el punto de apoyo: alterna la posición de la cabeza, la orientación en la cuna y el brazo con que lo llevas",
                fr: "Variez le point de pression : alternez la position de la tête, l'orientation du lit et le bras de transport.",
                pt: "Varie o ponto de pressão: alterne a posição da cabeça, a orientação do berço e o braço de transporte",
                zh: "改变压力点：交替头部位置、床方向和支撑臂"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Alternate which end of the cot the head goes to each night, so your baby turns towards the room from both sides.",
                    "Move the mobile or the interesting side of the room from time to time.",
                    "Switch the arm you carry and feed on, even if bottle feeding.",
                    "Increase awake time off the back of the head — tummy time, side-lying play, upright carrying.",
                    "Limit time in car seats, bouncers and swings to what travel actually requires."
                ],
                ru: [
                    "Каждую ночь кладите ребёнка головой к разным концам кроватки, чтобы он поворачивался к комнате то одной, то другой стороной.",
                    "Время от времени перевешивайте мобиль или меняйте «интересную» сторону комнаты.",
                    "Меняйте руку, на которой носите и кормите, в том числе при кормлении из бутылочки.",
                    "Увеличивайте время бодрствования без опоры на затылок — выкладывание на живот, игра на боку, ношение вертикально.",
                    "Ограничьте время в автокресле, шезлонге и качелях тем, что действительно нужно для поездки."
                ],
                de: [
                    "Wechseln Sie jede Nacht, welches Ende des Bettes der Kopf zu liegt, damit Ihr Baby sich von beiden Seiten zum Zimmer umdreht.",
                    "Bewegen Sie das Mobile oder die interessante Seite des Zimmers von Zeit zu Zeit.",
                    "Wechseln Sie den Arm, auf dem Sie das Baby tragen und füttern, auch beim Flaschenfttern.",
                    "Erhöhen Sie die Wachzeit ohne Druck auf dem Hinterkopf – Bauchzeit, Seitenlage-Spiel, aufrechtes Tragen.",
                    "Begrenzen Sie die Zeit in Autositzen, Bouncern und Schaukeln auf das, was Reisen tatsächlich erfordern."
                ],
                es: [
                    "Alterna cada noche a qué extremo de la cuna va la cabeza, para que el bebé se gire hacia la habitación por ambos lados.",
                    "Cambia de sitio el móvil o el lado interesante de la habitación de vez en cuando.",
                    "Cambia el brazo con el que lo llevas y le das de comer, también con biberón.",
                    "Aumenta el rato despierto sin apoyar la nuca: boca abajo, juego de lado, llevarlo en vertical.",
                    "Limita el tiempo en la silla del coche, hamacas y columpios a lo que realmente exija el desplazamiento."
                ],
                fr: [
                    "Alternez l'extrémité du lit vers laquelle la tête va chaque nuit, afin que votre bébé se tourne vers la pièce des deux côtés.",
                    "Déplacez le mobile ou le côté intéressant de la pièce de temps en temps.",
                    "Changez le bras que vous portez et nourrissez-le, même si vous allaitez au biberon.",
                    "Augmentez le temps d'éveil à l'arrière de la tête : temps sur le ventre, jeu couché sur le côté, portage vertical.",
                    "Limitez le temps passé dans les sièges d'auto, les transats et les balançoires aux besoins réels du voyage.",
                ],
                pt: [
                    "Alterne para qual lado do berço a cabeça vai todas as noites, para que o bebê se vire em direção ao quarto de ambos os lados.",
                    "Mova o móbile ou o lado interessante da sala de vez em quando.",
                    "Troque o braço que você carrega e alimenta, mesmo que seja com mamadeira.",
                    "Aumente o tempo de vigília na parte de trás da cabeça - tempo de bruços, brincadeiras deitadas de lado, carregamento na posição vertical.",
                    "Limite o tempo em assentos de carro, seguranças e balanços ao que a viagem realmente exige.",
                ],
                zh: [
                    "每晚交替将头转向婴儿床的哪一端，以便宝宝从两侧转向房间。",
                    "时不时地移动一下手机或房间有趣的一面。",
                    "切换您携带的手臂并继续喂食，即使是奶瓶喂养。",
                    "增加后脑勺的清醒时间——趴着的时间、侧躺玩耍的时间、直立携带的时间。",
                    "将汽车座椅、摇椅和秋千上的时间限制在旅行实际需要的范围内。",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "An infant skull is soft and reshapes under sustained pressure, so a baby who always rests on the same spot develops a flat area there. The fix is variety rather than any device, and the earlier it starts the more effectively the skull rounds out on its own. Persistent one-sided turning sometimes means a tight neck muscle, which responds well to early physiotherapy and less well to waiting.",
                ru: "Череп младенца мягкий и меняет форму под постоянным давлением, поэтому у ребёнка, который всегда лежит на одном и том же месте, там образуется уплощение. Решение — разнообразие положений, а не какое-либо приспособление, и чем раньше начать, тем эффективнее череп округляется сам. Стойкий поворот головы в одну сторону иногда означает укорочение мышцы шеи, которое хорошо поддаётся ранней физиотерапии и плохо — выжиданию.",
                de: "Der Säuglingssschädel ist weich und verformt sich unter anhältendem Druck, daher entwickelt ein Baby, das immer an der gleichen Stelle ruht, dort eine flache Stelle. Die Lösung ist Vielfalt statt eines Geräts, und je früher es beginnt, desto wirksamer nimmt der Schädel von selbst Form an. Persistentes einseitiges Drehen bedeutet manchmal einen verspannten Nackenmuskel, der gut auf frühe Physiotherapie anspricht und weniger auf Abwarten.",
                es: "El cráneo del lactante es blando y se remodela bajo una presión mantenida, así que un bebé que siempre apoya el mismo punto desarrolla ahí una zona plana. La solución es la variedad, no ningún dispositivo, y cuanto antes se empiece más eficazmente se redondea el cráneo por sí solo. Girar siempre hacia el mismo lado a veces indica un músculo del cuello acortado, que responde bien a la fisioterapia temprana y mal a la espera.",
                fr: "Le crâne d'un nourrisson est mou et se remodèle sous une pression soutenue, de sorte qu'un bébé qui repose toujours au même endroit y développe une zone plate. La solution réside dans la variété plutôt que dans n'importe quel appareil, et plus elle démarre tôt, plus le crâne s'arrondit tout seul. Une rotation unilatérale persistante signifie parfois une tension musculaire du cou, qui répond bien à une physiothérapie précoce et moins bien à l'attente.",
                pt: "O crânio de um bebê é macio e se remodela sob pressão sustentada, de modo que um bebê que sempre descansa no mesmo lugar desenvolve ali uma área plana. A solução é a variedade, e não qualquer dispositivo, e quanto mais cedo ela for iniciada, mais eficazmente o crânio se completará por conta própria. Virar unilateralmente persistentemente às vezes significa um músculo tenso no pescoço, que responde bem à fisioterapia precoce e menos bem à espera.",
                zh: "婴儿的头骨很软，在持续的压力下会重塑，所以总是躺在同一个地方的婴儿会在那里形成一个平坦的区域。修复方法是多种多样的，而不是任何设备，而且开始得越早，头骨就能更有效地自行变圆。持续的一侧转动有时意味着颈部肌肉紧张，这对早期物理治疗反应良好，但对等待反应较差。"
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Head-shaping pillows or positioners in the cot — unsafe for sleep and not effective.",
                    "Long daily stretches in a car seat or bouncer.",
                    "Always feeding and carrying on the same side.",
                    "Changing sleep position to the front to relieve pressure."
                ],
                ru: [
                    "Ортопедические подушки и позиционеры в кроватке — небезопасны для сна и неэффективны.",
                    "Долгое ежедневное пребывание в автокресле или шезлонге.",
                    "Всегда кормить и носить на одной и той же стороне.",
                    "Перекладывать ребёнка спать на живот, чтобы снять давление."
                ],
                de: [
                    "Kopfformende Kissen oder Positionierer im Bett – unsicher zum Schlafen und nicht wirksam.",
                    "Lange tägliche Zeiten im Autositz oder Bouncer.",
                    "Immer auf der gleichen Seite füttern und tragen.",
                    "Schlafposition zur Front ändern, um Druck zu entlasten."
                ],
                es: [
                    "Cojines o posicionadores moldeadores en la cuna: inseguros para dormir y poco eficaces.",
                    "Largos ratos diarios en la silla del coche o la hamaca.",
                    "Alimentar y llevar siempre del mismo lado.",
                    "Cambiar la postura de sueño a boca abajo para aliviar la presión."
                ],
                fr: [
                    "Oreillers ou positionneurs qui façonnent la tête dans le lit – dangereux pour le sommeil et inefficaces.",
                    "De longues étirements quotidiens dans un siège auto ou un transat.",
                    "Toujours nourrir et porter du même côté.",
                    "Changer la position de sommeil vers l'avant pour soulager la pression.",
                ],
                pt: [
                    "Almofadas modeladoras de cabeça ou posicionadores no berço – inseguros para dormir e ineficazes.",
                    "Longos alongamentos diários em uma cadeirinha ou segurança.",
                    "Sempre alimentando e carregando do mesmo lado.",
                    "Mudar a posição de dormir para a frente para aliviar a pressão.",
                ],
                zh: [
                    "婴儿床上的塑头枕头或定位器——对睡眠不安全且无效。",
                    "每天在汽车座椅或摇椅上进行长时间的伸展运动。",
                    "始终在同一侧喂食和携带。",
                    "将睡姿改为正面以缓解压力。",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "A visible flat area that is not improving with position changes by around four months.",
                    "Your baby cannot or will not turn the head one way.",
                    "The face or ears look asymmetric.",
                    "Any concern about head size or shape at a routine check."
                ],
                ru: [
                    "Заметное уплощение, которое к четырём месяцам не уменьшается при смене положений.",
                    "Ребёнок не может или не хочет поворачивать голову в одну сторону.",
                    "Лицо или уши выглядят несимметрично.",
                    "Любые сомнения по поводу размера или формы головы на плановом осмотре."
                ],
                de: [
                    "Eine sichtbare flache Stelle, die sich bis etwa vier Monate mit Positionswechseln nicht verbessert.",
                    "Ihr Baby kann oder will den Kopf in eine Richtung nicht drehen.",
                    "Das Gesicht oder die Ohren sehen asymmetrisch aus.",
                    "Bedenken bezüglich der Kopfgröße oder -form bei der Routineuntersuchung."
                ],
                es: [
                    "Una zona plana visible que no mejora con los cambios de posición hacia los cuatro meses.",
                    "El bebé no puede o no quiere girar la cabeza hacia un lado.",
                    "La cara o las orejas se ven asimétricas.",
                    "Cualquier duda sobre el tamaño o la forma de la cabeza en una revisión rutinaria."
                ],
                fr: [
                    "Une zone plane visible qui ne s'améliore pas avec des changements de position d'environ quatre mois.",
                    "Votre bébé ne peut pas ou ne veut pas tourner la tête dans un sens.",
                    "Le visage ou les oreilles semblent asymétriques.",
                    "Toute préoccupation concernant la taille ou la forme de la tête lors d'un contrôle de routine.",
                ],
                pt: [
                    "Uma área plana visível que não melhora com mudanças de posição há cerca de quatro meses.",
                    "Seu bebê não consegue ou não quer virar a cabeça para um lado.",
                    "O rosto ou as orelhas parecem assimétricos.",
                    "Qualquer preocupação sobre o tamanho ou formato da cabeça em uma verificação de rotina.",
                ],
                zh: [
                    "明显的平坦区域在大约四个月内没有随着位置变化而改善。",
                    "您的宝宝不能或不会向某一方向转动头部。",
                    "脸或耳朵看起来不对称。",
                    "例行检查时对头部尺寸或形状的任何担忧。",
                ]
            )
        ),

        CareTip(
            id: 1403, category: .development, icon: "bubble.left.and.bubble.right.fill", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Serve and return: answer every babble",
                ru: "Диалог с малышом: отвечайте на каждое агуканье",
                de: "Serve and Return: Antworten Sie auf jedes Brabbeln",
                es: "Ida y vuelta: responde a cada balbuceo",
                fr: "Servir et rendre : répondez à chaque bavardage",
                pt: "Servir e devolver: responda a cada tagarelice",
                zh: "发球和接球：回答每一个喋喋不休的问题"
            ),
            summary: LocalizedText(
                en: "Your reply to a sound is what builds language, long before words appear",
                ru: "Именно ваш ответ на звук строит речь — задолго до первых слов",
                de: "Ihre Antwort auf einen Laut ist es, der Sprache aufbaut, lange bevor Worte erscheinen",
                es: "Tu respuesta a un sonido es lo que construye el lenguaje, mucho antes de que aparezcan las palabras",
                fr: "Votre réponse à un son est ce qui construit le langage, bien avant que les mots n'apparaissent",
                pt: "Sua resposta a um som é o que constrói a linguagem, muito antes de as palavras aparecerem",
                zh: "早在单词出现之前，你对声音的回应就构成了语言"
            ),
            whatToDo: LocalizedList(
                en: [
                    "When your baby makes a sound, look at them, respond, and pause as if waiting for a reply.",
                    "Name what they are looking at rather than what you want them to look at.",
                    "Narrate ordinary routines out loud — nappy changes, cooking, getting dressed.",
                    "Use warm exaggerated intonation; the sing-song voice is genuinely easier for a baby to process.",
                    "Keep it two-way — leave gaps rather than filling every silence."
                ],
                ru: [
                    "Когда ребёнок издаёт звук, посмотрите на него, ответьте и сделайте паузу, будто ждёте ответа.",
                    "Называйте то, на что смотрит он, а не то, на что вы хотите обратить его внимание.",
                    "Проговаривайте вслух обычные дела — смену подгузника, готовку, одевание.",
                    "Говорите тепло и с подчёркнутой интонацией: напевная речь действительно легче для восприятия младенцем.",
                    "Сохраняйте диалог — оставляйте паузы, а не заполняйте каждую тишину."
                ],
                de: [
                    "Wenn Ihr Baby einen Laut macht, schauen Sie es an, antworten Sie und machen Sie eine Pause, als würden Sie auf eine Antwort warten.",
                    "Benennen Sie, worauf es schaut, nicht worauf Sie es schauen lassen möchten.",
                    "Erzählen Sie alltägliche Routinen laut – Windelwechsel, Kochen, Anziehen.",
                    "Nutzen Sie warme, übertriebene Intonation; die Singsan-Stimme ist wirklich einfacher für ein Baby zu verarbeiten.",
                    "Halten Sie es bidirektional – lassen Sie Lücken, statt jede Stille zu füllen."
                ],
                es: [
                    "Cuando el bebé emita un sonido, míralo, respóndele y haz una pausa como si esperaras contestación.",
                    "Nombra lo que él está mirando, no lo que tú quieres que mire.",
                    "Narra en voz alta las rutinas cotidianas: cambios de pañal, cocinar, vestirse.",
                    "Usa una entonación cálida y exagerada; esa voz cantarina es de verdad más fácil de procesar para un bebé.",
                    "Que sea de ida y vuelta: deja huecos en vez de llenar cada silencio."
                ],
                fr: [
                    "Lorsque votre bébé émet un son, regardez-le, répondez et faites une pause comme si vous attendiez une réponse.",
                    "Nommez ce qu’ils regardent plutôt que ce que vous voulez qu’ils regardent.",
                    "Racontez à voix haute les routines ordinaires – changer les couches, cuisiner, s’habiller.",
                    "Utilisez une intonation chaleureuse et exagérée ; la voix chantée est véritablement plus facile à traiter pour un bébé.",
                    "Gardez-le dans les deux sens : laissez des espaces plutôt que de combler chaque silence.",
                ],
                pt: [
                    "Quando seu bebê emitir um som, olhe para ele, responda e faça uma pausa como se estivesse esperando uma resposta.",
                    "Nomeie o que eles estão olhando, em vez do que você deseja que vejam.",
                    "Narre rotinas comuns em voz alta – trocar fraldas, cozinhar, vestir-se.",
                    "Use entonação quente e exagerada; a voz cantada é genuinamente mais fácil para um bebê processar.",
                    "Mantenha a situação nos dois sentidos – deixe lacunas em vez de preencher todos os silêncios.",
                ],
                zh: [
                    "当宝宝发出声音时，看着他们，做出回应，然后暂停，就像在等待答复一样。",
                    "说出他们正在看什么，而不是你想让他们看什么。",
                    "大声讲述日常事务——换尿布、做饭、穿衣服。",
                    "使用温暖夸张的语调；唱歌的声音确实更容易让婴儿接受。",
                    "保持双向——留下空白而不是填补每一个沉默。",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Language develops through back-and-forth exchanges, not through volume of speech directed at a child. Each time your baby vocalises and you respond, they learn that sounds cause responses — the foundation of conversation. Research consistently finds that the number of these turn-taking exchanges predicts later language ability better than the total number of words a child hears.",
                ru: "Речь развивается через обмен репликами, а не через объём слов, обращённых к ребёнку. Каждый раз, когда ребёнок издаёт звук, а вы отвечаете, он усваивает, что звуки вызывают отклик, — это основа диалога. Исследования стабильно показывают, что число таких обменов предсказывает будущий уровень речи лучше, чем общее количество услышанных слов.",
                de: "Sprache entwickelt sich durch gegenseitige Austausche, nicht durch die Lautstärke der an ein Kind gerichteten Rede. Jedes Mal, wenn Ihr Baby vokalisiert und Sie antworten, lernt es, dass Laute Reaktionen hervorrufen – die Grundlage von Gesprächen. Forschung zeigt konsistent, dass die Anzahl dieser Rollentausch-Austausche die spätere Sprachfähigkeit besser vorhersagt als die Gesamtzahl der Wörter, die ein Kind hört.",
                es: "El lenguaje se desarrolla mediante intercambios de ida y vuelta, no por el volumen de habla dirigido al niño. Cada vez que el bebé vocaliza y tú respondes, aprende que los sonidos provocan respuestas: la base de la conversación. La investigación encuentra de forma consistente que el número de estos turnos predice la capacidad lingüística futura mejor que el total de palabras que el niño escucha.",
                fr: "Le langage se développe grâce à des échanges de va-et-vient, et non à travers le volume de la parole adressée à un enfant. Chaque fois que votre bébé vocalise et que vous répondez, il apprend que les sons provoquent des réponses – le fondement de la conversation. Les recherches révèlent systématiquement que le nombre de ces échanges à tour de rôle prédit mieux les capacités linguistiques ultérieures que le nombre total de mots qu'un enfant entend.",
                pt: "A linguagem se desenvolve por meio de trocas de vaivém, e não por meio do volume da fala dirigida a uma criança. Cada vez que o seu bebé vocaliza e você responde, ele aprende que os sons causam respostas – a base da conversa. A investigação constata consistentemente que o número destas trocas de turnos prevê melhor a capacidade linguística posterior do que o número total de palavras que uma criança ouve.",
                zh: "语言是通过来回交流而不是通过对孩子大声说话来发展的。每次你的宝宝发出声音并且你做出回应时，他们就会知道声音会引起反应——这是对话的基础。研究一致发现，这些轮流交流的次数比孩子听到的单词总数更能预测以后的语言能力。"
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Background television or radio treated as language exposure — it does not respond.",
                    "Filling every gap so there is no space for the baby to take a turn.",
                    "Waiting for real words before starting conversations.",
                    "Correcting babble instead of answering it."
                ],
                ru: [
                    "Считать фоновый телевизор или радио речевой средой — они не отвечают.",
                    "Заполнять каждую паузу, не оставляя ребёнку места для своей реплики.",
                    "Ждать настоящих слов, прежде чем начинать разговоры.",
                    "Исправлять лепет вместо того, чтобы отвечать на него."
                ],
                de: [
                    "Hintergrund-Fernseh- oder Radioberieselung als Sprachexposition zu betrachten – es antwortet nicht.",
                    "Jede Lücke zu füllen, sodass das Baby keine Gelegenheit hat, einen Zug zu machen.",
                    "Auf echte Worte warten, bevor man Gespräche beginnt.",
                    "Brabbellaute korrigieren, statt sie zu beantworten."
                ],
                es: [
                    "Tomar la televisión o la radio de fondo como exposición al lenguaje: no responden.",
                    "Llenar cada hueco, de modo que el bebé no tiene espacio para su turno.",
                    "Esperar a que haya palabras reales para empezar a conversar.",
                    "Corregir el balbuceo en lugar de responderlo."
                ],
                fr: [
                    "La télévision ou la radio en arrière-plan est traitée comme une exposition linguistique – elle ne répond pas.",
                    "Combler chaque espace afin qu'il n'y ait pas d'espace pour que le bébé puisse prendre son tour.",
                    "Attendre de vrais mots avant d’entamer des conversations.",
                    "Corriger le babillage au lieu d'y répondre.",
                ],
                pt: [
                    "Televisão ou rádio de fundo tratada como exposição linguística – não responde.",
                    "Preenchendo todas as lacunas para que não haja espaço para o bebê dar uma volta.",
                    "Esperando por palavras reais antes de iniciar conversas.",
                    "Corrigindo balbucios em vez de respondê-los.",
                ],
                zh: [
                    "背景电视或广播被视为语言暴露——它没有反应。",
                    "填满每一个空隙，这样宝宝就没有转动的空间。",
                    "在开始对话之前等待真实的话语。",
                    "纠正胡言乱语而不是回答它。",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "No cooing or vocal sounds by around four months.",
                    "No babbling with consonants by nine months.",
                    "No response to their name or to loud sounds.",
                    "A loss of sounds, gestures or eye contact that were previously there — mention this promptly."
                ],
                ru: [
                    "К четырём месяцам нет гуления и голосовых звуков.",
                    "К девяти месяцам нет лепета с согласными звуками.",
                    "Ребёнок не реагирует на своё имя или на громкие звуки.",
                    "Исчезли звуки, жесты или зрительный контакт, которые уже были, — сообщите об этом врачу без промедления."
                ],
                de: [
                    "Kein Gurren oder Vokallaute bis etwa vier Monate.",
                    "Kein Brabbeln mit Konsonanten bis neun Monate.",
                    "Keine Reaktion auf ihren Namen oder auf laute Geräusche.",
                    "Verlust von Lauten, Gesten oder Augenkontakt, die vorher da waren – erwähnen Sie dies sofort."
                ],
                es: [
                    "No emite arrullos ni sonidos vocales hacia los cuatro meses.",
                    "No balbucea con consonantes a los nueve meses.",
                    "No responde a su nombre ni a sonidos fuertes.",
                    "Pérdida de sonidos, gestos o contacto visual que antes tenía: coméntalo cuanto antes."
                ],
                fr: [
                    "Aucun roucoulement ni bruit vocal vers quatre mois.",
                    "Pas de babillage avec des consonnes à neuf mois.",
                    "Aucune réponse à leur nom ou aux sons forts.",
                    "Une perte de sons, de gestes ou de contact visuel qui existaient auparavant – mentionnez-le rapidement.",
                ],
                pt: [
                    "Nenhum arrulho ou sons vocais por volta dos quatro meses.",
                    "Nada de balbuciar consoantes aos nove meses.",
                    "Nenhuma resposta ao seu nome ou a sons altos.",
                    "Perda de sons, gestos ou contato visual que existiam anteriormente – mencione isso imediatamente.",
                ],
                zh: [
                    "大约四个月的时候就不会发出咕咕声或声音了。",
                    "九个月大时还不会咿呀学语。",
                    "对他们的名字或响亮的声音没有反应。",
                    "之前的声音、手势或目光接触消失——立即提及。",
                ]
            )
        ),

        CareTip(
            id: 1404, category: .development, icon: "heart.fill", ageFrom: 0, ageTo: 3,
            title: LocalizedText(
                en: "Skin-to-skin — and why fathers should do it too",
                ru: "Контакт кожа к коже — и почему он нужен и отцам",
                de: "Haut-zu-Haut – und warum auch Väter das tun sollten",
                es: "Piel con piel: y por qué los padres también deben hacerlo",
                fr: "Peau à peau – et pourquoi les pères devraient le faire aussi",
                pt: "Pele a pele – e por que os pais também deveriam fazer isso",
                zh: "皮肤接触——以及为什么父亲也应该这样做"
            ),
            summary: LocalizedText(
                en: "Bare chest, bare back covered, and twenty unhurried minutes",
                ru: "Голая грудь, укрытая спинка малыша и двадцать неспешных минут",
                de: "Nackte Brust, bedeckter Rücken und zwanzig ungehörte Minuten",
                es: "Pecho desnudo, espalda cubierta y veinte minutos sin prisa",
                fr: "Poitrine nue, dos nu couvert, et vingt minutes sans hâte",
                pt: "Peito nu, costas nuas cobertas e vinte minutos sem pressa",
                zh: "光着胸，光着背，不紧不慢的二十分钟"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Undress your baby to the nappy and place them chest-down on your bare chest.",
                    "Cover their back with a light blanket, leaving the face clear and visible at all times.",
                    "Stay upright and awake — if you feel sleepy, move your baby to the cot first.",
                    "Aim for at least twenty minutes so both of you can settle into it.",
                    "Share it: fathers, partners and adoptive parents get the same benefits."
                ],
                ru: [
                    "Разденьте ребёнка до подгузника и положите его животом на вашу обнажённую грудь.",
                    "Укройте спинку лёгким одеялом, лицо всегда должно оставаться открытым и видимым.",
                    "Оставайтесь в полусидячем положении и не засыпайте — если клонит в сон, сначала переложите ребёнка в кроватку.",
                    "Стремитесь хотя бы к двадцати минутам, чтобы вы оба успели расслабиться.",
                    "Делите это между собой: отцы, партнёры и приёмные родители получают такую же пользу."
                ],
                de: [
                    "Ziehen Sie Ihr Baby bis zur Windel aus und legen Sie es mit der Brust nach unten auf Ihre nackte Brust.",
                    "Bedecken Sie seinen Rücken mit einer leichten Decke, wobei das Gesicht jederzeit klar und sichtbar bleiben muss.",
                    "Bleiben Sie aufrecht und wach – wenn Sie sich schläfrig fühlen, legen Sie Ihr Baby zuerst ins Bett.",
                    "Streben Sie mindestens zwanzig Minuten an, damit ihr euch beide beruhigen könnt.",
                    "Teilen Sie es: Väter, Partner und Adoptiveltern bekommen die gleichen Vorteile."
                ],
                es: [
                    "Desviste al bebé hasta el pañal y colócalo boca abajo sobre tu pecho desnudo.",
                    "Cúbrele la espalda con una manta ligera, dejando la cara despejada y visible en todo momento.",
                    "Quédate incorporado y despierto: si te entra sueño, pasa antes al bebé a la cuna.",
                    "Busca al menos veinte minutos para que ambos podáis relajaros.",
                    "Compartidlo: padres, parejas y familias adoptivas obtienen los mismos beneficios."
                ],
                fr: [
                    "Déshabillez votre bébé jusqu'à la couche et placez-le poitrine vers le bas sur votre poitrine nue.",
                    "Couvrez leur dos avec une couverture légère, laissant le visage clair et visible à tout moment.",
                    "Restez debout et éveillé. Si vous avez sommeil, déplacez d'abord votre bébé vers le lit.",
                    "Visez au moins vingt minutes pour que vous puissiez tous les deux vous y installer.",
                    "Partagez-le : les pères, les partenaires et les parents adoptifs bénéficient des mêmes avantages.",
                ],
                pt: [
                    "Tire a roupa do seu bebê até ficar com a fralda e coloque-o com o peito para baixo sobre o peito nu.",
                    "Cubra as costas com um cobertor leve, deixando o rosto sempre limpo e visível.",
                    "Fique em pé e acordado - se sentir sono, leve primeiro o bebê para o berço.",
                    "Mire por pelo menos vinte minutos para que vocês dois possam se acomodar.",
                    "Compartilhe: pais, companheiros e pais adotivos recebem os mesmos benefícios.",
                ],
                zh: [
                    "脱掉宝宝的衣服，穿上尿布，然后将他们胸部朝下放在您裸露的胸前。",
                    "用薄毯盖住他们的背部，使脸部始终清晰可见。",
                    "保持直立和清醒——如果您感到困，请先将宝宝移到婴儿床上。",
                    "目标是至少二十分钟，这样你们俩都能适应。",
                    "分享：父亲、伴侣和养父母获得同样的福利。",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Direct skin contact stabilises a baby's heart rate, breathing and temperature, and it lowers stress hormones in both the baby and the adult holding them. For the parent it triggers oxytocin release, which supports bonding and, for the feeding parent, milk supply. It is one of the few things that is simultaneously good for the baby, good for the adult, and free.",
                ru: "Прямой контакт кожи стабилизирует у ребёнка частоту сердцебиения, дыхание и температуру и снижает гормоны стресса и у него, и у взрослого, который его держит. У родителя он запускает выброс окситоцина, который поддерживает привязанность, а у кормящего родителя — и выработку молока. Это одна из немногих вещей, которые одновременно полезны ребёнку, полезны взрослому и ничего не стоят.",
                de: "Direkter Hautkontakt stabilisiert die Herzfrequenz, Atmung und Temperatur eines Babys und senkt Stresshormone sowohl beim Baby als auch beim haltenden Erwachsenen. Bei dem Elternteil löst es die Oxytocin-Ausschüttung aus, die die Bindung unterstützt und beim stillenden Elternteil die Milchproduktion. Es ist eines der wenigen Dinge, das gleichzeitig gut für das Baby, gut für den Erwachsenen und kostenlos ist.",
                es: "El contacto directo de piel estabiliza la frecuencia cardiaca, la respiración y la temperatura del bebé, y baja las hormonas del estrés tanto en el bebé como en el adulto que lo sostiene. En el progenitor libera oxitocina, lo que favorece el vínculo y, en quien amamanta, la producción de leche. Es una de las pocas cosas que a la vez es buena para el bebé, buena para el adulto y gratis.",
                fr: "Le contact direct avec la peau stabilise la fréquence cardiaque, la respiration et la température du bébé, et réduit les hormones de stress chez le bébé et l'adulte qui le tient. Pour le parent, cela déclenche la libération d'ocytocine, qui favorise la liaison et, pour le parent qui se nourrit, la production de lait. C’est l’une des rares choses qui soit à la fois bonne pour le bébé, bonne pour l’adulte et gratuite.",
                pt: "O contato direto com a pele estabiliza a frequência cardíaca, a respiração e a temperatura do bebê, e reduz os hormônios do estresse tanto no bebê quanto no adulto que os segura. Para os pais, desencadeia a liberação de oxitocina, que apoia o vínculo e, para os pais que amamentam, o fornecimento de leite. É uma das poucas coisas que é simultaneamente boa para o bebê, boa para o adulto e gratuita.",
                zh: "直接的皮肤接触可以稳定婴儿的心率、呼吸和体温，并降低婴儿和抱着婴儿的成人的压力荷尔蒙。对于父母来说，它会触发催产素的释放，从而支持亲密关系，对于喂养的父母来说，它可以促进乳汁供应。它是为数不多的同时对婴儿、对成人都有好处且免费的东西之一。"
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Treating it as something only the birth mother can do.",
                    "Stopping after the first week — it stays valuable for months.",
                    "Falling asleep with the baby on your chest on a sofa or armchair.",
                    "Rushing it into five-minute slots between other tasks."
                ],
                ru: [
                    "Считать, что это доступно только родившей матери.",
                    "Прекращать после первой недели — польза сохраняется месяцами.",
                    "Засыпать с ребёнком на груди на диване или в кресле.",
                    "Втискивать это в пятиминутные промежутки между делами."
                ],
                de: [
                    "Es als etwas zu behandeln, das nur die Geburtsmutter tun kann.",
                    "Nach der ersten Woche zu stoppen – es bleibt monatelang wertvoll.",
                    "Mit dem Baby auf der Brust auf einem Sofa oder Sessel einschlafen.",
                    "Es in fünf-Minuten-Blöcke zwischen anderen Aufgaben quetschen."
                ],
                es: [
                    "Tratarlo como algo que solo puede hacer la madre que ha dado a luz.",
                    "Dejarlo tras la primera semana: sigue siendo valioso durante meses.",
                    "Dormirse con el bebé sobre el pecho en un sofá o un sillón.",
                    "Encajarlo a la carrera en ratos de cinco minutos entre otras tareas."
                ],
                fr: [
                    "Le traiter comme quelque chose que seule la mère biologique peut faire.",
                    "S'arrêter après la première semaine – il reste précieux pendant des mois.",
                    "S'endormir avec le bébé sur la poitrine sur un canapé ou un fauteuil.",
                    "En le précipitant dans des créneaux de cinq minutes entre d'autres tâches.",
                ],
                pt: [
                    "Tratar isso como algo que só a mãe biológica pode fazer.",
                    "Parando após a primeira semana – permanece valioso por meses.",
                    "Adormecer com o bebê no peito, em um sofá ou poltrona.",
                    "Apressando-o em intervalos de cinco minutos entre outras tarefas.",
                ],
                zh: [
                    "将其视为只有亲生母亲才能做的事情。",
                    "第一周后就停止——它在几个月内仍然有价值。",
                    "将宝宝放在沙发或扶手椅上，放在胸前入睡。",
                    "把它赶到其他任务之间的五分钟间隙。",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby becomes cold, mottled or floppy during skin-to-skin.",
                    "Noisy or laboured breathing while lying on your chest.",
                    "You feel no connection at all after weeks of trying — this is worth saying to a professional, and it is common."
                ],
                ru: [
                    "Во время контакта кожа к коже ребёнок замерзает, кожа становится мраморной или он вялый.",
                    "Шумное или затруднённое дыхание, пока ребёнок лежит у вас на груди.",
                    "Вы неделями не чувствуете никакой связи — об этом стоит сказать специалисту, и это встречается часто."
                ],
                de: [
                    "Ihr Baby wird während des Haut-zu-Haut-Kontakts kalt, fleckig oder schlaff.",
                    "Lautes oder schwieriges Atmen, während es auf Ihrer Brust liegt.",
                    "Sie fühlen nach Wochen des Versuchens gar keine Verbindung – es lohnt sich, dies einem Fachmann zu sagen, und es ist häufig."
                ],
                es: [
                    "El bebé se queda frío, moteado o flácido durante el piel con piel.",
                    "Respiración ruidosa o costosa mientras está sobre tu pecho.",
                    "No sientes ninguna conexión tras semanas intentándolo: merece la pena contárselo a un profesional, y es frecuente."
                ],
                fr: [
                    "Votre bébé devient froid, marbré ou mou lors d'un contact peau à peau.",
                    "Respiration bruyante ou difficile en position couchée sur la poitrine.",
                    "Vous ne ressentez aucune connexion après des semaines d’essais – cela vaut la peine d’en parler à un professionnel, et c’est courant.",
                ],
                pt: [
                    "Seu bebê fica com frio, manchado ou mole durante o contato pele a pele.",
                    "Respiração ruidosa ou difícil enquanto está deitado de bruços.",
                    "Você não sente nenhuma conexão depois de semanas de tentativas – vale a pena dizer isso a um profissional, e é comum.",
                ],
                zh: [
                    "肌肤接触时，宝宝会变得寒冷、出现斑点或软弱。",
                    "趴在胸前时呼吸嘈杂或困难。",
                    "经过几周的尝试后，你根本感觉不到任何联系——这值得对专业人士说，而且很常见。",
                ]
            )
        ),

        CareTip(
            id: 1405, category: .development, icon: "book.fill", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Read aloud daily, starting now",
                ru: "Читайте вслух каждый день, начиная прямо сейчас",
                de: "Lesen Sie täglich laut vor, ab sofort",
                es: "Lee en voz alta a diario, empezando ya",
                fr: "Lisez à haute voix quotidiennement, à partir de maintenant",
                pt: "Leia em voz alta diariamente, começando agora",
                zh: "每天大声朗读，从现在开始"
            ),
            summary: LocalizedText(
                en: "The voice matters more than the story, and no age is too early",
                ru: "Голос важнее сюжета, и слишком раннего возраста здесь не бывает",
                de: "Die Stimme ist wichtiger als die Geschichte, und es gibt kein zu frühes Alter",
                es: "La voz importa más que la historia, y ninguna edad es demasiado temprana",
                fr: "La voix compte plus que l'histoire, et aucun âge n'est trop tôt",
                pt: "A voz é mais importante do que a história, e nenhuma idade é cedo demais",
                zh: "声音比故事更重要，年龄不嫌早"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Read for a few minutes a day from the newborn stage — any book, including your own.",
                    "Choose high-contrast and simple images for the first months, then cloth and board books to grab and chew.",
                    "Let your baby set the pace: skip pages, repeat favourites, stop when interest goes.",
                    "Point at pictures and name them rather than reading the text word for word.",
                    "Fit it into a routine you already have, such as before the last feed."
                ],
                ru: [
                    "Читайте по несколько минут в день уже с периода новорождённости — любую книгу, в том числе свою собственную.",
                    "В первые месяцы выбирайте контрастные и простые изображения, затем — тканевые и картонные книжки, которые можно хватать и грызть.",
                    "Пусть ребёнок задаёт темп: пропускайте страницы, повторяйте любимые, останавливайтесь, когда интерес пропал.",
                    "Показывайте на картинки и называйте их, а не читайте текст слово в слово.",
                    "Встройте чтение в уже существующий ритуал — например, перед последним кормлением."
                ],
                de: [
                    "Lesen Sie von der Neugeborenenphase an täglich einige Minuten lang – jedes Buch, auch Ihr eigenes.",
                    "Wählen Sie in den ersten Monaten hochkontrastive und einfache Bilder, dann Stoff- und Pappbücher zum Greifen und Kauen.",
                    "Lassen Sie Ihr Baby das Tempo bestimmen: Überspringen Sie Seiten, wiederholen Sie Favoriten, stoppen Sie, wenn das Interesse nachlässt.",
                    "Zeigen Sie auf Bilder und benennen Sie sie, anstatt den Text Wort für Wort zu lesen.",
                    "Integrieren Sie es in eine Routine, die Sie bereits haben, z. B. vor der letzten Fütterung."
                ],
                es: [
                    "Lee unos minutos al día desde la etapa de recién nacido: cualquier libro, incluido el tuyo.",
                    "Elige imágenes sencillas y de alto contraste los primeros meses, y luego libros de tela y de cartón para agarrar y morder.",
                    "Deja que el bebé marque el ritmo: sáltate páginas, repite los favoritos, para cuando pierda el interés.",
                    "Señala los dibujos y nómbralos en lugar de leer el texto palabra por palabra.",
                    "Encájalo en una rutina que ya tengas, como antes de la última toma."
                ],
                fr: [
                    "Lisez quelques minutes par jour dès le stade du nouveau-né – n’importe quel livre, y compris le vôtre.",
                    "Choisissez des images simples et contrastées pour les premiers mois, puis des livres en tissu et en carton à saisir et à mâcher.",
                    "Laissez votre bébé donner le ton : sauter des pages, répéter les favoris, arrêter lorsque l'intérêt diminue.",
                    "Montrez des images et nommez-les plutôt que de lire le texte mot pour mot.",
                    "Intégrez-le à une routine que vous avez déjà, comme avant la dernière tétée.",
                ],
                pt: [
                    "Leia alguns minutos por dia desde o estágio de recém-nascido - qualquer livro, inclusive o seu.",
                    "Escolha imagens simples e de alto contraste para os primeiros meses, depois livros de tecido e papelão para pegar e mastigar.",
                    "Deixe o seu bebé ditar o ritmo: salte páginas, repita os favoritos, pare quando o interesse acabar.",
                    "Aponte para as imagens e nomeie-as em vez de ler o texto palavra por palavra.",
                    "Encaixe-o em uma rotina que você já possui, como antes da última mamada.",
                ],
                zh: [
                    "从新生儿阶段开始，每天阅读几分钟——任何书，包括你自己的书。",
                    "最初几个月选择高对比度和简单的图像，然后选择布书和纸板书来抓握和咀嚼。",
                    "让您的宝宝设定节奏：跳过页面、重复最喜欢的内容、当兴趣消失时停止。",
                    "指着图片并说出它们的名称，而不是逐字阅读文本。",
                    "将其融入您已有的日常习惯中，例如在最后一次喂食之前。",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Books put unusual words into a warm familiar voice, and the combination of rhythm, repetition and closeness is what makes them stick. Long before a baby understands a story, they learn that pages turn, that pictures mean something, and that this is a shared and pleasant activity. Building the habit in the first year is far easier than introducing it to a mobile toddler.",
                ru: "Книги приносят непривычные слова тёплым знакомым голосом, а сочетание ритма, повторения и близости — то, что закрепляет их. Задолго до того, как ребёнок поймёт сюжет, он усваивает, что страницы переворачиваются, что картинки что-то означают и что это общее приятное занятие. Сформировать привычку на первом году намного проще, чем приучить к ней подвижного малыша постарше.",
                de: "Bücher bringen ungewöhnliche Wörter in eine warme, vertraute Stimme, und die Kombination aus Rhythmus, Wiederholung und Nähe ist das, was sie zum Haften bringt. Lange bevor ein Baby eine Geschichte versteht, lernt es, dass Seiten umgeblättert werden, dass Bilder etwas bedeuten und dass dies eine gemeinsame und angenehme Aktivität ist. Die Gewohnheit im ersten Jahr zu entwickeln ist viel einfacher, als sie einem mobilen Kleinkind später beizubringen.",
                es: "Los libros traen palabras poco habituales con una voz cálida y conocida, y la combinación de ritmo, repetición y cercanía es lo que hace que se fijen. Mucho antes de entender una historia, el bebé aprende que las páginas se pasan, que los dibujos significan algo y que esta es una actividad compartida y agradable. Crear el hábito en el primer año es mucho más fácil que introducirlo cuando ya camina.",
                fr: "Les livres mettent des mots inhabituels dans une voix chaleureuse et familière, et la combinaison du rythme, de la répétition et de la proximité est ce qui les rend fidèles. Bien avant qu'un bébé ne comprenne une histoire, il apprend que les pages se tournent, que les images signifient quelque chose et qu'il s'agit d'une activité partagée et agréable. Construire cette habitude dès la première année est bien plus facile que de la présenter à un tout-petit mobile.",
                pt: "Os livros colocam palavras incomuns em uma voz calorosa e familiar, e a combinação de ritmo, repetição e proximidade é o que os mantém. Muito antes de um bebê entender uma história, ele aprende que as páginas viram, que as imagens significam alguma coisa e que esta é uma atividade compartilhada e agradável. Construir o hábito no primeiro ano é muito mais fácil do que apresentá-lo a uma criança móvel.",
                zh: "书籍将不寻常的词语融入温暖熟悉的声音中，节奏、重复和亲密的结合使得它们被牢牢记住。早在婴儿理解故事之前，他们就知道书页会翻动，图片会有意义，而且这是一项共享且令人愉快的活动。在第一年养成这个习惯比把它介绍给一个会走路的孩子要容易得多。"
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Waiting until the child can sit still and listen.",
                    "Insisting on finishing the book.",
                    "Swapping books for an app or a screen at this age.",
                    "Choosing only long text-heavy stories."
                ],
                ru: [
                    "Ждать, пока ребёнок сможет спокойно сидеть и слушать.",
                    "Настаивать на том, чтобы дочитать книгу до конца.",
                    "Заменять книги приложением или экраном в этом возрасте.",
                    "Выбирать только длинные истории с большим количеством текста."
                ],
                de: [
                    "Warten, bis das Kind ruhig sitzen und zuhören kann.",
                    "Darauf bestehen, das Buch zu beenden.",
                    "Bücher in diesem Alter durch eine App oder einen Bildschirm ersetzen.",
                    "Nur lange textlastige Geschichten wählen."
                ],
                es: [
                    "Esperar a que el niño pueda quedarse quieto y escuchar.",
                    "Insistir en terminar el libro.",
                    "Cambiar los libros por una app o una pantalla a esta edad.",
                    "Elegir solo historias largas y con mucho texto."
                ],
                fr: [
                    "Attendre que l'enfant puisse rester assis et écouter.",
                    "Insister pour terminer le livre.",
                    "Échanger des livres contre une application ou un écran à cet âge.",
                    "Choisir uniquement de longues histoires riches en texte.",
                ],
                pt: [
                    "Esperar até que a criança consiga ficar parada e ouvir.",
                    "Insistindo em terminar o livro.",
                    "Trocar livros por um aplicativo ou tela nessa idade.",
                    "Escolher apenas histórias longas e com muito texto.",
                ],
                zh: [
                    "等到孩子能安静地坐着听。",
                    "坚持把书看完。",
                    "在这个年龄段，将书籍换成应用程序或屏幕。",
                    "只选择长文本故事。",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "No visual tracking of pictures or faces by three months.",
                    "No interest in looking at books or faces at all by around a year.",
                    "Any concern about hearing or vision — get it checked rather than watched."
                ],
                ru: [
                    "К трём месяцам ребёнок не следит взглядом за картинками или лицами.",
                    "К году совсем нет интереса рассматривать книги или лица.",
                    "Любые сомнения по поводу слуха или зрения — лучше проверить, чем наблюдать."
                ],
                de: [
                    "Keine visuelle Verfolgung von Bildern oder Gesichtern bis etwa drei Monate.",
                    "Absolut kein Interesse an Büchern oder Gesichtern bis etwa ein Jahr.",
                    "Bedenken bezüglich Gehör oder Sehkraft – lassen Sie diese überprüfen, anstatt zu beobachten."
                ],
                es: [
                    "No sigue con la mirada dibujos ni caras a los tres meses.",
                    "Ningún interés en mirar libros o caras hacia el año de edad.",
                    "Cualquier duda sobre la audición o la visión: mejor comprobarla que esperar."
                ],
                fr: [
                    "Aucun suivi visuel des images ou des visages d’ici trois mois.",
                    "Aucun intérêt à regarder des livres ou des visages d’ici environ un an.",
                    "Tout problème concernant l'audition ou la vision : faites-le vérifier plutôt que de le surveiller.",
                ],
                pt: [
                    "Nenhum rastreamento visual de fotos ou rostos por três meses.",
                    "Não há interesse em olhar livros ou rostos por volta de um ano.",
                    "Qualquer preocupação com audição ou visão – verifique em vez de observar.",
                ],
                zh: [
                    "三个月内无法对照片或面部进行视觉跟踪。",
                    "大约一年后，就完全没有兴趣看书或看脸了。",
                    "如果对听力或视力有任何疑问，请检查而不是观看。",
                ]
            )
        )
    ]
}
