import 'package:equatable/equatable.dart';
import '../../data/models/clip_model.dart';

enum ClipsStatus { initial, loading, loaded, error }

class ClipsState extends Equatable {
  final ClipsStatus status;
  final List<ClipModel> clips;
  final String? errorMessage;

  const ClipsState._({
    required this.status,
    this.clips = const [],
    this.errorMessage,
  });

  const ClipsState.initial() : this._(status: ClipsStatus.initial);

  ClipsState copyWith({
    ClipsStatus? status,
    List<ClipModel>? clips,
    String? errorMessage,
  }) {
    return ClipsState._(
      status: status ?? this.status,
      clips: clips ?? this.clips,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, clips, errorMessage];
}
