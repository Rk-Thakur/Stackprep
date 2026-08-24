import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'blocs/auth/auth_bloc.dart';
import 'data/auth_repository.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      builder: (context, child) => RepositoryProvider(
        create: (_) => AuthRepository(),
        child: BlocProvider(
          create: (context) =>
              AuthBloc(authRepository: context.read<AuthRepository>()),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'StackPrep',
            theme: AppTheme.dark,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.dark,
            home: const AuthScreen(),
          ),
        ),
      ),
    );
  }
}
