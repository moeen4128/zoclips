/// Mirrors `GET /api/v1/videos/{video_id}/clips/{clip_id}/metadata` — the
/// AI-generated title/description/hashtags for a clip's publishing details.
class ClipMetadataModel {
  final String status;
  final String? title;
  final String? description;
  final List<String> hashtags;

  const ClipMetadataModel({
    required this.status,
    this.title,
    this.description,
    this.hashtags = const [],
  });

  bool get hasContent =>
      (title?.trim().isNotEmpty ?? false) ||
      (description?.trim().isNotEmpty ?? false) ||
      hashtags.isNotEmpty;

  factory ClipMetadataModel.fromJson(Map<String, dynamic> json) {
    return ClipMetadataModel(
      status: json['status'] as String? ?? 'pending',
      title: json['title'] as String?,
      description: json['description'] as String?,
      hashtags:
          (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
