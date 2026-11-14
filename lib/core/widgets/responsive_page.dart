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
    // Bottom inset goes into the scroll padding (not SafeArea) so content
    // scrolls *behind* the shell's floating bottom nav pill (extendBody)
    // instead of stopping above it and leaving an empty background box,
    // while the last item can still scroll clear of the pill.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.pageHorizontalPadding,
          AppSizes.lg,
          context.pageHorizontalPadding,
          AppSizes.lg + bottomInset,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}
