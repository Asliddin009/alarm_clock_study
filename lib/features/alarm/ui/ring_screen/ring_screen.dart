// ignore_for_file: unused_import

import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/category/domain/cubit/category_cubit.dart';
import 'package:alearn/features/category/domain/entity/word_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class AlarmRingScreen extends StatefulWidget {
  const AlarmRingScreen({required this.alarmSettings, required this.alarmEntity, super.key});
  final AlarmEntity alarmEntity;
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
    FlutterRingtonePlayer().play(
      android: AndroidSounds.alarm,
      ios: IosSounds.alarm,
      looping: true, // Android only - API >= 28
      volume: 0.7, // Android only - API >= 28
      asAlarm: true, // Android only - all APIs
    );
    super.initState();
  }

  List<WordEntity> getWords() {
    try {
      // final categoryId = widget.alarmEntity.listCategoryId.first;
      // final categoryState = context.read<CategoryCubit>().state as CategoryDoneState;
      // final category = categoryState.listCategory.firstWhere((element) => element.id == categoryId);
      // return category.wordList;
      return [];
    } on Exception catch (e) {
      log(e.toString(), name: 'AlarmRingScreen getWords');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Выберите правильный перевод слова Alarm',
              style: Theme.of(context).textTheme.titleLarge,
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
      ),
    );
  }
}
