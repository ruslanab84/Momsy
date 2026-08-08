import Foundation

extension CareTipsCatalog {
    static let comfort: [CareTip] = [

        CareTip(
            id: 1301, category: .comfort, icon: "waveform", ageFrom: 0, ageTo: 4,
            title: LocalizedText(
                en: "Soothing a colicky evening",
                ru: "Как успокоить малыша в колики вечером",
                de: "Ein kolikartig veranlagtes Abend beruhigen",
                es: "Calmar una tarde de cólicos",
                fr: "Apaiser une soirée de coliques",
                pt: "Acalmando uma noite com cólicas"
            ),
            summary: LocalizedText(
                en: "Layer several calming inputs at once and give each combination a few minutes",
                ru: "Сочетайте сразу несколько успокаивающих приёмов и давайте каждой комбинации несколько минут",
                de: "Kombinieren Sie mehrere Beruhigungsmethoden gleichzeitig und geben Sie jeder Kombination ein paar Minuten Zeit",
                es: "Combina varios estímulos calmantes a la vez y dale unos minutos a cada combinación",
                fr: "Superposez plusieurs entrées apaisantes à la fois et accordez quelques minutes à chaque combinaison.",
                pt: "Coloque várias entradas calmantes de uma só vez e dê a cada combinação alguns minutos"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Try the calming set together: a snug wrap, holding on the side or over your forearm, a steady shushing sound, gentle rhythmic movement, and something to suck.",
                    "Keep the rhythm constant — babies settle to repetition, not variety.",
                    "Reduce input elsewhere: dim the lights, turn off the television, move to a quieter room.",
                    "Change holder every twenty minutes if there are two of you.",
                    "If nothing works and you feel your patience going, put your baby down safely in the cot and step away for a few minutes."
                ],
                ru: [
                    "Пробуйте успокаивающий набор целиком: плотное пеленание, положение на боку или на предплечье, ровный звук «ш-ш-ш», мягкое ритмичное покачивание и что-то, что можно пососать.",
                    "Держите ритм постоянным — малышей успокаивает повторение, а не разнообразие.",
                    "Уберите лишние раздражители: приглушите свет, выключите телевизор, перейдите в более тихую комнату.",
                    "Если вас двое, меняйтесь каждые двадцать минут.",
                    "Если ничего не помогает и вы чувствуете, что терпение на исходе, безопасно положите ребёнка в кроватку и отойдите на несколько минут."
                ],
                de: [
                    "Probieren Sie das Beruhigungsset zusammen: ein festes Wickeln, Position auf der Seite oder über dem Unterarm, ein gleichmäßiges \"Shhh\"-Geräusch, sanfte rhythmische Bewegungen und etwas zum Saugen.",
                    "Halten Sie den Rhythmus konstant – Babys beruhigen sich durch Wiederholung, nicht durch Abwechslung.",
                    "Reduzieren Sie andere Reize: dimmen Sie das Licht, schalten Sie den Fernseher aus, gehen Sie in einen ruhigeren Raum.",
                    "Wenn Sie zu zweit seid, wechselt euch alle zwanzig Minuten ab.",
                    "Wenn nichts hilft und Sie merken, dass Ihnen die Geduld ausgeht, legen Sie Ihr Baby sicher in sein Bettchen und gehen Sie ein paar Minuten weg."
                ],
                es: [
                    "Prueba el conjunto calmante completo: un envoltorio ceñido, sostenerlo de lado o sobre tu antebrazo, un sonido constante de \"shhh\", un movimiento rítmico suave y algo que succionar.",
                    "Mantén el ritmo constante: a los bebés los calma la repetición, no la variedad.",
                    "Reduce el resto de estímulos: baja las luces, apaga la televisión, pasa a una habitación más tranquila.",
                    "Turnaos cada veinte minutos si sois dos.",
                    "Si nada funciona y notas que se te agota la paciencia, deja al bebé de forma segura en la cuna y apártate unos minutos."
                ],
                fr: [
                    "Essayez ensemble l'ensemble apaisant : une enveloppe bien ajustée, tenue sur le côté ou sur votre avant-bras, un son de chut régulier, un mouvement rythmé doux et quelque chose à sucer.",
                    "Gardez le rythme constant : les bébés se contentent de la répétition et non de la variété.",
                    "Réduisez les apports ailleurs : tamisez les lumières, éteignez la télévision, déplacez-vous dans une pièce plus calme.",
                    "Changez de support toutes les vingt minutes si vous êtes deux.",
                    "Si rien ne fonctionne et que vous sentez votre patience s'épuiser, déposez votre bébé en toute sécurité dans le lit et éloignez-vous quelques minutes.",
                ],
                pt: [
                    "Experimentem juntos o conjunto calmante: um envoltório confortável, segurando na lateral ou sobre o antebraço, um som constante de silêncio, um movimento rítmico suave e algo para sugar.",
                    "Mantenha o ritmo constante – os bebês se contentam com a repetição, não com a variedade.",
                    "Reduza a entrada em outros lugares: diminua as luzes, desligue a televisão, vá para uma sala mais silenciosa.",
                    "Troque de suporte a cada vinte minutos se vocês forem dois.",
                    "Se nada funcionar e você sentir que sua paciência está acabando, coloque seu bebê em segurança no berço e afaste-se por alguns minutos.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Colic in the sense of long unexplained evening crying peaks around six weeks and settles for most babies by three or four months. These techniques imitate the constant motion, pressure and sound of the womb, which is why several at once tends to work better than any one alone. Knowing there is an end point matters as much as the techniques themselves — this phase is finite even when it does not feel that way.",
                ru: "Колики в смысле долгого необъяснимого вечернего плача достигают пика примерно к шести неделям и у большинства детей проходят к трём-четырём месяцам. Эти приёмы имитируют постоянное движение, давление и звук в утробе — поэтому несколько сразу работают лучше, чем любой из них по отдельности. Знание, что у этого есть конец, важно не меньше самих приёмов: этот период конечен, даже когда так не кажется.",
                de: "Kolik im Sinne von langen unerklärten Abendschreien erreicht ihren Höhepunkt um etwa sechs Wochen und verschwindet bei den meisten Babys um drei bis vier Monate. Diese Techniken ahmen die ständige Bewegung, den Druck und den Klang der Gebärmutter nach – deshalb funktionieren mehrere gleichzeitig besser als eine allein. Zu wissen, dass es ein Ende gibt, ist ebenso wichtig wie die Techniken selbst – diese Phase ist endlich, auch wenn es sich nicht so anfühlt.",
                es: "Los cólicos, entendidos como llanto vespertino prolongado y sin explicación, alcanzan su pico hacia las seis semanas y remiten en la mayoría de los bebés hacia los tres o cuatro meses. Estas técnicas imitan el movimiento, la presión y el sonido constantes del útero, y por eso varias a la vez suelen funcionar mejor que cualquiera por separado. Saber que hay un final importa tanto como las técnicas: esta etapa es finita, aunque no lo parezca.",
                fr: "Les coliques, c'est-à-dire de longs pleurs inexpliqués en soirée, culminent vers six semaines et s'installent pour la plupart des bébés au bout de trois ou quatre mois. Ces techniques imitent le mouvement, la pression et le bruit constants de l’utérus, c’est pourquoi plusieurs à la fois ont tendance à mieux fonctionner qu’une seule. Savoir qu'il y a un point final compte autant que les techniques elles-mêmes - cette phase est finie même si elle ne semble pas l'être.",
                pt: "A cólica, no sentido de um choro noturno longo e inexplicável, atinge o pico por volta das seis semanas e se instala na maioria dos bebês por volta dos três ou quatro meses. Essas técnicas imitam o movimento, a pressão e o som constantes do útero, e é por isso que várias de uma vez tendem a funcionar melhor do que qualquer uma sozinha. Saber que existe um ponto final é tão importante quanto as próprias técnicas – esta fase é finita mesmo quando não parece assim."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Switching technique every thirty seconds before any of them can work.",
                    "Colic drops, herbal remedies or gripe water without medical advice.",
                    "Assuming crying always means hunger and feeding continuously.",
                    "Blaming yourself — colic is not caused by anything you did or did not do."
                ],
                ru: [
                    "Менять приём каждые тридцать секунд, не дав ни одному подействовать.",
                    "Капли от колик, травяные средства или укропная вода без совета врача.",
                    "Считать, что плач всегда означает голод, и кормить без остановки.",
                    "Винить себя — колики не вызваны ничем, что вы сделали или не сделали."
                ],
                de: [
                    "Alle dreißig Sekunden die Technik wechseln, bevor eine von ihnen wirken kann.",
                    "Kolik-Tropfen, Kräutermittel oder Fenchelwasser ohne ärztliche Anleitung.",
                    "Annehmen, dass Weinen immer Hunger bedeutet, und ständig füttern.",
                    "Sich selbst die Schuld geben – Koliken werden nicht durch etwas verursacht, das Sie getan oder nicht getan haben."
                ],
                es: [
                    "Cambiar de técnica cada treinta segundos, antes de que ninguna pueda funcionar.",
                    "Gotas anticólico, remedios de hierbas o agua de anís sin consejo médico.",
                    "Dar por hecho que el llanto siempre significa hambre y alimentar sin parar.",
                    "Culparte: los cólicos no los causa nada que hayas hecho o dejado de hacer."
                ],
                fr: [
                    "Changer de technique toutes les trente secondes avant que l’un d’entre eux puisse fonctionner.",
                    "Gouttes contre les coliques, plantes médicinales ou eau anti-colique sans avis médical.",
                    "En supposant que pleurer signifie toujours avoir faim et se nourrir continuellement.",
                    "Se blâmer – les coliques ne sont pas causées par quelque chose que vous avez fait ou n’avez pas fait.",
                ],
                pt: [
                    "Trocar de técnica a cada trinta segundos antes que qualquer uma delas possa funcionar.",
                    "Gotas para cólicas, remédios fitoterápicos ou gripe water sem orientação médica.",
                    "Assumir que chorar sempre significa fome e alimentação contínua.",
                    "Culpar a si mesmo – a cólica não é causada por nada que você fez ou deixou de fazer.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Crying starts suddenly after a calm period, or the cry sounds high-pitched and unusual.",
                    "Crying with fever, vomiting, blood in the stool, or refusal to feed.",
                    "Poor weight gain alongside the crying.",
                    "You feel unable to cope — this is a reason to ask for help, not a failure."
                ],
                ru: [
                    "Плач начинается внезапно после спокойного периода либо звучит пронзительно и непривычно.",
                    "Плач с температурой, рвотой, кровью в стуле или отказом от еды.",
                    "Плохая прибавка в весе наряду с плачем.",
                    "Вы чувствуете, что не справляетесь, — это повод попросить помощи, а не признак неудачи."
                ],
                de: [
                    "Das Weinen beginnt plötzlich nach einer ruhigen Phase oder klingt hoch und ungewöhnlich.",
                    "Weinen mit Fieber, Erbrechen, Blut im Stuhl oder Fütterungsverweigerung.",
                    "Schlechte Gewichtszunahme neben dem Weinen.",
                    "Sie fühlen sich nicht in der Lage, damit umzugehen – das ist ein Grund um Hilfe zu bitten, kein Versagen."
                ],
                es: [
                    "El llanto empieza de repente tras un periodo tranquilo, o suena agudo e inusual.",
                    "Llanto con fiebre, vómitos, sangre en las heces o rechazo del alimento.",
                    "Escasa ganancia de peso junto con el llanto.",
                    "Sientes que no puedes con ello: es un motivo para pedir ayuda, no un fracaso."
                ],
                fr: [
                    "Les pleurs commencent soudainement après une période de calme, ou le cri semble aigu et inhabituel.",
                    "Pleurs accompagnés de fièvre, de vomissements, de sang dans les selles ou de refus de s'alimenter.",
                    "Mauvaise prise de poids accompagnée de pleurs.",
                    "Vous vous sentez incapable de faire face – c’est une raison pour demander de l’aide, pas un échec.",
                ],
                pt: [
                    "O choro começa repentinamente após um período de calma, ou o choro soa agudo e incomum.",
                    "Choro com febre, vômito, sangue nas fezes ou recusa em alimentar-se.",
                    "Baixo ganho de peso junto com o choro.",
                    "Você se sente incapaz de lidar com a situação – este é um motivo para pedir ajuda, não um fracasso.",
                ]
            )
        ),

