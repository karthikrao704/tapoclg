import 'package:flutter/material.dart';

class TipCard extends StatelessWidget {
  final String tipText;
  const TipCard({super.key, required this.tipText});

  @override
  Widget build(BuildContext context) {
    // Accessing the theme to use defined colors and text styles
    final theme = Theme.of(context);

    // Fetch the system's text scaler to scale non-text UI elements proportionally
    final textScaler = MediaQuery.textScalerOf(context);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Aligns the icon to the top in case the text wraps to multiple lines
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                // Scales the base 18px size by the user's font scale preference
                size: textScaler.scale(18),
                color: theme.colorScheme.onSecondary,
              ),
              const SizedBox(width: 8),
              // Expanded prevents horizontal overflow if the font is huge
              Expanded(
                child: Text(
                  'DAILY WELLNESS TIP',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Body text naturally wraps because it is inside a Column
          Text(
            tipText,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
