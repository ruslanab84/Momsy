# CLI TASK: Live Activity продолжает отсчёт после остановки сна

**Severity:** P1 (feature-breaking, видимо пользователю на lock screen)
**Repo:** ruslanab84/Momsy

## Диагноз

`SleepLiveActivityManager.endActivity()` — no-op, если `self.activity == nil`. В проекте два независимых экземпляра менеджера:

- `Momsy/Features/Sleep/Presentation/ViewModel/SleepViewModel.swift:28` — `private let liveActivity = SleepLiveActivityManager()`
- `Momsy/Core/WatchSync/QuickLogCoordinator.swift:19` — `private let sleepLA = SleepLiveActivityManager()`

Каждый хранит собственную ссылку `activity`. Если Live Activity запущена одним экземпляром (или прошлым запуском процесса), вызов `endActivity()` на другом экземпляре молча выходит по guard — Live Activity остаётся на экране блокировки и продолжает считать время.

**Репро-сценарии:**
1. Старт сна на iPhone (`SleepViewModel`) → стоп с Watch (`QuickLogCoordinator.stopSleep`, строки 121/129) → `sleepLA.activity == nil` → no-op.
2. Приложение перезапущено во время сна → стоп с Watch: экземпляр координатора в новом процессе пуст.

Тот же паттерн (`guard let activity else { return }`) скопирован во все 5 менеджеров: Feeding, Walk, Bath, Pumping — фиксим все, у Feeding идентичный кросс-инстанс сценарий (стоп кормления с Watch).

## Изменения

Во всех 5 файлах в `Momsy/Core/Widget/` заменить тело `endActivity()`. Семантика: завершать ВСЕ активности данного типа через `Activity<T>.activities`, не полагаясь на удерживаемую ссылку. Это идемпотентно и покрывает любые «осиротевшие» активности.

### 1. `Momsy/Core/Widget/SleepLiveActivityManager.swift` (строки 33–39)

**Before:**
```swift
    func endActivity() {
        guard let activity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            self.activity = nil
        }
    }
```

**After:**
```swift
    func endActivity() {
        activity = nil
        Task {
            for existing in Activity<SleepActivityAttributes>.activities {
                await existing.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
```

### 2. `Momsy/Core/Widget/FeedingLiveActivityManager.swift` (строки 51–57)

То же самое, тип `Activity<FeedingActivityAttributes>`.

### 3. `Momsy/Core/Widget/WalkLiveActivityManager.swift` (строки 33–39)

Тип `Activity<WalkActivityAttributes>`.

### 4. `Momsy/Core/Widget/BathLiveActivityManager.swift` (строки 33–39)

Тип `Activity<BathActivityAttributes>`.

### 5. `Momsy/Core/Widget/PumpingLiveActivityManager.swift` (строки 33–39)

Тип `Activity<PumpingActivityAttributes>`.

## Что НЕ трогать

- `startActivity()` во всех менеджерах уже завершает существующие активности перед запуском новой — оставить как есть.
- `reattachIfNeeded()` — оставить (используется в `restoreOpenSession`, `FeedingViewModel`, `WalkViewModel`, `BathViewModel`); после фикса он перестаёт быть критичным для остановки, но нужен для pause/resume у кормления.
- `WidgetDataStore.clearSleep` / таймлайны home-screen виджета — корректны, баг только в Live Activity.
- Никаких новых ключей локализации.

## Definition of Done

- [ ] Все 5 менеджеров используют паттерн `Activity<T>.activities` в `endActivity()`
- [ ] `activity = nil` выставляется синхронно до Task (защита от гонки с повторным start)
- [ ] Сборка iOS + Watch таргетов проходит
- [ ] Существующие тесты зелёные

## Manual QA

1. iPhone: старт сна → убедиться, что Live Activity появилась на lock screen.
2. Убить приложение (swipe в App Switcher), запустить заново → остановить сон с Apple Watch.
3. Ожидание: Live Activity исчезает немедленно, таймер не идёт.
4. Повторить для кормления: старт на iPhone → стоп с Watch → активность закрывается.
5. Регресс: обычный старт/стоп сна на iPhone без перезапуска — активность закрывается как раньше.
