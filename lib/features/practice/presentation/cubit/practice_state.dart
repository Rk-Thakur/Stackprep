import 'package:equatable/equatable.dart';

import '../../../onboarding/domain/entities/stack_track.dart';

enum PracticeStatus { initial, loading, ready, failure }

class PracticeState extends Equatable {
  const PracticeState({
    this.status = PracticeStatus.initial,
    this.tracks = const [],
    this.errorMessage,
  });

  final PracticeStatus status;
  final List<StackTrack> tracks;
  final String? errorMessage;

  PracticeState copyWith({
    PracticeStatus? status,
    List<StackTrack>? tracks,
    String? errorMessage,
  }) {
    return PracticeState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tracks, errorMessage];
}
