import 'package:alearn/app/ui/theme/app_color.dart';
import 'package:flutter/material.dart';

abstract final class AppThemeData {
  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: ColorResource.forest,
      onPrimary: ColorResource.white,
      secondary: ColorResource.mint,
      onSecondary: ColorResource.black,
      error: ColorResource.danger,
      onError: ColorResource.white,
      surface: isDark ? ColorResource.darkSurface : ColorResource.lightSurface,
      onSurface: isDark ? ColorResource.white : ColorResource.black,
    );
    final baseTheme = ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      useMaterial3: true,
    );
    final textTheme = baseTheme.textTheme.copyWith(
      headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.8,
      ),
      headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.1,
      ),
      headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
        height: 1.45,
        color: isDark ? ColorResource.white : ColorResource.black,
      ),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
        height: 1.45,
        color: isDark
            ? ColorResource.white.withValues(alpha: 0.72)
            : ColorResource.black.withValues(alpha: 0.62),
      ),
      labelLarge: baseTheme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );

    return baseTheme.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: isDark
          ? ColorResource.darkScaffold
          : ColorResource.lightScaffold,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: isDark ? ColorResource.white : ColorResource.black,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: isDark ? ColorResource.white : ColorResource.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: ColorResource.forest,
          foregroundColor: ColorResource.white,
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: isDark ? ColorResource.white : ColorResource.black,
          side: BorderSide(
            color: isDark
                ? ColorResource.white.withValues(alpha: 0.12)
                : ColorResource.forest.withValues(alpha: 0.14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? ColorResource.mint : ColorResource.forest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ColorResource.forest,
        foregroundColor: ColorResource.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark
            ? ColorResource.darkSurface
            : ColorResource.white,
        indicatorColor: isDark
            ? ColorResource.forestAccent
            : ColorResource.mint.withValues(alpha: 0.35),
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          textTheme.labelMedium!.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? ColorResource.white : ColorResource.black,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? (isDark ? ColorResource.white : ColorResource.forest)
                : (isDark
                      ? ColorResource.white.withValues(alpha: 0.55)
                      : ColorResource.black.withValues(alpha: 0.45)),
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? ColorResource.darkSurfaceSecondary
            : ColorResource.lightSurfaceSecondary,
        hintStyle: textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark
                ? ColorResource.white.withValues(alpha: 0.08)
                : ColorResource.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark
                ? ColorResource.white.withValues(alpha: 0.08)
                : ColorResource.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: ColorResource.forest, width: 1.4),
        ),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: isDark
            ? ColorResource.darkSurfaceSecondary
            : ColorResource.lightSurfaceSecondary,
        selectedColor: isDark
            ? ColorResource.forestAccent
            : ColorResource.forest,
        secondarySelectedColor: ColorResource.forest,
        labelStyle: textTheme.bodyMedium,
        secondaryLabelStyle: textTheme.bodyMedium?.copyWith(
          color: ColorResource.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(
          color: isDark
              ? ColorResource.white.withValues(alpha: 0.08)
              : ColorResource.border,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(
          isDark ? ColorResource.white : ColorResource.white,
        ),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorResource.forest;
          }
          return isDark
              ? ColorResource.white.withValues(alpha: 0.16)
              : ColorResource.black.withValues(alpha: 0.10);
        }),
      ),
      cardTheme: CardThemeData(
        color: isDark ? ColorResource.darkSurface : ColorResource.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      dividerColor: isDark
          ? ColorResource.white.withValues(alpha: 0.08)
          : ColorResource.border,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? ColorResource.darkSurface
            : ColorResource.black,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: ColorResource.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
