import 'package:alearn/app/localization/app_localizations.dart';
import 'package:alearn/app/ui/theme/app_theme.dart';
import 'package:alearn/di/app_dependencies.dart';
import 'package:alearn/di/app_dependencies_scope.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
import 'package:alearn/features/alarm/ui/screens/alarm_screen_new.dart';
import 'package:alearn/features/auth/domain/bloc/auth_bloc.dart';
import 'package:alearn/features/category/domain/cubit/category_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({required this.appDependencies, super.key});

  final AppDependencies appDependencies;

  @override
  Widget build(BuildContext context) {
    return AppDependenciesScope(
      appDependencies: appDependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(appDependencies.authRepo),
          ),
          BlocProvider<AlarmBloc>(
            create: (_) =>
                AlarmBloc(alarmService: appDependencies.alarmService)
                  ..add(const AlarmStarted()),
          ),
          BlocProvider<CategoryCubit>(
            create: (_) =>
                CategoryCubit(appDependencies.categoryRepo)..getCategories(),
          ),
        ],
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemeData.light(),
      darkTheme: AppThemeData.dark(),
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AlarmScreen(),
    );
  }
}
