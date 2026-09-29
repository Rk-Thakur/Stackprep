import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stackprep/core/error/failures.dart';
import 'package:stackprep/core/usecases/usecase.dart';
import 'package:stackprep/features/auth/domain/entities/app_user.dart';
import 'package:stackprep/features/export/data/progress_pdf_generator.dart';
import 'package:stackprep/features/export/data/report_icons.dart';
import 'package:stackprep/features/export/domain/entities/progress_report.dart';
import 'package:stackprep/features/export/domain/usecases/build_progress_report.dart';
import 'package:stackprep/features/onboarding/domain/entities/stack_track.dart';
import 'package:stackprep/features/onboarding/domain/usecases/get_stack_tracks.dart';
import 'package:stackprep/features/progress/domain/entities/focus_area.dart';
import 'package:stackprep/features/progress/domain/entities/progress_overview.dart';
import 'package:stackprep/features/progress/domain/entities/readiness_summary.dart';
import 'package:stackprep/features/progress/domain/entities/track_competency.dart';
import 'package:stackprep/features/progress/domain/repositories/progress_repository.dart';
import 'package:stackprep/features/progress/domain/usecases/get_progress_overview.dart';
import 'package:stackprep/core/widgets/track_icon.dart';

ProgressReport _report({
  List<int> activity = const [],
  List<ReportCompetency> competencies = const [],
  List<ReportFocusArea> focus = const [],
  String? name = 'Ada Lovelace',
  String? email = 'ada@example.com',
}) {
  return ProgressReport(
    generatedAt: DateTime(2026, 9, 28, 14, 30),
    userName: name,
    userEmail: email,
    currentStreakDays: 12,
    totalSessions: 87,
    readinessScore: 0.87,
    globalReadinessScore: 0.64,
    targetScore: 0.9,
    activityLevels: activity,
    competencies: competencies,
    focusAreas: focus,
  );
}

class _StubProgressRepository implements ProgressRepository {
  _StubProgressRepository(this._overview);

  final ProgressOverview? _overview;
  Failure? failure;

  @override
  Future<Either<Failure, ProgressOverview>> getProgressOverview() async {
    final overview = _overview;
    if (overview == null) return Left(failure!);
    return Right(overview);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubGetStackTracks implements GetStackTracks {
  _StubGetStackTracks(this._tracks);

  final List<StackTrack> _tracks;

  @override
  Future<Either<Failure, List<StackTrack>>> call(NoParams params) async =>
      Right(_tracks);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ProgressReport', () {
    test('builds a dated, stable file name', () {
      expect(_report().fileName, 'stackprep-report-2026-09-28.pdf');
    });

    test('unknown module totals fall back to the completed count', () {
      const competency = ReportCompetency(
        trackId: 'kotlin',
        trackName: 'Kotlin',
        score: 80,
        level: 'Proficient',
        modulesCompleted: 5,
        modulesTotal: 0,
      );
      expect(competency.modulesLabel, '5');
    });

    test('known module totals render as a fraction', () {
      const competency = ReportCompetency(
        trackId: 'kotlin',
        trackName: 'Kotlin',
        score: 80,
        level: 'Proficient',
        modulesCompleted: 5,
        modulesTotal: 8,
      );
      expect(competency.modulesLabel, '5/8');
    });
  });

