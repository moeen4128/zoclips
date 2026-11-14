/// Mirrors an entry from `GET /api/v1/videos/scheduling-summary` — one row
/// per source video, used to pick which video's clips to schedule.
class VideoSchedulingSummaryModel {
  final String videoId;
  final String title;
  final String? thumbnailUrl;
  final int totalClips;
  final int publishedClips;

  const VideoSchedulingSummaryModel({
    required this.videoId,
    required this.title,
    this.thumbnailUrl,
    required this.totalClips,
    required this.publishedClips,
  });

  factory VideoSchedulingSummaryModel.fromJson(Map<String, dynamic> json) {
    return VideoSchedulingSummaryModel(
      videoId: json['video_id'] as String,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : 'Untitled',
      thumbnailUrl: json['thumbnail_url'] as String?,
      totalClips: (json['total_clips'] as num?)?.toInt() ?? 0,
      publishedClips: (json['published_clips'] as num?)?.toInt() ?? 0,
    );
  }
}
