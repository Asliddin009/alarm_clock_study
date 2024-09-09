import 'ui_kit/theme/light_theme.dart';
import '../di/app_depends.dart';
import '../di/app_depends_provider.dart';
import '../features/alarm/domain/cubit/alarm_cubit.dart';
import '../features/alarm/ui/alarm_screen.dart';
import '../features/auth/domain/bloc/auth_bloc.dart';
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
            create: (BuildContext context) => AlarmCubit(appDepends.alarmRepo),
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
      home: const ExampleAlarmHomeScreen(),
    );
  }
}
