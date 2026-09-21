import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/terminal_snackbar.dart';
import '../../../../core/widgets/terminal_text_field.dart';
import '../../../../injection_container.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../../onboarding/presentation/pages/select_stack_page.dart';
import '../../../splash/presentation/widgets/hero_mark.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Terminal-themed sign-in / create-account page, backed by Firebase Auth
/// via [AuthBloc].
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with TickerProviderStateMixin {
  int _tabIndex = 0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _logoController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      TerminalSnackbar.show(
        context,
        level: SnackLevel.warning,
        message: 'EMAIL_AND_PASSWORD_REQUIRED',
      );
      return;
    }
    final bloc = context.read<AuthBloc>();
    if (_tabIndex == 0) {
      bloc.add(AuthSignInRequested(email: email, password: password));
    } else {
      bloc.add(AuthSignUpRequested(email: email, password: password));
    }
  }

  void _continueAnonymously() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SelectStackPage()),
    );
  }

  void _comingSoon(String provider) {
    TerminalSnackbar.show(
      context,
      level: SnackLevel.info,
      message: '${provider.toUpperCase()}_AUTH_NOT_AVAILABLE',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          (previous.status != AuthStatus.authenticated &&
              current.status == AuthStatus.authenticated) ||
          (current.justSignedUp != previous.justSignedUp) ||
          (current.formStatus == AuthFormStatus.failure &&
              current.errorMessage != previous.errorMessage),
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated && !state.justSignedUp) {
          final onboardingCompleted =
              sl<OnboardingLocalDataSource>().isOnboardingCompleted();
          TerminalSnackbar.show(
            context,
            level: SnackLevel.success,
            message: 'SECURE_CONNECTION_STABLE',
            duration: const Duration(seconds: 2),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => onboardingCompleted
                    ? const HomePage()
                    : const SelectStackPage(),
              ),
            );
          });
          return;
        }
        if (state.formStatus == AuthFormStatus.failure &&
            state.errorMessage != null) {
          TerminalSnackbar.show(
            context,
            level: SnackLevel.error,
            message: state.errorMessage!,
            actionLabel: 'RETRY',
            onAction: _submit,
          );
          return;
        }
        if (state.justSignedUp) {
          setState(() {
            _tabIndex = 0;
            _emailController.clear();
            _passwordController.clear();
          });
          TerminalSnackbar.show(
            context,
            level: SnackLevel.success,
            message: 'ACCOUNT_CREATED — sign in to continue',
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: -80.r,
              left: 0,
              right: 0,
              child: Center(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                  child: Container(
                    width: 260.w,
                    height: 180.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(
                        alpha: 0.25,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.margin,
                    vertical: AppSpacing.sm,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight -
                          (AppSpacing.sm * 2),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                    Container(
                      width: 108.r,
                      height: 108.r,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryContainer.withValues(
                              alpha: 0.15,
                            ),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, _) => HeroMark(
                          progress: _logoController.value,
                          size: 108,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'STACKPREP',
                        maxLines: 1,
                        style: AppTypography.headlineLg.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'v1.0.4-stable //\nSECURE_CONNECTION_ESTABLISHED',
                      textAlign: TextAlign.center,
                      style: AppTypography.labelMono.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: AppRadius.radiusLg,
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryContainer.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (previous, current) =>
                            previous.formStatus != current.formStatus,
                        builder: (context, state) {
                          final submitting =
                              state.formStatus == AuthFormStatus.submitting;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _AuthTabs(
                                index: _tabIndex,
                                onChanged: submitting
                                    ? (_) {}
                                    : (i) => setState(() => _tabIndex = i),
                              ),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                'USER_IDENTIFIER (Email)',
                                style: AppTypography.labelMono.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs),
                              TerminalTextField(
                                controller: _emailController,
                                icon: Icons.person_outline,
                                hintText: 'you@example.com',
                                keyboardType: TextInputType.emailAddress,
                                enabled: !submitting,
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                'AUTH_TOKEN (Password)',
                                style: AppTypography.labelMono.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs),
                              TerminalTextField(
                                controller: _passwordController,
                                icon: Icons.key_outlined,
                                obscureText: true,
                                hintText: '••••••••',
                                enabled: !submitting,
                              ),
                              SizedBox(height: AppSpacing.md),
                              ElevatedButton(
                                onPressed: submitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 14.r,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.radiusBase,
                                  ),
                                  textStyle: AppTypography.codeSm.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: submitting
                                    ? SizedBox(
                                        width: 18.r,
                                        height: 18.r,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.onPrimary,
                                        ),
                                      )
                                    : Text(
                                        _tabIndex == 0
                                            ? '[EXECUTE_LOGIN]'
                                            : '[CREATE_ACCOUNT]',
                                      ),
                              ),
                              SizedBox(height: AppSpacing.md),
                              Container(
                                height: 1,
                                color: AppColors.outlineVariant,
                              ),
                              SizedBox(height: AppSpacing.md),
                              OutlinedButton.icon(
                                onPressed: submitting
                                    ? null
                                    : _continueAnonymously,
                                icon: Icon(Icons.link, size: 16.r),
                                label: const Text('LINK_ANONYMOUS_SESSION'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryContainer,
                                  side: const BorderSide(
                                    color: AppColors.outlineVariant,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.r,
                                  ),
                                  textStyle: AppTypography.labelMono,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.radiusBase,
                                  ),
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: AppColors.outlineVariant,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                    ),
                                    child: Text(
                                      'EXTERNAL_PROVIDERS',
                                      style: AppTypography.labelMono
                                          .copyWith(
                                            color: AppColors.outline,
                                            fontSize: 10.sp,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: AppColors.outlineVariant,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Expanded(
                                    child: _ProviderButton(
                                      icon: Icons.code,
                                      label: 'GITHUB',
                                      onTap: submitting
                                          ? null
                                          : () => _comingSoon('GitHub'),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: _ProviderButton(
                                      icon: Icons.public,
                                      label: 'GOOGLE',
                                      onTap: submitting
                                          ? null
                                          : () => context
                                                .read<AuthBloc>()
                                                .add(
                                                  const AuthGoogleSignInRequested(),
                                                ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
        ],
        ),
      ),
    );
  }
}

class _AuthTabs extends StatelessWidget {
  const _AuthTabs({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _TabLabel(
                label: 'SIGN_IN',
                selected: index == 0,
                onTap: () => onChanged(0),
              ),
            ),
            Expanded(
              child: _TabLabel(
                label: 'CREATE_ACCOUNT',
                selected: index == 1,
                onTap: () => onChanged(1),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Stack(
          children: [
            Container(height: 1, color: AppColors.outlineVariant),
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: index == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(height: 2, color: AppColors.primaryContainer),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.labelMono.copyWith(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16.r, color: AppColors.onSurfaceVariant),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurfaceVariant,
        backgroundColor: AppColors.elevationLevel0,
        side: const BorderSide(color: AppColors.outlineVariant),
        padding: EdgeInsets.symmetric(vertical: 14.r),
        textStyle: AppTypography.labelMono,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusBase),
      ),
    );
  }
}
