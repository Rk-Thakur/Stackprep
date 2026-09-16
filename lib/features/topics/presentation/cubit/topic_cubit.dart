import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/topic_repository.dart';
import 'topic_state.dart';

class TopicCubit extends Cubit<TopicState> {
  TopicCubit({required TopicRepository repository})
      : _repository = repository,
        super(const TopicState());

  final TopicRepository _repository;

  Future<void> loadTopics() async {
    emit(state.copyWith(status: TopicStatus.loading));
    final result = await _repository.getTopics();
    result.fold(
      (Failure failure) => emit(
        state.copyWith(
          status: TopicStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (topics) => emit(
        state.copyWith(status: TopicStatus.ready, topics: topics),
      ),
    );
  }

  Future<void> loadTopic(String topicId) async {
    emit(state.copyWith(status: TopicStatus.loading));
    final result = await _repository.getTopic(topicId);
    result.fold(
      (Failure failure) => emit(
        state.copyWith(
          status: TopicStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (topic) => emit(state.copyWith(status: TopicStatus.ready, topic: topic)),
    );
  }
}
