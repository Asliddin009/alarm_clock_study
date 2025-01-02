import 'package:flutter/material.dart';

class DayOfWeekSelector extends StatefulWidget {
  const DayOfWeekSelector({super.key});

  @override
  DayOfWeekSelectorState createState() => DayOfWeekSelectorState();
}

class DayOfWeekSelectorState extends State<DayOfWeekSelector> {
  String? selectedDay; // Переменная для хранения выбранного дня

  // Список дней недели
  final List<String> daysOfWeek = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedDay, // Текущий выбранный день
      hint: const Text('Выберите день недели'),
      onChanged: (String? value) {
        setState(() {
          selectedDay = value;
        });
      },
      items: daysOfWeek.map((String day) {
        return DropdownMenuItem<String>(
          value: day,
          child: Text(day),
        );
      }).toList(),
    );
  }
}

class WrapContainer extends StatelessWidget {
  const WrapContainer({
    required this.text,
    required this.selected,
    super.key,
    this.onTap,
    this.height,
    this.width,
  });
  final String text;
  final bool selected;
  final void Function()? onTap;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 40,
        width: width ?? 40,
        decoration: BoxDecoration(
          color: selected ? Colors.amber : Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}
