import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/assets/data/datasources/assets_remote_datasource.dart';
import 'package:zoclips/features/assets/data/models/asset_item_model.dart';
import 'package:zoclips/features/assets/data/models/storage_usage_model.dart';
import 'package:zoclips/features/assets/data/models/subscription_model.dart';
import 'package:zoclips/features/assets/presentation/cubit/assets_cubit.dart';
import 'package:zoclips/features/assets/presentation/cubit/assets_state.dart';

const _storageUsage = StorageUsageModel(
  sourceVideosBytes: 0,
  renderedClipsBytes: 1000,
  thumbnailsBytes: 0,
  captionCacheBytes: 0,
  cleanedAudioBytes: 0,
  brollBytes: 0,
  totalBytes: 1000,
);

const _subscription = SubscriptionModel(
  planName: 'Business',
  maxStorageGb: 200,
  creditBalance: 10088,
);

AssetItemModel _item({required String title, required String category}) {
  return AssetItemModel(
    renderJobId: title,
    videoId: 'video-1',
    clipId: title,
    title: title,
    category: category,
    durationSeconds: 30,
    outputUrl: 'https://example.com/$title.mp4',
    videoTitle: 'Source video',
    createdAt: DateTime(2026, 1, 1),
  );
}

class _FakeAssetsRemoteDataSource implements AssetsRemoteDataSource {
  final Map<int, List<AssetItemModel>> pages;
  final int total;
  final Object? error;

  _FakeAssetsRemoteDataSource({
    required this.pages,
    required this.total,
    this.error,
  });

  @override
  Future<AssetsPageModel> getAssets({int page = 1, int pageSize = 12}) async {
    if (error != null) throw error!;
    return AssetsPageModel(
      items: pages[page] ?? const [],
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<StorageUsageModel> getStorageUsage() async => _storageUsage;

  @override
  Future<SubscriptionModel> getSubscription() async => _subscription;
}

void main() {
  test(
    'fetchAssets loads the requested page plus storage/subscription',
    () async {
      final cubit = AssetsCubit(
        _FakeAssetsRemoteDataSource(
          pages: {
            1: [
              _item(title: 'Clip A', category: 'motivational'),
              _item(title: 'Clip B', category: 'emotional'),
            ],
          },
          total: 2,
        ),
      );
      addTearDown(cubit.close);

      await cubit.fetchAssets();

      expect(cubit.state.status, AssetsStatus.loaded);
      expect(cubit.state.items, hasLength(2));
      expect(cubit.state.storageUsage, _storageUsage);
      expect(cubit.state.subscription, _subscription);
      expect(cubit.state.totalPages, 1);
    },
  );

  test('visibleItems filters by search query and category', () async {
    final cubit = AssetsCubit(
      _FakeAssetsRemoteDataSource(
        pages: {
          1: [
            _item(title: 'The Truth of Victory', category: 'motivational'),
            _item(
              title: 'Legacy of the Golden Warrior',
              category: 'inspirational',
            ),
          ],
        },
        total: 2,
      ),
    );
    addTearDown(cubit.close);
    await cubit.fetchAssets();

    cubit.setSearchQuery('truth');
    expect(cubit.state.visibleItems, hasLength(1));
    expect(cubit.state.visibleItems.first.title, 'The Truth of Victory');

    cubit.setSearchQuery('');
    cubit.setCategory('inspirational');
    expect(cubit.state.visibleItems, hasLength(1));
    expect(
      cubit.state.visibleItems.first.title,
      'Legacy of the Golden Warrior',
    );

    cubit.setCategory(null);
    expect(cubit.state.visibleItems, hasLength(2));
  });

  test(
    'goToPage re-fetches and clears filters, ignores out-of-range pages',
    () async {
      final cubit = AssetsCubit(
        _FakeAssetsRemoteDataSource(
          pages: {
            1: List.generate(
              12,
              (i) => _item(title: 'Clip $i', category: 'motivational'),
            ),
            2: [_item(title: 'Clip 12', category: 'emotional')],
          },
          total: 13,
        ),
      );
      addTearDown(cubit.close);
      await cubit.fetchAssets();
      cubit.setSearchQuery('clip 1'); // matches "Clip 1", "Clip 10", "Clip 11"

      expect(cubit.state.totalPages, 2);

      await cubit.goToPage(99); // out of range — ignored
      expect(cubit.state.page, 1);

      await cubit.goToPage(2);
      expect(cubit.state.page, 2);
      expect(cubit.state.items, hasLength(1));
      // Page change clears the stale search query from the previous page.
      expect(cubit.state.searchQuery, isEmpty);
    },
  );

  test('emits an error state on failure', () async {
    final cubit = AssetsCubit(
      _FakeAssetsRemoteDataSource(
        pages: const {},
        total: 0,
        error: Exception('boom'),
      ),
    );
    addTearDown(cubit.close);

    await cubit.fetchAssets();

    expect(cubit.state.status, AssetsStatus.error);
    expect(cubit.state.errorMessage, isNotNull);
  });
}
