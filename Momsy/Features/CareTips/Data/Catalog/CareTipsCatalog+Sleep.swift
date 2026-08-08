import Foundation

extension CareTipsCatalog {
    static let sleep: [CareTip] = [

        CareTip(
            id: 1101, category: .sleep, icon: "bed.double.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "The ABC of safe sleep: Alone, on the Back, in a Cot",
                ru: "Азбука безопасного сна: один, на спине, в кроватке",
                de: "Die Grundlagen sicheren Schlafs: Allein, auf dem Rücken, im Bett",
                es: "El ABC del sueño seguro: solo, boca arriba, en la cuna",
                fr: "L'ABC du sommeil en toute sécurité : seul, sur le dos, dans un lit bébé",
                pt: "O ABC do sono seguro: sozinho, de costas, em um berço",
                zh: "安全睡眠的基本知识：独自一人、仰卧在床上"
            ),
            summary: LocalizedText(
                en: "The single most protective habit of the first year, for every sleep",
                ru: "Самая защитная привычка первого года — и она нужна на каждый сон",
                de: "Die am stärksten schützende Gewohnheit des ersten Jahres für jeden Schlaf",
                es: "El hábito más protector del primer año, en cada sueño",
                fr: "L'habitude la plus protectrice de la première année, pour chaque sommeil",
                pt: "O hábito mais protetor do primeiro ano, para cada sono",
                zh: "第一年最具保护性的习惯，每次睡眠"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Alone: your baby sleeps on their own surface, with nobody and nothing else on it.",
                    "Back: on the back for every nap and every night, until they roll both ways by themselves.",
                    "Cot: a cot, crib or moses basket that meets current safety standards.",
                    "Apply it to every sleep, including short daytime naps and sleeps away from home.",
                    "Make sure everyone who ever settles your baby — partner, grandparents, nanny — follows the same three rules."
                ],
                ru: [
                    "Один: ребёнок спит на своей отдельной поверхности, где нет ни людей, ни предметов.",
                    "На спине: на спине на каждый дневной сон и на всю ночь, пока он не начнёт самостоятельно переворачиваться в обе стороны.",
                    "В кроватке: в детской кроватке, колыбели или корзине, соответствующей действующим стандартам безопасности.",
                    "Соблюдайте это на каждый сон, включая короткие дневные и сон вне дома.",
                    "Убедитесь, что все, кто когда-либо укладывает ребёнка — партнёр, бабушки и дедушки, няня, — следуют этим же трём правилам."
                ],
                de: [
                    "Allein: Ihr Baby schläft auf seiner eigenen Oberfläche, ohne jemanden oder etwas anderem darauf.",
                    "Auf dem Rücken: auf dem Rücken für jeden Schlaf Tag und jede Nacht, bis er sich selbst in beide Richtungen dreht.",
                    "Im Bett: ein Babybett, Gitterbett oder eine Wiege, die den aktuellen Sicherheitsstandards entspricht.",
                    "Wenden Sie es auf jeden Schlaf an, einschließlich kurzer Tagesschläfchen und Schläfe weg von zu Hause.",
                    "Stellen Sie sicher, dass jeder, der Ihr Baby je zu Bett bringt — Partner, Großeltern, Nanny — die gleichen drei Regeln befolgt."
                ],
                es: [
                    "Solo: el bebé duerme en su propia superficie, sin nadie ni nada más encima.",
                    "Boca arriba: boca arriba en cada siesta y cada noche, hasta que se gire solo en ambos sentidos.",
                    "En la cuna: una cuna, cuco o moisés que cumpla las normas de seguridad vigentes.",
                    "Aplícalo a todos los sueños, incluidas las siestas cortas y los sueños fuera de casa.",
                    "Asegúrate de que todo el que acueste al bebé —pareja, abuelos, canguro— siga las mismas tres reglas."
                ],
                fr: [
                    "Seul : votre bébé dort sur sa propre surface, sans personne ni rien d'autre dessus.",
                    "Dos : sur le dos à chaque sieste et chaque nuit, jusqu'à ce qu'il roule tout seul dans les deux sens.",
                    "Lit bébé : un lit bébé, un berceau ou un couffin répondant aux normes de sécurité en vigueur.",
                    "Appliquez-le à chaque sommeil, y compris les courtes siestes de jour et les nuits loin de la maison.",
                    "Assurez-vous que toutes les personnes qui installent votre bébé – partenaire, grands-parents, nounou – suivent les trois mêmes règles.",
                ],
                pt: [
                    "Sozinho: seu bebê dorme na sua própria superfície, sem ninguém e nada mais sobre ele.",
                    "Costas: nas costas a cada soneca e a cada noite, até rolarem sozinhos para os dois lados.",
                    "Berço: berço, berço ou cesto moisés que atenda às normas de segurança vigentes.",
                    "Aplique-o em todas as noites de sono, incluindo cochilos curtos durante o dia e fora de casa.",
                    "Certifique-se de que todos que cuidam do seu bebê – parceiro, avós, babá – sigam as mesmas três regras.",
                ],
                zh: [
                    "独自一人：您的宝宝睡在自己的表面上，上面没有任何人，也没有任何其他东西。",
                    "背部：每次小睡和每晚都仰卧，直到它们自己滚动。",
                    "婴儿床：符合现行安全标准的婴儿床、婴儿床或摩西篮。",
                    "将其应用于每次睡眠，包括白天短暂小睡和外出睡觉。",
                    "确保所有照顾你孩子的人——伴侣、祖父母、保姆——都遵守同样的三项规则。",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Back sleeping is the change most strongly associated with the fall in sudden infant death rates worldwide. On the back, the airway stays open and the swallowing reflex is better positioned to protect it, which is also why healthy babies do not choke when they sleep this way. The value of the rule comes from consistency: occasional exceptions, including at other people's homes, are where the risk concentrates.",
                ru: "Сон на спине — то изменение, которое сильнее всего связано со снижением частоты синдрома внезапной детской смерти во всём мире. На спине дыхательные пути остаются открытыми, а глотательный рефлекс лучше расположен для их защиты — поэтому здоровые дети в такой позе не поперхиваются. Ценность правила — в постоянстве: именно на редких исключениях, в том числе в гостях, и концентрируется риск.",
                de: "Rückenschlaf ist die Veränderung, die am stärksten mit dem Rückgang der Fälle von plötzlichem Kindstod weltweit verbunden ist. Auf dem Rücken bleiben die Atemwege offen und der Schluckreflex ist besser positioniert, um sie zu schützen — deshalb würgen gesunde Babys nicht, wenn sie auf diese Weise schlafen. Der Wert der Regel liegt in der Konsistenz: gelegentliche Ausnahmen, auch in anderen Häusern, konzentrieren das Risiko.",
                es: "Dormir boca arriba es el cambio más asociado a la caída de las tasas de muerte súbita del lactante en todo el mundo. Boca arriba, la vía aérea permanece abierta y el reflejo de deglución queda mejor situado para protegerla, y por eso los bebés sanos no se atragantan al dormir así. El valor de la regla está en la constancia: es en las excepciones ocasionales, incluidas las casas ajenas, donde se concentra el riesgo.",
                fr: "Le sommeil sur le dos est le changement le plus fortement associé à la baisse des taux de mort subite du nourrisson dans le monde. Sur le dos, les voies respiratoires restent ouvertes et le réflexe de déglutition est mieux positionné pour les protéger, c'est aussi pourquoi les bébés en bonne santé ne s'étouffent pas lorsqu'ils dorment de cette façon. La valeur de la règle vient de la cohérence : les exceptions occasionnelles, y compris au domicile d'autrui, sont là où se concentre le risque.",
                pt: "Dormir nas costas é a mudança mais fortemente associada à queda nas taxas de mortalidade infantil súbita em todo o mundo. Nas costas, a via aérea permanece aberta e o reflexo da deglutição fica melhor posicionado para protegê-la, razão pela qual bebês saudáveis ​​não engasgam quando dormem assim. O valor da regra vem da consistência: exceções ocasionais, inclusive nas casas de outras pessoas, são onde o risco se concentra.",
                zh: "仰睡是与全球婴儿猝死率下降最密切相关的变化。在背部，气道保持开放，吞咽反射可以更好地保护它，这也是为什么健康的婴儿以这种方式睡觉时不会窒息。规则的价值来自一致性：偶尔的例外情况，包括在其他人的家里，是风险集中的地方。"
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Side sleeping as a compromise — it is unstable and the baby can roll to the front.",
                    "Front sleeping for naps because the baby settles better that way.",
                    "Different rules for daytime naps than for the night.",
                    "Assuming a baby who has rolled once is ready to sleep on their front."
                ],
                ru: [
                    "Сон на боку как «компромисс» — эта поза неустойчива, и ребёнок может перевернуться на живот.",
                    "Укладывать на живот на дневной сон, потому что так ребёнок засыпает лучше.",
                    "Разные правила для дневного сна и для ночи.",
                    "Считать, что ребёнок, перевернувшийся один раз, уже готов спать на животе."
                ],
                de: [
                    "Seitenschlaf als Kompromiss — er ist instabil und das Baby kann sich nach vorne rollen.",
                    "Bauchschlag für Nickerchen, weil sich das Baby auf diese Weise besser beruhigt.",
                    "Unterschiedliche Regeln für Tagesschläfchen und Nachtschlaf.",
                    "Annahme, dass ein Baby, das sich einmal gedreht hat, bereit ist, auf dem Bauch zu schlafen."
                ],
                es: [
                    "Dormir de lado como solución intermedia: es inestable y el bebé puede girarse boca abajo.",
                    "Ponerlo boca abajo en las siestas porque así se calma mejor.",
                    "Reglas distintas para las siestas que para la noche.",
                    "Suponer que un bebé que se ha girado una vez ya puede dormir boca abajo."
                ],
                fr: [
                    "Dormir sur le côté comme compromis : il est instable et le bébé peut rouler vers l'avant.",
                    "Dormir devant pour les siestes car le bébé s'installe mieux ainsi.",
                    "Des règles différentes pour les siestes de jour et celles de nuit.",
                    "En supposant qu'un bébé qui a roulé une fois est prêt à dormir sur le ventre.",
                ],
                pt: [
                    "Dormir de lado é um compromisso – é instável e o bebê pode rolar para a frente.",
                    "Dormir de frente para cochilar porque o bebê se acomoda melhor assim.",
                    "Regras diferentes para cochilos diurnos e noturnos.",
                    "Supondo que um bebê que rolou uma vez esteja pronto para dormir de bruços.",
                ],
                zh: [
                    "侧睡是一种妥协——它不稳定，宝宝可能会滚到前面。",
                    "趴着睡小睡，因为这样宝宝会更好地安定下来。",
                    "白天小睡的规则与晚上不同。",
                    "假设已经翻滚过一次的婴儿准备好趴着睡。",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby is very unsettled on their back and has been diagnosed with reflux — ask before changing anything.",
                    "Any breathing pause, colour change, or floppiness during sleep — seek help immediately.",
                    "A health professional has advised a different position for a medical reason; follow their instruction, not this card."
                ],
                ru: [
                    "Ребёнок очень беспокоен на спине и у него диагностирован рефлюкс — спросите врача, прежде чем что-то менять.",
                    "Любая пауза в дыхании, изменение цвета кожи или вялость во время сна — немедленно обратитесь за помощью.",
                    "Врач рекомендовал другое положение по медицинским показаниям: следуйте его назначению, а не этой карточке."
                ],
                de: [
                    "Ihr Baby ist sehr unruhig auf dem Rücken und wurde mit Reflux diagnostiziert — fragen Sie, bevor Sie etwas ändern.",
                    "Jede Atempause, Farbveränderung oder Schlappe während des Schlafs — suchen Sie sofort Hilfe.",
                    "Ein Gesundheitsfachmann hat eine andere Position aus medizinischen Gründen empfohlen; folgen Sie seinen Anweisungen, nicht dieser Karte."
                ],
                es: [
                    "El bebé está muy inquieto boca arriba y tiene diagnóstico de reflujo: pregunta antes de cambiar nada.",
                    "Cualquier pausa respiratoria, cambio de color o flacidez durante el sueño: busca ayuda de inmediato.",
                    "Un profesional sanitario ha indicado otra postura por un motivo médico: sigue su indicación, no esta ficha."
                ],
                fr: [
                    "Votre bébé est très instable sur le dos et a reçu un diagnostic de reflux – renseignez-vous avant de changer quoi que ce soit.",
                    "En cas de pause respiratoire, de changement de couleur ou de souplesse pendant le sommeil, demandez immédiatement de l'aide.",
                    "Un professionnel de la santé a conseillé une position différente pour une raison médicale ; suivez leurs instructions, pas cette carte.",
                ],
                pt: [
                    "Seu bebê está muito inquieto e foi diagnosticado com refluxo – pergunte antes de mudar qualquer coisa.",
                    "Qualquer pausa respiratória, mudança de cor ou flacidez durante o sono – procure ajuda imediatamente.",
                    "Um profissional de saúde aconselhou uma posição diferente por motivos médicos; siga as instruções deles, não este cartão.",
                ],
                zh: [
                    "您的宝宝背部非常不稳定，并被诊断出患有反流——在改变任何东西之前先询问一下。",
                    "睡眠期间出现任何呼吸暂停、颜色变化或松软的情况——请立即寻求帮助。",
                    "出于医疗原因，健康专家建议采取不同的姿势；遵循他们的指示，而不是这张卡。",
                ]
            )
        ),

        CareTip(
            id: 1102, category: .sleep, icon: "checkmark.shield.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "A firm, flat, empty sleep surface",
                ru: "Твёрдая, ровная и пустая поверхность для сна",
                de: "Eine feste, flache, leere Schlaffläche",
                es: "Una superficie de sueño firme, plana y vacía",
                fr: "Une surface de sommeil ferme, plate et vide",
                pt: "Uma superfície de sono firme, plana e vazia",
                zh: "坚实、平坦、空旷的睡眠表面"
            ),
            summary: LocalizedText(
                en: "Nothing in the cot but a fitted sheet and your baby",
                ru: "В кроватке только натянутая простыня и сам ребёнок",
                de: "Nichts im Bett außer einem Spannbettuch und Ihrem Baby",
                es: "En la cuna, nada más que una sábana bajera y tu bebé",
                fr: "Rien dans le lit bébé sauf un drap housse et votre bébé",
                pt: "Nada no berço além de um lençol justo e seu bebê",
                zh: "婴儿床上只有床笠和您的宝宝"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Use a firm, flat mattress that fits the cot frame with no gaps at the edges.",
                    "Cover it with one well-fitted sheet and nothing else.",
                    "Remove pillows, duvets, loose blankets, cot bumpers, positioners, wedges and soft toys.",
                    "Use a sleeping bag or a light tucked blanket that reaches no higher than the chest, with feet at the foot of the cot.",
                    "Keep the cot away from cords, blind pulls, and anything hanging within reach."
                ],
                ru: [
                    "Используйте твёрдый ровный матрас, который точно подходит к кроватке без зазоров по краям.",
                    "Застелите его одной хорошо натянутой простынёй и больше ничем.",
                    "Уберите подушки, одеяла, свободные пледы, бортики, позиционеры, клинья и мягкие игрушки.",
                    "Используйте спальный мешок либо лёгкий подвёрнутый пледик не выше уровня груди, уложив ребёнка ножками к нижнему краю кроватки.",
                    "Держите кроватку вдали от проводов, шнуров жалюзи и всего, что свисает в пределах досягаемости."
                ],
                de: [
                    "Verwenden Sie eine feste, ebene Matratze, die ohne Spalten an den Kanten in den Bettenrahmen passt.",
                    "Bedecken Sie sie mit einem gut sitzendem Laken und nichts anderem.",
                    "Entfernen Sie Kissen, Bettdecken, lose Decken, Bettstoßfänger, Positionierer, Keile und Kuscheltiere.",
                    "Verwenden Sie einen Schlafsack oder eine leichte eingefasste Decke, die nicht höher als die Brust reicht, mit Füßen am Fuß des Betts.",
                    "Halten Sie das Bett von Kabeln, Rollowerschnüren und allem, das in Reichweite hängt, fern."
                ],
                es: [
                    "Usa un colchón firme y plano que encaje en la estructura de la cuna sin huecos en los bordes.",
                    "Cúbrelo con una sábana bajera bien ajustada y nada más.",
                    "Retira almohadas, nórdicos, mantas sueltas, protectores de cuna, posicionadores, cuñas y peluches.",
                    "Usa un saco de dormir o una manta ligera remetida que no pase del pecho, con los pies al fondo de la cuna.",
                    "Mantén la cuna lejos de cables, cordones de persiana y de cualquier cosa que cuelgue a su alcance."
                ],
                fr: [
                    "Utilisez un matelas ferme et plat qui s'adapte au cadre du lit, sans espaces sur les bords.",
                    "Couvrez-le d'un drap bien ajusté et rien d'autre.",
                    "Retirez les oreillers, les couettes, les couvertures amples, les tours de lit, les positionneurs, les cales et les peluches.",
                    "Utilisez un sac de couchage ou une couverture légère qui ne dépasse pas la poitrine et les pieds au pied du lit.",
                    "Gardez le lit à l'écart des cordons, des tirettes de store et de tout ce qui pend à portée de main.",
                ],
                pt: [
                    "Use um colchão firme e plano que caiba na estrutura do berço, sem folgas nas bordas.",
                    "Cubra-o com um lençol bem ajustado e nada mais.",
                    "Remova travesseiros, edredons, cobertores soltos, protetores de berço, posicionadores, cunhas e peluches.",
                    "Use um saco de dormir ou um cobertor leve que não ultrapasse o peito, com os pés na base do berço.",
                    "Mantenha o berço longe de cordas, puxadores de persianas e qualquer coisa pendurada ao seu alcance.",
                ],
                zh: [
                    "使用适合婴儿床框架且边缘没有间隙的坚固、平坦的床垫。",
                    "用一张合适的床单盖住它，没有其他东西。",
                    "取下枕头、羽绒被、宽松的毯子、婴儿床保险杠、定位器、楔子和毛绒玩具。",
                    "使用睡袋或轻便的毯子，高度不超过胸部，脚放在婴儿床的底部。",
                    "让婴儿床远离绳索、盲拉和任何悬挂在触手可及的地方。",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "A soft or cluttered surface can mould around the face or let a baby rebreathe their own exhaled air, and young babies cannot reliably move their head away from an obstruction. Cot bumpers and sleep positioners were designed to solve problems that a correctly sized cot does not have, and both have caused harm. The safest cot looks almost empty, which feels wrong to most parents and is exactly right.",
                ru: "Мягкая или заставленная поверхность может облепить лицо или заставить ребёнка вдыхать собственный выдохнутый воздух, а маленькие дети не могут надёжно отвернуть голову от препятствия. Бортики и позиционеры для сна придумали для решения проблем, которых у правильно подобранной кроватки нет, и и то и другое приводило к трагедиям. Самая безопасная кроватка выглядит почти пустой — большинству родителей это кажется неправильным, и это именно то, что нужно.",
                de: "Eine weiche oder vollgestellte Oberfläche kann sich um das Gesicht formen oder ein Baby dazu bringen, ihre eigene Ausatemluft wieder einzuatmen, und kleine Babys können ihren Kopf nicht zuverlässig von einem Hindernis abwenden. Bettstoßfänger und Schlafpositionierer wurden entwickelt, um Probleme zu lösen, die ein richtig großes Bett nicht hat, und beide haben Schaden verursacht. Das sicherste Bett sieht fast leer aus, was sich für die meisten Eltern falsch anfühlt und genau richtig ist.",
                es: "Una superficie blanda o llena de cosas puede amoldarse a la cara o hacer que el bebé vuelva a respirar su propio aire exhalado, y los bebés pequeños no pueden apartar la cabeza de un obstáculo de forma fiable. Los protectores y posicionadores se diseñaron para resolver problemas que una cuna del tamaño correcto no tiene, y ambos han causado daño. La cuna más segura parece casi vacía, lo que a la mayoría de los padres les resulta raro y es exactamente lo correcto.",
                fr: "Une surface molle ou encombrée peut se mouler autour du visage ou permettre au bébé de respirer son propre air expiré, et les jeunes bébés ne peuvent pas éloigner leur tête de manière fiable d'une obstruction. Les tours de lit et les positionneurs de sommeil ont été conçus pour résoudre des problèmes qu'un lit de bébé de taille correcte ne présente pas, et tous deux ont causé des dommages. Le lit de bébé le plus sûr semble presque vide, ce qui ne convient pas à la plupart des parents et qui est tout à fait correct.",
                pt: "Uma superfície macia ou desordenada pode moldar-se ao redor do rosto ou permitir que o bebê respire novamente o próprio ar exalado, e os bebês pequenos não conseguem mover a cabeça de forma confiável para longe de uma obstrução. Os protetores de berço e os posicionadores de dormir foram projetados para resolver problemas que um berço de tamanho correto não tem, e ambos causaram danos. O berço mais seguro parece quase vazio, o que parece errado para a maioria dos pais e é exatamente certo.",
                zh: "柔软或杂乱的表面可能会在脸部周围形成霉菌，或者让婴儿重新呼吸自己呼出的空气，并且年幼的婴儿无法可靠地将头部移开障碍物。婴儿床保险杠和睡眠定位器旨在解决尺寸正确的婴儿床所没有的问题，但两者都会造成伤害。最安全的婴儿床看起来几乎是空的，这对大多数父母来说是错误的，但实际上却是正确的。"
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Adding a comforter or muslin 'just for naps'.",
                    "A mattress topper or extra padding for comfort.",
                    "A duvet or pillow in the first year.",
                    "Letting the baby sleep on a sofa, armchair or beanbag with an adult."
                ],
                ru: [
                    "Добавлять игрушку-комфортер или пелёнку «только на дневной сон».",
                    "Класть наматрасник или дополнительную подкладку «для удобства».",
                    "Одеяло или подушка на первом году жизни.",
                    "Давать ребёнку спать на диване, в кресле или на бескаркасном пуфе вместе со взрослым."
                ],
                de: [
                    "Ein Trostspielzeug oder Musselin \"nur zu Nickerchen\" hinzufügen.",
                    "Eine Matratzenauflage oder zusätzliche Polsterung zum Komfort.",
                    "Eine Bettdecke oder ein Kissen im ersten Jahr.",
                    "Lassen Sie das Baby mit einem Erwachsenen auf einem Sofa, Sessel oder Sitzsack schlafen."
                ],
                es: [
                    "Añadir un doudou o una muselina «solo para las siestas».",
                    "Un cubrecolchón o acolchado extra por comodidad.",
                    "Un nórdico o una almohada durante el primer año.",
                    "Dejar que el bebé duerma con un adulto en el sofá, un sillón o un puf."
                ],
                fr: [
                    "Ajout d'un doudou ou d'une mousseline « juste pour les siestes ».",
                    "Un surmatelas ou un rembourrage supplémentaire pour plus de confort.",
                    "Une couette ou un oreiller la première année.",
                    "Laisser bébé dormir sur un canapé, un fauteuil ou un pouf avec un adulte.",
                ],
                pt: [
                    "Adicionando um edredom ou musselina 'só para cochilar'.",
                    "Um protetor de colchão ou acolchoamento extra para maior conforto.",
                    "Um edredom ou travesseiro no primeiro ano.",
                    "Deixar o bebê dormir em sofá, poltrona ou pufe com um adulto.",
                ],
                zh: [
                    "添加被子或平纹细布“只是为了小睡”。",
                    "床垫或额外的衬垫以增加舒适度。",
                    "第一年的羽绒被或枕头。",
                    "让宝宝与成人一起睡在沙发、扶手椅或懒人沙发上。",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby cannot settle at all on a firm flat surface after the newborn weeks.",
                    "Reflux is severe enough that you are considering a wedge or an incline — ask first.",
                    "You find your baby with bedding over the face, even once."
                ],
                ru: [
                    "После периода новорождённости ребёнок совсем не может уснуть на твёрдой ровной поверхности.",
                    "Рефлюкс настолько выражен, что вы думаете о клине или наклоне — сначала спросите врача.",
                    "Вы обнаружили ребёнка с постельным бельём на лице, даже однократно."
                ],
                de: [
                    "Ihr Baby kann sich nach den Neugeborenenwochen überhaupt nicht auf einer festen, flachen Oberfläche beruhigen.",
                    "Der Reflux ist so schwerwiegend, dass Sie einen Keil oder eine Neigung in Betracht ziehen — fragen Sie zuerst.",
                    "Sie finden Ihr Baby mit Bettwäsche über dem Gesicht, auch nur einmal."
                ],
                es: [
                    "Pasadas las primeras semanas, el bebé no consigue dormirse en absoluto sobre una superficie firme y plana.",
                    "El reflujo es tan intenso que estás pensando en una cuña o una inclinación: pregunta antes.",
                    "Encuentras al bebé con la ropa de cama sobre la cara, aunque sea una sola vez."
                ],
                fr: [
                    "Votre bébé ne peut pas du tout s'installer sur une surface plane et ferme après les semaines du nouveau-né.",
                    "Le reflux est suffisamment grave pour que vous envisagiez un coin ou une pente – demandez d’abord.",
                    "Vous trouvez votre bébé avec une literie sur le visage, même une fois.",
                ],
                pt: [
                    "Seu bebê não consegue se acomodar em uma superfície plana e firme após as semanas do recém-nascido.",
                    "O refluxo é grave o suficiente para que você considere uma cunha ou inclinação – pergunte primeiro.",
                    "Você encontra seu bebê com roupa de cama cobrindo o rosto, pelo menos uma vez.",
                ],
                zh: [
                    "新生儿几周后，您的宝宝根本无法在坚硬的平坦表面上安定下来。",
                    "回流非常严重，以至于您正在考虑使用楔子或斜坡——请先询问。",
                    "你会发现你的宝宝脸上盖着被褥，哪怕只有一次。",
                ]
            )
        ),

        CareTip(
            id: 1103, category: .sleep, icon: "house.fill", ageFrom: 0, ageTo: 6,
            title: LocalizedText(
                en: "Share a room, not a bed, for the first six months",
                ru: "Первые шесть месяцев — одна комната, но не одна кровать",
                de: "Teilen Sie ein Zimmer, aber kein Bett, für die ersten sechs Monate",
                es: "Compartid habitación, no cama, los primeros seis meses",
                fr: "Partagez une chambre, pas un lit, pendant les six premiers mois",
                pt: "Divida um quarto, não uma cama, durante os primeiros seis meses",
                zh: "前六个月共用一个房间，而不是一张床"
            ),
            summary: LocalizedText(
                en: "Same room, separate surface — close enough to hear, safe enough to sleep",
                ru: "Та же комната, отдельная поверхность: достаточно близко, чтобы слышать, и достаточно безопасно, чтобы спать",
                de: "Gleiches Zimmer, separate Oberfläche — nah genug zum Hören, sicher genug zum Schlafen",
                es: "Misma habitación, superficie separada: lo suficientemente cerca para oír, lo suficientemente seguro para dormir",
                fr: "Même pièce, surface séparée – suffisamment proche pour entendre, suffisamment en sécurité pour dormir",
                pt: "Mesmo quarto, superfície separada – perto o suficiente para ouvir, seguro o suficiente para dormir",
                zh: "同一个房间，不同的表面——距离足够近，可以听到声音，足够安全，可以睡觉"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Place the cot, crib or bedside sleeper within arm's reach of your bed.",
                    "Keep this arrangement for at least the first six months, including naps if you are in the room.",
                    "Feed in bed if you need to, but move your baby back to their own surface before you sleep.",
                    "If you might fall asleep while feeding, clear the bed of pillows and duvets first as a precaution.",
                    "Never sleep with your baby on a sofa or armchair — this carries a much higher risk than a bed."
                ],
                ru: [
                    "Поставьте кроватку, колыбель или приставную кроватку на расстоянии вытянутой руки от своей постели.",
                    "Сохраняйте такую расстановку минимум первые шесть месяцев, в том числе на дневной сон, если вы в комнате.",
                    "Кормите в постели, если так нужно, но переложите ребёнка на его поверхность, прежде чем сами уснёте.",
                    "Если есть риск, что вы уснёте во время кормления, заранее уберите с постели подушки и одеяла.",
                    "Никогда не засыпайте с ребёнком на диване или в кресле — это гораздо опаснее, чем кровать."
                ],
                de: [
                    "Platzieren Sie das Bett, Gitterbett oder die Bettseitenschläfer in Reichweite Ihres Bettes.",
                    "Halten Sie diese Anordnung mindestens sechs Monate lang, einschließlich Nickerchen, wenn Sie im Zimmer sind.",
                    "Stillen Sie im Bett, wenn nötig, aber legen Sie Ihr Baby vor dem Schlaf zurück auf seine Oberfläche.",
                    "Wenn Sie während des Stillen einschlafen könnten, leeren Sie das Bett zuerst von Kissen und Bettdecken als Vorsichtsmaßnahme.",
                    "Schlafen Sie niemals mit Ihrem Baby auf einem Sofa oder Sessel — dies ist mit einem Bett viel riskanter."
                ],
                es: [
                    "Coloque la cuna, cuna o cama junto a la cama al alcance de la mano de su cama.",
                    "Mantenga este arreglo durante al menos los primeros seis meses, incluidas las siestas si está en la habitación.",
                    "Aliméntelo en la cama si es necesario, pero lleve a su bebé a su propia superficie antes de dormir.",
                    "Si puede quedarse dormido mientras alimenta, primero limpie la cama de almohadas y edredones como medida de precaución.",
                    "Nunca duerma con su bebé en un sofá o sillón; esto conlleva un riesgo mucho mayor que una cama.",
                ],
                fr: [
                    "Placez le lit de bébé, le berceau ou le lit de chevet à portée de main de votre lit.",
                    "Conservez cet arrangement pendant au moins les six premiers mois, y compris les siestes si vous êtes dans la pièce.",
                    "Nourrissez-le au lit si vous en avez besoin, mais ramenez votre bébé sur sa propre surface avant de dormir.",
                    "Si vous risquez de vous endormir pendant le repas, débarrassez d'abord le lit des oreillers et des couettes par mesure de précaution.",
                    "Ne dormez jamais avec votre bébé sur un canapé ou un fauteuil : cela comporte un risque beaucoup plus élevé que dans un lit.",
                ],
                pt: [
                    "Coloque o berço, berço ou cama de cabeceira ao alcance do braço da cama.",
                    "Mantenha esse arranjo pelo menos nos primeiros seis meses, incluindo cochilos se você estiver no quarto.",
                    "Alimente-o na cama, se necessário, mas coloque o bebê de volta na superfície antes de dormir.",
                    "Se você adormecer durante a alimentação, limpe primeiro os travesseiros e edredons da cama, por precaução.",
                    "Nunca durma com seu bebê em um sofá ou poltrona – isso representa um risco muito maior do que em uma cama.",
                ],
                zh: [
                    "将婴儿床、婴儿床或床边睡床放在床伸手可及的范围内。",
                    "至少在前六个月保持这种安排，如果您在房间里，包括小睡。",
                    "如果需要，可以在床上喂奶，但在睡觉前将宝宝移回自己的表面。",
                    "如果您可能在喂奶时睡着，请先清理床上的枕头和羽绒被，以防万一。",
                    "切勿让宝宝睡在沙发或扶手椅上——这比睡在床上的风险要高得多。",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Room-sharing is associated with a lower risk of sudden infant death, and it makes night feeds far less exhausting because nobody has to cross the house. Bed-sharing is a different thing: adult bedding, mattress softness and the presence of another body change the picture. Separating the two ideas lets you keep the benefit of closeness without the associated risk.",
                ru: "Сон в одной комнате связан с более низким риском синдрома внезапной детской смерти, и он делает ночные кормления заметно менее изматывающими, потому что не нужно ходить через всю квартиру. Совместный сон в одной кровати — это другое: взрослое постельное бельё, мягкость матраса и присутствие другого тела меняют картину. Разделение этих двух понятий позволяет сохранить пользу близости без связанного с ней риска.",
                de: "Das Teilen eines Zimmers ist mit einem niedrigeren Risiko für plötzlichen Kindstod verbunden, und es macht nächtliche Fütterungen viel weniger anstrengend, da niemand das Haus durchqueren muss. Bettteilen ist etwas anderes: Erwachsenenbettwäsche, Matratzenzartheit und die Anwesenheit eines anderen Körpers ändern das Bild. Durch die Trennung dieser beiden Ideen können Sie den Vorteil der Nähe ohne das damit verbundene Risiko beibehalten.",
                es: "Compartir habitación se asocia con un menor riesgo de muerte súbita infantil y hace que las tomas nocturnas sean mucho menos agotadoras porque nadie tiene que cruzar la casa. Compartir la cama es otra cosa: la ropa de cama de los adultos, la suavidad del colchón y la presencia de otro cuerpo cambian el panorama. Separar las dos ideas le permite conservar el beneficio de la cercanía sin el riesgo asociado.",
                fr: "Le partage de la chambre est associé à un risque plus faible de mort subite du nourrisson et rend les tétées nocturnes beaucoup moins épuisantes car personne n'a à traverser la maison. Le partage du lit est une autre chose : la literie adulte, la douceur du matelas et la présence d’un autre corps changent la donne. Séparer les deux idées permet de conserver le bénéfice de la proximité sans le risque associé.",
                pt: "Compartilhar o quarto está associado a um menor risco de morte súbita do bebê e torna as mamadas noturnas muito menos cansativas porque ninguém precisa atravessar a casa. Compartilhar a cama é outra coisa: a roupa de cama dos adultos, a maciez do colchão e a presença de outro corpo mudam o quadro. Separar as duas ideias permite manter o benefício da proximidade sem o risco associado.",
                zh: "共用房间可以降低婴儿猝死的风险，而且由于没有人需要穿过房子，所以夜间喂奶的疲劳程度大大降低。共用床是另一回事：成人床上用品、床垫的柔软度以及另一个身体的存在会改变情况。将这两个想法分开可以让您保持亲密关系的好处，而无需承担相关的风险。"
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Moving the baby to their own room early because they seem noisy sleepers.",
                    "Falling asleep on the sofa during night feeds.",
                    "Bed-sharing after alcohol, sedating medication, or extreme exhaustion.",
                    "A bedside sleeper that is not securely fixed, leaving a gap against the adult mattress."
                ],
                ru: [
                    "Рано переселять ребёнка в отдельную комнату из-за того, что он «шумно спит».",
                    "Засыпать на диване во время ночных кормлений.",
                    "Спать с ребёнком в одной кровати после алкоголя, успокоительных препаратов или при крайнем истощении.",
                    "Ненадёжно закреплённая приставная кроватка, из-за которой остаётся щель у взрослого матраса."
                ],
                de: [
                    "Verschieben Sie das Baby früh in sein eigenes Zimmer, weil es laut schläft.",
                    "Während der Nachtfütterung auf dem Sofa einschlafen.",
                    "Bettteilen nach Alkohol, beruhigenden Medikamenten oder extremer Erschöpfung.",
                    "Ein nicht sicher befestigter Bettseitenschläfer, der eine Lücke gegen die Erwachsenenmatratze hinterlässt."
                ],
                es: [
                    "Llevar al bebé a su habitación temprano porque parece que duermen ruidosamente.",
                    "Dormirse en el sofá durante las tomas nocturnas.",
                    "Compartir la cama después del consumo de alcohol, medicamentos sedantes o agotamiento extremo.",
                    "Una cama junto a la cama que no está bien fijada, dejando un espacio contra el colchón de adultos.",
                ],
                fr: [
                    "Déplacer le bébé dans sa propre chambre plus tôt car il semble dormir bruyant.",
                    "S'endormir sur le canapé pendant les tétées nocturnes.",
                    "Partage du lit après avoir consommé de l'alcool, pris des sédatifs ou été extrêmement épuisé.",
                    "Un dormeur de chevet qui n'est pas solidement fixé, laissant un espace contre le matelas adulte.",
                ],
                pt: [
                    "Mover o bebê para seu próprio quarto mais cedo porque eles parecem ter sono barulhento.",
                    "Adormecer no sofá durante as mamadas noturnas.",
                    "Compartilhar a cama após álcool, medicação sedativa ou exaustão extrema.",
                    "Uma cama de cabeceira que não está bem fixada, deixando um espaço no colchão do adulto.",
                ],
                zh: [
                    "尽早将婴儿转移到自己的房间，因为他们看起来睡得很吵。",
                    "晚上吃奶的时候在沙发上睡着了。",
                    "饮酒、服用镇静药物或极度疲惫后同床共枕。",
                    "未牢固固定的床边睡枕，与成人床垫留有间隙。",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby was premature or had a low birth weight — ask about additional precautions.",
                    "You find yourself repeatedly falling asleep while feeding — say so; there are safer arrangements.",
                    "Snoring, pauses in breathing, or noisy laboured breathing during sleep."
                ],
                ru: [
                    "Ребёнок родился раньше срока или с низким весом — спросите о дополнительных мерах предосторожности.",
                    "Вы регулярно засыпаете во время кормления — скажите об этом: есть более безопасные варианты.",
                    "Храп, паузы в дыхании или шумное затруднённое дыхание во сне."
                ],
                de: [
                    "Ihr Baby war verfrüht oder hatte niedriges Geburtsgewicht — fragen Sie nach zusätzlichen Vorsichtsmaßnahmen.",
                    "Sie schlafen wiederholt während des Stillens ein — sagen Sie es; es gibt sicherere Anordnungen.",
                    "Schnarchen, Atempausen oder angestrengtes Atmen während des Schlafs."
                ],
                es: [
                    "Su bebé fue prematuro o tuvo bajo peso al nacer; pregunte sobre precauciones adicionales.",
                    "Te encuentras quedándote dormido repetidamente mientras te alimentas; díselo; hay arreglos más seguros.",
                    "Ronquidos, pausas en la respiración o respiración ruidosa y dificultosa durante el sueño.",
                ],
                fr: [
                    "Votre bébé était prématuré ou avait un faible poids à la naissance – renseignez-vous sur les précautions supplémentaires.",
                    "Vous vous endormez à plusieurs reprises pendant que vous vous nourrissez – dites-le ; il existe des arrangements plus sûrs.",
                    "Ronflement, pauses respiratoires ou respiration bruyante et difficile pendant le sommeil.",
                ],
                pt: [
                    "Seu bebê foi prematuro ou teve baixo peso ao nascer – pergunte sobre precauções adicionais.",
                    "Você adormece repetidamente enquanto se alimenta - diga isso; existem arranjos mais seguros.",
                    "Ronco, pausas na respiração ou respiração ruidosa e difícil durante o sono.",
                ],
                zh: [
                    "您的宝宝早产或出生体重过低——询问额外的预防措施。",
                    "您发现自己在喂奶时反复睡着——请这么说；有更安全的安排。",
                    "睡眠期间打鼾、呼吸暂停或呼吸困难。",
                ]
            )
        ),

        CareTip(
            id: 1104, category: .sleep, icon: "thermometer.medium", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Room temperature and how to dress for sleep",
                ru: "Температура в комнате и как одевать на сон",
                de: "Raumtemperatur und wie man zum Schlafen anzieht",
                es: "Temperatura ambiente y cómo vestirse para dormir.",
                fr: "Température ambiante et comment s'habiller pour dormir",
                pt: "Temperatura ambiente e como se vestir para dormir",
                zh: "室温和睡觉时如何着装"
            ),
            summary: LocalizedText(
                en: "Aim for 18–21 °C and check the chest, not the hands",
                ru: "Ориентир — 18–21 °C, проверяйте грудь, а не ручки",
                de: "Streben Sie 18–21 °C an und überprüfen Sie die Brust, nicht die Hände",
                es: "Apunte a una temperatura de 18 a 21 °C y revise el pecho, no las manos.",
                fr: "Visez une température de 18 à 21 °C et vérifiez la poitrine, pas les mains",
                pt: "Apontar para 18–21 °C e verificar o peito, não as mãos",
                zh: "目标温度为 18–21 °C，检查胸部，而不是手"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Keep the sleep room between about 18 and 21 °C where you can.",
                    "Dress your baby in one more layer than you are comfortable in, counting the sleeping bag as a layer.",
                    "Check temperature by slipping two fingers onto the chest or the back of the neck.",
                    "Use a lighter sleeping bag in summer and a warmer one in winter rather than adding loose blankets.",
                    "Remove hats and hoods indoors — babies release heat through the head."
                ],
                ru: [
                    "По возможности держите в комнате для сна примерно от 18 до 21 °C.",
                    "Одевайте ребёнка на один слой теплее, чем комфортно вам, считая спальный мешок за слой.",
                    "Проверяйте температуру, просунув два пальца на грудь или заднюю поверхность шеи.",
                    "Летом берите более тонкий спальный мешок, зимой — более тёплый, вместо того чтобы добавлять свободные пледы.",
                    "Дома снимайте шапочки и капюшоны — дети отдают тепло через голову."
                ],
                de: [
                    "Halten Sie den Schlafraum nach Möglichkeit zwischen etwa 18 und 21 °C.",
                    "Ziehen Sie Ihr Baby eine Schicht wärmer an als Sie es bequem haben, zählen Sie den Schlafsack als eine Schicht.",
                    "Überprüfen Sie die Temperatur, indem Sie zwei Finger auf die Brust oder die Rückseite des Halses schieben.",
                    "Verwenden Sie im Sommer einen leichteren Schlafsack und im Winter einen wärmeren, anstatt lose Decken hinzuzufügen.",
                    "Entfernen Sie Hüte und Kapuzen in Innenräumen — Babys geben Wärme über den Kopf ab."
                ],
                es: [
                    "Mantenga la habitación para dormir entre 18 y 21 °C aproximadamente, siempre que pueda.",
                    "Vista a su bebé con una capa más de la que usted se sienta cómoda, contando el saco de dormir como una capa.",
                    "Compruebe la temperatura deslizando dos dedos sobre el pecho o la nuca.",
                    "Utilice un saco de dormir más ligero en verano y uno más cálido en invierno en lugar de añadir mantas sueltas.",
                    "Quítese los sombreros y capuchas en el interior: los bebés liberan calor a través de la cabeza.",
                ],
                fr: [
                    "Gardez la chambre à coucher entre 18 et 21 °C environ lorsque vous le pouvez.",
                    "Habillez votre bébé avec une couche de plus que celle dans laquelle vous êtes à l'aise, en comptant la gigoteuse comme une couche.",
                    "Vérifiez la température en glissant deux doigts sur la poitrine ou sur la nuque.",
                    "Utilisez un sac de couchage plus léger en été et plus chaud en hiver plutôt que d'ajouter des couvertures amples.",
                    "Retirez les chapeaux et les cagoules à l’intérieur : les bébés dégagent de la chaleur par la tête.",
                ],
                pt: [
                    "Mantenha o quarto de dormir entre 18 e 21 °C sempre que possível.",
                    "Vista seu bebê com uma camada a mais do que você se sente confortável, contando o saco de dormir como uma camada.",
                    "Verifique a temperatura deslizando dois dedos no peito ou na nuca.",
                    "Use um saco de dormir mais leve no verão e um mais quente no inverno, em vez de adicionar cobertores soltos.",
                    "Remova chapéus e capuzes dentro de casa – os bebês liberam calor pela cabeça.",
                ],
                zh: [
                    "尽可能将睡眠房间的温度保持在 18 至 21 °C 左右。",
                    "给宝宝穿比你舒服的多一层的衣服，将睡袋算作一层。",
                    "将两根手指滑到胸部或颈后检查温度。",
                    "夏天使用较轻的睡袋，冬天使用较暖的睡袋，而不是添加宽松的毯子。",
                    "在室内摘掉帽子和头巾——婴儿通过头部释放热量。",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Overheating is a recognised risk factor for sudden infant death, and babies cannot take off a layer or push away a blanket the way an adult can. Cool hands and feet are normal for months and are a poor guide, because circulation to the extremities is still developing. The chest tells you the truth: it should feel warm and dry, never hot or clammy.",
                ru: "Перегрев — признанный фактор риска синдрома внезапной детской смерти, а ребёнок не может снять слой одежды или отбросить одеяло, как взрослый. Прохладные ручки и ножки нормальны в течение месяцев и плохо подходят как ориентир, потому что кровообращение в конечностях ещё формируется. Правду говорит грудь: она должна быть тёплой и сухой, но не горячей и не влажной.",
                de: "Überhitzung ist ein anerkannter Risikofaktor für den plötzlichen Kindstod, und Babys können eine Schicht nicht ausziehen oder eine Decke nicht wie ein Erwachsener abschieben. Kühle Hände und Füße sind für Monate normal und ein schlechter Leitfaden, da die Durchblutung der Gliedmaßen noch entwickelt wird. Die Brust sagt dir die Wahrheit: Sie sollte sich warm und trocken anfühlen, nie heiß oder feucht.",
                es: "El sobrecalentamiento es un factor de riesgo reconocido de muerte súbita infantil, y los bebés no pueden quitarse una capa ni apartar una manta como lo hace un adulto. Las manos y los pies fríos son normales durante meses y no son una buena guía, porque la circulación en las extremidades aún se está desarrollando. El pecho te dice la verdad: debe sentirse cálido y seco, nunca caliente ni húmedo.",
                fr: "La surchauffe est un facteur de risque reconnu de mort subite du nourrisson, et les bébés ne peuvent pas enlever une couche ou repousser une couverture comme le fait un adulte. Des mains et des pieds frais sont normaux pendant des mois et ne constituent pas un bon indicateur, car la circulation vers les extrémités est encore en développement. La poitrine vous dit la vérité : elle doit être chaude et sèche, jamais chaude ou moite.",
                pt: "O superaquecimento é um fator de risco reconhecido para morte súbita infantil, e os bebês não conseguem tirar uma camada ou afastar um cobertor como um adulto. Mãos e pés frios são normais durante meses e são um mau guia, porque a circulação nas extremidades ainda está em desenvolvimento. O peito diz a verdade: deve estar quente e seco, nunca quente ou úmido.",
                zh: "过热是婴儿猝死的公认危险因素，婴儿无法像成人那样脱掉衣服或推开毯子。手脚冰凉几个月是正常现象，但并不能起到指导作用，因为四肢的血液循环仍在发展中。胸部告诉你真相：它应该感觉温暖干燥，绝不是热的或湿冷的。"
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Adding layers because the hands feel cold.",
                    "Leaving a hat on for indoor sleep.",
                    "A hot water bottle or electric blanket in the cot.",
                    "Placing the cot next to a radiator or in direct sunlight."
                ],
                ru: [
                    "Добавлять слои одежды из-за того, что ручки холодные.",
                    "Оставлять шапочку на время сна дома.",
                    "Грелка или электрическое одеяло в кроватке.",
                    "Ставить кроватку у радиатора или под прямыми солнечными лучами."
                ],
                de: [
                    "Schichten hinzufügen, weil die Hände kalt sind.",
                    "Einen Hut für den Schlaf in Innenräumen anlassen.",
                    "Eine Wärmflasche oder eine elektrische Decke im Bett.",
                    "Das Bett neben einem Heizkörper oder in direktem Sonnenlicht platzieren."
                ],
                es: [
                    "Agregar capas porque las manos se sienten frías.",
                    "Dejar un sombrero puesto para dormir en el interior.",
                    "Una bolsa de agua caliente o manta eléctrica en la cuna.",
                    "Colocar la cuna junto a un radiador o bajo la luz solar directa.",
                ],
                fr: [
                    "Ajouter des couches parce que les mains sont froides.",
                    "Laisser un chapeau pour dormir à l’intérieur.",
                    "Une bouillotte ou une couverture chauffante dans le lit bébé.",
                    "Placer le lit à côté d'un radiateur ou en plein soleil.",
                ],
                pt: [
                    "Adicionando camadas porque as mãos ficam frias.",
                    "Deixar um chapéu para dormir dentro de casa.",
                    "Bolsa de água quente ou cobertor elétrico no berço.",
                    "Colocar o berço próximo a um radiador ou sob luz solar direta.",
                ],
                zh: [
                    "增加层数是因为手感觉冷。",
                    "室内睡觉时请戴上帽子。",
                    "婴儿床上有热水瓶或电热毯。",
                    "将婴儿床放在散热器旁边或阳光直射的地方。",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby is sweating, flushed, or breathing rapidly during sleep.",
                    "The chest feels hot and clammy even after removing a layer.",
                    "A fever appears alongside unusual drowsiness or refusal to feed."
                ],
                ru: [
                    "Ребёнок потеет, у него покраснело лицо или учащённое дыхание во сне.",
                    "Грудь горячая и влажная даже после того, как вы сняли один слой одежды.",
                    "Появилась температура вместе с необычной сонливостью или отказом от еды."
                ],
                de: [
                    "Ihr Baby schwitzt, ist gerötet oder atmet während des Schlafs schnell.",
                    "Die Brust fühlt sich selbst nach dem Entfernen einer Schicht heiß und feucht an.",
                    "Ein Fieber tritt zusammen mit ungewöhnlicher Schläfrigkeit oder Fütterungsverweigerung auf."
                ],
                es: [
                    "Su bebé suda, se sonroja o respira rápidamente mientras duerme.",
                    "El pecho se siente caliente y húmedo incluso después de quitar una capa.",
                    "La fiebre aparece junto con una somnolencia inusual o la negativa a alimentarse.",
                ],
                fr: [
                    "Votre bébé transpire, rougit ou respire rapidement pendant son sommeil.",
                    "La poitrine est chaude et moite même après avoir retiré une couche.",
                    "Une fièvre apparaît accompagnée d'une somnolence inhabituelle ou d'un refus de s'alimenter.",
                ],
                pt: [
                    "Seu bebê está suando, corado ou respirando rapidamente durante o sono.",
                    "O peito fica quente e úmido mesmo depois de remover uma camada.",
                    "A febre aparece juntamente com uma sonolência incomum ou recusa em alimentar-se.",
                ],
                zh: [
                    "您的宝宝在睡眠期间出汗、脸红或呼吸急促。",
                    "即使脱掉一层后，胸部仍感觉又热又湿。",
                    "发烧伴随着异常嗜睡或拒绝进食。",
                ]
            )
        ),

        CareTip(
            id: 1105, category: .sleep, icon: "moon.fill", ageFrom: 0, ageTo: 4,
            title: LocalizedText(
                en: "Swaddling — and stopping at the first sign of rolling",
                ru: "Пеленание — и отказ от него при первых переворотах",
                de: "Pucken — und beim ersten Anzeichen des Rollens stoppen",
                es: "Envolverlo y detenerse a la primera señal de que está rodando",
                fr: "Emmailloter – et s’arrêter au premier signe de roulage",
                pt: "Enfaixando – e parando ao primeiro sinal de rolar",
                zh: "襁褓——一有滚动迹象就停止"
            ),
            summary: LocalizedText(
                en: "Snug at the arms, loose at the hips, and finished before rolling starts",
                ru: "Плотно у ручек, свободно в бёдрах и закончить до начала переворотов",
                de: "Fest an den Armen, locker an den Hüften, und beendet bevor das Rollen beginnt",
                es: "Ajustado en los brazos, suelto en las caderas y terminado antes de que comience a rodar.",
                fr: "Bien ajusté au niveau des bras, ample au niveau des hanches et terminé avant le début du roulage",
                pt: "Aconchegante nos braços, solto nos quadris e finalizado antes de começar a rolar",
                zh: "手臂紧贴，臀部宽松，在滚动开始前完成"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Use a thin breathable fabric or a purpose-made swaddle, never a heavy blanket.",
                    "Keep it firm across the chest but loose enough to slide two fingers under the top edge.",
                    "Leave plenty of room at the hips so the legs can bend up and out.",
                    "Always place a swaddled baby on their back, never on the side or front.",
                    "Stop swaddling completely at the first sign of rolling — usually somewhere between two and four months. Move to a sleeping bag with arms free."
                ],
                ru: [
                    "Используйте тонкую дышащую ткань или специальный конверт для пеленания, но не плотное одеяло.",
                    "Пеленайте плотно на уровне груди, но так, чтобы под верхний край проходили два пальца.",
                    "Оставляйте достаточно места в бёдрах, чтобы ножки могли сгибаться и разводиться.",
                    "Запелёнатого ребёнка всегда кладите на спину, никогда на бок или на живот.",
                    "Полностью прекратите пеленание при первых признаках переворотов — обычно между двумя и четырьмя месяцами. Перейдите на спальный мешок со свободными руками."
                ],
                de: [
                    "Verwenden Sie ein dünnes atmungsaktives Tuch oder ein speziell angefertigtes Pucktuch, niemals eine schwere Decke.",
                    "Halten Sie es straff an der Brust, aber locker genug, um zwei Finger unter die obere Kante zu schieben.",
                    "Lassen Sie viel Platz an den Hüften, damit die Beine sich nach oben und außen beugen können.",
                    "Legen Sie ein gepucktes Baby immer auf den Rücken, nie auf die Seite oder den Bauch.",
                    "Hören Sie beim ersten Anzeichen des Rollens vollständig auf zu pucken — normalerweise irgendwann zwischen zwei und vier Monaten. Wechseln Sie zu einem Schlafsack mit freien Armen."
                ],
                es: [
                    "Utilice una tela fina y transpirable o un arrullo especialmente diseñado, nunca una manta pesada.",
                    "Manténgalo firme a lo largo del pecho pero lo suficientemente suelto como para deslizar dos dedos debajo del borde superior.",
                    "Deje suficiente espacio en las caderas para que las piernas puedan doblarse hacia arriba y hacia afuera.",
                    "Coloque siempre al bebé envuelto boca arriba, nunca de lado o de frente.",
                    "Deje de envolverlo por completo a la primera señal de que está rodando, generalmente entre dos y cuatro meses. Pasar a un saco de dormir con los brazos libres.",
                ],
                fr: [
                    "Utilisez un tissu fin et respirant ou un emmaillotage spécialement conçu, jamais une couverture lourde.",
                    "Gardez-le ferme sur la poitrine mais suffisamment lâche pour glisser deux doigts sous le bord supérieur.",
                    "Laissez suffisamment d’espace au niveau des hanches pour que les jambes puissent se plier et s’étendre.",
                    "Placez toujours un bébé emmailloté sur le dos, jamais sur le côté ou sur le devant.",
                    "Arrêtez complètement d’emmailloter dès les premiers signes de roulage – généralement entre deux et quatre mois. Déplacez-vous vers un sac de couchage avec les bras libres.",
                ],
                pt: [
                    "Use um tecido fino e respirável ou um pano feito sob medida, nunca um cobertor pesado.",
                    "Mantenha-o firme no peito, mas solto o suficiente para deslizar dois dedos sob a borda superior.",
                    "Deixe bastante espaço nos quadris para que as pernas possam dobrar para cima e para fora.",
                    "Sempre coloque o bebê enfaixado de costas, nunca de lado ou de frente.",
                    "Pare de enfaixar completamente ao primeiro sinal de rolar – geralmente entre dois e quatro meses. Vá para um saco de dormir com os braços livres.",
                ],
                zh: [
                    "使用薄的透气织物或特制的襁褓，切勿使用厚重的毯子。",
                    "保持胸部牢固，但足够宽松，可以将两根手指滑到顶部边缘下方。",
                    "在臀部留出足够的空间，以便腿部可以向上和向外弯曲。",
                    "始终将襁褓中的婴儿仰卧，切勿侧卧或正面。",
                    "一旦出现滚动迹象，就停止完全用襁褓——通常在两到四个月之间。转移到睡袋上，双臂自由。",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Swaddling dampens the startle reflex that wakes newborns from light sleep, which is why it often buys everyone a longer stretch. The danger point is rolling: a swaddled baby who turns onto their front cannot use their arms to lift or turn their head. Hip room matters too, because tightly straightened legs can interfere with normal hip development in the early months.",
                ru: "Пеленание сглаживает рефлекс вздрагивания, который будит новорождённого из поверхностного сна, — поэтому оно часто даёт всем более длинный отрезок сна. Опасный момент — перевороты: запелёнатый ребёнок, оказавшийся на животе, не может опереться руками, чтобы поднять или повернуть голову. Свобода в бёдрах тоже важна: туго выпрямленные ножки могут нарушить нормальное развитие тазобедренных суставов в первые месяцы.",
                de: "Pucken dämpft den Schreckreflex, der Neugeborene aus dem leichten Schlaf weckt, weshalb es oft allen eine längere Strecke bringt. Der Gefahrenpunkt ist das Rollen: Ein gepucktes Baby, das sich auf den Bauch dreht, kann seine Arme nicht benutzen, um seinen Kopf zu heben oder zu drehen. Der Platz an den Hüften ist auch wichtig, da eng gerade Beine die normale Entwicklung der Hüften in den frühen Monaten beeinträchtigen können.",
                es: "Envolverlo amortigua el reflejo de sobresalto que despierta a los recién nacidos del sueño ligero, razón por la cual a menudo les da a todos un período más prolongado. El peligro es rodar: un bebé envuelto en pañales que se gira boca abajo no puede utilizar los brazos para levantar o girar la cabeza. El espacio para las caderas también es importante, porque las piernas muy estiradas pueden interferir con el desarrollo normal de la cadera en los primeros meses.",
                fr: "L'emmaillotage atténue le réflexe de sursaut qui réveille les nouveau-nés d'un sommeil léger, c'est pourquoi cela permet souvent à tout le monde de s'étirer plus longtemps. Le point dangereux est de rouler : un bébé emmailloté qui se retourne sur le ventre ne peut pas utiliser ses bras pour soulever ou tourner la tête. L'espace pour les hanches est également important, car des jambes bien tendues peuvent interférer avec le développement normal des hanches au cours des premiers mois.",
                pt: "Enfaixar amortece o reflexo de susto que desperta os recém-nascidos do sono leve, e é por isso que muitas vezes proporciona a todos um alongamento mais longo. O ponto perigoso é rolar: um bebê enfaixado que vira de frente não consegue usar os braços para levantar ou virar a cabeça. O espaço para os quadris também é importante, porque as pernas bem esticadas podem interferir no desenvolvimento normal do quadril nos primeiros meses.",
                zh: "襁褓会抑制将新生儿从浅睡中唤醒的惊吓反射，这就是为什么襁褓通常可以让每个人获得更长的伸展时间。危险点是翻滚：襁褓中的婴儿翻身时无法用手臂抬起或转动头部。臀部空间也很重要，因为紧紧伸直的双腿会在最初几个月干扰臀部的正常发育。"
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Wrapping the legs straight and tight.",
                    "Continuing to swaddle after the first roll because it still helps sleep.",
                    "Swaddling on top of thick clothing, which risks overheating.",
                    "Covering the neck or chin with the top edge of the fabric."
                ],
                ru: [
                    "Пеленать ножки туго и выпрямленными.",
                    "Продолжать пеленать после первого переворота, потому что это всё ещё помогает спать.",
                    "Пеленать поверх плотной одежды — риск перегрева.",
                    "Закрывать верхним краем ткани шею или подбородок."
                ],
                de: [
                    "Die Beine gerade und fest wickeln.",
                    "Weiterhin pucken nach dem ersten Rollen, weil es immer noch beim Schlafen hilft.",
                    "Über dicker Kleidung pucken, was Überhitzung risikiert.",
                    "Nacken oder Kinn mit der oberen Kante des Stoffs abdecken."
                ],
                es: [
                    "Envolviendo las piernas rectas y apretadas.",
                    "Continuar envolviéndolo después del primer giro porque todavía ayuda a dormir.",
                    "Envolverlo encima de ropa gruesa, lo que supone un riesgo de sobrecalentamiento.",
                    "Cubriendo el cuello o la barbilla con el borde superior de la tela.",
                ],
                fr: [
                    "Enrouler les jambes droites et serrées.",
                    "Continuer à emmailloter après le premier roulage car cela aide quand même à dormir.",
                    "Emmailloter sur des vêtements épais, ce qui risque de surchauffer.",
                    "Couvrir le cou ou le menton avec le bord supérieur du tissu.",
                ],
                pt: [
                    "Envolvendo as pernas retas e firmes.",
                    "Continuar a enfaixar após o primeiro rolo porque ainda ajuda a dormir.",
                    "Enrolar em cima de roupas grossas, pois há risco de superaquecimento.",
                    "Cobrindo o pescoço ou queixo com a borda superior do tecido.",
                ],
                zh: [
                    "将腿伸直并紧紧包裹。",
                    "第一次滚动后继续襁褓，因为它仍然有助于睡眠。",
                    "裹在厚衣服上，有过热的风险。",
                    "用布料的上边缘覆盖颈部或下巴。",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "You hear a click from the hips, or the legs seem to move unevenly.",
                    "Your baby overheats when swaddled even in light layers.",
                    "Your baby rolls while swaddled — stop immediately and mention it at the next check-up."
                ],
                ru: [
                    "Вы слышите щелчок в области бёдер или ножки двигаются несимметрично.",
                    "Ребёнок перегревается в пеленании даже в лёгкой одежде.",
                    "Ребёнок перевернулся запелёнатым — сразу прекратите пеленание и скажите об этом на следующем осмотре."
                ],
                de: [
                    "Sie hören einen Klick aus den Hüften, oder die Beine scheinen ungleichmäßig zu bewegen.",
                    "Ihr Baby überhitzt beim Pucken, auch in leichten Schichten.",
                    "Ihr Baby rollt sich beim Pucken — stoppen Sie sofort und erwähnen Sie es beim nächsten Check-up."
                ],
                es: [
                    "Escuchas un clic en las caderas o las piernas parecen moverse de manera desigual.",
                    "Su bebé se sobrecalienta cuando lo envuelven, incluso con capas ligeras.",
                    "Su bebé se da vuelta mientras está envuelto; deténgase inmediatamente y menciónelo en el próximo chequeo.",
                ],
                fr: [
                    "Vous entendez un clic provenant des hanches ou les jambes semblent bouger de manière inégale.",
                    "Votre bébé surchauffe lorsqu'il est emmailloté, même dans des couches légères.",
                    "Votre bébé roule lorsqu'il est emmailloté : arrêtez-vous immédiatement et mentionnez-le lors du prochain contrôle.",
                ],
                pt: [
                    "Você ouve um clique nos quadris ou as pernas parecem se mover de maneira irregular.",
                    "Seu bebê superaquece quando enrolado, mesmo em camadas leves.",
                    "Seu bebê rola enquanto está enrolado – pare imediatamente e mencione isso no próximo check-up.",
                ],
                zh: [
                    "您会听到臀部发出咔嗒声，或者双腿似乎移动不均匀。",
                    "即使用薄层襁褓，宝宝也会过热。",
                    "您的宝宝在襁褓中滚动——立即停止并在下次检查时提及。",
                ]
            )
        ),

        CareTip(
            id: 1106, category: .sleep, icon: "clock.fill", ageFrom: 0, ageTo: 12,
            title: LocalizedText(
                en: "Wake windows and the overtired trap",
                ru: "Окна бодрствования и ловушка перевозбуждения",
                de: "Wachfenster und die Übermüdungsfalle",
                es: "Despierta las ventanas y la trampa cansada",
                fr: "Les fenêtres de réveil et le piège fatigué",
                pt: "Acorde as janelas e a armadilha cansada",
                zh: "唤醒窗口和过度疲劳陷阱"
            ),
            summary: LocalizedText(
                en: "Watch the clock and the baby — a short awake stretch prevents a long fight",
                ru: "Следите и за часами, и за ребёнком: короткое бодрствование избавляет от долгой борьбы",
                de: "Beobachten Sie die Uhr und das Baby — ein kurzes Wachintervall verhindert einen langen Kampf",
                es: "Vigile el reloj y al bebé: un breve período de vigilia evita una pelea larga",
                fr: "Surveillez l'horloge et le bébé : un court étirement d'éveil évite un long combat",
                pt: "Observe o relógio e o bebê – um curto período de vigília evita uma longa briga",
                zh: "注意时钟和婴儿——短暂的清醒伸展可以防止长时间的争吵"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Use rough guides: about 45–60 minutes awake for a newborn, 1.5–2 hours around 3–4 months, 2–3 hours by 6 months, 3–4 hours near a year.",
                    "Start winding down at the first tired cues — a fixed stare, red eyebrows, ear pulling, sudden clumsiness in movement.",
                    "Treat the ranges as a starting point and adjust to your own baby over a week of observation.",
                    "Track sleep in Momsy for a few days to see the real pattern rather than the remembered one.",
                    "Shorten the wake window rather than lengthening it when settling has been difficult."
                ],
                ru: [
                    "Ориентировочные рамки: около 45–60 минут бодрствования у новорождённого, 1,5–2 часа в 3–4 месяца, 2–3 часа к 6 месяцам, 3–4 часа ближе к году.",
                    "Начинайте успокаивать при первых признаках усталости — застывший взгляд, покраснение вокруг бровей, потягивание за ухо, внезапная неловкость движений.",
                    "Считайте эти рамки отправной точкой и подстраивайте под своего ребёнка, наблюдая в течение недели.",
                    "Понаблюдайте за сном в Momsy несколько дней, чтобы увидеть реальную картину, а не ту, которая запомнилась.",
                    "Если укладывание идёт тяжело, сокращайте окно бодрствования, а не удлиняйте его."
                ],
                de: [
                    "Verwenden Sie ungefähre Richtlinien: etwa 45–60 Minuten wach für ein Neugeborenes, 1,5–2 Stunden um 3–4 Monate, 2–3 Stunden bis 6 Monate, 3–4 Stunden ein Jahr.",
                    "Beginnen Sie mit den ersten Müdigkeitszeichen ruhig zu werden — ein starrer Blick, rote Augenbrauen, Ohrziehen, plötzliche Tollpatschigkeit.",
                    "Behandeln Sie die Spannen als Ausgangspunkt und passen Sie sie nach einer Woche Beobachtung an Ihr Baby an.",
                    "Verfolgen Sie den Schlaf in Momsy für ein paar Tage, um das echte Muster zu sehen, anstatt das erinnerte.",
                    "Verkürzen Sie das Wachfenster, anstatt es zu verlängern, wenn die Beruhigung schwierig war."
                ],
                es: [
                    "Utilice guías aproximadas: alrededor de 45 a 60 minutos despierto para un recién nacido, de 1,5 a 2 horas alrededor de los 3 a 4 meses, de 2 a 3 horas a los 6 meses, de 3 a 4 horas cerca de un año.",
                    "Empiece a relajarse ante las primeras señales de cansancio: una mirada fija, cejas rojas, tirones de orejas, torpeza repentina en el movimiento.",
                    "Trate los rangos como punto de partida y ajústelos a los de su propio bebé durante una semana de observación.",
                    "Realice un seguimiento del sueño en Momsy durante unos días para ver el patrón real en lugar del recordado.",
                    "Acorte la ventana de estela en lugar de alargarla cuando el asentamiento haya sido difícil.",
                ],
                fr: [
                    "Utilisez des guides approximatifs : environ 45 à 60 minutes d'éveil pour un nouveau-né, 1,5 à 2 heures vers 3 à 4 mois, 2 à 3 heures à 6 mois, 3 à 4 heures près d'un an.",
                    "Commencez à vous détendre dès les premiers signaux de fatigue : un regard fixe, des sourcils rouges, des tiraillements d'oreilles, une maladresse soudaine dans les mouvements.",
                    "Considérez les plages comme un point de départ et adaptez-vous à votre propre bébé au cours d'une semaine d'observation.",
                    "Suivez le sommeil dans Momsy pendant quelques jours pour voir le modèle réel plutôt que celui mémorisé.",
                    "Raccourcissez la fenêtre de réveil plutôt que de l'allonger lorsque la stabilisation a été difficile.",
                ],
                pt: [
                    "Use guias aproximados: cerca de 45–60 minutos acordado para um recém-nascido, 1,5–2 horas por volta dos 3–4 meses, 2–3 horas por 6 meses, 3–4 horas perto de um ano.",
                    "Comece a relaxar aos primeiros sinais de cansaço - olhar fixo, sobrancelhas vermelhas, puxar as orelhas, súbita falta de jeito nos movimentos.",
                    "Trate os intervalos como ponto de partida e ajuste-os ao seu próprio bebê durante uma semana de observação.",
                    "Acompanhe o sono em Momsy por alguns dias para ver o padrão real, em vez do lembrado.",
                    "Encurte a janela de ativação em vez de aumentá-la quando a acomodação for difícil.",
                ],
                zh: [
                    "使用粗略指南：新生儿大约需要清醒 45-60 分钟，3-4 个月大约需要 1.5-2 小时，6 个月需要 2-3 小时，一年左右需要 3-4 小时。",
                    "看到第一个疲倦的迹象就开始放松——凝视、红眉毛、拉耳朵、动作突然笨拙。",
                    "将这些范围作为起点，并在一周的观察中根据您自己的宝宝进行调整。",
                    "在 Momsy 中跟踪睡眠几天，以了解真实的模式，而不是记忆中的模式。",
                    "当稳定困难时，缩短尾流窗口而不是延长它。",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "When a baby stays awake past their limit, the body releases stress hormones to keep going, and those same hormones then make falling asleep harder and staying asleep shorter. That is the counter-intuitive part of infant sleep: an overtired baby fights sleep more, not less. Catching the window early is usually the difference between a five-minute settle and forty-five minutes of crying.",
                ru: "Когда ребёнок бодрствует дольше своего предела, организм выбрасывает гормоны стресса, чтобы держаться, и эти же гормоны потом мешают уснуть и сокращают сон. В этом парадокс детского сна: переутомлённый ребёнок сопротивляется сну сильнее, а не слабее. Поймать окно вовремя — обычно разница между пятиминутным укладыванием и сорока пятью минутами плача.",
                de: "Wenn ein Baby länger als sein Limit wach bleibt, setzt der Körper Stresshormone frei, um weiterzumachen, und dieselben Hormone machen es dann schwieriger, einzuschlafen, und verkürzen den Schlaf. Das ist der kontraintuitive Teil des Babyschlafes: Ein überforderndes Baby kämpft mehr gegen Schlaf, nicht weniger. Das Fenster früh zu erwischen ist normalerweise der Unterschied zwischen einer fünfminütigen Beruhigung und fünfundvierzig Minuten Weinen.",
                es: "Cuando un bebé permanece despierto más allá de su límite, el cuerpo libera hormonas del estrés para seguir adelante, y esas mismas hormonas hacen que conciliar el sueño sea más difícil y que permanezca más corto. Ésa es la parte contraria a la intuición del sueño infantil: un bebé demasiado cansado lucha por dormir más, no menos. Agarrar la ventana temprano suele ser la diferencia entre un descanso de cinco minutos y cuarenta y cinco minutos de llanto.",
                fr: "Lorsqu'un bébé reste éveillé au-delà de sa limite, le corps libère des hormones de stress pour continuer, et ces mêmes hormones rendent l'endormissement plus difficile et le sommeil plus court. C’est la partie contre-intuitive du sommeil du nourrisson : un bébé fatigué a plus de difficultés à dormir, pas moins. Attraper la fenêtre plus tôt fait généralement la différence entre cinq minutes d'installation et quarante-cinq minutes de pleurs.",
                pt: "Quando um bebê fica acordado além do limite, o corpo libera hormônios do estresse para continuar, e esses mesmos hormônios tornam o adormecimento mais difícil e o sono mais curto. Essa é a parte contra-intuitiva do sono infantil: um bebê cansado luta mais para dormir, e não menos. Chegar cedo à janela geralmente é a diferença entre uma pausa de cinco minutos e quarenta e cinco minutos de choro.",
                zh: "当婴儿保持清醒状态超过极限时，身体会释放压力荷尔蒙以继续保持清醒，而这些荷尔蒙会使入睡变得更困难，睡眠时间也会更短。这就是婴儿睡眠中违反直觉的部分：过度疲劳的婴儿会抗争更多的睡眠，而不是更少。尽早赶上窗口通常是五分钟安定和四十五分钟哭泣之间的区别。"
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Keeping the baby up longer in the hope of a better night.",
                    "Following a chart from the internet instead of your own baby's signals.",
                    "Missing the earliest cues and waiting for eye rubbing or crying.",
                    "Expecting the same window every time of day — the first one of the morning is usually shortest."
                ],
                ru: [
                    "Специально не давать ребёнку спать дольше в надежде на лучшую ночь.",
                    "Следовать таблице из интернета вместо сигналов собственного ребёнка.",
                    "Пропускать самые ранние признаки и ждать, пока он начнёт тереть глаза или плакать.",
                    "Ожидать одинаковое окно в любое время дня — первое, утреннее, обычно самое короткое."
                ],
                de: [
                    "Das Baby absichtlich länger wach halten in der Hoffnung auf eine bessere Nacht.",
                    "Einem Chart aus dem Internet folgen, anstatt Ihres eigenen Babysignalen.",
                    "Die frühesten Hinweise verpassen und auf Augenjucken oder Weinen warten.",
                    "Erwarten Sie das gleiche Fenster zu jeder Tageszeit — das erste am Morgen ist normalerweise das kürzeste."
                ],
                es: [
                    "Mantener al bebé despierto por más tiempo con la esperanza de una noche mejor.",
                    "Seguir un gráfico de Internet en lugar de las señales de su propio bebé.",
                    "Perder las primeras señales y esperar a que se frote los ojos o llore.",
                    "Esperar la misma ventana a todas horas del día; la primera de la mañana suele ser la más corta.",
                ],
                fr: [
                    "Garder bébé éveillé plus longtemps dans l’espoir d’une meilleure nuit.",
                    "Suivre un tableau provenant d'Internet au lieu des signaux de votre propre bébé.",
                    "Manquer les premiers signaux et attendre de se frotter les yeux ou de pleurer.",
                    "S'attendre à la même fenêtre à chaque moment de la journée – la première du matin est généralement la plus courte.",
                ],
                pt: [
                    "Manter o bebê acordado por mais tempo na esperança de uma noite melhor.",
                    "Seguir um gráfico da internet em vez dos sinais do seu próprio bebê.",
                    "Perdendo os primeiros sinais e esperando esfregar os olhos ou chorar.",
                    "Esperar a mesma janela a cada hora do dia – a primeira da manhã geralmente é mais curta.",
                ],
                zh: [
                    "让宝宝睡得更久，希望有一个更好的夜晚。",
                    "遵循互联网上的图表而不是您自己宝宝的信号。",
                    "错过了最早的线索并等待揉眼睛或哭泣。",
                    "一天中的每个时间都期待着相同的窗口——早上的第一个窗口通常是最短的。",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Your baby sleeps far more or far less than the guides over several weeks and seems unwell with it.",
                    "Sleep is constantly broken by pain, coughing, or laboured breathing.",
                    "You are worried about development alongside unusual sleep patterns."
                ],
                ru: [
                    "Ребёнок неделями спит намного больше или намного меньше ориентиров и при этом выглядит нездоровым.",
                    "Сон постоянно прерывается из-за боли, кашля или затруднённого дыхания.",
                    "Необычный режим сна сочетается с вашими опасениями по поводу развития."
                ],
                de: [
                    "Ihr Baby schläft über Wochen hinweg viel mehr oder viel weniger als die Richtlinien und scheint damit unwohl.",
                    "Der Schlaf wird ständig durch Schmerzen, Husten oder angestrengtes Atmen unterbrochen.",
                    "Sie sind über die Entwicklung zusammen mit ungewöhnlichen Schlafmustern besorgt."
                ],
                es: [
                    "Su bebé duerme mucho más o menos que las guías durante varias semanas y parece no sentirse bien.",
                    "El sueño se ve constantemente interrumpido por el dolor, la tos o la dificultad para respirar.",
                    "Le preocupa el desarrollo junto con patrones de sueño inusuales.",
                ],
                fr: [
                    "Votre bébé dort beaucoup plus ou beaucoup moins que les guides pendant plusieurs semaines et ne semble pas bien.",
                    "Le sommeil est constamment interrompu par la douleur, la toux ou une respiration difficile.",
                    "Vous vous inquiétez du développement et des habitudes de sommeil inhabituelles.",
                ],
                pt: [
                    "Seu bebê dorme muito mais ou menos do que os guias durante várias semanas e parece indisposto.",
                    "O sono é constantemente interrompido por dor, tosse ou dificuldade para respirar.",
                    "Você está preocupado com o desenvolvimento juntamente com padrões de sono incomuns.",
                ],
                zh: [
                    "您的宝宝在几周内的睡眠时间比指导值多得多或少得多，并且似乎对此感到不舒服。",
                    "睡眠经常因疼痛、咳嗽或呼吸困难而中断。",
                    "您担心发育和不寻常的睡眠模式。",
                ]
            )
        ),

        CareTip(
            id: 1107, category: .sleep, icon: "sparkles", ageFrom: 2, ageTo: 12,
            title: LocalizedText(
                en: "Build a twenty-minute bedtime routine",
                ru: "Создайте двадцатиминутный ритуал перед сном",
                de: "Bauen Sie eine zwanzigminütige Schlafenszeit-Routine auf",
                es: "Construya una rutina de veinte minutos para acostarse",
                fr: "Construisez une routine du coucher de vingt minutes",
                pt: "Crie uma rotina de vinte minutos para dormir",
                zh: "建立二十分钟的就寝时间"
            ),
            summary: LocalizedText(
                en: "The same short sequence every night becomes a signal your baby can read",
                ru: "Одна и та же короткая последовательность каждый вечер становится понятным ребёнку сигналом",
                de: "Die gleiche kurze Abfolge jeden Abend wird zu einem Signal, das Ihr Baby lesen kann",
                es: "La misma secuencia corta todas las noches se convierte en una señal que tu bebé puede leer.",
                fr: "La même courte séquence chaque soir devient un signal que votre bébé peut lire",
                pt: "A mesma sequência curta todas as noites torna-se um sinal que seu bebê pode ler",
                zh: "每晚相同的短序列成为宝宝可以阅读的信号"
            ),
            whatToDo: LocalizedList(
                en: [
                    "Choose three or four steps and keep the order fixed: for example bath, sleeping bag, feed, one short song.",
                    "Keep the whole thing to about twenty minutes — long routines drift past the tired window.",
                    "Dim the lights and lower your voice from the first step onwards.",
                    "Finish in the room where your baby will sleep.",
                    "Use the same shortened version away from home so the signal still works when everything else is unfamiliar."
                ],
                ru: [
                    "Выберите три-четыре шага и не меняйте их порядок: например, купание, спальный мешок, кормление, одна короткая песенка.",
                    "Укладывайтесь примерно в двадцать минут — длинные ритуалы выходят за окно усталости.",
                    "С первого шага приглушите свет и говорите тише.",
                    "Заканчивайте в той комнате, где ребёнок будет спать.",
                    "Вне дома используйте ту же, только сокращённую версию, чтобы сигнал работал, когда всё вокруг незнакомо."
                ],
                de: [
                    "Wählen Sie drei oder vier Schritte und halten Sie die Reihenfolge fest: zum Beispiel Bad, Schlafsack, Füttern, ein kurzes Lied.",
                    "Halten Sie das Ganze bei etwa zwanzig Minuten — lange Routinen driften über das müde Fenster hinaus.",
                    "Dimmen Sie die Lichter ab und senken Sie Ihre Stimme ab dem ersten Schritt.",
                    "Beenden Sie das Zimmer, in dem Ihr Baby schlafen wird.",
                    "Verwenden Sie die gleiche verkürzte Version weg von zu Hause, so dass das Signal immer noch funktioniert, wenn alles andere unbekannt ist."
                ],
                es: [
                    "Elija tres o cuatro pasos y mantenga el orden fijo: por ejemplo, baño, saco de dormir, alimentación, una canción corta.",
                    "Mantenga todo en unos veinte minutos: largas rutinas pasan por la ventana cansada.",
                    "Atenúa las luces y baja la voz desde el primer paso en adelante.",
                    "Termina en la habitación donde dormirá tu bebé.",
                    "Utilice la misma versión abreviada fuera de casa para que la señal siga funcionando cuando todo lo demás no le resulte familiar.",
                ],
                fr: [
                    "Choisissez trois ou quatre étapes et gardez l'ordre fixe : par exemple bain, sac de couchage, nourriture, une courte chanson.",
                    "Gardez le tout à environ vingt minutes – de longues routines passent devant la fenêtre fatiguée.",
                    "Baissez les lumières et baissez le ton dès le premier pas.",
                    "Terminez dans la pièce où dormira votre bébé.",
                    "Utilisez la même version abrégée loin de chez vous afin que le signal fonctionne toujours lorsque tout le reste ne vous est pas familier.",
                ],
                pt: [
                    "Escolha três ou quatro etapas e mantenha a ordem fixa: por exemplo, banho, saco de dormir, alimentação, uma música curta.",
                    "Mantenha tudo em cerca de vinte minutos - longas rotinas passam pela janela cansativa.",
                    "Apague as luzes e abaixe a voz desde o primeiro passo.",
                    "Termine no quarto onde seu bebê vai dormir.",
                    "Use a mesma versão abreviada fora de casa para que o sinal ainda funcione quando todo o resto não for familiar.",
                ],
                zh: [
                    "选择三到四个步骤并保持固定的顺序：例如洗澡、睡袋、喂食、一首短歌。",
                    "将整个过程控制在二十分钟左右——漫长的例行公事从疲惫的窗外飘过。",
                    "从第一步开始就调暗灯光并降低声音。",
                    "在宝宝睡觉的房间完成。",
                    "在外出时使用相同的缩短版本，以便在其他一切都不熟悉时信号仍然有效。",
                ]
            ),
            whyItMatters: LocalizedText(
                en: "Babies cannot tell time, but they are excellent at recognising sequences. A repeated pattern of dimming light, a familiar smell and a predictable order tells the body what is coming, and melatonin release follows the cue. The routine is doing something real; it is not a superstition. Consistency matters far more than the specific contents, which is why simple routines usually outperform elaborate ones.",
                ru: "Дети не умеют определять время, но прекрасно распознают последовательности. Повторяющееся сочетание приглушённого света, знакомого запаха и предсказуемого порядка сообщает организму, что будет дальше, и выброс мелатонина следует за этим сигналом. Ритуал действительно работает, это не суеверие. Постоянство важнее конкретного содержания — поэтому простые ритуалы обычно эффективнее сложных.",
                de: "Babys können keine Zeit erzählen, aber sie sind hervorragend in der Erkennung von Abfolgen. Ein wiederholtes Muster aus Dimmerlicht, einem vertrauten Duft und einer vorhersehbaren Reihenfolge sagt dem Körper, was kommt, und die Melatoninfreisetzung folgt dem Hinweis. Die Routine tut etwas Echtes; es ist kein Aberglaube. Konsistenz ist viel wichtiger als der spezifische Inhalt, daher schneiden einfache Routinen normalerweise besser ab als aufwendige.",
                es: "Los bebés no pueden decir la hora, pero son excelentes para reconocer secuencias. Un patrón repetido de luz tenue, un olor familiar y un orden predecible le indican al cuerpo lo que se avecina, y la liberación de melatonina sigue la señal. La rutina es hacer algo real; no es una superstición. La coherencia importa mucho más que los contenidos específicos, razón por la cual las rutinas simples suelen superar a las elaboradas.",
                fr: "Les bébés ne peuvent pas lire l’heure, mais ils sont excellents pour reconnaître les séquences. Un motif répété de lumière tamisée, une odeur familière et un ordre prévisible indiquent au corps ce qui arrive, et la libération de mélatonine suit le signal. La routine consiste à faire quelque chose de réel ; ce n'est pas une superstition. La cohérence compte bien plus que le contenu spécifique, c’est pourquoi les routines simples surpassent généralement les routines élaborées.",
                pt: "Os bebês não sabem dizer as horas, mas são excelentes em reconhecer sequências. Um padrão repetido de luz fraca, um cheiro familiar e uma ordem previsível informam ao corpo o que está por vir, e a liberação de melatonina segue a deixa. A rotina é fazer algo real; não é uma superstição. A consistência é muito mais importante do que os conteúdos específicos, e é por isso que rotinas simples geralmente superam as elaboradas.",
                zh: "婴儿无法辨别时间，但他们非常擅长识别序列。昏暗的灯光、熟悉的气味和可预测的顺序的重复模式告诉身体即将发生什么，褪黑激素会根据提示释放。例行公事就是做一些真实的事情；这不是迷信。一致性比具体内容更重要，这就是为什么简单的例程通常胜过复杂的例程。"
            ),
            commonMistakes: LocalizedList(
                en: [
                    "Changing the order depending on who is putting the baby down.",
                    "Screens or bright overhead light during the wind-down.",
                    "Starting the routine only after the baby is already overtired.",
                    "Abandoning the routine on holiday or when visiting family."
                ],
                ru: [
                    "Менять порядок в зависимости от того, кто укладывает ребёнка.",
                    "Экраны или яркий верхний свет во время подготовки ко сну.",
                    "Начинать ритуал, когда ребёнок уже переутомлён.",
                    "Отказываться от ритуала в отпуске или в гостях у родственников."
                ],
                de: [
                    "Die Reihenfolge abhängig von der Person, die das Baby zu Bett bringt, ändern.",
                    "Bildschirme oder helles Kopflicht während des Winddown.",
                    "Die Routine erst starten, wenn das Baby bereits überfordert ist.",
                    "Die Routine im Urlaub oder beim Besuch der Familie aufgeben."
                ],
                es: [
                    "Cambiando el orden dependiendo de quién acueste al bebé.",
                    "Pantallas o luces brillantes en el techo durante la relajación.",
                    "Comenzar la rutina solo después de que el bebé ya esté demasiado cansado.",
                    "Abandonar la rutina durante las vacaciones o cuando se visita a la familia.",
                ],
                fr: [
                    "Changer l'ordre en fonction de qui dépose le bébé.",
                    "Écrans ou plafonnier lumineux pendant la période de détente.",
                    "Commencer la routine seulement lorsque le bébé est déjà fatigué.",
                    "Abandonner la routine en vacances ou lors d'une visite en famille.",
                ],
                pt: [
                    "Mudando a ordem dependendo de quem está colocando o bebê no chão.",
                    "Telas ou luz brilhante no teto durante o relaxamento.",
                    "Iniciar a rotina somente depois que o bebê já estiver cansado.",
                    "Abandonando a rotina nas férias ou quando visita a família.",
                ],
                zh: [
                    "根据谁放下婴儿来改变顺序。",
                    "放松时屏幕或明亮的头顶灯。",
                    "仅在婴儿已经过度疲劳后才开始该例程。",
                    "在假期或探望家人时放弃常规。",
                ]
            ),
            whenToCallDoctor: LocalizedList(
                en: [
                    "Bedtime is consistently distressing for months despite a stable routine.",
                    "Your baby wakes screaming and cannot be comforted, night after night.",
                    "You are running out of resources to cope with the nights — say this out loud to your doctor or health visitor."
                ],
                ru: [
                    "Укладывание месяцами проходит тяжело, несмотря на стабильный ритуал.",
                    "Ребёнок просыпается с криком и не успокаивается, ночь за ночью.",
                    "У вас заканчиваются силы выдерживать ночи — скажите об этом врачу или патронажной сестре прямо."
                ],
                de: [
                    "Die Schlafenszeit ist trotz einer stabilen Routine durchgehend belastend.",
                    "Ihr Baby wacht schreiend auf und kann sich Nacht für Nacht nicht beruhigen.",
                    "Ihnen gehen die Ressourcen aus, um mit den Nächten umzugehen — sagen Sie dies laut zu Ihrem Arzt oder Besucherin."
                ],
                es: [
                    "La hora de acostarse es constantemente angustiosa durante meses a pesar de una rutina estable.",
                    "Su bebé se despierta gritando y no puede consolarlo, noche tras noche.",
                    "Se está quedando sin recursos para afrontar las noches; dígaselo en voz alta a su médico o visitador sanitario.",
                ],
                fr: [
                    "L’heure du coucher est constamment pénible pendant des mois malgré une routine stable.",
                    "Votre bébé se réveille en criant et ne peut être réconforté nuit après nuit.",
                    "Vous manquez de ressources pour faire face aux nuits – dites-le à voix haute à votre médecin ou à votre visiteur de santé.",
                ],
                pt: [
                    "A hora de dormir é consistentemente angustiante durante meses, apesar de uma rotina estável.",
                    "Seu bebê acorda gritando e não consegue ser consolado, noite após noite.",
                    "Você está ficando sem recursos para lidar com as noites – diga isso em voz alta ao seu médico ou enfermeiro.",
                ],
                zh: [
                    "尽管作息规律稳定，但就寝时间连续几个月都令人痛苦。",
                    "您的宝宝夜复一夜地尖叫着醒来，无法安抚。",
                    "您已经没有足够的资源来应对夜晚了——请向您的医生或健康访问员大声说出这一点。",
                ]
            )
        )
    ]
}
