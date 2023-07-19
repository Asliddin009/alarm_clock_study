import 'package:flutter/cupertino.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/app_builder.dart';
import '../domain/app_runner.dart';
import '../domain/di/init_di.dart';

class MainAppRunner implements AppRunner {
  final String env;

  const MainAppRunner(this.env);

  @override
  Future<void> preloadData() async {
    // init app
    initDi(env);
    // init config
  }

  @override
  Future<void> run(AppBuilder appBuilder) async {
    WidgetsFlutterBinding.ensureInitialized();
    HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: await getApplicationDocumentsDirectory());
        await preloadData();
        runApp(appBuilder.buildApp());
  }
}
