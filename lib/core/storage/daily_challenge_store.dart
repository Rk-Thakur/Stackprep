import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether today's rotating daily challenge has been completed.
/// A per-day SharedPreferences key makes the state reset naturally on the
/// next calendar day without any cleanup job.
class DailyChallengeStore {
  DailyChallengeStore({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  static String _keyFor(DateTime day) =>
      'daily_challenge_done_${_dateKey(day)}';

  bool isDoneToday([DateTime? now]) {
    final day = now ?? DateTime.now();
    return _prefs.getBool(_keyFor(day)) ?? false;
  }

  Future<void> markDoneToday([DateTime? now]) async {
    final day = now ?? DateTime.now();
    await _prefs.setBool(_keyFor(day), true);
  }

  static String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}