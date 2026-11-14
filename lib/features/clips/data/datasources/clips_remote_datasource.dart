import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/clip_metadata_model.dart';
import '../models/clip_model.dart';
import '../models/pipeline_status_model.dart';
import '../models/regenerate_job_model.dart';

abstract class ClipsRemoteDataSource {
  /// `GET /api/v1/videos/{video_id}/clips` — returns a raw JSON array (no
  /// pagination envelope), unlike the videos list endpoint.
  Future<List<ClipModel>> getClips({required String videoId});

  /// `GET /api/v1/videos/{video_id}/clips/{clip_id}/pipeline-status` — the
  /// render pipeline's progress and, once done, the clip's playable
  /// output/thumbnail URLs.
  Future<PipelineStatusModel> getPipelineStatus({
    required String videoId,
    required String clipId,
  });

  /// `GET /api/v1/videos/{video_id}/clips/{clip_id}/metadata` — the
  /// AI-generated title/description/hashtags for publishing this clip.
  Future<ClipMetadataModel> getClipMetadata({
    required String videoId,
    required String clipId,
  });

  /// `POST /api/v1/videos/{video_id}/clips/{clip_id}/metadata` — kicks off
  /// a regeneration job for the title/description/hashtags. The response
  /// only confirms the job started ("pending") — poll [getClipMetadata]
  /// until its status changes to get the actual new copy.
  Future<RegenerateJobModel> regenerateMetadata({
    required String videoId,
    required String clipId,
  });
}

class ClipsRemoteDataSourceImpl implements ClipsRemoteDataSource {
  final DioClient client;
  const ClipsRemoteDataSourceImpl(this.client);

  @override
  Future<List<ClipModel>> getClips({required String videoId}) async {
    final response = await client.get(ApiConstants.videoClips(videoId));
    return (response.data as List<dynamic>)
        .map((e) => ClipModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PipelineStatusModel> getPipelineStatus({
    required String videoId,
    required String clipId,
  }) async {
    final response = await client.get(
      ApiConstants.clipPipelineStatus(videoId, clipId),
    );
    return PipelineStatusModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ClipMetadataModel> getClipMetadata({
    required String videoId,
    required String clipId,
  }) async {
    final response = await client.get(
      ApiConstants.clipMetadata(videoId, clipId),
    );
    return ClipMetadataModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<RegenerateJobModel> regenerateMetadata({
    required String videoId,
    required String clipId,
  }) async {
    final response = await client.post(
      ApiConstants.clipMetadata(videoId, clipId),
    );
    return RegenerateJobModel.fromJson(response.data as Map<String, dynamic>);
  }
}
