import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stackprep/core/error/failures.dart';
import 'package:stackprep/core/theme/app_colors.dart';
import 'package:stackprep/core/theme/app_radius.dart';
import 'package:stackprep/core/theme/app_spacing.dart';
import 'package:stackprep/core/theme/app_theme_scope.dart';
import 'package:stackprep/core/theme/app_typography.dart';
import 'package:stackprep/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:stackprep/features/export/data/progress_report_exporter.dart';
import 'package:stackprep/features/export/domain/entities/progress_report.dart';

/// Export Data sheet: previews the report, then saves it as a PDF.
///
/// Shows a live summary of what the PDF will contain so the action is not a
/// leap of faith, and renders the report in the app's current theme.
class ExportDataSheet extends StatefulWidget {
  const ExportDataSheet({super.key, required this.exporter});

  final ProgressReportExporter exporter;

  /// Opens the sheet and resolves to where the report was saved, or null if
  /// dismissed. The caller shows the path, because nothing on screen points at
  /// the folder the file landed in.
  static Future<ExportSaved?> show(
    BuildContext context, {
    required ProgressReportExporter exporter,
  }) {
    return showModalBottomSheet<ExportSaved>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportDataSheet(exporter: exporter),
    );
  }

  @override
  State<ExportDataSheet> createState() => _ExportDataSheetState();
}

class _ExportDataSheetState extends State<ExportDataSheet> {
  ProgressReport? _report;
  Uint8List? _bytes;
  Failure? _failure;
  bool _building = true;

  /// True while the save is in flight, so the button can show progress and a
  /// second tap cannot start a second write.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _building = true;
      _failure = null;
    });

    final user = context.read<AuthBloc>().state.user;
    final result = await widget.exporter.build(user: user);
    if (!mounted) return;

    final failure = result.fold((f) => f, (_) => null);
    final report = result.fold((_) => null, (value) => value);
    if (report == null) {
      if (!mounted) return;
      setState(() {
        _building = false;
        _failure = failure;
      });
      return;
    }

    final generated = await widget.exporter.generate(report);
    if (!mounted) return;
    final bytes = generated.fold((_) => null, (value) => value);
    setState(() {
      _building = false;
      if (bytes == null) {
        _failure = generated.fold((f) => f, (_) => null);
      } else {
        _report = report;
        _bytes = bytes;
      }
    });
  }

  /// Writes the report to a file, keeping any platform failure inside the
  /// sheet rather than letting it surface as an unhandled async error.
  Future<void> _save() async {
    final bytes = _bytes;
    final report = _report;
    if (bytes == null || report == null || _saving) return;

    setState(() => _saving = true);
    try {
      final saved = await widget.exporter.save(bytes, report.fileName);
      if (!mounted) return;
      // A null result means the user closed the save picker. Stay on the sheet
      // so they can choose a location again, rather than reporting an error.
      if (saved == null) {
        setState(() => _saving = false);
        return;
      }
      Navigator.of(context).pop(saved);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _failure = error is Failure
            // A [Failure] already carries a message written for people.
            ? error
            : CacheFailure('Could not export the report. ($error)');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Themed(
      child: DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.5,
        maxChildSize: 0.94,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            children: [
              const _Grabber(),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  0,
                  AppSpacing.margin,
                  AppSpacing.sm,
                ),
                child: _header(),
              ),
              Expanded(child: _body(scrollController)),
              if (_report != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.margin,
                    AppSpacing.sm,
                    AppSpacing.margin,
                    AppSpacing.margin,
                  ),
                  child: _actions(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.18),
            borderRadius: AppRadius.radiusSm,
          ),
          child: Icon(
            Icons.picture_as_pdf_rounded,
            size: 18.r,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXPORT DATA',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 4.r),
              Text(
                'A PDF summary of your streaks, track competency and focus areas.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _body(ScrollController controller) {
    if (_building) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final failure = _failure;
    if (failure != null) {
      return _ErrorState(
        message: failure.message,
        onRetry: _load,
        scrollController: controller,
      );
    }

    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.xs,
        AppSpacing.margin,
        AppSpacing.lg,
      ),
      children: [
        _previewCard(),
        SizedBox(height: AppSpacing.lg),
        const _SheetLabel('INCLUDED SECTIONS'),
        SizedBox(height: AppSpacing.sm),
        _SectionList(report: _report!),
      ],
    );
  }

  Widget _previewCard() {
    final report = _report!;
    final stats = <(String, String)>[
      ('STREAK', '${report.currentStreakDays}d'),
      ('SESSIONS', '${report.totalSessions}'),
      ('READINESS', _percent(report.readinessScore)),
      ('TRACKS', '${report.competencies.length}'),
    ];

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.fileName,
                  style: AppTypography.codeSm.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              _Tag(label: '${_sizeLabel()} PDF', tone: _TagTone.neutral),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (final (i, stat) in stats.indexed) ...[
                if (i != 0)
                  Container(
                    width: 1,
                    height: 28.r,
                    margin: EdgeInsets.symmetric(horizontal: 6.r),
                    color: AppColors.outlineVariant,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.$1,
                        style: AppTypography.labelMono.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 9.sp,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 3.r),
                      Text(
                        stat.$2,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _sizeLabel() {
    final bytes = _bytes?.length ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _actions() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saving ? null : _save,
        icon: _buttonIcon(_saving, Icons.download_rounded),
        label: Text(_saving ? 'Saving…' : 'Save as PDF'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15.r),
        ),
      ),
    );
  }

  static Widget _buttonIcon(bool busy, IconData icon) =>
      busy ? const _ButtonSpinner() : Icon(icon, size: 16.r);

  static String _percent(double fraction) => '${(fraction * 100).round()}%';
}

