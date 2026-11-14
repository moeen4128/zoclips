import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../injection_container.dart';
import '../../data/models/language_model.dart';
import '../../data/models/video_source_metadata_model.dart';
import '../cubit/create_clips_cubit.dart';
import '../cubit/create_clips_state.dart';
import '../widgets/auto_publish_card.dart';
import '../widgets/quick_presets_card.dart';
import '../widgets/remove_music_card.dart';

class CreateClipsPage extends StatelessWidget {
  final VideoSourceMetadataModel videoSource;
  final String sourceUrl;

  const CreateClipsPage({
    super.key,
    required this.videoSource,
    required this.sourceUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CreateClipsCubit>()
            ..load(videoSource: videoSource, sourceUrl: sourceUrl),
      child: const _CreateClipsView(),
    );
  }
}

class _CreateClipsView extends StatelessWidget {
  const _CreateClipsView();

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
      ),
      body: ResponsivePage(
        child: BlocBuilder<CreateClipsCubit, CreateClipsState>(
          builder: (context, state) {
            switch (state.status) {
              case CreateClipsStatus.loading:
                return const _CreateClipsSkeleton();
              case CreateClipsStatus.error:
                return _ErrorState(
                  message: state.errorMessage ?? 'Something went wrong.',
                  onRetry: () => context.read<CreateClipsCubit>().load(
                    videoSource: state.videoSource,
                    sourceUrl: state.sourceUrl,
                  ),
                );
              case CreateClipsStatus.loaded:
                return const _CreateClipsForm();
            }
          },
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

class _CreateClipsSkeleton extends StatelessWidget {
  const _CreateClipsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 160, height: 26),
          const SizedBox(height: 8),
          const ShimmerBox(width: 240, height: 14),
          const SizedBox(height: AppSizes.lg),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: AppSizes.sm),
                  ShimmerBox(
                    width: 90,
                    height: 26,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          _SkeletonCard(
            titleWidth: 92,
            trailingWidth: 112,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 64, height: 64),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: double.infinity, height: 14),
                      SizedBox(height: 8),
                      ShimmerBox(width: 140, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          _SkeletonCard(
            titleWidth: 100,
            subtitleWidth: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(height: AppSizes.lg),
                  const ShimmerBox(width: 100, height: 12),
                  const SizedBox(height: AppSizes.sm),
                  const ShimmerBox(width: double.infinity, height: 36),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          _SkeletonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: 110,
                  height: 22,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                const SizedBox(height: AppSizes.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < 5; i++) ...[
                        if (i > 0) const SizedBox(width: AppSizes.sm),
                        const ShimmerBox(width: 84, height: 74),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          for (var i = 0; i < 3; i++) ...[
            _SkeletonCard(
              child: Row(
                children: [
                  const ShimmerBox.circle(size: 36),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: 160, height: 14),
                        SizedBox(height: 6),
                        ShimmerBox(width: double.infinity, height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  ShimmerBox(
                    width: 40,
                    height: 22,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
          ],
          ShimmerBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
        ],
      ),
    );
  }
}

/// Mirrors [_SectionCard]'s header (title + optional subtitle/trailing)
/// so the skeleton has the same silhouette as the loaded card instead of
/// just a blank box.
class _SkeletonCard extends StatelessWidget {
  final double? titleWidth;
  final double? subtitleWidth;
  final double? trailingWidth;
  final Widget child;
  const _SkeletonCard({
    this.titleWidth,
    this.subtitleWidth,
    this.trailingWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titleWidth != null) ...[
            Row(
              children: [
                ShimmerBox(width: titleWidth!, height: 16),
                if (trailingWidth != null) ...[
                  const Spacer(),
                  ShimmerBox(
                    width: trailingWidth!,
                    height: 32,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ],
              ],
            ),
            if (subtitleWidth != null) ...[
              const SizedBox(height: 6),
              ShimmerBox(width: subtitleWidth!, height: 12),
            ],
            const SizedBox(height: AppSizes.md),
          ],
          child,
        ],
      ),
    );
  }
}

class _CreateClipsForm extends StatelessWidget {
  const _CreateClipsForm();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create clips',
          style: AppTextStyles.heading(
            neutrals,
          ).copyWith(fontSize: AppSizes.fontXl),
        ),
        const SizedBox(height: 4),
        Text(
          'Tune the settings once — the AI cuts, captions, and publishes '
          'the rest.',
          style: AppTextStyles.subtitle(neutrals),
        ),
        const SizedBox(height: AppSizes.lg),
        const _StepHeader(),
        const SizedBox(height: AppSizes.xl),
        const _VideoSourceCard(),
        const SizedBox(height: AppSizes.lg),
        const _ClipSettingsCard(),
        const SizedBox(height: AppSizes.lg),
        const QuickPresetsCard(),
        const SizedBox(height: AppSizes.lg),
        const _BrollOverlayCard(),
        const SizedBox(height: AppSizes.lg),
        const RemoveMusicCard(),
        const SizedBox(height: AppSizes.lg),
        const AutoPublishCard(),
        const SizedBox(height: AppSizes.xl),
        const _GetClipsButton(),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader();

  static const _steps = [
    'Source',
    'Clip settings',
    'Captions & extras',
    'Publish',
  ];

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _steps.length; i++) ...[
            if (i > 0)
              Container(
                width: 20,
                height: 1,
                color: neutrals.cardBorder,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                border: Border.all(color: AppColors.accentGreen),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 9,
                    backgroundColor: AppColors.accentGreen,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _steps[i],
                    style: AppTextStyles.label(
                      neutrals,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VideoSourceCard extends StatelessWidget {
  const _VideoSourceCard();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final source = context.select((CreateClipsCubit c) => c.state.videoSource);
    return _SectionCard(
      title: 'Video Source',
      trailing: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          foregroundColor: neutrals.textPrimary,
          side: BorderSide(color: neutrals.cardBorder),
        ),
        icon: const Icon(Icons.refresh_rounded, size: AppSizes.iconSm),
        label: const Text('Change Video'),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  source.thumbnailUrl != null
                      ? Image.network(
                          source.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: neutrals.inputBackground,
                            child: Icon(
                              Icons.movie_creation_outlined,
                              color: neutrals.textHint,
                            ),
                          ),
                        )
                      : Container(
                          color: neutrals.inputBackground,
                          child: Icon(
                            Icons.movie_creation_outlined,
                            color: neutrals.textHint,
                          ),
                        ),
                  if (source.durationSeconds > 0)
                    Positioned(
                      right: 3,
                      bottom: 3,
                      child: _DurationBadge(seconds: source.durationSeconds),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.inputText(
                    neutrals,
                  ).copyWith(fontWeight: FontWeight.w600, height: 1.3),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if ((source.providerName ?? '').toLowerCase() ==
                        'youtube') ...[
                      const _YoutubeIcon(),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        [
                          if (source.authorName != null) source.authorName!,
                          if (source.providerName != null) source.providerName!,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMuted(neutrals),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  final double seconds;
  const _DurationBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final total = seconds.round();
    final minutes = total ~/ 60;
    final secs = total % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$minutes:${secs.toString().padLeft(2, '0')}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _YoutubeIcon extends StatelessWidget {
  const _YoutubeIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(3),
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 12,
      ),
    );
  }
}

class _ClipSettingsCard extends StatelessWidget {
  const _ClipSettingsCard();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final warning = context.select(
      (CreateClipsCubit c) => c.state.clipLengthWarning,
    );
    return _SectionCard(
      title: 'Clip settings',
      subtitle:
          'Choose how many clips to generate and how they should be '
          'trimmed.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Number of clips', style: AppTextStyles.label(neutrals)),
          const SizedBox(height: AppSizes.sm),
          const _ClipCountSelector(),
          const SizedBox(height: AppSizes.lg),
          Text('Clip length', style: AppTextStyles.label(neutrals)),
          const SizedBox(height: AppSizes.sm),
          const _ClipLengthSelector(),
          const SizedBox(height: AppSizes.lg),
          Text('AI model', style: AppTextStyles.label(neutrals)),
          const SizedBox(height: AppSizes.sm),
          const _AiModelDropdown(),
          const SizedBox(height: AppSizes.lg),
          Text('Caption style', style: AppTextStyles.label(neutrals)),
          const SizedBox(height: AppSizes.sm),
          const _CaptionWordStyleDropdown(),
          const SizedBox(height: AppSizes.lg),
          Text('Spoken language', style: AppTextStyles.label(neutrals)),
          const SizedBox(height: AppSizes.sm),
          const _SpokenLanguagePicker(),
          const SizedBox(height: AppSizes.xs),
          Text(
            'The AI detects the language automatically. Pick one if it '
            'gets it wrong.',
            style: AppTextStyles.bodyMuted(neutrals),
          ),
          if (warning != null) ...[
            const SizedBox(height: AppSizes.md),
            _ClipLengthWarningBox(message: warning),
          ],
        ],
      ),
    );
  }
}

