/// Mirrors `GET /api/v1/subscription/me` — trimmed to the fields the
/// storage-usage header actually needs (the plan's storage cap).
class SubscriptionModel {
  final String planName;
  final double? maxStorageGb;
  final int creditBalance;

  const SubscriptionModel({
    required this.planName,
    this.maxStorageGb,
    required this.creditBalance,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] as Map<String, dynamic>?;
    return SubscriptionModel(
      planName: plan?['name'] as String? ?? '',
      maxStorageGb: (plan?['max_storage_gb'] as num?)?.toDouble(),
      creditBalance: (json['credit_balance'] as num?)?.toInt() ?? 0,
    );
  }
}
