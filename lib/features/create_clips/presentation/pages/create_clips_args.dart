import '../../data/models/video_source_metadata_model.dart';

class CreateClipsArgs {
  final VideoSourceMetadataModel videoSource;
  final String sourceUrl;

  const CreateClipsArgs({required this.videoSource, required this.sourceUrl});
}
