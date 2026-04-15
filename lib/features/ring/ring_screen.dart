import 'package:alearn/app/ui/ui_kit/app_snack_bar.dart';
import 'package:alearn/di/app_dependencies_scope.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/ring/domain/ring_question_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlarmRingScreen extends StatelessWidget {
  const AlarmRingScreen({
    required this.alarmId,
    this.questionService,
    super.key,
  });

  final int alarmId;
  final RingQuestionService? questionService;

  @override
  Widget build(BuildContext context) {
    final alarm = _findAlarm(context.watch<AlarmBloc>().state.alarms);
    final resolvedQuestionService =
        questionService ?? AppDependenciesScope.of(context).ringQuestionService;

    return Scaffold(
      appBar: AppBar(title: const Text('Пора просыпаться')),
      body: SafeArea(
        child: FutureBuilder<RingQuestion?>(
          future: resolvedQuestionService.buildQuestionForAlarm(alarm),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final question = snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    alarm == null
                        ? 'Будильник уже не найден, но звонок можно безопасно остановить.'
                        : 'Будильник ${alarm.formattedTime}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (question == null)
                    const Text(
                      'Вопрос для квиза сейчас недоступен. Можно выключить будильник вручную.',
                    )
                  else ...[
                    Text(
                      question.prompt,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ...question.options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ElevatedButton(
                          onPressed: () => _handleAnswer(
                            context,
                            option: option,
                            correctAnswer: question.correctAnswer,
                          ),
                          child: Text(option),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => _stopAlarm(context),
                    child: const Text('Остановить будильник'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  AlarmEntity? _findAlarm(List<AlarmEntity> alarms) {
    for (final alarm in alarms) {
      if (alarm.id == alarmId) {
        return alarm;
      }
    }
    return null;
  }

  void _handleAnswer(
    BuildContext context, {
    required String option,
    required String correctAnswer,
  }) {
    if (option != correctAnswer) {
      AppSnackBar.showInfo(context, 'Неверно, попробуйте ещё раз.');
      return;
    }
    _stopAlarm(context);
  }

  void _stopAlarm(BuildContext context) {
    context.read<AlarmBloc>().add(AlarmDeleteRequested(alarmId));
    Navigator.of(context).pop();
  }
}
