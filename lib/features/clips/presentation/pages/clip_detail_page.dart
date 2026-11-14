import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/gallery_downloader.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../injection_container.dart';
import '../../../home/data/models/video_model.dart';
import '../../data/models/clip_metadata_model.dart';
import '../../data/models/clip_model.dart';
import '../../data/models/pipeline_status_model.dart';
import '../cubit/clip_detail_cubit.dart';
import '../cubit/clip_detail_state.dart';
import '../widgets/clip_badges.dart';

/// Width past which the video and the score/publishing cards sit side by
/// side instead of stacking.
const _wideLayoutBreakpoint = 760.0;

class ClipDetailPage extends StatelessWidget {
  final String videoId;
  final String clipId;

  /// Passed via GoRouter's `extra` from the clip grid card that was tapped
  /// — there's no "get one clip candidate" endpoint, so the already-loaded
  /// video + clip (title, category, score, duration) are threaded straight
  /// through instead of being re-fetched.
  final VideoModel? video;
  final ClipModel? clip;

  const ClipDetailPage({
    super.key,
    required this.videoId,
    required this.clipId,
    this.video,
    this.clip,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ClipDetailCubit>()..fetchDetail(videoId: videoId, clipId: clipId),
      child: _ClipDetailView(
        videoId: videoId,
        clipId: clipId,
        video: video,
        clip: clip,
      ),
    );
  }
}

