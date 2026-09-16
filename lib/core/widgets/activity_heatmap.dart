import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// The amber intensity scale shared by [ActivityHeatmap] cells and
/// [ReadinessLegend], lowest to highest.
const List<Color> kReadinessScale = [
  AppColors.surfaceContainerHigh,
  Color(0xFF6B4A1E),
  Color(0xFFB47A2A),
  AppColors.primaryContainer,
  AppColors.primary,
];

/// A GitHub-style grid of small squares showing recent daily activity.
///
/// Pass real per-day intensities (0-4, oldest first) via [levels]. When
/// omitted, cell intensity falls back to a value derived deterministically
/// from [seed] so the widget stays usable without live data.
class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({
    super.key,
    required this.days,
    this.columns = 7,
    this.seed = 7,
    this.levels,
    this.streakDays = 0,
  });

  final int days;
  final int columns;
  final int seed;
  final List<int>? levels;

  /// Number of consecutive active days in the most recent streak.
  /// The last [streakDays] non-zero cells are highlighted with a bright
  /// border so the streak is visually evident in the grid.
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final rows = (days / columns).ceil();
    final random = Random(seed);
    final cellSize = 10.r;
    final gap = 4.r;
    final realLevels = levels;

    // Find the start of the most recent streak in the levels list.
    var streakStart = -1;
    if (streakDays > 0 && realLevels != null) {
      var i = realLevels.length - 1;
      while (i >= 0 && realLevels[i] == 0) {
        i--;
      }
      streakStart = i - streakDays + 1;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(columns, (col) {
        return Column(
          children: List.generate(rows, (row) {
            final index = col * rows + row;
            final level = index >= days
                ? 0
                : realLevels != null
                    ? (index < realLevels.length
                        ? realLevels[index].clamp(0, 4)
                        : 0)
                    : random.nextInt(5);
            final inStreak = index >= streakStart &&
                index <= streakStart + streakDays - 1 &&
                level > 0;
            final cellColor = inStreak
                ? Color.lerp(kReadinessScale[level], AppColors.primary, 0.4)!
                : kReadinessScale[level];
            final glowColor = inStreak ? kReadinessScale[level] : null;
            return Padding(
              padding: EdgeInsets.only(bottom: row == rows - 1 ? 0 : gap),
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: AppRadius.radiusSm,
                  border: inStreak
                      ? Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        )
                      : null,
                  boxShadow: glowColor != null
                      ? [
                          BoxShadow(
                            color: glowColor.withValues(alpha: 0.6),
                            blurRadius: 6.r,
                            spreadRadius: 1.r,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

/// Small "Less -> More" legend of the same amber scale used by
/// [ActivityHeatmap], labeled "Readiness Levels".
class ReadinessLegend extends StatelessWidget {
  const ReadinessLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final cellSize = 10.r;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(kReadinessScale.length, (i) {
        return Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 4.r),
          child: Container(
            width: cellSize,
            height: cellSize,
            decoration: BoxDecoration(
              color: kReadinessScale[i],
              borderRadius: AppRadius.radiusSm,
            ),
          ),
        );
      }),
    );
  }
}