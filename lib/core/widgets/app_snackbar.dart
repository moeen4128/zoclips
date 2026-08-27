import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';
import '../theme/app_neutral_colors.dart';
import '../theme/app_text_styles.dart';

enum SnackType { success, error, info }

/// Top-anchored, animated toast — slides down from under the status bar with
/// a fade, sits for [duration], then slides back up and fades out. Lives in
/// the root [Overlay] so it survives navigation and stacks above everything.
class AppSnackbar {
  AppSnackbar._();

  static _TopSnackbarEntry? _current;

  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    _current?.removeImmediately();
    _current = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    final key = GlobalKey<_TopSnackbarState>();

    entry = OverlayEntry(
      builder: (context) => _TopSnackbar(
        key: key,
        message: message,
        type: type,
        duration: duration,
        onDismissed: () {
          entry.remove();
          if (_current?.entry == entry) _current = null;
        },
      ),
    );

    _current = _TopSnackbarEntry(entry: entry, key: key);
    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.error);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.info);
}

class _TopSnackbarEntry {
  final OverlayEntry entry;
  final GlobalKey<_TopSnackbarState> key;
  const _TopSnackbarEntry({required this.entry, required this.key});

  void removeImmediately() {
    key.currentState?.cancelAutoDismiss();
    if (entry.mounted) entry.remove();
  }
}

class _TopSnackbar extends StatefulWidget {
  final String message;
  final SnackType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopSnackbar({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TopSnackbar> createState() => _TopSnackbarState();
}

class _TopSnackbarState extends State<_TopSnackbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _autoDismissTimer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7),
    );
    _controller.forward();
    _autoDismissTimer = Timer(widget.duration, _dismiss);
  }

  void cancelAutoDismiss() => _autoDismissTimer?.cancel();

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _autoDismissTimer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final config = _configFor(widget.type, neutrals);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismiss,
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) < -100) _dismiss();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.sm,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.maxFormWidth,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg,
                        vertical: AppSizes.md,
                      ),
                      decoration: BoxDecoration(
                        color: neutrals.cardBackground,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        border: Border.all(color: config.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      // Overlay entries sit outside any Scaffold, so InkWell
                      // needs its own Material ancestor for splashes to work.
                      child: Material(
                        type: MaterialType.transparency,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: config.iconColor.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                config.icon,
                                color: config.iconColor,
                                size: AppSizes.iconMd,
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Text(
                                widget.message,
                                style: AppTextStyles.inputText(neutrals),
                              ),
                            ),
                            const SizedBox(width: AppSizes.xs),
                            InkWell(
                              onTap: _dismiss,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusPill,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: AppSizes.iconSm,
                                  color: neutrals.textHint,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static _SnackConfig _configFor(SnackType type, AppNeutralColors neutrals) {
    switch (type) {
      case SnackType.success:
        return _SnackConfig(
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
          borderColor: AppColors.success.withValues(alpha: 0.4),
        );
      case SnackType.error:
        return _SnackConfig(
          icon: Icons.error_outline,
          iconColor: AppColors.error,
          borderColor: AppColors.error.withValues(alpha: 0.4),
        );
      case SnackType.info:
        return _SnackConfig(
          icon: Icons.info_outline,
          iconColor: AppColors.accentGreen,
          borderColor: neutrals.cardBorder,
        );
    }
  }
}

class _SnackConfig {
  final IconData icon;
  final Color iconColor;
  final Color borderColor;

  const _SnackConfig({
    required this.icon,
    required this.iconColor,
    required this.borderColor,
  });
}
