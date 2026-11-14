import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/caption_presets.dart';
import '../cubit/create_clips_cubit.dart';
import '../cubit/create_clips_state.dart';

/// Highlight-color swatches shown under the caption gallery — yellow is the
/// default selected swatch in every screenshot.
const List<Color> kHighlightColorPalette = [
  Color(0xFFFACC15), // yellow
  Color(0xFFEF4444), // red
  Color(0xFF22C55E), // green
  Color(0xFF3B82F6), // blue
  Color(0xFFF97316), // orange
];

const List<String> kAspectRatios = ['9:16', '1:1', '16:9', '4:5'];

class QuickPresetsCard extends StatelessWidget {
  const QuickPresetsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: neutrals.textPrimary,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: Text(
              'Quick presets',
              style: TextStyle(
                color: neutrals.background,
                fontWeight: FontWeight.w700,
                fontSize: AppSizes.fontXs,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const _CaptionGallerySection(),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Text('Caption position', style: AppTextStyles.label(neutrals)),
              const Spacer(),
              const _CaptionPositionToggle(),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Text('Highlight color', style: AppTextStyles.label(neutrals)),
              const Spacer(),
              const _HighlightColorSwatches(),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Text('Choose aspect ratio', style: AppTextStyles.label(neutrals)),
              const Spacer(),
              const _AspectRatioDropdown(),
            ],
          ),
        ],
      ),
    );
  }
}

/// Caption count label, the forward/back scroll arrows, and the horizontal
/// gallery itself — a single [ScrollController] is shared between the
/// arrows and the list so each arrow tap scrolls the same view.
class _CaptionGallerySection extends StatefulWidget {
  const _CaptionGallerySection();

  @override
  State<_CaptionGallerySection> createState() => _CaptionGallerySectionState();
}

class _CaptionGallerySectionState extends State<_CaptionGallerySection> {
  final _controller = ScrollController();

  // One tile (84px) plus its separator (AppSizes.sm) — scrolls roughly
  // three tiles per arrow tap.
  static const _tileExtent = 84.0 + AppSizes.sm;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    if (!_controller.hasClients) return;
    final target = (_controller.offset + delta).clamp(
      0.0,
      _controller.position.maxScrollExtent,
    );
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Caption ',
              style: AppTextStyles.label(
                neutrals,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '(${kCaptionPresets.length - 1} styles)',
              style: AppTextStyles.bodyMuted(neutrals),
            ),
            const Spacer(),
            _ScrollArrowButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => _scrollBy(-_tileExtent * 3),
            ),
            const SizedBox(width: AppSizes.xs),
            _ScrollArrowButton(
              icon: Icons.chevron_right_rounded,
              onTap: () => _scrollBy(_tileExtent * 3),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        _CaptionPresetGallery(controller: _controller),
      ],
    );
  }
}

