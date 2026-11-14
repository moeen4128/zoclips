import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/features/assets/data/datasources/assets_remote_datasource.dart';
import 'package:zoclips/features/assets/data/models/asset_item_model.dart';
import 'package:zoclips/features/assets/data/models/storage_usage_model.dart';
import 'package:zoclips/features/assets/data/models/subscription_model.dart';
import 'package:zoclips/features/assets/presentation/cubit/assets_cubit.dart';
import 'package:zoclips/features/assets/presentation/pages/assets_page.dart';
import 'package:zoclips/injection_container.dart';

const _storageUsage = StorageUsageModel(
  sourceVideosBytes: 0,
  renderedClipsBytes: 59659044,
  thumbnailsBytes: 573786,
  captionCacheBytes: 0,
  cleanedAudioBytes: 0,
  brollBytes: 0,
  totalBytes: 60232830,
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
    durationSeconds: 32,
    outputUrl: 'https://example.com/$title.mp4',
    videoTitle: 'Source video title',
    createdAt: DateTime(2026, 1, 1),
  );
}

class _FakeAssetsRemoteDataSource implements AssetsRemoteDataSource {
  final List<AssetItemModel> items;
  final Object? error;
  _FakeAssetsRemoteDataSource({this.items = const [], this.error});

  @override
  Future<AssetsPageModel> getAssets({int page = 1, int pageSize = 12}) async {
    if (error != null) throw error!;
    return AssetsPageModel(
      items: items,
      total: items.length,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<StorageUsageModel> getStorageUsage() async => _storageUsage;

  @override
  Future<SubscriptionModel> getSubscription() async => _subscription;
}

Future<void> _pump(
  WidgetTester tester,
  AssetsRemoteDataSource dataSource,
) async {
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  sl.registerFactory<AssetsCubit>(() => AssetsCubit(dataSource));
  addTearDown(() => sl.unregister<AssetsCubit>());

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: const Scaffold(body: AssetsPage()),
    ),
  );
}

void main() {
  testWidgets('shows the clip grid with the storage usage header once loaded', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeAssetsRemoteDataSource(
        items: [
          _item(title: 'The Truth of Victory', category: 'motivational'),
          _item(
            title: 'Legacy of the Golden Warrior',
            category: 'inspirational',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Asset Library'), findsOneWidget);
    expect(find.text('The Truth of Victory'), findsOneWidget);
    expect(find.text('Legacy of the Golden Warrior'), findsOneWidget);
    // The storage line is a RichText with multiple spans, not a plain Text.
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('of 200 GB used'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('search filters the visible clips', (tester) async {
    await _pump(
      tester,
      _FakeAssetsRemoteDataSource(
        items: [
          _item(title: 'The Truth of Victory', category: 'motivational'),
          _item(
            title: 'Legacy of the Golden Warrior',
            category: 'inspirational',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'truth');
    await tester.pumpAndSettle();

    expect(find.text('The Truth of Victory'), findsOneWidget);
    expect(find.text('Legacy of the Golden Warrior'), findsNothing);
  });

  testWidgets('switching to the Uploads tab shows the empty state', (
    tester,
  ) async {
    await _pump(tester, _FakeAssetsRemoteDataSource());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Uploads'));
    await tester.pumpAndSettle();

    expect(find.text('No uploads yet'), findsOneWidget);
    expect(find.text('Upload a video'), findsOneWidget);
  });

  testWidgets('shows an error with retry on failure', (tester) async {
    await _pump(
      tester,
      _FakeAssetsRemoteDataSource(error: Exception('network down')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an empty state when there are no clips', (tester) async {
    await _pump(tester, _FakeAssetsRemoteDataSource());
    await tester.pumpAndSettle();

    expect(find.text('0 clips'), findsOneWidget);
  });
}
