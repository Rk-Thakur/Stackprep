import 'package:flutter/material.dart';

/// Color tokens for "The Engineer's Notebook" design system.
///
/// Dark-first: this is the primary, fully-specified palette from DESIGN.md.
/// Light mode is only described narratively there (crisp off-white, warm-grey
/// borders) without exact hex values, so it isn't defined here yet.
abstract final class AppColors {
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

  /// Signal Amber — reserved strictly for primary actions, progress, and
  /// high-importance highlights.
  static const primary = Color(0xFFFFD597);
  static const onPrimary = Color(0xFF432C00);
  static const primaryContainer = Color(0xFFFFB000);
  static const onPrimaryContainer = Color(0xFF6A4700);
  static const inversePrimary = Color(0xFF805600);

  static const secondary = Color(0xFFC8C6C5);
  static const onSecondary = Color(0xFF313030);
  static const secondaryContainer = Color(0xFF4A4949);
  static const onSecondaryContainer = Color(0xFFBAB8B7);

  static const tertiary = Color(0xFFDBDBDB);
  static const onTertiary = Color(0xFF2F3131);
  static const tertiaryContainer = Color(0xFFBFBFBF);
  static const onTertiaryContainer = Color(0xFF4C4E4E);

  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);

  static const primaryFixed = Color(0xFFFFDDAF);
  static const primaryFixedDim = Color(0xFFFFBA43);
  static const onPrimaryFixed = Color(0xFF281800);
  static const onPrimaryFixedVariant = Color(0xFF614000);

  static const secondaryFixed = Color(0xFFE5E2E1);
  static const secondaryFixedDim = Color(0xFFC8C6C5);
  static const onSecondaryFixed = Color(0xFF1C1B1B);
  static const onSecondaryFixedVariant = Color(0xFF474646);

  static const tertiaryFixed = Color(0xFFE2E2E2);
  static const tertiaryFixedDim = Color(0xFFC6C6C7);
  static const onTertiaryFixed = Color(0xFF1A1C1C);
  static const onTertiaryFixedVariant = Color(0xFF454747);

  static const background = Color(0xFF191209);
  static const onBackground = Color(0xFFEEE0D0);
  static const surfaceVariant = Color(0xFF3C3429);

  // Elevation reference values from the "Elevation & Depth" section
  // (tonal layering, no shadows). Kept alongside the M3 surface-container
  // scale above for components that want the literal spec values.
  static const elevationLevel0 = Color(0xFF121212);
  static const elevationLevel1 = Color(0xFF1E1E1E);
  static const elevationLevel1Border = Color(0xFF2A2A2A);
  static const elevationLevel2 = Color(0xFF252525);

  static const codeBlockBackground = Color(0xFF1A1A1A);
  static const codeLineNumber = Color(0xFF4A4A4A);
}
