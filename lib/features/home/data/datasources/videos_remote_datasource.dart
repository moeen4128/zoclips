import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

abstract class VideosRemoteDataSource {
  /// Hits the metadata endpoint for [url] — used to confirm the backend is
  /// reachable before the real clip-generation flow is built.
  Future<void> fetchMetadata({required String url});
}

class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  final DioClient client;
  const VideosRemoteDataSourceImpl(this.client);

  @override
  Future<void> fetchMetadata({required String url}) async {
    await client.post(ApiConstants.videoMetadata, data: {'url': url});
  }
}
