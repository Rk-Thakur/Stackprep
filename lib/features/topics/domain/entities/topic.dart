import 'package:equatable/equatable.dart';

import 'topic_module.dart';

/// A topic in the library, e.g. "Kotlin Coroutines" with its sub-topic
/// modules. [trackColor] is stored as an ARGB int to keep Flutter painting
/// types out of the domain layer.
class Topic extends Equatable {
  const Topic({
    required this.id,
    required this.level,
    required this.trackName,
    required this.trackColor,
    required this.title,
    required this.description,
    required this.modules,
  });

  final String id;
  final String level;
  final String trackName;
  final int trackColor;
  final String title;
  final String description;
  final List<TopicModule> modules;

  @override
  List<Object?> get props => [
    id,
    level,
    trackName,
    trackColor,
    title,
    description,
    modules,
  ];
}
