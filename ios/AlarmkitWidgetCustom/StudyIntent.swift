import AlarmKit
import AppIntents
import Foundation

/// Кнопка «Учить» в алерте будильника.
///
/// В отличие от `StopIntent` из шаблонов плагина, намеренно НЕ вызывает
/// `AlarmManager.shared.stop` — звук продолжается, пока пользователь не пройдёт
/// мини-квиз в приложении. Остановкой управляет Flutter-сторона через
/// `AlarmService.dismissRingingAlarm`.
///
/// `openAppWhenRun` поднимает приложение на передний план. Дальше Flutter сам
/// определяет, какой будильник звонит, — через `getAlarms()` и состояние
/// `alerting`, поэтому передавать alarmID в приложение не требуется.
@available(iOS 26.0, *)
public struct StudyIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Учить слова"
    public static var description = IntentDescription(
        "Открывает приложение с заданием по английскому"
    )
    public static var openAppWhenRun: Bool { true }

    @Parameter(title: "alarmID")
    public var alarmID: String

    public init(alarmID: String) {
        self.alarmID = alarmID
    }

    public init() {
        self.alarmID = ""
    }

    public func perform() throws -> some IntentResult {
        return .result()
    }
}
