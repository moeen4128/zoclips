import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection_container.dart';
import '../../data/datasources/clips_remote_datasource.dart';
import '../../data/models/clip_model.dart';
import 'clip_badges.dart';

class ClipCard extends StatelessWidget {
  final String videoId;
  final ClipModel clip;
  final VoidCallback? onTap;
  const ClipCard({
    super.key,
    required this.videoId,
    required this.clip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // The clip candidates endpoint has no thumbnail —
                    // _ClipThumbnail fetches it separately from the render
                    // pipeline once that's ready, falling back to a
                    // placeholder until then.
                    _ClipThumbnail(videoId: videoId, clipId: clip.id),
                    // Scrim so the pills stay legible over any thumbnail.
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
                    if (clip.category.isNotEmpty)
                      Positioned(
                        left: AppSizes.sm,
                        top: AppSizes.sm,
                        child: CategoryPill(text: clip.category),
                      ),
                    const Center(child: _PlayButton()),
                    if (clip.durationSeconds > 0)
                      Positioned(
                        right: AppSizes.sm,
                        bottom: AppSizes.sm,
                        child: _Pill(
                          text: _formatDuration(clip.durationSeconds),
                        ),
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
                      clip.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.inputText(
                        neutrals,
                      ).copyWith(fontWeight: FontWeight.w600, height: 1.3),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    // Wrap (not Row) so narrow cards (2-column grid, small
                    // phones) let the score chip drop to its own line
                    // instead of overflowing.
                    Wrap(
                      spacing: AppSizes.xs,
                      runSpacing: 4,
                      children: [
                        // The candidates endpoint has no per-clip status
                        // field — every clip it returns is, by definition,
                        // already found.
                        const ReadyChip(),
                        if (clip.score > 0) ScoreChip(score: clip.score),
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

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ClipThumbnail extends StatefulWidget {
  final String videoId;
  final String clipId;
  const _ClipThumbnail({required this.videoId, required this.clipId});

  @override
  State<_ClipThumbnail> createState() => _ClipThumbnailState();
}

class _ClipThumbnailState extends State<_ClipThumbnail> {
  String? _thumbnailUrl;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    try {
      final status = await sl<ClipsRemoteDataSource>().getPipelineStatus(
        videoId: widget.videoId,
        clipId: widget.clipId,
      );
      final url = status.latestRender?.thumbnailUrl;
      if (mounted && (url?.trim().isNotEmpty ?? false)) {
        setState(() => _thumbnailUrl = url);
      }
    } catch (_) {
      // A thumbnail is a nice-to-have here — if the pipeline isn't ready
      // yet (or the request fails), the placeholder below just stays up.
    }
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final placeholder = Container(
      color: neutrals.inputBackground,
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_creation_outlined,
        color: neutrals.textHint,
        size: 36,
      ),
    );
    if (_thumbnailUrl == null) return placeholder;
    return Image.network(
      _thumbnailUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
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
        size: 26,
      ),
    );
  }
}

String _formatDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
