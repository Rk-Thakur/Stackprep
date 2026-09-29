import 'package:flutter/material.dart';

/// Dark palette — "Obsidian Terminal". The fully-specified, primary palette
/// from DESIGN.md: a warm near-black surface ramp with Signal Amber reserved
/// for primary actions, progress, and high-importance highlights.
abstract final class AppDarkPalette {
  static const surface = Color(0xFF191209);
  static const surfaceDim = Color(0xFF191209);
  static const surfaceBright = Color(0xFF40382D);
  static const surfaceContainerLowest = Color(0xFF130D05);
  static const surfaceContainerLow = Color(0xFF211A11);
  static const surfaceContainer = Color(0xFF251E15);
  static const surfaceContainerHigh = Color(0xFF30291E);
  static const surfaceContainerHighest = Color(0xFF3C3429);
  static const onSurface = Color(0xFFEEE0D0);
  static const onSurfaceVariant = Color(0xFFD7C4AC);
  static const inverseSurface = Color(0xFFEEE0D0);
  static const inverseOnSurface = Color(0xFF372F25);
  static const outline = Color(0xFF9F8E78);
  static const outlineVariant = Color(0xFF524533);
  static const surfaceTint = Color(0xFFFFBA43);
  static const surfaceVariant = Color(0xFF3C3429);

  /// Signal Amber — reserved strictly for primary actions, progress, and
  /// high-importance highlights.
  static const primary = Color(0xFFFFD597);
  static const onPrimary = Color(0xFF432C00);
  static const primaryContainer = Color(0xFFFFB000);
  static const onPrimaryContainer = Color(0xFF6A4700);
  static const inversePrimary = Color(0xFF805600);
  static const primaryFixed = Color(0xFFFFDDAF);
  static const primaryFixedDim = Color(0xFFFFBA43);
  static const onPrimaryFixed = Color(0xFF281800);
  static const onPrimaryFixedVariant = Color(0xFF614000);

  static const secondary = Color(0xFFC8C6C5);
  static const onSecondary = Color(0xFF313030);
  static const secondaryContainer = Color(0xFF4A4949);
  static const onSecondaryContainer = Color(0xFFBAB8B7);
  static const secondaryFixed = Color(0xFFE5E2E1);
  static const secondaryFixedDim = Color(0xFFC8C6C5);
  static const onSecondaryFixed = Color(0xFF1C1B1B);
  static const onSecondaryFixedVariant = Color(0xFF474646);

  static const tertiary = Color(0xFFDBDBDB);
  static const onTertiary = Color(0xFF2F3131);
  static const tertiaryContainer = Color(0xFFBFBFBF);
  static const onTertiaryContainer = Color(0xFF4C4E4E);
  static const tertiaryFixed = Color(0xFFE2E2E2);
  static const tertiaryFixedDim = Color(0xFFC6C6C7);
  static const onTertiaryFixed = Color(0xFF1A1C1C);
  static const onTertiaryFixedVariant = Color(0xFF454747);

  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);

  static const background = Color(0xFF191209);
  static const onBackground = Color(0xFFEEE0D0);

  // Elevation reference values from the "Elevation & Depth" section
  // (tonal layering, no shadows).
  static const elevationLevel0 = Color(0xFF121212);
  static const elevationLevel1 = Color(0xFF1E1E1E);
  static const elevationLevel1Border = Color(0xFF2A2A2A);
  static const elevationLevel2 = Color(0xFF252525);

  static const codeBlockBackground = Color(0xFF1A1A1A);
  static const codeLineNumber = Color(0xFF4A4A4A);

  // Semantic snackbar signal colors ("Obsidian Terminal" component spec).
  static const errorRed = Color(0xFFF44336);
  static const warningOrange = Color(0xFFFF9800);
  static const infoBlue = Color(0xFF2196F3);
}

