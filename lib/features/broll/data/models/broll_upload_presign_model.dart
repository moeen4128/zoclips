/// Mirrors `POST /api/v1/broll/assets/uploads/presign` — a short-lived
/// signed URL to PUT the media file straight to object storage.
class BrollUploadPresignModel {
  final String uploadUrl;
  final String storageKey;
  final int expiresIn;

  const BrollUploadPresignModel({
    required this.uploadUrl,
    required this.storageKey,
    required this.expiresIn,
  });

  factory BrollUploadPresignModel.fromJson(Map<String, dynamic> json) {
    return BrollUploadPresignModel(
      uploadUrl: json['upload_url'] as String,
      storageKey: json['storage_key'] as String,
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 3600,
    );
  }
}
