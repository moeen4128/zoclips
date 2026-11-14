import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/broll_template_model.dart';
import '../cubit/broll_template_cubit.dart';

/// Border-color swatches offered in the Appearance section — hex strings
/// sent straight to the API's free-text `border_color` field.
const List<String> kBorderColorPalette = [
  '#000000',
  '#22C55E',
  '#FFFFFF',
  '#F97316',
  '#3B82F6',
  '#EC4899',
  '#2563EB',
];

Color parseBorderColor(String value) {
  final hex = value.trim().replaceFirst('#', '');
  if (hex.length == 6) {
    final parsed = int.tryParse('FF$hex', radix: 16);
    if (parsed != null) return Color(parsed);
  }
  if (hex.length == 8) {
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed != null) return Color(parsed);
  }
  // Values like the web app's "var(--info-color)" aren't renderable client
  // side — fall back to a reasonable stand-in instead of crashing.
  return const Color(0xFF3B82F6);
}

class BrollLivePreview extends StatelessWidget {
  const BrollLivePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final state = context.watch<BrollTemplateCubit>().state;
    final template = state.template;
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
              Icon(
                Icons.videocam_outlined,
                size: AppSizes.iconSm,
                color: neutrals.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Live Preview',
                style: AppTextStyles.inputText(
                  neutrals,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Text(
            'Updates as you change settings',
            style: AppTextStyles.bodyMuted(neutrals),
          ),
          const SizedBox(height: AppSizes.md),
          Center(
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: LayoutBuilder(
                builder: (context, constraints) => Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      if (template.enabled)
                        _OverlayBox(
                          template: template,
                          localAssetPreviewPath: state.localAssetPreviewPath,
                          frameWidth: constraints.maxWidth,
                          frameHeight: constraints.maxHeight,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Center(
            child: Text(
              'Preview · 9:16 · B-Roll ${template.enabled ? 'ON' : 'OFF'}',
              style: AppTextStyles.bodyMuted(neutrals),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayBox extends StatelessWidget {
  final BrollTemplateModel template;
  final String? localAssetPreviewPath;
  final double frameWidth;
  final double frameHeight;
  const _OverlayBox({
    required this.template,
    required this.localAssetPreviewPath,
    required this.frameWidth,
    required this.frameHeight,
  });

  Alignment get _alignment => switch (template.position) {
    'top-left' => Alignment.topLeft,
    'top-right' => Alignment.topRight,
    'bottom-left' => Alignment.bottomLeft,
    _ => Alignment.bottomRight,
  };

  @override
  Widget build(BuildContext context) {
    final fraction = template.sizeFraction;
    final boxWidth = (frameWidth * fraction).clamp(24.0, frameWidth - 16);
    final boxHeight = (frameHeight * fraction).clamp(24.0, frameHeight - 16);
    final hasPreview =
        localAssetPreviewPath != null && localAssetPreviewPath!.isNotEmpty;
    return Align(
      alignment: _alignment,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Opacity(
          opacity: template.opacity / 100,
          child: Container(
            width: boxWidth,
            height: boxHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                template.borderRadius.toDouble(),
              ),
              border: template.showBorder
                  ? Border.all(
                      color: parseBorderColor(template.borderColor),
                      width: 2,
                    )
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPreview
                ? Image.file(File(localAssetPreviewPath!), fit: BoxFit.cover)
                : const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: Colors.black54,
                          size: 18,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'B-Roll',
                          style: TextStyle(fontSize: 9, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class BrollCurrentConfig extends StatelessWidget {
  const BrollCurrentConfig({super.key});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final template = context.select((BrollTemplateCubit c) => c.state.template);
    final sizeLabel = template.sizePreset == 'custom'
        ? '${template.customWidth.round()}% × ${template.customHeight.round()}%'
        : '${(template.sizeFraction * 100).round()}% × '
              '${(template.sizeFraction * 100).round()}%';
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
          Text(
            'CURRENT CONFIG',
            style: AppTextStyles.bodyMuted(
              neutrals,
            ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6),
          ),
          const SizedBox(height: AppSizes.sm),
          _ConfigRow(
            label: 'Status',
            value: template.enabled ? 'Enabled' : 'Disabled',
            valueColor: template.enabled ? AppColors.accentGreen : null,
          ),
          _ConfigRow(
            label: 'Active asset',
            value: template.activeAsset != null ? 'Selected' : 'None selected',
          ),
          _ConfigRow(
            label: 'Position',
            value: _positionLabel(template.position),
          ),
          _ConfigRow(label: 'Size', value: '$sizeLabel of frame'),
          _ConfigRow(label: 'Opacity', value: '${template.opacity}%'),
          _ConfigRow(
            label: 'Border',
            value: template.showBorder ? 'On (${template.borderColor})' : 'Off',
          ),
        ],
      ),
    );
  }

  static String _positionLabel(String position) => switch (position) {
    'top-left' => 'Top Left',
    'top-right' => 'Top Right',
    'bottom-left' => 'Bottom Left',
    _ => 'Bottom Right',
  };
}

class _ConfigRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _ConfigRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMuted(neutrals)),
          Text(
            value,
            style: AppTextStyles.inputText(
              neutrals,
            ).copyWith(fontWeight: FontWeight.w600, color: valueColor),
          ),
        ],
      ),
    );
  }
}
