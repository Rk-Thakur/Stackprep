import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../onboarding/data/stack_tracks.dart';
import '../../../onboarding/domain/entities/stack_track.dart';
import 'flashcard_page.dart';
import 'module_detail_page.dart';
import '../../../practice/presentation/pages/practice_session_page.dart';

class TopicDetailPage extends StatefulWidget {
  const TopicDetailPage({super.key, required this.trackId});

  final String trackId;

  @override
  State<TopicDetailPage> createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  List<Map<String, dynamic>> _modules = [];
  bool _loading = true;
  String _trackName = '';
  String _trackDescription = '';

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    try {
      final trackDoc = await FirebaseFirestore.instance
          .collection('tracks')
          .doc(widget.trackId)
          .get();
      _trackName = (trackDoc.data()?['name'] as String?) ?? widget.trackId;
      _trackDescription = (trackDoc.data()?['description'] as String?) ?? '';

      final snap = await FirebaseFirestore.instance
          .collection('tracks')
          .doc(widget.trackId)
          .collection('modules')
          .orderBy('order')
          .get();
      setState(() {
        _modules = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              trailing: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: AppRadius.radiusSm,
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 22.r,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const _TopicDetailSkeleton()
                  : _modules.isEmpty
                      ? Center(
                          child: Text(
                            'No modules in $_trackName yet.',
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        )
                      : _TopicDetailBody(
                          trackId: widget.trackId,
                          trackName: _trackName,
                          trackDescription: _trackDescription,
                          modules: _modules,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmering placeholder matching [_TopicDetailBody]'s layout while the
/// track and its modules are still loading.
class _TopicDetailSkeleton extends StatelessWidget {
  const _TopicDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.margin,
          AppSpacing.md,
          AppSpacing.margin,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: AppSpacing.xl),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100.r,
                    height: 26.r,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: AppRadius.radiusFull,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Loading Track Name',
                    style: AppTypography.headlineLg.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.r),
                  Text(
                    'Loading a short description of this track while its '
                    'content comes down from the server.',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48.r,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppRadius.radiusBase,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Container(
                          height: 48.r,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: AppRadius.radiusBase,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Sub-topics & Challenges',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 22.sp,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Module title placeholder',
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.r),
                      Text(
                        'A couple of lines describing what this module '
                        'covers for the learner.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopicDetailBody extends StatelessWidget {
  const _TopicDetailBody({
    required this.trackId,
    required this.trackName,
    required this.trackDescription,
    required this.modules,
  });

  final String trackId;
  final String trackName;
  final String trackDescription;
  final List<Map<String, dynamic>> modules;

  StackTrack? get _track {
    for (final t in kStackTracks) {
      if (t.id == trackId) return t;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final track = _track;
    final accentColor = track?.color ?? AppColors.primary;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.md,
        AppSpacing.margin,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: track pill, title, description, action buttons.
          Container(
            padding: EdgeInsets.only(bottom: AppSpacing.xl),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (track != null) _TrackPill(track: track),
                SizedBox(height: AppSpacing.sm),
                Text(
                  trackName,
                  style: AppTypography.headlineLgResponsive(
                    context,
                  ).copyWith(color: AppColors.onSurface),
                ),
                if (trackDescription.isNotEmpty) ...[
                  SizedBox(height: 8.r),
                  Text(
                    trackDescription,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
                SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'MCQ Practice',
                        icon: Icons.play_arrow_rounded,
                        variant: _ActionButtonVariant.filled,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PracticeSessionPage(
                              topicCode: trackId,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _ActionButton(
                        label: '3D Flashcards',
                        icon: Icons.view_in_ar_rounded,
                        variant: _ActionButtonVariant.outlinedPrimary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FlashcardPage(topicId: trackId),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),

          // Sub-topics & challenges.
          Container(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sub-topics & Challenges',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 22.sp,
                  ),
                ),
                Text(
                  '${modules.length} MODULE${modules.length == 1 ? '' : 'S'}',
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 600 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  mainAxisExtent: 172.r,
                ),
                itemBuilder: (context, i) {
                  final module = modules[i];
                  return _ModuleCard(
                    module: module,
                    accentColor: accentColor,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ModuleDetailPage(
                          trackId: trackId,
                          moduleId: module['id'] as String,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TrackPill extends StatelessWidget {
  const _TrackPill({required this.track});

  final StackTrack track;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.radiusFull,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.data_object_rounded, size: 16.r, color: track.color),
          SizedBox(width: AppSpacing.xs),
          Text(
            track.name.toUpperCase(),
            style: AppTypography.labelMono.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ActionButtonVariant { filled, outlinedPrimary }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.variant,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final _ActionButtonVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == _ActionButtonVariant.filled;
    final borderColor = switch (variant) {
      _ActionButtonVariant.filled => null,
      _ActionButtonVariant.outlinedPrimary => AppColors.primary,
    };
    final foreground = isFilled ? AppColors.onPrimary : AppColors.primary;

    return Material(
      color: isFilled ? AppColors.primary : Colors.transparent,
      borderRadius: AppRadius.radiusBase,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusBase,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm + 4.r,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusBase,
            border: borderColor != null
                ? Border.all(color: borderColor)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20.r, color: foreground),
              SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.bodyLg.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.accentColor,
    required this.onTap,
  });

  final Map<String, dynamic> module;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = module['title'] as String? ?? module['id'] as String;
    final order = module['order'] ?? 0;
    final description = module['description'] as String? ?? '';
    final content = module['content'] as List<dynamic>? ?? [];
    final objectives = module['learningObjectives'] as List<dynamic>? ?? [];
    final taskCount = content.isNotEmpty ? content.length : objectives.length;
    final minutes = math.max(10, taskCount * 5);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusLg,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '$order. $title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20.r,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: 6.r),
                  Text(
                    description,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: AppSpacing.sm + 4.r),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.quiz_rounded,
                    size: 16.r,
                    color: AppColors.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.r),
                  Text(
                    '$taskCount Tasks',
                    style: AppTypography.labelMono.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.schedule_rounded,
                    size: 16.r,
                    color: AppColors.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.r),
                  Text(
                    '~${minutes}m',
                    style: AppTypography.labelMono.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