class _ScrollArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ScrollArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Material(
      color: neutrals.inputBackground,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            icon,
            size: AppSizes.iconSm,
            color: neutrals.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CaptionPresetGallery extends StatelessWidget {
  final ScrollController controller;
  const _CaptionPresetGallery({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateClipsCubit>();
    final selectedId = context.select(
      (CreateClipsCubit c) => c.state.captionPresetId,
    );
    return SizedBox(
      height: 96,
      child: ListView.separated(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemCount: kCaptionPresets.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, index) {
          final preset = kCaptionPresets[index];
          return _CaptionPresetTile(
            preset: preset,
            selected: preset.id == selectedId,
            onTap: () => cubit.setCaptionPreset(preset.id),
          );
        },
      ),
    );
  }
}

class _CaptionPresetTile extends StatelessWidget {
  final CaptionPresetOption preset;
  final bool selected;
  final VoidCallback onTap;
  const _CaptionPresetTile({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 84,
            height: 74,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              border: Border.all(
                color: selected ? AppColors.accentGreen : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                if (preset.badge != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: preset.badge == 'New'
                            ? AppColors.accentGreen
                            : const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        preset.badge!,
                        style: const TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                if (preset.id == 'none')
                  const Center(
                    child: Icon(
                      Icons.block_rounded,
                      color: Colors.white54,
                      size: 20,
                    ),
                  )
                else
                  Center(child: _CaptionPreviewContent(presetId: preset.id)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 84,
            child: Text(
              preset.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted(
                neutrals,
              ).copyWith(color: selected ? AppColors.accentGreen : null),
            ),
          ),
        ],
      ),
    );
  }
}

/// Demo preview rendered inside a caption-preset tile — every style animates
/// (word-by-word highlight sweep, cycling, or typing), none are static, so
/// the gallery actually shows the motion each style applies to captions.
class _CaptionPreviewContent extends StatelessWidget {
  final String presetId;
  const _CaptionPreviewContent({required this.presetId});

  @override
  Widget build(BuildContext context) {
    switch (presetId) {
      case 'one_word':
        return const _AnimatedWordsPreview(
          onlyShowActive: true,
          words: [
            _AnimatedWord('SCROLLING', activeScale: 1.1),
            _AnimatedWord('STOP', activeScale: 1.1),
            _AnimatedWord('NOW', activeScale: 1.1),
          ],
        );
      case 'typewriter':
        return const _TypewriterPreview(text: 'day 47.');
      case 'clean_bar':
        return const _CleanBarPreview();
      case 'gradient_pop':
        return const _GradientPopPreview();
      default:
        return _AnimatedWordsPreview(words: _wordsFor(presetId));
    }
  }

  static List<_AnimatedWord> _wordsFor(String id) {
    switch (id) {
      case 'highlight_pill':
        // The green highlight box sweeps across each word in turn.
        return const [
          _AnimatedWord('MAKE', activeBackground: AppColors.accentGreen),
          _AnimatedWord('MONEY', activeBackground: AppColors.accentGreen),
          _AnimatedWord('ONLINE', activeBackground: AppColors.accentGreen),
        ];
      case 'karaoke':
        return const [
          _AnimatedWord('THIS', activeColor: Color(0xFFFACC15)),
          _AnimatedWord('CHANGED', activeColor: Color(0xFFFACC15)),
          _AnimatedWord('ME', activeColor: Color(0xFFFACC15)),
        ];
      case 'beast_mode':
        return const [
          _AnimatedWord(
            'GO',
            activeColor: Color(0xFF60A5FA),
            activeDecoration: TextDecoration.underline,
          ),
          _AnimatedWord(
            'BIG',
            activeColor: Color(0xFF60A5FA),
            activeDecoration: TextDecoration.underline,
          ),
          _AnimatedWord(
            'TODAY',
            activeColor: Color(0xFF60A5FA),
            activeDecoration: TextDecoration.underline,
          ),
        ];
      case 'hormozi':
        return const [
          _AnimatedWord('WATCH', activeColor: Color(0xFFFACC15)),
          _AnimatedWord('THIS', activeColor: Color(0xFFFACC15)),
          _AnimatedWord('CLIP', activeColor: Color(0xFFFACC15)),
        ];
      case 'neon_glow':
        // Each word has its own glow color, lit up only while active.
        return const [
          _AnimatedWord(
            'CLUTCH',
            activeColor: Color(0xFFD946EF),
            activeShadows: [Shadow(color: Color(0xFFD946EF), blurRadius: 8)],
          ),
          _AnimatedWord(
            'OR',
            activeColor: Color(0xFFEC4899),
            activeShadows: [Shadow(color: Color(0xFFEC4899), blurRadius: 8)],
          ),
          _AnimatedWord(
            'KICK',
            activeColor: Color(0xFFF97316),
            activeShadows: [Shadow(color: Color(0xFFF97316), blurRadius: 8)],
          ),
        ];
      case 'comic_pop':
        return const [
          _AnimatedWord(
            'BEST',
            activeColor: Color(0xFFFACC15),
            activeScale: 1.25,
          ),
          _AnimatedWord(
            'DAY',
            activeColor: Color(0xFFFACC15),
            activeScale: 1.25,
          ),
          _AnimatedWord(
            'EVER',
            activeColor: Color(0xFFFACC15),
            activeScale: 1.25,
          ),
        ];
      case 'aesthetic':
        // Subtle brightness pulse — stays minimal instead of a loud color.
        return const [
          _AnimatedWord(
            'a',
            fontStyle: FontStyle.italic,
            activeColor: Color(0xFFF5F5F5),
            pastColor: Color(0xFFD4D4D4),
            upcomingColor: Color(0xFF737373),
          ),
          _AnimatedWord(
            'quiet',
            fontStyle: FontStyle.italic,
            activeColor: Color(0xFFF5F5F5),
            pastColor: Color(0xFFD4D4D4),
            upcomingColor: Color(0xFF737373),
          ),
          _AnimatedWord(
            'morning',
            fontStyle: FontStyle.italic,
            activeColor: Color(0xFFF5F5F5),
            pastColor: Color(0xFFD4D4D4),
            upcomingColor: Color(0xFF737373),
          ),
        ];
      case '3d_block':
        return const [
          _AnimatedWord(
            'NO',
            activeScale: 1.15,
            activeShadows: [
              Shadow(color: Color(0xFF737373), offset: Offset(2, 2)),
            ],
          ),
          _AnimatedWord(
            'EXCUSES',
            activeScale: 1.15,
            activeShadows: [
              Shadow(color: Color(0xFF737373), offset: Offset(2, 2)),
            ],
          ),
        ];
      case 'bubble':
        return const [
          _AnimatedWord(
            'Just',
            activeBackground: Color(0x40FFFFFF),
            activeScale: 1.1,
          ),
          _AnimatedWord(
            'like',
            activeBackground: Color(0x40FFFFFF),
            activeScale: 1.1,
          ),
          _AnimatedWord(
            'that',
            activeBackground: Color(0x40FFFFFF),
            activeScale: 1.1,
          ),
        ];
      case 'elegant':
        return const [
          _AnimatedWord(
            'Simply',
            fontStyle: FontStyle.italic,
            activeColor: Color(0xFFF97316),
          ),
          _AnimatedWord(
            'timeless',
            fontStyle: FontStyle.italic,
            activeColor: Color(0xFFF97316),
          ),
        ];
      case 'marker':
        // The highlighter mark moves from word to word.
        return const [
          _AnimatedWord('study', activeBackground: Colors.white),
          _AnimatedWord('marker', activeBackground: Color(0xFFFDE68A)),
          _AnimatedWord('today', activeBackground: Color(0xFFFACC15)),
        ];
      case 'glitch':
        return const [
          _AnimatedWord(
            'System',
            activeColor: Color(0xFFEF4444),
            activeShadows: [
              Shadow(color: Color(0xFF22D3EE), offset: Offset(-1.5, 0)),
            ],
          ),
          _AnimatedWord(
            'Error',
            activeColor: Color(0xFF22D3EE),
            activeShadows: [
              Shadow(color: Color(0xFFEF4444), offset: Offset(1.5, 0)),
            ],
          ),
        ];
      case 'classic':
        // No color trick — words simply reveal one at a time.
        return const [
          _AnimatedWord('To', upcomingColor: Color(0x33FFFFFF)),
          _AnimatedWord('get', upcomingColor: Color(0x33FFFFFF)),
          _AnimatedWord('started', upcomingColor: Color(0x33FFFFFF)),
        ];
      default:
        return const [];
    }
  }
}

enum _WordPhase { past, active, upcoming }

class _AnimatedWord {
  final String text;
  final Color activeColor;
  final Color? activeBackground;
  final TextDecoration? activeDecoration;
  final List<Shadow>? activeShadows;
  final FontStyle? fontStyle;
  final Color pastColor;
  final Color upcomingColor;
  final double activeScale;

  const _AnimatedWord(
    this.text, {
    this.activeColor = Colors.white,
    this.activeBackground,
    this.activeDecoration,
    this.activeShadows,
    this.fontStyle,
    this.pastColor = Colors.white,
    this.upcomingColor = const Color(0xFF8B8B8B),
    this.activeScale = 1.0,
  });
}

/// Cycles an "active" word through [words] on a loop — whichever word is
/// active gets its highlight treatment, already-passed words settle back to
/// plain, and upcoming words stay dim, like a caption being read aloud.
class _AnimatedWordsPreview extends StatefulWidget {
  final List<_AnimatedWord> words;
  final bool onlyShowActive;
  const _AnimatedWordsPreview({
    required this.words,
    this.onlyShowActive = false,
  });

  @override
  State<_AnimatedWordsPreview> createState() => _AnimatedWordsPreviewState();
}

class _AnimatedWordsPreviewState extends State<_AnimatedWordsPreview> {
  int _activeIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 750), (_) {
      if (!mounted) return;
      setState(() => _activeIndex = (_activeIndex + 1) % widget.words.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 2,
      children: [
        for (var i = 0; i < widget.words.length; i++)
          if (!widget.onlyShowActive || i == _activeIndex)
            _AnimatedWordText(
              word: widget.words[i],
              phase: i < _activeIndex
                  ? _WordPhase.past
                  : i == _activeIndex
                  ? _WordPhase.active
                  : _WordPhase.upcoming,
            ),
      ],
    );
  }
}

