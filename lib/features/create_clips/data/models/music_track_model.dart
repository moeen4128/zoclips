/// Mirrors an entry from `GET /api/v1/music-library`.
class MusicTrackModel {
  final String id;
  final String title;
  final String artist;
  final double durationSeconds;
  final String previewUrl;
  final String licenseName;
  final String? licenseUrl;

  const MusicTrackModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.durationSeconds,
    required this.previewUrl,
    required this.licenseName,
    this.licenseUrl,
  });

  factory MusicTrackModel.fromJson(Map<String, dynamic> json) {
    return MusicTrackModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble() ?? 0,
      previewUrl: json['preview_url'] as String,
      licenseName: json['license_name'] as String? ?? '',
      licenseUrl: json['license_url'] as String?,
    );
  }

  String get formattedDuration {
    final total = durationSeconds.round();
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
