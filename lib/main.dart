import 'package:flutter/material.dart';

import 'app/presentation/main_app_builder.dart';
import 'app/presentation/main_app_runner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const env = String.fromEnvironment("env", defaultValue: "test");
  const runner = MainAppRunner(env);
  final builder = MainAppBuilder();
  runner.run(builder);
}