class _ClipLengthWarningBox extends StatelessWidget {
  final String message;
  const _ClipLengthWarningBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: neutrals.errorBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: AppSizes.iconSm,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMuted(
                neutrals,
              ).copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClipCountSelector extends StatelessWidget {
  const _ClipCountSelector();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateClipsCubit>();
    final selected = context.select((CreateClipsCubit c) => c.state.clipCount);
    const options = {
      ClipCountOption.auto: 'Auto',
      ClipCountOption.one: '1',
      ClipCountOption.five: '5',
      ClipCountOption.ten: '10',
      ClipCountOption.custom: 'Custom',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SegmentedRow<ClipCountOption>(
          options: options,
          selected: selected,
          onChanged: cubit.setClipCount,
        ),
        if (selected == ClipCountOption.custom) ...[
          const SizedBox(height: AppSizes.sm),
          _CustomValueField(
            hint: 'e.g. 7',
            onChanged: cubit.setCustomClipCount,
          ),
        ],
      ],
    );
  }
}

class _ClipLengthSelector extends StatelessWidget {
  const _ClipLengthSelector();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateClipsCubit>();
    final selected = context.select((CreateClipsCubit c) => c.state.clipLength);
    const options = {
      ClipLengthOption.auto: 'Auto',
      ClipLengthOption.under30: '<30s',
      ClipLengthOption.from30to60: '30-60s',
      ClipLengthOption.from60to90: '60-90s',
      ClipLengthOption.custom: 'Custom',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SegmentedRow<ClipLengthOption>(
          options: options,
          selected: selected,
          onChanged: cubit.setClipLength,
        ),
        if (selected == ClipLengthOption.custom) ...[
          const SizedBox(height: AppSizes.sm),
          _CustomValueField(
            hint: 'e.g. 45s or 1-2min',
            onChanged: cubit.setCustomClipLength,
          ),
        ],
      ],
    );
  }
}