/// Which delivery action is in flight.
class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 14.r,
    height: 14.r,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: AppColors.onSurface,
    ),
  );
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.r),
      child: Container(
        width: 40.r,
        height: 4.r,
        decoration: BoxDecoration(
          color: AppColors.outline,
          borderRadius: AppRadius.radiusFull,
        ),
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({required this.report});

  final ProgressReport report;

  @override
  Widget build(BuildContext context) {
    final sections = <(String, String, String, int)>[
      if (report.activityLevels.isNotEmpty)
        (
          'calendar_month_rounded',
          'Activity heatmap',
          'Last 5 weeks',
          report.activityLevels.length,
        ),
      if (report.competencies.isNotEmpty)
        (
          'account_tree_rounded',
          'Track competency',
          'Score, level and modules',
          report.competencies.length,
        ),
      if (report.focusAreas.isNotEmpty)
        (
          'crisis_alert_rounded',
          'Focus areas',
          'Weakest topics and trends',
          report.focusAreas.length,
        ),
    ];

    if (sections.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Text(
          'There is no progress data to export yet. Complete a practice session '
          'and this report will fill in.',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            _SectionRow(
              icon: sections[i].$1,
              title: sections[i].$2,
              caption: sections[i].$3,
              count: sections[i].$4,
            ),
            if (i != sections.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(height: 1, color: AppColors.outlineVariant),
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.icon,
    required this.title,
    required this.caption,
    required this.count,
  });

  final String icon;
  final String title;
  final String caption;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2.r,
      ),
      child: Row(
        children: [
          Icon(_iconFor(icon), size: 18.r, color: AppColors.onSurfaceVariant),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.r),
                Text(
                  caption,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          _Tag(label: '$count', tone: _TagTone.amber),
        ],
      ),
    );
  }

  static IconData _iconFor(String name) => switch (name) {
    'calendar_month_rounded' => Icons.calendar_month_rounded,
    'account_tree_rounded' => Icons.account_tree_rounded,
    _ => Icons.crisis_alert_rounded,
  };
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMono.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 10.sp,
            letterSpacing: 1.4,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Container(height: 1, color: AppColors.outlineVariant),
      ],
    );
  }
}

enum _TagTone { amber, neutral }

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.tone});

  final String label;
  final _TagTone tone;

  @override
  Widget build(BuildContext context) {
    final isAmber = tone == _TagTone.amber;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
      decoration: BoxDecoration(
        color: isAmber
            ? AppColors.primaryContainer.withValues(alpha: 0.2)
            : AppColors.surfaceContainerHigh,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Text(
        label,
        style: AppTypography.labelMono.copyWith(
          color: isAmber ? AppColors.primary : AppColors.onSurfaceVariant,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.scrollController,
  });

  final String message;
  final VoidCallback onRetry;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.all(AppSpacing.margin),
      children: [
        SizedBox(height: AppSpacing.xl),
        Icon(Icons.error_outline_rounded, size: 32.r, color: AppColors.error),
        SizedBox(height: AppSpacing.md),
        Text(
          'Export unavailable',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh_rounded, size: 16.r),
            label: const Text('Try again'),
          ),
        ),
      ],
    );
  }
}
