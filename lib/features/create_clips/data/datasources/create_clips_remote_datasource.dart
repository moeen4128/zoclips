import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/broll_template_model.dart';
import '../models/language_model.dart';
import '../models/music_track_model.dart';
import '../models/social_account_model.dart';

abstract class CreateClipsRemoteDataSource {
  /// `GET /api/v1/videos/languages` — spoken-language options for the
  /// "Spoken language" picker.
  Future<List<LanguageModel>> getLanguages();

  /// `GET /api/v1/broll/template` — the user's saved B-Roll overlay, used to
  /// decide whether the "B-Roll Overlay" toggle can be switched on.
  Future<BrollTemplateModel> getBrollTemplate();

  /// `GET /api/v1/social-accounts` — connected publishing accounts, used to
  /// decide which "Publish to" platform chip is selectable.
  Future<List<SocialAccountModel>> getSocialAccounts();

  /// `GET /api/v1/music-library` — royalty-free background-music tracks for
  /// the "Remove copyright music" picker.
  Future<List<MusicTrackModel>> getMusicLibrary();
}

class CreateClipsRemoteDataSourceImpl implements CreateClipsRemoteDataSource {
  final DioClient client;
  const CreateClipsRemoteDataSourceImpl(this.client);

  @override
  Future<List<LanguageModel>> getLanguages() async {
    final response = await client.get(ApiConstants.videoLanguages);
    return (response.data as List<dynamic>)
        .map((e) => LanguageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BrollTemplateModel> getBrollTemplate() async {
    final response = await client.get(ApiConstants.brollTemplate);
    return BrollTemplateModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<SocialAccountModel>> getSocialAccounts() async {
    final response = await client.get(ApiConstants.socialAccounts);
    return (response.data as List<dynamic>)
        .map((e) => SocialAccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MusicTrackModel>> getMusicLibrary() async {
    final response = await client.get(ApiConstants.musicLibrary);
    return (response.data as List<dynamic>)
        .map((e) => MusicTrackModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
