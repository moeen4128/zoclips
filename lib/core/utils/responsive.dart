import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

/// Material 3 window size classes, used to pick layout (bottom bar vs nav
/// rail) and spacing consistently across phones, tablets, foldables and iPad.
enum ScreenSize { compact, medium, expanded }

extension AppResponsive on BuildContext {
  double get _width => MediaQuery.sizeOf(this).width;

  ScreenSize get screenSize {
    final width = _width;
    if (width >= AppSizes.breakpointExpanded) return ScreenSize.expanded;
    if (width >= AppSizes.breakpointMedium) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  bool get isCompact => screenSize == ScreenSize.compact;
  bool get isMedium => screenSize == ScreenSize.medium;
  bool get isExpanded => screenSize == ScreenSize.expanded;

  /// True for tablets, unfolded foldables and iPad — anything wide enough
  /// that a side nav rail reads better than a bottom bar.
  bool get isLargeScreen => !isCompact;

  /// Horizontal page padding that grows with available width.
  double get pageHorizontalPadding {
    switch (screenSize) {
      case ScreenSize.compact:
        return AppSizes.lg;
      case ScreenSize.medium:
        return AppSizes.xl;
      case ScreenSize.expanded:
        return AppSizes.xxl;
    }
  }
}
