import 'package:alearn/app/localization/app_localizations.dart';
import 'package:alearn/app/ui/theme/light_theme.dart';
import 'package:alearn/di/app_depends.dart';
import 'package:alearn/di/app_depends_provider.dart';
import 'package:alearn/features/alarm/data/shared_pref_alarm_cache.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/ui/alarm_screen/alarm_screen_new.dart';
import 'package:alearn/features/auth/domain/bloc/auth_bloc.dart';
import 'package:alearn/features/category/domain/cubit/category_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({required this.appDepends, super.key});
  final AppDepends appDepends;
  @override
  Widget build(BuildContext context) {
    return AppDependsProvider(
      key: const ValueKey('AppDependsProvider'),
      appDepends: appDepends,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) => AuthBloc(appDepends.authRepo),
          ),
          BlocProvider(
            create: (BuildContext context) => AlarmBloc(alarmRepo: appDepends.alarmRepo, alarmCashRepo: SharedPrefAlarmCache())..add(AlarmInitialEvent()),
          ),
          BlocProvider(
            create: (BuildContext context) => CategoryCubit(appDepends.categoryRepo)..getCategories(),
          ),
        ],
        child: const _App(),
      ),
    );
  }
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AlarmScreen(),
    );
  }
}
