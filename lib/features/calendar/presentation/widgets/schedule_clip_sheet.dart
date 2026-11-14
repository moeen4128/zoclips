import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../injection_container.dart';
import '../../../clips/data/datasources/clips_remote_datasource.dart';
import '../../../clips/data/models/clip_model.dart';
import '../../data/datasources/calendar_remote_datasource.dart';
import '../../data/models/video_scheduling_summary_model.dart';

Future<void> showScheduleClipSheet(
  BuildContext context, {
  required String dateLabel,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ScheduleClipSheet(dateLabel: dateLabel),
  );
}

enum _SheetStatus { loading, loaded, error }

enum _Step { videos, clips, time }

enum _ScheduleMode { schedule, publishNow }

class _ScheduleClipSheet extends StatefulWidget {
  final String dateLabel;
  const _ScheduleClipSheet({required this.dateLabel});

  @override
  State<_ScheduleClipSheet> createState() => _ScheduleClipSheetState();
}

class _ScheduleClipSheetState extends State<_ScheduleClipSheet> {
  _SheetStatus _videoStatus = _SheetStatus.loading;
  List<VideoSchedulingSummaryModel> _videos = const [];
  String? _videoErrorMessage;

  // Non-null once a video has been chosen — drives step 2 ("Choose a clip").
  VideoSchedulingSummaryModel? _selectedVideo;
  _SheetStatus _clipStatus = _SheetStatus.loading;
  List<ClipModel> _clips = const [];
  String? _clipErrorMessage;

