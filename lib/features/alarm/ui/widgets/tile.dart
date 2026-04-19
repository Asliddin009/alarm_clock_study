import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/app_container.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:flutter/material.dart';

class AlarmTile extends StatelessWidget {
  const AlarmTile({
    required this.alarm,
    required this.onPressed,
    required this.onPreviewPressed,
    this.onDismissed,
    super.key,
  });

  final AlarmEntity alarm;
  final VoidCallback onPressed;
  final VoidCallback onPreviewPressed;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);

    return Dismissible(
      key: ValueKey<String>('alarm-${alarm.id}'),
      direction: onDismissed == null
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDismissed?.call(),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onPressed,
        child: AppContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.formattedTime,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      alarm.weekdays.isEmpty
                          ? localization.alarm_one_time
                          : alarm.weekdays
                                .map((weekday) => weekday.shortLabel)
                                .join(', '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localization.alarm_categories_value(
                        alarm.listCategoryIds.length,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onPreviewPressed,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.visibility_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
