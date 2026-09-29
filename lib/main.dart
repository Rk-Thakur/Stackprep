import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stackprep/features/splash/presentation/pages/splash_page.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import './core/theme/app_theme_scope.dart';
import 'core/theme/theme_cubit.dart';
import 'core/router/route_observer.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<AuthBloc>()),
          BlocProvider(create: (_) => di.sl<OnboardingCubit>()),
          BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        ],
        child: AppBrightnessSync(
          child: BlocBuilder<ThemeCubit, ThemeState>(
            buildWhen: (previous, current) =>
                previous.brightness != current.brightness ||
                previous.generation != current.generation,
            builder: (context, theme) {
              // The color tokens are static, so the active palette has to be
              // swapped before any descendant reads them during this frame.
              AppColors.brightness = theme.brightness;
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'StackPrep',
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: theme.mode,
                navigatorObservers: [routeObserver],
                builder: (context, child) => AppThemeScope(
                  generation: theme.generation,
                  brightness: theme.brightness,
                  child: child ?? const SizedBox.shrink(),
                ),
                // home: const SeedPage(),
                home: const SplashPage(),
              );
            },
          ),
        ),
      ),
    );
  }
}
