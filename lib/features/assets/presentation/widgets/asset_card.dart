import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/gallery_downloader.dart';
import '../../../clips/presentation/widgets/clip_badges.dart';
import '../../../home/data/models/video_model.dart';
import '../../data/models/asset_item_model.dart';

// Card chrome matches the Home → project → ClipCard look (theme-adaptive
// via context.neutrals); only the thumbnail area stays a dark video frame.

class AssetCard extends StatelessWidget {
  final AssetItemModel item;
  const AssetCard({super.key, required this.item});

  void _openParentVideo(BuildContext context) {
    context.pushNamed(
      RouteNames.clips,
      pathParameters: {'videoId': item.videoId},
      extra: VideoModel(
        id: item.videoId,
        title: item.videoTitle,
        thumbnailUrl: item.videoThumbnailUrl,
        status: 'completed',
        durationSeconds: 0,
        isSaved: false,
        createdAt: item.completedAt ?? item.createdAt,
        sourceType: 'url',
      ),
    );
  }

  void _playClip(BuildContext context) {
    // AssetItemModel doesn't carry the full ClipModel (score, segments,
    // etc.) ClipDetailArgs.clip requires, so extra is omitted entirely —
    // the detail page fetches everything fresh via ClipDetailCubit anyway.
    context.pushNamed(
      RouteNames.clipDetail,
      pathParameters: {'videoId': item.videoId, 'clipId': item.clipId},
    );
  }

  @override
  Widget build(BuildContext context) {
    // Prefer the clip's own thumbnail; fall back to the source video's
    // (YouTube) thumbnail when the clip's hasn't been generated yet.
    final thumbnailUrl = (item.thumbnailUrl?.trim().isNotEmpty ?? false)
        ? item.thumbnailUrl
        : item.videoThumbnailUrl;
    final neutrals = context.neutrals;

    return Container(
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _playClip(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                      Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            // A video frame is always dark, independent of
                            // the app theme — a light-theme grey placeholder
                            // here would look like a broken/missing image
                            // instead of "still loading".
                            : Container(color: Colors.black),
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.movie_creation_outlined,
                            color: Colors.white38,
                            size: 36,
                          ),
                        ),
                      )
                    else
                      Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.movie_creation_outlined,
                          color: Colors.white38,
                          size: 36,
                        ),
                      ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.28),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                          stops: const [0, 0.3, 0.6, 1],
                        ),
                      ),
                    ),
                    if (item.category.isNotEmpty)
                      Positioned(
                        left: AppSizes.sm,
                        top: AppSizes.sm,
                        child: CategoryPill(text: item.category),
                      ),
                    const Center(child: _PlayBadge()),
                    if (item.durationSeconds > 0)
                      Positioned(
                        right: AppSizes.sm,
                        bottom: AppSizes.sm,
                        child: _DurationBadge(seconds: item.durationSeconds),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.inputText(
                        neutrals,
                      ).copyWith(fontWeight: FontWeight.w600, height: 1.3),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.videoTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: neutrals.textSecondary,
                        fontSize: AppSizes.fontXs,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        _DownloadButton(item: item),
                        const Spacer(),
                        _OpenButton(onTap: () => _openParentVideo(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10),
        ],
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  final int seconds;
  const _DurationBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        '$minutes:${secs.toString().padLeft(2, '0')}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DownloadButton extends StatefulWidget {
  final AssetItemModel item;
  const _DownloadButton({required this.item});

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _downloading = false;

  Future<void> _download() async {
    final url = widget.item.outputUrl;
    if (url == null || url.isEmpty) return;
    setState(() => _downloading = true);
    await downloadVideoToGallery(
      context: context,
      url: url,
      fileName: '${widget.item.title}.mp4',
    );
    if (mounted) setState(() => _downloading = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasOutput = (widget.item.outputUrl?.trim().isNotEmpty ?? false);
    final enabled = hasOutput && !_downloading;
    return Material(
      color: enabled
          ? AppColors.accentGreen
          : AppColors.accentGreen.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? _download : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: _downloading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Icon(
                  Icons.download_rounded,
                  size: AppSizes.iconSm,
                  color: Colors.black,
                ),
        ),
      ),
    );
  }
}

class _OpenButton extends StatelessWidget {
  final VoidCallback onTap;
  const _OpenButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: neutrals.inputBorder),
            ),
          ),
          child: Icon(
            Icons.open_in_new_rounded,
            size: AppSizes.iconSm,
            color: neutrals.textSecondary,
          ),
        ),
      ),
    );
  }
}
