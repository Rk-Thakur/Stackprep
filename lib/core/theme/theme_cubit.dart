import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/theme_store.dart';
import 'app_colors.dart';
import 'app_theme.dart';

class ThemeState extends Equatable {
  const ThemeState({
    required this.mode,
    required this.brightness,
    this.generation = 0,
  });

  /// The user's explicit choice; [ThemeMode.system] defers to the OS.
  final ThemeMode mode;

  /// [mode] resolved against the platform brightness, i.e. the palette the
  /// app is actually rendering with right now.
  final Brightness brightness;

  /// Bumped on every change so [AppThemeScope] dependents rebuild.
  final int generation;

  ThemeState copyWith({
    ThemeMode? mode,
    Brightness? brightness,
    int? generation,
  }) => ThemeState(
    mode: mode ?? this.mode,
    brightness: brightness ?? this.brightness,
    generation: generation ?? this.generation,
  );

  @override
  List<Object?> get props => [mode, brightness, generation];
}

/// Owns the app-wide theme mode, persists it, and keeps [AppColors] pointed at
/// the matching palette so the static color tokens repaint correctly.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({required ThemeStore store, Brightness? platformBrightness})
    : _store = store,
      super(
        _initialState(
          store.read(),
          platformBrightness ?? _platformBrightness(),
        ),
      ) {
    AppColors.brightness = state.brightness;
  }

  final ThemeStore _store;

  static Brightness _platformBrightness() =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  static ThemeState _initialState(
    ThemeMode mode,
    Brightness platformBrightness,
  ) => ThemeState(
    mode: mode,
    brightness: AppTheme.resolveBrightness(mode, platformBrightness),
  );

  /// Switches theme and persists the choice.
  Future<void> setMode(ThemeMode mode, {Brightness? platformBrightness}) async {
    final brightness = AppTheme.resolveBrightness(
      mode,
      platformBrightness ?? _platformBrightness(),
    );
    _applyPalette(brightness);
    emit(
      state.copyWith(
        mode: mode,
        brightness: brightness,
        generation: state.generation + 1,
      ),
    );
    await _store.write(mode);
  }

  /// Recomputes [ThemeState.brightness] when the OS appearance changes while
  /// the mode is [ThemeMode.system]. A no-op for an explicit mode.
  Future<void> syncPlatformBrightness(Brightness platformBrightness) async {
    if (state.mode != ThemeMode.system) return;
    final brightness = AppTheme.resolveBrightness(
      state.mode,
      platformBrightness,
    );
    if (brightness == state.brightness) return;
    _applyPalette(brightness);
    emit(
      state.copyWith(brightness: brightness, generation: state.generation + 1),
    );
  }

  /// Points the static token facade at the palette we are about to render.
  void _applyPalette([Brightness? brightness]) {
    AppColors.brightness = brightness ?? state.brightness;
  }
}
