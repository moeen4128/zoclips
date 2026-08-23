import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../utils/responsive.dart';

/// Standard page body wrapper: safe-area, padding that grows with screen
/// width, and a max-width cap so content stays readable on tablets/iPad
/// instead of stretching edge-to-edge.
class ResponsivePage extends StatelessWidget {
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;
  final double maxWidth;

  const ResponsivePage({
    super.key,
    required this.child,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.maxWidth = AppSizes.maxPageWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.pageHorizontalPadding,
              vertical: AppSizes.lg,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
