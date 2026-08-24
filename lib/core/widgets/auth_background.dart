import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';
import '../theme/app_neutral_colors.dart';

/// Full-bleed background with the top/bottom green radial glow seen in
/// every auth screen, plus a centered, width-capped, scrollable card so it
/// stays correct on tablets/large screens and when the keyboard opens.
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.neutrals.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _GlowLayer(alignment: Alignment.topCenter),
          const _GlowLayer(alignment: Alignment.bottomCenter),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.xl,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (AppSizes.xl * 2),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSizes.maxFormWidth,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowLayer extends StatelessWidget {
  final Alignment alignment;
  const _GlowLayer({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final opacity = context.neutrals.glowOpacity;
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Container(
          height: 260,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                AppColors.glowGreen.withValues(alpha: opacity),
                AppColors.glowGreen.withValues(alpha: 0.0),
              ],
              radius: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
