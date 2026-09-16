import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stackprep/features/splash/presentation/pages/splash_page.dart';

import 'core/theme/app_theme.dart';
import 'core/router/route_observer.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  firebaseEnv.load(['.env']);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Reference frame the design was built against (iPhone 14/15-ish).
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<AuthBloc>()),
          BlocProvider(create: (_) => di.sl<OnboardingCubit>()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'StackPrep',
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          navigatorObservers: [routeObserver],
          // home: const SeedPage(),
          home: const SplashPage(),
        ),
      ),
    );
  }
}
