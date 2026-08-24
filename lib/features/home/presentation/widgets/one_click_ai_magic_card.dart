import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../injection_container.dart';
import '../../data/datasources/videos_remote_datasource.dart';

const double _cardRadius = AppSizes.radiusLg + 8;

class OneClickAiMagicCard extends StatefulWidget {
  const OneClickAiMagicCard({super.key});

  @override
  State<OneClickAiMagicCard> createState() => _OneClickAiMagicCardState();
}

class _OneClickAiMagicCardState extends State<OneClickAiMagicCard> {
  final _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      AppSnackbar.error(context, 'Paste a video link first');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await sl<VideosRemoteDataSource>().fetchMetadata(url: url);
      if (!mounted) return;
      AppSnackbar.success(context, 'API is working — metadata request succeeded');
    } on ServerException catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.message);
    } on NetworkException catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.message);
    } on TimeoutException catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return _AnimatedLoadingBorder(
      isLoading: _isLoading,
      radius: _cardRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.xl),
        decoration: BoxDecoration(
          color: neutrals.cardBackground,
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(color: neutrals.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.glowGreen.withValues(alpha: neutrals.glowOpacity),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'One-Click AI Magic',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading(
                neutrals,
              ).copyWith(fontSize: AppSizes.fontXxl),
            ),
            const SizedBox(height: AppSizes.xl),
            _LinkInputField(controller: _urlController),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: _SecondaryActionButton(
                    icon: Icons.upload_outlined,
                    label: 'Upload',
                    onTap: () {}, // design only — wired up later
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: _SecondaryActionButton(
                    icon: Icons.add_to_drive_outlined,
                    label: 'Drive',
                    badge: 'SOON',
                    onTap: () {}, // design only — wired up later
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            _GetClipsButton(isLoading: _isLoading, onTap: _isLoading ? null : _submit),
          ],
        ),
      ),
    );
  }
}

class _LinkInputField extends StatefulWidget {
  final TextEditingController controller;
  const _LinkInputField({required this.controller});

  @override
  State<_LinkInputField> createState() => _LinkInputFieldState();
}

class _LinkInputFieldState extends State<_LinkInputField> {
  static const _placeholders = ['TikTok', 'Vimeo', 'YouTube', 'Facebook', 'Pinterest'];

  late final Timer _timer;
  int _hintIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _hintIndex = (_hintIndex + 1) % _placeholders.length);
    });
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final showHint = widget.controller.text.isEmpty;
    return Container(
      height: AppSizes.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: neutrals.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: neutrals.inputBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.link, size: AppSizes.iconMd, color: neutrals.textSecondary),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                if (showHint)
                  IgnorePointer(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Drop a ', style: AppTextStyles.hintText(neutrals)),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: Text(
                            _placeholders[_hintIndex],
                            key: ValueKey(_hintIndex),
                            style: AppTextStyles.hintText(neutrals),
                          ),
                        ),
                        Text(' link', style: AppTextStyles.hintText(neutrals)),
                      ],
                    ),
                  ),
                TextField(
                  controller: widget.controller,
                  style: AppTextStyles.inputText(neutrals),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Material(
      color: neutrals.inputBackground,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onTap,
        child: Container(
          height: AppSizes.buttonHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: neutrals.inputBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppSizes.iconMd, color: neutrals.textSecondary),
              const SizedBox(width: AppSizes.xs),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.label(
                    neutrals,
                  ).copyWith(fontSize: AppSizes.fontXs),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: AppSizes.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: neutrals.divider,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    badge!,
                    style: AppTextStyles.bodyMuted(neutrals).copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GetClipsButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _GetClipsButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        onTap: onTap,
        child: Container(
          height: AppSizes.buttonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.primaryButtonGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Get clips in 1 click',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Wraps [child] with a comet-tail highlight that travels around its rounded
/// border while [isLoading] is true — the "request in flight" cue for the
/// card, since the button itself has no separate progress affordance.
class _AnimatedLoadingBorder extends StatefulWidget {
  final bool isLoading;
  final double radius;
  final Widget child;

  const _AnimatedLoadingBorder({
    required this.isLoading,
    required this.radius,
    required this.child,
  });

  @override
  State<_AnimatedLoadingBorder> createState() => _AnimatedLoadingBorderState();
}

class _AnimatedLoadingBorderState extends State<_AnimatedLoadingBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _AnimatedLoadingBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _PulsingBorderPainter(
                    progress: _controller.value,
                    color: AppColors.accentGreen,
                    radius: widget.radius,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PulsingBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double radius;

  _PulsingBorderPainter({
    required this.progress,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final metric = (Path()..addRRect(rrect)).computeMetrics().first;
    final length = metric.length;
    final tailLength = length * 0.28;
    const segments = 24;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < segments; i++) {
      final segStart = (progress * length + i * (tailLength / segments)) % length;
      final segLen = tailLength / segments;
      paint.color = color.withValues(alpha: (i / segments) * 0.9);
      canvas.drawPath(_extractWrapped(metric, segStart, segLen), paint);
    }
  }

  Path _extractWrapped(ui.PathMetric metric, double start, double len) {
    final path = Path();
    var s = start % metric.length;
    var remaining = len;
    while (remaining > 0) {
      final end = (s + remaining).clamp(0, metric.length).toDouble();
      path.addPath(metric.extractPath(s, end), Offset.zero);
      remaining -= (end - s);
      s = 0;
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _PulsingBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
