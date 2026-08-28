# Momsy — карта экранов

Этот документ описывает пользовательские SwiftUI-экраны в текущей версии приложения. Он не включает мелкие UI-компоненты (`BBSectionLabel`, карточки, строки и т. п.).

## Вход в приложение

| View | Назначение | Когда показывается |
| --- | --- | --- |
| `MomsyApp` | Запускает Firebase и хранилище, создаёт `AppContainer`. | Точка входа приложения. |
| `MomsyRootView` | Обрабатывает запуск, deep links семейных приглашений, согласие на Cloud Sync и маршруты из виджетов. | После успешного создания хранилища. |
| `PersistenceRecoveryView` | Показывает восстановление, если локальное хранилище не удалось открыть. | При ошибке инициализации SwiftData. |
| `ContentView` | Выбирает splash, onboarding, paywall или основной интерфейс. | Корневой экран после запуска. |
| `SplashView` | Стартовая заставка. | Пока приложение и Premium-доступ инициализируются. |
| `OnboardingView` | Создаёт профиль ребёнка или присоединяет родителя по приглашению; собирает роль и выбор Cloud Sync. | Пока `onboardingDone == false`. |
| `PaywallView` | Покупка Premium либо присоединение к ожидающему семейному приглашению. | Когда Premium нужен, но доступа нет. |

## Основная навигация

`MainTabView` содержит четыре или пять вкладок. `Diary` и `Doctor` доступны только ролям с правом просмотра приватных данных.

| Вкладка | View | Назначение |
| --- | --- | --- |
| Today | `TodayView` | Главный дневной экран: сводка за сегодня, следующий сон, быстрые записи, подсказка и история. |
| Leaps | `LeapsView` | Этапы развития ребёнка, навыки и записи по этапам. |
| Diary | `DiaryView` | Личный дневник семьи. |
| Doctor | `DoctorMenuView` | Меню медицинских и аналитических разделов. |
| Me | `MeView` | Профиль ребёнка, семья, звуки и настройки. |

## Today: быстрые действия

`TodayView` открывает эти экраны как sheets. Маршруты `momsy://sleep`, `momsy://feeding`, `momsy://walk` и `momsy://bath` из виджетов также ведут сюда.

| View | Назначение |
| --- | --- |
| `FeedingView` | Кормления: таймер, ручное добавление и история. |
| `SleepView` | Сон: запуск/остановка таймера, ручные записи и история. |
| `WalkView` | Прогулки: таймер и ручные записи. |
| `BathView` | Купания: таймер и ручные записи. |
| `VitaminView` | Приём витаминов, категории и записи за день. |
| `PumpingView` | Сцеживание: таймер и ручные записи. |
| `SymptomView` | Симптомы ребёнка и их журнал. |
| `AllTodayEntriesView` | Полный список записей за текущий день. |
| `AddStoolEntrySheet` | Быстрое добавление записи о стуле. |
| `AddChildSheet` | Добавление профиля ребёнка. |

## Doctor: медицинское меню

`DoctorMenuView` — экран-меню. Он открывает следующие разделы через `NavigationLink`.

| View | Назначение |
| --- | --- |
| `SymptomView` | Запись и просмотр симптомов. |
| `CareTipsView` | Список рекомендаций по уходу. |
| `CareTipDetailView` | Полный текст выбранной рекомендации. |
| `LogReportView` | Отчёт по журналу событий с возможностью поделиться. |
| `ReportView` | Недельный отчёт для педиатра с экспортом/поделиться. |
| `TrackingView` | Рост, вес, температура и графики перцентилей ВОЗ. |
| `VaccinationView` | Календарь прививок, отметка выполненных и пользовательские прививки. |
| `FoodDiaryView` | Дневник прикорма и новые продукты. |
| `MomMoodView` | Самочувствие мамы; открывает сон мамы, воду и записи настроения. |
| `MomSleepView` | Учёт сна мамы. |
| `WaterIntakeView` | Учёт воды, выпитой мамой. |

## Me: профиль и семья

| View | Назначение |
| --- | --- |
| `MeView` | Сводка профиля ребёнка и меню личных разделов. |
| `EditBabyProfileView` | Редактирование активного профиля ребёнка. |
| `ManageChildrenView` | Управление профилями детей. |
| `SharingView` | Члены семьи, приглашения, роли и подключение к семье. |
| `SoundsView` | Колыбельные и фоновые звуки. |
| `SettingsView` | Тема, единицы измерения, язык, Cloud Sync, аккаунт, версия и удаление данных. |
| `AccountAuthSheet` / `AuthStep` | Вход или повторная аутентификация для семейных действий и удаления аккаунта. |

## Экраны, которые есть в коде, но сейчас скрыты

| View | Статус |
| --- | --- |
| `WeeklyInsightView` | Список еженедельных AI-инсайтов. Маршрут скрыт в `DoctorMenuView` для текущего App Store-релиза. |
| `WeeklyInsightDetailView` | Детали выбранного еженедельного AI-инсайта. Открывается только из `WeeklyInsightView`. |

## Быстрая навигационная схема

```text
MomsyApp
└─ MomsyRootView
   └─ ContentView
      ├─ SplashView
      ├─ OnboardingView
      ├─ PaywallView
      └─ MainTabView
         ├─ TodayView → tracking sheets
         ├─ LeapsView
         ├─ DiaryView
         ├─ DoctorMenuView → medical/analytics screens
         └─ MeView → profile, family, sounds, settings
```

## Где добавлять новый экран

- Новая вкладка: `Momsy/Core/Navigation/MainTabView.swift`.
- Действие на главном экране: `Momsy/Features/Today/Presentation/Views/TodayView.swift`.
- Медицинский/аналитический раздел: `Momsy/Features/Doctor/Presentation/Views/DoctorMenuView.swift`.
- Профиль, семья или настройки: `Momsy/Features/Me/Presentation/Views/MeView.swift`.
- Новый самостоятельный функциональный раздел: `Momsy/Features/<Feature>/Presentation/Views/` с ViewModel в соседней `ViewModel/` папке.
