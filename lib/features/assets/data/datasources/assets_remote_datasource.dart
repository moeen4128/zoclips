import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/asset_item_model.dart';
import '../models/storage_usage_model.dart';
import '../models/subscription_model.dart';

abstract class AssetsRemoteDataSource {
  /// `GET /api/v1/videos/assets` — every rendered clip across all of the
  /// user's videos, paginated.
  Future<AssetsPageModel> getAssets({int page = 1, int pageSize = 12});

  /// `GET /api/v1/videos/storage-usage` — storage breakdown in bytes.
  Future<StorageUsageModel> getStorageUsage();

  /// `GET /api/v1/subscription/me` — plan + credit balance.
  Future<SubscriptionModel> getSubscription();
}

class AssetsRemoteDataSourceImpl implements AssetsRemoteDataSource {
  final DioClient client;
  const AssetsRemoteDataSourceImpl(this.client);

  @override
  Future<AssetsPageModel> getAssets({int page = 1, int pageSize = 12}) async {
    final response = await client.get(
      ApiConstants.assets,
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    return AssetsPageModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<StorageUsageModel> getStorageUsage() async {
    final response = await client.get(ApiConstants.storageUsage);
    return StorageUsageModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SubscriptionModel> getSubscription() async {
    final response = await client.get(ApiConstants.subscriptionMe);
    return SubscriptionModel.fromJson(response.data as Map<String, dynamic>);
  }
}
