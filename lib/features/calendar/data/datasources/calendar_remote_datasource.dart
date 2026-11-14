import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/video_scheduling_summary_model.dart';

abstract class CalendarRemoteDataSource {
  /// `GET /api/v1/videos/scheduling-summary` — every source video with how
  /// many of its clips are published, for the "Schedule a clip" picker.
  Future<List<VideoSchedulingSummaryModel>> getSchedulingSummary();
}

class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  final DioClient client;
  const CalendarRemoteDataSourceImpl(this.client);

  @override
  Future<List<VideoSchedulingSummaryModel>> getSchedulingSummary() async {
    final response = await client.get(ApiConstants.videoSchedulingSummary);
    return (response.data as List<dynamic>)
        .map(
          (e) =>
              VideoSchedulingSummaryModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}
