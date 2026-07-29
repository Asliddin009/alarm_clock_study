import 'package:alearn/app/ui/theme/app_color.dart';
import 'package:flutter/material.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaseAppBar({
    required this.title,
    super.key,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.showBackButton,
    this.onBackPressed,
    this.actions,
    this.bottom,
    this.centerTitle = false,
    this.backgroundColor,
  });

  final String title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? leading;
  final bool? showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool centerTitle;
  final Color? backgroundColor;

  static const double _horizontalPadding = 20;
  static const double _rowHeight = 48;
  static const double _subtitleExtra = 22;
  static const double _bottomExtra = 68;

  @override
  Size get preferredSize => Size.fromHeight(
    24 +
        _rowHeight +
        (subtitle != null ? _subtitleExtra : 0) +
        (bottom != null ? _bottomExtra : 0),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resolvedShowBack = showBackButton ?? Navigator.of(context).canPop();
    final hasLeading = leading != null || resolvedShowBack;

    final titleColor = isDark ? ColorResource.white : ColorResource.black;
    final subtitleColor = isDark
        ? ColorResource.white.withValues(alpha: 0.6)
        : ColorResource.muted;

    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            _horizontalPadding,
            12,
            _horizontalPadding,
            12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: _rowHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (leading != null)
                      leading!
                    else if (resolvedShowBack)
                      BaseAppBarIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap:
                            onBackPressed ??
                            () => Navigator.of(context).maybePop(),
                      ),
                    if (hasLeading) const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: centerTitle
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          titleWidget ??
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineMedium
                                    ?.copyWith(color: titleColor),
                              ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (actions != null)
                      ...actions!.map(
                        (action) =>
                            Padding(padding: const EdgeInsets.only(left: 8), child: action),
                      ),
                  ],
                ),
              ),
              if (bottom != null) ...[const SizedBox(height: 14), bottom!],
            ],
          ),
        ),
      ),
    );
  }
}

class BaseAppBarIconButton extends StatelessWidget {
  const BaseAppBarIconButton({
    required this.icon,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark
          ? ColorResource.darkSurfaceSecondary
          : ColorResource.lightSurfaceSecondary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: isDark ? ColorResource.white : ColorResource.forest,
            ),
          ),
        ),
      ),
    );
  }
}
