# Momsy

Momsy — iOS-приложение для родителей и близких: уход за ребёнком, дневник,
развитие, здоровье и семейный доступ. Базовые данные хранятся локально; по
явному согласию пользователя они синхронизируются через Firebase.

## Возможности

- Быстрый учёт кормления, сна, прогулок, купания, сцеживания, витаминов,
  симптомов и стула.
- Профиль ребёнка, несколько детей, дневник, прикорм, прививки, измерения и
  отчёты для врача.
- Этапы развития, советы по уходу, трекинг самочувствия мамы и фоновые звуки.
- Семейные приглашения и роли; приватные вкладки доступны только ролям с
  соответствующим правом.
- Виджеты, Live Activities и deep links для быстрых действий.
- Premium через StoreKit. Семейный Premium определяется в Momsy-семье в
  Firebase, а не Apple Family Sharing.

Полная карта экранов: [docs/VIEW_MAP.md](docs/VIEW_MAP.md).

## Технологии и архитектура

- SwiftUI, Swift Concurrency, iOS 17+.
- SwiftData — локальное хранилище.
- Firebase Authentication, Firestore и App Check — необязательная
  аутентификация, синхронизация и семейный доступ.
- StoreKit 2 — подписка Premium.
- WidgetKit и WatchConnectivity — виджеты, Live Activities и быстрые действия
  с Apple Watch.

Код разложен по `Core`, `Features`, `Services` и `Resources`. Внутри фич
используется разделение `Data` / `Domain` / `Presentation`: Views отображают
состояние, ViewModels координируют действия, а репозитории и сервисы работают
с хранилищами и внешними SDK. `AppContainer` собирает production-зависимости.

## Запуск

1. Откройте [Momsy.xcodeproj](Momsy.xcodeproj) в Xcode.
2. Выберите схему `Momsy`, iOS Simulator или устройство и запустите проект.
   Swift Package Manager автоматически загрузит Firebase и Google Sign-In.
3. Для локального режима больше ничего не требуется: при отсутствии Firebase
   конфигурации приложение использует локальные реализации семейного доступа и
   синхронизации.

### Firebase для Cloud Sync

1. Создайте iOS-приложение в Firebase с bundle ID `RuslanAbd.Momsy`.
2. Скопируйте `Momsy/GoogleService-Info.plist.template` в
   `Momsy/GoogleService-Info.plist` и заполните значениями своего Firebase
   проекта.
3. Добавьте созданный plist в target `Momsy` в Xcode; файл с реальными
   значениями не должен попадать в Git.
   Сборочная фаза `Validate Firebase Configuration`
   ([scripts/validate-firebase-config.sh](scripts/validate-firebase-config.sh))
   проверяет, что plist попал в бандл и заполнен реальными значениями: для
   Debug это предупреждение, для Release и archive — ошибка сборки. Так релиз
   без конфигурации не уедет в TestFlight молча. На CI подкладывайте plist из
   секретов перед сборкой.
4. Перед развёртыванием Firestore проверьте `firestore.rules` и
   `firestore.indexes.json`. Конфигурация Firebase CLI находится в
   `firebase.json`.

Cloud Sync включается только после согласия пользователя в onboarding или
настройках. Без него записи остаются на устройстве.

## Тесты

В проекте есть unit-тесты Swift Testing для доменной логики, синхронизации,
семейного доступа, подписки и ViewModels. Запуск из терминала:

```bash
xcodebuild test \
  -project Momsy.xcodeproj \
  -scheme Momsy \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -parallel-testing-enabled NO
```

Если выбранного симулятора нет, подставьте доступную модель из Xcode. Для
проверки Firebase Rules требуется Firebase CLI и JDK 21.

## Приватность

Описание обрабатываемых данных, cloud sync и удаления аккаунта:
[PRIVACY.md](PRIVACY.md). Приложение не содержит рекламных SDK и не использует
Firebase Analytics.

## Документация для команды

- [Карта экранов](docs/VIEW_MAP.md)
- [Настройка Apple Watch](docs/AppleWatch-Setup.md)
- [Чек-лист приватности для App Store](docs/AppStore-Privacy-Checklist.md)
