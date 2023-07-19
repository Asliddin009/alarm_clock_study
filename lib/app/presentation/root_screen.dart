import 'package:flutter/material.dart';

import '../../feature/auth/ui/components/auth_builder.dart';
import '../../feature/auth/ui/login_screen.dart';
import '../../feature/main/main_screen.dart';
import 'app_loader.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthBuilder(
      isNotAuthorized: (context) => LoginScreen(),
      isWaiting: (context) => const AppLoader(),
      isAuthorized: (context, value, child) => MainScreen(),
    );
  }
}
