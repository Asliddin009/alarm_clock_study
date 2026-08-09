# Миграция `lib/features/alarm` на AlarmKit (iOS 26+)

Документ описывает переход с пакета `alarm` (`AlarmPlusRepo`) на системный AlarmKit
через плагин [`flutter_alarmkit`](https://pub.dev/packages/flutter_alarmkit).

> **Статус: миграция выполнена, кроме двух шагов в Xcode GUI.**
> Код, ассеты и конфиги на месте; `AlarmKitRepo` выбирается в рантайме на
> iOS 26+, `AlarmPlusRepo` остаётся фолбэком. Что осталось — раздел 7.

---

## 1. Почему текущий будильник «работает через раз»

Пакет `alarm` не использует системный планировщик — на iOS его просто нет для
третьих приложений. Механика такая:

1. Приложение держит фоновую аудиосессию (`UIBackgroundModes: audio` в
   [Info.plist](../ios/Runner/Info.plist)) и проигрывает тишину, чтобы iOS не
   убила процесс.
2. По внутреннему таймеру в нужный момент включается звук будильника.
3. Параллельно ставится локальное уведомление как запасной вариант.

Отсюда все сбои, и все они — не баги пакета, а следствие модели iOS:

| Причина | Что происходит |
|---|---|
| Пользователь свайпнул приложение из App Switcher | процесс убит, таймер мёртв, остаётся только уведомление |
| iOS выгрузила приложение под нехватку памяти | то же самое |
| Low Power Mode | агрессивно душит фоновое аудио |
| Беззвучный режим / Focus / DND | уведомление приходит тихо или откладывается |
| Долгий сон устройства без зарядки | фоновая сессия может быть прервана |

Никакой настройкой это не чинится. Нужен системный API.

---

## 2. Что даёт AlarmKit

`AlarmKit` — фреймворк Apple из iOS 26. Будильник регистрируется **в системе**,
приложению не нужно жить в фоне.

- ✅ Срабатывает, даже если приложение выгружено или убито
- ✅ Пробивает беззвучный режим и Focus **без** Critical Alerts entitlement
  (то есть без запроса особого разрешения у Apple)
- ✅ Полноэкранный алерт на локскрине + Live Activity в Dynamic Island
- ✅ Системный звук будильника и вибрация
- ✅ Нативные повторяющиеся будильники по дням недели

Ограничения:

- ❌ Только iOS 26+ (iPhone 11 / SE 2020 и новее)
- ❌ Требует Xcode 26+, Flutter 3.38.0+
- ❌ **UI алерта не кастомизируется** — подробно в разделе 4

---

## 3. Анализ `flutter_alarmkit` 0.4.0

Плагин от `gdelataillade` — того же автора, что и пакет `alarm`, который сейчас
используется в проекте. То есть это преемник, а не сторонняя альтернатива.

**Состояние на июль 2026:** версия 0.4.0, ~1.3k загрузок в неделю, 160 pub points,
26 лайков, MIT. Молодой, но активно развивается. Мажорной версии ещё нет — API
может ломаться, версию стоит пинить точно (`flutter_alarmkit: 0.4.0`).

### API, которое понадобится

```dart
final alarmkit = FlutterAlarmkit();

// Разрешения
await alarmkit.requestAuthorization();
await alarmkit.getAuthorizationState();

// Планирование — возвращают String alarmId (UUID)
await alarmkit.scheduleOneShotAlarm(
  timestamp: dateTime.millisecondsSinceEpoch.toDouble(),
  label: 'Подъём',
  tintColor: '#1F6F5C',
  soundPath: 'assets/music/marimba.caf', // .caf/.aiff/.wav, < 30 сек
  metadata: AlarmMetadata(icon: 'book.fill', subtitle: '5 слов до отключения'),
  uiConfig: AlarmUIConfig(
    stopButton: AlarmButtonConfig(
      text: 'Учить',
      icon: 'book.fill',
      textColor: '#FFFFFF',
      tintColor: '#1F6F5C',
    ),
  ),
);

await alarmkit.scheduleRecurrentAlarm(
  weekdays: {Weekday.monday, Weekday.wednesday},
  hour: 7, minute: 30, label: '...',
);

// Чтение состояния — источник правды
final alarms = await alarmkit.getAlarms();        // List<Alarm> со state
alarmkit.alarmUpdates().listen((AlarmUpdateEvent e) { /* added/updated/removed */ });

// Управление
await alarmkit.cancelAlarm(alarmId: id);  // bool
await alarmkit.stopAlarm(alarmId: id);    // bool
await alarmkit.cancelAll();
```

`AlarmState`: `scheduled`, `countdown`, `paused`, `alerting`, `unknown`.

### Чего в плагине нет

- **Snooze** — из коробки не поддержан. `secondaryButton` в alert-состоянии
  замаплен на `RepeatIntent` (перезапуск countdown), а не на отложить.
  Реализуется руками, см. раздел 5.
- **Открытие приложения по тапу** — в шаблонах виджета этого нет. Тоже
  дорабатывается руками, см. раздел 5.
- **Android** — плагин iOS-only. Для Android остаётся `alarm` или
  `android_alarm_manager_plus`.

---

## 4. Главный вопрос: можно ли показать там экран изучения английского?

Короткий ответ: **частично, и не так, как сейчас работает `AlarmRingScreen`.**

Нужно разделить три разные поверхности:

### 4.1 Полноэкранный системный алерт — НЕ кастомизируется

Когда будильник звонит и телефон заблокирован, iOS рисует **свой** экран
будильника. Ты управляешь только:

- заголовком (`label`)
- иконкой SF Symbol и подзаголовком (`AlarmMetadata`)
- текстом/цветом/иконкой кнопок (`AlarmUIConfig` / `AlarmButtonConfig`)
- tint-цветом

Вставить туда Flutter-виджет, карточку со словом или поле ввода **нельзя**.
Это процесс SpringBoard, а не твоё приложение.

### 4.2 Live Activity (локскрин + Dynamic Island) — кастомизируется, но это SwiftUI

Файлы виджета плагин копирует в твой проект (`ios/AlarmkitWidget/`), и это
**твой исходник** — правишь как хочешь. Но фундаментальные ограничения WidgetKit:

- Только SwiftUI. Flutter-рендера там нет и не будет.
- Никакого текстового ввода, скролла, жестов. Только кнопки через App Intents.
- Обновления только через ActivityKit, не в реальном времени.

Что реально можно сделать: показать **слово и перевод** текстом, и 2–4 кнопки-
варианта ответа. То есть примитивный квиз «выбери перевод» — да, реализуем.
Полноценный `AlarmRingScreen` со сессией вопросов, очками и снек-барами — нет.

### 4.3 Твой Flutter-экран — открывается по кнопке

Рабочий путь: кнопка в алерте/Live Activity открывает приложение, и уже там
показывается настоящий `AlarmRingScreen`. Делается через App Intent с
`openAppWhenRun` — код в разделе 5.3.

### 4.4 Ключевой компромисс, который надо принять осознанно

**В AlarmKit кнопка Stop обязательна и всегда останавливает будильник.**
`AlarmPresentation.Alert` требует `stopButton`. Пользователь всегда может
выключить будильник, не решив ни одного задания.

Сейчас на пакете `alarm` у тебя другая механика: открывается твой полноэкранный
Flutter-экран, и выключить будильник можно только пройдя квиз. Эту «принудиловку»
AlarmKit **отнимает**.

Выбор такой:

| | Надёжность срабатывания | Принудительный квиз |
|---|---|---|
| Пакет `alarm` (сейчас) | низкая — «работает через раз» | да |
| AlarmKit | высокая — системный уровень | нет, Stop всегда доступен |

Мой совет: брать AlarmKit и заменить принуждение на мотивацию —

- Stop останавливает звук, но приложение открывается на квизе через
  `openAppWhenRun` на второй кнопке (сделай её основной, яркой: «Учить»).
- Если квиз не пройден в течение N минут — шлёшь локальное уведомление
  («Ты не забрал 50 очков за утро») или ставишь ещё один AlarmKit-алярм.
- Streak / очки (`pointsRepo` уже есть в проекте) как основной драйвер.

Будильник, который не звонит, учит английскому хуже, чем будильник, который
звонит, но который можно выключить.

---

## 5. Пошаговая установка

### 5.1 Xcode (две ручные операции)

Значения должны совпадать **точно** — плагин ищет их по имени.

1. **Widget Extension.** File → New → Target → Widget Extension.
   Имя: `AlarmkitWidget`. Отметить только **Live Activity**, снять
   «Include Configuration Intent».
2. **App Groups.** Для обоих таргетов — `Runner` и `AlarmkitWidgetExtension` —
   Signing & Capabilities → + Capability → App Groups → добавить
   `group.flutter-alarmkit`.
   Без этого не работают кастомные цвета кнопок.

### 5.2 Автоматическая настройка

Закрыть Xcode, затем:

```bash
flutter pub add flutter_alarmkit && dart run flutter_alarmkit:setup
```

Скрипт сам: патчит `Info.plist` ключами AlarmKit, добавляет
`FlutterImplicitEngineDelegate` в [AppDelegate.swift](../ios/Runner/AppDelegate.swift),
копирует Swift-шаблоны в `ios/AlarmkitWidget/`, настраивает entitlements и
порядок build phases.

Проверка:

```bash
dart run flutter_alarmkit:setup --doctor
```

Должно быть всё зелёное до первой сборки.

> ⚠️ Повторный запуск `setup` перезаписывает файлы в `ios/AlarmkitWidget/`.
> Все правки из 5.3 после этого придётся накатывать заново — держи их в git и
> сверяйся с диффом.

### 5.3 Кастомизация: кнопка, открывающая приложение

В `ios/AlarmkitWidget/AppIntents.swift` добавить свой интент:

```swift
@available(iOS 26.0, *)
public struct StudyIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Учить слова"
    public static var openAppWhenRun: Bool { true }   // ← поднимает приложение

    @Parameter(title: "alarmID")
    public var alarmID: String

    public init(alarmID: String) { self.alarmID = alarmID }
    public init() { self.alarmID = "" }

    public func perform() throws -> some IntentResult {
        // Намеренно НЕ вызываем AlarmManager.shared.stop — звук продолжается,
        // пока пользователь не пройдёт квиз в приложении.
        return .result()
    }
}
```

В `ios/AlarmkitWidget/AlarmkitWidgetLiveActivity.swift`, в `AlarmControls`,
заменить маппинг вторичной кнопки в состоянии `.alert`:

```swift
case .alert:
    if let btn = presentation.alert.secondaryButton {
        ButtonView(config: btn,
                   intent: StudyIntent(alarmID: state.alarmID.uuidString),
                   tint: repeatTint)
    }
```

> Поведение `openAppWhenRun` на `LiveActivityIntent` обязательно проверить на
> реальном устройстве с iOS 26 — в симуляторе AlarmKit ведёт себя иначе.

### 5.4 Как приложение понимает, какой будильник звонит

Не нужен ни method channel, ни App Group UserDefaults. Плагин отдаёт состояние
сам — на старте и на резюме приложения:

```dart
final alarms = await FlutterAlarmkit().getAlarms();
final ringing = alarms.where((a) => a.state == AlarmState.alerting).firstOrNull;
if (ringing != null) {
  // открыть AlarmRingScreen для соответствующего AlarmEntity
}
```

Плюс живой поток, пока приложение открыто:

```dart
FlutterAlarmkit().alarmUpdates().listen((event) { /* ... */ });
```

Матчинг `alarmId` (UUID из AlarmKit) на твой `AlarmEntity.id` (int) — через
новое поле `nativeAlarmId`, см. 6.1.

---

## 6. Что править в коде проекта

Текущий [alarmkit_repo.dart](../lib/features/alarm/data/alarmkit_repo.dart)
закомментирован не случайно — он не собирается против нынешних интерфейсов.
Три несовпадения, которые надо устранить **до** раскомментирования.

### 6.1 `AlarmEntity` не хранит нативный id

Закомментированный код зовёт `alarm.copyWith(nativeAlarmId: ...)`, но такого
поля в [alarm_entity.dart](../lib/features/alarm/domain/entity/alarm_entity.dart)
нет. AlarmKit выдаёт UUID-строку, и без неё нельзя ни отменить, ни остановить
будильник.

Добавить `final String? nativeAlarmId` в конструктор, `copyWith`, `toJson`,
`fromJson` и `props`. Поле обязано переживать перезапуск — оно уже пишется в
`SharedPrefAlarmCache`, так что достаточно сериализации.

### 6.2 `IAlarmRepo` протекает типами пакета `alarm`

[i_alarm_repo.dart](../lib/features/alarm/domain/repo/i_alarm_repo.dart)
импортирует `package:alarm/alarm.dart` ради `Stream<AlarmSettings> ringStream`.
Доменный интерфейс не должен знать про конкретный пакет — из-за этого
`AlarmKitRepo` и не может его реализовать.

Заменить на доменное событие, например `Stream<int> ringStream` (id будильника)
или маленький `AlarmRingEvent`. Тот же импорт убрать из
[alarm_service.dart](../lib/features/alarm/domain/service/alarm_service.dart)
и из `AlarmBloc`.

### 6.3 Методы репозитория должны возвращать обновлённую сущность

Сейчас `scheduleAlarm` возвращает `Future<void>`, а `deleteAlarm(int id)` не
принимает нативный id. Новая сигнатура:

```dart
abstract interface class IAlarmRepo {
  Future<void> requestPermissions();
  Stream<int> get ringStream;

  Future<AlarmEntity> scheduleAlarm({
    required AlarmEntity alarm,
    required String notificationTitle,
    required String notificationBody,
  });

  Future<AlarmEntity> updateAlarm({ /* то же */ });

  Future<void> deleteAlarm({required int id, String? nativeAlarmId});
  Future<void> stopAlarm({required int id, String? nativeAlarmId});
}
```

В [alarm_service.dart](../lib/features/alarm/domain/service/alarm_service.dart)
соответственно сохранять в кэш **результат** вызова, а не исходную сущность:

```dart
final scheduled = await _alarmRepo.scheduleAlarm(alarm: alarm, ...);
await _alarmCacheRepo.save(scheduled);   // ← с nativeAlarmId
```

Иначе UUID потеряется и будильник станет неотменяемым «призраком».

### 6.4 Звуки надо переконвертировать

AlarmKit принимает только `.caf` / `.aiff` / `.wav` до 30 секунд. В
[pubspec.yaml](../pubspec.yaml) сейчас пять `.mp3`. Текущий
`_resolveAlarmKitSoundPath` молча возвращает `null` для mp3 — то есть все
будильники зазвонят дефолтным системным звуком.

```bash
for f in mozart nokia one_piece star_wars marimba; do
  afconvert -f caff -d LEI16@44100 "assets/music/$f.mp3" "assets/music/$f.caf"
done
```

Файлы добавить в `assets:` и переключить `AlarmEntity.defaultAudioAssetPath`.

### 6.5 Повторяющиеся будильники: убрать ручное перепланирование

`scheduleRecurrentAlarm` держит повтор на системном уровне. Логика в
`AlarmService.dismissRingingAlarm`, которая сейчас разбирает
`isRepeat || weekdays.isNotEmpty`, должна для AlarmKit-ветки просто вызывать
`stopAlarm` и не трогать расписание.

### 6.6 Выбор реализации в DI

В [app_dependencies.dart](../lib/di/app_dependencies.dart:77) сейчас:

```dart
final alarmRepo = kIsWeb
    ? const UnsupportedAlarmRepo(platformName: 'web')
    : AlarmPlusRepo(permissionService: const AlarmPermissionService());
```

Заменить на проверку версии iOS в рантайме (`device_info_plus`), с фолбэком:

```dart
final alarmRepo = switch (await _resolvePlatform()) {
  _Platform.web       => const UnsupportedAlarmRepo(platformName: 'web'),
  _Platform.ios26Plus => AlarmKitRepo(permissionService: const AlarmPermissionService()),
  _                   => AlarmPlusRepo(permissionService: const AlarmPermissionService()),
};
```

Проверять именно версию ОС, а не `Platform.isIOS`: на iOS 25 и ниже любой вызов
плагина кидает `PlatformException(code: 'UNSUPPORTED_VERSION')`.

### 6.7 Сверка состояния при старте

Главный приём против «работает через раз»: **системе верить больше, чем кэшу.**
При каждом запуске приложения сверять `getAlarms()` с `SharedPrefAlarmCache` —
удалять из кэша будильники, которых нет в системе, и перепланировать активные,
которые из системы пропали. Логичное место — `AlarmService.initialize()`.

---

## 7. Что сделано и что осталось

### Сделано

- [x] `IAlarmRepo` больше не импортирует `package:alarm` — ring-стрим отдаёт
      доменный `Stream<int>`, `scheduleAlarm`/`updateAlarm` возвращают сущность,
      `deleteAlarm`/`stopAlarm` принимают нативный id (6.1–6.3).
- [x] `AlarmEntity.nativeAlarmId` сериализуется и переживает перезапуск.
- [x] Звуки сконвертированы в `.caf` (IMA4, 2.6 МБ на пять файлов) и
      объявлены в `pubspec.yaml` рядом с `.mp3` (6.4).
- [x] `flutter_alarmkit: 0.4.0` добавлен, `dart run flutter_alarmkit:setup`
      отработал: `Info.plist`, `AppDelegate.swift`, `Runner.entitlements`,
      `ios/AlarmkitWidget/`, порядок build phases.
- [x] `AlarmKitRepo` написан под новые сигнатуры и работает.
- [x] DI выбирает реализацию рантайм-проверкой (6.6), сверка состояния с
      системой — в `AlarmService.syncWithSystem` (6.7).
- [x] Повторяющиеся будильники: AlarmKit держит расписание сам, а на
      `AlarmPlusRepo` `AlarmService` перевзводит их после звонка.

### Осталось

- [ ] **Xcode GUI, шаг 1:** создать Widget Extension `AlarmkitWidget` (5.1).
- [ ] **Xcode GUI, шаг 2:** App Group `group.flutter-alarmkit` на оба таргета.
- [ ] Закрыть Xcode → `dart run flutter_alarmkit:setup` → `--doctor` зелёный.
- [ ] Кастомный `StudyIntent` с `openAppWhenRun` (5.3) — правится только после
      того, как таргет виджета существует.
- [ ] Проверка на **физическом** устройстве с iOS 26: приложение выгружено из
      App Switcher, Low Power Mode, беззвучный режим, Focus.

### Чем проверялось

На симуляторе iOS 26.5 будильник планируется через AlarmKit и получает UUID,
который остаётся тем же после `simctl terminate` и перезапуска — то есть
расписание живёт в системе, а не в процессе приложения. На iOS 18.6 DI
уходит в `AlarmPlusRepo`, будильник звонит и открывает `AlarmRingScreen`.

---

## 8. Ссылки

- [pub.dev/packages/flutter_alarmkit](https://pub.dev/packages/flutter_alarmkit)
- [github.com/gdelataillade/flutter_alarmkit](https://github.com/gdelataillade/flutter_alarmkit)
- [InstallationSteps.md](https://github.com/gdelataillade/flutter_alarmkit/blob/main/InstallationSteps.md)
- [Apple: AlarmKit](https://developer.apple.com/documentation/alarmkit)
