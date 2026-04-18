import 'package:alearn/app/app_flow/domain/app_flow_cubit.dart';
import 'package:alearn/app/app_flow/domain/app_flow_state.dart';
import 'package:alearn/app/app_flow/ui/app_flow_screen.dart';
import 'package:alearn/app/localization/app_localizations.dart';
import 'package:alearn/app/ui/theme/app_theme.dart';
import 'package:alearn/di/app_dependencies.dart';
import 'package:alearn/di/app_dependencies_scope.dart';
import 'package:alearn/features/alarm/domain/bloc/alarm_bloc.dart';
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
          BlocProvider<AppFlowCubit>(
            create: (_) => AppFlowCubit(
              authRepo: appDependencies.authRepo,
              appPreferencesRepo: appDependencies.appPreferencesRepo,
            )..initialize(),
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
    return BlocBuilder<AppFlowCubit, AppFlowState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppThemeData.light(),
          darkTheme: AppThemeData.dark(),
          locale: state.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppFlowScreen(),
        );
      },
    );
  }
}