class _ClipDetailView extends StatelessWidget {
  final String videoId;
  final String clipId;
  final VideoModel? video;
  final ClipModel? clip;
  const _ClipDetailView({
    required this.videoId,
    required this.clipId,
    this.video,
    this.clip,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Scaffold(
      backgroundColor: neutrals.background,
      appBar: AppBar(
        backgroundColor: neutrals.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        systemOverlayStyle: context.statusBarIconStyle,
        iconTheme: IconThemeData(color: neutrals.textPrimary),
      ),
      body: ResponsivePage(
        maxWidth: 1000,
        child: BlocBuilder<ClipDetailCubit, ClipDetailState>(
          builder: (context, state) {
            switch (state.status) {
              case ClipDetailStatus.initial:
              case ClipDetailStatus.loading:
                return const _DetailSkeleton();
              case ClipDetailStatus.error:
                return _DetailError(
                  message: state.errorMessage ?? 'Could not load this clip.',
                  onRetry: () => context.read<ClipDetailCubit>().fetchDetail(
                    videoId: videoId,
                    clipId: clipId,
                  ),
                );
              case ClipDetailStatus.loaded:
                return _DetailContent(
                  videoId: videoId,
                  clipId: clipId,
                  video: video,
                  clip: clip,
                  pipelineStatus: state.pipelineStatus!,
                  metadata: state.metadata!,
                  isRegenerating: state.isRegenerating,
                );
            }
          },
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final String videoId;
  final String clipId;
  final VideoModel? video;
  final ClipModel? clip;
  final PipelineStatusModel pipelineStatus;
  final ClipMetadataModel metadata;
  final bool isRegenerating;

  const _DetailContent({
    required this.videoId,
    required this.clipId,
    required this.video,
    required this.clip,
    required this.pipelineStatus,
    required this.metadata,
    required this.isRegenerating,
  });

  Future<void> _regenerate(BuildContext context) async {
    try {
      await context.read<ClipDetailCubit>().regenerateMetadata(
        videoId: videoId,
        clipId: clipId,
      );
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Could not regenerate. Try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final leftColumn = _ClipPlayerSection(
      pipelineStatus: pipelineStatus,
      clipTitle: clip?.title ?? 'clip',
      durationSeconds: clip?.durationSeconds ?? 0,
    );
    final rightColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ViralScoreCard(clip: clip),
        const SizedBox(height: AppSizes.lg),
        _PublishingDetailsCard(
          metadata: metadata,
          publishStatus: pipelineStatus.publishStatus,
          publishedUrl: pipelineStatus.publishedUrl,
          isRegenerating: isRegenerating,
          onRegenerate: () => _regenerate(context),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (video != null)
          GestureDetector(
            onTap: () => context.pop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: AppSizes.iconSm,
                  color: neutrals.textSecondary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    video!.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMuted(neutrals),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSizes.sm),
        Text(
          clip?.title ?? 'Clip',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.heading(
            neutrals,
          ).copyWith(fontSize: AppSizes.fontLg),
        ),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: AppSizes.xs,
          runSpacing: 4,
          children: [
            if ((clip?.category ?? '').isNotEmpty)
              CategoryPillLight(text: clip!.category),
            const ReadyChipLight(),
          ],
        ),
        const SizedBox(height: AppSizes.xl),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= _wideLayoutBreakpoint) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: leftColumn),
                  const SizedBox(width: AppSizes.lg),
                  Expanded(flex: 2, child: rightColumn),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftColumn,
                const SizedBox(height: AppSizes.lg),
                rightColumn,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ClipPlayerSection extends StatelessWidget {
  final PipelineStatusModel pipelineStatus;
  final String clipTitle;
  final int durationSeconds;
  const _ClipPlayerSection({
    required this.pipelineStatus,
    required this.clipTitle,
    required this.durationSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final render = pipelineStatus.latestRender;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: render != null && render.hasOutput
              ? _ClipVideoPlayer(url: render.outputUrl!)
              : _RenderingPlaceholder(render: render),
        ),
        const SizedBox(height: AppSizes.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: neutrals.cardBackground,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: neutrals.cardBorder),
          ),
          child: Row(
            children: [
              Text('Duration', style: AppTextStyles.label(neutrals)),
              const SizedBox(width: AppSizes.sm),
              Text(
                _formatDuration(durationSeconds),
                style: AppTextStyles.inputText(
                  neutrals,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (render?.hasOutput ?? false)
                _DownloadButton(
                  url: render!.outputUrl!,
                  fileName: '$clipTitle.mp4',
                )
              else
                Icon(
                  Icons.download_rounded,
                  color: neutrals.textHint,
                  size: AppSizes.iconMd,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RenderingPlaceholder extends StatelessWidget {
  final RenderJobModel? render;
  const _RenderingPlaceholder({required this.render});

  @override
  Widget build(BuildContext context) {
    final label = _pipelineStageLabel(render);
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accentGreen),
            const SizedBox(height: AppSizes.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _pipelineStageLabel(RenderJobModel? render) {
  if (render == null) return 'Preparing this clip…';
  switch (render.status) {
    case 'completed':
      return 'Finishing up…';
    case 'failed':
      return (render.errorMessage?.trim().isNotEmpty ?? false)
          ? render.errorMessage!
          : 'Rendering failed — try again later.';
    case 'processing':
      return render.progress > 0
          ? 'Rendering… ${render.progress}%'
          : 'Rendering…';
    case 'queued':
    default:
      return 'Queued for rendering…';
  }
}

String _formatDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

class _ClipVideoPlayer extends StatefulWidget {
  final String url;
  const _ClipVideoPlayer({required this.url});

  @override
  State<_ClipVideoPlayer> createState() => _ClipVideoPlayerState();
}

class _ClipVideoPlayerState extends State<_ClipVideoPlayer> {
  late final VideoPlayerController _videoController;
  ChewieController? _chewieController;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _videoController
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoController,
              autoPlay: false,
              looping: false,
              aspectRatio: _videoController.value.aspectRatio,
              materialProgressColors: ChewieProgressColors(
                playedColor: AppColors.accentGreen,
                handleColor: AppColors.accentGreen,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white12,
              ),
            );
          });
        })
        .catchError((Object e) {
          if (mounted) setState(() => _error = e);
        });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Text(
            'Could not load this video.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    if (_chewieController == null) {
      return const AspectRatio(
        aspectRatio: 9 / 16,
        child: ColoredBox(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accentGreen),
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}

class _DownloadButton extends StatefulWidget {
  final String url;
  final String fileName;
  const _DownloadButton({required this.url, required this.fileName});

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _downloading = false;

  Future<void> _download() async {
    setState(() => _downloading = true);
    await downloadVideoToGallery(
      context: context,
      url: widget.url,
      fileName: widget.fileName,
    );
    if (mounted) setState(() => _downloading = false);
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    if (_downloading) {
      return SizedBox(
        width: AppSizes.iconMd,
        height: AppSizes.iconMd,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: neutrals.textSecondary,
        ),
      );
    }
    return IconButton(
      onPressed: _download,
      icon: Icon(
        Icons.download_rounded,
        color: neutrals.textPrimary,
        size: AppSizes.iconMd,
      ),
      tooltip: 'Download',
    );
  }
}

/// Buckets the clip's `score` (0–100) into the same qualitative labels seen
/// in the design — this bucketing is our own UI heuristic, not an API
/// field, since the backend only returns the raw number.
(String, Color) _scoreLabel(int score) {
  if (score >= 70) return ('Strong', AppColors.accentGreen);
  if (score >= 40) return ('Good', Colors.amber);
  return ('Needs work', AppColors.error);
}

class _ViralScoreCard extends StatelessWidget {
  final ClipModel? clip;
  const _ViralScoreCard({required this.clip});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final score = clip?.score ?? 0;
    final (label, color) = _scoreLabel(score);
    final hook = clip?.hook?.trim() ?? '';
    final reason = clip?.reason?.trim() ?? '';
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.accentGreen,
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Viral score',
                      style: AppTextStyles.heading(
                        neutrals,
                      ).copyWith(fontSize: AppSizes.fontMd),
                    ),
                    Text(
                      'How likely this clip is to hook a viewer',
                      style: AppTextStyles.bodyMuted(neutrals),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: AppTextStyles.heading(neutrals).copyWith(fontSize: 40),
              ),
              const SizedBox(width: AppSizes.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                    Text(
                      'out of 100',
                      style: AppTextStyles.bodyMuted(neutrals),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: LinearProgressIndicator(
              value: score.clamp(0, 100) / 100,
              minHeight: 8,
              backgroundColor: neutrals.inputBackground,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          if (hook.isNotEmpty) ...[
            const SizedBox(height: AppSizes.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: neutrals.inputBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WHY THIS CLIP',
                    style: AppTextStyles.label(
                      neutrals,
                    ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.4),
                  ),
                  const SizedBox(height: 4),
                  Text(hook, style: AppTextStyles.inputText(neutrals)),
                ],
              ),
            ),
          ],
          if (clip != null) ...[
            const SizedBox(height: AppSizes.lg),
            if (clip!.hookStrength != null)
              _MetricBar(
                icon: Icons.bolt_rounded,
                label: 'Hook strength',
                value: clip!.hookStrength!,
                max: 10,
              ),
            if (clip!.emotionalImpact != null)
              _MetricBar(
                icon: Icons.favorite_rounded,
                label: 'Emotional impact',
                value: clip!.emotionalImpact!,
                max: 10,
              ),
            if (clip!.curiosity != null)
              _MetricBar(
                icon: Icons.help_outline_rounded,
                label: 'Curiosity',
                value: clip!.curiosity!,
                max: 10,
              ),
            if (clip!.educationalValue != null)
              _MetricBar(
                icon: Icons.menu_book_outlined,
                label: 'Educational value',
                value: clip!.educationalValue!,
                max: 10,
              ),
            if (clip!.confidence != null)
              _MetricBar(
                icon: Icons.track_changes_rounded,
                label: 'AI confidence',
                value: (clip!.confidence! * 100).round(),
                max: 100,
                displayAsPercent: true,
              ),
          ],
          if (reason.isNotEmpty) ...[
            const SizedBox(height: AppSizes.xs),
            Text(reason, style: AppTextStyles.bodyMuted(neutrals)),
          ],
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showScheduleDialog(context),
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    size: AppSizes.iconSm,
                  ),
                  label: const Text('Schedule'),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showPublishDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.send_rounded, size: AppSizes.iconSm),
                  label: const Text('Publish'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Neither dialog actually calls the publish/schedule API yet — there's no
/// social-account-connection UI anywhere in the app to source a real
/// platform/social_account_id from, so confirming just acknowledges the
/// action for now. The channel name in both dialogs is generic for the
/// same reason.
Future<void> _showScheduleDialog(BuildContext context) async {
  final scheduledFor = await showDialog<DateTime>(
    context: context,
    builder: (_) => const _ScheduleClipDialog(),
  );
  if (scheduledFor != null && context.mounted) {
    AppSnackbar.info(context, 'Scheduling coming soon');
  }
}

Future<void> _showPublishDialog(BuildContext context) async {
  final neutrals = context.neutrals;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: neutrals.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Text(
        'Publish this clip now',
        style: AppTextStyles.heading(
          neutrals,
        ).copyWith(fontSize: AppSizes.fontLg),
      ),
      content: Text(
        "This will immediately post the clip to your connected account "
        "as a public video on YouTube. This can't be undone from here.",
        style: AppTextStyles.subtitle(neutrals),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text('Cancel', style: AppTextStyles.subtitle(neutrals)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGreen,
            foregroundColor: Colors.black,
          ),
          child: const Text('Publish now'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    AppSnackbar.info(context, 'Publishing coming soon');
  }
}

class _ScheduleClipDialog extends StatefulWidget {
  const _ScheduleClipDialog();

  @override
  State<_ScheduleClipDialog> createState() => _ScheduleClipDialogState();
}

class _ScheduleClipDialogState extends State<_ScheduleClipDialog> {
  DateTime? _dateTime;

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _dateTime != null
          ? TimeOfDay.fromDateTime(_dateTime!)
          : TimeOfDay.now(),
    );
    if (time == null || !mounted) return;
    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return AlertDialog(
      backgroundColor: neutrals.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Text(
        'Schedule this clip',
        style: AppTextStyles.heading(
          neutrals,
        ).copyWith(fontSize: AppSizes.fontLg),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick a date and time — the clip will be posted to your '
            'connected account on YouTube automatically.',
            style: AppTextStyles.subtitle(neutrals),
          ),
          const SizedBox(height: AppSizes.lg),
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.md,
              ),
              decoration: BoxDecoration(
                color: neutrals.inputBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: _dateTime != null
                      ? AppColors.accentGreen
                      : neutrals.inputBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: AppSizes.iconSm,
                    color: neutrals.textSecondary,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      _dateTime == null
                          ? 'dd/mm/yyyy --:-- --'
                          : _formatScheduleDateTime(_dateTime!),
                      style: _dateTime == null
                          ? AppTextStyles.hintText(neutrals)
                          : AppTextStyles.inputText(neutrals),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        0,
        AppSizes.lg,
        AppSizes.lg,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: AppTextStyles.subtitle(neutrals)),
        ),
        ElevatedButton(
          onPressed: _dateTime == null
              ? null
              : () => Navigator.of(context).pop(_dateTime),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGreen,
            foregroundColor: Colors.black,
            disabledBackgroundColor: AppColors.accentGreen.withValues(
              alpha: 0.4,
            ),
          ),
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}

String _formatScheduleDateTime(DateTime dateTime) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, '
      '$hour:$minute $period';
}

class _MetricBar extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final int max;
  final bool displayAsPercent;

  const _MetricBar({
    required this.icon,
    required this.label,
    required this.value,
    required this.max,
    this.displayAsPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconSm, color: neutrals.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label, style: AppTextStyles.label(neutrals)),
              ),
              Text(
                displayAsPercent ? '$value%' : '$value/$max',
                style: AppTextStyles.label(neutrals).copyWith(
                  fontWeight: FontWeight.w700,
                  color: neutrals.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: LinearProgressIndicator(
              value: (value / max).clamp(0, 1),
              minHeight: 6,
              backgroundColor: neutrals.inputBackground,
              valueColor: const AlwaysStoppedAnimation(AppColors.accentGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishingDetailsCard extends StatelessWidget {
  final ClipMetadataModel metadata;
  final String publishStatus;
  final String? publishedUrl;
  final bool isRegenerating;
  final VoidCallback onRegenerate;
  const _PublishingDetailsCard({
    required this.metadata,
    required this.publishStatus,
    this.publishedUrl,
    required this.isRegenerating,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.accentGreen,
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publishing details',
                      style: AppTextStyles.heading(
                        neutrals,
                      ).copyWith(fontSize: AppSizes.fontMd),
                    ),
                    Text(
                      'AI-generated title, description & hashtags',
                      style: AppTextStyles.bodyMuted(neutrals),
                    ),
                  ],
                ),
              ),
              _RegenerateButton(
                isRegenerating: isRegenerating,
                onTap: onRegenerate,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          if (isRegenerating)
            const _WritingYourCopy()
          else if (!metadata.hasContent)
            const _NothingGeneratedYet()
          else ...[
            _CopyableField(label: 'Title', value: metadata.title ?? ''),
            const SizedBox(height: AppSizes.md),
            _CopyableField(
              label: 'Description',
              value: metadata.description ?? '',
            ),
            if (metadata.hashtags.isNotEmpty) ...[
              const SizedBox(height: AppSizes.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hashtags', style: AppTextStyles.label(neutrals)),
                  _CopyButton(
                    value: metadata.hashtags.map((h) => '#$h').join(' '),
                    label: 'Copy all',
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.xs,
                runSpacing: AppSizes.xs,
                children: metadata.hashtags
                    .map((tag) => _HashtagChip(text: tag))
                    .toList(),
              ),
            ],
          ],
          const SizedBox(height: AppSizes.lg),
          Divider(color: neutrals.divider, height: 1),
          const SizedBox(height: AppSizes.lg),
          Text('Publish status', style: AppTextStyles.label(neutrals)),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              _PublishStatusChip(status: publishStatus),
              if ((publishedUrl?.trim().isNotEmpty ?? false)) ...[
                const Spacer(),
                _ViewPublishedLink(url: publishedUrl!),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PublishStatusChip extends StatelessWidget {
  final String status;
  const _PublishStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (status.toLowerCase()) {
      'published' => (
        Icons.check_circle_rounded,
        AppColors.success,
        'Published',
      ),
      'scheduled' => (Icons.schedule_rounded, Colors.amber, 'Scheduled'),
      'failed' => (Icons.error_rounded, AppColors.error, 'Failed'),
      'processing' ||
      'publishing' => (Icons.hourglass_top_rounded, Colors.amber, 'Publishing'),
      _ => (Icons.circle_outlined, Colors.grey, 'Draft'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewPublishedLink extends StatelessWidget {
  final String url;
  const _ViewPublishedLink({required this.url});

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      AppSnackbar.error(context, 'Could not open this link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _open(context),
      icon: const Icon(Icons.open_in_new_rounded, size: 14),
      label: const Text('View'),
    );
  }
}

class _RegenerateButton extends StatelessWidget {
  final bool isRegenerating;
  final VoidCallback onTap;
  const _RegenerateButton({required this.isRegenerating, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isRegenerating ? null : onTap,
      icon: isRegenerating
          ? const SizedBox(
              width: AppSizes.iconSm,
              height: AppSizes.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentGreen,
              ),
            )
          : const Icon(Icons.auto_awesome_rounded, size: AppSizes.iconSm),
      // "2" is a fixed cost shown ahead of the action — there's no
      // "what will this cost" endpoint, so this matches the design's
      // static copy rather than any API value.
      label: const Text('Regenerate · 2'),
    );
  }
}

class _WritingYourCopy extends StatelessWidget {
  const _WritingYourCopy();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.accentGreen,
                size: AppSizes.iconMd,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Writing your copy…',
              style: AppTextStyles.subtitle(neutrals).copyWith(
                fontWeight: FontWeight.w600,
                color: neutrals.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "This usually takes a few seconds. You don't need to keep "
              "this tab open.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted(neutrals),
            ),
          ],
        ),
      ),
    );
  }
}

class _NothingGeneratedYet extends StatelessWidget {
  const _NothingGeneratedYet();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 32,
              color: neutrals.textHint,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Nothing generated yet',
              style: AppTextStyles.subtitle(neutrals).copyWith(
                fontWeight: FontWeight.w600,
                color: neutrals.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Click "Regenerate" to have AI write a title, description, '
              'and hashtags for this clip.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted(neutrals),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyableField extends StatelessWidget {
  final String label;
  final String value;
  const _CopyableField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.label(neutrals)),
            _CopyButton(value: value),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: neutrals.inputBackground,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: neutrals.inputBorder),
          ),
          child: Text(value, style: AppTextStyles.inputText(neutrals)),
        ),
      ],
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String value;
  final String label;
  const _CopyButton({required this.value, this.label = 'Copy'});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: value));
        AppSnackbar.info(context, 'Copied to clipboard');
      },
      icon: const Icon(Icons.copy_rounded, size: 14),
      label: Text(label),
    );
  }
}

class _HashtagChip extends StatelessWidget {
  final String text;
  const _HashtagChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: neutrals.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: Border.all(color: neutrals.inputBorder),
      ),
      child: Text(
        '#$text',
        style: AppTextStyles.label(
          neutrals,
        ).copyWith(color: AppColors.accentGreen),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 160, height: 14),
          const SizedBox(height: AppSizes.md),
          const ShimmerBox(width: 240, height: 22),
          const SizedBox(height: AppSizes.md),
          const ShimmerBox(width: 100, height: 20),
          const SizedBox(height: AppSizes.xl),
          AspectRatio(
            aspectRatio: 9 / 16,
            child: ShimmerBox(
              height: double.infinity,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          ShimmerBox(
            width: double.infinity,
            height: 160,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ],
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _DetailError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xxxl),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 36),
            const SizedBox(height: AppSizes.md),
            Text(
              message,
              style: AppTextStyles.subtitle(neutrals),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.md),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
