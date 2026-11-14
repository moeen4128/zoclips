import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Surface/text colors that flip between light and dark theme. Brand colors
/// (green accents, error red) stay constant across both — see [AppColors].
@immutable
class AppNeutralColors extends ThemeExtension<AppNeutralColors> {
  final Color background;
  final Color cardBackground;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color inputBackground;
  final Color inputBorder;
  final Color divider;
  final Color errorBackground;

  /// Opacity of the auth-screen radial glow — the green glow reads fine on
  /// near-black but needs to be much more subtle on a white background.
  final double glowOpacity;

  const AppNeutralColors({
    required this.background,
    required this.cardBackground,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.inputBackground,
    required this.inputBorder,
    required this.divider,
    required this.errorBackground,
    required this.glowOpacity,
  });

  static const dark = AppNeutralColors(
    background: Color(0xFF000000),
    cardBackground: Color(0xFF0A0A0A),
    cardBorder: Color(0xFF262626),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA3A3A3),
    textHint: Color(0xFF6B6B6B),
    inputBackground: Color(0xFF0D0D0D),
    inputBorder: Color(0xFF2A2A2A),
    divider: Color(0xFF262626),
    errorBackground: Color(0xFF1A0E0E),
    glowOpacity: 0.35,
  );

  static const light = AppNeutralColors(
    background: Color(0xFFF6F7F6),
    cardBackground: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE3E6E3),
    textPrimary: Color(0xFF0B0F0D),
    textSecondary: Color(0xFF667066),
    textHint: Color(0xFF9AA39A),
    inputBackground: Color(0xFFF0F2F0),
    inputBorder: Color(0xFFDEE2DE),
    divider: Color(0xFFE3E6E3),
    errorBackground: Color(0xFFFDF0F0),
    glowOpacity: 0.12,
  );

  @override
  AppNeutralColors copyWith({
    Color? background,
    Color? cardBackground,
    Color? cardBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? inputBackground,
    Color? inputBorder,
    Color? divider,
    Color? errorBackground,
    double? glowOpacity,
  }) {
    return AppNeutralColors(
      background: background ?? this.background,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      inputBackground: inputBackground ?? this.inputBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      divider: divider ?? this.divider,
      errorBackground: errorBackground ?? this.errorBackground,
      glowOpacity: glowOpacity ?? this.glowOpacity,
    );
  }

  @override
  AppNeutralColors lerp(ThemeExtension<AppNeutralColors>? other, double t) {
    if (other is! AppNeutralColors) return this;
    return AppNeutralColors(
      background: Color.lerp(background, other.background, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      glowOpacity: t < 0.5 ? glowOpacity : other.glowOpacity,
    );
  }
}

extension AppNeutralColorsContext on BuildContext {
  AppNeutralColors get neutrals =>
      Theme.of(this).extension<AppNeutralColors>()!;

  /// Status bar style matching the current theme — icon brightness *and* an
  /// explicit `statusBarColor` painted the same as the app's background.
  /// Leaving `statusBarColor` transparent lets some OEM skins (Samsung,
  /// MIUI, …) draw their own dim scrim behind it for legibility, which
  /// shows up as a strip that doesn't match the app's actual background;
  /// painting it ourselves removes that mismatch. Pass this to
  /// `AppBar.systemOverlayStyle` explicitly on any AppBar that isn't fully
  /// opaque.
  SystemUiOverlayStyle get statusBarIconStyle {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: neutrals.background,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      // Same reasoning for the Android system nav bar: left unset, many
      // skins paint it white, which shows up as a white strip under our
      // floating bottom nav pill.
      systemNavigationBarColor: neutrals.background,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );
  }
}
