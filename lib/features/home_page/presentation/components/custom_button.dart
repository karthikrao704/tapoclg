import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onPressed;

  const CustomButton({
    super.key,
    this.icon,
    required this.label,
    this.isPrimary = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Resolve colors based on your theme mappings
    final bgColor = isPrimary
        ? AppColors.primaryColor
        : AppColors.white;

    final contentColor = isPrimary
        ? AppColors.white
        : AppTheme.primaryText;

    // 2. Fetch base text style directly from the theme
    final textStyle = AppFonts.poppinsSemiBold(
      fontSize: 16,
      color: contentColor,
    );

    return Material(
      color: bgColor,
      // 3. Use shape to apply both the border radius and the conditional outline
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPrimary
            ? BorderSide.none
            : BorderSide(color: const Color(0xFFF1F1F1), width: 1.5),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        // Replaced SizedBox with ConstrainedBox to allow vertical growth
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 48, // Acts as your base height
            minWidth: double.infinity,
          ),
          child: Padding(
            // Added vertical padding so wrapped text doesn't touch the borders
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18, // Fixed size for consistency with design
                    color: contentColor,
                  ),
                  const SizedBox(width: 8),
                ],
                // Flexible prevents horizontal overflow and allows multi-line text
                Flexible(
                  child: Text(
                    label,
                    style: textStyle,
                    textAlign:
                        TextAlign.center, // Keeps multi-line text centered
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
