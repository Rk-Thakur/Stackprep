import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackprep/core/storage/theme_store.dart';
import 'package:stackprep/core/theme/app_colors.dart';
import 'package:stackprep/core/theme/app_theme.dart';
import 'package:stackprep/core/theme/app_theme_scope.dart';
import 'package:stackprep/core/theme/theme_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// AppTypography reads ScreenUtil, which only has a scale inside a
  /// [ScreenUtilInit] subtree, so any test touching AppTheme needs one.
  Future<void> initScreenUtil(WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(home: const SizedBox.shrink()),
      ),
    );
  }

  setUp(() => AppColors.brightness = Brightness.dark);
  tearDown(() => AppColors.brightness = Brightness.dark);

  group('AppColors', () {
    test('dispatches to the dark palette by default', () {
      expect(AppColors.brightness, Brightness.dark);
      expect(AppColors.surface, AppDarkPalette.surface);
      expect(AppColors.onSurface, AppDarkPalette.onSurface);
    });

    test('dispatches to the light palette once brightness flips', () {
      AppColors.brightness = Brightness.light;
      expect(AppColors.surface, AppLightPalette.surface);
      expect(AppColors.onSurface, AppLightPalette.onSurface);
    });

    test('the two palettes are actually different', () {
      expect(AppDarkPalette.surface, isNot(AppLightPalette.surface));
      expect(AppDarkPalette.onSurface, isNot(AppLightPalette.onSurface));
      expect(AppDarkPalette.primary, isNot(AppLightPalette.primary));
    });

    test('light palette keeps text darker than its surface', () {
      expect(
        AppLightPalette.onSurface.computeLuminance(),
        lessThan(AppLightPalette.surface.computeLuminance()),
      );
    });
  });

  group('AppTheme', () {
    test('resolves each mode against the platform brightness', () {
      expect(
        AppTheme.resolveBrightness(ThemeMode.system, Brightness.dark),
        Brightness.dark,
      );
      expect(
        AppTheme.resolveBrightness(ThemeMode.system, Brightness.light),
        Brightness.light,
      );
      expect(
        AppTheme.resolveBrightness(ThemeMode.light, Brightness.dark),
        Brightness.light,
      );
      expect(
        AppTheme.resolveBrightness(ThemeMode.dark, Brightness.light),
        Brightness.dark,
      );
    });

    testWidgets('both themes build and carry their own brightness', (
      tester,
    ) async {
      await initScreenUtil(tester);
      expect(AppTheme.dark.brightness, Brightness.dark);
      expect(AppTheme.light.brightness, Brightness.light);
    });

    testWidgets('light theme is readable: onSurface contrasts with scaffold', (
      tester,
    ) async {
      await initScreenUtil(tester);
      final theme = AppTheme.light;
      expect(
        theme.colorScheme.onSurface.computeLuminance(),
        lessThan(theme.scaffoldBackgroundColor.computeLuminance()),
      );
    });
  });

  group('ThemeStore', () {
    test('defaults to system when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final store = ThemeStore(prefs: await SharedPreferences.getInstance());
      expect(store.read(), ThemeMode.system);
    });

    test('round-trips a stored mode', () async {
      SharedPreferences.setMockInitialValues({});
      final store = ThemeStore(prefs: await SharedPreferences.getInstance());
      await store.write(ThemeMode.light);
      expect(store.read(), ThemeMode.light);
    });

    test('falls back to system on an unrecognized value', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'nonsense'});
      final store = ThemeStore(prefs: await SharedPreferences.getInstance());
      expect(store.read(), ThemeMode.system);
    });
  });

  group('ThemeCubit', () {
    late ThemeStore store;
    late ThemeCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = ThemeStore(prefs: await SharedPreferences.getInstance());
      cubit = ThemeCubit(store: store, platformBrightness: Brightness.dark);
    });

    tearDown(() => cubit.close());

    test('starts in system mode and repoints the palette', () {
      expect(cubit.state.mode, ThemeMode.system);
      expect(cubit.state.brightness, Brightness.dark);
      expect(AppColors.brightness, Brightness.dark);
    });

    test('an explicit mode overrides the platform brightness', () async {
      await cubit.setMode(ThemeMode.light, platformBrightness: Brightness.dark);
      expect(cubit.state.brightness, Brightness.light);
      expect(AppColors.brightness, Brightness.light);
    });

    test('bumps the generation on every change', () async {
      final start = cubit.state.generation;
      await cubit.setMode(ThemeMode.light);
      await cubit.setMode(ThemeMode.dark);
      expect(cubit.state.generation, start + 2);
    });

    test('persists the chosen mode', () async {
      await cubit.setMode(ThemeMode.dark);
      expect(store.read(), ThemeMode.dark);
    });

    test('restores the persisted mode on the next launch', () async {
      await cubit.setMode(ThemeMode.light);
      final relaunched = ThemeCubit(
        store: store,
        platformBrightness: Brightness.dark,
      );
      addTearDown(relaunched.close);
      expect(relaunched.state.mode, ThemeMode.light);
      expect(relaunched.state.brightness, Brightness.light);
    });

    test('follows the OS while in system mode', () async {
      await cubit.syncPlatformBrightness(Brightness.light);
      expect(cubit.state.brightness, Brightness.light);
      expect(AppColors.brightness, Brightness.light);
    });

    test('ignores the OS while an explicit mode is set', () async {
      await cubit.setMode(ThemeMode.dark);
      await cubit.syncPlatformBrightness(Brightness.light);
      expect(cubit.state.brightness, Brightness.dark);
    });
  });

  group('Themed', () {
    testWidgets('rebuilds a page reading static colors when theme changes', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final store = ThemeStore(prefs: await SharedPreferences.getInstance());
      final cubit = ThemeCubit(
        store: store,
        platformBrightness: Brightness.dark,
      );
      addTearDown(cubit.close);
      final key = GlobalKey<_ProbePageState>();

      await initScreenUtil(tester);
      await tester.pumpWidget(
        _Host(
          cubit: cubit,
          child: Themed(child: _ProbePage(key: key)),
        ),
      );
      expect(key.currentState!.builds, 1);
      expect(
        tester.widget<ColoredBox>(find.byType(ColoredBox)).color,
        AppDarkPalette.surface,
      );

      // Simulate the user picking the light theme.
      await cubit.setMode(ThemeMode.light, platformBrightness: Brightness.dark);
      await tester.pumpAndSettle();

      expect(
        key.currentState!.builds,
        greaterThan(1),
        reason: 'the page subtree must rebuild to re-read AppColors',
      );
      final light = tester.widget<ColoredBox>(find.byType(ColoredBox)).color;
      expect(light, AppLightPalette.surface);
      expect(light, isNot(AppDarkPalette.surface));
    });

    testWidgets('without Themed the page is not rebuilt', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = ThemeStore(prefs: await SharedPreferences.getInstance());
      final cubit = ThemeCubit(
        store: store,
        platformBrightness: Brightness.dark,
      );
      addTearDown(cubit.close);
      final key = GlobalKey<_ProbePageState>();

      await initScreenUtil(tester);
      await tester.pumpWidget(
        _Host(
          cubit: cubit,
          child: _ProbePage(key: key),
        ),
      );
      expect(key.currentState!.builds, 1);

      await cubit.setMode(ThemeMode.light, platformBrightness: Brightness.dark);
      await tester.pumpAndSettle();

      // This is the trap Themed exists to avoid: the same widget instance is
      // left in place, so no rebuild and the stale dark color would persist.
      expect(key.currentState!.builds, 1);
    });
  });

  group('AppBrightnessSync', () {
    /// Simulates the OS flipping its appearance while the app is running.
    Future<void> flipOsBrightness(
      WidgetTester tester,
      Brightness brightness,
    ) async {
      tester.binding.platformDispatcher.platformBrightnessTestValue =
          brightness;
      addTearDown(
        tester.binding.platformDispatcher.clearPlatformBrightnessTestValue,
      );
      tester.binding.handlePlatformBrightnessChanged();
      await tester.pumpAndSettle();
    }

    testWidgets('follows the OS while the mode is system', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = ThemeStore(prefs: await SharedPreferences.getInstance());
      final cubit = ThemeCubit(
        store: store,
        platformBrightness: Brightness.dark,
      );
      addTearDown(cubit.close);
      final key = GlobalKey<_ProbePageState>();

      await initScreenUtil(tester);
      await tester.pumpWidget(
        _Host(
          cubit: cubit,
          child: Themed(child: _ProbePage(key: key)),
        ),
      );
      expect(AppColors.brightness, Brightness.dark);

      await flipOsBrightness(tester, Brightness.light);

      expect(cubit.state.mode, ThemeMode.system);
      expect(cubit.state.brightness, Brightness.light);
      expect(AppColors.brightness, Brightness.light);
      expect(
        tester.widget<ColoredBox>(find.byType(ColoredBox)).color,
        AppLightPalette.surface,
      );
    });

    testWidgets('ignores the OS once an explicit mode is chosen', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final store = ThemeStore(prefs: await SharedPreferences.getInstance());
      final cubit = ThemeCubit(
        store: store,
        platformBrightness: Brightness.dark,
      );
      addTearDown(cubit.close);

      await initScreenUtil(tester);
      await tester.pumpWidget(
        _Host(
          cubit: cubit,
          child: Themed(child: const _ProbePage()),
        ),
      );
      await cubit.setMode(ThemeMode.dark, platformBrightness: Brightness.dark);
      await tester.pumpAndSettle();

      await flipOsBrightness(tester, Brightness.light);

      expect(cubit.state.brightness, Brightness.dark);
      expect(AppColors.brightness, Brightness.dark);
    });
  });
}

