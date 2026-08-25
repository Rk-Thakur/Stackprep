import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/focus_area.dart';
import '../../domain/entities/progress_overview.dart';
import '../../domain/entities/readiness_summary.dart';
import '../../domain/entities/track_competency.dart';

/// Fetches the user's progress overview from Firestore at
/// `users/{uid}/progress/overview`.
class ProgressFirestoreDataSource {
  ProgressFirestoreDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
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
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .doc('overview')
          .get();
      if (!doc.exists || doc.data() == null) {
        return _defaultOverview();
      }
      return _fromFirestore(doc.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch progress.');
    }
  }

  ProgressOverview _fromFirestore(Map<String, dynamic> data) {
    final summaryRaw = data['summary'] as Map<String, dynamic>? ?? {};
    final competenciesRaw = data['competencies'] as List<dynamic>? ?? [];
    final focusAreasRaw = data['focusAreas'] as List<dynamic>? ?? [];

    return ProgressOverview(
      summary: ReadinessSummary(
        currentStreakDays: summaryRaw['currentStreakDays'] as int? ?? 0,
        totalSessions: summaryRaw['totalSessions'] as int? ?? 0,
        readinessScore:
            (summaryRaw['readinessScore'] as num?)?.toDouble() ?? 0,
        globalReadinessScore:
            (summaryRaw['globalReadinessScore'] as num?)?.toDouble() ?? 0,
        targetScore: (summaryRaw['targetScore'] as num?)?.toDouble() ?? 0,
      ),
      competencies: competenciesRaw
          .map((c) => TrackCompetency(
                trackId: c['trackId'] as String? ?? '',
                score: c['score'] as int? ?? 0,
                level: c['level'] as String? ?? '',
              ))
          .toList(),
      focusAreas: focusAreasRaw
          .map((f) => FocusArea(
                title: f['title'] as String? ?? '',
                percent: (f['percent'] as num?)?.toDouble() ?? 0,
                critical: f['critical'] as bool? ?? false,
                trend: _trendFromString(f['trend'] as String? ?? 'flat'),
                trendLabel: f['trendLabel'] as String? ?? '',
              ))
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

  ProgressOverview _defaultOverview() => const ProgressOverview(
        summary: ReadinessSummary(
          currentStreakDays: 0,
          totalSessions: 0,
          readinessScore: 0,
          globalReadinessScore: 0,
          targetScore: 0.90,
        ),
        competencies: [],
        focusAreas: [],
      );
}
