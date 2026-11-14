/// Mirrors the `POST /api/v1/videos/metadata` response — oEmbed-style
/// preview info for the pasted source link, fetched before any video record
/// exists yet.
class VideoSourceMetadataModel {
  final String title;
  final String? thumbnailUrl;
  final String? authorName;
  final String? providerName;
  final double durationSeconds;

  const VideoSourceMetadataModel({
    required this.title,
    this.thumbnailUrl,
    this.authorName,
    this.providerName,
    required this.durationSeconds,
  });

  factory VideoSourceMetadataModel.fromJson(Map<String, dynamic> json) {
    return VideoSourceMetadataModel(
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : 'Untitled',
      thumbnailUrl: json['thumbnail_url'] as String?,
      authorName: json['author_name'] as String?,
      providerName: json['provider_name'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble() ?? 0,
    );
  }
}
