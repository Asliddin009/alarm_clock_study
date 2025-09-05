import 'package:flutter/material.dart';

class AppConstrainedBox extends StatelessWidget {
  const AppConstrainedBox({
    required this.child,
    super.key,
    this.maxHeight = 600,
    this.maxWidth = 600,
    this.minWidth = 200,
    this.minHeight = 400,
  });
  final Widget child;
  final double maxHeight;
  final double maxWidth;
  final double minWidth;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
      ),
      child: child,
    );
  }
}
