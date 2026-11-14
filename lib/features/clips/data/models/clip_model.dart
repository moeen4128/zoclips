/// Mirrors the `GET /api/v1/videos/{video_id}/clips` item schema
/// (`ClipCandidateRead`) from the Swagger docs.
class ClipModel {
  final String id;
  final int startSegment;
  final int endSegment;
  final int startSeconds;
  final int endSeconds;
  final int durationSeconds;
  final String title;
  final String category;

  /// 0-100 — the API returns `score` as a 0.0-1.0 fraction (e.g. 0.6977);
  /// this is that value already scaled and rounded to a whole percentage.
  final int score;
  final int rank;

  // `llm_metadata` — free-form in the schema, but in practice always has
  // this shape once a clip has been scored. All nullable since older/
  // not-yet-scored clips may be missing it entirely.
  final String? reason;
  final String? hook;
  final int? hookStrength;
  final int? educationalValue;
  final int? emotionalImpact;
  final int? curiosity;

  /// 0.0-1.0
  final double? confidence;

  const ClipModel({
    required this.id,
    required this.startSegment,
    required this.endSegment,
    required this.startSeconds,
    required this.endSeconds,
    required this.durationSeconds,
    required this.title,
    required this.category,
    required this.score,
    required this.rank,
    this.reason,
    this.hook,
    this.hookStrength,
    this.educationalValue,
    this.emotionalImpact,
    this.curiosity,
    this.confidence,
  });

  factory ClipModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['llm_metadata'] as Map<String, dynamic>?;
    return ClipModel(
      id: json['id'] as String,
      startSegment: (json['start_segment'] as num?)?.toInt() ?? 0,
      endSegment: (json['end_segment'] as num?)?.toInt() ?? 0,
      startSeconds: (json['start_seconds'] as num?)?.toInt() ?? 0,
      endSeconds: (json['end_seconds'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : 'Untitled clip',
      category: json['category'] as String? ?? '',
      score: (((json['score'] as num?) ?? 0) * 100).round(),
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      reason: metadata?['reason'] as String?,
      hook: metadata?['hook'] as String?,
      hookStrength: (metadata?['hook_strength'] as num?)?.toInt(),
      educationalValue: (metadata?['educational_value'] as num?)?.toInt(),
      emotionalImpact: (metadata?['emotional_impact'] as num?)?.toInt(),
      curiosity: (metadata?['curiosity'] as num?)?.toInt(),
      confidence: (metadata?['confidence'] as num?)?.toDouble(),
    );
  }
}
