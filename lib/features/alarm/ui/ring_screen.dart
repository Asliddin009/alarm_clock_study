// ignore_for_file: unused_import

import 'package:alarm/alarm.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/category/domain/cubit/category_cubit.dart';
import 'package:alearn/features/category/domain/entity/word_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlarmRingScreen extends StatefulWidget {
  const AlarmRingScreen({required this.alarmSettings, required this.alarmEntity, super.key});
  final AlarmEntity alarmEntity;
  final AlarmSettings alarmSettings;

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  final List<WordEntity> words = [];

  @override
  void initState() {
    // words = context.read<CategoryCubit>().getWordsFromCategory(widget.alarmEntity.listCategoryId);
    // FlutterRingtonePlayer().play(
    //   ios: IosSounds.glass,
    //   fromAsset: widget.alarmSettings.assetAudioPath,
    //   looping: true, // Android only - API >= 28
    //   volume: 1, // Android only - API >= 28
    //   asAlarm: true, // Android only - all APIs
    // );
    super.initState();
  }

  WordEntity getRandomWord() {
    words.shuffle();
    return words.first;
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
            ...getRandomWord().examplesRu.map((word) => CupertinoButton(child: Text(word), onPressed: () {}))
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     RawMaterialButton(
            //       onPressed: () {
            //         final now = DateTime.now();
            //         Alarm.set(
            //           alarmSettings: widget.alarmSettings.copyWith(
            //             dateTime: DateTime(
            //               now.year,
            //               now.month,
            //               now.day,
            //               now.hour,
            //               now.minute,
            //             ).add(const Duration(minutes: 1)),
            //           ),
            //         ).then((_) {
            //           if (context.mounted) Navigator.pop(context);
            //         });
            //       },
            //       child: Text(
            //         'Snooze',
            //         style: Theme.of(context).textTheme.titleLarge,
            //       ),
            //     ),
            //     RawMaterialButton(
            //       onPressed: () {
            //         Alarm.stop(widget.alarmSettings.id).then((_) {
            //           if (context.mounted) Navigator.pop(context);
            //         });
            //       },
            //       child: Text(
            //         'Stop',
            //         style: Theme.of(context).textTheme.titleLarge,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