/// Light palette — the same warm hue family with the value structure
/// inverted: crisp off-white surfaces, warm-grey borders, and a deep amber
/// for Signal Amber so accent *text* stays legible on a light page.
///
/// The key inversion versus [AppDarkPalette]: `primary` is a pale cream in
/// dark mode because it is mostly read as text on dark surfaces, while its
/// `primaryContainer` is the solid amber used for filled buttons. In light
/// mode `primary` becomes the deep amber (readable as text on off-white) and
/// `primaryContainer` stays the solid amber fill.
abstract final class AppLightPalette {
  static const surface = Color(0xFFFDF9F2);
  static const surfaceDim = Color(0xFFF3EADC);
  static const surfaceBright = Color(0xFFFFFFFF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF8F2E8);
  static const surfaceContainer = Color(0xFFF3EADC);
  static const surfaceContainerHigh = Color(0xFFEDE2D1);
  static const surfaceContainerHighest = Color(0xFFE7DBC7);
  static const onSurface = Color(0xFF241B10);
  static const onSurfaceVariant = Color(0xFF5B4B38);
  static const inverseSurface = Color(0xFF372F25);
  static const inverseOnSurface = Color(0xFFF7EFE3);
  static const outline = Color(0xFF8B7960);
  static const outlineVariant = Color(0xFFDDD0BC);
  static const surfaceTint = Color(0xFFFFB000);
  static const surfaceVariant = Color(0xFFE7DBC7);

  static const primary = Color(0xFF8A5A00);
  static const onPrimary = Color(0xFFFFF8EC);
  static const primaryContainer = Color(0xFFFFC24D);
  static const onPrimaryContainer = Color(0xFF3B2700);
  static const inversePrimary = Color(0xFFFFB000);
  static const primaryFixed = Color(0xFFFFDFA6);
  static const primaryFixedDim = Color(0xFFFFB000);
  static const onPrimaryFixed = Color(0xFF2A1A00);
  static const onPrimaryFixedVariant = Color(0xFF614000);

  static const secondary = Color(0xFF6B6155);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFEFE4D3);
  static const onSecondaryContainer = Color(0xFF3F372C);
  static const secondaryFixed = Color(0xFFEFE4D3);
  static const secondaryFixedDim = Color(0xFFD6C7B0);
  static const onSecondaryFixed = Color(0xFF2A241B);
  static const onSecondaryFixedVariant = Color(0xFF4A4136);

  static const tertiary = Color(0xFF4F6470);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFDCE8EF);
  static const onTertiaryContainer = Color(0xFF17262E);
  static const tertiaryFixed = Color(0xFFDCE8EF);
  static const tertiaryFixedDim = Color(0xFFB9CBD6);
  static const onTertiaryFixed = Color(0xFF101F27);
  static const onTertiaryFixedVariant = Color(0xFF384A54);

  static const error = Color(0xFFB3261E);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFF9DEDC);
  static const onErrorContainer = Color(0xFF410E0B);

  static const background = Color(0xFFFDF9F2);
  static const onBackground = Color(0xFF241B10);

  static const elevationLevel0 = Color(0xFFFFFFFF);
  static const elevationLevel1 = Color(0xFFFFFFFF);
  static const elevationLevel1Border = Color(0xFFE7DBC7);
  static const elevationLevel2 = Color(0xFFF8F2E8);

  static const codeBlockBackground = Color(0xFFF5EEE2);
  static const codeLineNumber = Color(0xFFA8977F);

  static const errorRed = Color(0xFFD32F2F);
  static const warningOrange = Color(0xFFB26A00);
  static const infoBlue = Color(0xFF1565C0);
}

/// Brightness-dispatching facade over [AppDarkPalette] and
/// [AppLightPalette].
///
/// Widgets read colors from these tokens rather than from
/// `Theme.of(context).colorScheme`, so the tokens themselves have to know
/// which palette is live. [brightness] is assigned by the app root — see
/// `ThemeCubit` and `main.dart` — before the frame builds; it must never be
/// assigned from inside a `build` method.
///
/// Because the getters resolve at runtime, they are not `const`. Widgets that
/// want a `const` color should reach for the palette classes directly.
abstract final class AppColors {
  /// The palette the getters below resolve against. Assigned by
  /// `ThemeCubit` and `main.dart` — before the frame builds; it must never be
  /// assigned from inside a `build` method.
  static Brightness brightness = Brightness.dark;

