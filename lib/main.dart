import 'package:alearn/app/app_runner/app_env.dart';
import 'package:alearn/app/app_runner/app_runner.dart';

AppRunner createMainRunner() => AppRunner(AppEnv.test);

Future<void> main() async {
  await createMainRunner().run();
}
