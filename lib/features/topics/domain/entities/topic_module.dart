import 'package:equatable/equatable.dart';

/// A sub-topic module inside a [Topic], e.g. "Dispatchers & Context".
class TopicModule extends Equatable {
  const TopicModule({
    required this.title,
    required this.description,
    required this.taskCount,
    required this.duration,
  });

  final String title;
  final String description;
  final int taskCount;
  final String duration;

  @override
  List<Object?> get props => [title, description, taskCount, duration];
}
