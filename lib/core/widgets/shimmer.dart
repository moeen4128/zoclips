import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart' as shimmer_pkg;
import '../constants/app_sizes.dart';
import '../theme/app_neutral_colors.dart';

/// Wraps skeleton placeholder shapes with a moving highlight band that
/// sweeps left-to-right on loop. Wrap ONE shimmer around a whole group of
/// [ShimmerBox]es (a card, a list) rather than one per box, so the sweep
/// reads as a single continuous wave instead of several out-of-sync ones.
class Shimmer extends StatelessWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Proven high-contrast pair per theme — deriving these from the app's
    // border/hint neutrals produced a highlight that could end up *darker*
    // than the base in light mode (dull smudge instead of a shine), so
    // these are picked directly instead.
    final baseColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE7E9E7);
    final highlightColor = isDark
        ? const Color(0xFF444444)
        : const Color(0xFFF7F8F7);

    return shimmer_pkg.Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

/// A plain placeholder shape — the base color a [Shimmer] ancestor sweeps
/// its highlight across. Not animated on its own.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppSizes.radiusSm),
    ),
  });

  const ShimmerBox.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = const BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    // Shimmer.fromColors paints its own base/highlight gradient over this
    // shape's alpha, so any opaque fill works here — it's the shape (and
    // its alpha mask) that matters, not this color.
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.neutrals.cardBorder,
        borderRadius: borderRadius,
      ),
    );
  }
}
