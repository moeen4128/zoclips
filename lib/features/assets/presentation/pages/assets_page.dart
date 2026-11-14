import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../injection_container.dart';
import '../../data/models/storage_usage_model.dart';
import '../cubit/assets_cubit.dart';
import '../cubit/assets_state.dart';
import '../widgets/asset_card.dart';

const _assetMaxCrossAxisExtent = 200.0;

/// Fixed height of a card's info panel below the thumbnail — padding +
/// 2-line title + 1-line video subtitle + the Download/Open row. Constant
/// regardless of card width since all three are capped to a fixed number
/// of lines.
const _assetInfoPanelHeight = 150.0;

/// Same width-aware approach as the clips grid — a single column on a
/// narrow viewport can end up wider than [_assetMaxCrossAxisExtent], so a
/// fixed mainAxisExtent tuned only for the max case would overflow there.
SliverGridDelegate _gridDelegateFor(double maxWidth) {
  final crossAxisCount = (maxWidth / _assetMaxCrossAxisExtent).ceil().clamp(
    1,
    1 << 20,
  );
  final crossAxisExtent =
      (maxWidth - AppSizes.lg * (crossAxisCount - 1)) / crossAxisCount;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    crossAxisSpacing: AppSizes.lg,
    mainAxisSpacing: AppSizes.lg,
    mainAxisExtent: crossAxisExtent * 4 / 3 + _assetInfoPanelHeight,
  );
}

class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AssetsCubit>()..fetchAssets(),
      child: const _AssetsView(),
    );
  }
}

class _AssetsView extends StatefulWidget {
  const _AssetsView();

  @override
  State<_AssetsView> createState() => _AssetsViewState();
}

class _AssetsViewState extends State<_AssetsView> {
  int _tab = 0; // 0 = Clips, 1 = Uploads

  @override
  Widget build(BuildContext context) {
    return ResponsivePage(
      child: BlocBuilder<AssetsCubit, AssetsState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(state: state),
              const SizedBox(height: AppSizes.xl),
              _TabToggle(
                selected: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: AppSizes.lg),
              if (_tab == 1)
                const _UploadsEmptyState()
              else
                _ClipsTab(state: state),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AssetsState state;
  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asset Library',
          style: AppTextStyles.heading(
            neutrals,
          ).copyWith(fontSize: AppSizes.fontXl),
        ),
        const SizedBox(height: 4),
        Text(
          "Every clip you've rendered and every video you've uploaded, "
          "in one place.",
          style: AppTextStyles.subtitle(neutrals),
        ),
        if (state.storageUsage != null) ...[
          const SizedBox(height: AppSizes.lg),
          _StorageUsageBox(
            usage: state.storageUsage!,
            maxStorageGb: state.subscription?.maxStorageGb,
          ),
        ],
      ],
    );
  }
}

class _StorageUsageBox extends StatelessWidget {
  final StorageUsageModel usage;
  final double? maxStorageGb;
  const _StorageUsageBox({required this.usage, this.maxStorageGb});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    // The API gives 6 granular buckets; the design only shows 3, so
    // everything besides the video upload / rendered clip itself is
    // grouped as "processing" (thumbnails, captions, cleaned audio, broll).
    final processingBytes =
        usage.thumbnailsBytes +
        usage.captionCacheBytes +
        usage.cleanedAudioBytes +
        usage.brollBytes;
    final maxBytes = maxStorageGb != null
        ? (maxStorageGb! * 1024 * 1024 * 1024).round()
        : null;
    final fraction = (maxBytes != null && maxBytes > 0)
        ? (usage.totalBytes / maxBytes).clamp(0.0, 1.0)
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: neutrals.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: _formatBytes(usage.totalBytes),
                  style: AppTextStyles.inputText(
                    neutrals,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: maxStorageGb != null
                      ? ' of ${maxStorageGb!.toStringAsFixed(0)} GB used'
                      : ' used',
                  style: AppTextStyles.bodyMuted(neutrals),
                ),
              ],
            ),
          ),
          if (fraction != null) ...[
            const SizedBox(height: AppSizes.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: neutrals.inputBackground,
                valueColor: const AlwaysStoppedAnimation(AppColors.accentGreen),
              ),
            ),
          ],
          const SizedBox(height: AppSizes.xs),
          Text(
            '${_formatBytes(usage.sourceVideosBytes)} uploads · '
            '${_formatBytes(usage.renderedClipsBytes)} clips · '
            '${_formatBytes(processingBytes)} processing',
            style: AppTextStyles.bodyMuted(neutrals),
          ),
        ],
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes >= 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '$bytes B';
}