        CareTip(
            id: 1302, category: .comfort, icon: "arrow.triangle.2.circlepath", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Releasing trapped wind",
                ru: "Как помочь отойти газикам",
                de: "Eingeklemmte Luft freigeben",
                es: "Ayudar a expulsar los gases",
                fr: "Libérer le vent emprisonné",
                pt: "Liberando o vento preso"
            ),
            summary: LocalizedText(
                en: "Bicycle legs, a warm tummy and a few minutes of patience",
                ru: "«Велосипед» ножками, тёплый животик и несколько минут терпения",
                de: "Fahrradadbewegungen, ein warmer Bauch und ein paar Minuten Geduld",
                es: "Bicicleta con las piernas, barriga templada y unos minutos de paciencia",
                fr: "Des jambes de vélo, un ventre chaud et quelques minutes de patience",
                pt: "Pernas de bicicleta, barriga quentinha e alguns minutos de paciência"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Lay your baby on their back and cycle the legs slowly, one at a time.",
                    "Bring both knees gently up towards the tummy, hold for a few seconds, release. Repeat several times.",
                    "Massage the tummy in slow clockwise circles with warm hands, following the direction of the gut.",
                    "Try a few minutes of tummy time across your lap while your baby is awake and supervised.",
                    "Do all of this before a feed or well after one, not immediately afterwards."
                ],
                ru: [
                    "Положите ребёнка на спину и медленно «крутите велосипед» ножками, поочерёдно.",
                    "Мягко подтяните оба колена к животику, задержите на несколько секунд, отпустите. Повторите несколько раз.",
                    "Массируйте живот медленными круговыми движениями по часовой стрелке тёплыми руками, по ходу кишечника.",
                    "Выложите ребёнка на несколько минут на животик у себя на коленях, пока он бодрствует и под присмотром.",
                    "Делайте всё это до кормления или заметно позже, но не сразу после."
                ],
                de: [
                    "Legen Sie Ihr Baby auf den Rücken und fahren Sie mit den Beinen langsam Fahrrad, eines nach dem anderen.",
                    "Bringen Sie sanft beide Knie zum Bauch hin, halten Sie ein paar Sekunden, lassen Sie los. Wiederholen Sie mehrmals.",
                    "Massieren Sie den Bauch in langsamen Uhrzeigersinnbewegungen mit warmen Händen, der Richtung des Darms folgend.",
                    "Legen Sie Ihr Baby für ein paar Minuten wach und überwacht auf den Bauch über Ihrem Schoß.",
                    "Machen Sie dies alles vor einer Fütterung oder lange danach, aber nicht unmittelbar danach."
                ],
                es: [
                    "Tumba al bebé boca arriba y mueve sus piernas despacio como si pedaleara, una cada vez.",
                    "Lleva con suavidad ambas rodillas hacia la barriga, mantén unos segundos y suelta. Repite varias veces.",
                    "Masajea la barriga en círculos lentos en el sentido de las agujas del reloj con las manos calientes, siguiendo la dirección del intestino.",
                    "Prueba unos minutos boca abajo sobre tus piernas, con el bebé despierto y vigilado.",
                    "Haz todo esto antes de una toma o bastante después, nunca justo al terminar."
                ],
                fr: [
                    "Allongez votre bébé sur le dos et faites rouler ses jambes lentement, une à la fois.",
                    "Ramenez doucement les deux genoux vers le ventre, maintenez pendant quelques secondes, relâchez. Répétez plusieurs fois.",
                    "Massez le ventre en effectuant des cercles lents dans le sens des aiguilles d’une montre avec les mains chaudes, en suivant la direction de l’intestin.",
                    "Essayez de passer quelques minutes sur le ventre sur vos genoux pendant que votre bébé est éveillé et surveillé.",
                    "Faites tout cela avant ou bien après une tétée, pas immédiatement après.",
                ],
                pt: [
                    "Deite o bebê de costas e gire as pernas lentamente, uma de cada vez.",
                    "Traga ambos os joelhos suavemente em direção à barriga, segure por alguns segundos e solte. Repita várias vezes.",
                    "Massageie a barriga em círculos lentos no sentido horário com as mãos quentes, seguindo a direção do intestino.",
                    "Experimente alguns minutos de barriga para baixo em seu colo enquanto seu bebê está acordado e supervisionado.",
                    "Faça tudo isso antes ou bem depois da mamada, não imediatamente depois.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "An immature digestive system moves gas slowly, and a baby who cannot yet change position has no way to help it along. Leg movement and clockwise massage follow the path of the large intestine and physically encourage gas towards the exit. Warmth relaxes the abdominal wall, which is why the same movements work better with warm hands than cold ones.",
                ru: "Незрелая пищеварительная система продвигает газы медленно, а ребёнок, который ещё не может сменить позу, никак не способен себе помочь. Движения ножками и массаж по часовой стрелке повторяют ход толстой кишки и физически продвигают газы к выходу. Тепло расслабляет брюшную стенку — поэтому те же движения тёплыми руками работают лучше, чем холодными.",
                de: "Ein unreifes Verdauungssystem befördert Gas langsam, und ein Baby, das seine Position noch nicht verändern kann, hat keine Möglichkeit, ihm zu helfen. Beinbewegungen und kreisende Massage folgen dem Weg des Dickdarms und ermutigen die Luft physisch zum Ausgang. Wärme entspannt die Bauchdecke – deshalb funktionieren dieselben Bewegungen mit warmen Händen besser als mit kalten.",
                es: "Un sistema digestivo inmaduro desplaza los gases despacio, y un bebé que aún no puede cambiar de postura no tiene forma de ayudar. El movimiento de las piernas y el masaje en el sentido de las agujas del reloj siguen el recorrido del intestino grueso y empujan físicamente el gas hacia la salida. El calor relaja la pared abdominal: por eso los mismos movimientos funcionan mejor con las manos calientes que frías.",
                fr: "Un système digestif immature déplace les gaz lentement et un bébé qui ne peut pas encore changer de position n'a aucun moyen de l'aider. Le mouvement des jambes et le massage dans le sens des aiguilles d’une montre suivent le trajet du gros intestin et encouragent physiquement les gaz vers la sortie. La chaleur détend la paroi abdominale, c'est pourquoi les mêmes mouvements fonctionnent mieux avec des mains chaudes qu'avec des mains froides.",
                pt: "Um sistema digestivo imaturo movimenta os gases lentamente, e um bebê que ainda não consegue mudar de posição não tem como ajudá-lo. O movimento das pernas e a massagem no sentido horário seguem o trajeto do intestino grosso e estimulam fisicamente os gases em direção à saída. O calor relaxa a parede abdominal, razão pela qual os mesmos movimentos funcionam melhor com as mãos quentes do que com as frias."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Massaging straight after a feed, which usually brings milk back up.",
                    "Pressing firmly on a full tummy.",
                    "Anticlockwise circles, working against the natural direction.",
                    "Simethicone drops or herbal teas without asking your doctor first."
                ],
                ru: [
                    "Массировать сразу после кормления — обычно это заканчивается срыгиванием.",
                    "Сильно надавливать на полный живот.",
                    "Круговые движения против часовой стрелки, против естественного направления.",
                    "Капли с симетиконом или травяные чаи без предварительной консультации с врачом."
                ],
                de: [
                    "Massage unmittelbar nach dem Füttern, was normalerweise zu Aufstoßen führt.",
                    "Fest auf einen vollen Bauch drücken.",
                    "Bewegungen gegen den Uhrzeigersinn, gegen die natürliche Richtung.",
                    "Simethicon-Tropfen oder Kräutertees ohne vorherige ärztliche Rücksprache."
                ],
                es: [
                    "Masajear justo después de una toma, lo que suele provocar que devuelva la leche.",
                    "Presionar con fuerza sobre una barriga llena.",
                    "Hacer círculos en sentido contrario a las agujas del reloj, contra la dirección natural.",
                    "Gotas de simeticona o infusiones sin consultar antes con el médico."
                ],
                fr: [
                    "Masser juste après la tétée, ce qui fait généralement remonter le lait.",
                    "En appuyant fermement sur un ventre plein.",
                    "Cercles dans le sens inverse des aiguilles d’une montre, travaillant contre la direction naturelle.",
                    "Gouttes de siméthicone ou tisanes sans demander l'avis préalable de votre médecin.",
                ],
                pt: [
                    "Massagear logo após a mamada, o que geralmente traz o leite de volta.",
                    "Pressionando firmemente a barriga cheia.",
                    "Círculos no sentido anti-horário, trabalhando contra a direção natural.",
                    "Gotas de simeticona ou chás de ervas sem consultar primeiro o seu médico.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "The tummy is hard, swollen, or tender to touch.",
                    "No stool for an unusually long stretch alongside distress and vomiting.",
                    "Blood or mucus in the stool.",
                    "Drawing the legs up with screaming that comes in sharp waves."
                ],
                ru: [
                    "Живот твёрдый, вздутый или болезненный при прикосновении.",
                    "Необычно долгое отсутствие стула вместе с беспокойством и рвотой.",
                    "Кровь или слизь в стуле.",
                    "Ребёнок поджимает ножки и кричит резкими приступами."
                ],
                de: [
                    "Der Bauch ist hart, aufgebläht oder schmerzhaft bei Berührung.",
                    "Lange Zeit kein Stuhlgang zusammen mit Unbehagen und Erbrechen.",
                    "Blut oder Schleim im Stuhl.",
                    "Baby zieht die Beine an und schreit in scharfen Wellen."
                ],
                es: [
                    "La barriga está dura, hinchada o duele al tocarla.",
                    "Ausencia de deposiciones durante un periodo inusualmente largo junto con malestar y vómitos.",
                    "Sangre o moco en las heces.",
                    "Encoge las piernas y grita en oleadas intensas."
                ],
                fr: [
                    "Le ventre est dur, gonflé ou sensible au toucher.",
                    "Pas de selles pendant une période inhabituellement longue accompagnée de détresse et de vomissements.",
                    "Sang ou mucus dans les selles.",
                    "Remonter les jambes avec des cris qui se manifestent par vagues aiguës.",
                ],
                pt: [
                    "A barriga está dura, inchada ou sensível ao toque.",
                    "Ausência de fezes por um período anormalmente longo, juntamente com angústia e vômitos.",
                    "Sangue ou muco nas fezes.",
                    "Levantando as pernas com gritos que vêm em ondas agudas.",
                ]
            )
        ),

        CareTip(
            id: 1303, category: .comfort, icon: "thermometer.high", ageFrom: 0, ageTo: 24,
            title: LocalizedText(
                en: "Measuring a fever and knowing the thresholds",
                ru: "Как измерять температуру и какие пороги важны",
                de: "Fieber messen und die Schwellenwerte kennen",
                es: "Medir la fiebre y conocer los umbrales",
                fr: "Mesurer une fièvre et connaître les seuils",
                pt: "Medindo a febre e conhecendo os limites"
            ),
            summary: LocalizedText(
                en: "Under three months, any fever is an immediate call — no exceptions",
                ru: "До трёх месяцев любая лихорадка — повод немедленно обратиться к врачу, без исключений",
                de: "Unter drei Monaten ist jedes Fieber ein sofortiger Anruf – keine Ausnahmen",
                es: "Por debajo de los tres meses, cualquier fiebre exige llamar de inmediato, sin excepciones",
                fr: "Moins de trois mois, toute fièvre est un appel immédiat – sans exception",
                pt: "Menos de três meses, qualquer febre é uma chamada imediata – sem exceções"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Measure with a digital thermometer under the arm for young babies, or use the device your doctor recommends.",
                    "Record the number and the time in Momsy so you can show the curve, not a single point.",
                    "Watch behaviour as well as the number: feeding, alertness, wet nappies, breathing, skin colour.",
                    "Keep fluids going — more frequent breast or formula feeds, and water too once solids have started.",
                    "Do not overwrap. One light layer helps heat escape."
                ],
                ru: [
                    "Измеряйте цифровым термометром в подмышечной впадине у маленьких детей или прибором, который рекомендовал ваш врач.",
                    "Записывайте значение и время в Momsy, чтобы показать врачу динамику, а не одну точку.",
                    "Следите не только за цифрой, но и за поведением: кормление, активность, мокрые подгузники, дыхание, цвет кожи.",
                    "Поддерживайте питьевой режим — чаще прикладывайте к груди или давайте смесь, а после введения прикорма и воду.",
                    "Не кутайте. Один лёгкий слой одежды помогает теплу уходить."
                ],
                de: [
                    "Messen Sie mit einem digitalen Thermometer unter der Achsel bei Neugeborenen oder verwenden Sie das Gerät, das Ihr Arzt empfiehlt.",
                    "Notieren Sie die Temperatur und Uhrzeit in Momsy, damit Sie den Verlauf zeigen können, nicht nur einen Punkt.",
                    "Beobachten Sie nicht nur die Zahl, sondern auch das Verhalten: Fütterung, Wachsamkeit, nasse Windeln, Atmung, Hautfarbe.",
                    "Halten Sie die Flüssigkeitszufuhr aufrecht – häufigeres Stillen oder Fläschchen und später auch Wasser.",
                    "Wickeln Sie nicht zu viel ein. Eine leichte Schicht hilft Wärme zu entweichen."
                ],
                es: [
                    "Mide con un termómetro digital en la axila si el bebé es pequeño, o usa el dispositivo que te recomiende tu médico.",
                    "Anota el valor y la hora en Momsy para poder enseñar la curva, no un único dato.",
                    "Observa el comportamiento además de la cifra: tomas, reactividad, pañales mojados, respiración, color de la piel.",
                    "Mantén los líquidos: tomas de pecho o biberón más frecuentes, y también agua una vez iniciada la alimentación complementaria.",
                    "No lo abrigues de más. Una capa ligera ayuda a que el calor salga."
                ],
                fr: [
                    "Mesurez avec un thermomètre numérique sous le bras pour les jeunes bébés ou utilisez l'appareil recommandé par votre médecin.",
                    "Enregistrez le nombre et l'heure dans Momsy afin de pouvoir afficher la courbe, pas un seul point.",
                    "Surveillez le comportement ainsi que le nombre : alimentation, vigilance, couches mouillées, respiration, couleur de peau.",
                    "Continuez à boire - des tétées plus fréquentes au sein ou au lait maternisé, et de l'eau également une fois que les solides ont commencé.",
                    "Ne pas suremballer. Une couche légère aide la chaleur à s’échapper.",
                ],
                pt: [
                    "Meça com um termômetro digital debaixo do braço para bebês ou use o dispositivo recomendado pelo seu médico.",
                    "Registre o número e a hora no Momsy para poder mostrar a curva, não um único ponto.",
                    "Observe o comportamento e também o número: alimentação, estado de alerta, fraldas molhadas, respiração, cor da pele.",
                    "Mantenha a ingestão de líquidos – mamadas mais frequentes ou com fórmula, e água também quando os sólidos começarem.",
                    "Não embrulhe demais. Uma camada leve ajuda a escapar do calor.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "In babies under three months the immune system cannot contain infection reliably, so a temperature of 38 °C or above is treated as urgent regardless of how well the baby seems. From three months onwards, behaviour carries more information than the number itself: a baby with 39 °C who drinks and responds to you is usually less concerning than one at 38 °C who is limp and will not feed.",
                ru: "У детей до трёх месяцев иммунная система не может надёжно сдержать инфекцию, поэтому температура 38 °C и выше считается неотложной ситуацией независимо от того, насколько хорошо выглядит ребёнок. После трёх месяцев поведение говорит больше, чем сама цифра: ребёнок с 39 °C, который пьёт и реагирует на вас, обычно менее тревожен, чем ребёнок с 38 °C, который вялый и отказывается от еды.",
                de: "Bei Babys unter drei Monaten kann das Immunsystem Infektionen nicht zuverlässig eindämmen, daher wird eine Temperatur von 38 °C oder höher als dringend behandelt, unabhängig davon, wie gut das Baby aussieht. Ab drei Monaten sagt das Verhalten mehr aus als die Zahl selbst: Ein Baby mit 39 °C, das trinkt und auf Sie reagiert, ist normalerweise weniger besorgniserregend als eines mit 38 °C, das schlaff ist und nicht füttern will.",
                es: "En bebés menores de tres meses el sistema inmunitario no contiene la infección de forma fiable, así que una temperatura de 38 °C o más se trata como urgente por muy bien que parezca estar el bebé. A partir de los tres meses, el comportamiento aporta más información que la cifra: un bebé con 39 °C que bebe y responde suele preocupar menos que uno con 38 °C que está flácido y no quiere comer.",
                fr: "Chez les bébés de moins de trois mois, le système immunitaire ne peut pas contenir l'infection de manière fiable, c'est pourquoi une température de 38 °C ou plus est considérée comme urgente, quel que soit l'état de santé du bébé. À partir de trois mois, le comportement contient plus d'informations que le chiffre lui-même : un bébé à 39 °C qui boit et vous répond est généralement moins inquiétant qu'un bébé à 38 °C qui est mou et ne veut pas se nourrir.",
                pt: "Em bebés com menos de três meses, o sistema imunitário não consegue conter a infecção de forma fiável, pelo que uma temperatura de 38 °C ou superior é tratada como urgente, independentemente do estado de saúde do bebé. A partir dos três meses, o comportamento carrega mais informações do que o próprio número: um bebê com 39 °C que bebe e responde a você geralmente é menos preocupante do que um bebê com 38 °C que está mole e não mama."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Judging temperature by touch alone.",
                    "Wrapping a hot baby in blankets.",
                    "Any medication without confirming the dose for your baby's age and weight with a professional.",
                    "Cold baths or alcohol rubs to bring the temperature down."
                ],
                ru: [
                    "Оценивать температуру только на ощупь.",
                    "Укутывать горячего ребёнка в одеяла.",
                    "Давать любое лекарство, не уточнив у специалиста дозу для возраста и веса ребёнка.",
                    "Холодные ванны или обтирания спиртом, чтобы сбить температуру."
                ],
                de: [
                    "Temperatur nur durch Berührung beurteilen.",
                    "Ein heißes Baby in Decken wickeln.",
                    "Irgendwelche Medikamente geben, ohne mit einem Fachmann die Dosis für Alter und Gewicht zu bestätigen.",
                    "Kalte Bäder oder Alkoholabreibungen, um die Temperatur zu senken."
                ],
                es: [
                    "Juzgar la temperatura solo al tacto.",
                    "Envolver en mantas a un bebé caliente.",
                    "Dar cualquier medicamento sin confirmar con un profesional la dosis para la edad y el peso del bebé.",
                    "Baños fríos o friegas de alcohol para bajar la temperatura."
                ],
                fr: [
                    "Juger la température uniquement au toucher.",
                    "Envelopper un bébé chaud dans des couvertures.",
                    "Tout médicament sans confirmation de la dose adaptée à l'âge et au poids de votre bébé auprès d'un professionnel.",
                    "Des bains froids ou des frictions alcoolisées pour faire baisser la température.",
                ],
                pt: [
                    "Julgando a temperatura apenas pelo toque.",
                    "Envolvendo um bebê quente em cobertores.",
                    "Qualquer medicamento sem confirmação da dose para a idade e peso do seu bebê com um profissional.",
                    "Banhos frios ou fricções com álcool para baixar a temperatura.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Any fever of 38 °C or more in a baby under three months — seek care immediately.",
                    "Fever with a rash that does not fade under pressure, a stiff neck, or a bulging fontanelle — emergency.",
                    "Difficult or rapid breathing, unusual drowsiness, or a weak cry.",
                    "Fever lasting more than 48 hours, or a baby who will not drink."
                ],
                ru: [
                    "Любая температура 38 °C и выше у ребёнка младше трёх месяцев — обратитесь за помощью немедленно.",
                    "Температура с сыпью, которая не бледнеет при надавливании, ригидность шеи или выбухающий родничок — экстренная ситуация.",
                    "Затруднённое или учащённое дыхание, необычная сонливость или слабый крик.",
                    "Температура держится дольше 48 часов или ребёнок отказывается пить."
                ],
                de: [
                    "Jedes Fieber von 38 °C oder höher bei einem Baby unter drei Monaten – suchen Sie sofort Hilfe auf.",
                    "Fieber mit Ausschlag, der unter Druck nicht verblasst, steife Nacke oder ausbeulende Fontanelle – Notfall.",
                    "Schwieriges oder schnelles Atmen, ungewöhnliche Schläfrigkeit oder schwaches Weinen.",
                    "Fieber länger als 48 Stunden anhaltend oder Baby trinkt nicht."
                ],
                es: [
                    "Cualquier fiebre de 38 °C o más en un bebé menor de tres meses: busca atención de inmediato.",
                    "Fiebre con un sarpullido que no palidece al presionar, rigidez de nuca o fontanela abombada: urgencia.",
                    "Respiración difícil o acelerada, somnolencia inusual o llanto débil.",
                    "Fiebre de más de 48 horas, o un bebé que no quiere beber."
                ],
                fr: [
                    "Toute fièvre de 38 °C ou plus chez un bébé de moins de trois mois : consultez immédiatement.",
                    "Fièvre avec éruption cutanée qui ne s'estompe pas sous la pression, raideur de la nuque ou fontanelle bombée – urgence.",
                    "Respiration difficile ou rapide, somnolence inhabituelle ou cri faible.",
                    "Fièvre qui dure plus de 48 heures ou bébé qui ne veut pas boire.",
                ],
                pt: [
                    "Qualquer febre de 38°C ou mais em um bebê com menos de três meses – procure atendimento imediatamente.",
                    "Febre com erupção na pele que não desaparece sob pressão, rigidez no pescoço ou fontanela protuberante – emergência.",
                    "Respiração difícil ou rápida, sonolência incomum ou choro fraco.",
                    "Febre com duração superior a 48 horas ou bebê que não bebe.",
                ]
            )
        ),

        CareTip(
            id: 1304, category: .comfort, icon: "mouth.fill", ageFrom: 4, ageTo: 24,
            title: LocalizedText(
                en: "Teething relief that is actually safe",
                ru: "Безопасная помощь при прорезывании зубов",
                de: "Zahnen-Linderung, die wirklich sicher ist",
                es: "Alivio de la dentición que sí es seguro",
                fr: "Un soulagement de la dentition réellement sûr",
                pt: "Alívio da dentição que é realmente seguro"
            ),
            summary: LocalizedText(
                en: "Cool pressure works; necklaces and numbing gels do not belong here",
                ru: "Прохлада и давление помогают; бусы и обезболивающие гели здесь неуместны",
                de: "Kühle und Druck wirken; Halsketten und Zahnungsgel gehören hier nicht hin",
                es: "El frío y la presión funcionan; los collares y los geles anestésicos no pintan nada aquí",
                fr: "La pression froide fonctionne ; les colliers et les gels anesthésiants n'ont pas leur place ici",
                pt: "A pressão fria funciona; colares e géis anestésicos não pertencem aqui"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Offer a firm rubber or silicone teether, chilled in the fridge rather than the freezer.",
                    "Rub the gum with a clean finger or a cool damp flannel using steady pressure.",
                    "Let your baby chew on a cold clean cloth under supervision.",
                    "Wipe drool from the chin and neck often and apply a barrier cream to prevent a drool rash.",
                    "Keep routines calm and expect a few unsettled nights around each tooth."
                ],
                ru: [
                    "Дайте плотный резиновый или силиконовый прорезыватель, охлаждённый в холодильнике, а не в морозилке.",
                    "Разотрите десну чистым пальцем или прохладной влажной салфеткой, надавливая ровно и мягко.",
                    "Дайте ребёнку пожевать холодную чистую ткань под присмотром.",
                    "Часто вытирайте слюну с подбородка и шеи и наносите защитный крем, чтобы не было раздражения.",
                    "Сохраняйте спокойный режим дня и будьте готовы к нескольким беспокойным ночам на каждый зуб."
                ],
                de: [
                    "Bieten Sie einen festen Gummi- oder Silikon-Beißring an, im Kühlschrank gekühlt, nicht im Gefrierschrank.",
                    "Reiben Sie das Zahnfleisch mit einem sauberen Finger oder einer kühlen feuchten Waschlappen mit gleichmäßigem Druck.",
                    "Lassen Sie Ihr Baby unter Aufsicht an einem kalten sauberen Tuch kauen.",
                    "Wischen Sie Speichel häufig von Kinn und Hals ab und tragen Sie eine Schutzcrème auf, um Speichel-Ausschlag zu verhindern.",
                    "Halten Sie die Routine ruhig und rechnen Sie mit ein paar unruhigen Nächten um jeden Zahn."
                ],
                es: [
                    "Ofrece un mordedor firme de goma o silicona, enfriado en la nevera y no en el congelador.",
                    "Frota la encía con un dedo limpio o una gasa húmeda fresca, aplicando una presión constante.",
                    "Deja que muerda un paño limpio y frío, siempre bajo vigilancia.",
                    "Seca la baba de la barbilla y el cuello a menudo y aplica una crema barrera para evitar irritación.",
                    "Mantén las rutinas tranquilas y cuenta con algunas noches movidas por cada diente."
                ],
                fr: [
                    "Offrez un anneau de dentition ferme en caoutchouc ou en silicone, réfrigéré au réfrigérateur plutôt qu'au congélateur.",
                    "Frottez la gomme avec un doigt propre ou une flanelle fraîche et humide en exerçant une pression constante.",
                    "Laissez votre bébé mâcher un chiffon propre et froid sous surveillance.",
                    "Essuyez souvent la bave sur le menton et le cou et appliquez une crème barrière pour éviter les éruptions cutanées dues à la bave.",
                    "Gardez vos routines calmes et attendez-vous à quelques nuits instables autour de chaque dent.",
                ],
                pt: [
                    "Ofereça um mordedor firme de borracha ou silicone, refrigerado na geladeira e não no freezer.",
                    "Esfregue a goma com um dedo limpo ou uma flanela úmida e fria usando pressão constante.",
                    "Deixe seu bebê mastigar um pano limpo e frio sob supervisão.",
                    "Limpe a baba do queixo e pescoço com frequência e aplique um creme de barreira para evitar erupções cutâneas com baba.",
                    "Mantenha as rotinas calmas e espere algumas noites agitadas perto de cada dente.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Pressure on the gum interrupts the pain signal from the tooth pushing through, and cold reduces local swelling — which is why a chilled teether outperforms almost everything sold for the purpose. Amber necklaces are a strangulation and choking risk with no proven benefit, and some numbing gels contain ingredients not considered safe for infants. Teething also does not cause high fever or diarrhoea; if those appear, look for another explanation.",
                ru: "Давление на десну перебивает болевой сигнал от прорезывающегося зуба, а холод уменьшает местный отёк — поэтому охлаждённый прорезыватель эффективнее почти всего, что продают для этой цели. Янтарные бусы — риск удушения и попадания в дыхательные пути без доказанной пользы, а некоторые обезболивающие гели содержат вещества, небезопасные для младенцев. Прорезывание зубов также не вызывает высокой температуры и диареи; если они появились, ищите другую причину.",
                de: "Druck auf das Zahnfleisch unterbricht das Schmerzsignal vom durchbrechenden Zahn, und Kälte reduziert lokale Schwellungen – deshalb übertrifft ein gekühlter Beißring fast alles andere. Bernsteinketten sind Strangulations- und Erstickungsrisiken ohne nachgewiesenen Nutzen, und einige Zahnungsgel enthalten Inhaltsstoffe, die für Säuglinge nicht sicher sind. Zahnen verursacht auch nicht hohe Fieber oder Durchfall; wenn diese auftreten, suchen Sie nach einer anderen Erklärung.",
                es: "La presión sobre la encía interrumpe la señal de dolor del diente que empuja, y el frío reduce la inflamación local: por eso un mordedor enfriado supera a casi todo lo que se vende para esto. Los collares de ámbar son un riesgo de estrangulamiento y atragantamiento sin beneficio demostrado, y algunos geles anestésicos contienen ingredientes que no se consideran seguros en lactantes. La dentición tampoco causa fiebre alta ni diarrea; si aparecen, busca otra explicación.",
                fr: "La pression sur la gencive interrompt le signal de douleur émis par la dent et le froid réduit le gonflement local. C'est pourquoi un anneau de dentition réfrigéré surpasse presque tout ce qui est vendu à cet effet. Les colliers d'ambre présentent un risque d'étranglement et d'étouffement sans aucun bénéfice prouvé, et certains gels anesthésiants contiennent des ingrédients non considérés comme sûrs pour les nourrissons. La poussée dentaire ne provoque pas non plus de forte fièvre ni de diarrhée ; si ceux-ci apparaissent, cherchez une autre explication.",
                pt: "A pressão na gengiva interrompe o sinal de dor da passagem do dente, e o frio reduz o inchaço local – razão pela qual um mordedor resfriado supera quase tudo que é vendido para esse fim. Colares de âmbar apresentam risco de estrangulamento e asfixia sem benefício comprovado, e alguns géis anestésicos contêm ingredientes não considerados seguros para bebês. A dentição também não causa febre alta ou diarreia; se aparecerem, procure outra explicação."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Amber or wooden bead necklaces.",
                    "Teethers frozen solid, which are too hard for delicate gums.",
                    "Numbing gels containing benzocaine or lidocaine.",
                    "Blaming a high fever or a persistent illness on teething."
                ],
                ru: [
                    "Янтарные или деревянные бусы.",
                    "Замороженные до твёрдости прорезыватели — они слишком жёсткие для нежных дёсен.",
                    "Обезболивающие гели с бензокаином или лидокаином.",
                    "Списывать высокую температуру или затяжную болезнь на зубы."
                ],
                de: [
                    "Bernstein- oder Holzperlen-Halsketten.",
                    "Gefrorene Beißringe, die zu hart für empfindliches Zahnfleisch sind.",
                    "Zahnungsgel mit Benzocain oder Lidocain.",
                    "Hohes Fieber oder anhaltende Krankheit dem Zahnen anrechnen."
                ],
                es: [
                    "Collares de ámbar o de cuentas de madera.",
                    "Mordedores congelados y duros, demasiado rígidos para unas encías delicadas.",
                    "Geles anestésicos con benzocaína o lidocaína.",
                    "Achacar a los dientes una fiebre alta o una enfermedad persistente."
                ],
                fr: [
                    "Colliers de perles d'ambre ou de bois.",
                    "Anneaux de dentition gelés, trop durs pour les gencives délicates.",
                    "Gels anesthésiques contenant de la benzocaïne ou de la lidocaïne.",
                    "Attribuer une forte fièvre ou une maladie persistante à la poussée dentaire.",
                ],
                pt: [
                    "Colares de contas de âmbar ou madeira.",
                    "Mordedores congelados e sólidos, que são muito duros para gengivas delicadas.",
                    "Géis anestésicos contendo benzocaína ou lidocaína.",
                    "Culpar a dentição pela febre alta ou por uma doença persistente.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Fever above 38 °C, which is not caused by teething.",
                    "Diarrhoea, vomiting, or a rash across the body.",
                    "Refusal to feed for more than a day.",
                    "Swollen, bleeding gums, or no teeth at all by around 15 months."
                ],
                ru: [
                    "Температура выше 38 °C — она не вызвана прорезыванием зубов.",
                    "Диарея, рвота или сыпь по всему телу.",
                    "Отказ от еды дольше суток.",
                    "Отёкшие, кровоточащие дёсны или полное отсутствие зубов примерно к 15 месяцам."
                ],
                de: [
                    "Fieber über 38 °C, das nicht vom Zahnen verursacht wird.",
                    "Durchfall, Erbrechen oder Ausschlag am ganzen Körper.",
                    "Verweigerung der Fütterung für mehr als einen Tag.",
                    "Geschwollenes, blutendes Zahnfleisch oder überhaupt keine Zähne um etwa 15 Monate."
                ],
                es: [
                    "Fiebre por encima de 38 °C, que no está causada por la dentición.",
                    "Diarrea, vómitos o sarpullido por todo el cuerpo.",
                    "Rechazo del alimento durante más de un día.",
                    "Encías hinchadas o sangrantes, o ausencia total de dientes hacia los 15 meses."
                ],
                fr: [
                    "Fièvre supérieure à 38 °C, non causée par la poussée dentaire.",
                    "Diarrhée, vomissements ou éruption cutanée sur tout le corps.",
                    "Refus de se nourrir pendant plus d'une journée.",
                    "Gencives enflées, saignantes ou absence de dents du tout vers 15 mois.",
                ],
                pt: [
                    "Febre acima de 38°C, que não é causada pela dentição.",
                    "Diarréia, vômito ou erupção cutânea em todo o corpo.",
                    "Recusa de alimentação por mais de um dia.",
                    "Gengivas inchadas, sangrando ou nenhum dente por volta dos 15 meses.",
                ]
            )
        ),

        CareTip(
            id: 1305, category: .comfort, icon: "comb.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Cradle cap: harmless and self-resolving",
                ru: "Себорейные корочки: безобидны и проходят сами",
                de: "Kopfgneis: harmlos und heilt von selbst",
                es: "Costra láctea: inofensiva y se resuelve sola",
                fr: "Les croûtes de lait : inoffensives et auto-résolvantes",
                pt: "Crosta de berço: inofensiva e auto-resolvível"
            ),
            summary: LocalizedText(
                en: "Soften, comb gently, wash out — and accept that time does most of the work",
                ru: "Размягчить, аккуратно вычесать, смыть — и помнить, что основную работу делает время",
                de: "Aufweichen, sanft kämmen, auswaschen – und akzeptieren, dass die Zeit die meiste Arbeit macht",
                es: "Ablandar, peinar con suavidad, lavar — y aceptar que el tiempo hace casi todo el trabajo",
                fr: "Adoucir, peigner délicatement, laver — et accepter que le temps fasse l'essentiel du travail.",
                pt: "Suavize, penteie suavemente, lave – e aceite que o tempo faz a maior parte do trabalho"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Massage a little baby oil or an unfragranced emollient into the scalp and leave it for an hour or overnight.",
                    "Loosen the softened scales with a soft brush or a fine comb, always gently.",
                    "Wash out with a mild baby shampoo, then brush the hair through.",
                    "Repeat every few days rather than daily.",
                    "If it does not shift, leave it — it clears on its own within months."
                ],
                ru: [
                    "Вотрите в кожу головы немного детского масла или эмолента без отдушек и оставьте на час или на ночь.",
                    "Размягчённые чешуйки аккуратно приподнимите мягкой щёткой или частым гребнем.",
                    "Смойте мягким детским шампунем, затем расчешите волосы.",
                    "Повторяйте раз в несколько дней, а не ежедневно.",
                    "Если корочки не поддаются, оставьте их — они проходят сами за несколько месяцев."
                ],
                de: [
                    "Massieren Sie ein wenig Babyöl oder ein unparfümiertes Emolliens in die Kopfhaut und lassen Sie es eine Stunde oder über Nacht einwirken.",
                    "Lockern Sie die aufgeweichten Schuppen mit einer weichen Bürste oder einem feinen Kamm, immer sanft.",
                    "Waschen Sie mit einem milden Baby-Shampoo aus und kämmen Sie die Haare dann durch.",
                    "Wiederholen Sie alle paar Tage, nicht täglich.",
                    "Wenn sich nichts tut, lassen Sie es – es heilt innerhalb von Monaten von selbst ab."
                ],
                es: [
                    "Masajea un poco de aceite infantil o un emoliente sin perfume en el cuero cabelludo y déjalo actuar una hora o toda la noche.",
                    "Afloja las escamas ya ablandadas con un cepillo suave o un peine fino, siempre con delicadeza.",
                    "Lava con un champú infantil suave y después peina el pelo.",
                    "Repite cada pocos días, no a diario.",
                    "Si no se desprende, déjalo: desaparece solo en unos meses."
                ],
                fr: [
                    "Massez un peu d'huile pour bébé ou un émollient non parfumé sur le cuir chevelu et laissez agir pendant une heure ou toute la nuit.",
                    "Détachez les écailles ramollies avec une brosse douce ou un peigne fin, toujours délicatement.",
                    "Lavez avec un shampoing doux pour bébé, puis brossez les cheveux.",
                    "Répétez tous les quelques jours plutôt que quotidiennement.",
                    "S’il ne bouge pas, laissez-le – il disparaît tout seul en quelques mois.",
                ],
                pt: [
                    "Massageie um pouco de óleo de bebê ou um emoliente sem perfume no couro cabeludo e deixe agir por uma hora ou durante a noite.",
                    "Solte as escamas amolecidas com uma escova macia ou um pente fino, sempre com cuidado.",
                    "Lave com um xampu suave para bebês e depois escove o cabelo.",
                    "Repita a cada poucos dias, em vez de diariamente.",
                    "Se não mudar, deixe-o – ele desaparece sozinho em alguns meses.",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Cradle cap comes from overactive oil glands stimulated by hormones still circulating from pregnancy, so it is neither an infection nor a sign of poor hygiene, and it does not itch or bother your baby. Softening first is the whole trick: dry scales are attached to skin, oiled scales are not. Picking at dry patches breaks the skin underneath and opens the door to genuine infection.",
                ru: "Себорейные корочки возникают из-за избыточной работы сальных желёз под действием гормонов, оставшихся с беременности, — это не инфекция и не признак плохой гигиены, они не зудят и не беспокоят ребёнка. Весь секрет в предварительном размягчении: сухие чешуйки держатся за кожу, промасленные — нет. Ковыряние сухих участков повреждает кожу под ними и открывает путь настоящей инфекции.",
                de: "Kopfgneis entsteht durch überaktive Talgdrüsen, die durch Schwangerschaftshormone stimuliert werden – es ist weder eine Infektion noch ein Zeichen schlechter Hygiene, und es juckt nicht oder stört Ihr Baby nicht. Das Aufweichen zuerst ist der ganze Trick: trockene Schuppen halten an der Haut fest, geölte nicht. An trockenen Stellen zu kratzen verletzt die darunter liegende Haut und öffnet die Tür zu echten Infektionen.",
                es: "La costra láctea aparece por glándulas sebáceas hiperactivas estimuladas por hormonas que aún circulan del embarazo, así que no es una infección ni señal de mala higiene, y no pica ni molesta al bebé. Ablandar primero es todo el truco: las escamas secas están pegadas a la piel, las engrasadas no. Rascar las zonas secas rompe la piel de debajo y abre la puerta a una infección real.",
                fr: "Les croûtes de lait proviennent de glandes sébacées hyperactives stimulées par les hormones qui circulent encore depuis la grossesse. Ce n'est donc ni une infection ni un signe de mauvaise hygiène, et elles ne démangent pas et ne dérangent pas votre bébé. L'essentiel est de ramollir d'abord : les squames sèches sont attachées à la peau, les squames huilées ne le sont pas. Cueillir les zones sèches brise la peau en dessous et ouvre la porte à une véritable infection.",
                pt: "A crosta láctea provém de glândulas sebáceas hiperativas, estimuladas por hormônios que ainda circulam desde a gravidez, portanto, não é uma infecção nem um sinal de falta de higiene e não causa coceira nem incomoda o bebê. Amolecer primeiro é o truque: as escamas secas ficam presas à pele, as escamas oleosas não. Escolher manchas secas rompe a pele por baixo e abre a porta para infecções genuínas."
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Picking or scratching off dry flakes with a fingernail.",
                    "Adult anti-dandruff shampoo.",
                    "Daily washing, which strips the scalp and can make it worse.",
                    "Assuming it means your baby is uncomfortable — it almost never is."
                ],
                ru: [
                    "Соскабливать или сдирать сухие чешуйки ногтем.",
                    "Взрослый шампунь от перхоти.",
                    "Ежедневное мытьё, которое пересушивает кожу головы и может ухудшить состояние.",
                    "Думать, что ребёнку от этого дискомфортно, — почти никогда это не так."
                ],
                de: [
                    "Trockene Schuppen mit einem Fingernagel abkratzen oder abziehen.",
                    "Erwachsenen-Anti-Schuppen-Shampoo.",
                    "Tägliches Waschen, das die Kopfhaut austrocknet und es verschlimmern kann.",
                    "Annehmen, dass sich Ihr Baby unwohl fühlt – das ist fast nie der Fall."
                ],
                es: [
                    "Arrancar o rascar las escamas secas con la uña.",
                    "Champú anticaspa de adulto.",
                    "Lavar a diario, lo que reseca el cuero cabelludo y puede empeorarlo.",
                    "Suponer que el bebé está incómodo: casi nunca lo está."
                ],
                fr: [
                    "Cueillir ou gratter les flocons secs avec un ongle.",
                    "Shampoing antipelliculaire adulte.",
                    "Un lavage quotidien, qui dépouille le cuir chevelu et peut aggraver la situation.",
                    "En supposant que cela signifie que votre bébé est mal à l’aise – ce n’est presque jamais le cas.",
                ],
                pt: [
                    "Escolher ou raspar flocos secos com a unha.",
                    "Shampoo anticaspa adulto.",
                    "Lavagem diária, que desnuda o couro cabeludo e pode piorar a situação.",
                    "Supondo que isso signifique que seu bebê está desconfortável – quase nunca está.",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "The patches spread to the face, neck or body.",
                    "Redness, weeping, swelling, or a smell — signs of infection.",
                    "Your baby scratches at the scalp or seems itchy.",
                    "It has not improved by around a year."
                ],
                ru: [
                    "Участки распространяются на лицо, шею или тело.",
                    "Покраснение, мокнутие, отёк или запах — признаки инфекции.",
                    "Ребёнок расчёсывает голову или выглядит так, будто его беспокоит зуд.",
                    "К году состояние не улучшилось."
                ],
                de: [
                    "Die Flecken breiten sich auf Gesicht, Hals oder Körper aus.",
                    "Rötung, Nässen, Schwellung oder Geruch – Zeichen einer Infektion.",
                    "Ihr Baby kratzt sich an der Kopfhaut oder scheint juckend zu sein.",
                    "Es hat sich um etwa ein Jahr nicht verbessert."
                ],
                es: [
                    "Las placas se extienden a la cara, el cuello o el cuerpo.",
                    "Enrojecimiento, supuración, hinchazón u olor: signos de infección.",
                    "El bebé se rasca el cuero cabelludo o parece tener picor.",
                    "No ha mejorado hacia el año de edad."
                ],
                fr: [
                    "Les patchs s'étendent sur le visage, le cou ou le corps.",
                    "Rougeur, pleurs, gonflement ou odeur – signes d’infection.",
                    "Votre bébé se gratte le cuir chevelu ou semble avoir des démangeaisons.",
                    "La situation ne s'est pas améliorée depuis environ un an.",
                ],
                pt: [
                    "As manchas se espalham pelo rosto, pescoço ou corpo.",
                    "Vermelhidão, choro, inchaço ou cheiro – sinais de infecção.",
                    "Seu bebê coça o couro cabeludo ou parece coçar.",
                    "Não melhorou em cerca de um ano.",
                ]
            )
        )
    ]
}
