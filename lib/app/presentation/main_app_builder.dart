import 'package:alarm_study/app/presentation/root_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feature/auth/domain/auth_state/auth_cubit.dart';
import '../domain/app_builder.dart';
import '../domain/di/init_di.dart';

class MainAppBuilder implements AppBuilder {
  @override
  Widget buildApp() {
    return const _GlobalProviders(
      child: MaterialApp(home: RootScreen()),
    );
  }
}

class _GlobalProviders extends StatelessWidget {
  const _GlobalProviders({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => locator.get<AuthCubit>(),
      ),
    ], child: child);
  }
}
