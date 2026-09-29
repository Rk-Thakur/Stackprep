import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Vector icons for the report, stored as inline SVG.
///
/// The `pdf` package has its own SVG parser, so these are real paths rather
/// than glyphs from an icon font. That keeps the report self-contained: no font
/// to ship, no glyph to miss, and everything stays crisp when the PDF is
/// zoomed in.
///
/// Every template is drawn on the same 24x24 grid and uses two placeholders:
/// `{c}` for the main color and `{s}` for a lighter tint of it, so a single
/// template works in any accent color.
abstract final class ReportIcons {
  /// The StackPrep mark: a `</>` monogram, for a product about code.
  static const String code = '''
<path d="M8.4 6.1L2.2 12l6.2 5.9 2-2.1L6.2 12l4.2-3.8-2-2.1z" fill="{c}"/>
<path d="M15.6 6.1L13.6 8.2l4.2 3.8-4.2 3.8 2 2.1L21.8 12l-6.2-5.9z" fill="{c}"/>
<path d="M13.7 3.9l-3.4 16.2 2.2.4L15.9 4.3l-2.2-.4z" fill="{s}"/>
''';

  /// A teardrop flame with a hot core, for streak length.
  static const String flame = '''
<path d="M12 2.4L5.6 10.4a7.1 7.1 0 1 0 12.8 0L12 2.4z" fill="{c}"/>
<circle cx="12" cy="15.4" r="3.1" fill="{s}"/>
''';

  /// A circled tick, for logged sessions.
  static const String check = '''
<circle cx="12" cy="12" r="9" fill="none" stroke="{c}" stroke-width="2"/>
<path d="M7.8 12.4l2.9 2.9 5.5-5.8" fill="none" stroke="{c}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
''';

  /// A dial with a needle, for readiness against target.
  static const String gauge = '''
<path d="M3.6 18.4a9.4 9.4 0 1 1 16.8 0" fill="none" stroke="{c}" stroke-width="2" stroke-linecap="round"/>
<path d="M12 18.4l4.6-7.4" fill="none" stroke="{c}" stroke-width="2" stroke-linecap="round"/>
<circle cx="12" cy="18.4" r="1.9" fill="{c}"/>
''';

  /// A cup with handles and a star, for mastery.
  static const String trophy = '''
<path d="M7 3.4h10v5.2a5 5 0 0 1-10 0V3.4z" fill="{c}"/>
<path d="M11 13.6h2v3.4h-2z" fill="{c}"/>
<path d="M7.4 17h9.2v2.4H7.4z" fill="{c}"/>
<path d="M7.2 4.6H4.6v1.6a3.2 3.2 0 0 0 3.2 3.2" fill="none" stroke="{c}" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.8 4.6h2.6v1.6a3.2 3.2 0 0 1-3.2 3.2" fill="none" stroke="{c}" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M12 6.1l.95 1.9 2.1.3-1.5 1.5.35 2.1L12 10.9l-1.9 1-.35-2.1-1.5-1.5 2.1-.3L12 6.1z" fill="{s}"/>
''';

  /// A day sheet with a filled-in week, for the activity heatmap.
  static const String calendar = '''
<rect x="3.4" y="5" width="17.2" height="15.6" rx="3" fill="none" stroke="{c}" stroke-width="2"/>
<path d="M3.4 9.8h17.2" fill="none" stroke="{c}" stroke-width="2"/>
<path d="M8 3v3.6M16 3v3.6" fill="none" stroke="{c}" stroke-width="2" stroke-linecap="round"/>
<circle cx="8.6" cy="14" r="1.2" fill="{c}"/>
<circle cx="12" cy="14" r="1.2" fill="{c}"/>
<circle cx="15.4" cy="14" r="1.2" fill="{c}"/>
<circle cx="8.6" cy="17.4" r="1.2" fill="{c}"/>
<circle cx="12" cy="17.4" r="1.2" fill="{c}"/>
''';

  /// Three rising bars, for per-track competency.
  static const String bars = '''
<rect x="3.2" y="12.4" width="4.6" height="8.2" rx="1.6" fill="{s}"/>
<rect x="9.7" y="7.6" width="4.6" height="13" rx="1.6" fill="{c}"/>
<rect x="16.2" y="3.4" width="4.6" height="17.2" rx="1.6" fill="{c}"/>
''';

  /// Concentric rings, for focus areas.
  static const String target = '''
<circle cx="12" cy="12" r="8.6" fill="none" stroke="{c}" stroke-width="2"/>
<circle cx="12" cy="12" r="4.6" fill="none" stroke="{c}" stroke-width="2"/>
<circle cx="12" cy="12" r="1.5" fill="{c}"/>
''';

  /// A warning triangle, for a critical focus area.
  static const String warning = '''
<path d="M12 3.2l9.4 16.2H2.6L12 3.2z" fill="none" stroke="{c}" stroke-width="2" stroke-linejoin="round"/>
<path d="M12 9.4v4.4" fill="none" stroke="{c}" stroke-width="2.1" stroke-linecap="round"/>
<circle cx="12" cy="17" r="1.15" fill="{c}"/>
''';

