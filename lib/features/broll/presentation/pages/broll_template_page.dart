import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../injection_container.dart';
import '../cubit/broll_template_cubit.dart';
import '../cubit/broll_template_state.dart';
import '../widgets/broll_appearance_section.dart';
import '../widgets/broll_live_preview.dart';

class BrollTemplatePage extends StatelessWidget {
  const BrollTemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BrollTemplateCubit>()..load(),
      child: const _BrollTemplateView(),
    );
  }
}

class _BrollTemplateView extends StatelessWidget {
  const _BrollTemplateView();

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
        child: BlocBuilder<BrollTemplateCubit, BrollTemplateState>(
          builder: (context, state) {
            switch (state.status) {
              case BrollPageStatus.loading:
                return const _BrollTemplateSkeleton();
              case BrollPageStatus.error:
                return _ErrorState(
                  message: state.errorMessage ?? 'Something went wrong.',
                  onRetry: () => context.read<BrollTemplateCubit>().load(),
                );
              case BrollPageStatus.loaded:
                return const _BrollTemplateForm();
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

class _BrollTemplateSkeleton extends StatelessWidget {
  const _BrollTemplateSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: 140,
            height: 20,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          const SizedBox(height: AppSizes.sm),
          const ShimmerBox(width: 180, height: 24),
          const SizedBox(height: 8),
          const ShimmerBox(width: double.infinity, height: 14),
          const SizedBox(height: AppSizes.xl),
          _SkeletonCard(
            child: Row(
              children: [
                const ShimmerBox.circle(size: 36),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 120, height: 14),
                      SizedBox(height: 6),
                      ShimmerBox(width: double.infinity, height: 12),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                ShimmerBox(
                  width: 44,
                  height: 26,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          _SkeletonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 110, height: 14),
                SizedBox(height: AppSizes.sm),
                ShimmerBox(width: double.infinity, height: 140),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          _SkeletonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 90, height: 14),
                const SizedBox(height: AppSizes.sm),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSizes.sm,
                  mainAxisSpacing: AppSizes.sm,
                  childAspectRatio: 2.4,
                  children: const [
                    ShimmerBox(width: double.infinity, height: 50),
                    ShimmerBox(width: double.infinity, height: 50),
                    ShimmerBox(width: double.infinity, height: 50),
                    ShimmerBox(width: double.infinity, height: 50),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          _SkeletonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 70, height: 14),
                SizedBox(height: AppSizes.sm),
                ShimmerBox(width: double.infinity, height: 36),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          _SkeletonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 100, height: 14),
                SizedBox(height: AppSizes.md),
                ShimmerBox(width: double.infinity, height: 10),
                SizedBox(height: AppSizes.md),
                ShimmerBox(width: double.infinity, height: 10),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
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

class _SkeletonCard extends StatelessWidget {
  final Widget child;
  const _SkeletonCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
      ),
      child: child,
    );
  }
}

class _BrollTemplateForm extends StatelessWidget {
  const _BrollTemplateForm();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final enabled = context.select(
      (BrollTemplateCubit c) => c.state.template.enabled,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          child: const Text(
            'OVERLAY TEMPLATE',
            style: TextStyle(
              color: AppColors.accentGreen,
              fontWeight: FontWeight.w700,
              fontSize: AppSizes.fontXs,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          'B-Roll Template',
          style: AppTextStyles.heading(
            neutrals,
          ).copyWith(fontSize: AppSizes.fontXl),
        ),
        const SizedBox(height: 4),
        Text(
          'Configure a persistent overlay that appears on every clip — '
          'upload as many images or videos as you like, then pick one to '
          'use.',
          style: AppTextStyles.subtitle(neutrals),
        ),
        const SizedBox(height: AppSizes.xl),
        const _OverlayToggleCard(),
        const SizedBox(height: AppSizes.lg),
        if (!enabled)
          const _LockedHint()
        else ...[
          const _MediaLibrarySection(),
          const SizedBox(height: AppSizes.lg),
          const _PositionSection(),
          const SizedBox(height: AppSizes.lg),
          const _SizeSection(),
          const SizedBox(height: AppSizes.lg),
          const BrollAppearanceSection(),
        ],
        const SizedBox(height: AppSizes.lg),
        const BrollLivePreview(),
        const SizedBox(height: AppSizes.lg),
        const BrollCurrentConfig(),
        const SizedBox(height: AppSizes.lg),
        const _SaveButton(),
        const SizedBox(height: AppSizes.sm),
        const _ResetButton(),
      ],
    );
  }
}

class _OverlayToggleCard extends StatelessWidget {
  const _OverlayToggleCard();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final cubit = context.read<BrollTemplateCubit>();
    final enabled = context.select(
      (BrollTemplateCubit c) => c.state.template.enabled,
    );
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(
              Icons.auto_awesome_motion_rounded,
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
                  'B-Roll Overlay',
                  style: AppTextStyles.inputText(
                    neutrals,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Show a media overlay on all generated clips',
                  style: AppTextStyles.bodyMuted(neutrals),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeTrackColor: AppColors.accentGreen,
            onChanged: cubit.setEnabled,
          ),
        ],
      ),
    );
  }
}

