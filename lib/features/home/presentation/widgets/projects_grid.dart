import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/shimmer.dart';
import '../cubit/videos_cubit.dart';
import '../cubit/videos_state.dart';
import 'project_card.dart';

String _friendlyError(Object error) {
  if (error is ServerException) return error.message;
  if (error is NetworkException) return error.message;
  if (error is TimeoutException) return error.message;
  if (error is UnauthorizedException) return error.message;
  if (error is CacheException) return error.message;
  return 'Something went wrong. Please try again.';
}

/// Fixed height of a card's info panel below the thumbnail — padding + a
/// 2-line title (the app's default font, Georgia, has taller line metrics
/// than a typical sans font) + the meta row. Constant regardless of card
/// width, since the title is capped at 2 lines with ellipsis.
const _cardInfoPanelHeight = 108.0;

double _cardMainAxisExtent(double crossAxisExtent) =>
    crossAxisExtent * 10 / 16 + _cardInfoPanelHeight;

/// Shared by the loaded grid and its skeleton so they can never drift apart.
/// Card mode is always a single full-width card per row — its height is
/// derived from the available width (same formula grid mode uses per
/// column) so it never becomes a multi-column layout on phone-width
/// screens. Grid mode is a fixed 2-column override.
SliverGridDelegate _gridDelegateFor(double maxWidth, ProjectsViewMode mode) {
  if (mode == ProjectsViewMode.grid) {
    final crossAxisExtent = (maxWidth - AppSizes.lg) / 2;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: AppSizes.lg,
      mainAxisSpacing: AppSizes.lg,
      mainAxisExtent: _cardMainAxisExtent(crossAxisExtent),
    );
  }
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 1,
    mainAxisSpacing: AppSizes.lg,
    mainAxisExtent: _cardMainAxisExtent(maxWidth),
  );
}

class ProjectsGrid extends StatelessWidget {
  const ProjectsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideosCubit, VideosState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final gridDelegate = _gridDelegateFor(
              constraints.maxWidth,
              state.viewMode,
            );
            switch (state.status) {
              case VideosStatus.initial:
              case VideosStatus.loading:
                return _GridSkeleton(gridDelegate: gridDelegate);
              case VideosStatus.error:
                return _ErrorState(
                  message:
                      state.errorMessage ?? 'Could not load your projects.',
                  onRetry: () => context.read<VideosCubit>().fetchVideos(),
                );
              case VideosStatus.loaded:
                final items = state.visibleItems;
                if (items.isEmpty) {
                  return _EmptyState(showSavedOnly: state.showSavedOnly);
                }
                final cubit = context.read<VideosCubit>();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: gridDelegate,
                  itemBuilder: (context, index) {
                    final video = items[index];
                    return ProjectCard(
                      video: video,
                      isSaving: state.savingIds.contains(video.id),
                      isDeleting: state.deletingIds.contains(video.id),
                      onTap: () => context.pushNamed(
                        RouteNames.clips,
                        pathParameters: {'videoId': video.id},
                        extra: video,
                      ),
                      onToggleSaved: (id) async {
                        try {
                          await cubit.toggleSaved(id);
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackbar.error(context, _friendlyError(e));
                          }
                        }
                      },
                      onDelete: (id) async {
                        try {
                          await cubit.deleteVideo(id);
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackbar.error(context, _friendlyError(e));
                          }
                        }
                      },
                    );
                  },
                );
            }
          },
        );
      },
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  final SliverGridDelegate gridDelegate;
  const _GridSkeleton({required this.gridDelegate});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) => const _ProjectCardSkeleton(),
    );
  }
}

class _ProjectCardSkeleton extends StatelessWidget {
  const _ProjectCardSkeleton();

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
      // Shimmer recolors every opaque pixel in its child subtree (it uses
      // BlendMode.srcIn), so it has to wrap only the placeholder bars —
      // wrapping this card's own white background Container too would tint
      // the whole card into one uniform gray blob instead of showing
      // distinct bars on a white background.
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
                  const ShimmerBox(width: 120, height: 14),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: const [
                      ShimmerBox(width: 56, height: 12),
                      SizedBox(width: AppSizes.xs),
                      ShimmerBox(
                        width: 44,
                        height: 12,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppSizes.radiusPill),
                        ),
                      ),
                    ],
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

class _EmptyState extends StatelessWidget {
  final bool showSavedOnly;
  const _EmptyState({required this.showSavedOnly});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xxxl),
      child: Center(
        child: Column(
          children: [
            Icon(
              showSavedOnly
                  ? Icons.bookmark_border_rounded
                  : Icons.movie_creation_outlined,
              size: 40,
              color: neutrals.textHint,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              showSavedOnly ? 'No saved projects yet' : 'No projects yet',
              style: AppTextStyles.subtitle(neutrals),
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
