import 'package:equatable/equatable.dart';

import '../../domain/entities/topic.dart';

enum TopicStatus { initial, loading, ready, failure }

class TopicState extends Equatable {
  const TopicState({
    this.status = TopicStatus.initial,
    this.topic,
    this.errorMessage,
  });

  final TopicStatus status;
  final Topic? topic;
  final String? errorMessage;

  TopicState copyWith({
    TopicStatus? status,
    Topic? topic,
    String? errorMessage,
  }) {
    return TopicState(
      status: status ?? this.status,
      topic: topic ?? this.topic,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, topic, errorMessage];
}
