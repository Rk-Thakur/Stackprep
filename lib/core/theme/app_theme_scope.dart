import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_cubit.dart';

/// Publishes the app's current theme *generation* — a counter that changes
/// every time the user picks a different theme mode.
///
/// The app's colors come from the static [AppColors] tokens rather than from
/// `Theme.of(context).colorScheme`, so changing the [ThemeData] alone would
/// not repaint anything: Flutter skips rebuilding a subtree whose widget
/// instance is unchanged, and pages here are not rebuilt just because an
/// inherited theme changed. Dependents of this scope, however, *are* rebuilt,
/// which is what [Themed] uses to rebuild a page's whole subtree.
class AppThemeScope extends InheritedWidget {
  const AppThemeScope({
    super.key,
    required this.generation,
    required this.brightness,
    required super.child,
  });

  /// Increments on every theme change; see the class docs.
  final int generation;

  /// The brightness the app is currently rendering with.
  final Brightness brightness;

  static AppThemeScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppThemeScope>();

  @override
  bool updateShouldNotify(AppThemeScope oldWidget) =>
      generation != oldWidget.generation;
}

/// Wraps a page so the whole subtree is rebuilt whenever the app theme
/// changes, which is what makes the static [AppColors] tokens repaint.
///
/// Place it at the root of every page (and any full-screen sheet):
/// `return Themed(child: Scaffold(...));`
class Themed extends StatelessWidget {
  const Themed({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final generation = AppThemeScope.maybeOf(context)?.generation ?? 0;
    // A fresh key discards the old element tree, forcing every descendant to
    // run its build again and re-read AppColors against the new palette.
    return KeyedSubtree(key: ValueKey(generation), child: child);
  }
}

/// Keeps the app in step with the OS appearance while the mode is
/// [ThemeMode.system].
///
/// Place it below the `ThemeCubit` provider and above the `BlocBuilder` that
/// drives `MaterialApp`, so an OS change repaints without a restart.
class AppBrightnessSync extends StatefulWidget {
  const AppBrightnessSync({super.key, required this.child});

  final Widget child;

  @override
  State<AppBrightnessSync> createState() => _AppBrightnessSyncState();
}

class _AppBrightnessSyncState extends State<AppBrightnessSync>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // No-op unless the user chose to follow the system; the cubit decides.
    context.read<ThemeCubit>().syncPlatformBrightness(
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
