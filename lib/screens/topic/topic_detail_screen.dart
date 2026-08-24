import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../practice/practice_session_screen.dart';
import 'module_detail_screen.dart';

class _SubtopicModule {
  const _SubtopicModule({
    required this.title,
    required this.description,
    required this.taskCount,
    required this.duration,
  });

  final String title;
  final String description;
  final int taskCount;
  final String duration;
}

const List<_SubtopicModule> _kModules = [
  _SubtopicModule(
    title: 'Basics & Builders',
    description:
        'Understanding launch vs. async, runBlocking, and the lifecycle of '
        'a basic coroutine job.',
    taskCount: 5,
    duration: '~20m',
  ),
  _SubtopicModule(
    title: 'Dispatchers & Context',
    description:
        'Managing thread allocation. Switching contexts with withContext. '
        'Default, IO, and Main dispatchers explained.',
    taskCount: 8,
    duration: '~35m',
  ),
  _SubtopicModule(
    title: 'Structured Concurrency',
    description:
        'CoroutineScope, Job hierarchies, and how cancellation propagates '
        'through parents and children.',
    taskCount: 6,
    duration: '~30m',
  ),
  _SubtopicModule(
    title: 'Exception Handling',
    description:
        'CoroutineExceptionHandler vs try/catch. SupervisorJob and '
        'managing isolated failures across children.',
    taskCount: 4,
    duration: '~15m',
  ),
];

/// Topic detail / challenge-start screen, e.g. reached from the home
/// screen's daily-challenge "Start Challenge" button.
class TopicDetailScreen extends StatelessWidget {
  const TopicDetailScreen({
    super.key,
    this.topicId = 'KTN_COR',
    this.level = 'INTERMEDIATE',
    this.trackName = 'KOTLIN',
    this.trackColor = const Color(0xFF8B5CF6),
    this.title = 'Kotlin Coroutines',
    this.description =
        'Master asynchronous programming in Kotlin. Coroutines simplify '
        'background tasks, networking, and complex concurrent flows by '
        'allowing you to write asynchronous code sequentially. This '
        'module covers dispatchers, scopes, builders, and structured '
        'concurrency.',
  });

  final String topicId;
  final String level;
  final String trackName;
  final Color trackColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            _LibraryBar(topicId: topicId),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.md,
                  AppSpacing.margin,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _LevelPill(label: level),
                        SizedBox(width: AppSpacing.xs),
                        _TrackPillOutlined(label: trackName, color: trackColor),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      title,
                      style: AppTypography.headlineLgResponsive(context)
                          .copyWith(color: AppColors.onSurface),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      description,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PracticeSessionScreen(),
                          ),
                        ),
                        icon: Icon(Icons.play_arrow_rounded, size: 20.r),
                        label: const Text('Start Practice'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.r),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusMd,
                          ),
                          textStyle: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.bookmark_add_outlined, size: 20.r),
                        label: const Text('Save for Later'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.r),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusMd,
                          ),
                          textStyle: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Container(height: 1, color: AppColors.outlineVariant),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            'Sub-topics & Challenges',
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${_kModules.length} MODULES',
                          style: AppTypography.labelMono.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    for (var i = 0; i < _kModules.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == _kModules.length - 1 ? 0 : AppSpacing.md,
                        ),
                        child: _ModuleCard(
                          index: i + 1,
                          module: _kModules[i],
                          onTap: () {
                            if (i == 0) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ModuleDetailScreen(),
                                ),
                              );
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${_kModules[i].title} coming soon.',
                                ),
                              ),
                            );
                          },
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

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(
              Icons.terminal_rounded,
              size: 16.r,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              "Engineer's Notebook",
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 18.sp,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.surfaceContainerHigh,
            child: Icon(
              Icons.person_rounded,
              size: 20.r,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryBar extends StatelessWidget {
  const _LibraryBar({required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 1, color: AppColors.outlineVariant),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.margin,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: AppRadius.radiusSm,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 18.r,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Library',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4.r,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outlineVariant),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  'TOPIC_ID: $topicId',
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6.r),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: const BoxDecoration(
              color: AppColors.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelMono.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackPillOutlined extends StatelessWidget {
  const _TrackPillOutlined({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6.r),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.code_rounded, size: 14.r, color: color),
          SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.labelMono.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.index,
    required this.module,
    required this.onTap,
  });

  final int index;
  final _SubtopicModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$index. ${module.title}',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18.r,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
            SizedBox(height: 4.r),
            Text(
              module.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Container(height: 1, color: AppColors.outlineVariant),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 15.r,
                  color: AppColors.onSurfaceVariant,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '${module.taskCount} Tasks',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.access_time_rounded,
                  size: 15.r,
                  color: AppColors.onSurfaceVariant,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  module.duration,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
