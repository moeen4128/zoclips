import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../injection_container.dart';
import '../../../home/data/models/video_model.dart';
import '../../data/models/clip_model.dart';
import '../cubit/clips_cubit.dart';
import '../cubit/clips_state.dart';
import '../widgets/clip_card.dart';
import 'clip_detail_args.dart';

/// Fixed height of a clip card's info panel below the thumbnail — padding +
/// a 2-line title + the status/score chip row. Title is capped at 2 lines
/// with ellipsis; the chip row can wrap to 2 lines on narrow cards, so this
/// has headroom for that case too.
const _clipInfoPanelHeight = 112.0;

const _maxCrossAxisExtent = 340.0;

/// SliverGridDelegateWithMaxCrossAxisExtent lets a single column grow past
/// maxCrossAxisExtent to fill the row when the viewport is narrower than
/// 2 columns — a fixed mainAxisExtent tuned for the max width then overflows
/// at that wider single-column size. Computing crossAxisCount the same way
/// the max-extent delegate does, then handing a FixedCrossAxisCount delegate
/// the exact resulting column width, keeps mainAxisExtent correct at every
/// screen size (see the "does not overflow at a narrow single-column width"
/// project-card test for the same fix applied there).
SliverGridDelegate _gridDelegateFor(double maxWidth) {
  final crossAxisCount = (maxWidth / _maxCrossAxisExtent).ceil().clamp(
    1,
    1 << 20,
  );
  final crossAxisExtent =
      (maxWidth - AppSizes.lg * (crossAxisCount - 1)) / crossAxisCount;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    crossAxisSpacing: AppSizes.lg,
    mainAxisSpacing: AppSizes.lg,
    mainAxisExtent: crossAxisExtent * 10 / 16 + _clipInfoPanelHeight,
  );
}

class ClipsPage extends StatelessWidget {
  final String videoId;

  /// Passed via GoRouter's `extra` from the project card that was tapped —
  /// there's no `GET /videos/{id}` endpoint to re-fetch this from, so the
  /// already-loaded video (title, etc.) is threaded straight through.
  final VideoModel? video;

  const ClipsPage({super.key, required this.videoId, this.video});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClipsCubit>()..fetchClips(videoId),
      child: _ClipsView(videoId: videoId, video: video),
    );
  }
}

class _ClipsView extends StatelessWidget {
  final String videoId;
  final VideoModel? video;
  const _ClipsView({required this.videoId, this.video});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Scaffold(
      backgroundColor: neutrals.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: context.statusBarIconStyle,
        iconTheme: IconThemeData(color: neutrals.textPrimary),
        title: Text(
          'Clips',
          style: AppTextStyles.heading(
            neutrals,
          ).copyWith(fontSize: AppSizes.fontLg),
        ),
      ),
      body: ResponsivePage(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gridDelegate = _gridDelegateFor(constraints.maxWidth);
            return BlocBuilder<ClipsCubit, ClipsState>(
              builder: (context, state) {
                switch (state.status) {
                  case ClipsStatus.initial:
                  case ClipsStatus.loading:
                    return _ClipsSkeleton(
                      video: video,
                      gridDelegate: gridDelegate,
                    );
                  case ClipsStatus.error:
                    return _ClipsError(
                      message: state.errorMessage ?? 'Could not load clips.',
                      onRetry: () =>
                          context.read<ClipsCubit>().fetchClips(videoId),
                    );
                  case ClipsStatus.loaded:
                    return _ClipsContent(
                      videoId: videoId,
                      video: video,
                      clips: state.clips,
                      gridDelegate: gridDelegate,
                    );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _ClipsHeader extends StatelessWidget {
  final VideoModel? video;
  final int clipsFound;
  const _ClipsHeader({required this.video, required this.clipsFound});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            border: Border.all(
              color: AppColors.accentGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: AppSizes.iconSm,
                color: AppColors.accentGreen,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'AI-GENERATED CLIPS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label(neutrals).copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontXs,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          video?.title ?? 'Clips',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.heading(
            neutrals,
          ).copyWith(fontSize: AppSizes.fontMd),
        ),
        const SizedBox(height: 4),
        Text(
          'Every clip discovered from this video, rendering '
          'automatically — no further action needed.',
          style: AppTextStyles.subtitle(neutrals),
        ),
        const SizedBox(height: AppSizes.lg),
        Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: Icons.content_cut_rounded,
                value: clipsFound,
                label: 'Clips found',
                color: AppColors.accentGreen,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _StatChip(
                icon: Icons.check_circle_rounded,
                // The candidates endpoint has no per-clip status field, so
                // every clip it returns counts as ready — see ClipCard.
                value: clipsFound,
                label: 'Ready to use',
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: neutrals.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: AppSizes.iconSm, color: color),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value',
                  style: AppTextStyles.heading(
                    neutrals,
                  ).copyWith(fontSize: AppSizes.fontLg),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMuted(neutrals),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClipsContent extends StatelessWidget {
  final String videoId;
  final VideoModel? video;
  final List<ClipModel> clips;
  final SliverGridDelegate gridDelegate;
  const _ClipsContent({
    required this.videoId,
    required this.video,
    required this.clips,
    required this.gridDelegate,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ClipsHeader(video: video, clipsFound: clips.length),
        const SizedBox(height: AppSizes.xxl),
        if (clips.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: Text(
              'Generated clips',
              style: AppTextStyles.label(
                neutrals,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        if (clips.isEmpty)
          const _EmptyState()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: clips.length,
            gridDelegate: gridDelegate,
            itemBuilder: (context, index) {
              final clip = clips[index];
              return ClipCard(
                videoId: videoId,
                clip: clip,
                onTap: () => context.pushNamed(
                  RouteNames.clipDetail,
                  pathParameters: {'videoId': videoId, 'clipId': clip.id},
                  extra: ClipDetailArgs(video: video, clip: clip),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ClipsSkeleton extends StatelessWidget {
  final VideoModel? video;
  final SliverGridDelegate gridDelegate;
  const _ClipsSkeleton({required this.video, required this.gridDelegate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ClipsHeader(video: video, clipsFound: 0),
        const SizedBox(height: AppSizes.xxl),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: gridDelegate,
          itemBuilder: (context, index) => const _ClipCardSkeleton(),
        ),
      ],
    );
  }
}

class _ClipCardSkeleton extends StatelessWidget {
  const _ClipCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AspectRatio(
              aspectRatio: 16 / 10,
              child: ShimmerBox(height: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: AppSizes.xs),
                  const ShimmerBox(width: 100, height: 14),
                  const SizedBox(height: AppSizes.md),
                  const ShimmerBox(width: 56, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xxxl),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.content_cut_rounded, size: 40, color: neutrals.textHint),
            const SizedBox(height: AppSizes.md),
            Text('No clips found yet', style: AppTextStyles.subtitle(neutrals)),
          ],
        ),
      ),
    );
  }
}

class _ClipsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ClipsError({required this.message, required this.onRetry});

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
