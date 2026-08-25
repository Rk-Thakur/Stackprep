import 'package:equatable/equatable.dart';

/// Direction of a focus area's recent movement. Pages map this to an icon;
/// keeping IconData out of the domain layer.
enum TrendDirection { up, flat, levelUp }

/// A weak-area telemetry row on the progress tab.
class FocusArea extends Equatable {
  const FocusArea({
    required this.title,
    required this.percent,
    required this.trend,
    required this.trendLabel,
    this.critical = false,
  });

  final String title;

  /// Completion/mastery fraction between 0 and 1.
  final double percent;
  final bool critical;
  final TrendDirection trend;
  final String trendLabel;

  @override
  List<Object?> get props => [
    title,
    percent,
    critical,
    trend,
    trendLabel,
  ];
}
