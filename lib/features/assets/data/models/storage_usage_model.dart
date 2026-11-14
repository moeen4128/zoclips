/// Mirrors `GET /api/v1/videos/storage-usage`.
class StorageUsageModel {
  final int sourceVideosBytes;
  final int renderedClipsBytes;
  final int thumbnailsBytes;
  final int captionCacheBytes;
  final int cleanedAudioBytes;
  final int brollBytes;
  final int totalBytes;

  const StorageUsageModel({
    required this.sourceVideosBytes,
    required this.renderedClipsBytes,
    required this.thumbnailsBytes,
    required this.captionCacheBytes,
    required this.cleanedAudioBytes,
    required this.brollBytes,
    required this.totalBytes,
  });

  factory StorageUsageModel.fromJson(Map<String, dynamic> json) {
    int toInt(String key) => (json[key] as num?)?.toInt() ?? 0;
    return StorageUsageModel(
      sourceVideosBytes: toInt('source_videos_bytes'),
      renderedClipsBytes: toInt('rendered_clips_bytes'),
      thumbnailsBytes: toInt('thumbnails_bytes'),
      captionCacheBytes: toInt('caption_cache_bytes'),
      cleanedAudioBytes: toInt('cleaned_audio_bytes'),
      brollBytes: toInt('broll_bytes'),
      totalBytes: toInt('total_bytes'),
    );
  }
}
