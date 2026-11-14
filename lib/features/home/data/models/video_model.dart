/// Mirrors the `GET /api/v1/videos` item schema from the Swagger docs.
class VideoModel {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final String status;
  final String? errorMessage;
  final int durationSeconds;
  final bool isSaved;
  final DateTime createdAt;
  final String sourceType;
  final String? originalFilename;
  final String? previewUrl;

  const VideoModel({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.status,
    this.errorMessage,
    required this.durationSeconds,
    required this.isSaved,
    required this.createdAt,
    required this.sourceType,
    this.originalFilename,
    this.previewUrl,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : 'Untitled',
      thumbnailUrl: json['thumbnail_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      errorMessage: json['error_message'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      isSaved: json['is_saved'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      sourceType: json['source_type'] as String? ?? 'url',
      originalFilename: json['original_filename'] as String?,
      previewUrl: json['preview_url'] as String?,
    );
  }

  VideoModel copyWith({bool? isSaved}) {
    return VideoModel(
      id: id,
      title: title,
      thumbnailUrl: thumbnailUrl,
      status: status,
      errorMessage: errorMessage,
      durationSeconds: durationSeconds,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt,
      sourceType: sourceType,
      originalFilename: originalFilename,
      previewUrl: previewUrl,
    );
  }
}

/// A page of the paginated video list response.
class VideoListPage {
  final List<VideoModel> items;
  final int total;
  final int page;
  final int pageSize;

  const VideoListPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory VideoListPage.fromJson(Map<String, dynamic> json) {
    return VideoListPage(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
    );
  }
}
