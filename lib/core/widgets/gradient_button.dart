import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    return Opacity(
      opacity: disabled && isLoading == false ? 0.6 : 1,
      child: Container(
        height: AppSizes.buttonHeight,
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            onTap: disabled ? null : onPressed,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.black,
                      ),
                    )
                  : Text(label, style: AppTextStyles.button),
            ),
          ),
        ),
      ),
    );
  }
}
