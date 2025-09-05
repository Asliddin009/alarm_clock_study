abstract class UtilsDateTime {
  static String getHourAndMinute(DateTime date) {
    final hour = date.hour < 10 ? '0${date.hour}' : date.hour.toString();
    final minute =
        date.minute < 10 ? '0${date.minute}' : date.minute.toString();
    return '$hour:$minute';
  }
}
