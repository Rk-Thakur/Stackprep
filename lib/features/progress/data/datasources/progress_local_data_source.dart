import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/widgets/track_icon.dart';
import '../../../onboarding/domain/entities/stack_track.dart';
import '../../domain/entities/focus_area.dart';
import '../../domain/entities/progress_overview.dart';
import '../../domain/entities/readiness_summary.dart';
import '../../domain/entities/track_competency.dart';

const int _kActivityWindowDays = 91;

/// Per-track competency is a weighted blend of performance across every
/// activity channel the app offers (MCQ practice, module quizzes,
/// flashcards, and the daily challenge) plus how much of the track's study
/// content has been completed. Weight by channel rather than by "did the
/// user attempt anything", so a single 100% session — or merely browsing
/// track modules — can no longer inflate a track straight to 100.
const Map<String, double> _kActivityWeights = {
  'mcq': 0.30,
  'quiz': 0.30,
  'flashcard': 0.20,
  'challenge': 0.10,
};

/// Weight of the module-completion ratio in the blended competency score.
const double _kModuleCompletionWeight = 0.10;

/// Fetches the user's progress overview from Firestore at
/// `users/{uid}/progress/overview`, and records completed
/// practice/MCQ/flashcard attempts that roll into it.
class ProgressFirestoreDataSource {
  ProgressFirestoreDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  /// Returns the user's progress overview, or throws [ServerException].
  Future<ProgressOverview> getProgressOverview() async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const ServerException('No signed-in user.');
    }
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final results = await Future.wait([
        userRef.collection('progress').doc('overview').get(),
        _getActivityLevels(userRef, days: _kActivityWindowDays),
      ]);
      final doc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final activityLevels = results[1] as List<int>;

      if (!doc.exists || doc.data() == null) {
        return _defaultOverview(activityLevels);
      }
      final data = doc.data()!;
      final competenciesRaw = data['competencies'] as List<dynamic>? ?? [];
      final trackIds = <String>{
        for (final c in competenciesRaw)
          if (((c as Map)['trackId'] as String? ?? '').isNotEmpty)
            c['trackId'] as String,
      };
      final moduleTotals = await _getModuleTotals(trackIds);
      return _fromFirestore(data, activityLevels, moduleTotals);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch progress.');
    } on PlatformException {
      throw const ServerException(
        'Network error. Check your internet connection.',
      );
    }
  }

  /// Loads the live track catalog from the Firestore `tracks` collection, so
  /// the Core Competencies filter only offers tracks that currently exist.
  /// Throws [ServerException] if the read fails.
  Future<List<StackTrack>> getTracks() async {
    try {
      final snap = await _firestore.collection('tracks').orderBy('order').get();
      return snap.docs
          .map(
            (d) => StackTrack(
              id: d.id,
              name: d.data()['name'] as String? ?? d.id,
              category: d.data()['category'] as String? ?? 'TRACK',
              shape: TrackShapeType.roundedSquare,
              color: Color(d.data()['color'] as int? ?? 0xFF888888),
            ),
          )
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch track catalog.');
    }
  }

  /// Marks a module as viewed the first time; a no-op on repeat views. Bumps
  /// that track's `modulesCompleted` counter in the same transaction.
  Future<void> markModuleViewed({
    required String trackId,
    required String moduleId,
  }) async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final moduleRef = userRef
        .collection('moduleProgress')
        .doc('${trackId}_$moduleId');
    final overviewRef = userRef.collection('progress').doc('overview');
    final todayKey = _dateKey(DateTime.now());
    final activityRef = userRef.collection('activityDaily').doc(todayKey);

    try {
      await _firestore.runTransaction((txn) async {
        final moduleSnap = await txn.get(moduleRef);
        if (moduleSnap.exists) return; // Already counted.

        final overviewSnap = await txn.get(overviewRef);
        final data = overviewSnap.data() ?? <String, dynamic>{};
        final competencies = <Map<String, dynamic>>[
          for (final c in (data['competencies'] as List? ?? []))
            Map<String, dynamic>.from(c as Map),
        ];

        final index = competencies.indexWhere((c) => c['trackId'] == trackId);
        final existing = index >= 0 ? competencies[index] : null;
        // Reading module content counts toward the track's completion ratio
        // (a capped slice of the blended score) instead of bumping the raw
        // score, so merely browsing a track can't climb to 100.
        final channels = <String, Map<String, dynamic>>{
          for (final e in (existing?['channels'] as Map? ?? {}).entries)
            e.key as String: Map<String, dynamic>.from(e.value as Map),
        };
        if (index >= 0) {
          final current =
              (competencies[index]['modulesCompleted'] as num?)?.toInt() ?? 0;
          final modulesCompleted = current + 1;
          final score = _blendedScore(
            channels: channels,
            modulesCompleted: modulesCompleted,
          );
          competencies[index] = {
            ...competencies[index],
            'modulesCompleted': modulesCompleted,
            'channels': channels,
            'score': score,
            'level': _levelForScore(score),
          };
        } else {
          final score = _blendedScore(
            channels: channels,
            modulesCompleted: 1,
          );
          competencies.add({
            'trackId': trackId,
            'score': score,
            'level': _levelForScore(score),
            'modulesCompleted': 1,
            'channels': channels,
          });
        }

        final globalReadiness = competencies.isEmpty
            ? 0.0
            : competencies
                      .map((c) => (c['score'] as num).toDouble())
                      .reduce((a, b) => a + b) /
                  competencies.length /
                  100;

        txn.set(overviewRef, {
          'competencies': competencies,
          'summary': {
            'globalReadinessScore': globalReadiness,
          },
        }, SetOptions(merge: true));

        txn.set(moduleRef, {
          'trackId': trackId,
          'moduleId': moduleId,
          'viewedAt': FieldValue.serverTimestamp(),
        });

        txn.set(activityRef, {
          'count': FieldValue.increment(1),
        }, SetOptions(merge: true));
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to record module view.');
    }
  }

  /// Records one completed attempt and rolls it into `progress/overview`:
  /// bumps the day's activity count, appends an `attempts` record, and
  /// updates the streak / per-track competency / global readiness score in
  /// a single transaction.
  Future<void> recordAttempt({
    required String trackId,
    String? moduleId,
    String? moduleTitle,
    required String type,
    required int correct,
    required int total,
  }) async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final yesterdayKey = _dateKey(now.subtract(const Duration(days: 1)));
    final accuracy = total > 0 ? correct / total : 0.0;

    final userRef = _firestore.collection('users').doc(user.uid);
    final overviewRef = userRef.collection('progress').doc('overview');
    final activityRef = userRef.collection('activityDaily').doc(todayKey);
    final attemptRef = userRef.collection('attempts').doc();

    try {
      await _firestore.runTransaction((txn) async {
        final overviewSnap = await txn.get(overviewRef);
        final data = overviewSnap.data() ?? <String, dynamic>{};
        final summary = Map<String, dynamic>.from(
          data['summary'] as Map? ?? {},
        );
        final competencies = <Map<String, dynamic>>[
          for (final c in (data['competencies'] as List? ?? []))
            Map<String, dynamic>.from(c as Map),
        ];

        final index = competencies.indexWhere((c) => c['trackId'] == trackId);
        final existing = index >= 0 ? competencies[index] : null;
        final channels = <String, Map<String, dynamic>>{
          for (final e in (existing?['channels'] as Map? ?? {}).entries)
            e.key as String: Map<String, dynamic>.from(e.value as Map),
        };
        // Roll this attempt into its activity channel with an exponential
        // moving average, then re-blend the track score. Because each channel
        // only carries a slice of the weight, no single session moves a track
        // to 100.
        final channelKey = _channelForType(type);
        if (channelKey != null) {
          final prev = channels[channelKey];
          final prevScore = (prev?['score'] as num?)?.toDouble() ?? 0.0;
          final prevAttempts = (prev?['attempts'] as num?)?.toInt() ?? 0;
          final newChannelScore = prev == null
              ? accuracy * 100
              : (prevScore * 0.8 + accuracy * 100 * 0.2);
          channels[channelKey] = {
            'score': newChannelScore.round().clamp(0, 100),
            'attempts': prevAttempts + 1,
          };
        }
        final modulesCompleted =
            (existing?['modulesCompleted'] as num?)?.toInt() ?? 0;
        final roundedScore = _blendedScore(
          channels: channels,
          modulesCompleted: modulesCompleted,
        );
        final competencyEntry = {
          'trackId': trackId,
          'score': roundedScore,
          'level': _levelForScore(roundedScore),
          'modulesCompleted': modulesCompleted,
          'channels': channels,
        };
        if (index >= 0) {
          competencies[index] = competencyEntry;
        } else {
          competencies.add(competencyEntry);
        }

        // Per-module accuracy, used only to derive Focus Areas — the track
        // competency above already covers the track-wide score.
        final moduleStats = <String, Map<String, dynamic>>{
          for (final entry in (data['moduleStats'] as Map? ?? {}).entries)
            entry.key as String: Map<String, dynamic>.from(entry.value as Map),
        };
        if (moduleId != null) {
          final statKey = '${trackId}_$moduleId';
          final existing = moduleStats[statKey];
          final oldModuleScore =
              (existing?['score'] as num?)?.toDouble() ?? 0.0;
          final newModuleScore = existing != null
              ? (oldModuleScore * 0.7 + accuracy * 100 * 0.3)
              : accuracy * 100;
          final roundedModuleScore = newModuleScore.round().clamp(0, 100);
          final oldLevel = _levelForScore(oldModuleScore.round());
          final newLevel = _levelForScore(roundedModuleScore);
          final String trend;
          final String trendLabel;
          if (existing != null && _levelRank(newLevel) > _levelRank(oldLevel)) {
            trend = 'levelUp';
            trendLabel = 'Leveled up to $newLevel';
          } else if (existing != null &&
              roundedModuleScore - oldModuleScore.round() >= 5) {
            trend = 'up';
            trendLabel = 'Improving';
          } else {
            trend = 'flat';
            trendLabel = 'Holding steady';
          }
          moduleStats[statKey] = {
            'trackId': trackId,
            'moduleId': moduleId,
            'title': moduleTitle ?? (existing?['title'] as String? ?? moduleId),
            'score': roundedModuleScore,
            'trend': trend,
            'trendLabel': trendLabel,
          };
        }

        // Focus Areas: the weakest modules (score < 60), worst first.
        final focusAreas =
            moduleStats.values.where((m) => (m['score'] as num) < 60).toList()
              ..sort(
                (a, b) => (a['score'] as num).compareTo(b['score'] as num),
              );
        final focusAreasOut = focusAreas.take(3).map((m) {
          final score = (m['score'] as num).toInt();
          return {
            'title': m['title'],
            'percent': score / 100,
            'critical': score < 40,
            'trend': m['trend'],
            'trendLabel': m['trendLabel'],
            'trackId': m['trackId'],
            'moduleId': m['moduleId'],
          };
        }).toList();

        final lastActiveDate = summary['lastActiveDate'] as String?;
        var streak = (summary['currentStreakDays'] as int?) ?? 0;
        if (lastActiveDate == todayKey) {
          // Already active today — streak unchanged.
        } else if (lastActiveDate == yesterdayKey) {
          streak += 1;
        } else {
          streak = 1;
        }

        final oldReadiness =
            (summary['readinessScore'] as num?)?.toDouble() ?? 0.0;
        final newReadiness = overviewSnap.exists
            ? (oldReadiness * 0.8 + accuracy * 0.2)
            : accuracy;
        final globalReadiness = competencies.isEmpty
            ? 0.0
            : competencies
                      .map((c) => (c['score'] as num).toDouble())
                      .reduce((a, b) => a + b) /
                  competencies.length /
                  100;

        txn.set(overviewRef, {
          'summary': {
            'currentStreakDays': streak,
            'totalSessions': ((summary['totalSessions'] as int?) ?? 0) + 1,
            'readinessScore': newReadiness,
            'globalReadinessScore': globalReadiness,
            'targetScore': (summary['targetScore'] as num?)?.toDouble() ?? 0.90,
            'lastActiveDate': todayKey,
          },
          'competencies': competencies,
          'moduleStats': moduleStats,
          'focusAreas': moduleId != null
              ? focusAreasOut
              : (data['focusAreas'] ?? []),
        }, SetOptions(merge: true));

        txn.set(activityRef, {
          'count': FieldValue.increment(1),
        }, SetOptions(merge: true));

        txn.set(attemptRef, {
          'trackId': trackId,
          'moduleId': moduleId,
          'moduleTitle': moduleTitle,
          'type': type,
          'correct': correct,
          'total': total,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to record attempt.');
    }
  }

  /// One bucket (0-4) per day, oldest first, over the last [days] days.
  Future<List<int>> _getActivityLevels(
    DocumentReference<Map<String, dynamic>> userRef, {
    required int days,
  }) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days - 1));
    final snap = await userRef
        .collection('activityDaily')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: _dateKey(start))
        .get();
    final counts = <String, int>{
      for (final d in snap.docs)
        d.id: (d.data()['count'] as num?)?.toInt() ?? 0,
    };
    return List.generate(days, (i) {
      final date = start.add(Duration(days: i));
      return _bucketForCount(counts[_dateKey(date)] ?? 0);
    });
  }

  /// Total module count per track id, read from the (public) track catalog
  /// via a cheap aggregate count query — no document downloads. Best-effort:
  /// a network failure here degrades to zero totals rather than failing the
  /// whole overview load.
  Future<Map<String, int>> _getModuleTotals(Set<String> trackIds) async {
    if (trackIds.isEmpty) return const {};
    try {
      final entries = await Future.wait(
        trackIds.map((id) async {
          final agg = await _firestore
              .collection('tracks')
              .doc(id)
              .collection('modules')
              .count()
              .get();
          return MapEntry(id, agg.count ?? 0);
        }),
      );
      return Map.fromEntries(entries);
    } on FirebaseException {
      return const {};
    } on PlatformException {
      return const {};
    }
  }

  /// A channel's running accuracy (0-100), or 0 if the learner has never
  /// completed an activity of that type on this track — an unstarted
  /// channel contributes nothing to the blended score.
  double _channelScore(Map<String, dynamic>? channels, String key) {
    final entry = channels?[key];
    if (entry is! Map) return 0.0;
    final attempts = (entry['attempts'] as num?)?.toInt() ?? 0;
    if (attempts <= 0) return 0.0;
    return (entry['score'] as num?)?.toDouble() ?? 0.0;
  }

  /// Maps a recorded attempt's [type] onto a competency channel. Legacy
  /// 'practice' sessions (pre-split) count toward the MCQ channel.
  String? _channelForType(String type) {
    if (_kActivityWeights.containsKey(type)) return type;
    if (type == 'practice') return 'mcq';
    return null;
  }

  /// The blended competency score (0-100): weighted average of each engaged
  /// activity channel plus the track's module-completion ratio. Passing
  /// [modulesTotal] of 0 (unknown at write time) simply skips the completion
  /// component — reads recompute it against the live module catalog.
  int _blendedScore({
    required Map<String, dynamic> channels,
    required int modulesCompleted,
    int modulesTotal = 0,
  }) {
    var total = 0.0;
    for (final entry in _kActivityWeights.entries) {
      total += _channelScore(channels, entry.key) * entry.value;
    }
    if (modulesTotal > 0) {
      total +=
          (modulesCompleted / modulesTotal) * 100 * _kModuleCompletionWeight;
    }
    return total.round().clamp(0, 100);
  }

  int _bucketForCount(int count) {
    if (count <= 0) return 0;
    if (count == 1) return 1;
    if (count <= 3) return 2;
    if (count <= 5) return 3;
    return 4;
  }

  String _levelForScore(int score) {
    if (score < 40) return 'Beginner';
    if (score < 70) return 'Intermediate';
    if (score < 90) return 'Advanced';
    return 'Expert';
  }

  /// Ordinal rank of a level band, for detecting a level-up between two
  /// scores. Unknown labels rank lowest.
  int _levelRank(String level) {
    const order = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];
    final index = order.indexOf(level);
    return index < 0 ? 0 : index;
  }

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  ProgressOverview _fromFirestore(
    Map<String, dynamic> data,
    List<int> activityLevels,
    Map<String, int> moduleTotals,
  ) {
    final summaryRaw = data['summary'] as Map<String, dynamic>? ?? {};
    final competenciesRaw = data['competencies'] as List<dynamic>? ?? [];
    final focusAreasRaw = data['focusAreas'] as List<dynamic>? ?? [];

    // Re-compute the streak from the live activityLevels data instead of
    // trusting the stored value, so it stays in sync with the heatmap.
    // Find the most recent non-zero entry (skip trailing zeros), then count
    // the consecutive active block backwards from there.
    var i = activityLevels.length - 1;
    while (i >= 0 && activityLevels[i] == 0) {
      i--;
    }
    var streak = 0;
    while (i >= 0 && activityLevels[i] > 0) {
      streak++;
      i--;
    }

    // Authoritative competency scores are recomputed here — at the point
    // where the live module catalog totals are known — so the blended
    // channel performance plus completion ratio is what the UI shows, and
    // what drives the global readiness aggregate.
    final competencies = competenciesRaw.map((c) {
      final trackId = c['trackId'] as String? ?? '';
      final modulesTotal = moduleTotals[trackId] ?? 0;
      final modulesCompleted = c['modulesCompleted'] as int? ?? 0;
      final channels = <String, Map<String, dynamic>>{
        for (final e in (c['channels'] as Map? ?? {}).entries)
          e.key as String: Map<String, dynamic>.from(e.value as Map),
      };
      final hasChannels = c['channels'] is Map;
      // Records written before the channel blend (raw accuracy EMA + module
      // bumps) have no per-activity breakdown, so their stored score is not
      // trustworthy enough to display — it was routinely 100 after a single
      // perfect session or after merely browsing the track. Derive the score
      // from what we do know (module completion) instead; performing any new
      // activity records channel data and the full blend takes over.
      final score = hasChannels
          ? _blendedScore(
              channels: channels,
              modulesCompleted: modulesCompleted,
              modulesTotal: modulesTotal,
            )
          : _blendedScore(
              channels: const {},
              modulesCompleted: modulesCompleted,
              modulesTotal: modulesTotal,
            );
      return TrackCompetency(
        trackId: trackId,
        score: score,
        level: _levelForScore(score),
        modulesCompleted: modulesCompleted,
        modulesTotal: modulesTotal,
      );
    }).toList();

    final globalReadiness = competencies.isEmpty
        ? 0.0
        : competencies
                  .map((c) => c.score)
                  .reduce((a, b) => a + b) /
              competencies.length /
              100;

    return ProgressOverview(
      summary: ReadinessSummary(
        currentStreakDays: streak,
        totalSessions: summaryRaw['totalSessions'] as int? ?? 0,
        readinessScore: (summaryRaw['readinessScore'] as num?)?.toDouble() ?? 0,
        globalReadinessScore: globalReadiness,
        targetScore: (summaryRaw['targetScore'] as num?)?.toDouble() ?? 0,
        activityLevels: activityLevels,
      ),
      competencies: competencies,
      focusAreas: focusAreasRaw
          .map(
            (f) => FocusArea(
              title: f['title'] as String? ?? '',
              percent: (f['percent'] as num?)?.toDouble() ?? 0,
              critical: f['critical'] as bool? ?? false,
              trend: _trendFromString(f['trend'] as String? ?? 'flat'),
              trendLabel: f['trendLabel'] as String? ?? '',
              trackId: f['trackId'] as String?,
              moduleId: f['moduleId'] as String?,
            ),
          )
          .toList(),
    );
  }

  TrendDirection _trendFromString(String value) {
    switch (value) {
      case 'up':
        return TrendDirection.up;
      case 'levelUp':
        return TrendDirection.levelUp;
      default:
        return TrendDirection.flat;
    }
  }

  ProgressOverview _defaultOverview(List<int> activityLevels) =>
      ProgressOverview(
        summary: ReadinessSummary(
          currentStreakDays: 0,
          totalSessions: 0,
          readinessScore: 0,
          globalReadinessScore: 0,
          targetScore: 0.90,
          activityLevels: activityLevels,
        ),
        competencies: const [],
        focusAreas: const [],
      );
}
