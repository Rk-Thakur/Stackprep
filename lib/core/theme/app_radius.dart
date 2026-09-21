import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Corner radius tokens, scaled per-device via ScreenUtil.
abstract final class AppRadius {
  static double get sm => 4.r; // 0.25rem
  static double get base => 8.r; // 0.5rem (DEFAULT)
  static double get md => 12.r; // 0.75rem
  static double get lg => 16.r; // 1rem
  static double get xl => 24.r; // 1.5rem
  static double get full => 9999.r;

  static BorderRadius get radiusSm => BorderRadius.all(Radius.circular(sm));
  static BorderRadius get radiusBase => BorderRadius.all(Radius.circular(base));
  static BorderRadius get radiusMd => BorderRadius.all(Radius.circular(md));
  static BorderRadius get radiusLg => BorderRadius.all(Radius.circular(lg));
  static BorderRadius get radiusXl => BorderRadius.all(Radius.circular(xl));
  static BorderRadius get radiusFull => BorderRadius.all(Radius.circular(full));
}
