import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/broll_template_cubit.dart';
import 'broll_live_preview.dart';

class BrollAppearanceSection extends StatelessWidget {
  const BrollAppearanceSection({super.key});

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
              _SectionIcon(icon: Icons.tune_rounded),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: AppTextStyles.inputText(
                        neutrals,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Fine-tune how the overlay looks',
                      style: AppTextStyles.bodyMuted(neutrals),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          const _OpacitySlider(),
          const SizedBox(height: AppSizes.md),
          const _CornerRadiusSlider(),
          const SizedBox(height: AppSizes.md),
          const _BorderToggleRow(),
        ],
      ),
    );
  }
}

class _SectionIcon extends StatelessWidget {
  final IconData icon;
  const _SectionIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Icon(icon, color: AppColors.accentGreen, size: AppSizes.iconSm),
    );
  }
}

class _OpacitySlider extends StatelessWidget {
  const _OpacitySlider();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BrollTemplateCubit>();
    final opacity = context.select(
      (BrollTemplateCubit c) => c.state.template.opacity,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SliderLabel(label: 'Opacity', valueText: '$opacity%'),
        Slider(
          value: opacity.toDouble(),
          min: 10,
          max: 100,
          divisions: 90,
          activeColor: AppColors.accentGreen,
          onChanged: (v) => cubit.setOpacity(v.round()),
        ),
      ],
    );
  }
}

class _CornerRadiusSlider extends StatelessWidget {
  const _CornerRadiusSlider();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BrollTemplateCubit>();
    final radius = context.select(
      (BrollTemplateCubit c) => c.state.template.borderRadius,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SliderLabel(label: 'Corner radius', valueText: '${radius}px'),
        Slider(
          value: radius.toDouble(),
          max: 40,
          divisions: 40,
          activeColor: AppColors.accentGreen,
          onChanged: (v) => cubit.setBorderRadius(v.round()),
        ),
      ],
    );
  }
}

class _SliderLabel extends StatelessWidget {
  final String label;
  final String valueText;
  const _SliderLabel({required this.label, required this.valueText});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Row(
      children: [
        Text(label, style: AppTextStyles.label(neutrals)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Text(
            valueText,
            style: const TextStyle(
              color: AppColors.accentGreen,
              fontWeight: FontWeight.w700,
              fontSize: AppSizes.fontXs,
            ),
          ),
        ),
      ],
    );
  }
}

class _BorderToggleRow extends StatelessWidget {
  const _BorderToggleRow();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final cubit = context.read<BrollTemplateCubit>();
    final state = context.watch<BrollTemplateCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Border', style: AppTextStyles.label(neutrals)),
            const Spacer(),
            Switch(
              value: state.template.showBorder,
              activeTrackColor: AppColors.accentGreen,
              onChanged: cubit.setShowBorder,
            ),
          ],
        ),
        if (state.template.showBorder) ...[
          const SizedBox(height: AppSizes.sm),
          Text('Border color', style: AppTextStyles.label(neutrals)),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              for (final hex in kBorderColorPalette)
                _ColorSwatch(
                  hex: hex,
                  selected:
                      state.template.borderColor.toLowerCase() ==
                      hex.toLowerCase(),
                  onTap: () => cubit.setBorderColor(hex),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String hex;
  final bool selected;
  final VoidCallback onTap;
  const _ColorSwatch({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: parseBorderColor(hex),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.accentGreen : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
