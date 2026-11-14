import 'package:equatable/equatable.dart';
import '../../data/models/asset_item_model.dart';
import '../../data/models/storage_usage_model.dart';
import '../../data/models/subscription_model.dart';

enum AssetsStatus { initial, loading, loaded, error }

class AssetsState extends Equatable {
  final AssetsStatus status;
  final List<AssetItemModel> items;
  final int total;
  final int page;
  final int pageSize;
  final StorageUsageModel? storageUsage;
  final SubscriptionModel? subscription;
  final String searchQuery;
  final String? selectedCategory;
  final String? errorMessage;

  const AssetsState._({
    required this.status,
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 12,
    this.storageUsage,
    this.subscription,
    this.searchQuery = '',
    this.selectedCategory,
    this.errorMessage,
  });

  const AssetsState.initial() : this._(status: AssetsStatus.initial);

  int get totalPages => total == 0 ? 1 : (total / pageSize).ceil();

  /// Category names found on the current page — there's no dedicated
  /// categories endpoint, so the filter dropdown can only offer what's
  /// actually been fetched.
  List<String> get availableCategories {
    final set = <String>{};
    for (final item in items) {
      if (item.category.trim().isNotEmpty) set.add(item.category);
    }
    return set.toList()..sort();
  }

  /// Search + category filtering is client-side over the current page only
  /// — the assets endpoint only takes page/page_size, no search/category
  /// query params.
  List<AssetItemModel> get visibleItems {
    final query = searchQuery.trim().toLowerCase();
    return items.where((item) {
      final matchesCategory =
          selectedCategory == null ||
          item.category.toLowerCase() == selectedCategory!.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.videoTitle.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  AssetsState copyWith({
    AssetsStatus? status,
    List<AssetItemModel>? items,
    int? total,
    int? page,
    int? pageSize,
    StorageUsageModel? storageUsage,
    SubscriptionModel? subscription,
    String? searchQuery,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    String? errorMessage,
  }) {
    return AssetsState._(
      status: status ?? this.status,
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      storageUsage: storageUsage ?? this.storageUsage,
      subscription: subscription ?? this.subscription,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    total,
    page,
    pageSize,
    storageUsage,
    subscription,
    searchQuery,
    selectedCategory,
    errorMessage,
  ];
}
