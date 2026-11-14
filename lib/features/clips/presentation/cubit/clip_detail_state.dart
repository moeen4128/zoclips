import 'package:equatable/equatable.dart';
import '../../data/models/clip_metadata_model.dart';
import '../../data/models/pipeline_status_model.dart';

enum ClipDetailStatus { initial, loading, loaded, error }

class ClipDetailState extends Equatable {
  final ClipDetailStatus status;
  final PipelineStatusModel? pipelineStatus;
  final ClipMetadataModel? metadata;
  final String? errorMessage;

  /// True while a regenerate job is running (POST kicked off, polling
  /// GET .../metadata for a non-"pending" status) — drives the
  /// Regenerate button's spinner and the "Writing your copy…" placeholder.
  final bool isRegenerating;

  const ClipDetailState._({
    required this.status,
    this.pipelineStatus,
    this.metadata,
    this.errorMessage,
    this.isRegenerating = false,
  });

  const ClipDetailState.initial() : this._(status: ClipDetailStatus.initial);

  ClipDetailState copyWith({
    ClipDetailStatus? status,
    PipelineStatusModel? pipelineStatus,
    ClipMetadataModel? metadata,
    String? errorMessage,
    bool? isRegenerating,
  }) {
    return ClipDetailState._(
      status: status ?? this.status,
      pipelineStatus: pipelineStatus ?? this.pipelineStatus,
      metadata: metadata ?? this.metadata,
      errorMessage: errorMessage,
      isRegenerating: isRegenerating ?? this.isRegenerating,
    );
  }

  @override
  List<Object?> get props => [
    status,
    pipelineStatus,
    metadata,
    errorMessage,
    isRegenerating,
  ];
}