  static bool get isDark => brightness == Brightness.dark;

  static Color _pick(Color dark, Color light) => isDark ? dark : light;

  // Surfaces
  static Color get surface =>
      _pick(AppDarkPalette.surface, AppLightPalette.surface);
  static Color get surfaceDim =>
      _pick(AppDarkPalette.surfaceDim, AppLightPalette.surfaceDim);
  static Color get surfaceBright =>
      _pick(AppDarkPalette.surfaceBright, AppLightPalette.surfaceBright);
  static Color get surfaceContainerLowest => _pick(
    AppDarkPalette.surfaceContainerLowest,
    AppLightPalette.surfaceContainerLowest,
  );
  static Color get surfaceContainerLow => _pick(
    AppDarkPalette.surfaceContainerLow,
    AppLightPalette.surfaceContainerLow,
  );
  static Color get surfaceContainer =>
      _pick(AppDarkPalette.surfaceContainer, AppLightPalette.surfaceContainer);
  static Color get surfaceContainerHigh => _pick(
    AppDarkPalette.surfaceContainerHigh,
    AppLightPalette.surfaceContainerHigh,
  );
  static Color get surfaceContainerHighest => _pick(
    AppDarkPalette.surfaceContainerHighest,
    AppLightPalette.surfaceContainerHighest,
  );
  static Color get surfaceVariant =>
      _pick(AppDarkPalette.surfaceVariant, AppLightPalette.surfaceVariant);
  static Color get onSurface =>
      _pick(AppDarkPalette.onSurface, AppLightPalette.onSurface);
  static Color get onSurfaceVariant =>
      _pick(AppDarkPalette.onSurfaceVariant, AppLightPalette.onSurfaceVariant);
  static Color get inverseSurface =>
      _pick(AppDarkPalette.inverseSurface, AppLightPalette.inverseSurface);
  static Color get inverseOnSurface =>
      _pick(AppDarkPalette.inverseOnSurface, AppLightPalette.inverseOnSurface);
  static Color get outline =>
      _pick(AppDarkPalette.outline, AppLightPalette.outline);
  static Color get outlineVariant =>
      _pick(AppDarkPalette.outlineVariant, AppLightPalette.outlineVariant);
  static Color get surfaceTint =>
      _pick(AppDarkPalette.surfaceTint, AppLightPalette.surfaceTint);
  static Color get background =>
      _pick(AppDarkPalette.background, AppLightPalette.background);
  static Color get onBackground =>
      _pick(AppDarkPalette.onBackground, AppLightPalette.onBackground);

  /// Signal Amber — reserved strictly for primary actions, progress, and
  /// high-importance highlights.
  static Color get primary =>
      _pick(AppDarkPalette.primary, AppLightPalette.primary);
  static Color get onPrimary =>
      _pick(AppDarkPalette.onPrimary, AppLightPalette.onPrimary);
  static Color get primaryContainer =>
      _pick(AppDarkPalette.primaryContainer, AppLightPalette.primaryContainer);
  static Color get onPrimaryContainer => _pick(
    AppDarkPalette.onPrimaryContainer,
    AppLightPalette.onPrimaryContainer,
  );
  static Color get inversePrimary =>
      _pick(AppDarkPalette.inversePrimary, AppLightPalette.inversePrimary);
  static Color get primaryFixed =>
      _pick(AppDarkPalette.primaryFixed, AppLightPalette.primaryFixed);
  static Color get primaryFixedDim =>
      _pick(AppDarkPalette.primaryFixedDim, AppLightPalette.primaryFixedDim);
  static Color get onPrimaryFixed =>
      _pick(AppDarkPalette.onPrimaryFixed, AppLightPalette.onPrimaryFixed);
  static Color get onPrimaryFixedVariant => _pick(
    AppDarkPalette.onPrimaryFixedVariant,
    AppLightPalette.onPrimaryFixedVariant,
  );