/// A page-shaped widget that reads the static [AppColors] tokens, the way the
/// real pages do.
class _ProbePage extends StatefulWidget {
  const _ProbePage({super.key});

  @override
  State<_ProbePage> createState() => _ProbePageState();
}

class _ProbePageState extends State<_ProbePage> {
  int builds = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    return ColoredBox(
      color: AppColors.surface,
      child: Text(AppColors.onSurface.toARGB32().toRadixString(16)),
    );
  }
}

/// Stands in for the app root: registers the OS observer, repoints the
/// palette, and publishes the scope.
class _Host extends StatelessWidget {
  const _Host({required this.cubit, required this.child});

  final ThemeCubit cubit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: AppBrightnessSync(child: _BuilderHost(child: child)),
    );
  }
}

/// Mirrors the app root's BlocBuilder -> MaterialApp -> AppThemeScope chain.
class _BuilderHost extends StatelessWidget {
  const _BuilderHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, theme) {
        AppColors.brightness = theme.brightness;
        return MaterialApp(
          theme: theme.brightness == Brightness.dark
              ? AppTheme.dark
              : AppTheme.light,
          builder: (context, _) => AppThemeScope(
            generation: theme.generation,
            brightness: theme.brightness,
            child: child,
          ),
        );
      },
    );
  }
}
