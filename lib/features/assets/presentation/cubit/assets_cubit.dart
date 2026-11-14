import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/assets_remote_datasource.dart';
import 'assets_state.dart';

class AssetsCubit extends Cubit<AssetsState> {
  final AssetsRemoteDataSource dataSource;

  AssetsCubit(this.dataSource) : super(const AssetsState.initial());

  Future<void> fetchAssets({int page = 1}) async {
    emit(state.copyWith(status: AssetsStatus.loading));
    try {
      final assetsPage = await dataSource.getAssets(
        page: page,
        pageSize: state.pageSize,
      );
      final storageUsage = await dataSource.getStorageUsage();
      final subscription = await dataSource.getSubscription();
      emit(
        state.copyWith(
          status: AssetsStatus.loaded,
          items: assetsPage.items,
          total: assetsPage.total,
          page: assetsPage.page,
          pageSize: assetsPage.pageSize,
          storageUsage: storageUsage,
          subscription: subscription,
          // A page change should drop filters tied to the old page's
          // category set rather than silently keeping an invisible one.
          clearSelectedCategory: true,
          searchQuery: '',
        ),
      );
    } on ServerException catch (e) {
      emit(state.copyWith(status: AssetsStatus.error, errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(status: AssetsStatus.error, errorMessage: e.message));
    } on TimeoutException catch (e) {
      emit(state.copyWith(status: AssetsStatus.error, errorMessage: e.message));
    } on UnauthorizedException catch (e) {
      emit(state.copyWith(status: AssetsStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: AssetsStatus.error,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> goToPage(int page) {
    if (page < 1 || page > state.totalPages || page == state.page) {
      return Future.value();
    }
    return fetchAssets(page: page);
  }

  void setSearchQuery(String query) => emit(state.copyWith(searchQuery: query));

  void setCategory(String? category) => emit(
    state.copyWith(
      selectedCategory: category,
      clearSelectedCategory: category == null,
    ),
  );
}