  /// A climbing line, for a rising trend.
  static const String trendUp = '''
<path d="M4 16.6L9.4 11l3.4 3.4L20 7" fill="none" stroke="{c}" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M15.4 6.2H20v4.6" fill="none" stroke="{c}" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round"/>
''';

  /// A double-headed flat line, for a steady trend.
  static const String trendFlat = '''
<path d="M4.6 12h14.8" fill="none" stroke="{c}" stroke-width="2.1" stroke-linecap="round"/>
<path d="M8.2 8.6L4.6 12l3.6 3.4" fill="none" stroke="{c}" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M15.8 8.6l3.6 3.4-3.6 3.4" fill="none" stroke="{c}" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round"/>
''';

  /// A lightning bolt, for a level-up.
  static const String bolt = '''
<path d="M13.6 2.4L6.2 13.4h4.6l-1 8.2 7.8-11.4h-4.8l.8-7.8z" fill="{c}"/>
''';

  /// A shield with a tick, for a healthy or on-track verdict.
  static const String shield = '''
<path d="M12 2.6l7.4 2.8v5.4c0 4.6-3 8.6-7.4 10.2-4.4-1.6-7.4-5.6-7.4-10.2V5.4L12 2.6z" fill="none" stroke="{c}" stroke-width="2" stroke-linejoin="round"/>
<path d="M8.6 12.1l2.4 2.4 4.4-4.6" fill="none" stroke="{c}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
''';

  /// A lightbulb, for the recommendations panel.
  static const String bulb = '''
<path d="M12 2.8a6.4 6.4 0 0 0-3.8 11.5c.5.4.8 1 .8 1.6v.4h6v-.4c0-.6.3-1.2.8-1.6A6.4 6.4 0 0 0 12 2.8z" fill="{c}"/>
<path d="M9.4 18.3h5.2M10.5 21h3" fill="none" stroke="{c}" stroke-width="2" stroke-linecap="round"/>
''';

  /// A clock face, for the generated timestamp.
  static const String clock = '''
<circle cx="12" cy="12" r="9" fill="none" stroke="{c}" stroke-width="2"/>
<path d="M12 6.6V12l3.6 2.2" fill="none" stroke="{c}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
''';

  /// A person, for the signed-in identity.
  static const String user = '''
<circle cx="12" cy="8.2" r="3.9" fill="{c}"/>
<path d="M3.8 20.6a8.2 8.2 0 0 1 16.4 0z" fill="{c}"/>
''';

  /// Every icon in the set. Kept as a list so a test can render all of them
  /// and catch a malformed template, which would otherwise only show up as a
  /// blank spot in a real export.
  static const List<String> all = [
    code,
    flame,
    check,
    gauge,
    trophy,
    calendar,
    bars,
    target,
    warning,
    trendUp,
    trendFlat,
    bolt,
    shield,
    bulb,
    clock,
    user,
  ];

  /// The finished SVG for [template] at [size], with both color placeholders
  /// resolved. Public so the substitution can be asserted directly.
  static String resolve(
    String template, {
    required PdfColor color,
    double size = 14,
  }) {
    final body = template
        .replaceAll('{c}', _hex(color))
        .replaceAll('{s}', _hex(tint(color, 0.55)));
    return '<svg viewBox="0 0 24 24" width="$size" height="$size">$body</svg>';
  }

  /// Renders [template] at [size], tinted [color].
  static pw.Widget draw(
    String template, {
    required PdfColor color,
    double size = 14,
  }) {
    return pw.SvgImage(
      svg: resolve(template, color: color, size: size),
      width: size,
      height: size,
    );
  }

  /// [draw] on a rounded tile of the color's own tint, which is what makes the
  /// icons read as badges rather than loose glyphs.
  static pw.Widget tile(
    String template, {
    required PdfColor color,
    double size = 14,
    PdfColor? background,
    double radius = 6,
    double padding = 5,
  }) {
    return pw.Container(
      width: size + padding * 2,
      height: size + padding * 2,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: background ?? tint(color),
        borderRadius: pw.BorderRadius.circular(radius),
      ),
      child: draw(template, color: color, size: size),
    );
  }

  /// The `{s}` companion to `{c}`: the color washed out towards white so it can
  /// sit behind or inside the icon without a second palette entry.
  static PdfColor tint(PdfColor color, [double amount = 0.8]) {
    return PdfColor(
      color.red + (1 - color.red) * amount,
      color.green + (1 - color.green) * amount,
      color.blue + (1 - color.blue) * amount,
    );
  }

  /// Drops the alpha channel: the SVG colour parser is happier with six digits.
  static String _hex(PdfColor color) {
    return '#${(color.toInt() & 0xffffff).toRadixString(16).padLeft(6, '0')}';
  }
}
