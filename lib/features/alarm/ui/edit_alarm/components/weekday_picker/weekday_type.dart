enum WeekdayType {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String getName() {
    switch (this) {
      case WeekdayType.monday:
        return 'Понедельник';
      case WeekdayType.tuesday:
        return 'Вторник';
      case WeekdayType.wednesday:
        return 'Среда';
      case WeekdayType.thursday:
        return 'Четверг';
      case WeekdayType.friday:
        return 'Пятница';
      case WeekdayType.saturday:
        return 'Суббота';
      case WeekdayType.sunday:
        return 'Воскресенье';
    }
  }

  String getShortName() {
    switch (this) {
      case WeekdayType.monday:
        return 'Пн';
      case WeekdayType.tuesday:
        return 'Вт';
      case WeekdayType.wednesday:
        return 'Ср';
      case WeekdayType.thursday:
        return 'Чт';
      case WeekdayType.friday:
        return 'Пт';
      case WeekdayType.saturday:
        return 'Сб';
      case WeekdayType.sunday:
        return 'Вс';
    }
  }
}
