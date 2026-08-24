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
/// Cell intensity is derived deterministically from [seed] so the pattern
/// stays stable across rebuilds.
class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({
    super.key,
    required this.days,
    this.columns = 7,
    this.seed = 7,
  });

  final int days;
  final int columns;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final rows = (days / columns).ceil();
    final random = Random(seed);
    final cellSize = 10.r;
    final gap = 4.r;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(columns, (col) {
        return Column(
          children: List.generate(rows, (row) {
            final index = col * rows + row;
            final level = index >= days ? 0 : random.nextInt(5);
            return Padding(
              padding: EdgeInsets.only(bottom: row == rows - 1 ? 0 : gap),
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: kReadinessScale[level],
                  borderRadius: AppRadius.radiusSm,
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
