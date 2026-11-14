/// Mirrors the `latest_render` object in `GET
/// /api/v1/videos/{video_id}/clips/{clip_id}/pipeline-status`.
class RenderJobModel {
  final String id;
  final String status;
  final int progress;
  final String? errorMessage;
  final String? outputUrl;
  final String? thumbnailUrl;

  const RenderJobModel({
    required this.id,
    required this.status,
    required this.progress,
    this.errorMessage,
    this.outputUrl,
    this.thumbnailUrl,
  });

  bool get hasOutput => outputUrl?.trim().isNotEmpty ?? false;

  factory RenderJobModel.fromJson(Map<String, dynamic> json) {
    return RenderJobModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'queued',
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      errorMessage: json['error_message'] as String?,
      outputUrl: json['output_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }
}

/// Mirrors `GET /api/v1/videos/{video_id}/clips/{clip_id}/pipeline-status`.
class PipelineStatusModel {
  final String clipId;
  final String editingPlanStatus;
  final String cameraAnalysisStatus;
  final String timelineDirectionStatus;
  final RenderJobModel? latestRender;
  final String? errorMessage;
  final String publishStatus;
  final String? publishedUrl;

  const PipelineStatusModel({
    required this.clipId,
    required this.editingPlanStatus,
    required this.cameraAnalysisStatus,
    required this.timelineDirectionStatus,
    this.latestRender,
    this.errorMessage,
    required this.publishStatus,
    this.publishedUrl,
  });

  factory PipelineStatusModel.fromJson(Map<String, dynamic> json) {
    final renderJson = json['latest_render'] as Map<String, dynamic>?;
    return PipelineStatusModel(
      clipId: json['clip_id'] as String? ?? '',
      editingPlanStatus: json['editing_plan_status'] as String? ?? 'pending',
      cameraAnalysisStatus:
          json['camera_analysis_status'] as String? ?? 'pending',
      timelineDirectionStatus:
          json['timeline_direction_status'] as String? ?? 'pending',
      latestRender: renderJson != null
          ? RenderJobModel.fromJson(renderJson)
          : null,
      errorMessage: json['error_message'] as String?,
      publishStatus: json['publish_status'] as String? ?? 'draft',
      publishedUrl: json['published_url'] as String?,
    );
  }
}
