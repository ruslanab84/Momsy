# CLI TASK — Fix: relay-email вместо имени участника после join семьи

**Приоритет:** P1 (публично видимая утечка relay-адреса в ростере семьи)
**Скоуп:** одна строка в одном файле. Ничего больше не менять.

## Симптом

После присоединения к семье по инвайту участник отображается как `jm2kg4hb96@privaterelay.appleid.com` вместо имени (скриншот Family / «Zarifa's Team»).

## Root cause (проверено по свежему клону)

`Momsy/Core/Family/FamilyManager.swift`, строка **256**, метод `joinFamily(code:uid:force:)`:

```swift
let displayName = Auth.auth().currentUser?.displayName ?? Auth.auth().currentUser?.email ?? "User"
```

Проблемы:
1. При Apple Sign-In `displayName` может быть `nil` или пустой строкой (Apple отдаёт fullName только при первой авторизации) → fallback на `email`, который при «Hide My Email» — relay-адрес.
2. Пустая строка `""` в `displayName` не отфильтровывается оператором `??`.

Путь создания семьи (`AuthManager.swift:71` → `FamilyManager.setup`) уже использует централизованный резолвер `AccountDisplay.memberName(displayName:email:)` (`Momsy/Core/Auth/AccountDisplay.swift`), который триммит пустые имена и отбрасывает `@privaterelay.appleid.com`. Join-путь его обходит — единственное расхождение.

Google Sign-In всегда даёт непустой `displayName`, поэтому после фикса оба провайдера корректны.

## Изменение — FamilyManager.swift (строка 256)

**Было:**
```swift
        let displayName = Auth.auth().currentUser?.displayName ?? Auth.auth().currentUser?.email ?? "User"
```

**Стало:**
```swift
        let currentUser = Auth.auth().currentUser
        let displayName = AccountDisplay.memberName(
            displayName: currentUser?.displayName,
            email: currentUser?.email
        )
```

`AccountDisplay` находится в том же таргете (`Momsy/Core/Auth/AccountDisplay.swift`), дополнительные import не нужны.

## Почему это чинит и уже «испорченные» документы

`joinFamily` пишет member-документ через `batch.setData(..., merge: true)` — при повторном join имя перезапишется. Для текущего тестового аккаунта достаточно выйти из семьи и присоединиться заново (или пересоздать члена). Никакой миграции не требуется.

## Definition of Done

- [ ] `grep -n "privaterelay\|?? Auth.auth().currentUser?.email" Momsy/Core/Family/FamilyManager.swift` → нет прямого fallback на email
- [ ] `grep -n "AccountDisplay.memberName" Momsy/Core/Family/FamilyManager.swift` → 1 вхождение (в `joinFamily`)
- [ ] Проект собирается
- [ ] Изменён только `FamilyManager.swift` (`git status`)

## Manual QA

1. Аккаунт Apple Sign-In с «Hide My Email», displayName пустой → join по коду → в Family участник отображается как «User» (не relay-адрес).
2. Аккаунт Apple с именем → join → отображается имя.
3. Google-аккаунт → join → отображается имя Google-профиля.
