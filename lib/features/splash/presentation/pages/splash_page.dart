import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../../onboarding/presentation/pages/select_stack_page.dart';
import '../widgets/boot_terminal.dart';
import '../widgets/hero_mark.dart';
import '../widgets/splash_background.dart';
import '../widgets/system_start_button.dart';
import '../../../../injection_container.dart' show sl;

/// The app's boot screen: ambient shader-style backdrop, a rotating
/// wireframe hero mark, a typewriter boot log, and a "SYSTEM START" CTA
/// that reveals once the sequence finishes.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _bgController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  late final AnimationController _heroController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();

  late final AnimationController _titleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  late final AnimationController _bootController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5000),
  )..forward();

  bool _canStart = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (!mounted) return;
      final authenticated = sl<AuthRemoteDataSource>().currentUser != null;
      if (authenticated) {
        final onboardingCompleted =
            sl<OnboardingLocalDataSource>().isOnboardingCompleted();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => onboardingCompleted
                ? const HomePage()
                : const SelectStackPage(),
          ),
        );
      } else {
        setState(() => _canStart = true);
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _heroController.dispose();
    _titleController.dispose();
    _bootController.dispose();
    super.dispose();
  }

  void _start() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) =>
                  SplashBackground(progress: _bgController.value),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: AppSpacing.xl),
                AnimatedBuilder(
                  animation: _titleController,
                  builder: (context, child) {
                    final t = _titleController.value;
                    final decay = 1 - t;
                    final dx = sin(t * 26) * decay * 10;
                    final rot = sin(t * 20) * decay * 0.06;
                    return Opacity(
                      opacity: (t / 0.25).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(dx, 0),
                        child: Transform.rotate(angle: rot, child: child),
                      ),
                    );
                  },
                  child: Text(
                    'STACKPREP',
                    style: AppTypography.headlineLg.copyWith(
                      color: AppColors.primaryContainer,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _heroController,
                          builder: (context, _) => HeroMark(
                            progress: _heroController.value,
                            size: 240.r,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xl),
                        AnimatedBuilder(
                          animation: _bootController,
                          builder: (context, _) =>
                              BootTerminal(progress: _bootController.value),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xl),
                  child: AnimatedOpacity(
                    opacity: _canStart ? 1 : 0,
                    duration: const Duration(milliseconds: 600),
                    child: AnimatedSlide(
                      offset: _canStart ? Offset.zero : const Offset(0, 0.06),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      child: IgnorePointer(
                        ignoring: !_canStart,
                        child: SystemStartButton(onTap: _start),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