class _TabToggle extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _TabToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabPill(
          label: 'Clips',
          selected: selected == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: AppSizes.sm),
        _TabPill(
          label: 'Uploads',
          selected: selected == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(
            color: selected ? AppColors.accentGreen : neutrals.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label(neutrals).copyWith(
            color: selected ? Colors.black : neutrals.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _UploadsEmptyState extends StatelessWidget {
  const _UploadsEmptyState();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xxxl),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: neutrals.inputBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insert_drive_file_outlined,
                color: neutrals.textHint,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'No uploads yet',
              style: AppTextStyles.inputText(
                neutrals,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Videos you upload from your device will show up here.',
              style: AppTextStyles.bodyMuted(neutrals),
            ),
            const SizedBox(height: AppSizes.lg),
            // No upload endpoint has been shared yet — placeholder until
            // that's wired up.
            ElevatedButton.icon(
              onPressed: () =>
                  AppSnackbar.info(context, 'Uploading coming soon'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.upload_rounded, size: AppSizes.iconSm),
              label: const Text('Upload a video'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClipsTab extends StatelessWidget {
  final AssetsState state;
  const _ClipsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    switch (state.status) {
      case AssetsStatus.initial:
      case AssetsStatus.loading:
        return const _ClipsSkeleton();
      case AssetsStatus.error:
        return _ClipsError(
          message: state.errorMessage ?? 'Could not load your assets.',
          onRetry: () =>
              context.read<AssetsCubit>().fetchAssets(page: state.page),
        );
      case AssetsStatus.loaded:
        final visible = state.visibleItems;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    // Keying by page resets the field when the page
                    // changes, matching the cubit clearing search on
                    // fetchAssets — no manual controller sync needed.
                    key: ValueKey(state.page),
                    initialValue: state.searchQuery,
                    onChanged: (value) =>
                        context.read<AssetsCubit>().setSearchQuery(value),
                    style: AppTextStyles.inputText(neutrals),
                    decoration: InputDecoration(
                      hintText: 'Search clips...',
                      hintStyle: AppTextStyles.hintText(neutrals),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: neutrals.textSecondary,
                      ),
                      filled: true,
                      fillColor: neutrals.inputBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        borderSide: BorderSide(color: neutrals.inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        borderSide: BorderSide(color: neutrals.inputBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                _CategoryDropdown(state: state),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${visible.length} clip${visible.length == 1 ? '' : 's'}',
                style: AppTextStyles.bodyMuted(neutrals),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            if (visible.isEmpty)
              const _EmptyClipsState()
            else
              LayoutBuilder(
                builder: (context, constraints) => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visible.length,
                  gridDelegate: _gridDelegateFor(constraints.maxWidth),
                  itemBuilder: (context, index) =>
                      AssetCard(item: visible[index]),
                ),
              ),
            if (state.totalPages > 1) ...[
              const SizedBox(height: AppSizes.xl),
              _Pagination(state: state),
            ],
          ],
        );
    }
  }
}

class _CategoryDropdown extends StatelessWidget {
  final AssetsState state;
  const _CategoryDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final categories = state.availableCategories;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      decoration: BoxDecoration(
        color: neutrals.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: neutrals.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: state.selectedCategory,
          hint: Text(
            'All categories',
            style: AppTextStyles.inputText(neutrals),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: neutrals.textSecondary,
          ),
          dropdownColor: neutrals.cardBackground,
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'All categories',
                style: AppTextStyles.inputText(neutrals),
              ),
            ),
            ...categories.map(
              (c) => DropdownMenuItem<String?>(
                value: c,
                child: Text(c, style: AppTextStyles.inputText(neutrals)),
              ),
            ),
          ],
          onChanged: (value) => context.read<AssetsCubit>().setCategory(value),
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final AssetsState state;
  const _Pagination({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssetsCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: state.page > 1
              ? () => cubit.goToPage(state.page - 1)
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        for (var p = 1; p <= state.totalPages; p++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _PageDot(
              page: p,
              selected: p == state.page,
              onTap: () => cubit.goToPage(p),
            ),
          ),
        IconButton(
          onPressed: state.page < state.totalPages
              ? () => cubit.goToPage(state.page + 1)
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _PageDot extends StatelessWidget {
  final int page;
  final bool selected;
  final VoidCallback onTap;
  const _PageDot({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.accentGreen : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.accentGreen : neutrals.cardBorder,
          ),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            color: selected ? Colors.black : neutrals.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ClipsSkeleton extends StatelessWidget {
  const _ClipsSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: _gridDelegateFor(constraints.maxWidth),
        itemBuilder: (context, index) => const _AssetCardSkeleton(),
      ),
    );
  }
}

class _AssetCardSkeleton extends StatelessWidget {
  const _AssetCardSkeleton();

  @override
  Widget build(BuildContext context) {
    // Matches AssetCard's fixed white/light card chrome so the skeleton
    // doesn't flash from dark to white once the real card loads in.
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AspectRatio(
              aspectRatio: 3 / 4,
              child: ShimmerBox(height: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: AppSizes.xs),
                  const ShimmerBox(width: 100, height: 12),
                  const SizedBox(height: AppSizes.md),
                  ShimmerBox(
                    width: double.infinity,
                    height: 36,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
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

class _EmptyClipsState extends StatelessWidget {
  const _EmptyClipsState();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xxxl),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: neutrals.textHint),
            const SizedBox(height: AppSizes.md),
            Text(
              'No clips match your search',
              style: AppTextStyles.subtitle(neutrals),
            ),
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
