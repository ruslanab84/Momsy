# CLI TASK — Parent-neutral строки: «Hello, mama!» (Onboarding) и «hang in there, mama» (Leaps)

**Приоритет:** P3 (polish, инклюзивность)
**Скоуп:** две строки. Ничего больше не менять.

## Контекст

На шаге онбординга `OBStepAge` заголовок — `loc.strings.helloMama` («Hello, mama!»). Онбординг может проходить папа или другой член семьи. Нужен нейтральный вариант «Hello, parent!» (локализованно — обращение к родителю, без указания пола).

Проверено по свежему клону (`git clone --depth 1`):
- Ключ: `Momsy/Core/Localization/L10n.swift`, строка **1034**
- Единственное использование: `Momsy/Features/Onboarding/Presentation/Views/OBStepAge.swift`, строка **23**

Вторая строка: ключ `hangInThere` («hang in there, mama ✿»), `L10n.swift`, строка **476**; единственное использование — `Momsy/Features/Leaps/Presentation/Views/LeapsView.swift`, строка **64**. Тоже сделать нейтральной.

## Изменение 1 — L10n.swift (строка 1034)

Переименовать ключ `helloMama` → `helloParent` и заменить значения на нейтральные во всех 7 языках.

**Было:**
```swift
    var helloMama: String       { s("Hello, mama!",  "Привет, мама!", "Hallo, Mama!",  "¡Hola, mamá!", "Bonjour, maman !", "Olá, mamã!", "你好，妈妈！") }
```

**Стало:**
```swift
    var helloParent: String     { s("Hello!",        "Привет!",       "Hallo!",        "¡Hola!", "Bonjour !", "Olá!", "你好！") }
```

Примечание: во многих языках слово «родитель» в обращении звучит канцелярски («Hello, parent!», «Привет, родитель!»). Нейтральное короткое приветствие — стандартное решение. Если Руслан хочет именно «parent», альтернативный вариант:
```swift
    var helloParent: String     { s("Hi there!",     "Здравствуйте!", "Hallo zusammen!", "¡Hola!", "Bonjour !", "Olá!", "您好！") }
```
Использовать первый вариант, если не сказано иное.

## Изменение 2 — OBStepAge.swift (строка 23)

**Было:**
```swift
                Text(loc.strings.helloMama)
```

**Стало:**
```swift
                Text(loc.strings.helloParent)
```

## Изменение 3 — L10n.swift (строка 476)

Имя ключа `hangInThere` оставить (оно нейтральное), заменить только значения — убрать «mama» во всех 7 языках, сохранив ✿.

**Было:**
```swift
    var hangInThere: String     { s("hang in there, mama ✿", "держитесь, мама ✿", "Haltet durch, Mama ✿", "ánimo, mamá ✿", "courage, maman ✿", "força, mamã ✿", "坚持住，妈妈 ✿") }
```

**Стало:**
```swift
    var hangInThere: String     { s("hang in there ✿", "вы справитесь ✿", "Haltet durch ✿", "ánimo ✿", "courage ✿", "força ✿", "坚持住 ✿") }
```

`LeapsView.swift` менять не нужно — имя ключа не изменилось.

## Definition of Done

- [ ] `grep -rn "helloMama" Momsy/ MomsyWatch/ MomsyWidget/` → пусто
- [ ] `grep -rn "helloParent" Momsy/` → ровно 2 вхождения (L10n.swift + OBStepAge.swift)
- [ ] `grep -n "hangInThere" Momsy/Core/Localization/L10n.swift` → строка без «mama»/«мама» ни в одном языке
- [ ] Проект собирается (`xcodebuild build` или сборка в Xcode)
- [ ] Изменены только 2 файла: `L10n.swift` (2 строки) и `OBStepAge.swift` (1 строка); `git status` это подтверждает
