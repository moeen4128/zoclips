/// Mirrors an entry from `GET /api/v1/social-accounts`.
class SocialAccountModel {
  final String id;
  final String platform;
  final String? handle;
  final String? channelName;

  const SocialAccountModel({
    required this.id,
    required this.platform,
    this.handle,
    this.channelName,
  });

  factory SocialAccountModel.fromJson(Map<String, dynamic> json) {
    return SocialAccountModel(
      id: json['id'] as String,
      platform: json['platform'] as String,
      handle: json['handle'] as String?,
      channelName: json['channel_name'] as String?,
    );
  }
}
