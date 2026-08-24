import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_neutral_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final Widget? trailingLink;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.trailingLink,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: AppTextStyles.label(neutrals)),
            if (widget.trailingLink != null) widget.trailingLink!,
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          style: AppTextStyles.inputText(neutrals),
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: neutrals.textSecondary,
                      size: AppSizes.iconMd,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : (widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: neutrals.textSecondary,
                          size: AppSizes.iconMd,
                        )
                      : null),
          ),
        ),
      ],
    );
  }
}