class _CustomValueField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _CustomValueField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return TextFormField(
      onChanged: onChanged,
      style: AppTextStyles.inputText(neutrals),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.hintText(neutrals),
        filled: true,
        fillColor: neutrals.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.accentGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.accentGreen),
        ),
      ),
    );
  }
}

class _SegmentedRow<T> extends StatelessWidget {
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;
  const _SegmentedRow({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Wrap(
      spacing: AppSizes.xs,
      runSpacing: AppSizes.xs,
      children: options.entries.map((entry) {
        final isSelected = entry.key == selected;
        return GestureDetector(
          onTap: () => onChanged(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? neutrals.textPrimary
                  : neutrals.inputBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              entry.value,
              style: AppTextStyles.inputText(neutrals).copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? neutrals.background
                    : neutrals.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AiModelDropdown extends StatelessWidget {
  const _AiModelDropdown();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateClipsCubit>();
    final selected = context.select((CreateClipsCubit c) => c.state.aiModel);
    return _LabeledDropdown<AiModelOption>(
      value: selected,
      items: const {
        AiModelOption.proAutoSelect: 'Pro Auto-Select (Beta)',
        AiModelOption.standard: 'Standard',
      },
      onChanged: cubit.setAiModel,
    );
  }
}

class _CaptionWordStyleDropdown extends StatelessWidget {
  const _CaptionWordStyleDropdown();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateClipsCubit>();
    final selected = context.select(
      (CreateClipsCubit c) => c.state.captionWordStyle,
    );
    return _LabeledDropdown<CaptionWordStyle>(
      value: selected,
      items: const {
        CaptionWordStyle.multipleWords: 'Multiple words',
        CaptionWordStyle.oneWordAtATime: 'One word at a time',
      },
      onChanged: cubit.setCaptionWordStyle,
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;
  const _LabeledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        color: neutrals.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: neutrals.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: neutrals.textSecondary,
          ),
          dropdownColor: neutrals.cardBackground,
          items: items.entries
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e.key,
                  child: Text(
                    e.value,
                    style: AppTextStyles.inputText(neutrals),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _SpokenLanguagePicker extends StatelessWidget {
  const _SpokenLanguagePicker();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final state = context.watch<CreateClipsCubit>().state;
    final label = state.languageCode == 'auto'
        ? 'Auto-detect'
        : _languageLabel(
            state.languages.firstWhere(
              (l) => l.code == state.languageCode,
              orElse: () => const LanguageModel(
                code: 'auto',
                englishName: 'Auto-detect',
                nativeName: 'Auto-detect',
              ),
            ),
          );
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      onTap: () => _openPicker(context),
      child: Container(
        height: AppSizes.inputHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        decoration: BoxDecoration(
          color: neutrals.inputBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: neutrals.inputBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTextStyles.inputText(neutrals)),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: neutrals.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    final cubit = context.read<CreateClipsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) =>
          BlocProvider.value(value: cubit, child: const _LanguagePickerSheet()),
    );
  }
}

String _languageLabel(LanguageModel language) {
  if (language.code == 'auto') return 'Auto-detect';
  return language.nativeName == language.englishName
      ? language.englishName
      : '${language.nativeName} · ${language.englishName}';
}

class _LanguagePickerSheet extends StatefulWidget {
  const _LanguagePickerSheet();

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final state = context.watch<CreateClipsCubit>().state;
    final query = _query.trim().toLowerCase();
    final filtered = state.languages.where((l) {
      if (query.isEmpty) return true;
      return l.englishName.toLowerCase().contains(query) ||
          l.nativeName.toLowerCase().contains(query);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: neutrals.cardBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusLg),
            ),
          ),
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                autofocus: false,
                onChanged: (v) => setState(() => _query = v),
                style: AppTextStyles.inputText(neutrals),
                decoration: InputDecoration(
                  hintText: 'Search language...',
                  hintStyle: AppTextStyles.hintText(neutrals),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: neutrals.textSecondary,
                  ),
                  filled: true,
                  fillColor: neutrals.inputBackground,
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
              const SizedBox(height: AppSizes.sm),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    if (query.isEmpty)
                      _LanguageTile(
                        label: 'Auto-detect',
                        selected: state.languageCode == 'auto',
                        onTap: () {
                          context.read<CreateClipsCubit>().setLanguageCode(
                            'auto',
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    for (final language in filtered)
                      _LanguageTile(
                        label: _languageLabel(language),
                        selected: state.languageCode == language.code,
                        onTap: () {
                          context.read<CreateClipsCubit>().setLanguageCode(
                            language.code,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return ListTile(
      onTap: onTap,
      tileColor: selected
          ? AppColors.accentGreen.withValues(alpha: 0.12)
          : Colors.transparent,
      title: Text(
        label,
        style: AppTextStyles.inputText(neutrals).copyWith(
          color: selected ? AppColors.accentGreen : neutrals.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.accentGreen)
          : null,
    );
  }
}

class _BrollOverlayCard extends StatelessWidget {
  const _BrollOverlayCard();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final cubit = context.read<CreateClipsCubit>();
    final state = context.watch<CreateClipsCubit>().state;
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
              _FeatureIcon(icon: Icons.auto_awesome_motion_rounded),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'B-Roll Overlay',
                      style: AppTextStyles.inputText(
                        neutrals,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Apply your saved overlay to these clips',
                      style: AppTextStyles.bodyMuted(neutrals),
                    ),
                  ],
                ),
              ),
              Switch(
                value: state.brollOverlayEnabled,
                activeTrackColor: AppColors.accentGreen,
                onChanged: state.canEnableBroll
                    ? cubit.setBrollOverlayEnabled
                    : null,
              ),
            ],
          ),
          if (!state.canEnableBroll) ...[
            const SizedBox(height: AppSizes.sm),
            InkWell(
              onTap: () async {
                await context.pushNamed(RouteNames.brollTemplate);
                if (context.mounted) {
                  context.read<CreateClipsCubit>().refreshBrollTemplate();
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: AppSizes.iconSm,
                    color: neutrals.textSecondary,
                  ),
                  const SizedBox(width: AppSizes.xs),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMuted(neutrals),
                        children: const [
                          TextSpan(text: 'Enable your B-Roll from the '),
                          TextSpan(
                            text: 'B-Roll page',
                            style: AppTextStyles.linkGreen,
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  const _FeatureIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Icon(icon, color: AppColors.accentGreen, size: AppSizes.iconMd),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  const _SectionCard({
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
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
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.inputText(neutrals).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppTextStyles.bodyMuted(neutrals)),
          ],
          const SizedBox(height: AppSizes.md),
          child,
        ],
      ),
    );
  }
}

class _GetClipsButton extends StatelessWidget {
  const _GetClipsButton();

  @override
  Widget build(BuildContext context) {
    final hasWarning = context.select(
      (CreateClipsCubit c) => c.state.clipLengthWarning != null,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        // Submission isn't wired up yet — the workflow's settings are
        // UI-only for now.
        onTap: hasWarning
            ? null
            : () => AppSnackbar.info(context, 'Coming soon'),
        child: Container(
          height: AppSizes.buttonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: hasWarning ? null : AppColors.primaryButtonGradient,
            color: hasWarning
                ? AppColors.accentGreen.withValues(alpha: 0.3)
                : null,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          child: Text(
            'Get clips in 1 click',
            style: TextStyle(
              color: hasWarning ? Colors.white60 : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: AppSizes.fontMd,
            ),
          ),
        ),
      ),
    );
  }
}
