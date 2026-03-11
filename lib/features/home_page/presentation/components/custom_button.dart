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

    // 1. Resolve colors based on your theme mappings
    final bgColor = isPrimary
        ? theme.colorScheme.primary
        : theme.colorScheme.surface; // Mapped to your Special Card Bg

    final contentColor = isPrimary
        ? theme
              .colorScheme
              .onPrimary // Standard M3 pair for primary elements
        : theme.colorScheme.onSurface; // Mapped to your Special Card Text

    // 2. Fetch base text style directly from the theme
    final textStyle = theme.textTheme.labelLarge?.copyWith(
      color: contentColor,
      // Removed hardcoded FontWeight; the theme's labelLarge handles this natively
    );

    return Material(
      color: bgColor,
      // 3. Use shape to apply both the border radius and the conditional outline
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isPrimary
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline, // Mapped to Borders/Dividers
                width: 1.0,
              ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: contentColor),
                  const SizedBox(width: 8),
                ],
                Text(label, style: textStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