  group('BuildProgressReport', () {
    BuildProgressReport build({
      required ProgressOverview? overview,
      List<StackTrack> tracks = const [],
      Failure? failure,
    }) {
      return BuildProgressReport(
        getProgressOverview: GetProgressOverview(
          repository: _StubProgressRepository(overview)
            ..failure = failure ?? const CacheFailure('boom'),
        ),
        getStackTracks: _StubGetStackTracks(tracks),
      );
    }

    const overview = ProgressOverview(
      summary: ReadinessSummary(
        currentStreakDays: 5,
        totalSessions: 20,
        readinessScore: 0.5,
        globalReadinessScore: 0.4,
        targetScore: 0.8,
        activityLevels: [0, 1, 2, 3, 4],
      ),
      competencies: [
        TrackCompetency(
          trackId: 'kotlin',
          score: 72,
          level: 'Proficient',
          modulesCompleted: 4,
          modulesTotal: 9,
        ),
      ],
      focusAreas: [
        FocusArea(
          title: 'Coroutines',
          percent: 0.31,
          trend: TrendDirection.flat,
          trendLabel: 'steady',
          critical: true,
        ),
      ],
    );

    test('resolves track ids to human names', () async {
      final result = await build(
        overview: overview,
        tracks: [
          const StackTrack(
            id: 'kotlin',
            name: 'Kotlin Multiplatform',
            category: 'Android',
            shape: TrackShapeType.circle,
            color: Color(0xFF000000),
          ),
        ],
      )(BuildProgressReportParams(generatedAt: DateTime(2026, 9, 28)));

      final report = result.fold((_) => null, (value) => value)!;
      expect(report.competencies.single.trackName, 'Kotlin Multiplatform');
    });

    test('falls back to the raw id when the catalog is empty', () async {
      final result = await build(overview: overview)(
        BuildProgressReportParams(generatedAt: DateTime(2026, 9, 28)),
      );
      final report = result.fold((_) => null, (value) => value)!;
      expect(report.competencies.single.trackName, 'kotlin');
    });

    test('carries the signed-in identity through', () async {
      final result = await build(overview: overview)(
        BuildProgressReportParams(
          user: const AppUser(
            uid: 'u1',
            email: 'ada@example.com',
            displayName: 'Ada',
          ),
          generatedAt: DateTime(2026, 9, 28),
        ),
      );
      final report = result.fold((_) => null, (value) => value)!;
      expect(report.userName, 'Ada');
      expect(report.userEmail, 'ada@example.com');
    });

    test('normalizes blank identity fields to null', () async {
      final result = await build(overview: overview)(
        BuildProgressReportParams(
          user: const AppUser(uid: 'u1', displayName: '   ', email: ''),
          generatedAt: DateTime(2026, 9, 28),
        ),
      );
      final report = result.fold((_) => null, (value) => value)!;
      expect(report.userName, isNull);
      expect(report.userEmail, isNull);
    });

    test(
      'propagates a repository failure instead of an empty report',
      () async {
        final result = await build(overview: null)(
          BuildProgressReportParams(generatedAt: DateTime(2026, 9, 28)),
        );
        expect(result.isLeft(), isTrue);
        expect(result.fold((f) => f.message, (_) => ''), 'boom');
      },
    );

    test('copies summary stats and focus areas across', () async {
      final result = await build(overview: overview)(
        BuildProgressReportParams(generatedAt: DateTime(2026, 9, 28)),
      );
      final report = result.fold((_) => null, (value) => value)!;
      expect(report.currentStreakDays, 5);
      expect(report.totalSessions, 20);
      expect(report.readinessScore, 0.5);
      expect(report.activityLevels, [0, 1, 2, 3, 4]);
      expect(report.focusAreas.single.title, 'Coroutines');
      expect(report.focusAreas.single.critical, isTrue);
    });
  });

