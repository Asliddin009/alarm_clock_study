import 'package:alearn/app/app_runner/app_env.dart';
import 'package:alearn/app/app_runner/app_runner.dart';

AppRunner createProdRunner() => AppRunner(AppEnv.prod);

Future<void> main() async {
  await createProdRunner().run();
}
