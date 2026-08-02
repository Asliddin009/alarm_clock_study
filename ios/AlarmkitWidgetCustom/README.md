# Кастомизация виджета AlarmKit

Файлы здесь — **не** собираемая часть проекта. Это заготовки, которые
переносятся в `ios/AlarmkitWidget/` после того, как таргет Widget Extension
создан в Xcode. Лежат отдельно, чтобы `dart run flutter_alarmkit:setup` их не
трогал и чтобы Xcode не конфликтовал с именем папки при создании таргета.

## Порядок

1. В Xcode создать таргет Widget Extension с именем **ровно** `AlarmkitWidget`
   (File → New → Target → Widget Extension, отметить только Live Activity).
2. App Group **не подключаем** — см. ниже.
3. Закрыть Xcode, выполнить `dart run flutter_alarmkit:setup`.
4. Скопировать `StudyIntent.swift` в `ios/AlarmkitWidget/` и добавить файл в
   таргет `AlarmkitWidgetExtension`.
5. Применить патч ниже к `ios/AlarmkitWidget/AlarmkitWidgetLiveActivity.swift`.

## Патч AlarmControls

В `struct AlarmControls`, в ветке `case .alert`, шаблон плагина вешает на
вторичную кнопку `RepeatIntent` — перезапуск обратного отсчёта. Для будильника
это бесполезно, кнопка должна открывать приложение.

Было:

```swift
case .alert:
    if let btn = presentation.alert.secondaryButton {
        ButtonView(config: btn,
                   intent: RepeatIntent(alarmID: state.alarmID.uuidString),
                   tint: repeatTint)
    }
```

Стало:

```swift
case .alert:
    if let btn = presentation.alert.secondaryButton {
        ButtonView(config: btn,
                   intent: StudyIntent(alarmID: state.alarmID.uuidString),
                   tint: repeatTint)
    }
```

## Чтобы вторичная кнопка вообще появилась

`AlarmControls` рисует её только при непустом `presentation.alert.secondaryButton`.
Плагин 0.4.0 заполняет это поле лишь для countdown-будильников, а обычные
`scheduleOneShotAlarm` / `scheduleRecurrentAlarm` создают алерт с одной кнопкой
Stop.

То есть кастомная кнопка «Учить» требует правки нативной части плагина
(`FlutterAlarmkitPlugin.swift`, сборка `AlarmPresentation.Alert`) — либо через
форк, либо через issue в апстрим. Без этого рабочий сценарий такой: пользователь
жмёт системный Stop, открывает приложение сам, и там его ждёт квиз с накопленными
очками.

Проверять `openAppWhenRun` обязательно на физическом устройстве с iOS 26 —
в симуляторе AlarmKit ведёт себя иначе.

## Почему нет App Group

Плагин требует App Group с захардкоженным идентификатором
`group.flutter-alarmkit`. Получить его нельзя по двум причинам.

Главная: проект подписывается **бесплатным Apple ID** (персональная команда,
профили на 7 дней). App Groups — функция платного Developer Program.

Вторая: даже на платном аккаунте это конкретное имя занято — идентификаторы
App Group уникальны глобально во всей экосистеме Apple. Xcode отвечает
«An Application Group with Identifier 'group.flutter-alarmkit' is not
available».

Своё имя вроде `group.com.alearn.mobile` потребовало бы правки двух
захардкоженных строк, одна из которых —
`ios/flutter_alarmkit/Sources/flutter_alarmkit/FlutterAlarmkitPlugin.swift` —
живёт в pub-cache и стирается при каждом `flutter pub get`. То есть форк плагина.

Цена отказа минимальна. Группа используется ровно в одном месте — передать
цвета заливки кнопок в виджет (`loadButtonTints`). Без неё кнопки берут
дефолтные цвета AlarmKit. Всё остальное — планирование, звуки, Live Activity,
основной tint-цвет через `AlarmAttributes` — работает как обычно.

Из-за этого `--doctor` навсегда останется с одним `[FAIL]` про entitlements и
одним `[WARN]` про расширение. Это осознанное отклонение, а не недоделка.
