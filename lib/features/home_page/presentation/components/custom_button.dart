import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    // Fetch the text scaler to adjust the icon size dynamically
    final textScaler = MediaQuery.textScalerOf(context);

    // 1. Resolve colors based on your theme mappings
    final bgColor = isPrimary
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;

    final contentColor = isPrimary
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    // 2. Fetch base text style directly from the theme
    final textStyle = theme.textTheme.labelLarge?.copyWith(color: contentColor);

    return Material(
      color: bgColor,
      // 3. Use shape to apply both the border radius and the conditional outline
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isPrimary
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.outline, width: 1.0),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
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
                    size: textScaler.scale(18), // Scaled dynamically
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
