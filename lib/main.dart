import 'package:alearn/app/app_runner/app_env.dart';
import 'package:alearn/app/app_runner/app_runner.dart';

void main() async {
  await AppRuner(AppEnv.test).run();
}
