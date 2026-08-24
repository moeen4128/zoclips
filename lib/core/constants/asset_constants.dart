import 'package:flutter/material.dart';

class AssetConstants {
  AssetConstants._();

  /// White/outline mark — reads correctly on dark surfaces.
  static const String logoOnDark = 'assets/branding/zoclips-white-logo.png';

  /// Black-filled mark — reads correctly on light surfaces.
  static const String logoOnLight = 'assets/branding/zoclips-dark-logo.png';

  /// Picks the mark that has enough contrast for the given [brightness].
  static String logoFor(Brightness brightness) =>
      brightness == Brightness.dark ? logoOnDark : logoOnLight;
}
