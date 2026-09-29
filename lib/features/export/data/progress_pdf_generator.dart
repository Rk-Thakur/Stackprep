import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stackprep/features/export/data/report_icons.dart';
import 'package:stackprep/features/export/domain/entities/progress_report.dart';

/// Renders a [ProgressReport] as a paginated PDF.
///
/// Print-only colors live here as constants: a PDF is a light document
/// regardless of the app theme it was exported from.
class ProgressPdfGenerator {
  const ProgressPdfGenerator();

  static const PdfColor _ink = PdfColor.fromInt(0xFF241B10);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6B5943);
  static const PdfColor _faint = PdfColor.fromInt(0xFFA08A6C);
  static const PdfColor _amber = PdfColor.fromInt(0xFF8A5A00);
  static const PdfColor _amberSoft = PdfColor.fromInt(0xFFFFC24D);
  static const PdfColor _rule = PdfColor.fromInt(0xFFE4D8C4);
  static const PdfColor _panel = PdfColor.fromInt(0xFFFAF5EC);
  static const PdfColor _error = PdfColor.fromInt(0xFFB3261E);
  static const PdfColor _errorTint = PdfColor.fromInt(0xFFFBEAE8);
  static const PdfColor _success = PdfColor.fromInt(0xFF2E6B3E);

  /// Ink ramp for the 5 heatmap buckets, lightest first.
  static const List<PdfColor> _heat = [
    PdfColor.fromInt(0xFFEDE2D1),
    PdfColor.fromInt(0xFFFFE2AC),
    PdfColor.fromInt(0xFFFFC65C),
    PdfColor.fromInt(0xFFFFB000),
    PdfColor.fromInt(0xFF8A5A00),
  ];

  /// Weekday initials down the left of the heatmap, Monday first.
  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  /// Rows in the activity grid. Capped so the section has a fixed height.
  static const int _heatmapWeeks = 8;

  /// The advice panel is ordered by impact, so anything past the first few is
  /// padding. Capping it keeps the report from spilling a near-empty last page.
  static const int _maxInsights = 4;

  Future<Uint8List> generate(ProgressReport report) async {
    final doc = pw.Document(
      title: 'StackPrep Progress Report',
      author: 'StackPrep',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 40),
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : _runningHeader(context),
        footer: (context) => _footer(context),
        build: (context) => [
          _hero(report),
          pw.SizedBox(height: 16),
          _verdict(report),
          pw.SizedBox(height: 16),
          _kpiGrid(report),
          pw.SizedBox(height: 20),
          if (report.activityLevels.isNotEmpty) ...[
            _sectionHeader(
              'CONSISTENCY',
              ReportIcons.calendar,
              'Day by day activity, most recent week at the right',
            ),
            _heatmap(report),
            pw.SizedBox(height: 8),
            _heatmapLegend(),
            pw.SizedBox(height: 20),
          ],
          if (report.competencies.isNotEmpty) ...[
            _sectionHeader(
              'TRACK COMPETENCY',
              ReportIcons.bars,
              'Score per track, weighted into your global mastery',
            ),
            _competencyCards(report),
            pw.SizedBox(height: 20),
          ],
          if (report.focusAreas.isNotEmpty) ...[
            _sectionHeader(
              'FOCUS AREAS',
              ReportIcons.target,
              'Ranked by how much each one is holding readiness back',
            ),
            _focusRows(report),
            pw.SizedBox(height: 20),
          ],
          _insights(report),
          pw.SizedBox(height: 14),
          _footnote(),
        ],
      ),
    );

    return doc.save();
  }

  // ── Hero ────────────────────────────────────────────────────────────────

  pw.Widget _hero(ProgressReport report) {
    final name = report.userName?.trim();
    final email = report.userEmail?.trim();
    final who = [
      if (name != null && name.isNotEmpty) name,
      if (email != null && email.isNotEmpty) email,
    ].join('  ·  ');

    final facts = <String>[
      if (report.currentStreakDays > 0)
        '${report.currentStreakDays}-day streak'
      else
        'no active streak',
      '${report.totalSessions} session${report.totalSessions == 1 ? '' : 's'}',
      '${report.competencies.length} track${report.competencies.length == 1 ? '' : 's'}',
      '${report.focusAreas.length} focus area${report.focusAreas.length == 1 ? '' : 's'}',
    ].join('  ·  ');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // An amber cap over a bordered panel, both rounded, so the header reads
        // as one card rather than a stack of boxes.
        pw.Container(
          height: 4,
          decoration: const pw.BoxDecoration(
            color: _amberSoft,
            borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(10)),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(16, 15, 16, 16),
          decoration: const pw.BoxDecoration(
            color: _panel,
            border: pw.Border.fromBorderSide(
              pw.BorderSide(color: _rule, width: 0.7),
            ),
            borderRadius: pw.BorderRadius.vertical(
              bottom: pw.Radius.circular(10),
            ),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 40,
                height: 40,
                alignment: pw.Alignment.center,
                decoration: const pw.BoxDecoration(
                  color: _ink,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(11)),
                ),
                child: ReportIcons.draw(
                  ReportIcons.code,
                  color: _amberSoft,
                  size: 24,
                ),
              ),
              pw.SizedBox(width: 13),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'STACKPREP',
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        letterSpacing: 3,
                        color: _amber,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Progress Report',
                      style: pw.TextStyle(
                        fontSize: 20,
                        color: _ink,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (who.isNotEmpty) ...[
                      pw.SizedBox(height: 7),
                      pw.Row(
                        children: [
                          ReportIcons.draw(
                            ReportIcons.user,
                            color: _faint,
                            size: 9,
                          ),
                          pw.SizedBox(width: 5),
                          pw.Expanded(
                            child: pw.Text(
                              who,
                              style: pw.TextStyle(fontSize: 9, color: _muted),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                    pw.SizedBox(height: 4),
                    pw.Text(
                      facts,
                      style: pw.TextStyle(fontSize: 7.5, color: _faint),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 10),
              _dateChip(report),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _dateChip(ProgressReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _rule, width: 0.7),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Row(
            children: [
              ReportIcons.draw(ReportIcons.clock, color: _faint, size: 9),
              pw.SizedBox(width: 4),
              pw.Text(
                'GENERATED',
                style: pw.TextStyle(
                  fontSize: 6.5,
                  letterSpacing: 1.4,
                  color: _faint,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            DateFormat.yMMMd().format(report.generatedAt),
            style: pw.TextStyle(
              fontSize: 8.5,
              color: _ink,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            DateFormat.jm().format(report.generatedAt),
            style: pw.TextStyle(fontSize: 7.5, color: _muted),
          ),
        ],
      ),
    );
  }

  // ── Verdict banner ──────────────────────────────────────────────────────

  /// A one-paragraph read on where the account actually is, so the numbers
  /// below arrive with an interpretation attached.
  pw.Widget _verdict(ProgressReport report) {
    final mastery = report.globalReadinessScore;
    final String icon;
    final PdfColor color;
    final String title;
    final String body;

    if (mastery >= 0.8) {
      icon = ReportIcons.shield;
      color = _success;
      title = 'Interview ready';
      body =
          'Global mastery sits at ${_percent(mastery)}, the top band for this '
          'stack. The job now is keeping your strongest tracks warm so a slow '
          'week cannot quietly undo them.';
    } else if (mastery >= 0.6) {
      icon = ReportIcons.trophy;
      color = _amber;
      title = 'Solid footing';
      body =
          'Global mastery is at ${_percent(mastery)}. You can hold a technical '
          'conversation across most areas; the focus areas below are what '
          'separate you from the top band.';
    } else if (mastery >= 0.35) {
      icon = ReportIcons.bars;
      color = _amber;
      title = 'Foundation building';
      body =
          'Global mastery is at ${_percent(mastery)}. The base is real but '
          'thin. At this stage, completing modules moves the number far more '
          'than rereading the ones you have already finished.';
    } else {
      icon = ReportIcons.bolt;
      color = _muted;
      title = 'Early momentum';
      body =
          'Global mastery is at ${_percent(mastery)}. Very little compounds at '
          'this stage, so the fastest win available is one completed module '
          'today rather than a long session this weekend.';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(13),
      decoration: pw.BoxDecoration(
        color: ReportIcons.tint(color, 0.88),
        borderRadius: pw.BorderRadius.circular(9),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          ReportIcons.tile(icon, color: color, size: 15, padding: 6, radius: 8),
          pw.SizedBox(width: 11),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 8,
                    letterSpacing: 1.8,
                    color: color,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  body,
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    color: _ink,
                    lineSpacing: 2.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── KPI cards ───────────────────────────────────────────────────────────

  pw.Widget _kpiGrid(ProgressReport report) {
    // No CrossAxisAlignment.stretch here: a stretched Row reports an infinite
    // height inside MultiPage, which trips the "widget won't fit" check.
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _kpi(
          icon: ReportIcons.flame,
          label: 'STREAK',
          value: '${report.currentStreakDays}',
          caption: report.currentStreakDays == 0
              ? 'no streak yet, start one today'
              : 'consecutive days practised',
        ),
        _gap(),
        _kpi(
          icon: ReportIcons.check,
          label: 'SESSIONS',
          value: '${report.totalSessions}',
          caption: 'practice sessions logged',
        ),
        _gap(),
        _kpi(
          icon: ReportIcons.gauge,
          label: 'READINESS',
          value: _percent(report.readinessScore),
          caption: 'your target is ${_percent(report.targetScore)}',
        ),
        _gap(),
        _kpi(
          icon: ReportIcons.trophy,
          label: 'MASTERY',
          value: _percent(report.globalReadinessScore),
          caption: 'global across every track',
          accent: report.globalReadinessScore >= 0.8 ? _success : _amber,
        ),
      ],
    );
  }

  pw.Widget _gap() => pw.SizedBox(width: 9);

  pw.Widget _kpi({
    required String icon,
    required String label,
    required String value,
    required String caption,
    PdfColor? accent,
  }) {
    final color = accent ?? _amber;
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.fromLTRB(11, 11, 11, 12),
        decoration: pw.BoxDecoration(
          color: _panel,
          border: pw.Border.all(color: _rule, width: 0.7),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                ReportIcons.tile(
                  icon,
                  color: color,
                  size: 11,
                  padding: 4,
                  radius: 5,
                ),
                pw.SizedBox(width: 5),
                pw.Expanded(
                  child: pw.Text(
                    label,
                    style: pw.TextStyle(
                      fontSize: 7,
                      letterSpacing: 1.2,
                      color: _muted,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 9),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 19,
                color: _ink,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              caption,
              style: pw.TextStyle(fontSize: 7, color: _muted, lineSpacing: 1.6),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ── Sections ────────────────────────────────────────────────────────────

  pw.Widget _sectionHeader(String title, String icon, String note) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            ReportIcons.tile(
              icon,
              color: _amber,
              size: 13,
              padding: 5,
              radius: 7,
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 9,
                letterSpacing: 1.8,
                color: _ink,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(child: pw.Container(height: 0.6, color: _rule)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(note, style: pw.TextStyle(fontSize: 7.5, color: _muted)),
        pw.SizedBox(height: 9),
      ],
    );
  }

  /// GitHub-style grid, laid out 7 columns per week, oldest day top-left.
  pw.Widget _heatmap(ProgressReport report) {
    // Only the most recent weeks are drawn. An account with a year of history
    // would otherwise push the rest of the report onto an extra page, and the
    // recent window is the part worth reading anyway.
    final levels = report.activityLevels.length > _heatmapWeeks * 7
        ? report.activityLevels.sublist(
            report.activityLevels.length - _heatmapWeeks * 7,
          )
        : report.activityLevels;

    // Pad the start so the first cell lands on the right weekday column.
    final cells = <int>[];
    final lead = levels.length % 7 == 0 ? 0 : 7 - (levels.length % 7);
    for (var i = 0; i < lead; i++) {
      cells.add(-1);
    }
    cells.addAll(levels);
    while (cells.length % 7 != 0) {
      cells.add(-1);
    }

    const size = 9.0;
    const gap = 1.5;

    // Seven columns per row, one column per weekday, so the labels on the left
    // line up with the cells. A Wrap would reflow to whatever fits the page
    // width and drift away from them.
    final weeks = <List<int>>[];
    for (var i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, (i + 7).clamp(0, cells.length)));
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          children: [
            for (final letter in _weekdays)
              pw.Container(
                width: 10,
                height: size + gap,
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  letter,
                  style: pw.TextStyle(fontSize: 5.5, color: _faint),
                ),
              ),
          ],
        ),
        pw.SizedBox(width: 5),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (final week in weeks)
                pw.Padding(
                  padding: pw.EdgeInsets.only(
                    bottom: week == weeks.last ? 0 : gap,
                  ),
                  child: pw.Row(
                    children: [
                      for (final level in week)
                        pw.Container(
                          width: size,
                          height: size,
                          margin: pw.EdgeInsets.only(
                            right: level == week.last ? 0 : gap,
                          ),
                          decoration: pw.BoxDecoration(
                            color: level < 0
                                ? PdfColors.white
                                : _heat[level.clamp(0, _heat.length - 1)],
                            border: pw.Border.all(
                              color: level < 0 ? PdfColors.white : _rule,
                              width: 0.4,
                            ),
                            borderRadius: pw.BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _heatmapLegend() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
          'LESS',
          style: pw.TextStyle(fontSize: 6.5, color: _muted, letterSpacing: 0.8),
        ),
        pw.SizedBox(width: 6),
        for (final color in _heat) ...[
          pw.Container(
            width: 8,
            height: 8,
            decoration: pw.BoxDecoration(
              color: color,
              border: pw.Border.all(color: _rule, width: 0.4),
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 2),
        ],
        pw.SizedBox(width: 4),
        pw.Text(
          'MORE',
          style: pw.TextStyle(fontSize: 6.5, color: _muted, letterSpacing: 0.8),
        ),
      ],
    );
  }

  // ── Track competency ────────────────────────────────────────────────────

  pw.Widget _competencyCards(ProgressReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final c in report.competencies) ...[
          _competencyCard(c),
          pw.SizedBox(height: 7),
        ],
      ],
    );
  }

  pw.Widget _competencyCard(ReportCompetency c) {
    final fill = _bandColor(c.score);
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(11, 10, 11, 11),
      decoration: pw.BoxDecoration(
        color: _panel,
        border: pw.Border.all(color: _rule, width: 0.7),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              ReportIcons.tile(
                ReportIcons.bars,
                color: fill,
                size: 12,
                padding: 4,
                radius: 5,
              ),
              pw.SizedBox(width: 9),
              pw.Expanded(
                child: pw.Text(
                  c.trackName,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    color: _ink,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            '${c.level}  ·  ${c.modulesLabel} modules',
            style: pw.TextStyle(fontSize: 7, color: _muted),
          ),
          pw.SizedBox(height: 8),
          // The score shares the bar's line instead of sitting above it, so the
          // figure and the indicator can never touch or read as one shape.
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(child: _bar(c.score / 100, fill)),
              pw.SizedBox(width: 9),
              pw.Text(
                '${c.score}%',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: _ink,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Focus areas ─────────────────────────────────────────────────────────

  pw.Widget _focusRows(ProgressReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final f in report.focusAreas) ...[
          _focusRow(f),
          pw.SizedBox(height: 7),
        ],
      ],
    );
  }

  pw.Widget _focusRow(ReportFocusArea f) {
    final accent = f.critical ? _error : _amber;
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(11, 10, 11, 11),
      decoration: pw.BoxDecoration(
        color: f.critical ? _errorTint : _panel,
        border: pw.Border.all(color: f.critical ? _error : _rule, width: 0.7),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          ReportIcons.tile(
            f.critical ? ReportIcons.warning : ReportIcons.target,
            color: accent,
            size: 12,
            padding: 4,
            radius: 5,
          ),
          pw.SizedBox(width: 9),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Flexible(
                      child: pw.Text(
                        f.title,
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          color: _ink,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    if (f.critical) ...[
                      pw.SizedBox(width: 6),
                      _chip('CRITICAL', _error, _errorTint),
                    ],
                  ],
                ),
                pw.SizedBox(height: 7),
                _bar(f.percent, accent),
              ],
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                _percent(f.percent),
                style: pw.TextStyle(
                  fontSize: 9.5,
                  color: _ink,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  ReportIcons.draw(
                    _trendIcon(f.trendLabel),
                    color: _faint,
                    size: 9,
                  ),
                  pw.SizedBox(width: 4),
                  pw.Text(
                    f.trendLabel,
                    style: pw.TextStyle(fontSize: 7, color: _muted),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _chip(String text, PdfColor color, PdfColor background) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: pw.BoxDecoration(
        color: background,
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 6,
          letterSpacing: 0.8,
          color: color,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  /// A two-segment bar. Both halves keep a flex of at least one so a 0% or 100%
  /// score still renders a visible bar instead of collapsing to nothing.
  pw.Widget _bar(double fraction, PdfColor fill) {
    final filled = (fraction.clamp(0.0, 1.0) * 100).round().clamp(1, 99);
    return pw.Row(
      children: [
        pw.Expanded(
          flex: filled,
          child: pw.Container(
            height: 5,
            decoration: pw.BoxDecoration(
              color: fill,
              borderRadius: pw.BorderRadius.circular(2.5),
            ),
          ),
        ),
        pw.Expanded(
          flex: 100 - filled,
          child: pw.Container(height: 5, color: _rule),
        ),
      ],
    );
  }

  PdfColor _bandColor(int score) {
    if (score >= 75) return _success;
    if (score >= 45) return _amber;
    return _error;
  }

  /// Maps the free-text trend label the progress layer produces onto an icon.
  /// Unrecognised wording falls back to the flat arrow rather than guessing.
  String _trendIcon(String label) {
    final value = label.toLowerCase();
    if (value.contains('up') ||
        value.contains('rising') ||
        value.contains('gain')) {
      return ReportIcons.trendUp;
    }
    if (value.contains('level') || value.contains('promot')) {
      return ReportIcons.bolt;
    }
    return ReportIcons.trendFlat;
  }

  // ── Recommendations ─────────────────────────────────────────────────────

  pw.Widget _insights(ProgressReport report) {
    final items = _insightList(report);
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(14, 13, 14, 4),
      decoration: pw.BoxDecoration(
        color: _panel,
        border: pw.Border.all(color: _rule, width: 0.7),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              ReportIcons.tile(
                ReportIcons.bulb,
                color: _amber,
                size: 13,
                padding: 5,
                radius: 7,
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'WHAT TO DO NEXT',
                style: pw.TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.8,
                  color: _ink,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Derived from the numbers above, not generic advice.',
            style: pw.TextStyle(fontSize: 7.5, color: _muted),
          ),
          pw.SizedBox(height: 10),
          for (final item in items.take(_maxInsights)) ...[
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                ReportIcons.tile(
                  item.icon,
                  color: item.color,
                  size: 10,
                  padding: 4,
                  radius: 5,
                ),
                pw.SizedBox(width: 9),
                pw.Expanded(
                  child: pw.Text(
                    item.text,
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      color: _ink,
                      lineSpacing: 2.2,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  /// Recommendations, each one only present when the data actually supports it.
  List<_Insight> _insightList(ProgressReport report) {
    final out = <_Insight>[];

    final streak = report.currentStreakDays;
    if (streak >= 30) {
      out.add(
        _Insight(
          ReportIcons.flame,
          '$streak days without a break. Past this point consistency, not '
          'intensity, is what keeps the score moving. A short daily '
          'session outperforms the occasional long one.',
          _amber,
        ),
      );
    } else if (streak >= 3) {
      out.add(
        _Insight(
          ReportIcons.flame,
          'A $streak-day streak is building. Protect it on the days you least '
          'feel like practising by making the session small enough that '
          'skipping it feels like the harder option.',
          _amber,
        ),
      );
    } else if (streak == 0) {
      out.add(
        _Insight(
          ReportIcons.check,
          'No active streak. Ten minutes today is enough to start one, and a '
          'streak is the cheapest way to raise consistency across every '
          'track at once.',
          _amber,
        ),
      );
    }

    final critical = report.focusAreas.where((f) => f.critical).toList();
    if (critical.isNotEmpty) {
      final names = critical.take(3).map((f) => f.title).join(', ');
      final rest = critical.length > 3
          ? ' and ${critical.length - 3} more'
          : '';
      out.add(
        _Insight(
          ReportIcons.warning,
          '${critical.length == 1 ? 'One area is' : '${critical.length} areas are'} '
          'flagged critical: $names$rest. Critical areas are weighted '
          'heaviest, so clearing one moves readiness more than any other '
          'single action available to you.',
          _error,
        ),
      );
    }

    if (report.competencies.length > 1) {
      final weakest = report.competencies.reduce(
        (a, b) => a.score <= b.score ? a : b,
      );
      out.add(
        _Insight(
          ReportIcons.bars,
          '${weakest.trackName} is your lowest track at ${weakest.score}% '
          '(${weakest.modulesLabel} modules). The global score is an '
          'average, so lifting the weakest entry lifts everything.',
          _bandColor(weakest.score),
        ),
      );
    }

    if (report.competencies.isNotEmpty) {
      final strongest = report.competencies.reduce(
        (a, b) => a.score >= b.score ? a : b,
      );
      if (strongest.score >= 80) {
        out.add(
          _Insight(
            ReportIcons.trophy,
            '${strongest.trackName} is at ${strongest.score}%. You already '
            'have a strong anchor here. Keep it warm with periodic '
            'review so it stays interview-ready without re-learning it.',
            _success,
          ),
        );
      }
    }

    final gap = report.targetScore - report.readinessScore;
    if (gap > 0.02) {
      out.add(
        _Insight(
          ReportIcons.gauge,
          'Readiness is ${_percent(gap)} below your '
          '${_percent(report.targetScore)} target. The focus areas above '
          'are ordered by how much each one weighs on that number, so '
          'working them top-down is the shortest route to the line.',
          _amber,
        ),
      );
    }

    final levels = report.activityLevels;
    if (levels.isEmpty) {
      out.add(
        _Insight(
          ReportIcons.calendar,
          'No activity has been recorded yet. The consistency grid fills in '
          'as soon as you complete your first session, so there is no '
          'reason to wait on a full week before it appears.',
          _muted,
        ),
      );
    } else {
      final tail = levels.length > 3
          ? levels.sublist(levels.length - 3)
          : levels;
      if (tail.length == 3 && tail.every((level) => level == 0)) {
        out.add(
          _Insight(
            ReportIcons.warning,
            'The last three days are empty. Gaps like this are where streaks '
            'usually break, so keep the next session deliberately small: '
            'one module is enough to keep the chain intact.',
            _error,
          ),
        );
      }
    }

    if (out.isEmpty) {
      out.add(
        _Insight(
          ReportIcons.shield,
          'Nothing is flagged on this report. Hold the current rhythm and '
          're-check the focus areas as soon as new modules unlock.',
          _success,
        ),
      );
    }
    return out;
  }

  // ── Chrome ──────────────────────────────────────────────────────────────

  pw.Widget _runningHeader(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _rule, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          ReportIcons.draw(ReportIcons.code, color: _amber, size: 9),
          pw.SizedBox(width: 6),
          pw.Text(
            'STACKPREP  ·  PROGRESS REPORT',
            style: pw.TextStyle(fontSize: 7, letterSpacing: 1.6, color: _muted),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Text(
              'PAGE ${context.pageNumber}',
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 7,
                letterSpacing: 1.6,
                color: _faint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _footer(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 14),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by StackPrep, interview prep for mobile engineers',
            style: pw.TextStyle(fontSize: 7, color: _faint),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 7, color: _muted),
          ),
        ],
      ),
    );
  }

  pw.Widget _footnote() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        color: _panel,
        border: pw.Border.all(color: _rule, width: 0.7),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          ReportIcons.draw(ReportIcons.shield, color: _faint, size: 11),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              'This report reflects the activity recorded on your account up to '
              'the generation time shown above. Readiness is measured against '
              'your chosen target, global mastery is the average across active '
              'tracks, and critical focus areas are the ones carrying the most '
              'weight against it.',
              style: pw.TextStyle(
                fontSize: 7.5,
                color: _muted,
                lineSpacing: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _percent(double fraction) => '${(fraction * 100).round()}%';
}

/// One recommendation, tied to the icon and accent it is rendered with.
class _Insight {
  const _Insight(this.icon, this.text, this.color);

  final String icon;
  final String text;
  final PdfColor color;
}
