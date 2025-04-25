import 'package:alearn/di/app_depends.dart';
import 'package:flutter/widgets.dart';

final class AppDependsProvider extends InheritedWidget {
  const AppDependsProvider({
    required super.child,
    required this.appDepends,
    super.key,
  });
  final AppDepends appDepends;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
  static AppDepends of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppDependsProvider>();
    assert(provider != null, 'Depends not found');
    return provider!.appDepends;
  }
}
