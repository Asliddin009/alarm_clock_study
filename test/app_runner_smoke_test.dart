import 'package:alearn/app/app_runner/app_env.dart';
import 'package:alearn/di/app_dependencies.dart';
import 'package:alearn/main.dart' as main_entry;
import 'package:alearn/main_prod.dart' as prod_entry;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default entrypoint uses test environment', () {
    expect(main_entry.createMainRunner().appEnv, AppEnv.test);
  });

  test('prod entrypoint uses prod environment', () {
    expect(prod_entry.createProdRunner().appEnv, AppEnv.prod);
  });

  test('prod dependencies fail fast with unsupported error', () async {
    await expectLater(
      () => AppDependencies.create(AppEnv.prod),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
