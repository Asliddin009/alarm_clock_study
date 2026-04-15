import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:flutter/material.dart';

class AlarmTile extends StatelessWidget {
  const AlarmTile({
    required this.alarm,
    required this.onPressed,
    this.onDismissed,
    super.key,
  });

  final AlarmEntity alarm;
  final VoidCallback onPressed;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<String>('alarm-${alarm.id}'),
      direction: onDismissed == null
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDismissed?.call(),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          onTap: onPressed,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            alarm.formattedTime,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          subtitle: alarm.weekdays.isEmpty
              ? null
              : Text(
                  alarm.weekdays
                      .map((weekday) => weekday.shortLabel)
                      .join(', '),
                ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
