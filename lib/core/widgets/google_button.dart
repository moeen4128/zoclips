import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_neutral_colors.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return SizedBox(
      height: AppSizes.buttonHeight,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: neutrals.cardBackground,
          side: BorderSide(color: neutrals.cardBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
        ),
        icon: Icon(
          Icons.g_mobiledata,
          size: 22,
          color: neutrals.textPrimary,
        ), // swap for a real Google asset later
        label: Text(
          'Google',
          style: TextStyle(
            color: neutrals.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
