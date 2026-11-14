import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';

/// Tiers a 0-100 score into the same color used for the qualitative label
/// on the clip detail page (Strong/Good/Needs work) — kept here so the grid
/// badges and the detail page always agree on what a score "means".
Color scoreColor(int score) {
  if (score >= 70) return AppColors.accentGreen;
  if (score >= 40) return Colors.amber;
  return AppColors.error;
}

/// Shared by the grid card and the clip detail page so their "Ready" /
/// category / score badges never visually drift apart.
class ReadyChip extends StatelessWidget {
  const ReadyChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 12,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          const Text(
            'Ready',
            style: TextStyle(
              color: AppColors.success,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreChip extends StatelessWidget {
  final int score;
  const ScoreChip({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = scoreColor(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$score',
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

/// Light, accent-tinted variants for use directly on the page background
/// (e.g. the clip detail header) rather than over a video thumbnail.
class ReadyChipLight extends StatelessWidget {
  const ReadyChipLight({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 13,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          const Text(
            'Ready',
            style: TextStyle(
              color: AppColors.success,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryPillLight extends StatelessWidget {
  final String text;
  const CategoryPillLight({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final label = text.length > 1
        ? '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}'
        : text.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.accentGreen,
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Dark, light-bordered pill used on light backgrounds/video thumbnails —
/// a colored dot + title-case category name.
class CategoryPill extends StatelessWidget {
  final String text;
  const CategoryPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final label = text.length > 1
        ? '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}'
        : text.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container(
          //   width: 6,
          //   height: 6,
          //   decoration: const BoxDecoration(
          //     color: AppColors.accentGreen,
          //     shape: BoxShape.circle,
          //   ),
          // ),
          // const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.accentGreen,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