  static Color get secondary =>
      _pick(AppDarkPalette.secondary, AppLightPalette.secondary);
  static Color get onSecondary =>
      _pick(AppDarkPalette.onSecondary, AppLightPalette.onSecondary);
  static Color get secondaryContainer => _pick(
    AppDarkPalette.secondaryContainer,
    AppLightPalette.secondaryContainer,
  );
  static Color get onSecondaryContainer => _pick(
    AppDarkPalette.onSecondaryContainer,
    AppLightPalette.onSecondaryContainer,
  );
  static Color get secondaryFixed =>
      _pick(AppDarkPalette.secondaryFixed, AppLightPalette.secondaryFixed);
  static Color get secondaryFixedDim => _pick(
    AppDarkPalette.secondaryFixedDim,
    AppLightPalette.secondaryFixedDim,
  );
  static Color get onSecondaryFixed =>
      _pick(AppDarkPalette.onSecondaryFixed, AppLightPalette.onSecondaryFixed);
  static Color get onSecondaryFixedVariant => _pick(
    AppDarkPalette.onSecondaryFixedVariant,
    AppLightPalette.onSecondaryFixedVariant,
  );

  static Color get tertiary =>
      _pick(AppDarkPalette.tertiary, AppLightPalette.tertiary);
  static Color get onTertiary =>
      _pick(AppDarkPalette.onTertiary, AppLightPalette.onTertiary);
  static Color get tertiaryContainer => _pick(
    AppDarkPalette.tertiaryContainer,
    AppLightPalette.tertiaryContainer,
  );
  static Color get onTertiaryContainer => _pick(
    AppDarkPalette.onTertiaryContainer,
    AppLightPalette.onTertiaryContainer,
  );
  static Color get tertiaryFixed =>
      _pick(AppDarkPalette.tertiaryFixed, AppLightPalette.tertiaryFixed);
  static Color get tertiaryFixedDim =>
      _pick(AppDarkPalette.tertiaryFixedDim, AppLightPalette.tertiaryFixedDim);
  static Color get onTertiaryFixed =>
      _pick(AppDarkPalette.onTertiaryFixed, AppLightPalette.onTertiaryFixed);
  static Color get onTertiaryFixedVariant => _pick(
    AppDarkPalette.onTertiaryFixedVariant,
    AppLightPalette.onTertiaryFixedVariant,
  );

  static Color get error => _pick(AppDarkPalette.error, AppLightPalette.error);
  static Color get onError =>
      _pick(AppDarkPalette.onError, AppLightPalette.onError);
  static Color get errorContainer =>
      _pick(AppDarkPalette.errorContainer, AppLightPalette.errorContainer);
  static Color get onErrorContainer =>
      _pick(AppDarkPalette.onErrorContainer, AppLightPalette.onErrorContainer);

  // Elevation reference values ("Elevation & Depth": tonal layering, no
  // shadows). In light mode the lowest level is the white page itself.
  static Color get elevationLevel0 =>
      _pick(AppDarkPalette.elevationLevel0, AppLightPalette.elevationLevel0);
  static Color get elevationLevel1 =>
      _pick(AppDarkPalette.elevationLevel1, AppLightPalette.elevationLevel1);
  static Color get elevationLevel1Border => _pick(
    AppDarkPalette.elevationLevel1Border,
    AppLightPalette.elevationLevel1Border,
  );
  static Color get elevationLevel2 =>
      _pick(AppDarkPalette.elevationLevel2, AppLightPalette.elevationLevel2);

  static Color get codeBlockBackground => _pick(
    AppDarkPalette.codeBlockBackground,
    AppLightPalette.codeBlockBackground,
  );
  static Color get codeLineNumber =>
      _pick(AppDarkPalette.codeLineNumber, AppLightPalette.codeLineNumber);

  // Semantic snackbar signal colors.
  static Color get errorRed =>
      _pick(AppDarkPalette.errorRed, AppLightPalette.errorRed);
  static Color get warningOrange =>
      _pick(AppDarkPalette.warningOrange, AppLightPalette.warningOrange);
  static Color get infoBlue =>
      _pick(AppDarkPalette.infoBlue, AppLightPalette.infoBlue);
}
