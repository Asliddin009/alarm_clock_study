import 'package:flutter/material.dart';

class AppContainer extends StatelessWidget {
  const AppContainer({
    super.key,
    this.color,
    this.borderRadius = 28,
    this.child,
    this.height,
    this.padding,
    this.margin,
    this.width,
    this.borderColor,
    this.shadow,
  });

  final Color? color;
  final double borderRadius;
  final double? height;
  final double? width;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(18),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        border: Border.all(
          color:
              borderColor ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.06)),
        ),
        boxShadow:
            shadow ??
            <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
      ),
      child: child,
    );
  }
}
