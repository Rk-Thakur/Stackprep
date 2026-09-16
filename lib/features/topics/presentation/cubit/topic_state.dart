import 'package:equatable/equatable.dart';

import '../../domain/entities/topic.dart';

enum TopicStatus { initial, loading, ready, failure }

class TopicState extends Equatable {
  const TopicState({
    this.status = TopicStatus.initial,
    this.topic,
    this.topics = const [],
    this.errorMessage,
  });

  final TopicStatus status;
  final Topic? topic;
  final List<Topic> topics;
  final String? errorMessage;

  TopicState copyWith({
    TopicStatus? status,
    Topic? topic,
    List<Topic>? topics,
    String? errorMessage,
  }) {
    return TopicState(
      status: status ?? this.status,
      topic: topic ?? this.topic,
      topics: topics ?? this.topics,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, topic, topics, errorMessage];
}
