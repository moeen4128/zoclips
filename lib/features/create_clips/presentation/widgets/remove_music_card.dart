import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../data/models/music_track_model.dart';
import '../cubit/create_clips_cubit.dart';

class RemoveMusicCard extends StatelessWidget {
  const RemoveMusicCard({super.key});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final cubit = context.read<CreateClipsCubit>();
    final enabled = context.select(
      (CreateClipsCubit c) => c.state.removeCopyrightMusic,
    );
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
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
                      'Remove copyright music',
                      style: AppTextStyles.inputText(
                        neutrals,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Strip background music from each clip, keeping '
                      'only speech',
                      style: AppTextStyles.bodyMuted(neutrals),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                activeTrackColor: AppColors.accentGreen,
                onChanged: cubit.setRemoveCopyrightMusic,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: AppSizes.md),
            Text(
              "We'll separate speech from background music on each "
              'generated clip and remove the original music. Pick a '
              'royalty-free replacement below to play quietly under your '
              "speech, or let us choose one for you.",
              style: AppTextStyles.bodyMuted(neutrals),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Background music', style: AppTextStyles.label(neutrals)),
            const SizedBox(height: AppSizes.sm),
            const _MusicLibrarySection(),
            const SizedBox(height: AppSizes.xs),
            Text(
              'All tracks are royalty-free (Creative Commons) — mixed in '
              "at low volume under your clip's speech.",
              style: AppTextStyles.bodyMuted(neutrals),
            ),
          ],
        ],
      ),
    );
  }
}

class _MusicLibrarySection extends StatelessWidget {
  const _MusicLibrarySection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CreateClipsCubit>().state;
    if (state.musicLibraryLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.musicLibraryError != null) {
      return _MusicLibraryError(message: state.musicLibraryError!);
    }
    return const _MusicTrackList();
  }
}

class _MusicLibraryError extends StatelessWidget {
  final String message;
  const _MusicLibraryError({required this.message});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
      child: Center(
        child: Column(
          children: [
            Text(
              message,
              style: AppTextStyles.bodyMuted(neutrals),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),
            TextButton(
              onPressed: () =>
                  context.read<CreateClipsCubit>().loadMusicLibrary(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicTrackList extends StatefulWidget {
  const _MusicTrackList();

  @override
  State<_MusicTrackList> createState() => _MusicTrackListState();
}

class _MusicTrackListState extends State<_MusicTrackList> {
  VideoPlayerController? _controller;
  String? _playingTrackId;
  bool _buffering = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(MusicTrackModel track) async {
    final wasPlayingThis = _playingTrackId == track.id;
    final oldController = _controller;
    setState(() {
      _controller = null;
      _playingTrackId = wasPlayingThis ? null : track.id;
      _buffering = !wasPlayingThis;
    });
    await oldController?.pause();
    await oldController?.dispose();
    if (wasPlayingThis) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(track.previewUrl),
    );
    try {
      await controller.initialize();
      if (!mounted || _playingTrackId != track.id) {
        await controller.dispose();
        return;
      }
      controller.addListener(() => _onPosition(track.id, controller));
      await controller.play();
      if (!mounted || _playingTrackId != track.id) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _buffering = false;
      });
    } catch (_) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _playingTrackId = null;
        _buffering = false;
      });
      AppSnackbar.error(context, 'Could not play this preview.');
    }
  }

  void _onPosition(String trackId, VideoPlayerController controller) {
    if (!mounted || _playingTrackId != trackId) return;
    final value = controller.value;
    if (value.duration > Duration.zero && value.position >= value.duration) {
      setState(() {
        _playingTrackId = null;
        _controller = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final cubit = context.read<CreateClipsCubit>();
    final state = context.watch<CreateClipsCubit>().state;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: neutrals.inputBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 280,
        child: ListView(
          children: [
            _AutoChooseTile(selected: state.selectedMusicTrackId == 'auto'),
            for (final track in state.musicTracks)
              _MusicTrackTile(
                track: track,
                selected: state.selectedMusicTrackId == track.id,
                isPlaying: _playingTrackId == track.id && !_buffering,
                isBuffering: _playingTrackId == track.id && _buffering,
                onSelect: () => cubit.setSelectedMusicTrack(track.id),
                onPlayToggle: () => _togglePlay(track),
              ),
          ],
        ),
      ),
    );
  }
}

class _AutoChooseTile extends StatelessWidget {
  final bool selected;
  const _AutoChooseTile({required this.selected});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final cubit = context.read<CreateClipsCubit>();
    return InkWell(
      onTap: () => cubit.setSelectedMusicTrack('auto'),
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentGreen.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(
            color: selected ? AppColors.accentGreen : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shuffle_rounded,
                color: AppColors.accentGreen,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto-choose',
                    style: AppTextStyles.inputText(
                      neutrals,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "We'll pick one track for you and use it across all "
                    'clips from this video',
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

class _MusicTrackTile extends StatelessWidget {
  final MusicTrackModel track;
  final bool selected;
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onSelect;
  final VoidCallback onPlayToggle;
  const _MusicTrackTile({
    required this.track,
    required this.selected,
    required this.isPlaying,
    required this.isBuffering,
    required this.onSelect,
    required this.onPlayToggle,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentGreen.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(
            color: selected ? AppColors.accentGreen : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Material(
              color: isPlaying
                  ? AppColors.accentGreen
                  : neutrals.inputBackground,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onPlayToggle,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: isBuffering
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: neutrals.textSecondary,
                          ),
                        )
                      : Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: isPlaying
                              ? Colors.black
                              : neutrals.textSecondary,
                          size: 18,
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
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.inputText(
                      neutrals,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${track.artist} · ${track.formattedDuration}',
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
