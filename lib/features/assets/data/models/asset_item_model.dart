/// Mirrors one item of `GET /api/v1/videos/assets` — a rendered clip,
/// shown across every source video in one flat list.
class AssetItemModel {
  final String renderJobId;
  final String videoId;
  final String clipId;
  final String title;
  final String category;
  final int durationSeconds;
  final String? outputUrl;
  final String videoTitle;
  final String? videoThumbnailUrl;
  final String? thumbnailUrl;
  final DateTime? completedAt;
  final DateTime createdAt;

  const AssetItemModel({
    required this.renderJobId,
    required this.videoId,
    required this.clipId,
    required this.title,
    required this.category,
    required this.durationSeconds,
    this.outputUrl,
    required this.videoTitle,
    this.videoThumbnailUrl,
    this.thumbnailUrl,
    this.completedAt,
    required this.createdAt,
  });

  factory AssetItemModel.fromJson(Map<String, dynamic> json) {
    return AssetItemModel(
      renderJobId: json['render_job_id'] as String? ?? '',
      videoId: json['video_id'] as String? ?? '',
      clipId: json['clip_id'] as String? ?? '',
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : 'Untitled clip',
      category: json['category'] as String? ?? '',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      outputUrl: json['output_url'] as String?,
      videoTitle: json['video_title'] as String? ?? '',
      videoThumbnailUrl: json['video_thumbnail_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// A page of the paginated `GET /api/v1/videos/assets` response.
class AssetsPageModel {
  final List<AssetItemModel> items;
  final int total;
  final int page;
  final int pageSize;

  const AssetsPageModel({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory AssetsPageModel.fromJson(Map<String, dynamic> json) {
    return AssetsPageModel(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => AssetItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 12,
    );
  }
}