  // Non-null once a clip has been chosen — drives step 3 ("Pick a time").
  ClipModel? _selectedClip;
  _ScheduleMode _scheduleMode = _ScheduleMode.schedule;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  _Step get _step {
    if (_selectedClip != null) return _Step.time;
    if (_selectedVideo != null) return _Step.clips;
    return _Step.videos;
  }

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() => _videoStatus = _SheetStatus.loading);
    try {
      final videos = await sl<CalendarRemoteDataSource>()
          .getSchedulingSummary();
      if (!mounted) return;
      setState(() {
        _videos = videos;
        _videoStatus = _SheetStatus.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _videoStatus = _SheetStatus.error;
        _videoErrorMessage = 'Could not load your videos. Please try again.';
      });
    }
  }

  Future<void> _selectVideo(VideoSchedulingSummaryModel video) async {
    setState(() {
      _selectedVideo = video;
      _clipStatus = _SheetStatus.loading;
    });
    try {
      final clips = await sl<ClipsRemoteDataSource>().getClips(
        videoId: video.videoId,
      );
      if (!mounted) return;
      setState(() {
        _clips = clips;
        _clipStatus = _SheetStatus.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _clipStatus = _SheetStatus.error;
        _clipErrorMessage = 'Could not load this video\'s clips. Try again.';
      });
    }
  }

  void _selectClip(ClipModel clip) => setState(() => _selectedClip = clip);

  void _handleBack() {
    if (_selectedClip != null) {
      setState(() => _selectedClip = null);
    } else if (_selectedVideo != null) {
      setState(() => _selectedVideo = null);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time == null || !mounted) return;
    setState(() => _selectedTime = time);
  }

  void _confirmSchedule() {
    AppSnackbar.info(
      context,
      _scheduleMode == _ScheduleMode.schedule
          ? 'Scheduling coming soon'
          : 'Publishing coming soon',
    );
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final step = _step;
    final showBack = step != _Step.videos;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: neutrals.cardBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusLg),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.sm),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: neutrals.divider,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.sm,
                  AppSizes.md,
                  AppSizes.sm,
                  AppSizes.sm,
                ),
                child: Row(
                  children: [
                    if (showBack)
                      IconButton(
                        onPressed: _handleBack,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: neutrals.textSecondary,
                        ),
                      )
                    else
                      const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            switch (step) {
                              _Step.videos => 'Schedule a clip',
                              _Step.clips => 'Choose a clip',
                              _Step.time => 'Pick a time',
                            },
                            style: AppTextStyles.inputText(neutrals).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: AppSizes.fontMd,
                            ),
                          ),
                          Text(
                            widget.dateLabel,
                            style: AppTextStyles.bodyMuted(neutrals),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: neutrals.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (step != _Step.videos)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    0,
                    AppSizes.lg,
                    AppSizes.sm,
                  ),
                  child: Text(
                    step == _Step.time
                        ? _selectedClip!.title
                        : _selectedVideo!.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMuted(
                      neutrals,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              Divider(height: 1, color: neutrals.divider),
              Expanded(
                child: switch (step) {
                  _Step.videos => _buildVideosBody(scrollController),
                  _Step.clips => _buildClipsBody(scrollController),
                  _Step.time => _buildTimeBody(scrollController),
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideosBody(ScrollController scrollController) {
    switch (_videoStatus) {
      case _SheetStatus.loading:
        return _LoadingList(scrollController: scrollController);
      case _SheetStatus.error:
        return _ErrorState(message: _videoErrorMessage!, onRetry: _loadVideos);
      case _SheetStatus.loaded:
        if (_videos.isEmpty) {
          return const _EmptyVideosState();
        }
        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          itemCount: _videos.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSizes.xs),
          itemBuilder: (context, index) {
            final video = _videos[index];
            return _VideoRow(video: video, onTap: () => _selectVideo(video));
          },
        );
    }
  }

  Widget _buildClipsBody(ScrollController scrollController) {
    switch (_clipStatus) {
      case _SheetStatus.loading:
        return _LoadingList(scrollController: scrollController);
      case _SheetStatus.error:
        return _ErrorState(
          message: _clipErrorMessage!,
          onRetry: () => _selectVideo(_selectedVideo!),
        );
      case _SheetStatus.loaded:
        if (_clips.isEmpty) {
          return const _EmptyClipsState();
        }
        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          itemCount: _clips.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSizes.xs),
          itemBuilder: (context, index) {
            final clip = _clips[index];
            return _ClipRow(clip: clip, onTap: () => _selectClip(clip));
          },
        );
    }
  }

  Widget _buildTimeBody(ScrollController scrollController) {
    final neutrals = context.neutrals;
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: neutrals.inputBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ScheduleModeSegment(
                    label: 'Schedule',
                    selected: _scheduleMode == _ScheduleMode.schedule,
                    onTap: () =>
                        setState(() => _scheduleMode = _ScheduleMode.schedule),
                  ),
                ),
                Expanded(
                  child: _ScheduleModeSegment(
                    label: 'Publish now',
                    selected: _scheduleMode == _ScheduleMode.publishNow,
                    onTap: () => setState(
                      () => _scheduleMode = _ScheduleMode.publishNow,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_scheduleMode == _ScheduleMode.schedule) ...[
            const SizedBox(height: AppSizes.lg),
            Text(
              'Time',
              style: AppTextStyles.bodyMuted(
                neutrals,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.xs),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.md,
                ),
                decoration: BoxDecoration(
                  color: neutrals.inputBackground,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: neutrals.inputBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime.format(context),
                      style: AppTextStyles.inputText(neutrals),
                    ),
                    Icon(
                      Icons.access_time_rounded,
                      size: AppSizes.iconSm,
                      color: neutrals.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _confirmSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
              ),
              icon: Icon(
                _scheduleMode == _ScheduleMode.schedule
                    ? Icons.calendar_today_rounded
                    : Icons.bolt_rounded,
                size: AppSizes.iconSm,
              ),
              label: Text(
                _scheduleMode == _ScheduleMode.schedule
                    ? 'Schedule'
                    : 'Publish now',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleModeSegment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ScheduleModeSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        decoration: BoxDecoration(
          color: selected ? neutrals.cardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.inputText(neutrals).copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? neutrals.textPrimary : neutrals.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _VideoRow extends StatelessWidget {
  final VideoSchedulingSummaryModel video;
  final VoidCallback onTap;
  const _VideoRow({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: SizedBox(
                width: 44,
                height: 44,
                child:
                    (video.thumbnailUrl != null &&
                        video.thumbnailUrl!.isNotEmpty)
                    ? Image.network(
                        video.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: neutrals.inputBackground,
                          child: Icon(
                            Icons.movie_creation_outlined,
                            color: neutrals.textHint,
                            size: 20,
                          ),
                        ),
                      )
                    : Container(
                        color: neutrals.inputBackground,
                        child: Icon(
                          Icons.movie_creation_outlined,
                          color: neutrals.textHint,
                          size: 20,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.inputText(
                      neutrals,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${video.publishedClips}/${video.totalClips} published',
                    style: AppTextStyles.bodyMuted(neutrals),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: neutrals.textHint,
              size: AppSizes.iconSm,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  final ScrollController scrollController;
  const _LoadingList({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        itemCount: 6,
        separatorBuilder: (_, _) => const SizedBox(height: AppSizes.md),
        itemBuilder: (context, index) => Row(
          children: [
            const ShimmerBox(
              width: 44,
              height: 44,
              borderRadius: BorderRadius.all(
                Radius.circular(AppSizes.radiusSm),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: double.infinity, height: 14),
                  SizedBox(height: 6),
                  ShimmerBox(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 32),
            const SizedBox(height: AppSizes.md),
            Text(
              message,
              style: AppTextStyles.bodyMuted(neutrals),
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

class _EmptyVideosState extends StatelessWidget {
  const _EmptyVideosState();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Text(
          "You don't have any videos yet.",
          style: AppTextStyles.bodyMuted(neutrals),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _EmptyClipsState extends StatelessWidget {
  const _EmptyClipsState();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Text(
          "This video doesn't have any clips yet.",
          style: AppTextStyles.bodyMuted(neutrals),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ClipRow extends StatelessWidget {
  final ClipModel clip;
  final VoidCallback onTap;
  const _ClipRow({required this.clip, required this.onTap});

  String get _durationLabel {
    final seconds = clip.durationSeconds;
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: Container(
                width: 44,
                height: 44,
                color: neutrals.inputBackground,
                child: Icon(
                  Icons.content_cut_rounded,
                  color: neutrals.textHint,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clip.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.inputText(
                      neutrals,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _durationLabel,
                    style: AppTextStyles.bodyMuted(neutrals),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
