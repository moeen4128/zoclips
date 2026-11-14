import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/video_model.dart';

class ProjectCard extends StatelessWidget {
  final VideoModel video;
  final bool isSaving;
  final bool isDeleting;
  final ValueChanged<String> onToggleSaved;
  final ValueChanged<String> onDelete;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.video,
    required this.onToggleSaved,
    required this.onDelete,
    this.isSaving = false,
    this.isDeleting = false,
    this.onTap,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final neutrals = context.neutrals;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: neutrals.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          'Delete project?',
          style: AppTextStyles.heading(
            neutrals,
          ).copyWith(fontSize: AppSizes.fontLg),
        ),
        content: Text(
          '"${video.title}" will be removed from this list.',
          style: AppTextStyles.subtitle(neutrals),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel', style: AppTextStyles.subtitle(neutrals)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete(video.id);
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Material(
      color: neutrals.cardBackground,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: neutrals.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _Thumbnail(video: video),
                    Positioned(
                      right: AppSizes.sm,
                      top: AppSizes.sm,
                      child: Column(
                        children: [
                          isSaving
                              ? const _OverlaySpinner()
                              : _OverlayIconButton(
                                  icon: video.isSaved
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: video.isSaved
                                      ? AppColors.accentGreen
                                      : Colors.white,
                                  onTap: () => onToggleSaved(video.id),
                                ),
                          const SizedBox(height: AppSizes.xs),
                          isDeleting
                              ? const _OverlaySpinner()
                              : _OverlayIconButton(
                                  icon: Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  onTap: () => _confirmDelete(context),
                                ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: AppSizes.sm,
                      bottom: AppSizes.sm,
                      child: _DurationBadge(seconds: video.durationSeconds),
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
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.inputText(
                        neutrals,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _relativeTime(video.createdAt),
                            style: AppTextStyles.subtitle(neutrals),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        _StatusPill(status: video.status),
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

class _Thumbnail extends StatelessWidget {
  final VideoModel video;
  const _Thumbnail({required this.video});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final url = video.thumbnailUrl;
    if (url == null || url.isEmpty) {
      return Container(
        color: neutrals.inputBackground,
        alignment: Alignment.center,
        child: Icon(
          Icons.movie_creation_outlined,
          color: neutrals.textHint,
          size: 36,
        ),
      );
    }
    // Decode at the card's on-screen size instead of the source's full
    // resolution (YouTube maxres thumbnails are 1280×720+) — full-size
    // decodes for every card were the main cause of janky Home scrolling.
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = constraints.maxWidth.isFinite
            ? (constraints.maxWidth * dpr).round()
            : null;
        return Image.network(
          url,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
          gaplessPlayback: true,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(color: neutrals.inputBackground);
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: neutrals.inputBackground,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: neutrals.textHint,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OverlayIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: AppSizes.iconSm, color: color),
        ),
      ),
    );
  }
}

class _OverlaySpinner extends StatelessWidget {
  const _OverlaySpinner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: const SizedBox(
        width: AppSizes.iconSm,
        height: AppSizes.iconSm,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  final int seconds;
  const _DurationBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        _formatDuration(seconds),
        style: const TextStyle(
          color: Colors.white,
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final (label, color) = switch (status.toLowerCase()) {
      'completed' || 'ready' || 'done' => ('Ready', AppColors.success),
      'failed' || 'error' => ('Failed', AppColors.error),
      'pending' ||
      'processing' ||
      'queued' => ('Processing', neutrals.textSecondary),
      _ => (
        status.isEmpty
            ? 'Unknown'
            : status[0].toUpperCase() + status.substring(1),
        neutrals.textSecondary,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String _relativeTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inDays >= 60) return '${diff.inDays ~/ 30} months ago';
  if (diff.inDays >= 30) return 'last month';
  if (diff.inDays >= 14) return '${diff.inDays ~/ 7} weeks ago';
  if (diff.inDays >= 7) return 'last week';
  if (diff.inDays >= 1) return '${diff.inDays}d ago';
  if (diff.inHours >= 1) return '${diff.inHours}h ago';
  if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
  return 'just now';
}
