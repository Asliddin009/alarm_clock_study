import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/ui/widgets/edit_alarm_tile.dart';
import 'package:alearn/features/alarm/ui/widgets/time_picker.dart';
import 'package:alearn/features/alarm/ui/widgets/weekday_picker.dart';
import 'package:alearn/features/category/domain/cubit/category_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CreateAlarmScreen extends StatefulWidget {
  const CreateAlarmScreen({
    this.initialAlarm,
    super.key,
  });

  final AlarmEntity? initialAlarm;

  @override
  State<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends State<CreateAlarmScreen> {
  late DateTime _selectedDateTime;
  late bool _isRepeat;
  late List<Weekday> _selectedWeekdays;
  late Set<int> _selectedCategoryIds;

  @override
  void initState() {
    super.initState();
    final initialDate = widget.initialAlarm?.time ?? DateTime.now().add(
          const Duration(minutes: 1),
        );
    _selectedDateTime = initialDate.copyWith(second: 0, millisecond: 0);
    _isRepeat = widget.initialAlarm?.isRepeat ?? false;
    _selectedWeekdays = <Weekday>[
      ...?widget.initialAlarm?.weekdays,
    ];
    _selectedCategoryIds = <int>{
      ...?widget.initialAlarm?.listCategoryIds,
    };
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final isEditing = widget.initialAlarm != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактирование будильника' : localization.create_alarm),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            EditItemWidget(
              title: localization.date,
              leadingIcon: Icons.calendar_today_outlined,
              trailing: Text(
                DateFormat('dd.MM.yyyy').format(_selectedDateTime),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            AlarmTimePickerField(
              value: _selectedDateTime,
              onChanged: (value) => setState(() => _selectedDateTime = value),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: SwitchListTile(
                value: _isRepeat,
                title: const Text('Повторять'),
                onChanged: (value) => setState(() => _isRepeat = value),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Дни недели',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    WeekdayPicker(
                      selectedWeekdays: _selectedWeekdays,
                      onChanged: (value) => setState(() {
                        _selectedWeekdays = value;
                        _isRepeat = value.isNotEmpty || _isRepeat;
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _CategorySelector(
              selectedCategoryIds: _selectedCategoryIds,
              onChanged: (value) => setState(() => _selectedCategoryIds = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveAlarm,
              child: Text(isEditing ? 'Сохранить изменения' : 'Создать'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) {
      return;
    }
    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  void _saveAlarm() {
    if (widget.initialAlarm == null) {
      context.read<AlarmBloc>().add(
            AlarmCreateRequested(
              dateTime: _selectedDateTime,
              isRepeat: _isRepeat,
              weekdays: _selectedWeekdays,
              categoryIds: _selectedCategoryIds.toList(growable: false),
            ),
          );
    } else {
      context.read<AlarmBloc>().add(
            AlarmUpdateRequested(
              widget.initialAlarm!.copyWith(
                time: _selectedDateTime,
                isRepeat: _isRepeat,
                weekdays: _selectedWeekdays,
                listCategoryIds: _selectedCategoryIds.toList(growable: false),
              ),
            ),
          );
    }
    Navigator.of(context).pop();
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.selectedCategoryIds,
    required this.onChanged,
  });

  final Set<int> selectedCategoryIds;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        final categories = state.categories;
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Категории для квиза',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (categories.isEmpty)
                  const Text('Категории загрузятся автоматически.')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected =
                          selectedCategoryIds.contains(category.id);
                      return FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (_) {
                          final updated = <int>{...selectedCategoryIds};
                          if (isSelected) {
                            updated.remove(category.id);
                          } else {
                            updated.add(category.id);
                          }
                          onChanged(updated);
                        },
                      );
                    }).toList(growable: false),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