class _AnimatedWordText extends StatelessWidget {
  final _AnimatedWord word;
  final _WordPhase phase;
  const _AnimatedWordText({required this.word, required this.phase});

  @override
  Widget build(BuildContext context) {
    final isActive = phase == _WordPhase.active;
    final Color color;
    if (phase == _WordPhase.past) {
      color = word.pastColor;
    } else if (phase == _WordPhase.upcoming) {
      color = word.upcomingColor;
    } else {
      color = word.activeBackground != null ? Colors.black : word.activeColor;
    }
    return AnimatedScale(
      scale: isActive ? word.activeScale : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: isActive && word.activeBackground != null
            ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isActive ? word.activeBackground : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 9,
            fontStyle: word.fontStyle,
            decoration: isActive ? word.activeDecoration : null,
            shadows: isActive ? word.activeShadows : null,
          ),
          child: Text(word.text),
        ),
      ),
    );
  }
}

/// Cycles the orange "spoken" accent across "watch this closely" inside the
/// persistent white bar.
class _CleanBarPreview extends StatefulWidget {
  const _CleanBarPreview();

  @override
  State<_CleanBarPreview> createState() => _CleanBarPreviewState();
}

class _CleanBarPreviewState extends State<_CleanBarPreview> {
  static const _words = ['watch', 'this', 'closely'];
  int _activeIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 750), (_) {
      if (!mounted) return;
      setState(() => _activeIndex = (_activeIndex + 1) % _words.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 3,
        children: [
          for (var i = 0; i < _words.length; i++)
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                color: i == _activeIndex
                    ? const Color(0xFFF59E0B)
                    : Colors.black,
                fontWeight: i == _activeIndex
                    ? FontWeight.w800
                    : FontWeight.w700,
                fontSize: 8.5,
              ),
              child: Text(_words[i]),
            ),
        ],
      ),
    );
  }
}

