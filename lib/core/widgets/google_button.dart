import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.cardBackground,
          side: const BorderSide(color: AppColors.cardBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
        ),
        icon: const Icon(
          Icons.g_mobiledata,
          size: 22,
          color: Colors.white,
        ), // swap for a real Google asset later
        label: const Text(
          'Google',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
