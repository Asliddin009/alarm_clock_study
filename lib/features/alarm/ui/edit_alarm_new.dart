import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAlarmScreen extends StatelessWidget {
  const CreateAlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание будильника'),
      ),
      body: Column(
        children: [
          //Выбор даты

          //создать
          ElevatedButton(
            onPressed: () {
              final List<Weekday> weekdays = [];
              context.read<AlarmBloc>().add(
                    CreateAlarmEvent(
                      dateTime: DateTime.now().add(const Duration(minutes: 10)),
                      isRepeat: true,
                      weekdays: weekdays,
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('data'),
          ),
        ],
      ),
    );
  }
}
