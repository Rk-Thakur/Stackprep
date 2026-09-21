import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing tokens — strict 4px base grid, scaled per-device via ScreenUtil.
abstract final class AppSpacing {
  static double get unit => 4.r;
  static double get xs => 4.r;
  static double get sm => 8.r;
  static double get md => 16.r;
  static double get lg => 24.r;
  static double get xl => 32.r;

  /// Gutter between grid columns / list items.
  static double get gutter => 16.r;

  /// Standard horizontal screen margin.
  static double get margin => 20.r;
}
