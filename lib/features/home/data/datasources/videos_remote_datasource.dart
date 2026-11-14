import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../create_clips/data/models/video_source_metadata_model.dart';
import '../models/video_model.dart';

abstract class VideosRemoteDataSource {
  /// `POST /api/v1/videos/metadata` — oEmbed-style preview (title,
  /// thumbnail, author, duration) for a pasted source link, fetched before
  /// the Create Clips workflow starts.
  Future<VideoSourceMetadataModel> fetchMetadata({required String url});

  /// `GET /api/v1/videos` — paginated list of the user's videos/projects.
  Future<VideoListPage> listVideos({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? sourceType,
  });

  /// `PATCH /api/v1/videos/{video_id}/save` — sets the saved flag, returns
  /// the updated video.
  Future<VideoModel> saveVideo({
    required String videoId,
    required bool isSaved,
  });

  /// `DELETE /api/v1/videos/{video_id}` — 204 No Content on success.
  Future<void> deleteVideo({required String videoId});
}

class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  final DioClient client;
  const VideosRemoteDataSourceImpl(this.client);

  @override
  Future<VideoSourceMetadataModel> fetchMetadata({required String url}) async {
    final response = await client.post(
      ApiConstants.videoMetadata,
      data: {'url': url},
    );
    return VideoSourceMetadataModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<VideoListPage> listVideos({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? sourceType,
  }) async {
    final response = await client.get(
      ApiConstants.videos,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sourceType != null) 'source_type': sourceType,
      },
    );
    return VideoListPage.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<VideoModel> saveVideo({
    required String videoId,
    required bool isSaved,
  }) async {
    final response = await client.patch(
      ApiConstants.videoSave(videoId),
      data: {'is_saved': isSaved},
    );
    return VideoModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteVideo({required String videoId}) async {
    await client.delete(ApiConstants.videoById(videoId));
  }
}
