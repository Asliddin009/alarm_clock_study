import 'dart:ui';

import 'package:flutter/material.dart';

Future<T?> showBaseModalBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  Color? backgroundColor,
  double borderRadius = 16,
}) async {
  return showModalBottomSheet<T>(
    barrierColor: Theme.of(context).bottomSheetTheme.shadowColor,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    context: context,
    backgroundColor: backgroundColor,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.4, sigmaY: 1.4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
          ),
          color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        ),
        child: child,
      ),
    ),
  );
}
