import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/category/domain/cubit/category_cubit.dart';
import 'package:alearn/features/category/domain/entity/word_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class AlarmRingScreen extends StatefulWidget {
  const AlarmRingScreen({required this.alarmSettings, super.key});
  final AlarmSettings alarmSettings;

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  late final List<WordEntity> words;

  @override
  void initState() {
    words = getWords();
    log(words.toString(), name: 'before');
    words.shuffle();
    log(words.toString(), name: 'after');
    super.initState();
  }

  List<WordEntity> getWords() {
    try {
      return [];
    } on Exception catch (e) {
      log(e.toString(), name: 'AlarmRingScreen getWords');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Выберите правильный перевод слова Alarm',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          BlocBuilder<AlarmBloc, AlarmState>(
            builder: (context, state) {
              if (state is AlarmDoneState) {
                final alarm = state.listAlarm.firstWhere((element) => element.id == widget.alarmSettings.id);
                return Text('time ${alarm.time.hour}:${alarm.time.minute} weekdays: ${alarm.weekdays}  categoryId${alarm.listCategoryId}');
              }
              return const Text('loading');
            },
          ),
          BlocBuilder<CategoryCubit, CategoryState>(builder: (context, state) => Text(state.toString())),
          ElevatedButton(
            onPressed: () {
              context.read<AlarmBloc>().add(AlarmGetAllEvent());
              context.read<CategoryCubit>().getCategories();
            },
            child: const Text('getAlarm and word'),
          ),
          ElevatedButton(
            onPressed: () {
              FlutterRingtonePlayer().stop();
              context.read<AlarmBloc>().add(AlarmDeleteEvent(widget.alarmSettings.id));
            },
            child: const Text('replace after 15 seconds'),
          ),
          RawMaterialButton(
            onPressed: () {
              //выключить рингтон
              FlutterRingtonePlayer().stop();
              //ивент чтобы выключить будильник
              context.read<AlarmBloc>().add(AlarmDeleteEvent(widget.alarmSettings.id));
              Navigator.pop(context);
            },
            child: Text(
              'Stop',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
