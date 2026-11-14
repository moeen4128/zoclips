import '../../../home/data/models/video_model.dart';
import '../../data/models/clip_model.dart';

/// Passed via GoRouter's `extra` when navigating to the clip detail route —
/// a plain typed class instead of a record, so the router's `extra is ...`
/// check can't silently miss due to a record-type mismatch.
class ClipDetailArgs {
  final VideoModel? video;
  final ClipModel clip;

  const ClipDetailArgs({this.video, required this.clip});
}