/// Cycles the pink-purple gradient fill across "LEVEL UP" one word at a
/// time.
class _GradientPopPreview extends StatefulWidget {
  const _GradientPopPreview();

  @override
  State<_GradientPopPreview> createState() => _GradientPopPreviewState();
}

class _GradientPopPreviewState extends State<_GradientPopPreview> {
  static const _words = ['LEVEL', 'UP'];
  int _activeIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 750), (_) {
      if (!mounted) return;
      setState(() => _activeIndex = (_activeIndex + 1) % _words.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        for (var i = 0; i < _words.length; i++)
          if (i == _activeIndex)
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
              ).createShader(bounds),
              child: Text(
                _words[i],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            )
          else
            Text(
              _words[i],
              style: const TextStyle(
                color: Color(0xFF8B8B8B),
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
      ],
    );
  }
}

/// Types [text] out one character at a time with a blinking cursor, then
/// pauses and loops.
class _TypewriterPreview extends StatefulWidget {
  final String text;
  const _TypewriterPreview({required this.text});

  @override
  State<_TypewriterPreview> createState() => _TypewriterPreviewState();
}

class _TypewriterPreviewState extends State<_TypewriterPreview> {
  Timer? _timer;
  int _visibleChars = 0;
  int _pauseTicks = 0;
  bool _cursorOn = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 160), (_) {
      if (!mounted) return;
      setState(() {
        if (_visibleChars < widget.text.length) {
          _visibleChars++;
          _cursorOn = true;
        } else if (_pauseTicks < 5) {
          _pauseTicks++;
          _cursorOn = !_cursorOn;
        } else {
          _visibleChars = 0;
          _pauseTicks = 0;
          _cursorOn = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = widget.text.substring(
      0,
      _visibleChars.clamp(0, widget.text.length),
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: shown,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          TextSpan(
            text: '|',
            style: TextStyle(
              color: _cursorOn ? Colors.white : Colors.transparent,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _CaptionPositionToggle extends StatelessWidget {
  const _CaptionPositionToggle();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateClipsCubit>();
    final selected = context.select(
      (CreateClipsCubit c) => c.state.captionPosition,
    );
    final neutrals = context.neutrals;
    const options = {
      CaptionPosition.top: 'Top',
      CaptionPosition.center: 'Center',
      CaptionPosition.bottom: 'Bottom',
    };
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: neutrals.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.entries.map((entry) {
          final isSelected = entry.key == selected;
          return GestureDetector(
            onTap: () => cubit.setCaptionPosition(entry.key),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? neutrals.textPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Text(
                entry.value,
                style: AppTextStyles.bodyMuted(neutrals).copyWith(
                  color: isSelected
                      ? neutrals.background
                      : neutrals.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HighlightColorSwatches extends StatelessWidget {
  const _HighlightColorSwatches();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateClipsCubit>();
    final selectedIndex = context.select(
      (CreateClipsCubit c) => c.state.highlightColorIndex,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < kHighlightColorPalette.length; i++)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: GestureDetector(
              onTap: () => cubit.setHighlightColorIndex(i),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: kHighlightColorPalette[i],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i == selectedIndex
                        ? Colors.white
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AspectRatioDropdown extends StatelessWidget {
  const _AspectRatioDropdown();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final cubit = context.read<CreateClipsCubit>();
    final selected = context.select(
      (CreateClipsCubit c) => c.state.aspectRatio,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      decoration: BoxDecoration(
        color: neutrals.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: neutrals.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: neutrals.textSecondary,
          ),
          dropdownColor: neutrals.cardBackground,
          items: kAspectRatios
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Text(r, style: AppTextStyles.inputText(neutrals)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) cubit.setAspectRatio(v);
          },
        ),
      ),
    );
  }
}