class _LockedHint extends StatelessWidget {
  const _LockedHint();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: neutrals.textHint,
            size: AppSizes.iconSm,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'Enable the B-Roll overlay above to configure its settings.',
              style: AppTextStyles.bodyMuted(neutrals),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaLibrarySection extends StatelessWidget {
  const _MediaLibrarySection();

  Future<void> _pickMedia(BuildContext context) async {
    final cubit = context.read<BrollTemplateCubit>();
    final picker = ImagePicker();
    final XFile? file;
    try {
      file = await picker.pickMedia();
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Could not open the media picker.');
      }
      return;
    }
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!context.mounted) return;
    await cubit.uploadMedia(
      filename: file.name,
      bytes: bytes,
      localPath: file.path,
    );
    if (!context.mounted) return;
    final error = context.read<BrollTemplateCubit>().state.uploadError;
    if (error != null) {
      AppSnackbar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final state = context.watch<BrollTemplateCubit>().state;
    final hasPreview =
        (state.localAssetPreviewPath?.isNotEmpty ?? false) &&
        File(state.localAssetPreviewPath!).existsSync();
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(
                  Icons.upload_outlined,
                  color: AppColors.accentGreen,
                  size: AppSizes.iconSm,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Media Library',
                      style: AppTextStyles.inputText(
                        neutrals,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Upload an image or video to use as your overlay',
                      style: AppTextStyles.bodyMuted(neutrals),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          InkWell(
            onTap: state.uploading ? null : () => _pickMedia(context),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: neutrals.inputBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: neutrals.inputBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: state.uploading
                  ? const Center(child: CircularProgressIndicator())
                  : hasPreview
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(state.localAssetPreviewPath!),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: AppSizes.sm,
                          bottom: AppSizes.sm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                            ),
                            child: const Text(
                              'Replace',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppSizes.fontXs,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: AppColors.accentGreen,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            'Add media',
                            style: AppTextStyles.inputText(
                              neutrals,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to pick an image or video',
                            style: AppTextStyles.bodyMuted(neutrals),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionSection extends StatelessWidget {
  const _PositionSection();

  static const _options = [
    (value: 'top-left', label: 'Top Left', subtitle: 'Upper-left corner'),
    (value: 'top-right', label: 'Top Right', subtitle: 'Upper-right corner'),
    (value: 'bottom-left', label: 'Bottom Left', subtitle: 'Lower-left corner'),
    (
      value: 'bottom-right',
      label: 'Bottom Right',
      subtitle: 'Lower-right corner (default)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final cubit = context.read<BrollTemplateCubit>();
    final position = context.select(
      (BrollTemplateCubit c) => c.state.template.position,
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
              Icon(
                Icons.open_with_rounded,
                size: AppSizes.iconSm,
                color: AppColors.accentGreen,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Position',
                      style: AppTextStyles.inputText(
                        neutrals,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Choose where the overlay appears on screen',
                      style: AppTextStyles.bodyMuted(neutrals),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSizes.sm,
            mainAxisSpacing: AppSizes.sm,
            childAspectRatio: 2.4,
            children: [
              for (final option in _options)
                _PositionTile(
                  selected: option.value == position,
                  label: option.label,
                  subtitle: option.subtitle,
                  onTap: () => cubit.setPosition(option.value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PositionTile extends StatelessWidget {
  final bool selected;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _PositionTile({
    required this.selected,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentGreen.withValues(alpha: 0.08)
              : neutrals.inputBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: selected ? AppColors.accentGreen : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.accentGreen : neutrals.textHint,
              size: AppSizes.iconSm,
            ),
            const SizedBox(width: AppSizes.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.inputText(neutrals).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.fontXs,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMuted(
                      neutrals,
                    ).copyWith(fontSize: 10),
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

class _SizeSection extends StatelessWidget {
  const _SizeSection();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final cubit = context.read<BrollTemplateCubit>();
    final template = context.select((BrollTemplateCubit c) => c.state.template);
    const presets = {
      'small': 'Small',
      'medium': 'Medium',
      'large': 'Large',
      'custom': 'Custom',
    };
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
              Icon(
                Icons.photo_size_select_large_outlined,
                size: AppSizes.iconSm,
                color: AppColors.accentGreen,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Size',
                      style: AppTextStyles.inputText(
                        neutrals,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Control how much of the screen the overlay occupies',
                      style: AppTextStyles.bodyMuted(neutrals),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text('Size preset', style: AppTextStyles.label(neutrals)),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: presets.entries.map((entry) {
              final selected = entry.key == template.sizePreset;
              return Expanded(
                child: GestureDetector(
                  onTap: () => cubit.setSizePreset(entry.key),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accentGreen.withValues(alpha: 0.15)
                          : neutrals.inputBackground,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(
                        color: selected
                            ? AppColors.accentGreen
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMuted(neutrals).copyWith(
                        color: selected ? AppColors.accentGreen : null,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (template.sizePreset == 'custom') ...[
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: _PercentField(
                    label: 'Width (%)',
                    value: template.customWidth,
                    onChanged: cubit.setCustomWidth,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: _PercentField(
                    label: 'Height (%)',
                    value: template.customHeight,
                    onChanged: cubit.setCustomHeight,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSizes.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(
              'Overlay will occupy '
              '${(template.sizeFraction * 100).round()}% × '
              '${(template.sizeFraction * 100).round()}% of the video frame',
              style: AppTextStyles.bodyMuted(
                neutrals,
              ).copyWith(color: AppColors.accentGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _PercentField extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _PercentField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_PercentField> createState() => _PercentFieldState();
}

class _PercentFieldState extends State<_PercentField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value.round().toString(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.label(neutrals)),
        const SizedBox(height: 4),
        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          style: AppTextStyles.inputText(neutrals),
          onChanged: (text) {
            final parsed = double.tryParse(text);
            if (parsed != null) widget.onChanged(parsed.clamp(5, 100));
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: neutrals.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
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
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<BrollTemplateCubit>();
    final success = await cubit.save();
    if (!context.mounted) return;
    if (success) {
      AppSnackbar.success(context, 'B-Roll template saved');
    } else {
      AppSnackbar.error(context, 'Could not save. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select((BrollTemplateCubit c) => c.state.saving);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        onTap: saving ? null : () => _save(context),
        child: Container(
          height: AppSizes.buttonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.primaryButtonGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          child: saving
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Save template',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return OutlinedButton.icon(
      onPressed: () {
        context.read<BrollTemplateCubit>().resetToDefaults();
        AppSnackbar.info(context, 'Defaults restored — tap Save to apply.');
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        foregroundColor: neutrals.textSecondary,
        side: BorderSide(color: neutrals.cardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
      ),
      icon: const Icon(Icons.restart_alt_rounded, size: AppSizes.iconSm),
      label: const Text('Reset to defaults'),
    );
  }
}