  group('ProgressPdfGenerator', () {
    const generator = ProgressPdfGenerator();

    test('produces a valid PDF document', () async {
      final bytes = await generator.generate(
        _report(
          activity: List.generate(35, (i) => i % 5),
          competencies: const [
            ReportCompetency(
              trackId: 'kotlin',
              trackName: 'Kotlin Multiplatform',
              score: 72,
              level: 'Proficient',
              modulesCompleted: 4,
              modulesTotal: 9,
            ),
            ReportCompetency(
              trackId: 'swift',
              trackName: 'SwiftUI',
              score: 91,
              level: 'Advanced',
              modulesCompleted: 10,
              modulesTotal: 11,
            ),
          ],
          focus: const [
            ReportFocusArea(
              title: 'Coroutines',
              percent: 0.31,
              trendLabel: 'steady',
              critical: true,
            ),
          ],
        ),
      );

      expect(bytes, isNotEmpty);
      // PDF magic number.
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    });

    test('renders with an empty dataset instead of throwing', () async {
      final bytes = await generator.generate(_report(name: null, email: null));
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test(
      'handles an activity log that is not a whole number of weeks',
      () async {
        final bytes = await generator.generate(
          _report(activity: List.generate(13, (i) => i % 5)),
        );
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      },
    );

    test('handles out-of-range activity levels without crashing', () async {
      final bytes = await generator.generate(
        _report(activity: [0, 9, -1, 3, 4, 2]),
      );
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('paginates a very long competency table', () async {
      final bytes = await generator.generate(
        _report(
          competencies: [
            for (var i = 0; i < 60; i++)
              ReportCompetency(
                trackId: 'track$i',
                trackName: 'Track $i',
                score: i,
                level: 'Level $i',
                modulesCompleted: i,
                modulesTotal: 60,
              ),
          ],
        ),
      );
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('returns bytes the exporter can write out', () async {
      final Uint8List bytes = await generator.generate(_report());
      expect(bytes, isA<Uint8List>());
      expect(bytes.length, greaterThan(0));
    });

    test('draws vector graphics for the icons', () async {
      // A full report embeds the icon set as real paths. A broken template
      // would render as a blank tile, which no byte-level assertion can see.
      final empty = await generator.generate(_report(name: null, email: null));
      final rich = await generator.generate(
        _report(
          activity: List.generate(35, (i) => i % 5),
          competencies: const [
            ReportCompetency(
              trackId: 'kotlin',
              trackName: 'Kotlin',
              score: 72,
              level: 'Proficient',
              modulesCompleted: 4,
              modulesTotal: 9,
            ),
          ],
          focus: const [
            ReportFocusArea(
              title: 'Coroutines',
              percent: 0.31,
              trendLabel: 'steady',
              critical: true,
            ),
          ],
        ),
      );
      expect(rich.length, greaterThan(empty.length));
    });

    test('survives scores at both extremes', () async {
      // The bars clamp their fill so a 0% or 100% score cannot collapse the
      // row to nothing.
      final bytes = await generator.generate(
        _report(
          competencies: const [
            ReportCompetency(
              trackId: 'a',
              trackName: 'Perfect',
              score: 100,
              level: 'Mastered',
              modulesCompleted: 9,
              modulesTotal: 9,
            ),
            ReportCompetency(
              trackId: 'b',
              trackName: 'Unstarted',
              score: 0,
              level: 'None',
              modulesCompleted: 0,
              modulesTotal: 0,
            ),
          ],
          focus: const [
            ReportFocusArea(
              title: 'Nothing logged',
              percent: 0,
              // Wording the icon mapping does not know: it must fall back to
              // the flat arrow rather than throw or pick a wrong one.
              trendLabel: 'unclassified',
              critical: false,
            ),
          ],
        ),
      );
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });

  group('ReportIcons', () {
    const amber = PdfColor.fromInt(0xFF8A5A00);

    test('every template resolves its color placeholders', () {
      for (final template in ReportIcons.all) {
        final svg = ReportIcons.resolve(template, color: amber);
        expect(svg, isNot(contains('{c}')), reason: template);
        expect(svg, isNot(contains('{s}')), reason: template);
        expect(svg, contains('#8a5a00'), reason: template);
      }
    });

    test('every icon renders without a parse error', () async {
      // Parsing is where a malformed path would surface, and it only happens
      // at paint time, so the icon has to actually be drawn.
      for (final template in ReportIcons.all) {
        final doc = pw.Document();
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (_) => ReportIcons.tile(template, color: amber),
          ),
        );
        final bytes = await doc.save();
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-', reason: template);
      }
    });

    test('the tint is lighter than the color it comes from', () {
      final tint = ReportIcons.tint(amber);
      expect(tint.red, greaterThan(amber.red));
      expect(tint.green, greaterThan(amber.green));
      expect(tint.blue, greaterThan(amber.blue));
    });
  });
}
