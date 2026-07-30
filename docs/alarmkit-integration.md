# Миграция `lib/features/alarm` на AlarmKit (iOS 26+)

Документ описывает переход с пакета `alarm` (`AlarmPlusRepo`) на системный AlarmKit
через плагин [`flutter_alarmkit`](https://pub.dev/packages/flutter_alarmkit).

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

### 4.3 Твой Flutter-экран — открывается по кнопке, но есть блокер

Задумка: кнопка в алерте открывает приложение через App Intent с
`openAppWhenRun`, и там показывается настоящий `AlarmRingScreen`.

**Плагин 0.4.0 этого не позволяет.** Проверено по его исходнику
`FlutterAlarmkitPlugin.swift`:

| Метод | Кнопки в алерте |
|---|---|
| `scheduleOneShotAlarm` (строка 576) | только `stopButton` |
| `scheduleRecurrentAlarm` (строка 842) | только `stopButton` |
| `setCountdownAlarm` (строка 699) | `stopButton` + `secondaryButton`, поведение `.countdown` |

Вторичная кнопка есть только у countdown-будильников, и её поведение жёстко
задано как `.countdown` (перезапуск отсчёта), а не `.custom` (запуск своего
интента). То есть приложение она не открывает даже там.

Варианты: форкнуть плагин и добавить `secondaryButtonBehavior: .custom` в сборку
`AlarmPresentation.Alert`, либо завести issue в апстрим. До этого рабочий
сценарий — пользователь жмёт системный Stop и открывает приложение сам,
а квиз ждёт его внутри.

Заготовки Swift и инструкция лежат в
[ios/AlarmkitWidgetCustom/](../ios/AlarmkitWidgetCustom/README.md).

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

- Если квиз не пройден в течение N минут — шлёшь локальное уведомление
  («Ты не забрал 50 очков за утро») или ставишь ещё один AlarmKit-алярм.
- Streak / очки (`pointsRepo` уже есть в проекте) как основной драйвер.
- Когда пользователь всё-таки откроет приложение, квиз встретит его сам:
  `AlarmService.findRingingAlarmId()` опрашивает систему на старте и на
  возврате из фона, так что экран открывается без всякой кнопки в алерте.

Будильник, который не звонит, учит английскому хуже, чем будильник, который
звонит, но который можно выключить.

---

## 5. Пошаговая установка

### 5.1 Xcode (одна ручная операция)

**Widget Extension.** File → New → Target → Widget Extension.
Имя: `AlarmkitWidget` — должно совпадать **точно**, плагин ищет по нему.
Отметить только **Live Activity**, снять «Include Configuration Intent».

Xcode 26 создаёт таргет с именем `AlarmkitWidgetExtension` и папкой
`AlarmkitWidget`. Список TARGETS живёт внутри редактора проекта (клик по синей
иконке `Runner` вверху навигатора), а не в файловом навигаторе.

### 5.1.1 App Groups: не подключаем

Инструкция плагина (`InstallationSteps.md`) требует App Group
`group.flutter-alarmkit` для обоих таргетов. **Сделать это невозможно**, и
причин две.

Главная: **проект подписывается бесплатным Apple ID** (персональная команда,
профили выпускаются на 7 дней). App Groups — функция платного Apple Developer
Program, на бесплатном аккаунте она недоступна в принципе, никакое имя группы
не подойдёт.

Вторая: даже на платном аккаунте конкретно `group.flutter-alarmkit` не
получить — идентификаторы App Group уникальны глобально во всей экосистеме
Apple, и этот уже занят чужим аккаунтом:

```
An Application Group with Identifier 'group.flutter-alarmkit' is not available.
Please enter a different string
```

Своё имя потребовало бы форка: плагин хардкодит идентификатор в
`FlutterAlarmkitPlugin.swift`, который лежит в pub-cache и перезаписывается при
каждом `flutter pub get`.

Группа используется ровно в одном месте — передать цвета заливки кнопок в
виджет (`loadButtonTints`). Без неё кнопки берут дефолтные цвета AlarmKit;
текст и иконки кнопок задаются через `AlarmButton` и работают, основной
tint-цвет идёт через `AlarmAttributes` и тоже работает.

Поэтому `group.flutter-alarmkit` удалён из
[Runner.entitlements](../ios/Runner/Runner.entitlements), а `--doctor` навсегда
останется с одним `[FAIL]` про entitlements и одним `[WARN]` про расширение.
Это осознанное отклонение, а не недоделка.

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

`setup` уже выполнен: он пропатчил [Info.plist](../ios/Runner/Info.plist),
добавил `FlutterImplicitEngineDelegate` в
[AppDelegate.swift](../ios/Runner/AppDelegate.swift), настроил entitlements и
переставил build phases. Осталась только ручная часть 5.1 — таргет и App Group.

> Повторный запуск `setup` сохраняет осознанные правки в `ios/AlarmkitWidget/`
> (перезаписать их можно только флагом `--force`). Но Xcode при создании
> таргета перетирает файлы виджета сам, поэтому порядок именно такой:
> сначала вся работа в Xcode, потом `setup` с закрытым Xcode.

#### Тексты разрешений

Плагин вписывает в Info.plist шаблонные английские строки; они заменены на
осмысленные русские. Отдельно стоит знать про два ключа:

```
NSBonjourServices        = _alarmkit._tcp
NSLocalNetworkUsageDescription
```

Плагин объявляет их обязательными и помечает как «required for AlarmKit local
network communication». Это выглядит ошибкой: AlarmKit работает целиком на
устройстве, а Live Activity общается через App Group и ActivityKit — сети там
нет. Ключи оставлены, чтобы `--doctor` не ругался, но перед релизом в App Store
их стоит попробовать убрать: иначе пользователь увидит запрос доступа к
локальной сети, никак не связанный с будильниками.

### 5.3 Кастомизация виджета

Заготовки и пошаговая инструкция вынесены в отдельную папку, чтобы `setup` и
Xcode их не задели:
[ios/AlarmkitWidgetCustom/](../ios/AlarmkitWidgetCustom/README.md).

Там же описан блокер из раздела 4.3 — без правки нативной части плагина кнопка
«Учить» в алерте не появится.

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
новое поле `nativeAlarmId`, см. 6.1. Реализация — в `AlarmKitRepo.ringStream`
и `AlarmKitRepo.getRingingAlarm()`, разбор идентификаторов — в 6.8.

---

## 6. Что изменено в коде проекта

Всё в этом разделе **уже реализовано**. Раздел оставлен как запись того, что
поменялось и почему.

Отправная точка: [alarmkit_repo.dart](../lib/features/alarm/data/alarmkit_repo.dart)
был закомментирован не случайно — он не собирался против тогдашних интерфейсов.
Три несовпадения пришлось устранить до раскомментирования.

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
  afconvert -f caff -d ima4 "assets/music/$f.mp3" "assets/music/$f.caf"
done
```

Кодек `ima4`, а не `LEI16` из README плагина: несжатый PCM раздул пять файлов
с 745 КБ до 10.4 МБ, IMA4 даёт 2.6 МБ при том же качестве. iOS принимает его
в системных звуках наравне с PCM.

Дефолт `AlarmEntity.defaultAudioAssetPath` **остался mp3**, и в
[pubspec.yaml](../pubspec.yaml) лежат оба набора. Причина: `.caf` — контейнер
Apple, а `AlarmPlusRepo` играет тот же ассет на Android через ExoPlayer.
Сущность хранит логический выбор звука, а `AlarmKitRepo._resolveAlarmKitSoundPath`
подменяет расширение на `.caf` при планировании. Если формат вообще незнакомый,
метод возвращает `null` — система сыграет свой звук, и это лучше, чем упавшее
планирование.

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

Реализовано без `device_info_plus`: вместо номера версии проверяется сама
способность плагина работать.

```dart
static Future<bool> _isAlarmKitAvailable() async {
  if (defaultTargetPlatform != TargetPlatform.iOS) return false;
  try {
    await alarmkit.FlutterAlarmkit().getPlatformVersion();
    return true;
  } on Object {
    return false;
  }
}
```

На iOS ниже 26 вызов кидает `PlatformException(UNSUPPORTED_VERSION)`, на других
платформах плагин не зарегистрирован и бросает `MissingPluginException`. Оба
случая означают «AlarmKit нет» — а проба ещё и переживёт смену минимальной
версии в будущих релизах плагина, в отличие от захардкоженной цифры 26.

### 6.7 Сверка состояния при старте

Главный приём против «работает через раз»: **системе верить больше, чем кэшу.**
`AlarmService.initialize()` сверяет `getScheduledAlarmKeys()` с
`SharedPrefAlarmCache` и чинит расхождения.

Одно важное отличие от первоначального замысла. Сначала логика **удаляла** из
кэша будильники, пропавшие из системы. Тест поймал последствие: сработавший
одноразовый будильник исчезал из списка. Хуже того, если
`getScheduledAlarmKeys()` вернёт пусто по внешней причине — переустановка
приложения, сброс хранилища пакета — стёрся бы весь список пользователя.

Поэтому сверка не удаляет ничего. Сработавший одноразовый будильник просто
переводится в `isActive: false` и остаётся в списке — ровно как в системных
«Часах». Ошибка опроса системы прерывает сверку целиком, ошибка на отдельном
будильнике не мешает остальным.

### 6.8 Определение звонящего будильника при холодном старте

`ringStream` ловит только те звонки, что случились при живом приложении. Когда
приложение открывают уже звонящим будильником, поток молчит.

Добавлен `IAlarmRepo.getRingingAlarm()` (у AlarmKit — поиск состояния
`alerting` в `getAlarms()`, у пакета `alarm` — `Alarm.ringing.valueOrNull`) и
`AlarmService.findRingingAlarmId()`. `AlarmScreen` вызывает его в `initState`
и при возврате из фона; флаг `_isRingScreenOpen` не даёт открыть экран квиза
дважды, когда звонок придёт и из потока, и из опроса.

---

## 7. Что осталось сделать

Код готов и покрыт тестами. Осталась ручная часть, которую нельзя выполнить из
командной строки:

1. **Xcode: создать Widget Extension и App Group** — раздел 5.1. Это блокирует
   всё остальное: без таргета `--doctor` не станет зелёным, а Live Activity
   не появится.
2. Закрыть Xcode, повторно выполнить `dart run flutter_alarmkit:setup`.
3. `cd ios && pod install`, затем `flutter run --release`.
4. Решить, что делать с блокером вторичной кнопки из раздела 4.3 — форк плагина
   или issue в апстрим.
5. Перед релизом попробовать убрать `NSBonjourServices` /
   `NSLocalNetworkUsageDescription` — см. 5.2.
6. Проверка на **физическом** устройстве с iOS 26: приложение выгружено из
   App Switcher, Low Power Mode, беззвучный режим, Focus. Симулятор для
   AlarmKit не показателен.

---

## 8. Ссылки

- [pub.dev/packages/flutter_alarmkit](https://pub.dev/packages/flutter_alarmkit)
- [github.com/gdelataillade/flutter_alarmkit](https://github.com/gdelataillade/flutter_alarmkit)
- [InstallationSteps.md](https://github.com/gdelataillade/flutter_alarmkit/blob/main/InstallationSteps.md)
- [Apple: AlarmKit](https://developer.apple.com/documentation/alarmkit)
