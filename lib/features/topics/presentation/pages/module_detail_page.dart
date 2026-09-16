import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/code_block.dart';
import '../../../../injection_container.dart';
import '../../../practice/presentation/pages/practice_session_page.dart';
import '../../../progress/domain/usecases/mark_module_viewed.dart';

class ModuleDetailPage extends StatefulWidget {
  const ModuleDetailPage({
    super.key,
    required this.trackId,
    required this.moduleId,
  });

  final String trackId;
  final String moduleId;

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  Map<String, dynamic>? _module;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadModule();
  }

  Future<void> _loadModule() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('tracks')
          .doc(widget.trackId)
          .collection('modules')
          .doc(widget.moduleId)
          .get();
      setState(() {
        _module = doc.data();
        _loading = false;
      });
      if (_module != null) {
        unawaited(
          sl<MarkModuleViewed>()(
            MarkModuleViewedParams(
              trackId: widget.trackId,
              moduleId: widget.moduleId,
            ),
          ),
        );
      }
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
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const _ModuleDetailSkeleton()
                  : _module == null
                      ? Center(
                          child: Text(
                            'Module not found.',
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        )
                      : _ModuleContent(
                          trackId: widget.trackId,
                          moduleId: widget.moduleId,
                          module: _module!,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmering placeholder matching [_ModuleContent]'s layout while the
/// module document is still loading.
class _ModuleDetailSkeleton extends StatelessWidget {
  const _ModuleDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.margin,
          AppSpacing.lg,
          AppSpacing.margin,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Module title placeholder',
              style: AppTypography.headlineLgResponsive(
                context,
              ).copyWith(color: AppColors.onSurface),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'A short paragraph describing what this module teaches and '
              'why it matters for interview prep.',
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Learning Objectives',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16.r,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'A learning objective placeholder line',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              height: 140.r,
              decoration: BoxDecoration(
                color: AppColors.codeBlockBackground,
                borderRadius: AppRadius.radiusMd,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              height: 48.r,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.radiusBase,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleContent extends StatelessWidget {
  const _ModuleContent({
    required this.trackId,
    required this.moduleId,
    required this.module,
  });

  final String trackId;
  final String moduleId;
  final Map<String, dynamic> module;

  @override
  Widget build(BuildContext context) {
    final title = module['title'] as String? ?? '';
    final description = module['description'] as String? ?? '';
    final objectives = module['learningObjectives'] as List<dynamic>? ?? [];
    final content = module['content'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.lg,
        AppSpacing.margin,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headlineLgResponsive(context).copyWith(
              color: AppColors.onSurface,
            ),
          ),
          if (description.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
          if (objectives.isNotEmpty) ...[
            SizedBox(height: AppSpacing.lg),
            Text(
              'Learning Objectives',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            for (final obj in objectives)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16.r,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        obj as String,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (content.isNotEmpty) ...[
            SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < content.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == content.length - 1 ? 0 : AppSpacing.md,
                ),
                child: _ContentBlockWidget(block: content[i]),
              ),
          ],
          SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PracticeSessionPage(
                    topicCode: trackId,
                    moduleId: moduleId,
                  ),
                ),
              ),
              icon: Icon(Icons.quiz_rounded, size: 20.r),
              label: const Text('Take Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimaryContainer,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                textStyle: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusBase,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentBlockWidget extends StatelessWidget {
  const _ContentBlockWidget({required this.block});

  final dynamic block;

  @override
  Widget build(BuildContext context) {
    final type = (block as Map<String, dynamic>?)?['type'] ?? 'explanation';
    final text = block?['text'] as String? ?? '';
    final language = block?['language'] as String? ?? '';
    final code = block?['code'] as String? ?? '';

    if (type == 'heading') {
      return Text(
        text,
        style: AppTypography.headlineMd.copyWith(
          color: AppColors.onSurface,
          fontSize: 18.sp,
        ),
      );
    }

    if (type == 'code' && code.isNotEmpty) {
      final lines = code.split('\n');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Implementation Example',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          CodeBlock(
            header: language,
            language: language,
            lines: lines,
          ),
        ],
      );
    }

    if (text.isNotEmpty) {
      return Text(
        text,
        style: AppTypography.bodyLg.copyWith(
          color: AppColors.onSurfaceVariant,
          height: 1.5,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
