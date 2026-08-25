import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../cubit/topic_cubit.dart';
import '../cubit/topic_state.dart';
import 'mcq_page.dart';
import 'module_detail_page.dart';

class TopicDetailPage extends StatelessWidget {
  const TopicDetailPage({super.key, this.topicId = 'KTN_COR'});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TopicCubit()..loadTopic(topicId),
      child: const _TopicDetailView(),
    );
  }
}

class _TopicDetailView extends StatelessWidget {
  const _TopicDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.margin,
                vertical: AppSpacing.sm,
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
                          'Back',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.outlineVariant),
            // Content
            Expanded(
              child: BlocBuilder<TopicCubit, TopicState>(
                builder: (context, state) {
                  if (state.status == TopicStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.topic == null) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Topic not found.',
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return _TopicContent(topic: state.topic!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicContent extends StatelessWidget {
  const _TopicContent({required this.topic});

  final dynamic topic;

  @override
  Widget build(BuildContext context) {
    final trackColor = Color(topic.trackColor);

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
          // Level + Track pills
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6.r,
                ),
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
                      topic.level,
                      style: AppTypography.labelMono.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6.r,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: trackColor.withValues(alpha: 0.6),
                  ),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.code_rounded,
                      size: 14.r,
                      color: trackColor,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      topic.trackName,
                      style: AppTypography.labelMono.copyWith(
                        color: trackColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          // Title
          Text(
            topic.title,
            style: AppTypography.headlineLgResponsive(context).copyWith(
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          // Description
          if (topic.description.isNotEmpty)
            Text(
              topic.description,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          SizedBox(height: AppSpacing.lg),
          // Start Practice button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => McqPage(topicId: topic.id),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 14.r),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusMd,
                ),
              ),
              child: Text(
                'Start Practice',
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          // Modules header
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Modules',
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${topic.modules.length}',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          // Module cards
          for (var i = 0; i < topic.modules.length; i++)
            _ModuleCard(
              index: i + 1,
              module: topic.modules[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ModuleDetailPage(),
                ),
              ),
            ),
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
  final dynamic module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
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
              Text(
                '$index. ${module.title}',
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (module.description.isNotEmpty) ...[
                SizedBox(height: 4.r),
                Text(
                  module.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
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
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.r,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
