import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens.
///
/// Inter handles UI labels, headers, and body text. JetBrains Mono handles
/// numerals, data points, code blocks, and metadata labels.
abstract final class AppTypography {
  static TextStyle get headlineLg => GoogleFonts.inter(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.02 * 32.sp,
  );

  /// [headlineLg], scaled down for narrow screens (< 375px wide) per
  /// DESIGN.md's mobile-specific adjustment.
  static TextStyle headlineLgResponsive(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 375) {
      return headlineLg.copyWith(fontSize: 28.sp);
    }
    return headlineLg;
  }

  static TextStyle get headlineMd => GoogleFonts.inter(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    letterSpacing: -0.01 * 24.sp,
  );

  static TextStyle get bodyLg => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static TextStyle get bodyMd => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static TextStyle get codeSm => GoogleFonts.jetBrainsMono(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    height: 20 / 13,
  );

  static TextStyle get labelMono => GoogleFonts.jetBrainsMono(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.05 * 12.sp,
  );

  static TextStyle get numeralLg => GoogleFonts.jetBrainsMono(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    height: 24 / 24,
  );
}
