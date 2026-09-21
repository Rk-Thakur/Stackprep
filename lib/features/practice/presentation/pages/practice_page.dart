import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../injection_container.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../progress/domain/entities/track_competency.dart';
import '../../../progress/domain/usecases/get_progress_overview.dart';
import '../../../progress/presentation/pages/progress_page.dart';
import '../../../topics/presentation/pages/topic_detail_page.dart';

/// Practice tab: pick a track to drill, or jump into a cross-platform
/// concept that spans every stack.
class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  List<Map<String, dynamic>> _tracks = [];
  Map<String, TrackCompetency> _competencyByTrack = {};
  bool _loading = true;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
    _loadTracks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTracks {
    if (_query.isEmpty) return _tracks;
    return _tracks.where((t) {
      final name = (t['name'] as String? ?? '').toLowerCase();
      final description = (t['description'] as String? ?? '').toLowerCase();
      return name.contains(_query) || description.contains(_query);
    }).toList();
  }

  Future<void> _loadTracks() async {
    try {
      final tracksFuture = FirebaseFirestore.instance
          .collection('tracks')
          .orderBy('order')
          .get();
      final overviewFuture = sl<GetProgressOverview>()(const NoParams());

      final snap = await tracksFuture;
      final overviewResult = await overviewFuture;

      final competencyByTrack = <String, TrackCompetency>{};
      overviewResult.fold((_) {}, (overview) {
        for (final c in overview.competencies) {
          competencyByTrack[c.trackId] = c;
        }
      });

      setState(() {
        _tracks = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _competencyByTrack = competencyByTrack;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(showBottomDivider: true),
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
                    Text(
                      'Technical Tracks',
                      style: AppTypography.headlineLgResponsive(context)
                          .copyWith(color: AppColors.onSurface),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Select a domain to begin mastering technical '
                      'interview patterns.',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    _SearchField(controller: _searchController),
                    SizedBox(height: AppSpacing.lg),
                    if (_loading)
                      const _TrackListSkeleton()
                    else if (_filteredTracks.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          child: Text(
                            _query.isEmpty
                                ? 'No tracks available.'
                                : 'No tracks match your search.',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < _filteredTracks.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == _filteredTracks.length - 1
                                ? 0
                                : AppSpacing.md,
                          ),
                          child: _FirestoreTrackCard(
                            track: _filteredTracks[i],
                            competency:
                                _competencyByTrack[_filteredTracks[i]['id']
                                    as String],
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TopicDetailPage(
                                    trackId:
                                        _filteredTracks[i]['id'] as String,
                                  ),
                                ),
                              );
                              // Refresh competency indicators after returning
                              // from the track so progress is up to date.
                              if (mounted) _loadTracks();
                            },
                          ),
                        ),
                    SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            AppBottomNavBar(
              currentIndex: 1,
              onTap: (i) {
                if (i == 1) return;
                if (i == 0) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  return;
                }
                if (i == 2) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProgressPage()),
                  );
                  return;
                }
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20.r,
            color: AppColors.onSurfaceVariant,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search tracks...',
                hintStyle: AppTypography.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14.r),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: controller.clear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

class _TrackListSkeleton extends StatelessWidget {
  const _TrackListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == 2 ? 0 : AppSpacing.md),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              'Track name',
                              style: AppTypography.labelMono.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 56.r,
                          height: 56.r,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'A short description of what this track covers for '
                      'the learner.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    const _SegmentedBar(value: 0),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Maps a track's id/name to a representative glyph — the track catalog
/// only stores a color, not an icon.
IconData _iconForTrack(String id, String name) {
  final key = '$id $name'.toLowerCase();
  if (key.contains('kotlin')) return Icons.data_object_rounded;
  if (key.contains('swift')) return Icons.terminal_rounded;
  if (key.contains('flutter')) return Icons.flutter_dash;
  if (key.contains('react')) return Icons.hub_rounded;
  if (key.contains('system') || key.contains('design')) {
    return Icons.architecture_rounded;
  }
  return Icons.code_rounded;
}

class _FirestoreTrackCard extends StatelessWidget {
  const _FirestoreTrackCard({
    required this.track,
    required this.onTap,
    this.competency,
  });

  final Map<String, dynamic> track;
  final VoidCallback onTap;
  final TrackCompetency? competency;

  @override
  Widget build(BuildContext context) {
    final color = Color(track['color'] as int? ?? 0xFF888888);
    final id = track['id'] as String? ?? '';
    final name = track['name'] as String? ?? id;
    final description = track['description'] as String? ?? '';
    final score = competency?.score ?? 0;

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconForTrack(id, name),
                    size: 18.r,
                    color: color,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    name.toUpperCase(),
                    style: AppTypography.labelMono.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 56.r,
                  height: 56.r,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 56.r,
                        height: 56.r,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 4,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primaryFixedDim,
                          ),
                        ),
                      ),
                      Text(
                        '$score%',
                        style: AppTypography.labelMono.copyWith(
                          color: AppColors.onSurface,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: AppSpacing.sm),
            _SegmentedBar(value: score / 100),
          ],
        ),
      ),
    );
  }
}

/// A blocky "telemetry" progress bar — a handful of thick segments rather
/// than a smooth fill, matching the app's terminal/mono aesthetic.
class _SegmentedBar extends StatelessWidget {
  const _SegmentedBar({required this.value});

  final double value;

  static const int _segments = 4;

  @override
  Widget build(BuildContext context) {
    final filled = (value.clamp(0, 1) * _segments).round();
    return Row(
      children: List.generate(_segments, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == _segments - 1 ? 0 : 4.r),
            child: Container(
              height: 6.r,
              decoration: BoxDecoration(
                color: i < filled
                    ? AppColors.primaryFixedDim
                    : AppColors.surfaceContainerHigh,
                borderRadius: AppRadius.radiusSm,
              ),
            ),
          ),
        );
      }),
    );
  }
}
