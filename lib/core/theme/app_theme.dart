import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// "The Engineer's Notebook" — Minimalist-Technical design system.
///
/// Both brightnesses are built from the palette classes directly (never from
/// the brightness-dispatching [AppColors] facade) so constructing a
/// [ThemeData] has no side effects on the active palette.
abstract final class AppTheme {
  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    surface: AppDarkPalette.surface,
    surfaceDim: AppDarkPalette.surfaceDim,
    surfaceBright: AppDarkPalette.surfaceBright,
    surfaceContainerLowest: AppDarkPalette.surfaceContainerLowest,
    surfaceContainerLow: AppDarkPalette.surfaceContainerLow,
    surfaceContainer: AppDarkPalette.surfaceContainer,
    surfaceContainerHigh: AppDarkPalette.surfaceContainerHigh,
    surfaceContainerHighest: AppDarkPalette.surfaceContainerHighest,
    onSurface: AppDarkPalette.onSurface,
    onSurfaceVariant: AppDarkPalette.onSurfaceVariant,
    inverseSurface: AppDarkPalette.inverseSurface,
    onInverseSurface: AppDarkPalette.inverseOnSurface,
    outline: AppDarkPalette.outline,
    outlineVariant: AppDarkPalette.outlineVariant,
    surfaceTint: AppDarkPalette.surfaceTint,
    primary: AppDarkPalette.primary,
    onPrimary: AppDarkPalette.onPrimary,
    primaryContainer: AppDarkPalette.primaryContainer,
    onPrimaryContainer: AppDarkPalette.onPrimaryContainer,
    inversePrimary: AppDarkPalette.inversePrimary,
    secondary: AppDarkPalette.secondary,
    onSecondary: AppDarkPalette.onSecondary,
    secondaryContainer: AppDarkPalette.secondaryContainer,
    onSecondaryContainer: AppDarkPalette.onSecondaryContainer,
    tertiary: AppDarkPalette.tertiary,
    onTertiary: AppDarkPalette.onTertiary,
    tertiaryContainer: AppDarkPalette.tertiaryContainer,
    onTertiaryContainer: AppDarkPalette.onTertiaryContainer,
    error: AppDarkPalette.error,
    onError: AppDarkPalette.onError,
    errorContainer: AppDarkPalette.errorContainer,
    onErrorContainer: AppDarkPalette.onErrorContainer,
    primaryFixed: AppDarkPalette.primaryFixed,
    primaryFixedDim: AppDarkPalette.primaryFixedDim,
    onPrimaryFixed: AppDarkPalette.onPrimaryFixed,
    onPrimaryFixedVariant: AppDarkPalette.onPrimaryFixedVariant,
    secondaryFixed: AppDarkPalette.secondaryFixed,
    secondaryFixedDim: AppDarkPalette.secondaryFixedDim,
    onSecondaryFixed: AppDarkPalette.onSecondaryFixed,
    onSecondaryFixedVariant: AppDarkPalette.onSecondaryFixedVariant,
    tertiaryFixed: AppDarkPalette.tertiaryFixed,
    tertiaryFixedDim: AppDarkPalette.tertiaryFixedDim,
    onTertiaryFixed: AppDarkPalette.onTertiaryFixed,
    onTertiaryFixedVariant: AppDarkPalette.onTertiaryFixedVariant,
  );

  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    surface: AppLightPalette.surface,
    surfaceDim: AppLightPalette.surfaceDim,
    surfaceBright: AppLightPalette.surfaceBright,
    surfaceContainerLowest: AppLightPalette.surfaceContainerLowest,
    surfaceContainerLow: AppLightPalette.surfaceContainerLow,
    surfaceContainer: AppLightPalette.surfaceContainer,
    surfaceContainerHigh: AppLightPalette.surfaceContainerHigh,
    surfaceContainerHighest: AppLightPalette.surfaceContainerHighest,
    onSurface: AppLightPalette.onSurface,
    onSurfaceVariant: AppLightPalette.onSurfaceVariant,
    inverseSurface: AppLightPalette.inverseSurface,
    onInverseSurface: AppLightPalette.inverseOnSurface,
    outline: AppLightPalette.outline,
    outlineVariant: AppLightPalette.outlineVariant,
    surfaceTint: AppLightPalette.surfaceTint,
    primary: AppLightPalette.primary,
    onPrimary: AppLightPalette.onPrimary,
    primaryContainer: AppLightPalette.primaryContainer,
    onPrimaryContainer: AppLightPalette.onPrimaryContainer,
    inversePrimary: AppLightPalette.inversePrimary,
    secondary: AppLightPalette.secondary,
    onSecondary: AppLightPalette.onSecondary,
    secondaryContainer: AppLightPalette.secondaryContainer,
    onSecondaryContainer: AppLightPalette.onSecondaryContainer,
    tertiary: AppLightPalette.tertiary,
    onTertiary: AppLightPalette.onTertiary,
    tertiaryContainer: AppLightPalette.tertiaryContainer,
    onTertiaryContainer: AppLightPalette.onTertiaryContainer,
    error: AppLightPalette.error,
    onError: AppLightPalette.onError,
    errorContainer: AppLightPalette.errorContainer,
    onErrorContainer: AppLightPalette.onErrorContainer,
    primaryFixed: AppLightPalette.primaryFixed,
    primaryFixedDim: AppLightPalette.primaryFixedDim,
    onPrimaryFixed: AppLightPalette.onPrimaryFixed,
    onPrimaryFixedVariant: AppLightPalette.onPrimaryFixedVariant,
    secondaryFixed: AppLightPalette.secondaryFixed,
    secondaryFixedDim: AppLightPalette.secondaryFixedDim,
    onSecondaryFixed: AppLightPalette.onSecondaryFixed,
    onSecondaryFixedVariant: AppLightPalette.onSecondaryFixedVariant,
    tertiaryFixed: AppLightPalette.tertiaryFixed,
    tertiaryFixedDim: AppLightPalette.tertiaryFixedDim,
    onTertiaryFixed: AppLightPalette.onTertiaryFixed,
    onTertiaryFixedVariant: AppLightPalette.onTertiaryFixedVariant,
  );

  static TextTheme _textTheme(Color bodyColor) => TextTheme(
    headlineLarge: AppTypography.headlineLg,
    headlineMedium: AppTypography.headlineMd,
    bodyLarge: AppTypography.bodyLg,
    bodyMedium: AppTypography.bodyMd,
    labelMedium: AppTypography.labelMono,
  ).apply(bodyColor: bodyColor, displayColor: bodyColor);

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    colorScheme: darkColorScheme,
    background: AppDarkPalette.background,
    onSurface: AppDarkPalette.onSurface,
    onSurfaceVariant: AppDarkPalette.onSurfaceVariant,
    outlineVariant: AppDarkPalette.outlineVariant,
    cardColor: AppDarkPalette.elevationLevel1,
    cardBorder: AppDarkPalette.elevationLevel1Border,
    primaryContainer: AppDarkPalette.primaryContainer,
    onPrimaryContainer: AppDarkPalette.onPrimaryContainer,
    primary: AppDarkPalette.primary,
  );

  static ThemeData get light => _build(
    brightness: Brightness.light,
    colorScheme: lightColorScheme,
    background: AppLightPalette.background,
    onSurface: AppLightPalette.onSurface,
    onSurfaceVariant: AppLightPalette.onSurfaceVariant,
    outlineVariant: AppLightPalette.outlineVariant,
    cardColor: AppLightPalette.elevationLevel1,
    cardBorder: AppLightPalette.elevationLevel1Border,
    primaryContainer: AppLightPalette.primaryContainer,
    onPrimaryContainer: AppLightPalette.onPrimaryContainer,
    primary: AppLightPalette.primary,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color background,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outlineVariant,
    required Color cardColor,
    required Color cardBorder,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color primary,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: _textTheme(onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        titleTextStyle: AppTypography.headlineMd.copyWith(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusBase,
          side: BorderSide(color: cardBorder),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: outlineVariant,
        thickness: 1,
        space: 1,
      ),
      // Primary: solid Signal Amber with dark text, bold typography.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: onPrimaryContainer,
          elevation: 0,
          textStyle: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusBase),
        ),
      ),
      // Secondary: transparent with a 1px border, amber text.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: cardBorder),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusBase),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
          side: BorderSide(color: outlineVariant),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: AppTypography.bodyMd.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusBase),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: outlineVariant,
        circularTrackColor: outlineVariant,
      ),
    );
  }

  /// True when [platformBrightness] should render with the dark palette.
  /// `ThemeMode.system` follows the OS setting; the explicit modes ignore it.
  static Brightness resolveBrightness(
    ThemeMode mode,
    Brightness platformBrightness,
  ) {
    switch (mode) {
      case ThemeMode.system:
        return platformBrightness;
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
    }
  }
}
