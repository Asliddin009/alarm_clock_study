import 'package:alearn/di/app_dependencies.dart';
import 'package:flutter/widgets.dart';

final class AppDependenciesScope extends InheritedWidget {
  const AppDependenciesScope({
    required this.appDependencies,
    required super.child,
    super.key,
  });

  final AppDependencies appDependencies;

  static AppDependencies of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppDependenciesScope>();
    assert(scope != null, 'AppDependenciesScope not found in widget tree.');
    return scope!.appDependencies;
  }

  @override
  bool updateShouldNotify(covariant AppDependenciesScope oldWidget) {
    return appDependencies != oldWidget.appDependencies;
  }
}
