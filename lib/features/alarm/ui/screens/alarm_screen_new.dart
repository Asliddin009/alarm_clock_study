import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/app_container.dart';
import 'package:alearn/app/ui/ui_kit/app_entrance.dart';
import 'package:alearn/app/ui/ui_kit/app_snack_bar.dart';
import 'package:alearn/di/app_dependencies_scope.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/domain/entity/alarm_entity.dart';
import 'package:alearn/features/alarm/ui/screens/edit_alarm_new.dart';
import 'package:alearn/features/alarm/ui/widgets/shortcut_button.dart';
import 'package:alearn/features/alarm/ui/widgets/tile.dart';
import 'package:alearn/features/ring/ring_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({
    super.key,
    this.permissionsReadyLoader,
    this.requestPermissionsHandler,
    this.openSettingsHandler,
  });

  final Future<bool> Function()? permissionsReadyLoader;
  final Future<void> Function()? requestPermissionsHandler;
  final Future<void> Function()? openSettingsHandler;

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> with WidgetsBindingObserver {
  StreamSubscription<AlarmSettings>? _ringStreamSubscription;
  late Future<bool> _permissionsFuture;
  int _reloadSeed = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permissionsFuture = _loadPermissionsReady();
    _ringStreamSubscription = context.read<AlarmBloc>().ringStream.listen(
      _openRingScreen,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshPermissionsState());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ringStreamSubscription?.cancel();
    super.dispose();
  }

  Future<bool> _loadPermissionsReady() {
    return widget.permissionsReadyLoader?.call() ?? _hasAlarmPermissions();
  }

  Future<bool> _hasAlarmPermissions() async {
    try {
      final trackedStatuses = <PermissionStatus>[
        await Permission.notification.status,
      ];
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        trackedStatuses.add(await Permission.scheduleExactAlarm.status);
      }
      return trackedStatuses.every(
        (status) =>
            status.isGranted || status.isLimited || status.isProvisional,
      );
    } on Object {
      return false;
    }
  }

  Future<void> _refreshPermissionsState() async {
    setState(() {
      _reloadSeed += 1;
      _permissionsFuture = _loadPermissionsReady();
    });
  }

  Future<void> _requestPermissions() async {
    final localization = LocalizationHelper.getLocalizations(context);

    try {
      if (widget.requestPermissionsHandler != null) {
        await widget.requestPermissionsHandler!.call();
      } else {
        await AppDependenciesScope.of(context).alarmRepo.requestPermissions();
      }
      await _refreshPermissionsState();
      final isReady = await _permissionsFuture;
      if (!mounted) {
        return;
      }
      if (isReady) {
        AppSnackBar.showSuccess(context, localization.alarm_permissions_ready);
      } else {
        AppSnackBar.showInfo(context, localization.alarm_permissions_missing);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.showError(context, error.toString());
    }
  }

  Future<void> _openSystemSettings() async {
    if (widget.openSettingsHandler != null) {
      await widget.openSettingsHandler!.call();
    } else {
      await openAppSettings();
    }
    await _refreshPermissionsState();
  }

  Future<void> _openRingScreen(AlarmSettings alarmSettings) async {
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AlarmRingScreen(alarmId: alarmSettings.id),
      ),
    );
    if (!mounted) {
      return;
    }
    context.read<AlarmBloc>().add(const AlarmRefreshRequested());
    setState(() => _reloadSeed += 1);
  }

  Future<void> _showPreviewDialog(AlarmEntity alarm) async {
    final localization = LocalizationHelper.getLocalizations(context);
    final session = await AppDependenciesScope.of(
      context,
    ).ringQuestionService.buildSessionForAlarm(alarm);
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localization.alarm_preview_title),
          content: SizedBox(
            width: 420,
            child: session == null || session.previewItems.isEmpty
                ? Text(localization.alarm_preview_empty)
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.alarm_preview_subtitle,
                          style: Theme.of(dialogContext).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ...session.previewItems.asMap().entries.map((entry) {
                          final item = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  entry.key == session.previewItems.length - 1
                                  ? 0
                                  : 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(dialogContext)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('${entry.key + 1}'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.sourceText,
                                        style: Theme.of(
                                          dialogContext,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.targetText,
                                        style: Theme.of(
                                          dialogContext,
                                        ).textTheme.bodyLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${localization.alarm_preview_category_label}: ${item.categoryName}',
                                        style: Theme.of(
                                          dialogContext,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                MaterialLocalizations.of(dialogContext).okButtonLabel,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAlarm(AlarmEntity alarm) async {
    await AppDependenciesScope.of(context).alarmService.deleteAlarm(alarm.id);
    if (!mounted) {
      return;
    }
    context.read<AlarmBloc>().add(const AlarmRefreshRequested());
    setState(() => _reloadSeed += 1);
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);

    return BlocConsumer<AlarmBloc, AlarmState>(
      listener: (context, state) {
        if (state is AlarmErrorState) {
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final alarms = state.alarms;
        final isLoading = state is AlarmLoadingState && alarms.isEmpty;

        return Scaffold(
          appBar: AppBar(title: Text(localization.alarm)),
          body: SafeArea(
            bottom: false,
            child: FutureBuilder<bool>(
              future: _permissionsFuture,
              key: ValueKey<int>(_reloadSeed),
              builder: (context, snapshot) {
                if (isLoading ||
                    snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final hasPermissions = snapshot.data ?? false;
                if (!hasPermissions) {
                  return _PermissionGate(
                    onRequestPermissions: _requestPermissions,
                    onOpenSettings: _openSystemSettings,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: alarms.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.only(bottom: 168),
                          children: [
                            const SizedBox(height: 8),
                            AppEntrance(
                              child: AppContainer(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localization.no_alarms,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      localization.alarm_empty_subtitle,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 168),
                          itemCount: alarms.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final alarm = alarms[index];
                            return AppEntrance(
                              delay: Duration(milliseconds: 80 + (index * 40)),
                              child: AlarmTile(
                                alarm: alarm,
                                onPressed: () => _openEditScreen(alarm),
                                onPreviewPressed: () =>
                                    _showPreviewDialog(alarm),
                                onDismissed: () => _deleteAlarm(alarm),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 120),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ExampleAlarmHomeShortcutButton(),
                FloatingActionButton(
                  heroTag: 'create-alarm',
                  onPressed: () => _openEditScreen(null),
                  child: const Icon(Icons.alarm_add_rounded, size: 32),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Future<void> _openEditScreen(AlarmEntity? alarm) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreateAlarmScreen(initialAlarm: alarm),
      ),
    );
    if (!mounted) {
      return;
    }
    context.read<AlarmBloc>().add(const AlarmRefreshRequested());
    setState(() => _reloadSeed += 1);
  }
}

class _PermissionGate extends StatelessWidget {
  const _PermissionGate({
    required this.onRequestPermissions,
    required this.onOpenSettings,
  });

  final Future<void> Function() onRequestPermissions;
  final Future<void> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
        child: AppEntrance(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: AppContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.alarm_permissions_title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    localization.alarm_permissions_subtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    localization.alarm_permissions_missing,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('alarm-request-permissions-button'),
                      onPressed: onRequestPermissions,
                      child: Text(localization.alarm_request_permissions),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onOpenSettings,
                      child: Text(localization.open_settings),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
