/// Mirrors `POST /api/v1/videos/{video_id}/clips/{clip_id}/metadata` — kicks
/// off a regeneration job. The actual new title/description/hashtags land
/// later on `GET .../metadata` once its `status` stops being "pending".
class RegenerateJobModel {
  final String clipMetadataId;
  final String status;
  final int creditsCharged;

  const RegenerateJobModel({
    required this.clipMetadataId,
    required this.status,
    required this.creditsCharged,
  });

  factory RegenerateJobModel.fromJson(Map<String, dynamic> json) {
    return RegenerateJobModel(
      clipMetadataId: json['clip_metadata_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      creditsCharged: (json['credits_charged'] as num?)?.toInt() ?? 0,
    );
  }
}
