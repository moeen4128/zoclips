import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../injection_container.dart';
import '../../data/onboarding_storage.dart';

class _OnboardingSlideData {
  final IconData icon;
  final String title;
  final String body;
  const _OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.body,
  });
}

const _slides = [
  _OnboardingSlideData(
    icon: Icons.link_rounded,
    title: AppStrings.onboardingTitle1,
    body: AppStrings.onboardingBody1,
  ),
  _OnboardingSlideData(
    icon: Icons.auto_awesome_rounded,
    title: AppStrings.onboardingTitle2,
    body: AppStrings.onboardingBody2,
  ),
  _OnboardingSlideData(
    icon: Icons.closed_caption_rounded,
    title: AppStrings.onboardingTitle3,
    body: AppStrings.onboardingBody3,
  ),
  _OnboardingSlideData(
    icon: Icons.public_rounded,
    title: AppStrings.onboardingTitle4,
    body: AppStrings.onboardingBody4,
  ),
];

/// First-run-only walkthrough shown after the splash screen, before sign-in.
/// [OnboardingStorage] gates it so it never shows again once completed/skipped.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _slides.length - 1;

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    sl<OnboardingStorage>().markSeen();
    context.goNamed(RouteNames.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Scaffold(
      backgroundColor: neutrals.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.sm,
                  AppSizes.lg,
                  0,
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isLast ? 0 : 1,
                  child: TextButton(
                    onPressed: _isLast ? null : _finish,
                    child: Text(
                      AppStrings.onboardingSkip,
                      style: AppTextStyles.subtitle(neutrals),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _OnboardingSlide(data: _slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => _Dot(active: i == _index),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxFormWidth,
                ),
                child: GradientButton(
                  label: _isLast
                      ? AppStrings.onboardingGetStarted
                      : AppStrings.onboardingNext,
                  onPressed: _next,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingSlideData data;
  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(data.icon, size: 52, color: AppColors.accentGreen),
              ),
              const SizedBox(height: AppSizes.xxl),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading(neutrals),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                data.body,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle(
                  neutrals,
                ).copyWith(fontSize: AppSizes.fontMd),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 22 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.accentGreen : context.neutrals.cardBorder,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
    );
  }
}
